//! C ABI between the R glue (`src/datasusr.c`) and the `datasus-core`
//! reader.
//!
//! No R API is called from Rust.  Numeric, logical and date values are
//! written straight into the memory of the R vectors (pointers supplied by
//! the C side); character values are handed back per batch as byte ranges
//! so the C side can create the R strings.  Columns with few distinct
//! values are dictionary-encoded per batch, so each distinct value is
//! turned into an R string once instead of once per row.

use std::ffi::{c_char, c_int, c_void, CStr};
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::path::PathBuf;

use datasus_core::{ColType, Container, Cursor, Encoding, Error, ReadOptions, Sink, Table};

/// R's `NA_integer_` and `NA_logical_`.
const NA_INT: i32 = i32::MIN;
const EMPTY: u32 = u32::MAX;

/// Character values of one column for the current batch.
struct TextCol {
    /// Bytes of the values, concatenated.
    arena: Vec<u8>,
    /// End offset in `arena` of each value.
    ends: Vec<u32>,
    /// Dictionary mode: index into the values for each row of the batch.
    codes: Vec<u32>,
    /// Open-addressing hash table of value indices (dictionary mode).
    table: Vec<u32>,
    /// Dictionary mode is dropped for columns where it does not pay off.
    dict: bool,
}

impl TextCol {
    fn new() -> TextCol {
        TextCol { arena: Vec::new(), ends: Vec::new(), codes: Vec::new(), table: vec![EMPTY; 1024], dict: true }
    }

    fn start_batch(&mut self) {
        // More than half of the rows distinct: the dictionary only adds work.
        if self.dict && self.codes.len() >= 1024 && self.ends.len() * 2 > self.codes.len() {
            self.dict = false;
            self.table = Vec::new();
        }
        self.arena.clear();
        self.ends.clear();
        self.codes.clear();
        if self.dict {
            self.table.fill(EMPTY);
        }
    }

    #[inline]
    fn value(&self, k: usize) -> &[u8] {
        let start = if k == 0 { 0 } else { self.ends[k - 1] as usize };
        &self.arena[start..self.ends[k] as usize]
    }

    #[inline]
    fn push_value(&mut self, raw: &[u8]) -> u32 {
        self.arena.extend_from_slice(raw);
        self.ends.push(self.arena.len() as u32);
        (self.ends.len() - 1) as u32
    }

    fn grow(&mut self) {
        let cap = self.table.len() * 2;
        self.table.clear();
        self.table.resize(cap, EMPTY);
        for k in 0..self.ends.len() {
            let mut slot = hash(self.value(k)) as usize & (cap - 1);
            while self.table[slot] != EMPTY {
                slot = (slot + 1) & (cap - 1);
            }
            self.table[slot] = k as u32;
        }
    }

    #[inline]
    fn push(&mut self, raw: &[u8]) {
        if !self.dict {
            self.push_value(raw);
            return;
        }
        // Runs of equal values are common: skip the hash for them.
        if let Some(&last) = self.codes.last() {
            if self.value(last as usize) == raw {
                self.codes.push(last);
                return;
            }
        }
        let mask = self.table.len() - 1;
        let mut slot = hash(raw) as usize & mask;
        let code = loop {
            let k = self.table[slot];
            if k == EMPTY {
                let k = self.push_value(raw);
                self.table[slot] = k;
                if self.ends.len() * 2 > self.table.len() {
                    self.grow();
                }
                break k;
            }
            if self.value(k as usize) == raw {
                break k;
            }
            slot = (slot + 1) & mask;
        };
        self.codes.push(code);
    }
}

/// FNV-1a; field values are short (at most 255 bytes).
#[inline]
fn hash(bytes: &[u8]) -> u64 {
    let mut h: u64 = 0xcbf29ce484222325;
    for &b in bytes {
        h = (h ^ b as u64).wrapping_mul(0x100000001b3);
    }
    h ^ (h >> 29)
}

pub struct Handle {
    table: Table,
    cursor: Cursor,
    na_real: f64,
    text: Vec<Option<TextCol>>,
}

struct RSink<'a> {
    dest: &'a [*mut c_void],
    base: usize,
    na_real: f64,
    text: &'a mut [Option<TextCol>],
}

impl Sink for RSink<'_> {
    #[inline]
    fn int(&mut self, col: usize, row: usize, value: Option<i32>) {
        // SAFETY: the C side passes, for every non-character column, the
        // data pointer of an R vector with `n_rows` elements of the right
        // type; `base + row < n_rows` because rows are counted by the table.
        unsafe { *(self.dest[col] as *mut i32).add(self.base + row) = value.unwrap_or(NA_INT) }
    }
    #[inline]
    fn double(&mut self, col: usize, row: usize, value: Option<f64>) {
        // SAFETY: as in `int`.
        unsafe { *(self.dest[col] as *mut f64).add(self.base + row) = value.unwrap_or(self.na_real) }
    }
    #[inline]
    fn logical(&mut self, col: usize, row: usize, value: Option<bool>) {
        // SAFETY: as in `int`.
        unsafe {
            *(self.dest[col] as *mut i32).add(self.base + row) = value.map_or(NA_INT, i32::from)
        }
    }
    #[inline]
    fn date(&mut self, col: usize, row: usize, value: Option<i32>) {
        self.int(col, row, value)
    }
    #[inline]
    fn text(&mut self, col: usize, _: usize, raw: &[u8]) {
        if let Some(t) = &mut self.text[col] {
            t.push(raw);
        }
    }
}

#[repr(C)]
pub struct DsrOptions {
    select: *const *const c_char,
    n_select: usize,
    /// Maximum number of rows; infinite or huge means no limit.
    n_max: f64,
    trim_ws: c_int,
    utf8: c_int,
    guess_types: c_int,
    col_type_names: *const *const c_char,
    col_type_values: *const *const c_char,
    n_col_types: usize,
    parse_dates: c_int,
}

unsafe fn strings(ptr: *const *const c_char, n: usize) -> Vec<String> {
    (0..n).map(|i| CStr::from_ptr(*ptr.add(i)).to_string_lossy().into_owned()).collect()
}

#[cfg(unix)]
fn path_from(bytes: &[u8]) -> PathBuf {
    use std::os::unix::ffi::OsStrExt;
    PathBuf::from(std::ffi::OsStr::from_bytes(bytes))
}

#[cfg(not(unix))]
fn path_from(bytes: &[u8]) -> PathBuf {
    PathBuf::from(String::from_utf8_lossy(bytes).into_owned())
}

unsafe fn open(path: *const c_char, o: &DsrOptions, na_real: f64) -> Result<Handle, String> {
    let path_bytes = CStr::from_ptr(path).to_bytes();
    let select = strings(o.select, o.n_select);
    let names = strings(o.col_type_names, o.n_col_types);
    let values = strings(o.col_type_values, o.n_col_types);
    let opts = ReadOptions {
        select: if select.is_empty() { None } else { Some(select) },
        n_max: if o.n_max.is_finite() && o.n_max < 1.8e19 { Some(o.n_max.max(0.0) as u64) } else { None },
        trim_ws: o.trim_ws != 0,
        encoding: if o.utf8 != 0 { Encoding::Utf8 } else { Encoding::Latin1 },
        guess_types: o.guess_types != 0,
        // Unknown type names are ignored, as in the C parser.
        col_types: names
            .into_iter()
            .zip(values)
            .filter_map(|(n, v)| ColType::from_name(&v).map(|t| (n, t)))
            .collect(),
        parse_dates: o.parse_dates != 0,
    };
    let table = datasus_core::open(path_from(path_bytes), &opts).map_err(|e| match e {
        Error::Io(_) => format!("Failed to read DBC file: {}", String::from_utf8_lossy(path_bytes)),
        other => other.to_string(),
    })?;
    let text = table
        .columns()
        .map(|f| matches!(f.col_type, Some(ColType::Character) | None).then(TextCol::new))
        .collect();
    Ok(Handle { table, cursor: Cursor::default(), na_real, text })
}

unsafe fn write_err(err: *mut c_char, err_len: usize, msg: &str) {
    if err.is_null() || err_len == 0 {
        return;
    }
    let n = msg.len().min(err_len - 1);
    std::ptr::copy_nonoverlapping(msg.as_ptr(), err as *mut u8, n);
    *err.add(n) = 0;
}

/// Open and decode a file.  Returns NULL and writes a message to `err` on
/// failure.  The handle must be released with `dsr_free`.
///
/// # Safety
/// `path` and the strings in `opts` must be valid NUL-terminated strings;
/// `err` must point to `err_len` writable bytes.
#[no_mangle]
pub unsafe extern "C" fn dsr_open(
    path: *const c_char,
    opts: *const DsrOptions,
    na_real: f64,
    err: *mut c_char,
    err_len: usize,
) -> *mut Handle {
    match catch_unwind(AssertUnwindSafe(|| open(path, &*opts, na_real))) {
        Ok(Ok(h)) => Box::into_raw(Box::new(h)),
        Ok(Err(msg)) => {
            write_err(err, err_len, &msg);
            std::ptr::null_mut()
        }
        Err(_) => {
            write_err(err, err_len, "Internal error while reading the file.");
            std::ptr::null_mut()
        }
    }
}

/// # Safety
/// `h` must come from `dsr_open` and not have been freed.
#[no_mangle]
pub unsafe extern "C" fn dsr_free(h: *mut Handle) {
    if !h.is_null() {
        drop(Box::from_raw(h));
    }
}

/// # Safety
/// `h` must be a live handle.
#[no_mangle]
pub unsafe extern "C" fn dsr_n_rows(h: *const Handle) -> usize {
    (&*h).table.n_rows()
}

/// # Safety
/// `h` must be a live handle.
#[no_mangle]
pub unsafe extern "C" fn dsr_n_cols(h: *const Handle) -> usize {
    (&*h).table.n_cols()
}

/// # Safety
/// `h` must be a live handle.
#[no_mangle]
pub unsafe extern "C" fn dsr_n_fields(h: *const Handle) -> usize {
    (&*h).table.fields().len()
}

/// 0 plain DBF, 1 truncated DBF, 2 DBC, 3 whole-file DBC.
///
/// # Safety
/// `h` must be a live handle.
#[no_mangle]
pub unsafe extern "C" fn dsr_container(h: *const Handle) -> c_int {
    match (&*h).table.data().container() {
        Container::PlainDbf => 0,
        Container::TruncatedDbf => 1,
        Container::Dbc => 2,
        Container::WholeFileDbc => 3,
    }
}

/// Size in bytes of the uncompressed record area.
///
/// # Safety
/// `h` must be a live handle.
#[no_mangle]
pub unsafe extern "C" fn dsr_records_len(h: *const Handle) -> usize {
    (&*h).table.data().records().len()
}

/// Name of selected column `i` (not NUL-terminated; length in `len`).
///
/// # Safety
/// `h` must be a live handle, `i < dsr_n_cols(h)`, `len` writable.
#[no_mangle]
pub unsafe extern "C" fn dsr_col_name(h: *const Handle, i: usize, len: *mut usize) -> *const c_char {
    let name = &(&*h).table.columns().nth(i).unwrap().name;
    *len = name.len();
    name.as_ptr() as *const c_char
}

/// 0 character, 1 integer, 2 double, 3 logical, 4 date.
///
/// # Safety
/// `h` must be a live handle and `i < dsr_n_cols(h)`.
#[no_mangle]
pub unsafe extern "C" fn dsr_col_type(h: *const Handle, i: usize) -> c_int {
    match (&*h).table.columns().nth(i).unwrap().col_type {
        Some(ColType::Integer) => 1,
        Some(ColType::Double) => 2,
        Some(ColType::Logical) => 3,
        Some(ColType::Date) => 4,
        _ => 0,
    }
}

/// # Safety
/// `h` must be a live handle.
#[no_mangle]
pub unsafe extern "C" fn dsr_n_warnings(h: *const Handle) -> usize {
    (&*h).table.warnings().len()
}

/// # Safety
/// `h` must be a live handle, `i < dsr_n_warnings(h)`, `len` writable.
#[no_mangle]
pub unsafe extern "C" fn dsr_warning(h: *const Handle, i: usize, len: *mut usize) -> *const c_char {
    let w = &(&*h).table.warnings()[i];
    *len = w.len();
    w.as_ptr() as *const c_char
}

/// Decode up to `max_rows` rows.  `dest[c]` is the data pointer of the R
/// vector of column `c` (ignored for character columns); values go to
/// elements `row_offset..`.  Returns the number of rows decoded, 0 at the
/// end, `SIZE_MAX` on an internal error.
///
/// # Safety
/// `h` must be a live handle; `dest` must hold `dsr_n_cols(h)` pointers to
/// vectors of `dsr_n_rows(h)` elements of the column's type.
#[no_mangle]
pub unsafe extern "C" fn dsr_next_batch(
    h: *mut Handle,
    dest: *const *mut c_void,
    row_offset: usize,
    max_rows: usize,
) -> usize {
    let h = &mut *h;
    let dest = std::slice::from_raw_parts(dest, h.table.n_cols());
    catch_unwind(AssertUnwindSafe(|| {
        for t in h.text.iter_mut().flatten() {
            t.start_batch();
        }
        let mut sink = RSink { dest, base: row_offset, na_real: h.na_real, text: &mut h.text };
        h.table.read_rows(&mut h.cursor, max_rows, &mut sink)
    }))
    .unwrap_or(usize::MAX)
}

/// Character values of column `col` for the last batch: `n_values` byte
/// ranges in `arena`, value `k` ending at `ends[k]`.  Returns the per-row
/// indices into the values, or NULL when there is one value per row.
///
/// # Safety
/// `h` must be a live handle, `col` a character column, and the output
/// pointers writable.  The returned pointers are valid until the next
/// `dsr_next_batch` or `dsr_free`.
#[no_mangle]
pub unsafe extern "C" fn dsr_text(
    h: *const Handle,
    col: usize,
    arena: *mut *const c_char,
    ends: *mut *const u32,
    n_values: *mut usize,
) -> *const u32 {
    let t = (&*h).text[col].as_ref().unwrap();
    *arena = t.arena.as_ptr() as *const c_char;
    *ends = t.ends.as_ptr();
    *n_values = t.ends.len();
    if t.dict {
        t.codes.as_ptr()
    } else {
        std::ptr::null()
    }
}

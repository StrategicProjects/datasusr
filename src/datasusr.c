/* R glue for the Rust reader (src/rust, crate 'datasus-core').
 *
 * The Rust side decompresses and parses the file; this file allocates the R
 * vectors and creates the R strings.  No R API is called from Rust: numeric
 * values are written straight into the vectors, character values come back
 * per batch as byte ranges. */

#include <R.h>
#include <Rinternals.h>
#include <R_ext/Print.h>
#include <R_ext/Utils.h>

#include <stddef.h>
#include <stdint.h>
#include <string.h>

#define BATCH_ROWS 65536

typedef struct dsr_handle dsr_handle;

typedef struct {
    const char **select;
    size_t n_select;
    double n_max;
    int trim_ws;
    int utf8;
    int guess_types;
    const char **col_type_names;
    const char **col_type_values;
    size_t n_col_types;
    int parse_dates;
} dsr_options;

dsr_handle *dsr_open(const char *path, const dsr_options *opts, double na_real,
                     char *err, size_t err_len);
void dsr_free(dsr_handle *h);
size_t dsr_n_rows(const dsr_handle *h);
size_t dsr_n_cols(const dsr_handle *h);
size_t dsr_n_fields(const dsr_handle *h);
int dsr_container(const dsr_handle *h);
size_t dsr_records_len(const dsr_handle *h);
const char *dsr_col_name(const dsr_handle *h, size_t i, size_t *len);
int dsr_col_type(const dsr_handle *h, size_t i);
size_t dsr_n_warnings(const dsr_handle *h);
const char *dsr_warning(const dsr_handle *h, size_t i, size_t *len);
size_t dsr_next_batch(dsr_handle *h, void *const *dest, size_t row_offset, size_t max_rows);
const uint32_t *dsr_text(const dsr_handle *h, size_t col, const char **arena,
                         const uint32_t **ends, size_t *n_values);

enum { COL_CHARACTER = 0, COL_INTEGER = 1, COL_DOUBLE = 2, COL_LOGICAL = 3, COL_DATE = 4 };

/* The handle lives in an external pointer so it is released even when an R
   error, warning-as-error or interrupt unwinds through this function. */
static void handle_finalizer(SEXP ptr) {
    dsr_handle *h = (dsr_handle *) R_ExternalPtrAddr(ptr);
    if (h != NULL) {
        dsr_free(h);
        R_ClearExternalPtr(ptr);
    }
}

static const char **string_array(SEXP x, size_t n) {
    const char **out = (const char **) R_alloc(n ? n : 1, sizeof(const char *));
    for (size_t i = 0; i < n; i++) {
        out[i] = CHAR(STRING_ELT(x, (R_xlen_t) i));
    }
    return out;
}

/* The R wrapper validates `encoding` and passes one of "latin1", "UTF-8"
   or "unknown". */
static cetype_t get_encoding_ce(const char *encoding) {
    if (strcmp(encoding, "UTF-8") == 0 || strcmp(encoding, "utf-8") == 0 ||
        strcmp(encoding, "utf8") == 0 || strcmp(encoding, "UTF8") == 0) {
        return CE_UTF8;
    }
    if (strcmp(encoding, "unknown") == 0) {
        return CE_NATIVE;
    }
    return CE_LATIN1;
}

SEXP c_read_datasus_dbc(
    SEXP file_sexp,
    SEXP select_sexp,
    SEXP nmax_sexp,
    SEXP trim_sexp,
    SEXP encoding_sexp,
    SEXP guess_types_sexp,
    SEXP col_types_values_sexp,
    SEXP col_types_names_sexp,
    SEXP parse_dates_sexp,
    SEXP verbose_sexp
) {
    const char *path = CHAR(STRING_ELT(file_sexp, 0));
    cetype_t encoding_ce = get_encoding_ce(CHAR(STRING_ELT(encoding_sexp, 0)));
    int verbose = LOGICAL(verbose_sexp)[0];

    dsr_options opts;
    opts.n_select = TYPEOF(select_sexp) == STRSXP ? (size_t) XLENGTH(select_sexp) : 0;
    opts.select = string_array(select_sexp, opts.n_select);
    opts.n_max = REAL(nmax_sexp)[0];
    opts.trim_ws = LOGICAL(trim_sexp)[0];
    opts.utf8 = encoding_ce == CE_UTF8;
    opts.guess_types = LOGICAL(guess_types_sexp)[0];
    opts.n_col_types = 0;
    if (TYPEOF(col_types_values_sexp) == STRSXP && TYPEOF(col_types_names_sexp) == STRSXP &&
        XLENGTH(col_types_values_sexp) == XLENGTH(col_types_names_sexp)) {
        opts.n_col_types = (size_t) XLENGTH(col_types_names_sexp);
    }
    opts.col_type_names = string_array(col_types_names_sexp, opts.n_col_types);
    opts.col_type_values = string_array(col_types_values_sexp, opts.n_col_types);
    opts.parse_dates = LOGICAL(parse_dates_sexp)[0];

    SEXP handle = PROTECT(R_MakeExternalPtr(NULL, R_NilValue, R_NilValue));
    R_RegisterCFinalizerEx(handle, handle_finalizer, TRUE);

    char err[1024];
    err[0] = '\0';
    dsr_handle *h = dsr_open(path, &opts, NA_REAL, err, sizeof(err));
    if (h == NULL) {
        error("%s", err);
    }
    R_SetExternalPtrAddr(handle, h);

    for (size_t i = 0; i < dsr_n_warnings(h); i++) {
        size_t len;
        const char *msg = dsr_warning(h, i, &len);
        warning("%.*s", (int) len, msg);
    }

    size_t n_rows = dsr_n_rows(h);
    size_t n_cols = dsr_n_cols(h);

    if (verbose) {
        switch (dsr_container(h)) {
        case 0:
            Rprintf("Input already looks like a complete DBF file; skipping blast()\n");
            break;
        case 1:
            Rprintf("Input looks like a truncated plain DBF file; reading available records\n");
            break;
        case 2:
            Rprintf("DBC decompressed successfully from record area\n");
            Rprintf("Decompressed record bytes: %zu\n", dsr_records_len(h));
            break;
        default:
            Rprintf("Whole-file DBC decompressed successfully\n");
            break;
        }
        Rprintf("DBF rows: %zu\n", n_rows);
        Rprintf("DBF fields: %zu\n", dsr_n_fields(h));
        Rprintf("Selected fields: %zu\n", n_cols);
    }

    SEXP out = PROTECT(allocVector(VECSXP, (R_xlen_t) n_cols));
    SEXP out_names = PROTECT(allocVector(STRSXP, (R_xlen_t) n_cols));
    void **dest = (void **) R_alloc(n_cols ? n_cols : 1, sizeof(void *));
    int has_text = 0;

    for (size_t c = 0; c < n_cols; c++) {
        SEXP col;
        switch (dsr_col_type(h, c)) {
        case COL_INTEGER:
            col = PROTECT(allocVector(INTSXP, (R_xlen_t) n_rows));
            dest[c] = INTEGER(col);
            break;
        case COL_DOUBLE:
            col = PROTECT(allocVector(REALSXP, (R_xlen_t) n_rows));
            dest[c] = REAL(col);
            break;
        case COL_LOGICAL:
            col = PROTECT(allocVector(LGLSXP, (R_xlen_t) n_rows));
            dest[c] = LOGICAL(col);
            break;
        case COL_DATE: {
            col = PROTECT(allocVector(INTSXP, (R_xlen_t) n_rows));
            dest[c] = INTEGER(col);
            SEXP cls = PROTECT(mkString("Date"));
            classgets(col, cls);
            UNPROTECT(1);
            break;
        }
        default:
            col = PROTECT(allocVector(STRSXP, (R_xlen_t) n_rows));
            dest[c] = NULL;
            has_text = 1;
            break;
        }
        SET_VECTOR_ELT(out, (R_xlen_t) c, col);

        size_t len;
        const char *name = dsr_col_name(h, c, &len);
        SET_STRING_ELT(out_names, (R_xlen_t) c, mkCharLenCE(name, (int) len, CE_UTF8));
        UNPROTECT(1);
    }

    /* Holds the R strings of the distinct values of one column and batch. */
    SEXP uniq = PROTECT(allocVector(STRSXP, has_text ? BATCH_ROWS : 0));

    size_t done = 0;
    for (;;) {
        size_t n = dsr_next_batch(h, dest, done, BATCH_ROWS);
        if (n == SIZE_MAX) {
            error("Internal error while parsing DBF records.");
        }
        if (n == 0) {
            break;
        }

        for (size_t c = 0; c < n_cols; c++) {
            if (dest[c] != NULL) {
                continue;
            }
            SEXP col = VECTOR_ELT(out, (R_xlen_t) c);
            const char *arena;
            const uint32_t *ends;
            size_t n_values;
            const uint32_t *codes = dsr_text(h, c, &arena, &ends, &n_values);
            uint32_t start = 0;

            if (codes != NULL) {
                for (size_t k = 0; k < n_values; k++) {
                    SET_STRING_ELT(uniq, (R_xlen_t) k,
                                   mkCharLenCE(arena + start, (int) (ends[k] - start), encoding_ce));
                    start = ends[k];
                }
                for (size_t r = 0; r < n; r++) {
                    SET_STRING_ELT(col, (R_xlen_t) (done + r), STRING_ELT(uniq, codes[r]));
                }
            } else {
                for (size_t r = 0; r < n; r++) {
                    SET_STRING_ELT(col, (R_xlen_t) (done + r),
                                   mkCharLenCE(arena + start, (int) (ends[r] - start), encoding_ce));
                    start = ends[r];
                }
            }
        }

        done += n;
        R_CheckUserInterrupt();
    }

    handle_finalizer(handle);

    setAttrib(out, R_NamesSymbol, out_names);
    SEXP df_cls = PROTECT(mkString("data.frame"));
    classgets(out, df_cls);

    SEXP row_names = PROTECT(allocVector(INTSXP, 2));
    INTEGER(row_names)[0] = NA_INTEGER;
    INTEGER(row_names)[1] = -(int) n_rows;
    setAttrib(out, R_RowNamesSymbol, row_names);

    UNPROTECT(6);
    return out;
}

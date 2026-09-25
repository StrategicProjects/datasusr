# Changelog

## datasusr 0.1.1

Robustness release following a code audit of the compiled reader and of
the download layer. No new dependencies.

### Behaviour changes

- Deleted DBF records (`*` flag) are dropped instead of returned as
  all-`NA` rows.
- The cache layout now includes the release period
  (`<cache>/<source>/<file_type>/<period>/<file_name>`); existing caches
  re-download once.
- `timeout` in
  [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
  /
  [`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)
  defaults to `Inf`.
- [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
  gains `success` and `error` columns;
  [`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)
  gains `refresh` and `overwrite` arguments.
- `encoding`, `year`, `month` and `uf` are validated and invalid values
  error.

### DBC / DBF reader (compiled code)

- **Malformed headers are rejected instead of read out of bounds.** The
  declared field widths are now validated against the record length
  before any data is touched (previously a corrupt file could make the
  parser read past the end of its buffer).
- **Deleted records (`*` flag) are dropped.** They used to come back as
  all-`NA` rows. `n_max` now counts live records only.
- **Much lower memory use on character-heavy files**: per-cell scratch
  allocations were replaced by a single reusable buffer.
- **No native memory is leaked on error**: the file and decompression
  buffers are released through `R_UnwindProtect()` whenever an R error
  or interrupt unwinds out of the reader.
- Integer fields are parsed with overflow detection; values outside R’s
  integer range (including `-2147483648`, R’s `NA` sentinel) are
  inferred as `double` or returned as `NA` instead of a wrong number.
- Numeric, logical and date fields are always trimmed before parsing;
  `trim_ws` now only affects character output (with `trim_ws = FALSE`,
  padded numbers used to become `NA`).
- Invalid dates such as `20240231` are now `NA` instead of rolling over
  into the next month.
- `encoding` is validated: `"latin1"` (and the `latin-1` / `ISO-8859-1`
  aliases), `"UTF-8"` and `"unknown"` are accepted; anything else errors
  instead of being silently treated as Latin-1.
- `select` and `col_types` names are matched case-insensitively against
  the DBF field names, and `select` names that match no column raise a
  warning instead of silently returning fewer columns.
- A DBF whose data area is shorter than its header declares now reads
  the available records with a warning; a truncated plain DBF no longer
  fails with a misleading decompression error.
- A very small DBC whose compressed payload is larger than its
  uncompressed record area is no longer mistaken for a plain DBF (the
  record-flag bytes are checked in addition to the file size).
- `n_max` is floored to a whole number of rows.

### Catalog, downloads and cache

- **`SIM`/`DO` and `SINASC`/`DN` without `uf` now list all 27 UFs**
  (previously zero files were returned).
- **Cache layout now includes the period**:
  `<cache>/<source>/<file_type>/<period>/<file_name>`. Final and
  preliminary releases of the same file (e.g. `DOPE2022.dbc`) used to
  share one path, which made
  [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
  fail with “Duplicate destfiles” or served a stale preliminary file
  forever. Existing caches will re-download once.
- **Failed or interrupted downloads no longer poison the cache**: files
  are downloaded to a `.part` name and renamed only on success; partial
  files are removed.
  [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
  gains `success` and `error` columns and `downloaded` reflects the real
  outcome.
  [`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)
  skips failed files with a warning and errors if every download failed.
- **[`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)
  prefers final over preliminary data**: when the same file (matched
  case-insensitively, and treating `SINAN_P` / `ESUSNOTIFICA_P` as
  preliminary aliases of `SINAN` / `ESUSNOTIFICA`) is available in both
  trees only the final copy is read, so rows are not duplicated. A final
  candidate that could not be confirmed on the FTP does not suppress a
  preliminary copy known to exist.
  [`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)
  also gains `refresh` and `overwrite` arguments (the vignette
  documented `refresh` but it was not accepted).
- **`timeout` no longer caps the whole transfer.** It used to be passed
  to libcurl as the total time allowed per file (240 s), which aborted
  large files on the slow DATASUS FTP. It now defaults to `Inf`; stalled
  transfers are detected with a connect timeout and a low-speed limit
  instead.
- FTP listing failures are reported with a warning and the affected
  files keep `exists = NA`, instead of being silently reported as
  absent.
- [`datasus_build_path()`](https://strategicprojects.github.io/datasusr/reference/datasus_build_path.md)
  no longer recycles a vector `year` against the SINASC path templates
  (which produced a warning and wrong paths).
- `SINAN_P` was advertised in
  [`datasus_sources()`](https://strategicprojects.github.io/datasusr/reference/datasus_sources.md)
  but had no file types and could never be fetched; its file types are
  now registered.
- `year`, `month` and `uf` are validated before any network access.
- File names are matched against the FTP listing case-insensitively,
  keeping the server’s spelling in the download URL.
- `datasus_download(use_cache = FALSE)` without `dest_dir` writes to a
  fresh subdirectory of
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) instead of the
  working directory, and `overwrite = FALSE` is honoured in that mode.
- [`datasus_get_territory()`](https://strategicprojects.github.io/datasusr/reference/datasus_get_territory.md)
  copes with upper-case member names inside the territorial ZIP.
- New offline test suite (`tests/testthat`) covering the DBF parser with
  synthetic files and the catalog / cache / download logic with
  `file://` URLs.

## datasusr 0.1.0

CRAN release: 2026-05-04

### CRAN review fixes

- `DESCRIPTION` now consistently single-quotes external software/API
  names (‘DATASUS’, ‘DBC’, ‘DBF’, ‘FTP’, ‘C’, ‘PKWare DCL’, ‘blast’,
  ‘zlib’) and unquotes the in-package function reference
  [`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md).
  The description field also now references the upstream sources
  (DATASUS file transfer site and Adler 2003 for the bundled blast
  decompressor).
- All examples switched from `\dontrun{}` to `\donttest{}`. Network-
  dependent examples are wrapped in
  [`tryCatch()`](https://rdrr.io/r/base/conditions.html) and write to
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) so that running
  them never touches the user’s home filespace.
- The default cache directory is now a session-scoped subdirectory of
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) instead of
  `tools::R_user_dir("datasusr", "cache")`. To opt in to a persistent
  cache across sessions, set the `DATASUSR_CACHE_DIR` environment
  variable, the `datasusr.cache_dir` R option, or pass `cache_dir`
  explicitly.

### Breaking changes

- Package version bumped to 0.1.0 to reflect the expanded scope beyond
  just reading DBC files.

### New features

- **[`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)**:
  high-level convenience function that lists, downloads, and reads
  DATASUS files in a single call. Supports column selection, type
  specification, and row-binding of multiple files.
- **`DATASUSR_CACHE_DIR` environment variable**: the cache directory now
  respects the `DATASUSR_CACHE_DIR` env var in addition to the existing
  `datasusr.cache_dir` option.
- [`format_bytes()`](https://strategicprojects.github.io/datasusr/reference/format_bytes.md)
  is now exported for general use.

### Bug fixes

- **SIM path templates**: `DOEXT`, `DOINF`, and `DOMAT` are served from
  the same `DOFET` FTP directory as `DOFET` (verified against the live
  FTP); the templates register that directory for each of them.
- **Fixed column/argument name shadowing** in
  [`datasus_build_path()`](https://strategicprojects.github.io/datasusr/reference/datasus_build_path.md),
  [`datasus_file_types()`](https://strategicprojects.github.io/datasusr/reference/datasus_file_types.md),
  and
  [`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md).
  Column names like `source` and `file_type` no longer clash with
  function arguments thanks to proper use of `.env$` pronouns.
- **Download failures no longer abort the loop**: individual FTP
  download errors are caught and reported without stopping the remaining
  downloads.
- Empty file lists now return immediately from
  [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
  instead of proceeding with zero iterations.

### Improvements

- **Removed all `.data$` pronoun usage** inside `dplyr` verbs. Columns
  are now referenced with bare (tidy evaluation) names, and external
  variables use `.env$` where needed. This follows current tidyverse
  best practice.
- **Replaced deprecated purrr functions**: `pmap_dfr()` replaced with
  `map2() |> list_rbind()`.
- **Replaced
  [`purrr::map_lgl()`](https://purrr.tidyverse.org/reference/map.html)
  in cache functions** with base
  [`vapply()`](https://rdrr.io/r/base/lapply.html) for fewer
  dependencies in hot paths.
- **Improved CLI messages throughout**: all user-facing messages now use
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
  with structured hints (`i` bullets) instead of bare
  [`stop()`](https://rdrr.io/r/base/stop.html). Progress messages are
  more concise and informative.
- **Wrapped FTP connection errors** with a user-friendly message
  suggesting a connectivity check.
- `rlang` is now an explicit dependency (was already an indirect dep via
  `dplyr`), making the `%||%` import explicit.
- Added `rlang (>= 1.0.0)` and `dplyr (>= 1.1.0)` minimum version
  constraints.
- Vignettes expanded with richer explanations and a new comparison
  article.
- pkgdown site structure updated with a comparison article.
- Compiled `.o` and `.so` files excluded from the source bundle via
  `.Rbuildignore`.

## datasusr 0.0.7.3

- Fixed dplyr data-masking bugs in catalog and file listing helpers.
- Removed `.data$` usage inside mutate pipelines and simplified
  tidyverse expressions.
- Improved verbose output in
  [`read_datasus_dbc()`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md)
  so row and column counts print on separate lines.

## datasusr 0.0.7.1

- Fixed `datasus_file_types(source = ...)` filtering consistency.
- Improved `cli` spacing and summary formatting in key functions.
- Filtered invalid source/file type combinations earlier in
  [`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md).

## datasusr 0.0.7

- Standardized user-facing progress and status messages with `cli`.
- Added progress bars and cache-hit messages to
  [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md).
- Added optional `verbose` control to FTP, listing, and cache helpers.
- Improved cache summaries with human-readable sizes.

## datasusr 0.0.6

- Added a configurable cache layer for DATASUS downloads.
- Added
  [`datasus_cache_dir()`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_dir.md),
  [`datasus_cache_list()`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_list.md),
  [`datasus_cache_info()`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_info.md),
  [`datasus_cache_clear()`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_clear.md),
  and
  [`datasus_cache_prune()`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_prune.md).
- Integrated cache-aware downloads into
  [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md).

## datasusr 0.0.5

- Added DATASUS catalog helpers:
  [`datasus_sources()`](https://strategicprojects.github.io/datasusr/reference/datasus_sources.md),
  [`datasus_modalities()`](https://strategicprojects.github.io/datasusr/reference/datasus_modalities.md),
  [`datasus_file_types()`](https://strategicprojects.github.io/datasusr/reference/datasus_file_types.md),
  and
  [`datasus_ufs()`](https://strategicprojects.github.io/datasusr/reference/datasus_ufs.md).
- Added FTP helpers:
  [`datasus_ftp_ls()`](https://strategicprojects.github.io/datasusr/reference/datasus_ftp_ls.md),
  [`datasus_build_path()`](https://strategicprojects.github.io/datasusr/reference/datasus_build_path.md),
  [`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md),
  and
  [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md).

## datasusr 0.0.4

- Added `guess_types`, `col_types`, and `parse_dates` to
  [`read_datasus_dbc()`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md).
- Improved DBC handling for files with DBF headers plus compressed
  record areas.

# datasusr 0.1.0

## CRAN review fixes

- `DESCRIPTION` now consistently single-quotes external software/API
  names ('DATASUS', 'DBC', 'DBF', 'FTP', 'C', 'PKWare DCL', 'blast',
  'zlib') and unquotes the in-package function reference
  `datasus_fetch()`. The description field also now references the
  upstream sources (DATASUS file transfer site and Adler 2003 for the
  bundled blast decompressor).
- All examples switched from `\dontrun{}` to `\donttest{}`. Network-
  dependent examples are wrapped in `tryCatch()` and write to
  `tempdir()` so that running them never touches the user's home
  filespace.
- The default cache directory is now a session-scoped subdirectory of
  `tempdir()` instead of `tools::R_user_dir("datasusr", "cache")`. To
  opt in to a persistent cache across sessions, set the
  `DATASUSR_CACHE_DIR` environment variable, the `datasusr.cache_dir`
  R option, or pass `cache_dir` explicitly.

## Breaking changes

- Package version bumped to 0.1.0 to reflect the expanded scope beyond just
  reading DBC files.

## New features

- **`datasus_fetch()`**: high-level convenience function that lists, downloads,
  and reads DATASUS files in a single call. Supports column selection,
  type specification, and row-binding of multiple files.
- **`DATASUSR_CACHE_DIR` environment variable**: the cache directory now
  respects the `DATASUSR_CACHE_DIR` env var in addition to the existing
  `datasusr.cache_dir` option.
- `format_bytes()` is now exported for general use.

## Bug fixes

- **Fixed SIM path templates**: `DOEXT`, `DOINF`, and `DOMAT` previously
  pointed to the `DOFET` FTP directory. Each now has its own correct path.
- **Fixed column/argument name shadowing** in `datasus_build_path()`,
  `datasus_file_types()`, and `datasus_list_files()`. Column names like
  `source` and `file_type` no longer clash with function arguments thanks
  to proper use of `.env$` pronouns.
- **Download failures no longer abort the loop**: individual FTP download
  errors are caught and reported without stopping the remaining downloads.
- Empty file lists now return immediately from `datasus_download()` instead
  of proceeding with zero iterations.

## Improvements

- **Removed all `.data$` pronoun usage** inside `dplyr` verbs. Columns are
  now referenced with bare (tidy evaluation) names, and external variables
  use `.env$` where needed. This follows current tidyverse best practice.
- **Replaced deprecated purrr functions**: `pmap_dfr()` replaced with
  `map2() |> list_rbind()`.
- **Replaced `purrr::map_lgl()` in cache functions** with base `vapply()`
  for fewer dependencies in hot paths.
- **Improved CLI messages throughout**: all user-facing messages now use
  `cli::cli_abort()` with structured hints (`i` bullets) instead of
  bare `stop()`. Progress messages are more concise and informative.
- **Wrapped FTP connection errors** with a user-friendly message suggesting
  a connectivity check.
- `rlang` is now an explicit dependency (was already an indirect dep via
  `dplyr`), making the `%||%` import explicit.
- Added `rlang (>= 1.0.0)` and `dplyr (>= 1.1.0)` minimum version
constraints.
- Vignettes expanded with richer explanations and a new comparison article.
- pkgdown site structure updated with a comparison article.
- Compiled `.o` and `.so` files excluded from the source bundle via
  `.Rbuildignore`.

# datasusr 0.0.7.3

- Fixed dplyr data-masking bugs in catalog and file listing helpers.
- Removed `.data$` usage inside mutate pipelines and simplified tidyverse
  expressions.
- Improved verbose output in `read_datasus_dbc()` so row and column counts
  print on separate lines.

# datasusr 0.0.7.1

- Fixed `datasus_file_types(source = ...)` filtering consistency.
- Improved `cli` spacing and summary formatting in key functions.
- Filtered invalid source/file type combinations earlier in
  `datasus_list_files()`.

# datasusr 0.0.7

- Standardized user-facing progress and status messages with `cli`.
- Added progress bars and cache-hit messages to `datasus_download()`.
- Added optional `verbose` control to FTP, listing, and cache helpers.
- Improved cache summaries with human-readable sizes.

# datasusr 0.0.6

- Added a configurable cache layer for DATASUS downloads.
- Added `datasus_cache_dir()`, `datasus_cache_list()`,
  `datasus_cache_info()`, `datasus_cache_clear()`, and
  `datasus_cache_prune()`.
- Integrated cache-aware downloads into `datasus_download()`.

# datasusr 0.0.5

- Added DATASUS catalog helpers: `datasus_sources()`,
  `datasus_modalities()`, `datasus_file_types()`, and `datasus_ufs()`.
- Added FTP helpers: `datasus_ftp_ls()`, `datasus_build_path()`,
  `datasus_list_files()`, and `datasus_download()`.

# datasusr 0.0.4

- Added `guess_types`, `col_types`, and `parse_dates` to
  `read_datasus_dbc()`.
- Improved DBC handling for files with DBF headers plus compressed record
  areas.

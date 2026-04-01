# Changelog

## datasusr 0.1.0

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

- **Fixed SIM path templates**: `DOEXT`, `DOINF`, and `DOMAT` previously
  pointed to the `DOFET` FTP directory. Each now has its own correct
  path.
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

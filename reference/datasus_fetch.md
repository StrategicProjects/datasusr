# Fetch DATASUS data in one step

A convenience wrapper that lists, downloads, and reads DATASUS files in
a single call. Particularly useful for interactive / exploratory work.

## Usage

``` r
datasus_fetch(
  source,
  file_type,
  year = NULL,
  month = NULL,
  uf = NULL,
  ...,
  bind = TRUE,
  include_prelim = TRUE,
  timeout = Inf,
  use_cache = TRUE,
  cache_dir = NULL,
  refresh = FALSE,
  overwrite = FALSE,
  verbose = TRUE
)
```

## Arguments

- source:

  Character vector of source codes.

- file_type:

  Character vector of file type codes.

- year:

  Integer vector of years.

- month:

  Integer vector of months (required for monthly sources).

- uf:

  Character vector of UF codes (required for UF-scoped sources).

- ...:

  Additional arguments forwarded to
  [`read_datasus_dbc()`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md)
  (e.g. `select`, `col_types`, `parse_dates`).

- bind:

  Logical. When `TRUE` (the default), all files are row-bound into a
  single tibble. When `FALSE`, a list of tibbles is returned.

- include_prelim:

  Logical. Include preliminary data trees (default `TRUE`).

- timeout:

  Optional hard cap, in seconds, on each file transfer (default `Inf`,
  no cap); see
  [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md).
  A finite value is also used for the FTP listing (otherwise 120
  seconds).

- use_cache:

  Logical. Reuse cached downloads (default `TRUE`).

- cache_dir:

  Optional cache directory.

- refresh:

  Logical. Force re-download even when a cached file exists (default
  `FALSE`). Forwarded to
  [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md).

- overwrite:

  Logical. Re-download files that already exist at the destination
  (default `FALSE`). Forwarded to
  [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md).

- verbose:

  Logical. Emit progress messages (default `TRUE`).

## Value

A tibble (when `bind = TRUE`) or a named list of tibbles. List names are
the file names; when the same file name comes from more than one FTP
tree they are prefixed with the period (e.g. `"prelim/DOPE2022.dbc"`).

## Details

Files that fail to download are skipped with a warning; if every
download fails, an error is raised.

When the same file is available both as a final release and as a
preliminary one (a SIM `DO` year that has just been consolidated, or a
`SINAN` file requested together with its `SINAN_P` alias), only the
final version is read, so rows are not duplicated. A final file that
could not be confirmed on the FTP does not suppress a preliminary copy
that is known to exist. Use
[`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md)
and
[`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
directly to work with both copies.

## Examples

``` r
# \donttest{
tryCatch({
  # Fetch a small SIHSUS slice into tempdir() (network required).
  df <- datasus_fetch(
    source    = "SIHSUS",
    file_type = "RD",
    year      = 2024,
    month     = 1,
    uf        = "AC",
    select    = c("uf_zi", "ano_cmpt", "munic_res", "val_tot"),
    cache_dir = tempdir(),
    verbose   = FALSE
  )
}, error = function(e) message("FTP unavailable: ", conditionMessage(e)))
# }
```

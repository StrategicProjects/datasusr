# Download DATASUS files

Downloads one or many DATASUS files. When `use_cache = TRUE`, files that
already exist in the cache directory are reused instead of
re-downloaded.

## Usage

``` r
datasus_download(
  files = NULL,
  ...,
  dest_dir = NULL,
  overwrite = FALSE,
  timeout = Inf,
  use_cache = TRUE,
  cache_dir = NULL,
  refresh = FALSE,
  verbose = TRUE
)
```

## Arguments

- files:

  A tibble returned by
  [`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md).
  When `NULL`, additional filters are forwarded to
  [`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md).

- ...:

  Filters passed to
  [`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md)
  when `files` is `NULL`.

- dest_dir:

  Optional destination directory. When `NULL`, the package cache
  directory is used if `use_cache = TRUE`; otherwise a fresh
  subdirectory of [`tempdir()`](https://rdrr.io/r/base/tempfile.html) is
  used.

- overwrite:

  Logical. Re-download files even when they already exist at the
  destination (default `FALSE`).

- timeout:

  Optional hard cap, in seconds, on the total transfer time of each file
  (default `Inf`, no cap). Stalled transfers are always detected
  independently: the connection must be established within 60 seconds
  and a transfer is aborted when it stays below 1 byte/s for 120
  seconds. When `files` is `NULL`, a finite `timeout` is also used for
  the FTP listing (otherwise 120 seconds).

- use_cache:

  Logical. Store and reuse downloads in the cache directory (default
  `TRUE`).

- cache_dir:

  Optional cache directory.

- refresh:

  Logical. Force re-download even when a cached file exists (default
  `FALSE`).

- verbose:

  Logical. Emit progress messages (default `TRUE`).

## Value

The `files` tibble with additional columns: `local_file` (path to the
local copy), `downloaded` (`TRUE` when the file was transferred in this
call), `success` (`TRUE` when `local_file` is available, either
downloaded or reused from the cache), `error` (the failure message, `NA`
on success) and `cache_dir`.

## Details

Files are stored as `<dir>/<source>/<file_type>/<period>/<file_name>`,
where `<dir>` is `dest_dir` or the cache directory and `<period>` is the
FTP tree the file came from (`"current"`, `"historical"` or `"prelim"`).
Keeping the period in the path means a preliminary file never shadows
the final file of the same name. When `files` lacks the
`source`/`file_type`/`period` columns, the corresponding path components
are omitted.

Each file is first written to a temporary `<file_name>.part` file and
only renamed to its final name when the transfer succeeds, so an
interrupted or failed download never becomes a cache hit.

## Examples

``` r
# \donttest{
tryCatch({
  files <- datasus_list_files(
    source = "SIHSUS", file_type = "RD",
    year = 2024, month = 1, uf = "AC",
    verbose = FALSE
  )
  downloads <- datasus_download(
    files,
    cache_dir = tempdir(),
    verbose   = FALSE
  )
}, error = function(e) message("FTP unavailable: ", conditionMessage(e)))
# }
```

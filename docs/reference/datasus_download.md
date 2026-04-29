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
  timeout = 240,
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

  Optional destination directory. When `NULL` and `use_cache = TRUE`,
  the package cache directory is used.

- overwrite:

  Logical. Overwrite existing files (default `FALSE`).

- timeout:

  Timeout in seconds for each download (default 240).

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

A tibble with a `local_file` column containing the paths to the
downloaded files, plus a `downloaded` flag.

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

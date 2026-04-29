# Cache and downloads

`datasusr` can cache DATASUS downloads in a local directory so that
repeated calls do not hit the DATASUS FTP again. This is especially
useful when developing analysis pipelines interactively.

## How caching works

When you call
[`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
with `use_cache = TRUE` (the default), files are stored in a structured
subdirectory tree under the cache folder. On subsequent calls for the
same files, the cached versions are reused without any network access.

``` r

library(datasusr)

downloads <- datasus_fetch(
  source    = "SIHSUS",
  file_type = c("RD", "SP"),
  year      = 2024,
  month     = 1,
  uf        = c("PE", "PB")
)
```

## Configuring the cache directory

By default, downloads are placed in a session-scoped subdirectory of
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) (which R cleans up
automatically when the session ends), so the package never writes
outside the user-controlled tempdir unless you opt in.

The cache location is resolved in the following order:

1.  The `cache_dir` function argument
2.  The `DATASUSR_CACHE_DIR` environment variable
3.  The `datasusr.cache_dir` R option
4.  The session default (`file.path(tempdir(), "datasusr-cache")`)

To enable a persistent cache that survives across sessions, point one of
the above to a directory of your choice — for example
`tools::R_user_dir("datasusr", "cache")` — and the cache becomes truly
persistent.

To set it globally, add a line to your `.Renviron`:

    DATASUSR_CACHE_DIR=/path/to/my/cache

Or in R:

``` r

options(datasusr.cache_dir = "/path/to/my/cache")
```

## Inspecting the cache

``` r

# Quick summary
datasus_cache_info(verbose = TRUE)

# Detailed listing of all cached files
datasus_cache_list()
```

## Forcing a re-download

Pass `refresh = TRUE` to
[`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
(or
[`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md))
to re-download files even when they exist in the cache:

``` r

datasus_download(files, refresh = TRUE)
```

## Pruning and clearing the cache

Over time the cache can grow large. Two functions help manage its size:

``` r

# Remove files older than 90 days
datasus_cache_prune(older_than_days = 90)

# Keep the total cache under 5 GB
datasus_cache_prune(max_size_bytes = 5 * 1024^3)

# Remove everything
datasus_cache_clear()
```

When pruning by size, the least-recently-accessed files are removed
first.

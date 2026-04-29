# Resolve the datasusr cache directory

Returns the active cache directory path. Checks, in order: the
`cache_dir` argument, the `DATASUSR_CACHE_DIR` environment variable, the
`datasusr.cache_dir` option, and finally a session-scoped subdirectory
of [`tempdir()`](https://rdrr.io/r/base/tempfile.html). To opt in to a
persistent cache across sessions, set the `DATASUSR_CACHE_DIR`
environment variable, the `datasusr.cache_dir` option, or pass
`cache_dir` explicitly (for example,
`tools::R_user_dir("datasusr", "cache")`).

## Usage

``` r
datasus_cache_dir(cache_dir = NULL)
```

## Arguments

- cache_dir:

  Optional cache directory supplied by the caller.

## Value

A single path string.

## Examples

``` r
datasus_cache_dir()
#> [1] "/var/folders/j9/7g_srh2x0d71c5q0pbj5mxh40000gn/T//Rtmp7l1NmS/datasusr-cache"
```

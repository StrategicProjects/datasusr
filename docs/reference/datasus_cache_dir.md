# Resolve the datasusr cache directory

Returns the active cache directory path. Checks, in order: the
`cache_dir` argument, the `DATASUSR_CACHE_DIR` environment variable, the
`datasusr.cache_dir` option, and finally the default user cache
directory.

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
#> [1] "/Users/leite/Library/Caches/org.R-project.R/R/datasusr"
```

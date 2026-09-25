# List cached DATASUS files

Returns a tibble describing every file currently stored in the cache
directory.

## Usage

``` r
datasus_cache_list(cache_dir = NULL)
```

## Arguments

- cache_dir:

  Optional cache directory.

## Value

A tibble with columns `path`, `file_name`, `size_bytes`,
`modified_time`, and `accessed_time`.

## Examples

``` r
datasus_cache_list()
#> # A tibble: 0 × 5
#> # ℹ 5 variables: path <chr>, file_name <chr>, size_bytes <dbl>,
#> #   modified_time <dttm>, accessed_time <dttm>
```

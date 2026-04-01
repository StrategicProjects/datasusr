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
#> # A tibble: 1 × 5
#>   path              file_name size_bytes modified_time       accessed_time      
#>   <chr>             <chr>          <dbl> <dttm>              <dttm>             
#> 1 /Users/leite/Lib… RDPE2401…    3695686 2025-02-09 21:30:54 2025-02-09 21:30:54
```

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
#> # A tibble: 38 × 5
#>    path             file_name size_bytes modified_time       accessed_time      
#>    <chr>            <chr>          <dbl> <dttm>              <dttm>             
#>  1 /Users/leite/Li… tb_munic…     663434 2026-04-01 00:02:19 2026-04-01 00:02:19
#>  2 /Users/leite/Li… 12-base …    1517583 2026-04-01 00:02:19 2026-04-01 00:02:19
#>  3 /Users/leite/Li… tb_munic…     905726 2026-03-31 23:58:40 2026-03-31 23:58:40
#>  4 /Users/leite/Li… 10-base_…    1699756 2026-03-31 23:58:40 2026-03-31 23:58:40
#>  5 /Users/leite/Li… tb_munic…    2185087 2026-03-31 23:57:55 2026-03-31 23:57:55
#>  6 /Users/leite/Li… base_ter…    2434673 2026-03-31 23:57:55 2026-03-31 23:57:55
#>  7 /Users/leite/Li… tb_munic…     722830 2026-03-31 23:57:14 2026-03-31 23:57:14
#>  8 /Users/leite/Li… 02-base_…    1733670 2026-03-31 23:57:14 2026-03-31 23:57:14
#>  9 /Users/leite/Li… ZIKABR23…     870752 2026-03-31 23:15:54 2026-03-31 23:15:54
#> 10 /Users/leite/Li… CHIKBR23…    9801216 2026-03-31 23:15:31 2026-03-31 23:15:31
#> # ℹ 28 more rows
```

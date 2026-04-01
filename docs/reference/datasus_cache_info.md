# Summarise the datasusr cache

Returns a one-row tibble summarising the current cache: directory path,
file count, total size, and modification time range.

## Usage

``` r
datasus_cache_info(cache_dir = NULL, verbose = TRUE)
```

## Arguments

- cache_dir:

  Optional cache directory.

- verbose:

  Logical. Print a summary to the console (default `TRUE`).

## Value

A tibble with one row.

## Examples

``` r
datasus_cache_info()
#> 
#> ── datasusr cache ──
#> 
#> ℹ Directory: /Users/leite/Library/Caches/org.R-project.R/R/datasusr
#> ℹ Files: 1
#> ℹ Total size: 3.52 MB
#> # A tibble: 1 × 6
#>   cache_dir              n_files total_size_bytes total_size oldest_modified    
#>   <chr>                    <int>            <dbl> <chr>      <dttm>             
#> 1 /Users/leite/Library/…       1          3695686 3.52 MB    2025-02-09 21:30:54
#> # ℹ 1 more variable: newest_modified <dttm>
```

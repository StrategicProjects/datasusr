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
#> ℹ Directory: /var/folders/j9/7g_srh2x0d71c5q0pbj5mxh40000gn/T//Rtmp7l1NmS/datasusr-cache
#> ℹ Files: 0
#> ℹ Total size: 0 B
#> # A tibble: 1 × 6
#>   cache_dir              n_files total_size_bytes total_size oldest_modified
#>   <chr>                    <int>            <dbl> <chr>      <dttm>         
#> 1 /var/folders/j9/7g_sr…       0                0 0 B        NA             
#> # ℹ 1 more variable: newest_modified <dttm>
```

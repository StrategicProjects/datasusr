# Format byte sizes for display

Converts raw byte counts into human-readable strings (e.g. `"1.23 MB"`).

## Usage

``` r
format_bytes(x)
```

## Arguments

- x:

  Numeric vector of byte sizes.

## Value

A character vector with formatted sizes.

## Examples

``` r
format_bytes(c(1024, 1048576, NA))
#> [1] "1 KB" "1 MB" NA    
```

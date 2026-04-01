# Build DATASUS FTP paths from filters

Builds candidate FTP directories for a given source and file type. For
SIH/SIA, the function selects historical vs. current trees by
year/month. For SIM and SINASC, preliminary trees are included when
requested.

## Usage

``` r
datasus_build_path(
  source,
  file_type,
  year = NULL,
  month = NULL,
  include_prelim = TRUE
)
```

## Arguments

- source:

  Source code (e.g. `"SIHSUS"`).

- file_type:

  File type code (e.g. `"RD"`).

- year:

  Integer vector of years.

- month:

  Integer vector of months.

- include_prelim:

  Logical. Include preliminary trees when available (default `TRUE`).

## Value

A tibble with columns `source`, `file_type`, `period`, and `path`.

## Examples

``` r
datasus_build_path(source = "SIHSUS", file_type = "RD", year = 2024, month = 1)
#> # A tibble: 1 × 4
#>   source file_type period  path                                                 
#>   <chr>  <chr>     <chr>   <chr>                                                
#> 1 SIHSUS NA        current ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/20…
```

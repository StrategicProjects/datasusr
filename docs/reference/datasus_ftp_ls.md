# List files and directories from the DATASUS FTP

Fetches a raw directory listing from a DATASUS FTP path.

## Usage

``` r
datasus_ftp_ls(path, timeout = 120, ftp_use_epsv = FALSE, verbose = TRUE)
```

## Arguments

- path:

  FTP path or full URL. Relative paths are prefixed with the DATASUS
  public FTP root.

- timeout:

  Timeout in seconds (default 120).

- ftp_use_epsv:

  Logical. Passed to curl (default `FALSE`).

- verbose:

  Logical. Emit progress messages (default `TRUE`).

## Value

A tibble with columns `ftp_url` and `entry`.

## Examples

``` r
# \donttest{
tryCatch(
  datasus_ftp_ls("SIHSUS/200801_/Dados/", verbose = FALSE),
  error = function(e) message("FTP unavailable: ", conditionMessage(e))
)
#> # A tibble: 22,369 × 2
#>    ftp_url                                                          entry       
#>    <chr>                                                            <chr>       
#>  1 ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/ CHBR1901.dbc
#>  2 ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/ CHBR1902.dbc
#>  3 ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/ CHBR1903.dbc
#>  4 ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/ CHBR1904.dbc
#>  5 ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/ CHBR1905.dbc
#>  6 ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/ CHBR1906.dbc
#>  7 ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/ CHBR1907.dbc
#>  8 ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/ CHBR1908.dbc
#>  9 ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/ CHBR1909.dbc
#> 10 ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/ CHBR1910.dbc
#> # ℹ 22,359 more rows
# }
```

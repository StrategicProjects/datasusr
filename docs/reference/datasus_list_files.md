# List available DATASUS files

Builds candidate file names from the internal catalog and, optionally,
validates them against the DATASUS FTP.

## Usage

``` r
datasus_list_files(
  source,
  file_type,
  year = NULL,
  month = NULL,
  uf = NULL,
  include_prelim = TRUE,
  check_exists = TRUE,
  timeout = 120,
  ftp_use_epsv = FALSE,
  verbose = TRUE
)
```

## Arguments

- source:

  Character vector of source codes.

- file_type:

  Character vector of file type codes.

- year:

  Integer vector of years.

- month:

  Integer vector of months (required for monthly sources).

- uf:

  Character vector of UF codes (required for UF-scoped sources).

- include_prelim:

  Logical. Include preliminary data trees (default `TRUE`).

- check_exists:

  Logical. Query the FTP and keep only files that exist (default
  `TRUE`). Setting to `FALSE` skips FTP access and returns all candidate
  files.

- timeout:

  Timeout in seconds for FTP requests (default 120).

- ftp_use_epsv:

  Logical. Passed to curl (default `FALSE`).

- verbose:

  Logical. Emit progress messages (default `TRUE`).

## Value

A tibble with one row per file, including its FTP URL and metadata.

## Examples

``` r
# \donttest{
tryCatch(
  datasus_list_files(
    source    = "SIHSUS",
    file_type = "RD",
    year      = 2024,
    month     = 1,
    uf        = c("PE", "PB"),
    verbose   = FALSE
  ),
  error = function(e) message("FTP unavailable: ", conditionMessage(e))
)
#> # A tibble: 2 × 11
#>   source file_type description       scope frequency availability period  path  
#>   <chr>  <chr>     <chr>             <chr> <chr>     <chr>        <chr>   <chr> 
#> 1 SIHSUS RD        RD - AIH Reduzida UF    monthly   current      current ftp:/…
#> 2 SIHSUS RD        RD - AIH Reduzida UF    monthly   current      current ftp:/…
#> # ℹ 3 more variables: file_name <chr>, url <chr>, exists <lgl>
# }
```

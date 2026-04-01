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
if (FALSE) { # \dontrun{
datasus_ftp_ls("SIHSUS/200801_/Dados/")
} # }
```

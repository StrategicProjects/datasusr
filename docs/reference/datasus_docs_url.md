# Get FTP URLs for DATASUS documentation

Returns the FTP URLs where documentation files (layouts, data
dictionaries) for each source system can be found. Use
[`datasus_ftp_ls()`](https://strategicprojects.github.io/datasusr/reference/datasus_ftp_ls.md)
to list the actual files at each URL.

## Usage

``` r
datasus_docs_url(source = NULL)
```

## Arguments

- source:

  Optional source code to filter (e.g. `"SIHSUS"`). When `NULL`, all
  known documentation paths are returned.

## Value

A tibble with columns `source` and `docs_url`.

## Examples

``` r
datasus_docs_url()
#> # A tibble: 5 × 2
#>   source docs_url                                                      
#>   <chr>  <chr>                                                         
#> 1 SIHSUS ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Doc/
#> 2 SIASUS ftp://ftp.datasus.gov.br/dissemin/publicos/SIASUS/200801_/Doc/
#> 3 CNES   ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Doc/  
#> 4 SIM    ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DOC/     
#> 5 SINASC ftp://ftp.datasus.gov.br/dissemin/publicos/SINASC/1996_/Doc/  
datasus_docs_url("CNES")
#> # A tibble: 1 × 2
#>   source docs_url                                                    
#>   <chr>  <chr>                                                       
#> 1 CNES   ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Doc/

if (FALSE) { # \dontrun{
# List documentation files for CNES
docs <- datasus_docs_url("CNES")
datasus_ftp_ls(docs$docs_url[[1]])
} # }
```

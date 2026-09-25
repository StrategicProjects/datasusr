# List DATASUS data sources

Returns the internal catalog of DATASUS sources available in `datasusr`.

## Usage

``` r
datasus_sources()
```

## Value

A tibble with one row per source, including its code, description,
default scope, and flags for monthly and UF support.

## Examples

``` r
datasus_sources()
#> # A tibble: 17 × 7
#>    source   description default_scope supports_month supports_uf access verified
#>    <chr>    <chr>       <chr>         <lgl>          <lgl>       <chr>  <lgl>   
#>  1 BASE_TE… Base Terri… BR            FALSE          FALSE       terri… TRUE    
#>  2 CIH      CIH - Sist… UF            TRUE           TRUE        fetch  FALSE   
#>  3 CIHA     CIHA - Sis… UF            TRUE           TRUE        fetch  FALSE   
#>  4 CNES     CNES - Cad… UF            TRUE           TRUE        fetch  TRUE    
#>  5 DATASUS  Aplicativo… BR            FALSE          FALSE       ftp_o… TRUE    
#>  6 ESUSNOT… e-SUS Noti… BR            FALSE          FALSE       fetch  FALSE   
#>  7 ESUSNOT… e-SUS Noti… BR            FALSE          FALSE       fetch  FALSE   
#>  8 PCE      PCE - Prog… UF            FALSE          TRUE        fetch  FALSE   
#>  9 PO       PO - Paine… BR            FALSE          FALSE       fetch  FALSE   
#> 10 RESP     RESP - Not… UF            FALSE          TRUE        fetch  FALSE   
#> 11 SIASUS   SIASUS - S… UF            TRUE           TRUE        fetch  TRUE    
#> 12 SIHSUS   SIHSUS - S… UF            TRUE           TRUE        fetch  TRUE    
#> 13 SIM      SIM - Sist… TT            FALSE          TRUE        fetch  TRUE    
#> 14 SINAN    SINAN - Si… BR            FALSE          FALSE       fetch  FALSE   
#> 15 SINAN_P  SINAN prel… BR            FALSE          FALSE       fetch  FALSE   
#> 16 SINASC   SINASC - S… TT            FALSE          TRUE        fetch  TRUE    
#> 17 SISPREN… SISPRENATA… UF            TRUE           TRUE        fetch  FALSE   
```

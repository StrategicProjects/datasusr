# List DATASUS modalities

Returns the available DATASUS data modalities (data, documentation,
programs, etc.).

## Usage

``` r
datasus_modalities()
```

## Value

A tibble.

## Examples

``` r
datasus_modalities()
#> # A tibble: 7 × 4
#>   modality_code modality      description                        subdir         
#>           <int> <chr>         <chr>                              <chr>          
#> 1             0 auxiliary     Arquivos auxiliares para tabulacao Auxiliar       
#> 2             1 data          Dados                              Dados          
#> 3             2 documentation Documentacao                       DOCS           
#> 4             3 programs      Programas                          Programas      
#> 5             4 territorial   Bases territoriais                 Base_Territori…
#> 6             5 maps          Mapas                              Mapas          
#> 7             6 conversions   Conversoes                         Conversoes     
```

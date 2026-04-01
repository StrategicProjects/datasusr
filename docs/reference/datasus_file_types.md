# List DATASUS file types

Returns the internal catalog of file types. Optionally filtered by
source and/or file type codes.

## Usage

``` r
datasus_file_types(source = NULL, file_type = NULL)
```

## Arguments

- source:

  Optional character vector of source codes (e.g. `"SIHSUS"`).

- file_type:

  Optional character vector of file type codes (e.g. `"RD"`).

## Value

A tibble.

## Examples

``` r
datasus_file_types()
#> # A tibble: 69 × 6
#>    source           file_type description           scope frequency availability
#>    <chr>            <chr>     <chr>                 <chr> <chr>     <chr>       
#>  1 BASE_TERRITORIAL CNV       Conversoes            BR    static    current     
#>  2 BASE_TERRITORIAL MAP       Bases Mapas           BR    static    current     
#>  3 BASE_TERRITORIAL TER       Bases Territoriais    BR    static    current     
#>  4 CIH              CR        CR - Comunicacao de … UF    monthly   current     
#>  5 CIHA             CIHA      CIHA - Comunicacao d… UF    monthly   current     
#>  6 CNES             DC        DC - Dados Complemen… UF    monthly   current     
#>  7 CNES             EE        EE - Estabelecimento… UF    monthly   current     
#>  8 CNES             EF        EF - Estabelecimento… UF    monthly   current     
#>  9 CNES             EP        EP - Equipes          UF    monthly   current     
#> 10 CNES             EQ        EQ - Equipamentos     UF    monthly   current     
#> # ℹ 59 more rows
datasus_file_types(source = "SIHSUS")
#> # A tibble: 4 × 6
#>   source file_type description                      scope frequency availability
#>   <chr>  <chr>     <chr>                            <chr> <chr>     <chr>       
#> 1 SIHSUS ER        ER - AIH Rejeitadas com codigo … UF    monthly   current     
#> 2 SIHSUS RD        RD - AIH Reduzida                UF    monthly   current     
#> 3 SIHSUS RJ        RJ - AIH Rejeitadas              UF    monthly   current     
#> 4 SIHSUS SP        SP - Servicos Profissionais      UF    monthly   current     
datasus_file_types(source = "CNES", file_type = "ST")
#> # A tibble: 1 × 6
#>   source file_type description           scope frequency availability
#>   <chr>  <chr>     <chr>                 <chr> <chr>     <chr>       
#> 1 CNES   ST        ST - Estabelecimentos UF    monthly   current     
```

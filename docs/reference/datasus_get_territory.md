# Download DATASUS territorial tables

Downloads and reads tables from the DATASUS territorial data section.
The DATASUS FTP publishes a ZIP archive per year containing reference
tables for municipalities, health regions, and other geographic
divisions used by SUS, in CSV, DBF, and TXT formats.

## Usage

``` r
datasus_get_territory(
  table = "tb_municip",
  year = NULL,
  format = "csv",
  cache_dir = NULL,
  verbose = TRUE
)
```

## Arguments

- table:

  Name of the table to read. Common values: `"tb_municip"`
  (municipalities), `"tb_uf"` (states), `"tb_regsaud"` (health regions),
  `"tb_macsaud"` (macro health regions), `"tb_regiao"` (geographic
  regions), `"tb_micibge"` (IBGE micro-regions), `"tb_regmetr"`
  (metropolitan regions), `"tb_dsei"` (indigenous health districts).
  Relationship tables start with `"rl_"` (e.g. `"rl_municip_regsaud"`).

- year:

  Year of the territorial table. Defaults to the current year. Use
  `datasus_ftp_ls("ftp://ftp.datasus.gov.br/territorio/tabelas/")` to
  see available years.

- format:

  File format to extract from the ZIP: `"csv"` (default) or `"dbf"`.

- cache_dir:

  Optional cache directory.

- verbose:

  Logical. Emit progress messages (default `TRUE`).

## Value

A tibble with column names in snake_case.

## Examples

``` r
if (FALSE) { # \dontrun{
# Municipalities
municipios <- datasus_get_territory("tb_municip")

# Health regions
regioes <- datasus_get_territory("tb_regsaud")

# States
ufs <- datasus_get_territory("tb_uf")

# Specific year
municipios_2023 <- datasus_get_territory("tb_municip", year = 2023)

# List available years
datasus_ftp_ls("ftp://ftp.datasus.gov.br/territorio/tabelas/")
} # }
```

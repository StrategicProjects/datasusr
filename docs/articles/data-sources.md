# Available data sources

This vignette provides a reference of every DATASUS data source
registered in `datasusr`, with ready-to-run examples for each one.

## Source catalog overview

``` r

library(datasusr)

datasus_sources()
```

The `access` column indicates which function to use with each source:

- **`fetch`** — use
  [`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md),
  or the step-by-step workflow with
  [`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md),
  [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md),
  and
  [`read_datasus_dbc()`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md).
  These sources contain `.dbc` files on the DATASUS FTP.
- **`territory`** — use
  [`datasus_get_territory()`](https://strategicprojects.github.io/datasusr/reference/datasus_get_territory.md).
  These are CSV reference tables (municipalities, health regions, etc.).
- **`ftp_only`** — use
  [`datasus_ftp_ls()`](https://strategicprojects.github.io/datasusr/reference/datasus_ftp_ls.md)
  to browse. These are software downloads (TabWin, TabNet), not data
  files.

## Hospital information (SIH)

The Hospital Information System (SIHSUS) publishes monthly files by
state.

``` r

# Reduced Hospital Admission Records
df <- datasus_fetch(
  source = "SIHSUS", file_type = "RD",
  year = 2024, month = 1, uf = "PE",
  select = c("uf_zi", "ano_cmpt", "munic_res", "val_tot")
)

# Rejected admissions
df <- datasus_fetch(
  source = "SIHSUS", file_type = "RJ",
  year = 2024, month = 1, uf = "PE"
)

# Professional services
df <- datasus_fetch(
  source = "SIHSUS", file_type = "SP",
  year = 2024, month = 1, uf = "PE"
)
```

## Outpatient information (SIA)

The Outpatient Information System (SIASUS) also publishes monthly files
by state.

``` r

# Outpatient production
df <- datasus_fetch(
  source = "SIASUS", file_type = "PA",
  year = 2024, month = 1, uf = "PE"
)

# Medication authorisations (APAC)
df <- datasus_fetch(
  source = "SIASUS", file_type = "AM",
  year = 2024, month = 1, uf = "PE"
)
```

## Mortality (SIM)

The Mortality Information System (SIM) publishes yearly files. Death
records (DO) are scoped by state; specialised subsets (DOFET, DOEXT,
DOINF, DOMAT) cover all of Brazil.

``` r

# Death records by state (4-digit year in file name)
df <- datasus_fetch(
  source = "SIM", file_type = "DO",
  year = 2022, uf = "PE"
)

# Foetal deaths
df <- datasus_fetch(
  source = "SIM", file_type = "DOFET",
  year = 2022
)

# Deaths from external causes
df <- datasus_fetch(
  source = "SIM", file_type = "DOEXT",
  year = 2022
)

# Infant deaths
df <- datasus_fetch(
  source = "SIM", file_type = "DOINF",
  year = 2022
)

# Maternal deaths
df <- datasus_fetch(
  source = "SIM", file_type = "DOMAT",
  year = 2022
)
```

## Live births (SINASC)

The Live Birth Information System publishes yearly files by state.

``` r

df <- datasus_fetch(
  source = "SINASC", file_type = "DN",
  year = 2022, uf = "PE"
)
```

## Health facilities (CNES)

The National Registry of Health Facilities publishes monthly files by
state across many subtypes.

``` r

# Facilities
df <- datasus_fetch(
  source = "CNES", file_type = "ST",
  year = 2024, month = 1, uf = "PE"
)

# Hospital beds
df <- datasus_fetch(
  source = "CNES", file_type = "LT",
  year = 2024, month = 1, uf = "PE"
)

# Professionals
df <- datasus_fetch(
  source = "CNES", file_type = "PF",
  year = 2024, month = 1, uf = "PE"
)

# Equipment
df <- datasus_fetch(
  source = "CNES", file_type = "EQ",
  year = 2024, month = 1, uf = "PE"
)

# Specialised services
df <- datasus_fetch(
  source = "CNES", file_type = "SR",
  year = 2024, month = 1, uf = "PE"
)
```

See `datasus_file_types(source = "CNES")` for the full list of CNES
subtypes (LT, ST, DC, EQ, SR, HB, PF, EP, RC, IN, EE, EF, GM).

## Hospital and outpatient reporting (CIHA / CIH)

CIHA replaced CIH in 2011. Both publish monthly files by state.

``` r

# CIHA (2011 onwards)
df <- datasus_fetch(
  source = "CIHA", file_type = "CIHA",
  year = 2024, month = 1, uf = "PE"
)

# CIH (historical, 2008-2011)
df <- datasus_fetch(
  source = "CIH", file_type = "CR",
  year = 2010, month = 1, uf = "PE"
)
```

## Notifiable diseases (SINAN)

SINAN publishes yearly files with national scope (no UF filter needed).

``` r

# Dengue
df <- datasus_fetch(
  source = "SINAN", file_type = "DENG",
  year = 2023
)

# Chikungunya
df <- datasus_fetch(
  source = "SINAN", file_type = "CHIK",
  year = 2023
)

# Zika
df <- datasus_fetch(
  source = "SINAN", file_type = "ZIKA",
  year = 2023
)

# Malaria
df <- datasus_fetch(
  source = "SINAN", file_type = "MALA",
  year = 2023
)
```

Preliminary SINAN data is available through the `SINAN_P` source.

## Other disease surveillance

``` r

# e-SUS Notifica (chronic Chagas disease)
df <- datasus_fetch(
  source = "ESUSNOTIFICA", file_type = "DCCR",
  year = 2023
)

# Suspected congenital Zika syndrome (RESP)
df <- datasus_fetch(
  source = "RESP", file_type = "RESP",
  year = 2022, uf = "PE"
)
```

## Oncology panel

``` r

df <- datasus_fetch(
  source = "PO", file_type = "PO",
  year = 2022
)
```

## Schistosomiasis control (PCE)

``` r

df <- datasus_fetch(
  source = "PCE", file_type = "PCE",
  year = 2022, uf = "PE"
)
```

## Discontinued and replaced systems

SISCOLO and SISMAMA were replaced by SISCAN and are no longer available
on the DATASUS FTP. SISPRENATAL data may still be available for
historical periods.

``` r

# Prenatal monitoring (historical)
df <- datasus_fetch(
  source = "SISPRENATAL", file_type = "PN",
  year = 2014, month = 1, uf = "PE"
)
```

## Territorial reference tables

Territorial data (municipality names, health regions, geographic
divisions) is published as CSV files organised by year. Use
[`datasus_get_territory()`](https://strategicprojects.github.io/datasusr/reference/datasus_get_territory.md):

``` r

# Municipality table (defaults to current year)
municipalities <- datasus_get_territory("tb_municip")
municipalities

# Specific year
municipalities_2023 <- datasus_get_territory("tb_municip", year = 2023)

# Browse available years and tables
datasus_ftp_ls("ftp://ftp.datasus.gov.br/territorio/tabelas/")
```

## Documentation and data dictionaries

Each information system has documentation files on the DATASUS FTP. Use
[`datasus_docs_url()`](https://strategicprojects.github.io/datasusr/reference/datasus_docs_url.md)
to find them:

``` r

# All known documentation paths
datasus_docs_url()

# List documentation files for a specific system
datasus_ftp_ls(datasus_docs_url("CNES")$docs_url[[1]])
```

## Connectivity check

The following code tests path resolution for every source and file type
in the catalog:

``` r

library(dplyr)

sources_dbc <- datasus_sources() |>
  filter(access == "fetch")

results <- purrr::map(seq_len(nrow(sources_dbc)), \(i) {
  src <- sources_dbc$source[[i]]
  fts <- datasus_file_types(source = src)

  purrr::map(seq_len(nrow(fts)), \(j) {
    ft <- fts$file_type[[j]]
    ok <- tryCatch({
      datasus_build_path(source = src, file_type = ft, year = 2023, month = 1)
      TRUE
    }, error = function(e) FALSE)
    tibble::tibble(source = src, file_type = ft, has_path = ok)
  }) |> purrr::list_rbind()
}) |> purrr::list_rbind()

results |> print(n = Inf)
```

## Cleaning up

The examples above download files to the local cache. To remove all
cached files after testing:

``` r

datasus_cache_info()
datasus_cache_clear()
```

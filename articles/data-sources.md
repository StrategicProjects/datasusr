# Available data sources

This vignette provides a reference of every DATASUS data source
registered in `datasusr`, with ready-to-run examples for each one.

## Source catalog overview

[`library`](https://rdrr.io/r/base/library.html)`(`[`datasusr`](https://strategicprojects.github.io/datasusr/)`)`` `` `[`datasus_sources`](https://strategicprojects.github.io/datasusr/reference/datasus_sources.md)`(``)`

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

`# Reduced Hospital Admission Records`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIHSUS"``, file_type ``=`` ``"RD"``,`` `` year ``=`` ``2024``, month ``=`` ``1``, uf ``=`` ``"PE"``,`` `` select ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"uf_zi"``, ``"ano_cmpt"``, ``"munic_res"``, ``"val_tot"``)`` ``)`` `` ``# Rejected admissions`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIHSUS"``, file_type ``=`` ``"RJ"``,`` `` year ``=`` ``2024``, month ``=`` ``1``, uf ``=`` ``"PE"`` ``)`` `` ``# Professional services`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIHSUS"``, file_type ``=`` ``"SP"``,`` `` year ``=`` ``2024``, month ``=`` ``1``, uf ``=`` ``"PE"`` ``)`

## Outpatient information (SIA)

The Outpatient Information System (SIASUS) also publishes monthly files
by state.

`# Outpatient production`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIASUS"``, file_type ``=`` ``"PA"``,`` `` year ``=`` ``2024``, month ``=`` ``1``, uf ``=`` ``"PE"`` ``)`` `` ``# Medication authorisations (APAC)`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIASUS"``, file_type ``=`` ``"AM"``,`` `` year ``=`` ``2024``, month ``=`` ``1``, uf ``=`` ``"PE"`` ``)`

## Mortality (SIM)

The Mortality Information System (SIM) publishes yearly files. Death
records (DO) are scoped by state; specialised subsets (DOFET, DOEXT,
DOINF, DOMAT) cover all of Brazil.

`# Death records by state (4-digit year in file name)`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIM"``, file_type ``=`` ``"DO"``,`` `` year ``=`` ``2022``, uf ``=`` ``"PE"`` ``)`` `` ``# Foetal deaths`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIM"``, file_type ``=`` ``"DOFET"``,`` `` year ``=`` ``2022`` ``)`` `` ``# Deaths from external causes`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIM"``, file_type ``=`` ``"DOEXT"``,`` `` year ``=`` ``2022`` ``)`` `` ``# Infant deaths`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIM"``, file_type ``=`` ``"DOINF"``,`` `` year ``=`` ``2022`` ``)`` `` ``# Maternal deaths`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIM"``, file_type ``=`` ``"DOMAT"``,`` `` year ``=`` ``2022`` ``)`

## Live births (SINASC)

The Live Birth Information System publishes yearly files by state.

`df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SINASC"``, file_type ``=`` ``"DN"``,`` `` year ``=`` ``2022``, uf ``=`` ``"PE"`` ``)`

## Health facilities (CNES)

The National Registry of Health Facilities publishes monthly files by
state across many subtypes.

`# Facilities`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"CNES"``, file_type ``=`` ``"ST"``,`` `` year ``=`` ``2024``, month ``=`` ``1``, uf ``=`` ``"PE"`` ``)`` `` ``# Hospital beds`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"CNES"``, file_type ``=`` ``"LT"``,`` `` year ``=`` ``2024``, month ``=`` ``1``, uf ``=`` ``"PE"`` ``)`` `` ``# Professionals`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"CNES"``, file_type ``=`` ``"PF"``,`` `` year ``=`` ``2024``, month ``=`` ``1``, uf ``=`` ``"PE"`` ``)`` `` ``# Equipment`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"CNES"``, file_type ``=`` ``"EQ"``,`` `` year ``=`` ``2024``, month ``=`` ``1``, uf ``=`` ``"PE"`` ``)`` `` ``# Specialised services`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"CNES"``, file_type ``=`` ``"SR"``,`` `` year ``=`` ``2024``, month ``=`` ``1``, uf ``=`` ``"PE"`` ``)`

See `datasus_file_types(source = "CNES")` for the full list of CNES
subtypes (LT, ST, DC, EQ, SR, HB, PF, EP, RC, IN, EE, EF, GM).

## Hospital and outpatient reporting (CIHA / CIH)

CIHA replaced CIH in 2011. Both publish monthly files by state.

`# CIHA (2011 onwards)`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"CIHA"``, file_type ``=`` ``"CIHA"``,`` `` year ``=`` ``2024``, month ``=`` ``1``, uf ``=`` ``"PE"`` ``)`` `` ``# CIH (historical, 2008-2011)`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"CIH"``, file_type ``=`` ``"CR"``,`` `` year ``=`` ``2010``, month ``=`` ``1``, uf ``=`` ``"PE"`` ``)`

## Notifiable diseases (SINAN)

SINAN publishes yearly files with national scope (no UF filter needed).

`# Dengue`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SINAN"``, file_type ``=`` ``"DENG"``,`` `` year ``=`` ``2023`` ``)`` `` ``# Chikungunya`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SINAN"``, file_type ``=`` ``"CHIK"``,`` `` year ``=`` ``2023`` ``)`` `` ``# Zika`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SINAN"``, file_type ``=`` ``"ZIKA"``,`` `` year ``=`` ``2023`` ``)`` `` ``# Malaria`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SINAN"``, file_type ``=`` ``"MALA"``,`` `` year ``=`` ``2023`` ``)`

Preliminary SINAN data is available through the `SINAN_P` source.

## Other disease surveillance

`# e-SUS Notifica (chronic Chagas disease)`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"ESUSNOTIFICA"``, file_type ``=`` ``"DCCR"``,`` `` year ``=`` ``2023`` ``)`` `` ``# Suspected congenital Zika syndrome (RESP)`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"RESP"``, file_type ``=`` ``"RESP"``,`` `` year ``=`` ``2022``, uf ``=`` ``"PE"`` ``)`

## Oncology panel

`df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"PO"``, file_type ``=`` ``"PO"``,`` `` year ``=`` ``2022`` ``)`

## Schistosomiasis control (PCE)

`df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"PCE"``, file_type ``=`` ``"PCE"``,`` `` year ``=`` ``2022``, uf ``=`` ``"PE"`` ``)`

## Discontinued and replaced systems

SISCOLO and SISMAMA were replaced by SISCAN and are no longer available
on the DATASUS FTP. SISPRENATAL data may still be available for
historical periods.

`# Prenatal monitoring (historical)`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SISPRENATAL"``, file_type ``=`` ``"PN"``,`` `` year ``=`` ``2014``, month ``=`` ``1``, uf ``=`` ``"PE"`` ``)`

## Territorial reference tables

Territorial data (municipality names, health regions, geographic
divisions) is published as CSV files organised by year. Use
[`datasus_get_territory()`](https://strategicprojects.github.io/datasusr/reference/datasus_get_territory.md):

`# Municipality table (defaults to current year)`` ``municipalities`` ``<-`` `[`datasus_get_territory`](https://strategicprojects.github.io/datasusr/reference/datasus_get_territory.md)`(``"tb_municip"``)`` ``municipalities`` `` ``# Specific year`` ``municipalities_2023`` ``<-`` `[`datasus_get_territory`](https://strategicprojects.github.io/datasusr/reference/datasus_get_territory.md)`(``"tb_municip"``, year ``=`` ``2023``)`` `` ``# Browse available years and tables`` `[`datasus_ftp_ls`](https://strategicprojects.github.io/datasusr/reference/datasus_ftp_ls.md)`(``"ftp://ftp.datasus.gov.br/territorio/tabelas/"``)`

## Documentation and data dictionaries

Each information system has documentation files on the DATASUS FTP. Use
[`datasus_docs_url()`](https://strategicprojects.github.io/datasusr/reference/datasus_docs_url.md)
to find them:

`# All known documentation paths`` `[`datasus_docs_url`](https://strategicprojects.github.io/datasusr/reference/datasus_docs_url.md)`(``)`` `` ``# List documentation files for a specific system`` `[`datasus_ftp_ls`](https://strategicprojects.github.io/datasusr/reference/datasus_ftp_ls.md)`(`[`datasus_docs_url`](https://strategicprojects.github.io/datasusr/reference/datasus_docs_url.md)`(``"CNES"``)``$``docs_url``[[``1``]``]``)`

## Connectivity check

The following code tests path resolution for every source and file type
in the catalog:

[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `` ``sources_dbc`` ``<-`` `[`datasus_sources`](https://strategicprojects.github.io/datasusr/reference/datasus_sources.md)`(``)`` ``|>`` `` `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``access`` ``==`` ``"fetch"``)`` `` ``results`` ``<-`` ``purrr``::`[`map`](https://purrr.tidyverse.org/reference/map.html)`(`[`seq_len`](https://rdrr.io/r/base/seq.html)`(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``sources_dbc``)``)``, \``(``i``)`` ``{`` `` ``src`` ``<-`` ``sources_dbc``$``source``[[``i``]``]`` `` ``fts`` ``<-`` `[`datasus_file_types`](https://strategicprojects.github.io/datasusr/reference/datasus_file_types.md)`(``source ``=`` ``src``)`` `` `` ``purrr``::`[`map`](https://purrr.tidyverse.org/reference/map.html)`(`[`seq_len`](https://rdrr.io/r/base/seq.html)`(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``fts``)``)``, \``(``j``)`` ``{`` `` ``ft`` ``<-`` ``fts``$``file_type``[[``j``]``]`` `` ``ok`` ``<-`` `[`tryCatch`](https://rdrr.io/r/base/conditions.html)`(``{`` `` `[`datasus_build_path`](https://strategicprojects.github.io/datasusr/reference/datasus_build_path.md)`(``source ``=`` ``src``, file_type ``=`` ``ft``, year ``=`` ``2023``, month ``=`` ``1``)`` `` ``TRUE`` `` ``}``, error ``=`` ``function``(``e``)`` ``FALSE``)`` `` ``tibble``::`[`tibble`](https://tibble.tidyverse.org/reference/tibble.html)`(``source ``=`` ``src``, file_type ``=`` ``ft``, has_path ``=`` ``ok``)`` `` ``}``)`` ``|>`` ``purrr``::`[`list_rbind`](https://purrr.tidyverse.org/reference/list_c.html)`(``)`` ``}``)`` ``|>`` ``purrr``::`[`list_rbind`](https://purrr.tidyverse.org/reference/list_c.html)`(``)`` `` ``results`` ``|>`` `[`print`](https://rdrr.io/r/base/print.html)`(``n ``=`` ``Inf``)`

## Cleaning up

The examples above download files to the local cache. To remove all
cached files after testing:

[`datasus_cache_info`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_info.md)`(``)`` `[`datasus_cache_clear`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_clear.md)`(``)`

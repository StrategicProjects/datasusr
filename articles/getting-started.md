# Getting started with datasusr

`datasusr` provides fast, in-memory reading of DATASUS `.dbc` files and
a complete workflow for discovering, downloading, and caching Brazilian
public health data.

## The fastest way: `datasus_fetch()`

If you know the source, file type, period, and state you need,
[`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)
handles listing, downloading, and reading in a single call:

[`library`](https://rdrr.io/r/base/library.html)`(`[`datasusr`](https://strategicprojects.github.io/datasusr/)`)`` `` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIHSUS"``,`` `` file_type ``=`` ``"RD"``,`` `` year ``=`` ``2024``,`` `` month ``=`` ``1``,`` `` uf ``=`` ``"PE"`` ``)`` `` ``df`

The result is a tibble ready for analysis with `dplyr`, `ggplot2`, or
any tidyverse tool. Files are cached by default, so running the same
call again skips the download entirely.

## Reading a local DBC file

If you already have a `.dbc` file on disk, use
[`read_datasus_dbc()`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md)
directly:

`x`` ``<-`` `[`read_datasus_dbc`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md)`(``"RDPE2401.dbc"``)`` ``x`

## Selecting columns

DATASUS files often have dozens of columns. Use `select` to keep only
what you need — this is faster and uses less memory:

`x`` ``<-`` `[`read_datasus_dbc`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md)`(`` `` ``"RDPE2401.dbc"``,`` `` select ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"uf_zi"``, ``"ano_cmpt"``, ``"munic_res"``, ``"val_tot"``)`` ``)`

## Controlling column types

By default, `datasusr` inspects each numeric field to decide between
integer and double. You can override this with `col_types` and parse
date fields with `parse_dates`:

`x`` ``<-`` `[`read_datasus_dbc`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md)`(`` `` ``"SPPE2401.dbc"``,`` `` select ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"sp_gestor"``, ``"sp_naih"``, ``"sp_dtinter"``, ``"sp_valato"``)``,`` `` col_types ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`` `` sp_gestor ``=`` ``"character"``,`` `` sp_naih ``=`` ``"character"``,`` `` sp_dtinter ``=`` ``"date"``,`` `` sp_valato ``=`` ``"double"`` `` ``)``,`` `` parse_dates ``=`` ``TRUE``,`` `` guess_types ``=`` ``FALSE`` ``)`

## Exploring available data

Before downloading, you can browse the internal catalog to discover
which sources and file types are available:

[`datasus_sources`](https://strategicprojects.github.io/datasusr/reference/datasus_sources.md)`(``)`` `[`datasus_file_types`](https://strategicprojects.github.io/datasusr/reference/datasus_file_types.md)`(``source ``=`` ``"SIHSUS"``)`` `[`datasus_file_types`](https://strategicprojects.github.io/datasusr/reference/datasus_file_types.md)`(``source ``=`` ``"CNES"``)`

## Step-by-step workflow

For more control, you can use the individual functions instead of
[`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md):

`# 1. Build the FTP paths`` `[`datasus_build_path`](https://strategicprojects.github.io/datasusr/reference/datasus_build_path.md)`(``source ``=`` ``"SIHSUS"``, file_type ``=`` ``"RD"``, year ``=`` ``2024``, month ``=`` ``1``)`` `` ``# 2. List files (validated against FTP)`` ``files`` ``<-`` `[`datasus_list_files`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md)`(`` `` source ``=`` ``"SIHSUS"``,`` `` file_type ``=`` ``"RD"``,`` `` year ``=`` ``2024``,`` `` month ``=`` ``1``:``3``,`` `` uf ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"PE"``, ``"PB"``)`` ``)`` `` ``# 3. Download with cache`` ``downloads`` ``<-`` `[`datasus_download`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)`(``files``, use_cache ``=`` ``TRUE``)`` `` ``# 4. Read`` ``x`` ``<-`` `[`read_datasus_dbc`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md)`(``downloads``$``local_file``[[``1``]``]``)`

To skip FTP validation (useful when the server is slow), set
`check_exists = FALSE` in
[`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md).

## Territorial data (municipalities, regions)

DATASUS publishes territorial reference tables (municipalities, health
regions, etc.) as CSV files. Use
[`datasus_get_territory()`](https://strategicprojects.github.io/datasusr/reference/datasus_get_territory.md)
to download and read them:

`# Download municipalities table`` ``municipios`` ``<-`` `[`datasus_get_territory`](https://strategicprojects.github.io/datasusr/reference/datasus_get_territory.md)`(``"tb_municip"``)`` ``municipios`` `` ``# Other available tables`` `[`datasus_ftp_ls`](https://strategicprojects.github.io/datasusr/reference/datasus_ftp_ls.md)`(``"ftp://ftp.datasus.gov.br/territorio/tabelas/"``)`

## Finding documentation and data dictionaries

Each information system has documentation files on the DATASUS FTP. Use
[`datasus_docs_url()`](https://strategicprojects.github.io/datasusr/reference/datasus_docs_url.md)
to find them:

`# See all documentation paths`` `[`datasus_docs_url`](https://strategicprojects.github.io/datasusr/reference/datasus_docs_url.md)`(``)`` `` ``# List documentation files for a specific system`` `[`datasus_docs_url`](https://strategicprojects.github.io/datasusr/reference/datasus_docs_url.md)`(``"CNES"``)`` `[`datasus_ftp_ls`](https://strategicprojects.github.io/datasusr/reference/datasus_ftp_ls.md)`(`[`datasus_docs_url`](https://strategicprojects.github.io/datasusr/reference/datasus_docs_url.md)`(``"CNES"``)``$``docs_url``[[``1``]``]``)`

## Next steps

See the other vignettes for more detail:

- **Cache and downloads** — how caching works and how to manage it
- **Performance notes** — tips for reading large files quickly
- **Comparison with read.dbc and microdatasus** — how `datasusr` relates
  to other R packages for DATASUS data

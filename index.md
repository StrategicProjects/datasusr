# datasusr

**datasusr** provides fast, in-memory reading of DATASUS `.dbc` files
and a complete workflow for discovering, downloading, caching, and
reading Brazilian public health data from the DATASUS FTP.

> **Looking for a broader toolkit?** If your workflow goes beyond the
> DATASUS FTP — e.g. you also need IBGE surveys (VIGITEL, PNS, PNAD-C,
> POF, Censo), SISAB primary-care indicators, ANS, ANVISA, or
> out-of-the-box variable dictionaries and value labels —
> [`healthbR`](https://github.com/SidneyBissoli/healthbR) is the more
> complete and currently more active package, and is the recommended
> first choice in many cases. `datasusr` focuses on being a small, fast,
> dependency-light reader for raw DBC files plus a catalog and FTP
> layer. See the [Comparison
> article](https://strategicprojects.github.io/datasusr/articles/comparison.html)
> for the full breakdown.

[TABLE]

## Installation

`# Install from GitHub`` ``# install.packages("remotes")`` ``remotes``::`[`install_github`](https://remotes.r-lib.org/reference/install_github.html)`(``"StrategicProjects/datasusr"``)`

## Quick start

[`library`](https://rdrr.io/r/base/library.html)`(`[`datasusr`](https://strategicprojects.github.io/datasusr/)`)`` `` ``# One-step: list, download, and read SIH data for Pernambuco`` ``df`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIHSUS"``,`` `` file_type ``=`` ``"RD"``,`` `` year ``=`` ``2024``,`` `` month ``=`` ``1``,`` `` uf ``=`` ``"PE"`` ``)`` `` ``df`

## Step-by-step workflow

For more control, use the individual functions:

[`library`](https://rdrr.io/r/base/library.html)`(`[`datasusr`](https://strategicprojects.github.io/datasusr/)`)`` `` ``# 1. Explore the catalog`` `[`datasus_sources`](https://strategicprojects.github.io/datasusr/reference/datasus_sources.md)`(``)`` `[`datasus_file_types`](https://strategicprojects.github.io/datasusr/reference/datasus_file_types.md)`(``source ``=`` ``"SIHSUS"``)`` `` ``# 2. List available files on the FTP`` ``files`` ``<-`` `[`datasus_list_files`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md)`(`` `` source ``=`` ``"SIHSUS"``,`` `` file_type ``=`` ``"RD"``,`` `` year ``=`` ``2024``,`` `` month ``=`` ``1``:``3``,`` `` uf ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"PE"``, ``"PB"``)`` ``)`` `` ``# 3. Download (with automatic caching)`` ``downloads`` ``<-`` `[`datasus_download`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)`(``files``, use_cache ``=`` ``TRUE``)`` `` ``# 4. Read a DBC file into a tibble`` ``x`` ``<-`` `[`read_datasus_dbc`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md)`(``downloads``$``local_file``[[``1``]``]``)`` `` ``# 5. Read with column selection and type control`` ``x`` ``<-`` `[`read_datasus_dbc`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md)`(`` `` ``downloads``$``local_file``[[``1``]``]``,`` `` select ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"uf_zi"``, ``"ano_cmpt"``, ``"dt_inter"``, ``"val_tot"``)``,`` `` col_types ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``dt_inter ``=`` ``"date"``, val_tot ``=`` ``"double"``)``,`` `` parse_dates ``=`` ``TRUE`` ``)`

## Cache management

Downloads are cached by default so repeated runs do not hit the DATASUS
FTP:

[`datasus_cache_info`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_info.md)`(``)`` `[`datasus_cache_list`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_list.md)`(``)`` `` ``# Prune old files`` `[`datasus_cache_prune`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_prune.md)`(``older_than_days ``=`` ``90``)`` `` ``# Or clear everything`` `[`datasus_cache_clear`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_clear.md)`(``)`

You can configure the cache directory via the `DATASUSR_CACHE_DIR`
environment variable, the `datasusr.cache_dir` R option, or the
`cache_dir` argument.

## Data sources

![DATASUS data sources supported by
datasusr](reference/figures/sources.svg)

## Main functions

| Function | Purpose |
|----|----|
| [`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md) | List + download + read in one call |
| [`read_datasus_dbc()`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md) | Read `.dbc` / `.dbf` files into a tibble |
| [`datasus_sources()`](https://strategicprojects.github.io/datasusr/reference/datasus_sources.md) | Browse data sources in the catalog |
| [`datasus_file_types()`](https://strategicprojects.github.io/datasusr/reference/datasus_file_types.md) | Browse file types by source |
| [`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md) | List candidate files (optionally validated against FTP) |
| [`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md) | Download files with caching support |
| [`datasus_get_territory()`](https://strategicprojects.github.io/datasusr/reference/datasus_get_territory.md) | Download territorial reference tables (municipalities, etc.) |
| [`datasus_docs_url()`](https://strategicprojects.github.io/datasusr/reference/datasus_docs_url.md) | Find FTP paths for documentation and data dictionaries |
| [`datasus_ftp_ls()`](https://strategicprojects.github.io/datasusr/reference/datasus_ftp_ls.md) | Raw FTP directory listing |
| `datasus_cache_*()` | Cache management helpers |

## Progress messages

All functions emit `cli` progress messages by default. Suppress them
with `verbose = FALSE`.

## License

MIT

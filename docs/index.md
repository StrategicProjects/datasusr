# datasusr

**datasusr** provides fast, in-memory reading of DATASUS `.dbc` files
and a complete workflow for discovering, downloading, caching, and
reading Brazilian public health data from the DATASUS FTP.

[TABLE]

## Installation

``` r

# Install from GitHub
# install.packages("remotes")
remotes::install_github("StrategicProjects/datasusr")
```

## Quick start

``` r

library(datasusr)

# One-step: list, download, and read SIH data for Pernambuco
df <- datasus_fetch(
  source    = "SIHSUS",
  file_type = "RD",
  year      = 2024,
  month     = 1,
  uf        = "PE"
)

df
```

## Step-by-step workflow

For more control, use the individual functions:

``` r

library(datasusr)

# 1. Explore the catalog
datasus_sources()
datasus_file_types(source = "SIHSUS")

# 2. List available files on the FTP
files <- datasus_list_files(
  source    = "SIHSUS",
  file_type = "RD",
  year      = 2024,
  month     = 1:3,
  uf        = c("PE", "PB")
)

# 3. Download (with automatic caching)
downloads <- datasus_download(files, use_cache = TRUE)

# 4. Read a DBC file into a tibble
x <- read_datasus_dbc(downloads$local_file[[1]])

# 5. Read with column selection and type control
x <- read_datasus_dbc(
  downloads$local_file[[1]],
  select     = c("uf_zi", "ano_cmpt", "dt_inter", "val_tot"),
  col_types  = c(dt_inter = "date", val_tot = "double"),
  parse_dates = TRUE
)
```

## Cache management

Downloads are cached by default so repeated runs do not hit the DATASUS
FTP:

``` r

datasus_cache_info()
datasus_cache_list()

# Prune old files
datasus_cache_prune(older_than_days = 90)

# Or clear everything
datasus_cache_clear()
```

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

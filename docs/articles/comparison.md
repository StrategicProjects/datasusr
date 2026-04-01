# Comparison with microdatasus

The [`microdatasus`](https://github.com/rfsaldanha/microdatasus) package
(Saldanha, Bastos & Barcellos, 2019) is the most widely used R package
for downloading and pre-processing DATASUS microdata. This article
compares it with `datasusr` to help you choose the right tool for your
workflow.

## Feature comparison

| Feature | datasusr | microdatasus |
|----|----|----|
| **DBC reading** | In-memory C parser (bundled) | Via `read.dbc` (external dep) |
| **Column selection at read** | Yes (`select`) | Yes (`vars`) |
| **Type control** | Yes (`col_types`, `guess_types`) | No |
| **Date parsing at read** | Yes (`parse_dates`) | Via `process_*()` post-hoc |
| **Column names** | snake_case by default (`clean_names`) | Uppercase (original) |
| **Return type** | Always tibble | tibble (after `process_*()`) |
| **Data sources** | 18 systems catalogued | ~15 systems |
| **Catalog browsing** | Yes ([`datasus_sources()`](https://strategicprojects.github.io/datasusr/reference/datasus_sources.md), [`datasus_file_types()`](https://strategicprojects.github.io/datasusr/reference/datasus_file_types.md)) | No |
| **FTP file listing** | Yes ([`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md), [`datasus_ftp_ls()`](https://strategicprojects.github.io/datasusr/reference/datasus_ftp_ls.md)) | No |
| **Persistent cache** | Yes (configurable dir, env var, pruning) | Session-level temp files |
| **Parallel downloads** | Yes ([`curl::multi_download`](https://jeroen.r-universe.dev/curl/reference/multi_download.html), progress bars) | Sequential |
| **Territorial tables** | Yes ([`datasus_get_territory()`](https://strategicprojects.github.io/datasusr/reference/datasus_get_territory.md)) | No |
| **Documentation paths** | Yes ([`datasus_docs_url()`](https://strategicprojects.github.io/datasusr/reference/datasus_docs_url.md)) | No |
| **Variable labelling** | No | Yes (`process_*()` family) |
| **One-step fetch** | Yes ([`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)) | Yes (`fetch_datasus()`) |
| **Preliminary data** | Yes (`include_prelim` flag) | Yes (e.g. `"SIM-DO-PRELIM"`) |
| **CRAN** | GitHub | Archived (dep on archived `read.dbc`) |
| **License** | MIT | MIT |

## Reading DBC files

Both packages ultimately use C code based on Mark Adler’s `blast`
decompressor for the PKWare DCL format used by DATASUS. The key
difference is in how the decompressed data is handled:

**microdatasus** delegates reading to the `read.dbc` package, which
decompresses the `.dbc` to a temporary `.dbf` file on disk, then calls
[`foreign::read.dbf()`](https://rdrr.io/pkg/foreign/man/read.dbf.html)
to parse it into a `data.frame`. This two-step process involves disk I/O
and inherits the type limitations of
[`foreign::read.dbf()`](https://rdrr.io/pkg/foreign/man/read.dbf.html)
(all numeric fields become `double`).

**datasusr** performs decompression and DBF parsing entirely in memory
in a single C call. The compressed payload is decompressed directly into
a memory buffer and parsed field-by-field into pre-allocated R vectors.
This avoids temporary files and enables features like column selection,
type inference, and date parsing at the C level. It also handles a wider
range of DBC variants, including files with non-standard header
terminators found in some CNES files.

## Downloading and discovering data

Both packages provide a one-step function to download and read files:

``` r

# --- datasusr -----------------------------------------------------------------
library(datasusr)
df <- datasus_fetch(
  source = "SIHSUS", file_type = "RD",
  year = 2024, month = 1:3, uf = "PE",
  select = c("uf_zi", "ano_cmpt", "munic_res", "val_tot")
)

# --- microdatasus -------------------------------------------------------------
library(microdatasus)
df <- fetch_datasus(
  year_start = 2024, year_end = 2024,
  month_start = 1, month_end = 3,
  uf = "PE", information_system = "SIH-RD"
)
df <- process_sih(df)
```

Where the packages differ in design:

**microdatasus** uses a single function (`fetch_datasus()`) with all
parameters upfront. The system name uses a hyphenated format
(`"SIH-RD"`, `"SIM-DO"`, `"CNES-ST"`). Path construction is handled
internally. This is simple and effective for common use cases.

**datasusr** offers a layered API that can be used at any level of
granularity:

``` r

# Browse what's available
datasus_sources()
datasus_file_types(source = "SINAN")

# Check which files exist on the FTP
files <- datasus_list_files(
  source = "SINAN", file_type = "DENG",
  year = 2020:2024
)

# Download with parallel connections and progress bars
downloads <- datasus_download(files)

# Read with type control
df <- read_datasus_dbc(
  downloads$local_file[[1]],
  select    = c("dt_notific", "id_municip", "classi_fin"),
  col_types = c(dt_notific = "date"),
  parse_dates = TRUE
)
```

Or use
[`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)
to do it all in one call, just like microdatasus.

## Caching

**microdatasus** downloads files to a temporary directory
([`tempdir()`](https://rdrr.io/r/base/tempfile.html)). Files are not
preserved between R sessions, so re-running the same query triggers a
new download from the DATASUS FTP.

**datasusr** maintains a persistent cache directory that survives
between sessions. Repeated calls with the same parameters reuse cached
files without any network access. The cache location can be configured
via the `DATASUSR_CACHE_DIR` environment variable, the
`datasusr.cache_dir` R option, or the `cache_dir` argument. Management
functions let you inspect, prune, or clear the cache:

``` r

datasus_cache_info()                         # summary
datasus_cache_prune(older_than_days = 90)    # remove old files
datasus_cache_prune(max_size_bytes = 5e9)    # cap total size
datasus_cache_clear()                        # remove everything
```

## Variable labelling

This is where `microdatasus` provides significant added value. Its
`process_*()` functions decode categorical fields by replacing numeric
codes with human-readable labels. For example, `process_sim()` converts
ICD-10 codes to descriptions, municipality codes to names, and numeric
sex/race indicators to labelled factors. This is done for SIM, SINASC,
SIH, SIA, CNES, and several SINAN diseases.

`datasusr` does not perform variable labelling. It returns the raw
values from the DBC files, leaving semantic interpretation to the
analyst. If you need labelled variables, you can use the territorial
tables as lookup references:

``` r

library(dplyr)

municipios <- datasus_get_territory("tb_municip")

df <- datasus_fetch(
  source = "SIM", file_type = "DO",
  year = 2022, uf = "PE"
) |>
  left_join(
    select(municipios, co_municip, ds_nome),
    by = c("codmunocor" = "co_municip")
  )
```

## CRAN availability

As of this writing, `microdatasus` has been archived from CRAN because
it depends on `read.dbc`, which is also archived. Both remain
installable from GitHub. `datasusr` is available on GitHub and has no
dependency on either package — it bundles its own C code for DBC
decompression.

## When to use which

**Choose `datasusr`** when you need:

- Fast reads of large DBC files with column selection and type control
- Persistent caching to avoid re-downloading
- Exploratory browsing of the DATASUS catalog and FTP
- Parallel downloads with progress bars
- Territorial reference tables (municipalities, health regions)
- A tidyverse-native workflow with snake_case column names

**Choose `microdatasus`** when you need:

- Automatic variable labelling and categorical recoding
- Analysis-ready data frames with minimal code
- A well-documented, published package (Cad. Saude Publica, 2019)

The two packages can also complement each other: use `datasusr` for
fast, cached I/O and `microdatasus::process_*()` for post-processing
when needed.

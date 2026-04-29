# Comparison with healthbR and microdatasus

`datasusr` is one of several R packages that pull Brazilian public
health data into the tidyverse. This article compares it with the two
most relevant alternatives so that you can pick the right tool — and, in
many cases, that tool will *not* be `datasusr`.

- [`healthbR`](https://github.com/SidneyBissoli/healthbR) (Sidney
  Bissoli): modern, broad-scope toolkit covering DATASUS *and* IBGE
  surveys, primary-care indicators, ANS, and ANVISA, with
  module-specific helpers, variable dictionaries, parallel downloads,
  and Parquet caching.
- [`microdatasus`](https://github.com/rfsaldanha/microdatasus)
  (Saldanha, Bastos & Barcellos, 2019): the original tidyverse-friendly
  DATASUS reader, with rich `process_*()` functions for variable
  labelling. Currently archived on CRAN.

## TL;DR — when to use what

**Reach for `healthbR` first** when you want analysis-ready data and
your question spans more than the DATASUS FTP. It covers VIGITEL, PNS,
PNAD Contínua, POF, Censo, SI-PNI (microdata 2020+), SISAB, ANS, and
ANVISA in addition to SIM/SINASC/SIH/SIA/SINAN/CNES, exposes a uniform
`<module>_data()` / `<module>_variables()` / `<module>_dictionary()`
API, filters by ICD-10 prefix at the call site, parallelises downloads
via `future`/`furrr`, and caches as Parquet via `arrow`. For most
applied public-health analyses this is the most productive starting
point.

**Use `datasusr`** when you specifically need a small, fast,
dependency-light reader for raw DBC files from the DATASUS FTP, a
persistent on-disk cache with age/size pruning, or low-level access to
the FTP catalog (custom paths, custom file types, custom column types).
It does *not* try to replace `healthbR`’s breadth or `microdatasus`’s
variable-labelling features — it stays focused on fast I/O and the FTP.

**Use `microdatasus`** when you want its `process_sim()` /
`process_sinasc()` / etc. labelling pipelines for
SIM/SINASC/SIH/SIA/CNES and a select set of SINAN diseases, in a
workflow you already know.

## Feature comparison

| Feature | datasusr | healthbR | microdatasus |
|----|----|----|----|
| **Data sources** | DATASUS FTP only (18 systems catalogued) | DATASUS FTP + IBGE surveys + SISAB + ANS + ANVISA | DATASUS FTP only (~15 systems) |
| **Survey microdata** (VIGITEL, PNS, PNAD-C, POF, Censo) | No | Yes | No |
| **Regulatory data** (ANS, ANVISA) | No | Yes | No |
| **Primary-care indicators** (SISAB) | No | Yes | No |
| **DBC reading** | In-memory C parser (bundled `blast`) | Vendored C decompressor | External `read.dbc` |
| **Module-specific API** | No (one generic [`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)) | Yes (`sim_data()`, `sih_data()`, …) | Yes (`fetch_datasus(information_system = "SIH-RD")`) |
| **Variable dictionaries / labels** | No (raw fields) | Yes (`*_variables()`, `*_dictionary()`) | Yes (`process_*()` family) |
| **Filter by ICD-10 prefix** | No (post-hoc with `dplyr`) | Yes (`cause = "I"`, `diagnosis = "J"`) | No |
| **Parallel downloads** | [`curl::multi_download`](https://jeroen.r-universe.dev/curl/reference/multi_download.html) (sequential per call) | `future` / `furrr` plans | Sequential |
| **Caching** | Persistent on disk, configurable, with `prune` by age/size | Per-module Parquet cache (via `arrow`) with `*_cache_status()` | Session-level temp files |
| **Cache opt-in** | tempdir() default, persistent only on opt-in | Per-module helpers | None |
| **Column selection at read** | Yes (`select`) | Module-dependent | Yes (`vars`) |
| **Type control at read** | Yes (`col_types`, `guess_types`) | No | No |
| **Date parsing at read** | Yes (`parse_dates`) | Module-dependent | Via `process_*()` |
| **Return type** | Tibble, snake_case by default | Tibble, snake_case | Data frame → tibble after `process_*()` |
| **CRAN status** | This submission | On CRAN | Archived |
| **Dependencies** | cli, curl, dplyr, purrr, rlang, stringr, tibble, tidyr | \+ readr, jsonlite, foreign (Imports); arrow, furrr, future, survey, srvyr (Suggests) | foreign, read.dbc (archived) |
| **License** | MIT | MIT | MIT |

## Reading DBC files

All three packages ultimately rely on Mark Adler’s `blast` decompressor
for the PKWare DCL format used by DATASUS. The differences are in *how*
the decompressed data is materialised in R:

- **`microdatasus`** delegates to the `read.dbc` package, which writes a
  temporary `.dbf` file and parses it with
  [`foreign::read.dbf()`](https://rdrr.io/pkg/foreign/man/read.dbf.html).
  All numeric fields become `double`.
- **`healthbR`** vendors its own C decompressor and parses fields into
  tidy tibbles per module. Each `<module>_data()` call applies the
  module’s specific cleaning/labelling rules.
- **`datasusr`** decompresses and parses entirely in memory in a single
  C call. The compressed payload goes straight to a memory buffer and is
  parsed field-by-field into pre-allocated R vectors, with optional
  column selection, integer-vs-double inference, explicit `col_types`,
  and date parsing — all at the C level. There are no temporary files on
  disk.

For a single large DBC file with column selection, `datasusr` is the
fastest option. For a multi-source analysis touching surveys and DATASUS
together, `healthbR`’s integrated workflow saves more wall time than the
per-file speedup is worth.

## API ergonomics

`healthbR` provides a uniform per-module API:

``` r

library(healthbR)

obitos    <- sim_data(year = 2022, uf = "AC")
obitos_cv <- sim_data(year = 2022, uf = "AC", cause = "I")  # ICD-10 prefix
nascidos  <- sinasc_data(year = 2022, uf = "AC")
intern    <- sih_data(year = 2022, month = 1:6, uf = c("SP", "RJ"))
ambul     <- sia_data(year = 2022, month = 1, uf = "AC", type = "AM")

# Variable metadata and value labels
sim_variables()
sim_dictionary("SEXO")
```

`datasusr` is intentionally one level lower. There is a single
[`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)
entry point, plus a layered API that exposes the catalog and the FTP:

``` r

library(datasusr)

# Browse the catalog
datasus_sources()
datasus_file_types(source = "SINAN")

# Validate availability against the FTP
files <- datasus_list_files(
  source = "SINAN", file_type = "DENG",
  year   = 2020:2024
)

# Download with caching
downloads <- datasus_download(files, cache_dir = tempdir())

# Read with column selection and explicit types
df <- read_datasus_dbc(
  downloads$local_file[[1]],
  select      = c("dt_notific", "id_municip", "classi_fin"),
  col_types   = c(dt_notific = "date"),
  parse_dates = TRUE
)
```

If you do not need that level of control,
[`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)
collapses the four steps above into one call, similar to `healthbR`’s
`<module>_data()`.

## Caching and parallelism

`healthbR` writes per-module Parquet files (when `arrow` is installed)
and exposes per-module cache helpers (`sim_cache_status()`,
`sih_clear_cache()`, …). Parallel downloads are opt-in via a `future`
plan, so a single call can pull many UFs/months/years at once.

`datasusr` keeps the cache as raw `.dbc` files in a single configurable
directory (default: a session-scoped subdirectory of
[`tempdir()`](https://rdrr.io/r/base/tempfile.html)). Pruning is global
rather than per-module:

``` r

datasus_cache_info()
datasus_cache_prune(older_than_days = 90)
datasus_cache_prune(max_size_bytes  = 5 * 1024^3)
datasus_cache_clear()
```

If you want a persistent cross-session cache, point `cache_dir` (or the
`DATASUSR_CACHE_DIR` env var, or the `datasusr.cache_dir` option) at a
directory of your choice, e.g. `tools::R_user_dir("datasusr", "cache")`.

`datasusr` does not bundle a parallel-download abstraction, but
[`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md)
returns a tibble of URLs that you can hand to
[`curl::multi_download()`](https://jeroen.r-universe.dev/curl/reference/multi_download.html)
or your own `future_map()` if you need parallel I/O.

## Variable labelling

Neither `datasusr` nor base R itself attaches semantic labels to DATASUS
variables. `healthbR` and `microdatasus` both do, with different styles:

- `healthbR`: per-module `*_variables()` and `*_dictionary()` return
  tibbles describing each field and its categorical levels.
- `microdatasus`: `process_sim()`, `process_sinasc()`, … rewrite the
  data frame in place with decoded values.

If you start in `datasusr`, you can join against the territorial tables
to recover human-readable municipality / region names, but ICD codes,
sex codes, race codes, etc. remain raw:

``` r

library(dplyr)
mun <- datasus_get_territory("tb_municip", cache_dir = tempdir())

df <- datasus_fetch(
  source = "SIM", file_type = "DO",
  year = 2022, uf = "PE",
  cache_dir = tempdir()
) |>
  left_join(
    select(mun, co_municip, ds_nome),
    by = c("codmunocor" = "co_municip")
  )
```

For analyses where labelled variables matter, prefer `healthbR` (or
`microdatasus`’s `process_*()` family).

## Composing the packages

The packages are not mutually exclusive. A common pattern:

- Use `healthbR` as the default entry point for surveys and labelled
  DATASUS data.
- Drop down to `datasusr` when you need fast custom reads of arbitrary
  DBC files, or when you want to navigate the FTP catalog directly
  ([`datasus_ftp_ls()`](https://strategicprojects.github.io/datasusr/reference/datasus_ftp_ls.md),
  [`datasus_list_files()`](https://strategicprojects.github.io/datasusr/reference/datasus_list_files.md),
  [`datasus_docs_url()`](https://strategicprojects.github.io/datasusr/reference/datasus_docs_url.md)).
- Reach for `microdatasus::process_*()` if you already rely on its
  labelling pipelines.

## Summary

`healthbR` is the most complete and currently the most actively
maintained option for Brazilian public health data in R, and is the
recommended starting point for most users. `datasusr` is a focused
DATASUS-FTP reader and catalog tool: it shines when you need fast,
flexible, dependency-light I/O against raw DBC files, but it does not
try to match `healthbR`’s scope.

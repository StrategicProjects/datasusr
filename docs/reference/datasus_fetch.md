# Fetch DATASUS data in one step

A convenience wrapper that lists, downloads, and reads DATASUS files in
a single call. Particularly useful for interactive / exploratory work.

## Usage

``` r
datasus_fetch(
  source,
  file_type,
  year = NULL,
  month = NULL,
  uf = NULL,
  ...,
  bind = TRUE,
  include_prelim = TRUE,
  timeout = 240,
  use_cache = TRUE,
  cache_dir = NULL,
  verbose = TRUE
)
```

## Arguments

- source:

  Character vector of source codes.

- file_type:

  Character vector of file type codes.

- year:

  Integer vector of years.

- month:

  Integer vector of months (required for monthly sources).

- uf:

  Character vector of UF codes (required for UF-scoped sources).

- ...:

  Additional arguments forwarded to
  [`read_datasus_dbc()`](https://strategicprojects.github.io/datasusr/reference/read_datasus_dbc.md)
  (e.g. `select`, `col_types`, `parse_dates`).

- bind:

  Logical. When `TRUE` (the default), all files are row-bound into a
  single tibble. When `FALSE`, a list of tibbles is returned.

- include_prelim:

  Logical. Include preliminary data trees (default `TRUE`).

- timeout:

  Timeout in seconds for FTP and download operations (default 240).

- use_cache:

  Logical. Reuse cached downloads (default `TRUE`).

- cache_dir:

  Optional cache directory.

- verbose:

  Logical. Emit progress messages (default `TRUE`).

## Value

A tibble (when `bind = TRUE`) or a named list of tibbles.

## Examples

``` r
if (FALSE) { # \dontrun{
# Fetch SIH data for Pernambuco, Jan 2024
df <- datasus_fetch(
  source    = "SIHSUS",
  file_type = "RD",
  year      = 2024,
  month     = 1,
  uf        = "PE"
)

# Fetch with column selection (snake_case names work)
df <- datasus_fetch(
  source    = "SIHSUS",
  file_type = "RD",
  year      = 2024,
  month     = 1:3,
  uf        = "PE",
  select    = c("uf_zi", "ano_cmpt", "munic_res", "val_tot")
)
} # }
```

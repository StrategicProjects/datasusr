# Read DATASUS DBC files

Reads a DATASUS `.dbc` file directly into R using native C code for
PKWare DCL decompression and DBF parsing. The function always returns a
tibble and is designed to work well with the tidyverse.

## Usage

``` r
read_datasus_dbc(
  file,
  select = NULL,
  n_max = Inf,
  trim_ws = TRUE,
  encoding = "latin1",
  guess_types = TRUE,
  col_types = NULL,
  parse_dates = FALSE,
  clean_names = TRUE,
  verbose = TRUE
)
```

## Arguments

- file:

  Path to a `.dbc` or `.dbf` file. Both compressed (DBC) and
  uncompressed (DBF) formats are accepted.

- select:

  Optional character vector of column names to keep. When `NULL` (the
  default), all columns are returned. Names are matched
  case-insensitively, so both `"UF_ZI"` and `"uf_zi"` work.

- n_max:

  Maximum number of rows to read. Defaults to `Inf` (all rows).

- trim_ws:

  Logical. Trim leading/trailing whitespace from character fields
  (default `TRUE`).

- encoding:

  Encoding of the DBF character fields. Typically `"latin1"` (the
  default for DATASUS files) or `"UTF-8"`.

- guess_types:

  Logical. Inspect numeric fields to distinguish integer-like columns
  from double columns (default `TRUE`). Disable for faster reads when
  precise types are not needed.

- col_types:

  Optional named character vector of explicit column types. Supported
  values: `"character"`, `"integer"`, `"double"`, `"logical"`, `"date"`.
  Names are matched case-insensitively against the original DBF field
  names.

- parse_dates:

  Logical. If `TRUE`, DBF date fields (`D` type) are returned as `Date`.
  Character fields are only parsed as dates when explicitly listed in
  `col_types` (default `FALSE`).

- clean_names:

  Logical. If `TRUE` (the default), column names are converted to
  `snake_case` (lowercase with underscores). The original DATASUS names
  are uppercase (e.g. `UF_ZI` becomes `uf_zi`).

- verbose:

  Logical. Emit progress messages (default `TRUE`).

## Value

A tibble.

## Examples

``` r
# \donttest{
# The example downloads a small DATASUS file into tempdir() and reads it.
# Skipped automatically if the FTP is unreachable.
tmp <- file.path(tempdir(), "RDAC2401.dbc")
url <- paste0(
  "ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/",
  "RDAC2401.dbc"
)
ok <- tryCatch(
  {
    utils::download.file(url, tmp, mode = "wb", quiet = TRUE)
    TRUE
  },
  error = function(e) FALSE,
  warning = function(w) FALSE
)

if (ok) {
  # Basic read (column names in snake_case by default)
  x <- read_datasus_dbc(tmp, verbose = FALSE)

  # Select works with either case
  x <- read_datasus_dbc(
    tmp,
    select = c("uf_zi", "ano_cmpt", "val_tot"),
    verbose = FALSE
  )

  # Keep original uppercase names
  x <- read_datasus_dbc(tmp, clean_names = FALSE, verbose = FALSE)

  unlink(tmp)
}
# }
```

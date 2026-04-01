# Performance notes

This vignette collects practical advice for reading large DATASUS files
efficiently with `datasusr`.

## Column selection

The single most effective way to speed up reads is to select only the
columns you need. The C parser skips over unneeded fields at the byte
level, so fewer columns means less allocation and less parsing:

``` r

library(datasusr)

# Slow: reads all ~100+ columns
x <- read_datasus_dbc("RDPE2401.dbc")

# Fast: reads only 4 columns
x <- read_datasus_dbc(
  "RDPE2401.dbc",
  select = c("uf_zi", "ano_cmpt", "munic_res", "val_tot")
)
```

## Type inference

When `guess_types = TRUE` (the default), the reader scans every value of
each numeric field to decide whether it fits in an integer or requires a
double. Disabling this skips the scan and relies on the DBF field
metadata alone:

``` r

x <- read_datasus_dbc("RDPE2401.dbc", guess_types = FALSE)
```

This is safe for most analyses and can save noticeable time on files
with millions of rows.

## Explicit types

When you know exactly which types you need, `col_types` lets you specify
them upfront and skip inference entirely:

``` r

x <- read_datasus_dbc(
  "RDPE2401.dbc",
  select      = c("uf_zi", "dt_inter", "val_tot"),
  col_types   = c(uf_zi = "character", dt_inter = "date", val_tot = "double"),
  parse_dates = TRUE,
  guess_types = FALSE
)
```

## Date parsing

Date parsing (`parse_dates = TRUE`) adds a small overhead per date
field. Only enable it when you actually need `Date` objects; otherwise
the raw `YYYYMMDD` character strings are often sufficient for filtering
and grouping.

## Benchmarking example

``` r

library(bench)

file <- "RDPE2401.dbc"

bench::mark(
  default    = read_datasus_dbc(file),
  no_guess   = read_datasus_dbc(file, guess_types = FALSE),
  selected   = read_datasus_dbc(file, select = c("uf_zi", "val_tot")),
  typed      = read_datasus_dbc(
    file,
    select      = c("uf_zi", "dt_inter", "val_tot"),
    col_types   = c(uf_zi = "character", dt_inter = "date", val_tot = "double"),
    parse_dates = TRUE,
    guess_types = FALSE
  ),
  check      = FALSE,
  iterations = 5
)
```

## Memory

`datasusr` allocates R vectors directly from C without materialising
intermediate files on disk. For very large datasets (tens of millions of
rows), consider processing files in batches rather than binding
everything into a single data frame.

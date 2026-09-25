# Prune the datasusr cache

Selectively removes cached files based on age and/or total size. Older
and least-recently-accessed files are removed first.

## Usage

``` r
datasus_cache_prune(
  cache_dir = NULL,
  max_size_bytes = NULL,
  older_than_days = NULL,
  verbose = TRUE
)
```

## Arguments

- cache_dir:

  Optional cache directory.

- max_size_bytes:

  Maximum total cache size in bytes. When exceeded, the
  least-recently-accessed files are removed until the cache fits.

- older_than_days:

  Age threshold in days. Files with a modification time older than this
  are removed.

- verbose:

  Logical. Emit progress messages (default `TRUE`).

## Value

A tibble with columns `path`, `removed`, and `reason`.

# Clear cached DATASUS files

Removes files from the cache directory. By default all cached files are
removed; pass a character vector to `files` to remove specific paths.

## Usage

``` r
datasus_cache_clear(cache_dir = NULL, files = NULL, verbose = TRUE)
```

## Arguments

- cache_dir:

  Optional cache directory.

- files:

  Optional character vector of file paths to remove. When `NULL`, all
  cached files are removed.

- verbose:

  Logical. Emit progress messages (default `TRUE`).

## Value

A tibble with columns `path` and `removed`.

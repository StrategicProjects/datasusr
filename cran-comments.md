## Resubmission

This is a resubmission addressing the review comments from Benjamin Altmann.

* `DESCRIPTION`: external software/API names ('DATASUS', 'DBC', 'DBF',
  'FTP', 'C', 'PKWare DCL', 'blast', 'zlib') are now single-quoted
  consistently in title and description; the in-package function name
  `datasus_fetch()` is now unquoted. Added URL references for the
  underlying data source and the bundled `blast` decompressor in the
  description field, in the form `<https:...>` (no spaces) for
  auto-linking.

* All example sections switched from `\dontrun{}` to `\donttest{}`.
  Network-dependent examples are wrapped in `tryCatch()` so they fail
  gracefully when the FTP is unreachable, and use `tempdir()` for any
  on-disk output. Examples checked under `R CMD check --as-cran
  --run-donttest` (28 s wall time, no failures).

* No function writes to the user's home filespace by default any more.
  The cache directory now defaults to a session-scoped subdirectory of
  `tempdir()`. A persistent cache is fully opt-in via the
  `DATASUSR_CACHE_DIR` environment variable, the `datasusr.cache_dir`
  R option, or an explicit `cache_dir` argument. Examples and tests
  write only to `tempdir()`.

## Other changes since the previous submission

* The package website and the `comparison` vignette were updated to
  position `datasusr` honestly relative to the broader-scope
  `healthbR` package: `healthbR` is now recommended as the first choice
  for users whose workflow extends beyond raw DATASUS DBC reading
  (surveys, regulatory data, variable dictionaries, parallel
  downloads). `datasusr` documents itself as the focused
  dependency-light DBC reader and FTP-catalog layer.

## R CMD check results

0 errors | 0 warnings | 0 notes

(Local checks show three environment-only NOTEs — `New submission`,
unable to verify current time, and HTML Tidy version — none of which
are intrinsic to the package. The local `WARNING` about
`-Wfixed-enum-extension` originates inside an R header file as compiled
by Apple Clang on macOS and does not appear on the CRAN check farm.)

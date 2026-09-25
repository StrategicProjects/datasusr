# Cache and downloads

`datasusr` can cache DATASUS downloads in a local directory so that
repeated calls do not hit the DATASUS FTP again. This is especially
useful when developing analysis pipelines interactively.

## How caching works

When you call
[`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
with `use_cache = TRUE` (the default), files are stored in a structured
subdirectory tree under the cache folder. On subsequent calls for the
same files, the cached versions are reused without any network access.

[`library`](https://rdrr.io/r/base/library.html)`(`[`datasusr`](https://strategicprojects.github.io/datasusr/)`)`` `` ``downloads`` ``<-`` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(`` `` source ``=`` ``"SIHSUS"``,`` `` file_type ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"RD"``, ``"SP"``)``,`` `` year ``=`` ``2024``,`` `` month ``=`` ``1``,`` `` uf ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"PE"``, ``"PB"``)`` ``)`

### Cache layout

Each file is stored as

    <cache_dir>/<source>/<file_type>/<period>/<file_name>

for example `SIM/DO/current/DOPE2022.dbc` and
`SIM/DO/prelim/DOPE2022.dbc`. `<period>` is the FTP tree the file came
from (`current`, `historical` or `prelim`), so a preliminary file never
shadows the final file of the same name. The same layout is used under
`dest_dir` when you pass one.

Downloads are first written to a temporary `<file_name>.part` file and
only renamed to the final name once the transfer succeeds, so an
interrupted or failed download never ends up in the cache.
[`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
reports the outcome of each file in the `success` and `error` columns,
and
[`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)
skips failed files with a warning.

With `use_cache = FALSE` and no `dest_dir`, files go to a fresh
temporary subdirectory of
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) instead of the
cache.

## Configuring the cache directory

By default, downloads are placed in a session-scoped subdirectory of
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) (which R cleans up
automatically when the session ends), so the package never writes
outside the user-controlled tempdir unless you opt in.

The cache location is resolved in the following order:

1.  The `cache_dir` function argument
2.  The `DATASUSR_CACHE_DIR` environment variable
3.  The `datasusr.cache_dir` R option
4.  The session default (`file.path(tempdir(), "datasusr-cache")`)

To enable a persistent cache that survives across sessions, point one of
the above to a directory of your choice — for example
`tools::R_user_dir("datasusr", "cache")` — and the cache becomes truly
persistent.

To set it globally, add a line to your `.Renviron`:

    DATASUSR_CACHE_DIR=/path/to/my/cache

Or in R:

[`options`](https://rdrr.io/r/base/options.html)`(``datasusr.cache_dir ``=`` ``"/path/to/my/cache"``)`

## Inspecting the cache

`# Quick summary`` `[`datasus_cache_info`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_info.md)`(``verbose ``=`` ``TRUE``)`` `` ``# Detailed listing of all cached files`` `[`datasus_cache_list`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_list.md)`(``)`

## Forcing a re-download

Pass `refresh = TRUE` to
[`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
(or
[`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md))
to re-download files even when they exist in the cache:

[`datasus_download`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)`(``files``, refresh ``=`` ``TRUE``)`` `` `[`datasus_fetch`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)`(``"SIM"``, ``"DO"``, year ``=`` ``2022``, uf ``=`` ``"PE"``, refresh ``=`` ``TRUE``)`

## Timeouts

The DATASUS FTP can be slow, so downloads have no hard limit on the
total transfer time by default. Instead, a connection must be
established within 60 seconds and a transfer is aborted when it stays
below 1 byte/s for 120 seconds. Pass a finite `timeout` (in seconds) to
[`datasus_download()`](https://strategicprojects.github.io/datasusr/reference/datasus_download.md)
or
[`datasus_fetch()`](https://strategicprojects.github.io/datasusr/reference/datasus_fetch.md)
to also impose a hard cap per file.

## Pruning and clearing the cache

Over time the cache can grow large. Two functions help manage its size:

`# Remove files older than 90 days`` `[`datasus_cache_prune`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_prune.md)`(``older_than_days ``=`` ``90``)`` `` ``# Keep the total cache under 5 GB`` `[`datasus_cache_prune`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_prune.md)`(``max_size_bytes ``=`` ``5`` ``*`` ``1024``^``3``)`` `` ``# Remove everything`` `[`datasus_cache_clear`](https://strategicprojects.github.io/datasusr/reference/datasus_cache_clear.md)`(``)`

When pruning by size, the least-recently-accessed files are removed
first.

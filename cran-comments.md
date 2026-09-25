## Update: datasusr 0.1.1

This is a maintenance release of a package first published on CRAN as
0.1.0 (all CRAN check flavours OK). It follows an internal code audit
of the compiled DBC/DBF reader and of the download layer; see
`NEWS.md` for the full list.

* Malformed DBF headers are now rejected instead of read out of bounds
  (verified with AddressSanitizer); native buffers are released via
  `R_UnwindProtect()` on error; deleted records are dropped; integer
  overflow, invalid dates and unsupported encodings are handled.
* Failed or interrupted downloads no longer poison the cache, and the
  cache layout keys files by release period so final and preliminary
  releases of the same file no longer collide.
* An offline `testthat` suite was added. It builds synthetic DBF files
  in `tempdir()` and exercises the download code with `file://` URLs,
  so no test needs network access. Network-dependent examples remain in
  `\donttest{}` and are guarded with `tryCatch()`.

## R CMD check results

Local `R CMD check --as-cran` (including `--run-donttest`) on R 4.6.0 /
macOS arm64 (Apple clang 21), with network access:

0 errors | 0 warnings | 0 notes

Locally the only NOTE is "Skipping checking HTML validation" because the
macOS system HTML Tidy is too old; in a sandbox without network access two
further environment-specific NOTEs appear ("unable to verify current
time" and an `xcrun_db` file created by Apple's toolchain in the temp
directory). None is intrinsic to the package. The compiled code builds cleanly
with `-Wall -Wextra -pedantic` and the parser was additionally
exercised under AddressSanitizer with malformed input.

Known limitation: on Windows the reader uses `ftell()` and cannot read
files larger than 2 GB; no DATASUS DBC file approaches that size.

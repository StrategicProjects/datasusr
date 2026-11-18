## Update: datasusr 0.2.0

This release replaces the C reader of DBC/DBF files with the Rust crate
'datasus-core', written by the package authors and shared with a
command-line tool and a Python package. The R interface is unchanged; see
`NEWS.md`. The package therefore now has
`SystemRequirements: Cargo (Rust's package manager), rustc >= 1.81`.

## Rust

The compiled code is Rust called through a small C file (`src/datasusr.c`)
that uses the R API; the Rust code itself does not call R.

* The source of the only Rust crate the package depends on is bundled in
  `src/rust/vendor.tar.xz`, and the build runs `cargo build --offline`:
  nothing is downloaded.
* `cargo build` runs with `-j 2`, and CARGO_HOME is a temporary directory
  inside the build tree, removed at the end.
* The versions of cargo and rustc are reported before compilation
  (`tools/msrv.R`), and `SystemRequirements` states the minimum rustc (1.81).
* Authors and licenses of the bundled crate are in `inst/AUTHORS`. Its
  decompressor is a port of `blast.c` from zlib contrib/blast; Mark Adler
  remains listed in `Authors@R` as contributor and copyright holder, and the
  zlib notice is kept in the ported file (`LICENSE.note`).

The build scaffolding (configure, Makevars, vendoring) is the one used by
our package 'foresightr', currently on CRAN.

## Test environments

* local: macOS 26.7 (aarch64), R 4.6.0, rustc 1.100.0
* rustc 1.81.0 (the oldest version the package declares): the bundled crate
  builds offline
* TODO before submission: win-builder (R-devel) and GitHub Actions
  (macOS, Windows, Ubuntu release and devel)

## R CMD check results

Local `R CMD check --as-cran --run-donttest`, with network access:

0 errors | 0 warnings | 0 notes

Locally the only NOTE is "Skipping checking HTML validation" because the
macOS system HTML Tidy is too old.

The test suite is offline: it builds synthetic DBF files in `tempdir()` and
exercises the download code with `file://` URLs. Network-dependent examples
remain in `\donttest{}` and are guarded with `tryCatch()`.

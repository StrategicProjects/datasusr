# Offline tests for the catalog, path building, file naming, cache and
# download helpers. Nothing here touches the network.

# ---- file names --------------------------------------------------------------

test_that("SIM DO and SINASC DN without uf expand to all UFs", {
  sim <- datasus_list_files("SIM", "DO", year = 2022,
                            check_exists = FALSE, verbose = FALSE)
  expect_gt(nrow(sim), 0L)
  expect_true(all(paste0("DO", datasus_ufs(), "2022.dbc") %in% sim$file_name))

  dn <- datasusr:::.datasus_candidate_file_names("SINASC", "DN", year = 2021)
  expect_equal(nrow(dn), length(datasus_ufs()))
  expect_setequal(dn$file_name, paste0("DN", datasus_ufs(), "2021.dbc"))

  do_pe <- datasusr:::.datasus_candidate_file_names("SIM", "DO", year = 2022, uf = "PE")
  expect_equal(do_pe$file_name, "DOPE2022.dbc")
})

test_that(".datasus_candidate_file_names builds the documented names", {
  f <- datasusr:::.datasus_candidate_file_names
  expect_equal(f("SIHSUS", "RD", year = 2024, month = 1, uf = "PE")$file_name,
               "RDPE2401.dbc")
  expect_equal(f("SIM", "DOFET", year = 2022)$file_name, "DOFET22.dbc")
  expect_equal(f("SINAN", "DENG", year = 2023)$file_name, "DENGBR23.dbc")
  expect_equal(f("SINAN_P", "DENG", year = 2024)$file_name, "DENGBR24.dbc")
  expect_equal(f("PO", "PO", year = 2020)$file_name, "POBR2020.dbc")
  expect_equal(f("RESP", "RESP", year = 2022, uf = "PE")$file_name, "RESPPE22.dbc")
  expect_equal(nrow(f("CNES", "ST", year = 2024, month = 1:3, uf = c("PE", "PB"))), 6L)

  expect_error(f("SIHSUS", "RD", year = 2024, uf = "PE"), "year.*month")
  expect_error(f("SIHSUS", "RD", year = 2024, month = 1), "uf")
  expect_error(f("SINAN", "DENG"), "year")
})

# ---- path templates ----------------------------------------------------------

test_that("datasus_build_path picks SIHSUS historical/current trees", {
  hist <- datasus_build_path("SIHSUS", "RD", year = 2007, month = 12)
  expect_equal(hist$period, "historical")
  expect_match(hist$path, "199201_200712")

  cur <- datasus_build_path("SIHSUS", "RD", year = 2008, month = 1)
  expect_equal(cur$period, "current")
  expect_match(cur$path, "200801_")

  both <- datasus_build_path("SIHSUS", "RD", year = c(2007, 2008), month = 1)
  expect_setequal(both$period, c("historical", "current"))

  expect_error(datasus_build_path("SIHSUS", "RD", year = 2024), "required")
})

test_that("datasus_build_path handles SINASC year vectors without recycling", {
  expect_no_warning(
    p <- datasus_build_path("SINASC", "DN", year = c(1995L, 2024L))
  )
  expect_setequal(p$period, c("historical", "current", "prelim"))

  p <- datasus_build_path("SINASC", "DN", year = c(2020L, 2021L, 2022L),
                          include_prelim = FALSE)
  expect_equal(p$period, "current")

  p <- datasus_build_path("SINASC", "DN", year = 1994L, include_prelim = FALSE)
  expect_equal(p$period, "historical")
})

# ---- catalog -----------------------------------------------------------------

test_that("SINAN_P and ESUSNOTIFICA_P have file types and can be listed", {
  sp <- datasus_file_types(source = "SINAN_P")
  expect_setequal(sp$file_type, datasus_file_types(source = "SINAN")$file_type)
  expect_true(all(sp$availability == "prelim"))
  expect_true(all(sp$scope == "BR"))
  expect_true(all(sp$frequency == "yearly"))

  out <- datasus_list_files("SINAN_P", "DENG", year = 2024,
                            check_exists = FALSE, verbose = FALSE)
  expect_equal(out$file_name, "DENGBR24.dbc")
  expect_match(out$url, "SINAN/DADOS/PRELIM/DENGBR24.dbc$")

  out <- datasus_list_files("ESUSNOTIFICA_P", "DCCR", year = 2024,
                            check_exists = FALSE, verbose = FALSE)
  expect_equal(nrow(out), 1L)

  # every fetchable source has at least one file type
  fetchable <- datasusr:::.datasus_sources_tbl()
  fetchable <- fetchable$source[fetchable$access == "fetch"]
  expect_true(all(fetchable %in% datasus_file_types()$source))
})

# ---- argument validation -----------------------------------------------------

test_that("datasus_list_files validates uf, year and month early", {
  expect_error(
    datasus_list_files("SIHSUS", "RD", year = 2024, month = 1, uf = "XX",
                       verbose = FALSE),
    "uf"
  )
  expect_error(
    datasus_list_files("SIHSUS", "RD", year = 1900, month = 1, uf = "PE",
                       verbose = FALSE),
    "year"
  )
  expect_error(
    datasus_list_files("SIHSUS", "RD", year = 2024.5, month = 1, uf = "PE",
                       verbose = FALSE),
    "year"
  )
  expect_error(
    datasus_list_files("SIHSUS", "RD", year = NA, month = 1, uf = "PE",
                       verbose = FALSE),
    "year"
  )
  expect_error(
    datasus_list_files("SIHSUS", "RD", year = 2024, month = 13, uf = "PE",
                       verbose = FALSE),
    "month"
  )
  expect_error(
    datasus_list_files("SIHSUS", "RD", year = 2024, month = 0, uf = "PE",
                       verbose = FALSE),
    "month"
  )
  # lower-case uf is accepted
  out <- datasus_list_files("SIHSUS", "RD", year = 2024, month = 1, uf = "pe",
                            check_exists = FALSE, verbose = FALSE)
  expect_equal(out$file_name, "RDPE2401.dbc")
})

# ---- FTP listing (mocked, no network) ---------------------------------------

test_that("listing failures warn and keep files with exists = NA", {
  local_mocked_bindings(
    datasus_ftp_ls = function(path, ...) stop("Timeout was reached"),
    .package = "datasusr"
  )
  expect_warning(
    out <- datasus_list_files("SIHSUS", "RD", year = 2024, month = 1,
                              uf = "PE", verbose = FALSE),
    "Could not list FTP directory"
  )
  expect_equal(nrow(out), 1L)
  expect_true(is.na(out$exists))
})

test_that("file names are matched case-insensitively against the listing", {
  local_mocked_bindings(
    datasus_ftp_ls = function(path, ...) {
      tibble::tibble(ftp_url = path, entry = c("rdpe2401.dbc", "RDPB2401.dbc"))
    },
    .package = "datasusr"
  )
  out <- datasus_list_files("SIHSUS", "RD", year = 2024, month = 1,
                            uf = c("PE", "PB", "AC"), verbose = FALSE)
  expect_setequal(out$file_name, c("rdpe2401.dbc", "RDPB2401.dbc"))
  expect_true(all(out$exists))
  expect_true(any(grepl("/rdpe2401\\.dbc$", out$url)))
})

# ---- download (file:// URLs, no network) -------------------------------------

# Fresh directory under tempdir() (cleaned up with the R session).
tmp_dir <- function() {
  d <- tempfile("datasusr-test-")
  dir.create(d)
  d
}

local_src_files <- function() {
  src <- tmp_dir()
  writeBin(as.raw(1:10), file.path(src, "cur.bin"))
  writeBin(as.raw(11:30), file.path(src, "pre.bin"))
  tibble::tibble(
    source    = "SIM",
    file_type = "DO",
    period    = c("current", "prelim"),
    file_name = "DOPE2022.dbc",
    url       = paste0("file://", file.path(src, c("cur.bin", "pre.bin")))
  )
}

test_that("cache layout includes period so current/prelim do not collide", {
  files <- local_src_files()
  cache <- tmp_dir()

  dl <- datasus_download(files, cache_dir = cache, verbose = FALSE)
  expect_equal(dl$local_file,
               file.path(cache, "SIM", "DO", c("current", "prelim"), "DOPE2022.dbc"))
  expect_true(all(dl$success))
  expect_true(all(dl$downloaded))
  expect_true(all(is.na(dl$error)))
  expect_equal(file.size(dl$local_file), c(10, 20))

  # second call reuses the cache
  dl2 <- datasus_download(files, cache_dir = cache, verbose = FALSE)
  expect_false(any(dl2$downloaded))
  expect_true(all(dl2$success))

  # refresh forces re-download
  dl3 <- datasus_download(files, cache_dir = cache, refresh = TRUE, verbose = FALSE)
  expect_true(all(dl3$downloaded))
})

test_that("failed downloads are reported and leave no partial file", {
  files <- local_src_files()
  files$url[[2]] <- paste0(files$url[[2]], ".missing")
  cache <- tmp_dir()

  expect_message(
    dl <- datasus_download(files, cache_dir = cache, verbose = FALSE),
    "Failed"
  )
  expect_equal(dl$success, c(TRUE, FALSE))
  expect_equal(dl$downloaded, c(TRUE, FALSE))
  expect_false(is.na(dl$error[[2]]))
  expect_false(file.exists(dl$local_file[[2]]))
  expect_false(file.exists(paste0(dl$local_file[[2]], ".part")))
  expect_length(list.files(cache, pattern = "\\.part$", recursive = TRUE), 0L)
})

test_that("datasus_fetch skips failed downloads and aborts if all fail", {
  # two distinct final files: the second one cannot be downloaded
  files <- local_src_files()
  files$period <- "current"
  files$file_name <- c("DOPE2022.dbc", "DOPE2021.dbc")
  files$url[[2]] <- paste0(files$url[[2]], ".missing")
  cache <- tmp_dir()
  local_mocked_bindings(
    datasus_list_files = function(...) files,
    read_datasus_dbc = function(file, ...) tibble::tibble(size = file.size(file)),
    .package = "datasusr"
  )
  expect_warning(
    suppressMessages(
      out <- datasus_fetch("SIM", "DO", year = 2022, uf = "PE",
                           cache_dir = cache, verbose = FALSE)
    ),
    "failed to download"
  )
  expect_equal(out$size, 10)

  # refresh is accepted and forwarded (not passed to read_datasus_dbc)
  expect_warning(
    suppressMessages(
      lst <- datasus_fetch("SIM", "DO", year = 2022, uf = "PE", bind = FALSE,
                           cache_dir = cache, refresh = TRUE, verbose = FALSE)
    ),
    "failed to download"
  )
  expect_named(lst, "DOPE2022.dbc")

  files$url[[1]] <- paste0(files$url[[1]], ".missing")
  expect_error(
    suppressMessages(
      datasus_fetch("SIM", "DO", year = 2022, uf = "PE",
                    cache_dir = tmp_dir(), verbose = FALSE)
    ),
    "All 2 downloads failed"
  )
})

test_that("datasus_fetch prefers the final file over its preliminary copy", {
  files <- local_src_files()
  local_mocked_bindings(
    datasus_list_files = function(...) files,
    read_datasus_dbc = function(file, ...) tibble::tibble(size = file.size(file)),
    .package = "datasusr"
  )
  expect_message(
    lst <- datasus_fetch("SIM", "DO", year = 2022, uf = "PE", bind = FALSE,
                         cache_dir = tmp_dir(), verbose = TRUE),
    "preliminary"
  )
  expect_named(lst, "DOPE2022.dbc")
  expect_equal(lst[[1]]$size, 10)

  # bound result has the rows of the final file only
  out <- datasus_fetch("SIM", "DO", year = 2022, uf = "PE",
                       cache_dir = tmp_dir(), verbose = FALSE)
  expect_equal(out$size, 10)

  # a preliminary-only file is still read
  files_prelim_only <- files[2, ]
  local_mocked_bindings(datasus_list_files = function(...) files_prelim_only,
                        .package = "datasusr")
  out2 <- datasus_fetch("SIM", "DO", year = 2022, uf = "PE",
                        cache_dir = tmp_dir(), verbose = FALSE)
  expect_equal(out2$size, 20)
})

test_that("use_cache = FALSE without dest_dir writes under tempdir()", {
  files <- local_src_files()[1, ]
  dl <- datasus_download(files, use_cache = FALSE, verbose = FALSE)
  expect_true(dl$success)
  expect_true(startsWith(normalizePath(dl$local_file),
                         normalizePath(tempdir())))
  expect_true(is.na(dl$cache_dir))
  unlink(dirname(dirname(dirname(dirname(dl$local_file)))), recursive = TRUE)
})

test_that("existing files in dest_dir are not re-downloaded unless asked", {
  files <- local_src_files()[1, ]
  dest <- tmp_dir()
  dl1 <- datasus_download(files, dest_dir = dest, use_cache = FALSE, verbose = FALSE)
  expect_true(dl1$downloaded)
  dl2 <- datasus_download(files, dest_dir = dest, use_cache = FALSE, verbose = FALSE)
  expect_false(dl2$downloaded)
  dl3 <- datasus_download(files, dest_dir = dest, use_cache = FALSE,
                          overwrite = TRUE, verbose = FALSE)
  expect_true(dl3$downloaded)
})

test_that("curl options never impose a total timeout by default", {
  opts <- datasusr:::.datasus_curl_opts()
  expect_null(opts$timeout)
  expect_equal(opts$connecttimeout, 60L)
  expect_equal(opts$low_speed_time, 120L)
  expect_equal(datasusr:::.datasus_curl_opts(300)$timeout, 300L)
  expect_null(datasusr:::.datasus_curl_opts(NULL)$timeout)
  expect_equal(datasusr:::.datasus_ls_timeout(Inf), 120)
})

# ---- cache helpers -----------------------------------------------------------

test_that("datasus_cache_* work on a temporary directory", {
  cache <- tmp_dir()
  expect_equal(datasus_cache_dir(cache), cache)
  expect_equal(nrow(datasus_cache_list(cache)), 0L)
  expect_equal(datasus_cache_info(cache, verbose = FALSE)$n_files, 0L)

  dir.create(file.path(cache, "SIM", "DO", "current"), recursive = TRUE)
  f1 <- file.path(cache, "SIM", "DO", "current", "a.dbc")
  f2 <- file.path(cache, "b.dbc")
  writeBin(raw(100), f1)
  writeBin(raw(2000), f2)
  Sys.setFileTime(f2, Sys.time() - 200 * 86400)

  lst <- datasus_cache_list(cache)
  expect_setequal(lst$file_name, c("a.dbc", "b.dbc"))
  info <- datasus_cache_info(cache, verbose = FALSE)
  expect_equal(info$n_files, 2L)
  expect_equal(info$total_size_bytes, 2100)

  pr <- datasus_cache_prune(cache, older_than_days = 90, verbose = FALSE)
  expect_equal(basename(pr$path), "b.dbc")
  expect_true(all(pr$removed))

  cl <- datasus_cache_clear(cache, verbose = FALSE)
  expect_equal(nrow(cl), 1L)
  expect_equal(nrow(datasus_cache_list(cache)), 0L)
})

test_that("datasus_cache_dir honours env var and option", {
  old_env <- Sys.getenv("DATASUSR_CACHE_DIR", unset = NA)
  old_opt <- options(datasusr.cache_dir = NULL)
  on.exit({
    if (is.na(old_env)) Sys.unsetenv("DATASUSR_CACHE_DIR")
    else Sys.setenv(DATASUSR_CACHE_DIR = old_env)
    options(old_opt)
  }, add = TRUE)

  Sys.setenv(DATASUSR_CACHE_DIR = "/env/cache")
  expect_equal(datasus_cache_dir(), "/env/cache")
  Sys.setenv(DATASUSR_CACHE_DIR = "")
  options(datasusr.cache_dir = "/opt/cache")
  expect_equal(datasus_cache_dir(), "/opt/cache")
  expect_equal(datasus_cache_dir("/arg"), "/arg")
  options(datasusr.cache_dir = NULL)
  expect_equal(datasus_cache_dir(), file.path(tempdir(), "datasusr-cache"))
})

# ---- format_bytes ------------------------------------------------------------

test_that("format_bytes formats sizes", {
  expect_equal(format_bytes(c(0, 512, 1024, 1048576, NA)),
               c("0 B", "512 B", "1 KB", "1 MB", NA))
  expect_equal(format_bytes(1536), "1.5 KB")
})

test_that("datasus_fetch dedups preliminary copies case-insensitively and only when the final one is usable", {
  files <- local_src_files()
  files$file_name <- c("DOPE2022.dbc", "dope2022.dbc")
  files$exists <- c(TRUE, TRUE)
  local_mocked_bindings(
    datasus_list_files = function(...) files,
    read_datasus_dbc = function(file, ...) tibble::tibble(size = file.size(file)),
    .package = "datasusr"
  )
  out <- datasus_fetch("SIM", "DO", year = 2022, uf = "PE",
                       cache_dir = tmp_dir(), verbose = FALSE)
  expect_equal(out$size, 10)

  # final candidate unverified (exists = NA) and unreachable: the verified
  # preliminary copy must still be read instead of aborting
  files2 <- files
  files2$exists <- c(NA, TRUE)
  files2$url[[1]] <- paste0(files2$url[[1]], ".missing")
  local_mocked_bindings(datasus_list_files = function(...) files2, .package = "datasusr")
  expect_warning(
    out2 <- datasus_fetch("SIM", "DO", year = 2022, uf = "PE",
                          cache_dir = tmp_dir(), verbose = FALSE),
    "failed to download"
  )
  expect_equal(out2$size, 20)

  # final candidate unverified but reachable: after download the preliminary
  # copy is dropped
  files3 <- files
  files3$exists <- c(NA, TRUE)
  local_mocked_bindings(datasus_list_files = function(...) files3, .package = "datasusr")
  out3 <- datasus_fetch("SIM", "DO", year = 2022, uf = "PE",
                        cache_dir = tmp_dir(), verbose = FALSE)
  expect_equal(out3$size, 10)
})

test_that("datasus_fetch treats SINAN_P as the preliminary alias of SINAN", {
  files <- local_src_files()
  files$source    <- c("SINAN", "SINAN_P")
  files$file_type <- "DENG"
  files$period    <- "current"
  files$file_name <- "DENGBR23.dbc"
  files$exists    <- TRUE
  local_mocked_bindings(
    datasus_list_files = function(...) files,
    read_datasus_dbc = function(file, ...) tibble::tibble(size = file.size(file)),
    .package = "datasusr"
  )
  out <- datasus_fetch(c("SINAN", "SINAN_P"), "DENG", year = 2023,
                       cache_dir = tmp_dir(), verbose = FALSE)
  expect_equal(out$size, 10)
  expect_equal(.datasus_prelim_rows(files), c(FALSE, TRUE))
})

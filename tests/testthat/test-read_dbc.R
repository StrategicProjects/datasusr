# Offline tests for read_datasus_dbc() using synthetic dBase III files built
# by make_dbf() (helper-dbf.R).

rd <- function(path, ...) read_datasus_dbc(path, verbose = FALSE, ...)

pad <- function(x, n) formatC(x, width = n, flag = "-")
padl <- function(x, n) formatC(x, width = n)

basic_fields <- list(
  list(name = "NAME", type = "C", len = 5),
  list(name = "CNT", type = "N", len = 4),
  list(name = "VAL", type = "N", len = 6, dec = 2),
  list(name = "RATE", type = "F", len = 6),
  list(name = "DT", type = "D", len = 8),
  list(name = "OK", type = "L", len = 1)
)

basic_records <- c(
  paste0(" ", pad("ana", 5), padl("12", 4), padl("3.50", 6), padl("1.5", 6), "20240115", "T"),
  paste0(" ", pad("bruno", 5), padl("-7", 4), padl("10.25", 6), padl("2", 6), "20231231", "F"),
  paste0(" ", pad("", 5), padl("", 4), padl("", 6), padl("", 6), pad("", 8), "?")
)

test_that("happy path reads C/N/F/D/L fields with proper types", {
  p <- make_dbf(basic_fields, basic_records)
  x <- rd(p)
  expect_s3_class(x, "tbl_df")
  expect_equal(names(x), c("name", "cnt", "val", "rate", "dt", "ok"))
  expect_equal(nrow(x), 3L)
  expect_identical(x$name, c("ana", "bruno", ""))
  expect_identical(x$cnt, c(12L, -7L, NA))
  expect_identical(x$val, c(3.5, 10.25, NA))
  expect_type(x$rate, "double")
  expect_identical(x$rate, c(1.5, 2, NA))
  expect_identical(x$dt, c("20240115", "20231231", ""))
  expect_identical(x$ok, c(TRUE, FALSE, NA))
})

test_that("parse_dates, col_types, clean_names and n_max work", {
  p <- make_dbf(basic_fields, basic_records)

  x <- rd(p, parse_dates = TRUE)
  expect_s3_class(x$dt, "Date")
  expect_equal(x$dt, as.Date(c("2024-01-15", "2023-12-31", NA)))

  x <- rd(p, col_types = c(cnt = "character", Val = "integer", dt = "date"))
  expect_identical(x$cnt, c("12", "-7", ""))
  expect_identical(x$val, c(NA_integer_, NA_integer_, NA_integer_))
  expect_equal(x$dt, as.Date(c("2024-01-15", "2023-12-31", NA)))

  x <- rd(p, clean_names = FALSE)
  expect_equal(names(x), c("NAME", "CNT", "VAL", "RATE", "DT", "OK"))

  x <- rd(p, n_max = 2)
  expect_equal(nrow(x), 2L)
  expect_identical(x$name, c("ana", "bruno"))

  x <- rd(p, guess_types = FALSE)
  expect_type(x$cnt, "integer")
  expect_type(x$val, "double")
})

test_that("encoding is validated and aliases are accepted", {
  f <- list(list(name = "TXT", type = "C", len = 4))
  p <- make_dbf(f, " caf\xe9")
  expect_identical(rd(p)$txt, "caf\u00e9")
  expect_identical(rd(p, encoding = "ISO-8859-1")$txt, "caf\u00e9")
  expect_identical(rd(p, encoding = "Latin-1")$txt, "caf\u00e9")
  expect_identical(Encoding(rd(p, encoding = "LATIN1")$txt), "latin1")
  expect_no_error(rd(p, encoding = "utf-8"))
  expect_no_error(rd(p, encoding = "unknown"))
  expect_error(rd(p, encoding = "CP1252"), "Unsupported")
  expect_error(rd(p, encoding = "foo"), "Unsupported")
})

test_that("field lengths exceeding the record length are rejected (item 1)", {
  f <- list(
    list(name = "A", type = "C", len = 200),
    list(name = "B", type = "C", len = 200)
  )
  # record_len declared as 11 but fields sum to 400
  p <- make_dbf(f, strrep(" ", 11), record_len = 11L)
  expect_error(rd(p), "exceed the declared record length")

  f0 <- list(list(name = "A", type = "C", len = 0))
  p0 <- make_dbf(f0, " ", record_len = 1L)
  expect_error(rd(p0), "length 0")

  fl <- list(list(name = "A", type = "L", len = 0), list(name = "B", type = "C", len = 2))
  pl <- make_dbf(fl, "  x", record_len = 3L)
  expect_error(rd(pl), "length 0")
})

test_that("deleted records are skipped and n_max counts live records (item 4)", {
  f <- list(list(name = "ID", type = "N", len = 3))
  recs <- c("*  1", "   2", "*  3", "   4", "   5")
  p <- make_dbf(f, recs)
  expect_identical(rd(p)$id, c(2L, 4L, 5L))
  expect_identical(rd(p, n_max = 2)$id, c(2L, 4L))
  expect_identical(rd(p, n_max = 1)$id, 2L)

  pall <- make_dbf(f, c("*  1", "*  2"))
  x <- rd(pall)
  expect_equal(nrow(x), 0L)
  expect_named(x, "id")
})

test_that("integer overflow and INT_MIN fall back to double / NA (item 5)", {
  f <- list(list(name = "N", type = "N", len = 12))
  big <- make_dbf(f, c(paste0(" ", padl("2147483648", 12)), paste0(" ", padl("1", 12))))
  x <- rd(big)
  expect_type(x$n, "double")
  expect_identical(x$n, c(2147483648, 1))

  imin <- make_dbf(f, c(paste0(" ", padl("-2147483648", 12)), paste0(" ", padl("5", 12))))
  x <- rd(imin)
  expect_type(x$n, "double")
  expect_identical(x$n, c(-2147483648, 5))

  huge <- make_dbf(f, paste0(" ", padl("99999999999", 12)))
  x <- rd(huge, col_types = c(N = "integer"))
  expect_identical(x$n, NA_integer_)

  x <- rd(imin, col_types = c(N = "integer"))
  expect_identical(x$n, c(NA_integer_, 5L))

  imax <- make_dbf(f, paste0(" ", padl("2147483647", 12)))
  expect_identical(rd(imax)$n, 2147483647L)
})

test_that("trim_ws = FALSE only affects character fields (item 6)", {
  f <- list(
    list(name = "C", type = "C", len = 4),
    list(name = "N", type = "N", len = 5),
    list(name = "D", type = "N", len = 6, dec = 1),
    list(name = "L", type = "L", len = 1),
    list(name = "DT", type = "D", len = 10)
  )
  p <- make_dbf(f, paste0(" ", " ab ", "12   ", " 1.5  ", "T", " 20240229 "))
  x <- rd(p, trim_ws = FALSE, parse_dates = TRUE)
  expect_identical(x$c, " ab ")
  expect_identical(x$n, 12L)
  expect_identical(x$d, 1.5)
  expect_identical(x$l, TRUE)
  expect_equal(x$dt, as.Date("2024-02-29"))

  x <- rd(p, trim_ws = TRUE)
  expect_identical(x$c, "ab")
})

test_that("invalid calendar dates become NA (item 8)", {
  f <- list(list(name = "DT", type = "D", len = 8))
  p <- make_dbf(f, c(" 20240231", " 20230229", " 20240229", " 20000229",
                     " 19000229", " 20240431", " 20241231", " 2024130a"))
  x <- rd(p, parse_dates = TRUE)
  expect_equal(
    x$dt,
    as.Date(c(NA, NA, "2024-02-29", "2000-02-29", NA, NA, "2024-12-31", NA))
  )
})

test_that("declared record count larger than data warns (item 10)", {
  f <- list(list(name = "ID", type = "N", len = 3))
  p <- make_dbf(f, c("   1", "   2"), n_records = 5L)
  expect_warning(x <- rd(p), "declares 5 records but only 2 are present")
  expect_identical(x$id, c(1L, 2L))
})

test_that("select is case-insensitive and warns on unmatched names (item 11)", {
  f <- list(
    list(name = "Abc", type = "C", len = 2),
    list(name = "XYZ", type = "C", len = 2)
  )
  p <- make_dbf(f, " aaxx")
  x <- rd(p, select = "abc")
  expect_named(x, "abc")
  x <- rd(p, select = "ABC", clean_names = FALSE)
  expect_named(x, "Abc")
  expect_warning(x <- rd(p, select = c("xyz", "nope", "Other")), "nope")
  expect_named(x, "xyz")
  expect_no_warning(rd(p, select = c("xyz", "ABC")))
  x <- rd(p, col_types = c(abc = "integer"))
  expect_type(x$abc, "integer")
})

test_that("truncated plain DBF is read with a warning (item 12)", {
  f <- list(list(name = "ID", type = "N", len = 3))
  p <- make_dbf(f, c("   1", "   2", "   3", "   4"))
  raw <- readBin(p, "raw", file.info(p)$size)
  # header (32 + 32 + 1 = 65 bytes) + 2.5 records, no EOF marker
  cut <- tempfile(fileext = ".dbf")
  writeBin(raw[seq_len(65 + 4 * 2 + 2)], cut)
  expect_warning(x <- rd(cut), "declares 4 records but only 2 are present")
  expect_identical(x$id, c(1L, 2L))
})

test_that("garbage input errors cleanly", {
  junk <- tempfile(fileext = ".dbc")
  writeBin(as.raw(c(0xFF, 0x00, 0x13, 0x37, 0x42)), junk)
  expect_error(rd(junk))
  expect_error(rd(tempfile()), "not found")
})

test_that("a tiny DBC whose payload exceeds the record area is still decompressed", {
  # Literal-only PKWare DCL stream encoding one live record " X" (2 bytes):
  # 8-bit literal flag (0), 8-bit dictionary size (4), one raw literal per
  # byte (flag bit 0 + 8 data bits), then the end code (length 519).
  bits <- c(as.integer(intToBits(0))[1:8], as.integer(intToBits(4))[1:8])
  for (b in as.integer(charToRaw(" X"))) bits <- c(bits, 0L, as.integer(intToBits(b))[1:8])
  bits <- c(bits, 1L, rep(0L, 7), rep(1L, 8))
  bits <- c(bits, rep(0L, (-length(bits)) %% 8L))
  payload <- as.raw(colSums(matrix(bits, nrow = 8) * 2^(0:7)))
  expect_gt(length(payload), 2L) # compressed payload is larger than the record

  plain <- make_dbf(list(list(name = "X", type = "C", len = 1)), " A")
  hdr <- readBin(plain, "raw", 65L)

  with_crc <- tempfile(fileext = ".dbc")
  writeBin(c(hdr, raw(4), payload), with_crc)
  expect_equal(read_datasus_dbc(with_crc, verbose = FALSE)$x, "X")

  no_crc <- tempfile(fileext = ".dbc")
  writeBin(c(hdr, payload), no_crc)
  expect_equal(read_datasus_dbc(no_crc, verbose = FALSE)$x, "X")
})

test_that("n_max is floored to a whole number of rows", {
  p <- make_dbf(list(list(name = "X", type = "C", len = 1)), c(" A", " B", " C"))
  expect_equal(nrow(read_datasus_dbc(p, n_max = 1.5, verbose = FALSE)), 1L)
  expect_equal(nrow(read_datasus_dbc(p, n_max = 2, verbose = FALSE)), 2L)
  expect_error(read_datasus_dbc(p, n_max = 0.5, verbose = FALSE), "n_max")
})

# Build a minimal dBase III (0x03) file in memory for tests.
# fields: list of list(name=, type=, len=, dec=)
# records: character vector; each element must be exactly 1 + sum(len) bytes
#          (first byte is the deletion flag: " " live, "*" deleted)
make_dbf <- function(fields, records, n_records = length(records),
                     record_len = NULL, path = tempfile(fileext = ".dbf")) {
  header_len <- 32L + 32L * length(fields) + 1L
  record_len <- record_len %||% (1L + sum(vapply(fields, `[[`, 0, "len")))
  le16 <- function(x) as.raw(c(x %% 256L, x %/% 256L))
  le32 <- function(x) as.raw(c(x %% 256L, (x %/% 256L) %% 256L,
                               (x %/% 65536L) %% 256L, x %/% 16777216L))
  hdr <- c(as.raw(0x03), as.raw(c(24L, 1L, 1L)), le32(n_records),
           le16(header_len), le16(record_len), raw(20))
  fd <- function(f) {
    n <- charToRaw(f$name)
    c(n, raw(11L - length(n)), charToRaw(f$type), raw(4),
      as.raw(f$len), as.raw(f$dec %||% 0L), raw(14))
  }
  body <- unlist(lapply(records, charToRaw))
  buf <- c(hdr, unlist(lapply(fields, fd)), as.raw(0x0D), body, as.raw(0x1A))
  writeBin(buf, path)
  path
}
`%||%` <- function(a, b) if (is.null(a)) b else a

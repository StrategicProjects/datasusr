
#' @importFrom rlang %||% .env
#' @keywords internal
NULL

# Column names used in dplyr pipelines (suppress R CMD check NOTEs)
utils::globalVariables(c(
  "accessed_time", "availability", "description", "dest_file", "entry",
  "exists", "file_name", "file_type", "frequency", "ftp_url",
  "modality_code", "modified_time", "path", "period", "reason",
  "scope", "source_dir", "token", "was_cached"
))

#' Format byte sizes for display
#'
#' Converts raw byte counts into human-readable strings (e.g. `"1.23 MB"`).
#'
#' @param x Numeric vector of byte sizes.
#'
#' @return A character vector with formatted sizes.
#' @export
#'
#' @examples
#' format_bytes(c(1024, 1048576, NA))
format_bytes <- function(x) {
  units <- c("B", "KB", "MB", "GB", "TB")
  vapply(x, function(value) {
    if (is.na(value)) return(NA_character_)
    size <- as.numeric(value)
    unit <- 1L
    while (size >= 1024 && unit < length(units)) {
      size <- size / 1024
      unit <- unit + 1L
    }
    paste0(format(round(size, 2), trim = TRUE, scientific = FALSE), " ", units[[unit]])
  }, character(1))
}

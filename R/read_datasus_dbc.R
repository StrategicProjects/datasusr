#' Read DATASUS DBC files
#'
#' Reads a DATASUS `.dbc` file directly into R using native C code for
#' PKWare DCL decompression and DBF parsing. The function always returns a
#' tibble and is designed to work well with the tidyverse.
#'
#' @param file Path to a `.dbc` or `.dbf` file. Both compressed (DBC) and
#'   uncompressed (DBF) formats are accepted.
#' @param select Optional character vector of column names to keep. When
#'   `NULL` (the default), all columns are returned. Names are matched
#'   case-insensitively, so both `"UF_ZI"` and `"uf_zi"` work.
#' @param n_max Maximum number of rows to read. Defaults to `Inf` (all rows).
#' @param trim_ws Logical. Trim leading/trailing whitespace from character
#'   fields (default `TRUE`).
#' @param encoding Encoding of the DBF character fields. Typically `"latin1"`
#'   (the default for DATASUS files) or `"UTF-8"`.
#' @param guess_types Logical. Inspect numeric fields to distinguish
#'   integer-like columns from double columns (default `TRUE`). Disable for
#'   faster reads when precise types are not needed.
#' @param col_types Optional named character vector of explicit column types.
#'   Supported values: `"character"`, `"integer"`, `"double"`, `"logical"`,
#'   `"date"`. Names are matched case-insensitively against the original
#'   DBF field names.
#' @param parse_dates Logical. If `TRUE`, DBF date fields (`D` type) are
#'   returned as `Date`. Character fields are only parsed as dates when
#'   explicitly listed in `col_types` (default `FALSE`).
#' @param clean_names Logical. If `TRUE` (the default), column names are
#'   converted to `snake_case` (lowercase with underscores). The original
#'   DATASUS names are uppercase (e.g. `UF_ZI` becomes `uf_zi`).
#' @param verbose Logical. Emit progress messages (default `TRUE`).
#'
#' @return A tibble.
#' @export
#'
#' @examples
#' \dontrun{
#' # Basic read (column names in snake_case by default)
#' x <- read_datasus_dbc("RDPE2401.dbc")
#' # columns: uf_zi, ano_cmpt, val_tot, ...
#'
#' # Select works with either case
#' x <- read_datasus_dbc(
#'   "RDPE2401.dbc",
#'   select = c("uf_zi", "ano_cmpt", "val_tot")
#' )
#'
#' # Keep original uppercase names
#' x <- read_datasus_dbc("RDPE2401.dbc", clean_names = FALSE)
#' # columns: UF_ZI, ANO_CMPT, VAL_TOT, ...
#' }
read_datasus_dbc <- function(
  file,
  select = NULL,
  n_max = Inf,
  trim_ws = TRUE,
  encoding = "latin1",
  guess_types = TRUE,
  col_types = NULL,
  parse_dates = FALSE,
  clean_names = TRUE,
  verbose = TRUE
) {
  # --- input validation -------------------------------------------------------
  if (!is.character(file) || length(file) != 1L || is.na(file)) {
    cli::cli_abort("{.arg file} must be a single non-missing file path.")
  }

  if (!file.exists(file)) {
    cli::cli_abort(c(
      "File not found: {.path {file}}",
      "i" = "Check the path or use {.fn datasus_download} to retrieve files from the FTP."
    ))
  }

  if (!is.null(select) && !is.character(select)) {
    cli::cli_abort("{.arg select} must be {.code NULL} or a character vector of column names.")
  }

  if (!is.numeric(n_max) || length(n_max) != 1L || is.na(n_max) || n_max <= 0) {
    cli::cli_abort("{.arg n_max} must be a single positive number.")
  }

  if (!is.logical(trim_ws) || length(trim_ws) != 1L || is.na(trim_ws)) {
    cli::cli_abort("{.arg trim_ws} must be {.code TRUE} or {.code FALSE}.")
  }

  if (!is.character(encoding) || length(encoding) != 1L || is.na(encoding)) {
    cli::cli_abort("{.arg encoding} must be a single character string (e.g. {.val latin1}).")
  }

  if (!is.logical(guess_types) || length(guess_types) != 1L || is.na(guess_types)) {
    cli::cli_abort("{.arg guess_types} must be {.code TRUE} or {.code FALSE}.")
  }

  if (!is.null(col_types)) {
    if (!is.character(col_types) || is.null(names(col_types))) {
      cli::cli_abort(c(
        "{.arg col_types} must be a named character vector.",
        "i" = 'Example: {.code c(COL_NAME = "double", OTHER = "character")}'
      ))
    }
    valid_types <- c("character", "integer", "double", "logical", "date")
    bad <- setdiff(unname(col_types), valid_types)
    if (length(bad) > 0L) {
      cli::cli_abort(c(
        "Invalid type{?s} in {.arg col_types}: {.val {bad}}.",
        "i" = "Supported types: {.val {valid_types}}."
      ))
    }
  }

  if (!is.logical(parse_dates) || length(parse_dates) != 1L || is.na(parse_dates)) {
    cli::cli_abort("{.arg parse_dates} must be {.code TRUE} or {.code FALSE}.")
  }

  if (!is.logical(verbose) || length(verbose) != 1L || is.na(verbose)) {
    cli::cli_abort("{.arg verbose} must be {.code TRUE} or {.code FALSE}.")
  }

  # --- read -------------------------------------------------------------------
  file_size <- file.info(file)$size

  if (isTRUE(verbose)) {
    cli::cli_alert_info(
      "Reading {.file {basename(file)}} ({format_bytes(file_size)})"
    )
  }

  # Normalise select/col_types to uppercase for case-insensitive matching
  select_upper <- if (!is.null(select)) toupper(select) else character()
  ct_values    <- if (!is.null(col_types)) unname(col_types) else character()
  ct_names     <- if (!is.null(col_types)) toupper(names(col_types)) else character()

  out <- .Call(
    "_datasusr_c_read_datasus_dbc",
    normalizePath(file, winslash = "/", mustWork = TRUE),
    select_upper,
    as.double(n_max),
    isTRUE(trim_ws),
    enc2utf8(encoding),
    isTRUE(guess_types),
    ct_values,
    ct_names,
    isTRUE(parse_dates),
    isTRUE(verbose),
    PACKAGE = "datasusr"
  )

  out <- tibble::as_tibble(out, .name_repair = "unique")

  if (isTRUE(clean_names)) {
    names(out) <- tolower(names(out))
  }

  if (isTRUE(verbose)) {
    cli::cli_alert_success(
      "Read complete: {format(nrow(out), big.mark = ',')} rows x {ncol(out)} columns."
    )
  }

  out
}

library(bench)
library(datasusr)

file <- "SPPE2601.dbc"

res <- bench::mark(
  default = read_datasus_dbc(file),
  no_guess = read_datasus_dbc(file, guess_types = FALSE),
  selected = read_datasus_dbc(
    file,
    select = c("SP_GESTOR", "SP_NAIH", "SP_VALATO")
  ),
  typed = read_datasus_dbc(
    file,
    select = c("SP_GESTOR", "SP_NAIH", "SP_DTINTER", "SP_VALATO"),
    col_types = c(
      SP_GESTOR = "character",
      SP_NAIH = "character",
      SP_DTINTER = "date",
      SP_VALATO = "double"
    ),
    parse_dates = TRUE,
    guess_types = FALSE
  ),
  iterations = 5,
  check = FALSE
)

print(res)

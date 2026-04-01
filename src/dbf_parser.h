#ifndef DATASUSR_DBF_PARSER_H
#define DATASUSR_DBF_PARSER_H

#include <Rinternals.h>
#include <stddef.h>

SEXP parse_dbf_parts(
    const unsigned char *header_buf,
    size_t header_len,
    const unsigned char *records_buf,
    size_t records_len,
    SEXP select,
    double n_max,
    int trim_ws,
    const char *encoding,
    int guess_types,
    SEXP col_types_values,
    SEXP col_types_names,
    int parse_dates,
    int verbose
);

SEXP parse_dbf_buffer(
    const unsigned char *buf,
    size_t len,
    SEXP select,
    double n_max,
    int trim_ws,
    const char *encoding,
    int guess_types,
    SEXP col_types_values,
    SEXP col_types_names,
    int parse_dates,
    int verbose
);

#endif

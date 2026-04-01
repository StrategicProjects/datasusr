#include "dbf_parser.h"

#include <R.h>
#include <Rinternals.h>
#include <R_ext/Print.h>

#include <ctype.h>
#include <limits.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    COL_AUTO = 0,
    COL_CHARACTER = 1,
    COL_INTEGER = 2,
    COL_DOUBLE = 3,
    COL_LOGICAL = 4,
    COL_DATE = 5
} col_target_t;

typedef struct {
    char *name;
    char type;
    unsigned char len;
    unsigned char dec;
    int keep;
    int out_index;
    col_target_t target;
} field_info_t;

static uint16_t le_u16(const unsigned char *p) {
    return (uint16_t) (p[0] | (p[1] << 8));
}

static uint32_t le_u32(const unsigned char *p) {
    return (uint32_t) (p[0] |
        ((uint32_t) p[1] << 8) |
        ((uint32_t) p[2] << 16) |
        ((uint32_t) p[3] << 24));
}

static int match_select(SEXP select, const char *name) {
    if (TYPEOF(select) != STRSXP || XLENGTH(select) == 0) {
        return 1;
    }

    for (R_xlen_t i = 0; i < XLENGTH(select); i++) {
        if (strcmp(CHAR(STRING_ELT(select, i)), name) == 0) {
            return 1;
        }
    }

    return 0;
}

static void trim_bounds(
    const unsigned char *src,
    int n,
    int trim_ws,
    int *start,
    int *end
) {
    int s = 0;
    int e = n;

    if (trim_ws) {
        while (s < n && isspace((unsigned char) src[s])) {
            s++;
        }
        while (e > s && isspace((unsigned char) src[e - 1])) {
            e--;
        }
    }

    *start = s;
    *end = e;
}

static void copy_trimmed(char *dest, const unsigned char *src, int n, int trim_ws) {
    int start;
    int end;
    trim_bounds(src, n, trim_ws, &start, &end);
    int out_len = end - start;
    memcpy(dest, src + start, (size_t) out_len);
    dest[out_len] = '\0';
}

static int has_decimal_or_exp(const char *x) {
    while (*x) {
        if (*x == '.' || *x == 'e' || *x == 'E') {
            return 1;
        }
        x++;
    }
    return 0;
}

static int is_all_digits_n(const char *x, int n) {
    for (int i = 0; i < n; i++) {
        if (!isdigit((unsigned char) x[i])) {
            return 0;
        }
    }
    return 1;
}

static int parse_dbf_date_days_raw(const unsigned char *src, int n) {
    if (n < 8) {
        return NA_INTEGER;
    }

    char tmp[9];
    memcpy(tmp, src, 8);
    tmp[8] = '\0';

    if (!is_all_digits_n(tmp, 8)) {
        return NA_INTEGER;
    }

    int year = (tmp[0] - '0') * 1000 + (tmp[1] - '0') * 100 + (tmp[2] - '0') * 10 + (tmp[3] - '0');
    int month = (tmp[4] - '0') * 10 + (tmp[5] - '0');
    int day = (tmp[6] - '0') * 10 + (tmp[7] - '0');

    if (month < 1 || month > 12 || day < 1 || day > 31) {
        return NA_INTEGER;
    }

    int y = year;
    int m = month;
    int d = day;

    y -= m <= 2;
    const int era = (y >= 0 ? y : y - 399) / 400;
    const unsigned yoe = (unsigned) (y - era * 400);
    const unsigned doy = (153U * (unsigned) (m + (m > 2 ? -3 : 9)) + 2U) / 5U + (unsigned) d - 1U;
    const unsigned doe = yoe * 365U + yoe / 4U - yoe / 100U + doy;

    return era * 146097 + (int) doe - 719468;
}

static int parse_yyyymmdd_char_days(const char *src) {
    if (src[0] == '\0') {
        return NA_INTEGER;
    }
    if ((int) strlen(src) != 8) {
        return NA_INTEGER;
    }
    return parse_dbf_date_days_raw((const unsigned char *) src, 8);
}

static cetype_t get_encoding_ce(const char *encoding) {
    if (encoding == NULL) {
        return CE_LATIN1;
    }

    if (strcmp(encoding, "UTF-8") == 0 || strcmp(encoding, "utf-8") == 0) {
        return CE_UTF8;
    }

    if (strcmp(encoding, "unknown") == 0) {
        return CE_NATIVE;
    }

    return CE_LATIN1;
}

static col_target_t parse_col_target(const char *x) {
    if (x == NULL) {
        return COL_AUTO;
    }
    if (strcmp(x, "character") == 0) {
        return COL_CHARACTER;
    }
    if (strcmp(x, "integer") == 0) {
        return COL_INTEGER;
    }
    if (strcmp(x, "double") == 0) {
        return COL_DOUBLE;
    }
    if (strcmp(x, "logical") == 0) {
        return COL_LOGICAL;
    }
    if (strcmp(x, "date") == 0) {
        return COL_DATE;
    }
    return COL_AUTO;
}

static col_target_t get_declared_col_target(
    SEXP col_types_values,
    SEXP col_types_names,
    const char *field_name
) {
    if (TYPEOF(col_types_values) != STRSXP ||
        TYPEOF(col_types_names) != STRSXP ||
        XLENGTH(col_types_values) == 0 ||
        XLENGTH(col_types_values) != XLENGTH(col_types_names)) {
        return COL_AUTO;
    }

    for (R_xlen_t i = 0; i < XLENGTH(col_types_names); i++) {
        if (strcmp(CHAR(STRING_ELT(col_types_names, i)), field_name) == 0) {
            return parse_col_target(CHAR(STRING_ELT(col_types_values, i)));
        }
    }

    return COL_AUTO;
}

static void free_fields(field_info_t *fields, int n_fields) {
    if (fields == NULL) {
        return;
    }
    for (int i = 0; i < n_fields; i++) {
        free(fields[i].name);
    }
    free(fields);
}

static col_target_t infer_numeric_target(
    const field_info_t *field,
    const unsigned char *records_buf,
    size_t records_len,
    uint32_t n_records,
    uint16_t record_len,
    int field_offset,
    int trim_ws
) {
    if (field->dec > 0) {
        return COL_DOUBLE;
    }

    if (!records_buf || record_len == 0) {
        return COL_INTEGER;
    }

    for (uint32_t r = 0; r < n_records; r++) {
        const unsigned char *rec = records_buf + ((size_t) r * (size_t) record_len);
        if (((size_t) (r + 1) * (size_t) record_len) > records_len) {
            break;
        }

        if (rec[0] == '*') {
            continue;
        }

        const unsigned char *field_ptr = rec + field_offset;
        char tmp[256];
        int use_len = field->len < 255 ? field->len : 255;
        copy_trimmed(tmp, field_ptr, use_len, trim_ws);

        if (tmp[0] == '\0') {
            continue;
        }

        if (has_decimal_or_exp(tmp)) {
            return COL_DOUBLE;
        }

        char *endptr = NULL;
        long val = strtol(tmp, &endptr, 10);
        if (endptr == tmp || *endptr != '\0') {
            return COL_DOUBLE;
        }
        if (val > INT_MAX || val < INT_MIN) {
            return COL_DOUBLE;
        }
    }

    return COL_INTEGER;
}

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
) {
    if (header_len < 32) {
        error("Invalid DBF header: too small.");
    }

    uint32_t n_records = le_u32(header_buf + 4);
    uint16_t header_len_decl = le_u16(header_buf + 8);
    uint16_t record_len = le_u16(header_buf + 10);

    if ((size_t) header_len_decl > header_len || record_len == 0) {
        error("Invalid DBF header.");
    }

    if ((header_len_decl - 33) % 32 != 0) {
        error("Invalid DBF header field descriptor section.");
    }

    int n_fields = (header_len_decl - 33) / 32;
    if (n_fields <= 0) {
        error("No DBF fields found.");
    }

    uint32_t available_records = (uint32_t) (records_len / (size_t) record_len);
    if (available_records < n_records) {
        n_records = available_records;
    }

    if (n_max < (double) n_records) {
        n_records = (uint32_t) n_max;
    }

    field_info_t *fields = (field_info_t *) calloc((size_t) n_fields, sizeof(field_info_t));
    if (fields == NULL) {
        error("Memory allocation failure for DBF fields.");
    }

    int kept = 0;
    int running_offset = 1;

    for (int i = 0; i < n_fields; i++) {
        const unsigned char *fd = header_buf + 32 + (i * 32);

        char raw_name[12];
        memcpy(raw_name, fd, 11);
        raw_name[11] = '\0';

        size_t k = 0;
        while (k < 11 && raw_name[k] != '\0') {
            k++;
        }

        fields[i].name = (char *) calloc(k + 1, 1);
        if (fields[i].name == NULL) {
            free_fields(fields, n_fields);
            error("Memory allocation failure for field name.");
        }

        memcpy(fields[i].name, raw_name, k);
        fields[i].name[k] = '\0';
        fields[i].type = (char) fd[11];
        fields[i].len = fd[16];
        fields[i].dec = fd[17];
        fields[i].keep = match_select(select, fields[i].name);
        fields[i].out_index = -1;
        fields[i].target = COL_AUTO;

        if (fields[i].keep) {
            fields[i].out_index = kept;
            kept++;
        }

        running_offset += fields[i].len;
    }

    running_offset = 1;
    for (int i = 0; i < n_fields; i++) {
        if (!fields[i].keep) {
            running_offset += fields[i].len;
            continue;
        }

        col_target_t declared = get_declared_col_target(
            col_types_values,
            col_types_names,
            fields[i].name
        );

        if (declared != COL_AUTO) {
            fields[i].target = declared;
            running_offset += fields[i].len;
            continue;
        }

        if (fields[i].type == 'L') {
            fields[i].target = COL_LOGICAL;
        } else if (fields[i].type == 'D') {
            fields[i].target = parse_dates ? COL_DATE : COL_CHARACTER;
        } else if (fields[i].type == 'N' || fields[i].type == 'F') {
            if (guess_types) {
                fields[i].target = infer_numeric_target(
                    &fields[i],
                    records_buf,
                    records_len,
                    n_records,
                    record_len,
                    running_offset,
                    trim_ws
                );
            } else {
                fields[i].target = (fields[i].dec > 0) ? COL_DOUBLE : COL_INTEGER;
            }
        } else {
            fields[i].target = COL_CHARACTER;
        }

        running_offset += fields[i].len;
    }

    if (verbose) {
        Rprintf("DBF rows: %u\n", n_records);
        Rprintf("DBF fields: %d\n", n_fields);
        Rprintf("Selected fields: %d\n", kept);
    }

    cetype_t encoding_ce = get_encoding_ce(encoding);

    SEXP out = PROTECT(allocVector(VECSXP, kept));
    SEXP out_names = PROTECT(allocVector(STRSXP, kept));

    for (int i = 0; i < n_fields; i++) {
        if (!fields[i].keep) {
            continue;
        }

        SEXP col = R_NilValue;

        if (fields[i].target == COL_INTEGER) {
            col = PROTECT(allocVector(INTSXP, n_records));
            for (uint32_t r = 0; r < n_records; r++) {
                INTEGER(col)[r] = NA_INTEGER;
            }
        } else if (fields[i].target == COL_DOUBLE) {
            col = PROTECT(allocVector(REALSXP, n_records));
            for (uint32_t r = 0; r < n_records; r++) {
                REAL(col)[r] = NA_REAL;
            }
        } else if (fields[i].target == COL_LOGICAL) {
            col = PROTECT(allocVector(LGLSXP, n_records));
            for (uint32_t r = 0; r < n_records; r++) {
                LOGICAL(col)[r] = NA_LOGICAL;
            }
        } else if (fields[i].target == COL_DATE) {
            col = PROTECT(allocVector(INTSXP, n_records));
            for (uint32_t r = 0; r < n_records; r++) {
                INTEGER(col)[r] = NA_INTEGER;
            }
            SEXP cls = PROTECT(mkString("Date"));
            classgets(col, cls);
            UNPROTECT(1);
        } else {
            col = PROTECT(allocVector(STRSXP, n_records));
            for (uint32_t r = 0; r < n_records; r++) {
                SET_STRING_ELT(col, r, NA_STRING);
            }
        }

        SET_VECTOR_ELT(out, fields[i].out_index, col);
        SET_STRING_ELT(out_names, fields[i].out_index, mkChar(fields[i].name));
        UNPROTECT(1);
    }

    for (uint32_t r = 0; r < n_records; r++) {
        const unsigned char *rec = records_buf + ((size_t) r * (size_t) record_len);

        if (((size_t) (r + 1) * (size_t) record_len) > records_len) {
            break;
        }

        if (rec[0] == '*') {
            continue;
        }

        int pos = 1;

        for (int i = 0; i < n_fields; i++) {
            const unsigned char *field_ptr = rec + pos;
            int flen = fields[i].len;
            pos += flen;

            if (!fields[i].keep) {
                continue;
            }

            SEXP col = VECTOR_ELT(out, fields[i].out_index);

            if (fields[i].target == COL_INTEGER) {
                char tmp[256];
                int use_len = flen < 255 ? flen : 255;
                copy_trimmed(tmp, field_ptr, use_len, trim_ws);

                if (tmp[0] != '\0') {
                    char *endptr = NULL;
                    long val = strtol(tmp, &endptr, 10);
                    if (endptr != tmp && *endptr == '\0' && val <= INT_MAX && val >= INT_MIN) {
                        INTEGER(col)[r] = (int) val;
                    }
                }
            } else if (fields[i].target == COL_DOUBLE) {
                char tmp[256];
                int use_len = flen < 255 ? flen : 255;
                copy_trimmed(tmp, field_ptr, use_len, trim_ws);

                if (tmp[0] != '\0') {
                    char *endptr = NULL;
                    double val = strtod(tmp, &endptr);
                    if (endptr != tmp && *endptr == '\0') {
                        REAL(col)[r] = val;
                    }
                }
            } else if (fields[i].target == COL_LOGICAL) {
                unsigned char ch = field_ptr[0];
                if (ch == 'Y' || ch == 'y' || ch == 'T' || ch == 't') {
                    LOGICAL(col)[r] = 1;
                } else if (ch == 'N' || ch == 'n' || ch == 'F' || ch == 'f') {
                    LOGICAL(col)[r] = 0;
                }
            } else if (fields[i].target == COL_DATE) {
                if (fields[i].type == 'D') {
                    int start, end;
                    trim_bounds(field_ptr, flen, 0, &start, &end);
                    if ((end - start) >= 8) {
                        INTEGER(col)[r] = parse_dbf_date_days_raw(field_ptr + start, end - start);
                    }
                } else {
                    char tmp[256];
                    int use_len = flen < 255 ? flen : 255;
                    copy_trimmed(tmp, field_ptr, use_len, trim_ws);
                    INTEGER(col)[r] = parse_yyyymmdd_char_days(tmp);
                }
            } else {
                char *tmp = (char *) R_alloc((size_t) flen + 1, sizeof(char));
                copy_trimmed(tmp, field_ptr, flen, trim_ws);
                SET_STRING_ELT(col, r, mkCharCE(tmp, encoding_ce));
            }
        }
    }

    setAttrib(out, R_NamesSymbol, out_names);
    classgets(out, mkString("data.frame"));

    SEXP row_names = PROTECT(allocVector(INTSXP, 2));
    INTEGER(row_names)[0] = NA_INTEGER;
    INTEGER(row_names)[1] = -(int) n_records;
    setAttrib(out, R_RowNamesSymbol, row_names);

    free_fields(fields, n_fields);

    UNPROTECT(3);
    return out;
}

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
) {
    if (len < 32) {
        error("Invalid DBF buffer: too small.");
    }

    uint16_t header_len = le_u16(buf + 8);
    if ((size_t) header_len >= len) {
        error("Invalid DBF header.");
    }

    return parse_dbf_parts(
        buf,
        (size_t) header_len,
        buf + header_len,
        len - (size_t) header_len,
        select,
        n_max,
        trim_ws,
        encoding,
        guess_types,
        col_types_values,
        col_types_names,
        parse_dates,
        verbose
    );
}

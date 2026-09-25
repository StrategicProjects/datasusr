#include "dbf_parser.h"

#include <R.h>
#include <Rinternals.h>
#include <R_ext/Print.h>

#include <ctype.h>
#include <errno.h>
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
    char name[12];
    char upper_name[12];
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

/* `select` is uppercased on the R side; compare it against the uppercased
   DBF field name so matching is case-insensitive on both sides. */
static int match_select(SEXP select, const char *upper_name) {
    if (TYPEOF(select) != STRSXP || XLENGTH(select) == 0) {
        return 1;
    }

    for (R_xlen_t i = 0; i < XLENGTH(select); i++) {
        if (strcmp(CHAR(STRING_ELT(select, i)), upper_name) == 0) {
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

/* Parse a decimal integer that is representable as a non-NA R integer.
   Returns 1 and stores the value on success, 0 otherwise.  INT_MIN is
   rejected because it is R's NA_integer_. */
static int parse_r_int(const char *x, int *out) {
    char *endptr = NULL;
    errno = 0;
    long val = strtol(x, &endptr, 10);
    if (endptr == x || *endptr != '\0' || errno == ERANGE) {
        return 0;
    }
    if (val <= (long) INT_MIN || val > (long) INT_MAX) {
        return 0;
    }
    *out = (int) val;
    return 1;
}

static int days_in_month(int year, int month) {
    static const int mdays[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    if (month == 2) {
        int leap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        return leap ? 29 : 28;
    }
    return mdays[month - 1];
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

    if (month < 1 || month > 12 || day < 1 || day > days_in_month(year, month)) {
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

/* The R wrapper validates `encoding` and passes one of "latin1", "UTF-8"
   or "unknown". */
static cetype_t get_encoding_ce(const char *encoding) {
    if (encoding == NULL) {
        return CE_LATIN1;
    }

    if (strcmp(encoding, "UTF-8") == 0 || strcmp(encoding, "utf-8") == 0 ||
        strcmp(encoding, "utf8") == 0 || strcmp(encoding, "UTF8") == 0) {
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

/* `col_types_names` is uppercased on the R side. */
static col_target_t get_declared_col_target(
    SEXP col_types_values,
    SEXP col_types_names,
    const char *upper_name
) {
    if (TYPEOF(col_types_values) != STRSXP ||
        TYPEOF(col_types_names) != STRSXP ||
        XLENGTH(col_types_values) == 0 ||
        XLENGTH(col_types_values) != XLENGTH(col_types_names)) {
        return COL_AUTO;
    }

    for (R_xlen_t i = 0; i < XLENGTH(col_types_names); i++) {
        if (strcmp(CHAR(STRING_ELT(col_types_names, i)), upper_name) == 0) {
            return parse_col_target(CHAR(STRING_ELT(col_types_values, i)));
        }
    }

    return COL_AUTO;
}

/* Scans the first `n_scan` records (deleted ones skipped).  Numeric text is
   always whitespace-trimmed, independently of `trim_ws`. */
static col_target_t infer_numeric_target(
    const field_info_t *field,
    const unsigned char *records_buf,
    uint32_t n_scan,
    uint16_t record_len,
    int field_offset
) {
    if (field->dec > 0) {
        return COL_DOUBLE;
    }

    if (!records_buf || record_len == 0) {
        return COL_INTEGER;
    }

    for (uint32_t r = 0; r < n_scan; r++) {
        const unsigned char *rec = records_buf + ((size_t) r * (size_t) record_len);

        if (rec[0] == '*') {
            continue;
        }

        char tmp[256];
        copy_trimmed(tmp, rec + field_offset, field->len, 1);

        if (tmp[0] == '\0') {
            continue;
        }

        if (has_decimal_or_exp(tmp)) {
            return COL_DOUBLE;
        }

        int ival;
        if (!parse_r_int(tmp, &ival)) {
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

    /* Validate field lengths against the record length before any
       allocation or data access. */
    {
        long sum_len = 1;
        for (int i = 0; i < n_fields; i++) {
            unsigned char flen = header_buf[32 + (i * 32) + 16];
            if (flen == 0) {
                error("Invalid DBF header: field %d has length 0.", i + 1);
            }
            sum_len += flen;
        }
        if (sum_len > (long) record_len) {
            error(
                "Invalid DBF header: field lengths (1 + %ld bytes) exceed the declared record length (%u bytes).",
                sum_len - 1, (unsigned) record_len
            );
        }
    }

    uint32_t available_records = (uint32_t) (records_len / (size_t) record_len);
    if (available_records < n_records) {
        warning(
            "DBF declares %u records but only %u are present; reading %u.",
            (unsigned) n_records, (unsigned) available_records, (unsigned) available_records
        );
        n_records = available_records;
    }

    /* Deleted records ('*' flag) are skipped; n_max counts live records.
       n_scan is the number of raw records to scan, n_out the number of
       live records that will be returned. */
    uint32_t n_scan = 0;
    uint32_t n_out = 0;
    for (uint32_t r = 0; r < n_records; r++) {
        if ((double) n_out >= n_max) {
            break;
        }
        n_scan = r + 1;
        if (records_buf[(size_t) r * (size_t) record_len] != '*') {
            n_out++;
        }
    }

    field_info_t *fields = (field_info_t *) R_alloc((size_t) n_fields, sizeof(field_info_t));

    int kept = 0;

    for (int i = 0; i < n_fields; i++) {
        const unsigned char *fd = header_buf + 32 + (i * 32);

        size_t k = 0;
        while (k < 11 && fd[k] != '\0') {
            k++;
        }

        memcpy(fields[i].name, fd, k);
        fields[i].name[k] = '\0';
        for (size_t j = 0; j <= k; j++) {
            fields[i].upper_name[j] = (char) toupper((unsigned char) fields[i].name[j]);
        }
        fields[i].type = (char) fd[11];
        fields[i].len = fd[16];
        fields[i].dec = fd[17];
        fields[i].keep = match_select(select, fields[i].upper_name);
        fields[i].out_index = -1;
        fields[i].target = COL_AUTO;

        if (fields[i].keep) {
            fields[i].out_index = kept;
            kept++;
        }
    }

    int running_offset = 1;
    for (int i = 0; i < n_fields; i++) {
        if (!fields[i].keep) {
            running_offset += fields[i].len;
            continue;
        }

        col_target_t declared = get_declared_col_target(
            col_types_values,
            col_types_names,
            fields[i].upper_name
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
                    n_scan,
                    record_len,
                    running_offset
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
        Rprintf("DBF rows: %u\n", (unsigned) n_out);
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
            col = PROTECT(allocVector(INTSXP, n_out));
            for (uint32_t r = 0; r < n_out; r++) {
                INTEGER(col)[r] = NA_INTEGER;
            }
        } else if (fields[i].target == COL_DOUBLE) {
            col = PROTECT(allocVector(REALSXP, n_out));
            for (uint32_t r = 0; r < n_out; r++) {
                REAL(col)[r] = NA_REAL;
            }
        } else if (fields[i].target == COL_LOGICAL) {
            col = PROTECT(allocVector(LGLSXP, n_out));
            for (uint32_t r = 0; r < n_out; r++) {
                LOGICAL(col)[r] = NA_LOGICAL;
            }
        } else if (fields[i].target == COL_DATE) {
            col = PROTECT(allocVector(INTSXP, n_out));
            for (uint32_t r = 0; r < n_out; r++) {
                INTEGER(col)[r] = NA_INTEGER;
            }
            SEXP cls = PROTECT(mkString("Date"));
            classgets(col, cls);
            UNPROTECT(1);
        } else {
            col = PROTECT(allocVector(STRSXP, n_out));
            for (uint32_t r = 0; r < n_out; r++) {
                SET_STRING_ELT(col, r, NA_STRING);
            }
        }

        SET_VECTOR_ELT(out, fields[i].out_index, col);
        SET_STRING_ELT(out_names, fields[i].out_index, mkChar(fields[i].name));
        UNPROTECT(1);
    }

    uint32_t o = 0;
    for (uint32_t r = 0; r < n_scan && o < n_out; r++) {
        const unsigned char *rec = records_buf + ((size_t) r * (size_t) record_len);

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
            /* flen is at most 255 (unsigned char), so tmp always fits. */
            char tmp[256];

            if (fields[i].target == COL_INTEGER) {
                copy_trimmed(tmp, field_ptr, flen, 1);

                int ival;
                if (tmp[0] != '\0' && parse_r_int(tmp, &ival)) {
                    INTEGER(col)[o] = ival;
                }
            } else if (fields[i].target == COL_DOUBLE) {
                copy_trimmed(tmp, field_ptr, flen, 1);

                if (tmp[0] != '\0') {
                    char *endptr = NULL;
                    double val = strtod(tmp, &endptr);
                    if (endptr != tmp && *endptr == '\0') {
                        REAL(col)[o] = val;
                    }
                }
            } else if (fields[i].target == COL_LOGICAL) {
                int start, end;
                trim_bounds(field_ptr, flen, 1, &start, &end);
                if (end > start) {
                    unsigned char ch = field_ptr[start];
                    if (ch == 'Y' || ch == 'y' || ch == 'T' || ch == 't') {
                        LOGICAL(col)[o] = 1;
                    } else if (ch == 'N' || ch == 'n' || ch == 'F' || ch == 'f') {
                        LOGICAL(col)[o] = 0;
                    }
                }
            } else if (fields[i].target == COL_DATE) {
                if (fields[i].type == 'D') {
                    int start, end;
                    trim_bounds(field_ptr, flen, 1, &start, &end);
                    if ((end - start) >= 8) {
                        INTEGER(col)[o] = parse_dbf_date_days_raw(field_ptr + start, end - start);
                    }
                } else {
                    copy_trimmed(tmp, field_ptr, flen, 1);
                    INTEGER(col)[o] = parse_yyyymmdd_char_days(tmp);
                }
            } else {
                copy_trimmed(tmp, field_ptr, flen, trim_ws);
                SET_STRING_ELT(col, o, mkCharCE(tmp, encoding_ce));
            }
        }

        o++;
    }

    setAttrib(out, R_NamesSymbol, out_names);
    SEXP df_cls = PROTECT(mkString("data.frame"));
    classgets(out, df_cls);

    SEXP row_names = PROTECT(allocVector(INTSXP, 2));
    INTEGER(row_names)[0] = NA_INTEGER;
    INTEGER(row_names)[1] = -(int) n_out;
    setAttrib(out, R_RowNamesSymbol, row_names);

    UNPROTECT(4);
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

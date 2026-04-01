#include <R.h>
#include <Rinternals.h>
#include <R_ext/Print.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "blast.h"
#include "dbf_parser.h"

#define CRC_OFFSET 4

typedef struct {
    const unsigned char *data;
    size_t len;
    size_t pos;
} blast_input_t;

typedef struct {
    unsigned char *data;
    size_t size;
    size_t capacity;
} blast_output_t;

static uint16_t le_u16(const unsigned char *p) {
    return (uint16_t) (p[0] | (p[1] << 8));
}

static uint32_t le_u32(const unsigned char *p) {
    return (uint32_t) (p[0] |
                     ((uint32_t) p[1] << 8) |
                     ((uint32_t) p[2] << 16) |
                     ((uint32_t) p[3] << 24));
}

static unsigned blast_in_callback(void *how, unsigned char **buf) {
    blast_input_t *in = (blast_input_t *) how;

    if (in->pos >= in->len) {
        *buf = NULL;
        return 0;
    }

    size_t remaining = in->len - in->pos;
    size_t chunk = remaining > 65536 ? 65536 : remaining;

    *buf = (unsigned char *) (in->data + in->pos);
    in->pos += chunk;

    return (unsigned) chunk;
}

static int blast_out_callback(void *how, unsigned char *buf, unsigned len) {
    blast_output_t *out = (blast_output_t *) how;

    if (len == 0) {
        return 0;
    }

    size_t needed = out->size + (size_t) len;

    if (needed > out->capacity) {
        size_t new_capacity = out->capacity ? out->capacity : 65536;

        while (new_capacity < needed) {
            new_capacity *= 2;
        }

        unsigned char *tmp = (unsigned char *) realloc(out->data, new_capacity);
        if (tmp == NULL) {
            return 1;
        }

        out->data = tmp;
        out->capacity = new_capacity;
    }

    memcpy(out->data + out->size, buf, len);
    out->size += len;

    return 0;
}

static void free_output(blast_output_t *out) {
    if (out->data != NULL) {
        free(out->data);
        out->data = NULL;
    }

    out->size = 0;
    out->capacity = 0;
}

static unsigned char *read_file_bin(const char *path, size_t *out_size) {
    FILE *f = fopen(path, "rb");
    if (f == NULL) {
        return NULL;
    }

    if (fseek(f, 0, SEEK_END) != 0) {
        fclose(f);
        return NULL;
    }

    long sz = ftell(f);
    if (sz < 0) {
        fclose(f);
        return NULL;
    }

    rewind(f);

    unsigned char *buf = (unsigned char *) malloc((size_t) sz);
    if (buf == NULL) {
        fclose(f);
        return NULL;
    }

    size_t nread = fread(buf, 1, (size_t) sz, f);
    fclose(f);

    if (nread != (size_t) sz) {
        free(buf);
        return NULL;
    }

    *out_size = (size_t) sz;
    return buf;
}

static int looks_like_dbf_header(const unsigned char *buf, size_t len) {
    if (buf == NULL || len < 32) {
        return 0;
    }

    unsigned char version = buf[0];

    int version_ok =
        version == 0x02 || version == 0x03 || version == 0x04 ||
        version == 0x05 || version == 0x30 || version == 0x31 ||
        version == 0x32 || version == 0x43 || version == 0x63 ||
        version == 0x7B || version == 0x83 || version == 0x8B ||
        version == 0x8E || version == 0xCB || version == 0xF5;

    if (!version_ok) {
        return 0;
    }

    unsigned int header_len = le_u16(buf + 8);
    unsigned int record_len = le_u16(buf + 10);

    if (header_len < 33 || record_len < 1) {
        return 0;
    }

    if ((size_t) header_len >= len) {
        return 0;
    }

    if (buf[header_len - 1] != 0x0D && buf[header_len - 1] != 0x00) {
        return 0;
    }

    return 1;
}

static int looks_like_complete_dbf(const unsigned char *buf, size_t len) {
    if (!looks_like_dbf_header(buf, len)) {
        return 0;
    }

    uint32_t n_records = le_u32(buf + 4);
    uint16_t header_len = le_u16(buf + 8);
    uint16_t record_len = le_u16(buf + 10);

    size_t expected_min = (size_t) header_len + ((size_t) n_records * (size_t) record_len);

    return len >= expected_min;
}

static int blast_from_memory(
    const unsigned char *src,
    size_t src_len,
    blast_output_t *out
) {
    blast_input_t in;
    in.data = src;
    in.len = src_len;
    in.pos = 0;

    out->data = NULL;
    out->size = 0;
    out->capacity = 0;

    return blast(blast_in_callback, &in, blast_out_callback, out, NULL, NULL);
}

SEXP c_read_datasus_dbc(
    SEXP file_sexp,
    SEXP select_sexp,
    SEXP nmax_sexp,
    SEXP trim_sexp,
    SEXP encoding_sexp,
    SEXP guess_types_sexp,
    SEXP col_types_values_sexp,
    SEXP col_types_names_sexp,
    SEXP parse_dates_sexp,
    SEXP verbose_sexp
) {
    const char *path = CHAR(STRING_ELT(file_sexp, 0));
    const char *encoding = CHAR(STRING_ELT(encoding_sexp, 0));
    double n_max = REAL(nmax_sexp)[0];
    int trim_ws = LOGICAL(trim_sexp)[0];
    int guess_types = LOGICAL(guess_types_sexp)[0];
    int parse_dates = LOGICAL(parse_dates_sexp)[0];
    int verbose = LOGICAL(verbose_sexp)[0];

    size_t file_len = 0;
    unsigned char *file_buf = read_file_bin(path, &file_len);

    if (file_buf == NULL) {
        error("Failed to read DBC file: %s", path);
    }

    if (looks_like_complete_dbf(file_buf, file_len)) {
        uint16_t header_len = le_u16(file_buf + 8);

        if (verbose) {
            Rprintf("Input already looks like a complete DBF file; skipping blast()\n");
            Rprintf("DBF size: %zu bytes\n", file_len);
        }

        SEXP ans = PROTECT(parse_dbf_parts(
            file_buf,
            (size_t) header_len,
            file_buf + header_len,
            file_len - (size_t) header_len,
            select_sexp,
            n_max,
            trim_ws,
            encoding,
            guess_types,
            col_types_values_sexp,
            col_types_names_sexp,
            parse_dates,
            verbose
        ));

        free(file_buf);
        UNPROTECT(1);
        return ans;
    }

    if (looks_like_dbf_header(file_buf, file_len)) {
        uint16_t header_len = le_u16(file_buf + 8);
        size_t comp_offset = (size_t) header_len + CRC_OFFSET;

        if (comp_offset >= file_len) {
            free(file_buf);
            error("Invalid DBC structure: compressed payload offset is beyond end of file.");
        }

        if (verbose) {
            Rprintf("Detected DBF header in input; trying to decompress record area\n");
            Rprintf("Header length: %u bytes\n", (unsigned) header_len);
        }

        const unsigned char *comp_body = file_buf + comp_offset;
        size_t comp_body_len = file_len - comp_offset;

        blast_output_t body_out;
        int rc = blast_from_memory(comp_body, comp_body_len, &body_out);

        /* Fallback: some DBC files have no CRC bytes between header and
           compressed payload.  If blast fails with the default 4-byte skip,
           retry starting right after the header. */
        if (rc != 0 && CRC_OFFSET > 0) {
            free_output(&body_out);

            comp_offset = (size_t) header_len;
            comp_body = file_buf + comp_offset;
            comp_body_len = file_len - comp_offset;

            if (verbose) {
                Rprintf("Retrying decompression without CRC skip (offset=%zu)\n", comp_offset);
            }

            rc = blast_from_memory(comp_body, comp_body_len, &body_out);
        }

        if (rc != 0) {
            free(file_buf);
            free_output(&body_out);
            error("Failed to decompress DBC record area with blast(); code=%d", rc);
        }

        if (verbose) {
            Rprintf("DBC decompressed successfully from record area\n");
            Rprintf("Compressed payload offset: %zu\n", comp_offset);
            Rprintf("Decompressed record bytes: %zu\n", body_out.size);
        }

        SEXP ans = PROTECT(parse_dbf_parts(
            file_buf,
            (size_t) header_len,
            body_out.data,
            body_out.size,
            select_sexp,
            n_max,
            trim_ws,
            encoding,
            guess_types,
            col_types_values_sexp,
            col_types_names_sexp,
            parse_dates,
            verbose
        ));

        free_output(&body_out);
        free(file_buf);
        UNPROTECT(1);
        return ans;
    }

    {
        blast_output_t out;
        int rc = blast_from_memory(file_buf, file_len, &out);
        free(file_buf);

        if (rc != 0) {
            free_output(&out);
            error("Failed to decompress DBC with blast(); code=%d", rc);
        }

        if (!looks_like_complete_dbf(out.data, out.size)) {
            free_output(&out);
            error("Decompression succeeded, but output does not look like a valid DBF file.");
        }

        if (verbose) {
            Rprintf("Whole-file DBC decompressed successfully\n");
            Rprintf("Decompressed DBF size: %zu bytes\n", out.size);
        }

        SEXP ans = PROTECT(parse_dbf_buffer(
            out.data,
            out.size,
            select_sexp,
            n_max,
            trim_ws,
            encoding,
            guess_types,
            col_types_values_sexp,
            col_types_names_sexp,
            parse_dates,
            verbose
        ));

        free_output(&out);
        UNPROTECT(1);
        return ans;
    }
}

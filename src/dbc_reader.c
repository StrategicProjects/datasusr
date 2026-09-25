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

    free_output(out);

    return blast(blast_in_callback, &in, blast_out_callback, out, NULL, NULL);
}

/* A truncated plain DBF (fewer bytes than the header declares) is not a
   DBC.  Its record area starts directly after the header and every record
   begins with a deletion flag (' ' live, '*' deleted), optionally followed
   by the 0x1A end-of-file marker. */
static int looks_like_plain_dbf_records(
    const unsigned char *buf,
    size_t len,
    size_t header_len,
    size_t record_len
) {
    if (header_len > len || record_len == 0) {
        return 0;
    }

    for (size_t off = header_len; off < len; off += record_len) {
        if (off == len - 1 && buf[off] == 0x1A) {
            break; /* dBase end-of-file marker */
        }
        if (buf[off] != ' ' && buf[off] != '*') {
            return 0;
        }
    }

    return 1;
}

typedef struct {
    unsigned char *file_buf;
    size_t file_len;
    blast_output_t out;
    SEXP select;
    double n_max;
    int trim_ws;
    const char *encoding;
    int guess_types;
    SEXP col_types_values;
    SEXP col_types_names;
    int parse_dates;
    int verbose;
} read_ctx_t;

/* Frees the malloc'd buffers.  Runs both on normal return and when an R
   error (or interrupt/warning-as-error) unwinds through R_UnwindProtect. */
static void read_ctx_cleanup(void *data, Rboolean jump) {
    read_ctx_t *ctx = (read_ctx_t *) data;
    (void) jump;

    if (ctx->file_buf != NULL) {
        free(ctx->file_buf);
        ctx->file_buf = NULL;
    }

    free_output(&ctx->out);
}

static SEXP ctx_parse_parts(
    read_ctx_t *ctx,
    const unsigned char *header_buf,
    size_t header_len,
    const unsigned char *records_buf,
    size_t records_len
) {
    return parse_dbf_parts(
        header_buf,
        header_len,
        records_buf,
        records_len,
        ctx->select,
        ctx->n_max,
        ctx->trim_ws,
        ctx->encoding,
        ctx->guess_types,
        ctx->col_types_values,
        ctx->col_types_names,
        ctx->parse_dates,
        ctx->verbose
    );
}

static SEXP read_dbc_body(void *data) {
    read_ctx_t *ctx = (read_ctx_t *) data;
    unsigned char *file_buf = ctx->file_buf;
    size_t file_len = ctx->file_len;
    int verbose = ctx->verbose;

    /* A plain DBF must not only be long enough for the declared records:
       every record must also start with a deletion flag.  A small DBC whose
       compressed payload is larger than the uncompressed record area passes
       the size test alone, so both are required before skipping blast(). */
    if (looks_like_complete_dbf(file_buf, file_len) &&
        looks_like_plain_dbf_records(file_buf, file_len,
                                     le_u16(file_buf + 8), le_u16(file_buf + 10))) {
        uint16_t header_len = le_u16(file_buf + 8);

        if (verbose) {
            Rprintf("Input already looks like a complete DBF file; skipping blast()\n");
            Rprintf("DBF size: %zu bytes\n", file_len);
        }

        return ctx_parse_parts(
            ctx,
            file_buf,
            (size_t) header_len,
            file_buf + header_len,
            file_len - (size_t) header_len
        );
    }

    if (looks_like_dbf_header(file_buf, file_len)) {
        uint16_t header_len = le_u16(file_buf + 8);
        uint16_t record_len = le_u16(file_buf + 10);
        size_t comp_offset = (size_t) header_len + CRC_OFFSET;
        int rc = -1;

        if (verbose) {
            Rprintf("Detected DBF header in input; trying to decompress record area\n");
            Rprintf("Header length: %u bytes\n", (unsigned) header_len);
        }

        if (comp_offset < file_len) {
            rc = blast_from_memory(file_buf + comp_offset, file_len - comp_offset, &ctx->out);
        }

        /* Fallback: some DBC files have no CRC bytes between header and
           compressed payload.  If blast fails with the default 4-byte skip,
           retry starting right after the header. */
        if (rc != 0 && CRC_OFFSET > 0) {
            comp_offset = (size_t) header_len;

            if (verbose) {
                Rprintf("Retrying decompression without CRC skip (offset=%zu)\n", comp_offset);
            }

            rc = blast_from_memory(file_buf + comp_offset, file_len - comp_offset, &ctx->out);
        }

        if (rc != 0) {
            free_output(&ctx->out);

            /* Not a DBC: a truncated plain DBF.  Parse what is there;
               parse_dbf_parts() warns about the missing records. */
            if (looks_like_plain_dbf_records(file_buf, file_len, header_len, record_len)) {
                if (verbose) {
                    Rprintf("Input looks like a truncated plain DBF file; reading available records\n");
                }

                return ctx_parse_parts(
                    ctx,
                    file_buf,
                    (size_t) header_len,
                    file_buf + header_len,
                    file_len - (size_t) header_len
                );
            }

            error("Failed to decompress DBC record area with blast(); code=%d", rc);
        }

        if (verbose) {
            Rprintf("DBC decompressed successfully from record area\n");
            Rprintf("Compressed payload offset: %zu\n", comp_offset);
            Rprintf("Decompressed record bytes: %zu\n", ctx->out.size);
        }

        return ctx_parse_parts(
            ctx,
            file_buf,
            (size_t) header_len,
            ctx->out.data,
            ctx->out.size
        );
    }

    {
        int rc = blast_from_memory(file_buf, file_len, &ctx->out);

        if (rc != 0) {
            error("Failed to decompress DBC with blast(); code=%d", rc);
        }

        if (!looks_like_complete_dbf(ctx->out.data, ctx->out.size)) {
            error("Decompression succeeded, but output does not look like a valid DBF file.");
        }

        if (verbose) {
            Rprintf("Whole-file DBC decompressed successfully\n");
            Rprintf("Decompressed DBF size: %zu bytes\n", ctx->out.size);
        }

        return parse_dbf_buffer(
            ctx->out.data,
            ctx->out.size,
            ctx->select,
            ctx->n_max,
            ctx->trim_ws,
            ctx->encoding,
            ctx->guess_types,
            ctx->col_types_values,
            ctx->col_types_names,
            ctx->parse_dates,
            ctx->verbose
        );
    }
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
    read_ctx_t ctx;
    const char *path = CHAR(STRING_ELT(file_sexp, 0));

    ctx.file_buf = NULL;
    ctx.file_len = 0;
    ctx.out.data = NULL;
    ctx.out.size = 0;
    ctx.out.capacity = 0;
    ctx.select = select_sexp;
    ctx.n_max = REAL(nmax_sexp)[0];
    ctx.trim_ws = LOGICAL(trim_sexp)[0];
    ctx.encoding = CHAR(STRING_ELT(encoding_sexp, 0));
    ctx.guess_types = LOGICAL(guess_types_sexp)[0];
    ctx.col_types_values = col_types_values_sexp;
    ctx.col_types_names = col_types_names_sexp;
    ctx.parse_dates = LOGICAL(parse_dates_sexp)[0];
    ctx.verbose = LOGICAL(verbose_sexp)[0];

    /* Allocate the continuation token before any malloc so that an
       allocation failure here cannot leak. */
    SEXP token = PROTECT(R_MakeUnwindCont());

    ctx.file_buf = read_file_bin(path, &ctx.file_len);
    if (ctx.file_buf == NULL) {
        error("Failed to read DBC file: %s", path);
    }

    SEXP ans = R_UnwindProtect(read_dbc_body, &ctx, read_ctx_cleanup, &ctx, token);

    UNPROTECT(1);
    return ans;
}

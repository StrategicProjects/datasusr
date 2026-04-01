#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

extern SEXP c_read_datasus_dbc(
    SEXP, SEXP, SEXP, SEXP, SEXP,
    SEXP, SEXP, SEXP, SEXP, SEXP
);

static const R_CallMethodDef call_entries[] = {
    {"_datasusr_c_read_datasus_dbc", (DL_FUNC) &c_read_datasus_dbc, 10},
    {NULL, NULL, 0}
};

void R_init_datasusr(DllInfo *dll) {
    R_registerRoutines(dll, NULL, call_entries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}

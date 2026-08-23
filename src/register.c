
#include <R_ext/Visibility.h>
#include <R_ext/Rdynload.h>
#include "harfbuzz.h"

static const R_CallMethodDef callMethods[] = {
    {"verticalGlyphIndex", (DL_FUNC) &verticalGlyphIndex, 1},
    { NULL, NULL, 0 }
};

void R_init_upxdvir(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, callMethods, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
    R_forceSymbols(dll, TRUE);
}

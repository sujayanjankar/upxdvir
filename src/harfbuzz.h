
#include <R.h>
#include <Rinternals.h>
#include <hb.h>
#include <hb-ft.h>
#include <ft2build.h>
#include FT_FREETYPE_H

SEXP hbGlyphIndex(SEXP code, SEXP font);

SEXP hbGlyphMetrics(SEXP font);

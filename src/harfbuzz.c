#include "harfbuzz.h"

SEXP verticalGlyphIndex(SEXP code, SEXP font)
{
    FT_Library ft_library;
    FT_Face face;
    int index, err;
    SEXP result = R_NilValue;

    PROTECT(result = allocVector(INTSXP, 1));

    err = FT_Init_FreeType(&ft_library);
    if (err) {
        error("FreeType initialisation failed");
    }

    err = FT_New_Face(ft_library,
                      CHAR(STRING_ELT(font, 0)),
                      0,
                      &face);
    if (err == FT_Err_Unknown_File_Format) {
        error("Font read failed: Unknown font format");
    } else if (err) {
        error("Font read failed");
    }

    hb_font_t *hb_font = hb_ft_font_create_referenced(face);

    hb_buffer_t *buf = hb_buffer_create();
    uint32_t cp = (uint32_t) INTEGER(code)[0];
    hb_buffer_add_utf32(buf, &cp, 1, 0, 1);
    hb_buffer_set_direction(buf, HB_DIRECTION_TTB);
    hb_buffer_guess_segment_properties(buf);

    hb_shape(hb_font, buf, NULL, 0);

    unsigned int count;
    hb_glyph_info_t *info = hb_buffer_get_glyph_infos(buf, &count);

    index = info[0].codepoint;
    if (!index) {
        error("Undefined character code");
    }
    INTEGER(result)[0] = index;
    hb_buffer_destroy(buf);
    hb_font_destroy(hb_font);
    err = FT_Done_Face(face);
    if (err) {
        error("Face clean up failed");
    }
    err = FT_Done_FreeType(ft_library);
    if (err) {
        error("FreeType shut down failed");
    }

    UNPROTECT(1);


    return result;
}

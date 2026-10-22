#include "harfbuzz.h"

SEXP hbGlyphIndex(SEXP code, SEXP font, SEXP direction) {
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
    if (INTEGER(direction)[0] == 1) {
        hb_buffer_set_direction(buf, HB_DIRECTION_TTB);
    }
    hb_buffer_guess_segment_properties(buf);
    hb_shape(hb_font, buf, NULL, 0);

    unsigned int count;
    hb_glyph_info_t *info = hb_buffer_get_glyph_infos(buf, &count);

    index = info[0].codepoint;

    /* Look-up raw charmaps for lmsy font. */
    if (!index) {
        for (int c = 0; c < face->num_charmaps && !index; c++) {
            FT_Set_Charmap(face, face->charmaps[c]);
            index = FT_Get_Char_Index(face, cp);
        }
    }

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

SEXP hbGlyphMetrics(SEXP font) {
    FT_Library  ft_library;
    FT_Face     face;
    hb_font_t  *hb_font;
    long        numGlyphs;
    int         i, glyphErr, err;

    SEXP unitsPerEm, glyphInfo, metrics, result;
    PROTECT(result = allocVector(VECSXP, 2));

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
        error("Font read failed (%s)", CHAR(STRING_ELT(font, 0)));
    }

    err = FT_Set_Char_Size(face, 0, 12*64, 96, 0);
    if (err) {
        error("Set char size failed");
    }

    hb_font = hb_ft_font_create_referenced(face);
    if (!hb_font) {
        error("HarfBuzz font creation failed");
    }

    hb_font_set_scale(hb_font,
                      face->units_per_EM,
                      face->units_per_EM);

    PROTECT(unitsPerEm = allocVector(INTSXP, 1));
    INTEGER(unitsPerEm)[0] = face->units_per_EM;
    SET_VECTOR_ELT(result, 0, unitsPerEm);
    UNPROTECT(1);

    numGlyphs = (long)face->num_glyphs;

    PROTECT(metrics = allocVector(VECSXP, numGlyphs));
    glyphErr = 0;

    for (i = 0; i < numGlyphs; i++) {
        hb_codepoint_t glyph = (hb_codepoint_t)i;
        hb_glyph_extents_t extents;
        hb_position_t origX;
        hb_position_t origY;
        int resultSize = 8;
        PROTECT(glyphInfo = allocVector(INTSXP, resultSize));
        hb_font_get_glyph_v_origin(hb_font, glyph, &origX, &origY);
        if (!hb_font_get_glyph_extents(hb_font, glyph, &extents)) {
            glyphErr = 1;
            for (i = 0; i < resultSize; i++) {
                INTEGER(glyphInfo)[i] = NA_INTEGER;    
            }
        } else {
            INTEGER(glyphInfo)[0] = hb_font_get_glyph_h_advance(hb_font, glyph); // horizontal advance
            INTEGER(glyphInfo)[1] = extents.x_bearing; // left
            INTEGER(glyphInfo)[2] = extents.x_bearing + extents.width; // right
            INTEGER(glyphInfo)[3] = extents.y_bearing; // top
            INTEGER(glyphInfo)[4] = extents.y_bearing + extents.height; // bottom
            INTEGER(glyphInfo)[5] = hb_font_get_glyph_v_advance(hb_font, glyph); // vertical advance
            INTEGER(glyphInfo)[6] = origX;
            INTEGER(glyphInfo)[7] = origY;
        }
        SET_VECTOR_ELT(metrics, i, glyphInfo);
        UNPROTECT(1);
    }

    SET_VECTOR_ELT(result, 1, metrics);
    UNPROTECT(1);

    if (glyphErr) {
        warning("HB: Some glyph metrics could not be extracted.");
    }

    hb_font_destroy(hb_font);

    err = FT_Done_Face(face);
    if (err) {
        error("HB: Face clean up failed");
    }

    err = FT_Done_FreeType(ft_library);
    if (err) {
        error("HB: FreeType shut down failed");
    }

    UNPROTECT(1);
    return result;
}
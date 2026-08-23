HBverticalGlyphIndex <- function(code, fontName) {
    .Call(
        C_verticalGlyphIndex,
        as.integer(code),
        as.character(fontName)[1]
    )
}

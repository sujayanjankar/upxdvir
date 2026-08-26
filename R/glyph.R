up_glyph_index <- function(raw, fontname, fontLib) {
    value <- 0
    if (length(raw) == 1) {
        value <- as.integer(raw)
    } else if (length(raw) == 2) {
        value <- sum(as.integer(raw) * c(256, 1))
    }
    # message(raw, " mapped to ", value)
    fontLib$glyphIndex(value, fontname)
}

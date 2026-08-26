set("hb-fontlib-cache", list())

# Most of this is copied from xdvir::freetype.R.
# TODO: Consider a refactor.
addFont <- function(fontName) {
    font <- .Call(C_hbGlyphMetrics, as.character(fontName)[1])
    names(font) <- c("unitsPerEm", "metrics")
    font$metrics <- lapply(
        font$metrics,
        function(x) {
            names(x) <- c(
                "width",
                "left", "right", "top", "bottom",
                "height"
            )
            x
        }
    )
    cache <- get("hb-fontlib-cache")
    cache[[fontName]] <- font
    set("hb-fontlib-cache", cache)
    font
}

getFont <- function(fontName) {
    cache <- get("hb-fontlib-cache")
    font <- cache[[fontName]]
    if (is.null(font)) {
        addFont(fontName)
    } else {
        font
    }
}

hbGlyphMetrics <- function(index, subset, fontName) {
    font <- getFont(fontName)
    ## +1 because glyph indices are zero-based, but
    ## we are accessing a one-based R vector
    metrics <- font$metrics[[index + 1]][subset]
    attr(metrics, "unitsPerEm") <- font$unitsPerEm
    metrics
}

hbGlyphWidth <- function(index, fontName) {
    hbGlyphMetrics(index, "width", fontName)
}

hbGlyphHeight <- function(index, fontName) {
    # HB returns a negative vert advance when moving down.
    # Negate it for compatibility with the engine.
    -hbGlyphMetrics(index, "height", fontName)
}

hbGlyphBounds <- function(index, fontName) {
    hbGlyphMetrics(
        index,
        c("left", "bottom", "right", "top"),
        fontName
    )
}

hbGlyphIndex <- function(code, fontName) {
    .Call(
        C_hbGlyphIndex,
        as.integer(code),
        as.character(fontName)[1]
    )
}

hbFontLibrary <- xdvir::FontLibrary(
    glyphWidth = hbGlyphWidth,
    glyphHeight = hbGlyphHeight,
    glyphBounds = hbGlyphBounds,
    glyphIndex = hbGlyphIndex
)

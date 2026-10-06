set("hb-fontlib-cache", list())

# Most of this is copied from xdvir::freetype.R.
# TODO: Consider a refactor.
.addFont <- function(fontName) {
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

.getFont <- function(fontName) {
    cache <- get("hb-fontlib-cache")
    font <- cache[[fontName]]
    if (is.null(font)) {
        .addFont(fontName)
    } else {
        font
    }
}

hbGlyphMetrics <- function(index, subset, fontName) {
    font <- .getFont(fontName)
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

.hbGlyphIndex <- function(value, fontName, direction) {
    .Call(
        C_hbGlyphIndex,
        as.integer(value),
        as.character(fontName)[1],
        as.integer(direction)
    )
}

upGlyphIndex <- function(raw, fontName, fontLib, direction = 1) {
    value <- 0
    if (length(raw) == 1) {
        value <- as.integer(raw)
    } else if (length(raw) == 2) {
        value <- sum(as.integer(raw) * c(256, 1))
    }
    .hbGlyphIndex(value, fontName, direction)
}

resolveScriptType <- function(fontName) {
    # message("Resolve script type for: ", fontName)
    if (fontName %in% get(FONT_CACHE_CJK)) {
        xdvir::SCRIPT_TYPE_CJK
    } else if (fontName %in% get(FONT_CACHE_LATIN)) {
        xdvir::SCRIPT_TYPE_LATIN
    } else {
        # TODO: Document this fallback.
        xdvir::SCRIPT_TYPE_LATIN
    }
}

HBfontLibrary <- xdvir::FontLibrary(
    glyphWidth = hbGlyphWidth,
    glyphHeight = hbGlyphHeight,
    glyphBounds = hbGlyphBounds,
    glyphIndex = upGlyphIndex,
    resolveScriptType = resolveScriptType
)

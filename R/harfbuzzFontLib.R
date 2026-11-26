set("hb-fontlib-cache", list())
.gidToCp <- new.env()

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
                "height",
                "origX", "origY"
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

.hwMultiplier <- function(index, fontName) {
    hwGlyphs <- get(paste0(FONT_CACHE_HW, basename(fontName)))
    # Don't clutter the base environment with index mapping.
    cp <- unlist(base::mget(paste(basename(fontName), index, sep = ":"),
        envir = .gidToCp, ifnotfound = NA
    ))
    m <- if (cp %in% hwGlyphs) 0.5 else 1
    m
}

hbGlyphWidth <- function(index, fontName) {
    m <- hbGlyphMetrics(index, c("width", "origX"), fontName)
    m["width"] <- m["width"] * .hwMultiplier(index, fontName)
    m
}

hbGlyphHeight <- function(index, fontName) {
    m <- hbGlyphMetrics(index, c("height", "origY"), fontName)
    m["height"] <- m["height"] * .hwMultiplier(index, fontName)
    m
}

hbGlyphBounds <- function(index, fontName) {
    hbGlyphMetrics(
        index,
        c("left", "bottom", "right", "top"),
        fontName
    )
}

#' @importFrom stats setNames
.hbGlyphIndex <- function(value, fontName, direction) {
    i <- .Call(
        C_hbGlyphIndex, as.integer(value),
        as.character(fontName)[1], as.integer(direction)
    )
    list2env(setNames(as.list(value), paste(basename(fontName), i, sep = ":")),
        envir = .gidToCp
    )
    i
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
        xdvir::ScriptTypeCJK
    } else if (fontName %in% get(FONT_CACHE_LATIN)) {
        xdvir::ScriptTypeLatin
    } else {
        # TODO: Document this fallback.
        xdvir::ScriptTypeLatin
    }
}

#' @title Retrieve Font Metrics and Glyph Indices Using HarfBuzz
#' @description Provides utility based on the \code{xdvir::FontLibrary}
#' object. It uses the HarfBuzz shaping engine to obtain glyph indices
#' and glyph metrics from the Unicode codepoint obtained from the DVI output.
#' @details
#' The font library makes the following functions available, their return
#' types are:
#' \itemize{
#'   \item glyphWidth: This contains horizontal advance as the first element,
#'  and the vertical x-origin as the second element.
#'   \item glyphHeight: This contains vertical advance as the first element,
#'  and the vertical y-origin as the second element.
#'  \item glyphBounds: This provides the left, right, top and bottom
#'  ink-extents of glyphs.
#'  \item glyphIndex: This maps a Unicode codepoint (as seen in DVI output)
#'  to a character index in the font.
#' \item resolveScriptType: This extension was specifically built into the
#'  \code{xdvir::FontLibrary} interface for the \code{upxdvir} implementation.
#'  This returns either \code{CJK} or \code{Latin}, depending on where the font
#'  file was found.
#' }
#' @seealso \code{xdvir::SupportedScriptTypes}
#' @seealso \code{xdvir::FontLibrary}
#' @seealso \code{xdvir::render}
#' @export
HBfontLibrary <- xdvir::FontLibrary(
    glyphWidth = hbGlyphWidth,
    glyphHeight = hbGlyphHeight,
    glyphBounds = hbGlyphBounds,
    glyphIndex = upGlyphIndex,
    resolveScriptType = resolveScriptType
)

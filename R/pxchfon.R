require("fs")

pxchfonSpecialPrefix <- "^pdf:mapline "
pxchFontCacheKey <- "upxdvir::pxchfon"
defaultFamilies <- c("sans", "serif", "mono")
ALLOWED_PTEX_FONT_FAMILIES <- "up-font-ptex-maps"

.pxchfonPreamble <- function(fontFamily, fontFace) {
    # Clean pxchfon state for every document.
    set(pxchFontCacheKey, list())
    ff <- "noalphabet"
    # pxchfon font family.
    if (nchar(fontFamily) > 1 && !(fontFamily %in% defaultFamilies)) {
        validatedFontFams <- unique(c(ff, .validatePtexFontFamily(fontFamily)))
        ff <- paste(validatedFontFams, collapse = ",")
    }
    preamblePackages <- paste0(
        "\\usepackage[deluxe,uplatex]{otf}\n",
        "\\usepackage[dvipdfmx,unicode,", ff, "]{pxchfon}"
    )
    if (!isTRUE(getOption("upxdvir.pfb"))) {
        preamblePackages <- c(
            c(
                "\\usepackage[T1]{fontenc}\n",
                "\\usepackage{lmodern}\n",
                "\\usepackage{mathastext}\n"
            ),
            preamblePackages
        )
    }
    paste(preamblePackages, collapse = "")
}

#' @importFrom fs path
.loadPtexFontMaps <- function() {
    ptexPath <- options("upxdvir.ptex.path")
    texHome <- lookupKpathsea("-var-value TEXMFDIST", wrapArgs = FALSE)
    if (isFALSE(nchar(ptexPath) > 0) && is.na(texHome)) {
        message(
            "TeX home can't be resolved, ptex-fontmaps can't be validated.",
            "Set the TEXMFDIST environment variable or ",
            "options(upxdvir.ptex.path) to enable font validation."
        )
        set(ALLOWED_PTEX_FONT_FAMILIES, list())
    } else if (!is.na(texHome)) {
        ptexPath <- fs::path(texHome, "fonts/map/dvipdfmx/ptex-fontmaps/")
        fontMaps <- c(system2("ls", ptexPath, stdout = TRUE, stderr = TRUE))
        if (length(fontMaps) > 0) {
            set(ALLOWED_PTEX_FONT_FAMILIES, fontMaps)
        }
    } else if (nchar(ptexPath) > 0) {
        fontMaps <- c(system2("ls", ptexPath, stdout = TRUE, stderr = TRUE))
        if (length(fontMaps) > 0) {
            set(ALLOWED_PTEX_FONT_FAMILIES, fontMaps)
        }
    } else {
        set(ALLOWED_PTEX_FONT_FAMILIES, list())
    }
}

.validatePtexFontFamily <- function(fontFamily) {
    allowedFontFamilies <- get(ALLOWED_PTEX_FONT_FAMILIES)
    if (length(allowedFontFamilies) == 0) {
        .loadPtexFontMaps()
        allowedFontFamilies <- get(ALLOWED_PTEX_FONT_FAMILIES)
    }

    if (length(allowedFontFamilies) > 0 && fontFamily %in% allowedFontFamilies) {
        fontFamily
    } else {
        message("Unsupported font family, using default instead.")
        "noalphabet"
    }
}

.pxchfonPrefix <- function(fontFamily, fontFace) {
    if (!nchar(fontFace)) {
        fontFace <- "plain"
    }
    fontFace <- match.arg(fontFace, c("plain", "bold"))
    prefix <- ""
    # Process font-face, currently only plain and bold work.
    if (fontFace == "bold") {
        prefix <- paste(
            prefix,
            "\\bfseries"
        )
    }
    # Process font families.
    if (fontFamily == "mono") {
        prefix <- paste(
            prefix,
            "\\gtfamily\\ttfamily"
        )
    } else if (fontFamily == "serif") {
        prefix <- paste(
            prefix,
            "\\mcfamily\\rmfamily"
        )
    } else {
        # No oblique faces supported.
        prefix <- paste(
            prefix,
            "\\gtfamily\\sffamily"
        )
    }
}

.pxchfonSpecial <- function(specialString, state) {
    if (grepl(pxchfonSpecialPrefix, specialString)) {
        splitArr <- unlist(strsplit(specialString, split = " "))
        fontName <- splitArr[2]
        fontFile <- splitArr[4]
        if (isTRUE(nchar(fontName) > 0 && nchar(fontFile) > 0)) {
            cacheItem <- get(pxchFontCacheKey) %||% list()
            cacheItem[fontName] <- fontFile
            set(pxchFontCacheKey, cacheItem)
        }
    }
}


#' @importFrom xdvir LaTeXpackage
#' @title LaTeX Package for \code{pxchfon} package
#' @examples 
#' \dontrun{
#' grid.uplatex(
#'     "Abc", 
#'     packages = pxchfonPackage(fontFamily = "serif", fontFace = "bold")
#' )
#' }
#' @description This package allows for font families supported by the \code{ptex-fontmaps} (u)p\LaTeX package
#' @details This includes the \code{pxchfon} package in the document preamble.
#' This also include the \code{japanese-otf} package in the (u)p\LaTeX fragment with the \code{deluxe} option to support multi-weight fonts.
#' @param fontFamily A font family supported by \code{ptex-fontmaps}, or one of \code{sans}, \code{serif} or \code{mono}. By default, \code{sans} is applied.
#' @param fontFace Only \code{plain} or \code{bold} faces are supported. By default, \code{plain} is applied.
#' @seealso [`xdvir::LaTeXpackage`]
#' @export
pxchfonPackage <- function(fontFamily = "", fontFace = "plain") {
    xdvir::LaTeXpackage(
        name = "pxchfon",
        preamble = .pxchfonPreamble(fontFamily, fontFace),
        prefix = .pxchfonPrefix(fontFamily, fontFace),
        special = .pxchfonSpecial
    )
}

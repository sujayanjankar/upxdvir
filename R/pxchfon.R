pxchfonSpecialPrefix <- "^pdf:mapline "
pxchFontCacheKey <- "upxdvir::pxchfon"
defaultFamilies <- c("sans", "serif", "mono")

.pxchfonPreamble <- function(fontFamily, fontFace) {
    # Clean pxchfon state for every document.
    set(pxchFontCacheKey, list())
    ff <- "noalphabet"
    # pxchfon font family.
    if (nchar(fontFamily) > 1 && fontFamily != ff && !(fontFamily %in% defaultFamilies)) {
        ff <- paste(ff, fontFamily, sep = ",")
    }
    paste0(
        "\\usepackage[deluxe,uplatex]{otf}\n",
        "\\usepackage[dvipdfmx,unicode,", ff, "]{pxchfon}"
    )
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

pxchfonPackage <- function(fontFamily = "", fontFace = "plain") {
    xdvir::LaTeXpackage(
        name = "pxchfon",
        preamble = .pxchfonPreamble(fontFamily, fontFace),
        prefix = .pxchfonPrefix(fontFamily, fontFace),
        special = .pxchfonSpecial
    )
}

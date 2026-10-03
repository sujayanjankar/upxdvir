pxchfonSpecialPrefix <- "^pdf:mapline "
pxchFontCacheKey <- "upxdvir::pxchfon"
defaultFamilies <- c("sans", "serif", "mono")

.upFontPreamble <- function(fontFamily) {
    ff <- "noalphabet"
    if (nchar(fontFamily) && fontFamily != ff && !(fontFamily %in% defaultFamilies)) {
        ff <- paste(ff, fontFamily, sep = ",")
    }
    paste0("\\usepackage[", ff, "]{pxchfon}")
}

.upFontPrefix <- function(fontFamily, fontFace) {
    if (length(fontFace) > 1) {
        fontFace <- fontFace[1]
        # TODO: When does this happen? Log it? Warn it?
    }
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

.upFontSpecial <- function(specialString, state) {
    if (grepl(pxchfonSpecialPrefix, specialString)) {
        splitArr <- unlist(strsplit(specialString, split = " "))
        fontName <- splitArr[2]
        fontFile <- splitArr[4]
        cacheItem <- get(pxchFontCacheKey) %||% list()
        cacheItem[fontName] <- fontFile
        set(pxchFontCacheKey, cacheItem)
    }
}

upFontPackage <- function(fontFamily = "", fontFace = "plain") {
    xdvir::LaTeXpackage(
        name = "pxchfon",
        preamble = .upFontPreamble(fontFamily),
        prefix = .upFontPrefix(fontFamily, fontFace),
        special = .upFontSpecial
    )
}

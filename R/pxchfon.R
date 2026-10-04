pxchfonSpecialPrefix <- "^pdf:mapline "
pxchFontCacheKey <- "upxdvir::pxchfon"
defaultFamilies <- c("sans", "serif", "mono")

.upFontPreamble <- function(fontFamily, fontFace) {
    ff <- "noalphabet"
    localFont <- ""
    if (grepl("\\.", fontFamily)) {
        # Local font file.
        fontPath <- lookupKpathsea(fontFamily)
        if (length(fontPath) > 0 && file.exists(fontPath)) {
            if (fontFace == "plain") {
                localFont <- paste0("\\setminchofont{", fontFamily, "}")
            } else {
                localFont <- paste0("\\setgothicfont{", fontFamily, "}")
            }
        } else {
            warning("Font", fontFamily, "could not be found. Falling back to system default.")
        }
    } else {
        # pxchfon font family.
        if (nchar(fontFamily) > 1 && fontFamily != ff && !(fontFamily %in% defaultFamilies)) {
            ff <- paste(ff, fontFamily, sep = ",")
        }
    }
    paste0("\\usepackage[dvipdfmx,unicode,", ff, "]{pxchfon}", localFont)
}

.upFontPrefix <- function(fontFamily, fontFace) {
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
        preamble = .upFontPreamble(fontFamily, fontFace),
        prefix = .upFontPrefix(fontFamily, fontFace),
        special = .upFontSpecial
    )
}

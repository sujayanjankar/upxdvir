pxchfonSpecialPrefix <- "^pdf:mapline "
pxchFontCacheKey <- "upxdvir::pxchfon"

upFontPreamble <- function(fontFamily = "alphabet") {
    paste0("\\usepackage[", fontFamily, "]{pxchfon}")
}

upFontSpecial <- function(specialString, state) {
    if (grepl(pxchfonSpecialPrefix, specialString)) {
        splitArr <- unlist(strsplit(specialString, split = " "))
        fontName <- splitArr[2]
        fontFile <- splitArr[4]
        cacheItem <- get(pxchFontCacheKey) %||% list()
        cacheItem[fontName] <- fontFile
        set(pxchFontCacheKey, cacheItem)
    }
}

upFontPackage <- function(fontFamily = "alphabet") {
    xdvir::LaTeXpackage(
        name = "pxchfon",
        preamble = upFontPreamble(fontFamily),
        special = upFontSpecial
    )
}

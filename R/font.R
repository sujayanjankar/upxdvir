require(fs)

FONT_CACHE_PREFIX <- "up-font-def-"
FONT_CACHE_CJK <- "up-font-cjk-"
FONT_CACHE_LATIN <- "up-font-ltn-"

.initFonts <- function() {
    # This may potentially be expanded in the future
    # considering other maps.
    pdftexMapPath <- lookupKpathsea("pdftex.map")
    kanjixMapPath <- lookupKpathsea("kanjix.map")
    if (!is.na(pdftexMapPath)) {
        set("pdftex.map.path", pdftexMapPath)
    }
    if (!is.na(kanjixMapPath)) {
        set("kanjix.map.path", kanjixMapPath)
    }
    set("fonts.initialised", TRUE)
    message("Fonts initialised.")
}

#' @importFrom fs path_sanitize
.lookupFont <- function(lookupString, lookupPath, fontNameIdx = 3) {
    fontMappingRow <- grep(
        lookupString,
        readLines(lookupPath),
        ignore.case = TRUE,
        value = TRUE
    )
    if (length(fontMappingRow) > 0) {
        fontFileName <- strsplit(fontMappingRow, "\\s")[[1]][fontNameIdx]
        # Remove any characters that shouldn't be in filenames.
        fontFileName <- fs::path_sanitize(fontFileName)
        hasExtension <- grepl("\\.[^/.]+$", fontFileName)
        # Assume otf, if no extension.
        filenameToSearch <- paste0(
            fontFileName,
            if (hasExtension) "" else ".otf"
        )
        lookupResult <- lookupKpathsea(filenameToSearch)
        if (is.na(lookupResult)) {
            # Lookup lowercase if the as-is lookup returns nothing.
            lookupResult <- lookupKpathsea(tolower(filenameToSearch))
        }
        if (is.na(lookupResult)) {
            message("File ", fontFileName, " not found!")
            return(NA_character_)
        } else {
            return(lookupResult)
        }
    }
    return(NA_character_)
}

.clearFontCache <- function(pattern = "^up-font-") {
    rm(
        list = grep(pattern, ls(upxdvir_state), value = TRUE),
        envir = upxdvir_state
    )
}

upFontFile <- function(fontNameWithoutExtension) {
    if (!isTRUE(get("fonts.initialised"))) {
        .initFonts()
    }
    fontCacheKey <- paste0(FONT_CACHE_PREFIX, fontNameWithoutExtension)
    cachedFontPath <- get(fontCacheKey)
    pxchFonts <- get(pxchFontCacheKey)
    # If a pxchfon family has been set, skip the cache.
    skipCache <- length(pxchFonts) > 0
    if (isTRUE(!skipCache && (nchar(cachedFontPath) > 0))) {
        # message("Returning cached font: ", cachedFontPath)
        return(cachedFontPath)
    }
    fontNameWithExtn <- paste0(fontNameWithoutExtension, ".vf")
    filePath <- lookupKpathsea(fontNameWithExtn)
    latinFont <- cjkFont <- NA
    # If the `.vf` file was not found, try the lookup in the latin font map.
    if (is.na(filePath)) {
        # Modern roman fonts have their OTF font name as the second column
        # in the font map.
        latinFont <- .lookupFont(fontNameWithoutExtension,
            get("pdftex.map.path"),
            fontNameIdx = 2
        )
        # TODO: Should this be "upxdvir.interactive"?
        if (isTRUE(getOption("upxdvir.pfb"))) {
            # Use the .pfb font.
            latinFont <- lookupKpathsea(
                paste0(fontNameWithoutExtension, ".pfb")
            )
        }
        # message("Found: ", latinFont)
        # Cache font names from the DVI output against their type.
        if (!is.na(latinFont)) {
            latinFonts <- get(FONT_CACHE_LATIN)
            set(FONT_CACHE_LATIN, c(latinFonts, fontNameWithoutExtension))
        }
    } else {
        strContentFile <- readVirtualFontName(filePath)
        # Kanji fonts have their OTF font name as the final column
        # in the font map.
        if (skipCache) {
            cjkFont <- lookupKpathsea(pxchFonts[strContentFile])
        }
        if (is.na(cjkFont)) {
            if (skipCache) {
                warning(
                    "Physical font ", pxchFonts[strContentFile],
                    "for the specified font family could not be located.",
                    "Using system default."
                )
            }
            # Lookup the old way if the pxchfon specification does
            # not return anything.
            cjkFont <- .lookupFont(strContentFile, get("kanjix.map.path"))
        }
        # message("Found: ", cjkFont)
        # Cache font names from the DVI output against their type.
        if (!is.na(cjkFont)) {
            cjkFonts <- get(FONT_CACHE_CJK)
            set(FONT_CACHE_CJK, c(cjkFonts, fontNameWithoutExtension))
        }
    }
    if (is.na(cjkFont) && is.na(latinFont)) {
        stop("No font could be resolved for: ", fontNameWithoutExtension)
    }
    res <- ifelse(!is.na(cjkFont), cjkFont, latinFont)
    set(fontCacheKey, res)
    # message("Resolving to: ", res)
    res
}

upFontPreset <- function(family, face, size, lineheight, colour) {
    packages <- list(pxchfonPackage(family, face))
    # Process font size.
    fontsize <- paste0(
        "\\fontsize{", size, "}{", size * lineheight, "}\n",
        "\\selectfont{}\n"
    )

    # Process font colour.
    if (is.null(colour)) {
        stop("No colour specified")
    }
    rgb <- grDevices::col2rgb(colour)
    col <- paste0(
        "\\definecolor{upxdvir}{RGB}{",
        rgb[1, ], ",", rgb[2, ], ",", rgb[3, ], "}\n",
        "\\color{upxdvir}\n"
    )
    black <- apply(rgb, 2, function(x) all(x == 0))
    col[black] <- ""
    if (any(!black)) {
        packages <- c(packages, list("xcolor"))
    }

    # Bring them all together.
    tex <- paste(fontsize, col, sep = "")
    attr(tex, "packages") <- packages
    tex
}

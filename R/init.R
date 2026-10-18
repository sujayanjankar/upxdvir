#' @useDynLib upxdvir, .registration=TRUE, .fixes="C_"

#' @importFrom rlang on_load
.onLoad <- function(libname, pkgname) {
    initialiseEngine()
}

#' @importFrom xdvir registerEngine registerPackage 
initialiseEngine <- function() {
    ## Define and register the upTeX engine.
    initUpTeX()
    if (uptexAvailable()) {
        UpTeXengine <- xdvir::TeXengine(
            name = "upTeX",
            version = uptexVersion(),
            command = "latex",
            isEngine = isUpTeX,
            fontFile = upFontFile,
            glyphIndex = upGlyphIndex,
            options = "",
            buildArgs = buildUpTeXargs,
            preamble = c(
                "\\usepackage[T1]{fontenc}",
                "\\usepackage{lmodern}",
                "\\pagestyle{empty}",
                "\\setlength{\\parindent}{0pt}"
            ),
            emulation = FALSE,
            fontPreset = upFontPreset
        )
        xdvir::registerEngine(UpTeXengine)
        xdvir::registerPackage(pxchfonPackage())
        xdvir::registerPackage(minipagePackage())
        # message("Registered upTeX!")
    } else {
        stop("No upTeX installation found!")
    }
}

buildUpTeXargs <- function(signature, dir) {
    paste0(
        '-latex="uplatex -output-comment=\'',
        signature,
        "' '-output-directory=", dir, '\'"',
        " -auxdir=", dir,
        " -outdir=", dir,
        " -dvi"
    )
}

initUpTeX <- function() {
    uptex <- Sys.which("uptex")
    if (nchar(uptex) > 0) {
        versText <- system("uptex --version", intern = TRUE)
        set("uptexVersionStr", versText)
        if (length(versText)) {
            version <- versText[1]
        } else {
            version <- "unknown version"
        }
        set("uptexVersion", version)
    }
}

uptexVersion <- function() {
    get("uptexVersion")
}

uptexAvailable <- function() {
    !is.null(uptexVersion())
}

#' @importFrom xdvir commentString
isUpTeX <- function(dvi) {
    commentStr <- xdvir::commentString(dvi)
    grepl(uptexVersion(), commentStr)
}

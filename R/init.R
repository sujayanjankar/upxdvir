.onLoad <- function(libname, pkgname) {
    initialiseEngine()
}

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
                "\\usepackage{lmodern}",
                "\\pagestyle{empty}"
            ),
            emulation = FALSE
        )
        xdvir::registerEngine(UpTeXengine)
        options(xdvir.engine = UpTeXengine)
        options(xdvir.fontLib = upFontLibrary)
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
        " -outdir=", dir
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

isUpTeX <- function(dvi) {
    commentStr <- xdvir::commentString(dvi)
    grepl(uptexVersion(), commentStr)
}

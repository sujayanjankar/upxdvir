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
    win <- .Platform$OS.type == "windows"
    od <- shQuote(paste0("-output-directory=", dir))
    latex <- paste0(
        "uplatex -output-comment=", shQuote(signature),
        if (!win) paste0(" ", od)
    )
    paste0(
        "-latex=", shQuote(latex),
        if (win) paste0(" ", od),
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

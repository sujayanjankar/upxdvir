.onLoad <- function(libname, pkgname) {
    initialise_engine()
}

initialise_engine <- function() {
    ## Define and register the upTeX engine.
    initUpTeX()
    if (uptexAvailable()) {
        UpTeXengine <- xdvir::TeXengine(
            name = "upTeX",
            version = uptexVersion(),
            command = "latex",
            isEngine = isUpTeX,
            fontFile = up_font_file,
            glyphIndex = hbGlyphIndex,
            options = "-latex=uplatex",
            preamble = c(
                "\\usepackage{lmodern}",
                "\\pagestyle{empty}"
            ),
            emulation = FALSE
        )
        xdvir::registerEngine(UpTeXengine)
        options(xdvir.engine = UpTeXengine)
        options(xdvir.fontLib=upFontLibrary)
        message("Registered upTeX!")
    } else {
        stop("No upTeX installation found!")
    }
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
    commentStr <- commentString(dvi)
    grepl(uptexVersion(), commentStr)
}

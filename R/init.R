require(xdvir)

.onLoad <- function(libname, pkgname) {
    # Uncomment this once ready once the font family is sorted.
    ## Define and register the upTeX engine.
    initUpTeX()
    if (uptexAvailable()) {
        UpTeXengine <- xdvir::TeXengine(
            name = "upTeX",
            version = uptexVersion(),
            command = "uptex",
            isEngine = isUpTeX,
            fontFile = up_font_file
        )
        registerEngine(UpTeXengine)
        options(xdvir.engine = UpTeXengine)
    }

}

initUpTeX <- function() {
    uptex <- Sys.which("uptex")
    if (nchar(uptex) > 0) {
        versText <- system("uptex --version", intern=TRUE)
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
require(xdvir)

.onLoad <- function(libname, pkgname) {
    ## Define and register the upTeX engine.
    initUpTeX()
    if (uptexAvailable()) {
        UpTeXengine <- xdvir::TeXengine(
            name = "upTeX",
            version = uptexVersion(),
            command = "latex",
            isEngine = isUpTeX,
            fontFile = up_font_file,
            glyphIndex = uptex_glyph_index,
            options = "-latex=uplatex -pdfdvi"
        )
        xdvir::registerEngine(UpTeXengine)
        options(xdvir.engine = UpTeXengine)
        print("Registered upTeX!")
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


tinytex::latexmk(
    "/Users/sujay/Documents/Workspace/upxdvir/inst/tex/minimal-uptex.tex",
    engine = "latex",
    engine_args = "-latex=uplatex",
    emulation = FALSE
)

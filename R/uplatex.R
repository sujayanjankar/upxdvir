require(grid)
require(xdvir)
# TODO: Clean up loggers.
grid.uplatex <- function(text, ..., height = 0, direction = 1, verbose = FALSE) {
    wrapper <- if (verbose) {
        \(...) actualExecution(...)
    } else {
        \(...) suppressMessages(suppressWarnings(actualExecution(...)))
    }
    wrapper(text, ..., height = height, direction = direction)
}

actualExecution <- function(text, ..., height, direction) {
    otherArgs <- list(...)
    message(text)
    message(str(otherArgs))
    message(height)
    message(direction)
    pkgs <- c()
    if (height > 0) {
        pkgs <- c(pkgs, list(minipagePackage(height)))
    }
    texFileContent <- xdvir::author(text,
        documentClass = ifelse(direction == 1, "utarticle", "ujarticle"),
        packages = pkgs, engine = "upTeX"
    )
    message(texFileContent)
    dviFile <- xdvir::typeset(texFileContent, engine = "upTeX")
    args <- c(
        list(dvi = dviFile),
        list(engine = "upTeX"),
        otherArgs,
        list(packages = pkgs),
        list(fontLib = upFontLibrary)
    )
    do.call(xdvir::render, args)
}

element_uplatex <- function(text, ..., height = 0, direction = 1) {
    otherArgs <- list(...)
    print(otherArgs)
    pkgs <- c()
    if (height > 0) {
        pkgs <- c(pkgs, list(minipagePackage(height)))
    }
    print(pkgs)
    do.call(
        xdvir::element_latex,
        c(
            list(engine = "upTeX"),
            list(documentClass = ifelse(direction == 1, "utarticle", "ujarticle")),
            otherArgs,
            list(fontLib = upFontLibrary),
            list(packages = pkgs)
        )
    )
}

uplatexGrob <- function(text, ..., height = 0, direction = 1) {
    otherArgs <- list(...)
    # TODO: Wire in height.
    do.call(
        xdvir::latexGrob,
        c(
            list(tex = text),
            list(engine = "upTeX"),
            otherArgs,
            list(fontLib = upFontLibrary),
            list(documentClass = ifelse(direction == 1, "utarticle", "ujarticle"))
        )
    )
}

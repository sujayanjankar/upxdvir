require(grid)
require(xdvir)

grid.uplatex <- function(text, ..., direction = 1, verbose = FALSE) {
    .clearFontCache()
    if (verbose) {
        .innerGridUplatex(text, ..., direction = direction)
    } else {
        suppressMessages(suppressWarnings(.innerGridUplatex(text, ..., direction = direction)))
    }
}

.innerGridUplatex <- function(text, ..., direction) {
    otherArgs <- list(...)
    pkgs <- c()
    dimToLimit <- if (direction == 1) otherArgs$gp$height else otherArgs$gp$width
    dimToLimit <- convertUnitToInches(dimToLimit)
    if (dimToLimit > 0) {
        pkgs <- c(pkgs, list(minipagePackage(dimToLimit)))
    }
    message(otherArgs)
    if (length(otherArgs$packages) > 0) {
        pkgs <- c(pkgs, list(otherArgs$packages))
        otherArgs$packages <- NULL
    }
    message(pkgs)
    args <- c(
        list(tex = text),
        list(engine = "upTeX"),
        list(documentClass = ifelse(direction == 1, "utarticle", "ujarticle")),
        otherArgs,
        list(packages = pkgs),
        list(fontLib = HBfontLibrary)
    )
    do.call(xdvir::grid.latex, args)
}

element_uplatex <- function(text, ..., height = 0, direction = 1,
                            angle = if (direction == 1) -0 else 0,
                            vjust = if (direction == 1) 0.5 else 0,
                            verbose = FALSE) {
    .clearFontCache()
    if (verbose) {
        .innerElementUplatex(text, ...,
            height = height, direction = direction,
            angle = angle, vjust = vjust
        )
    } else {
        suppressMessages(suppressWarnings(.innerElementUplatex(text, ...,
            height = height,
            direction = direction,
            angle = angle,
            vjust = vjust
        )))
    }
}

.innerElementUplatex <- function(text, ..., height, direction) {
    otherArgs <- list(...)
    pkgs <- c()
    dimToLimit <- if (direction == 1) otherArgs$gp$height else otherArgs$gp$width
    dimToLimit <- convertUnitToInches(dimToLimit)
    if (dimToLimit > 0) {
        pkgs <- c(pkgs, list(minipagePackage(dimToLimit)))
    }
    message(otherArgs)
    if (length(otherArgs$packages) > 0) {
        pkgs <- c(pkgs, list(otherArgs$packages))
        otherArgs$packages <- NULL
    }
    message(pkgs)
    do.call(
        xdvir::element_latex,
        c(
            list(engine = "upTeX"),
            list(documentClass = ifelse(direction == 1, "utarticle", "ujarticle")),
            otherArgs,
            list(fontLib = HBfontLibrary),
            list(packages = pkgs)
        )
    )
}

uplatexGrob <- function(text, ..., height = 0, direction = 1, verbose = FALSE) {
    .clearFontCache()
    if (verbose) {
        .innerUplatexGrob(text, ..., height = height, direction = direction)
    } else {
        suppressMessages(suppressWarnings(.innerUplatexGrob(text, ...,
            height = height,
            direction = direction
        )))
    }
}

.innerUplatexGrob <- function(text, ..., height, direction) {
    otherArgs <- list(...)
    pkgs <- c()
    dimToLimit <- if (direction == 1) height else width
    dimToLimit <- convertUnitToInches(dimToLimit)
    if (dimToLimit > 0) {
        pkgs <- c(pkgs, list(minipagePackage(dimToLimit)))
    }
    message(otherArgs)
    if (length(otherArgs$packages) > 0) {
        pkgs <- c(pkgs, list(otherArgs$packages))
        otherArgs$packages <- NULL
    }
    message(pkgs)
    do.call(
        xdvir::latexGrob,
        c(
            list(tex = text),
            list(engine = "upTeX"),
            list(packages = pkgs),
            otherArgs,
            list(fontLib = HBfontLibrary),
            list(documentClass = ifelse(direction == 1, "utarticle", "ujarticle"))
        )
    )
}

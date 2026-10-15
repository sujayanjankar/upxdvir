require(grid)
require(xdvir)

grid.uplatex <- function(..., direction = 1, verbose = FALSE) {
    .clearFontCache()
    if (verbose) {
        .innerGridUplatex(..., direction = direction)
    } else {
        quiet(.innerGridUplatex(..., direction = direction))
    }
}

.innerGridUplatex <- function(..., direction) {
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
        otherArgs,
        list(packages = pkgs),
        fixedParameters(direction)
    )
    do.call(xdvir::grid.latex, args)
}

element_uplatex <- function(..., height = 0, direction = 1,
                            angle = if (direction == 1) -0 else 0,
                            vjust = if (direction == 1) 0.5 else 0,
                            verbose = FALSE) {
    .clearFontCache()
    if (verbose) {
        .innerElementUplatex(...,
            height = height,
            direction = direction, angle = angle, vjust = vjust
        )
    } else {
        quiet(.innerElementUplatex(...,
            height = height,
            direction = direction, angle = angle, vjust = vjust
        ))
    }
}

.innerElementUplatex <- function(..., height, direction) {
    otherArgs <- list(...)
    pkgs <- c()
    dimToLimit <- if (direction == 1) height else otherArgs$width
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
            otherArgs,
            list(packages = pkgs),
            fixedParameters(direction)
        )
    )
}

uplatexGrob <- function(..., height = 0, direction = 1, verbose = FALSE) {
    .clearFontCache()
    if (verbose) {
        .innerUplatexGrob(..., height = height, direction = direction)
    } else {
        quiet(.innerUplatexGrob(..., height = height, direction = direction))
    }
}

.innerUplatexGrob <- function(..., height, direction) {
    otherArgs <- list(...)
    pkgs <- c()
    dimToLimit <- if (direction == 1) height else otherArgs$width
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
            otherArgs,
            list(packages = pkgs),
            fixedParameters(direction)
        )
    )
}

fixedParameters <- function(direction) {
    c(
        list(engine = "upTeX"),
        list(fontLib = HBfontLibrary),
        list(documentClass = ifelse(direction == 1, "utarticle", "ujarticle"))
    )
}

#' @title grid.uplatex
#' @description Draws a glyph grob on the specified graphics device.
#' @param text This is the up\LaTeX{} fragment to typeset.
#' @param direction Can be either 0 or 1. If 0, text is typeset horizontally,
#' else vertically. Default: 1.
#' @param verbose If \code{TRUE}, prints trace logging. Default: \code{FALSE}
#' @param \dots Additional parameters sent to \code{xdvir::grid.latex}
#' @param height For \code{grid.uplatex}, height is supplied as a part of the
#' graphical parameters (\code{gpar}s).
#'  For \code{uplatexGrob}, height is a parameter of its own. Height is
#' interpreted by \code{minipagePackage}. So it can be a number, or a
#' \code{grid::unit}. Default: 0
#' @export
#' @importFrom xdvir grid.latex
#' @aliases uplatexGrob
#' @rdname grid.uplatex
#' @examples \dontrun{
#' grid.uplatex("日本語")
#' grid.uplatex("日本語", gp = grid::gpar(height = grid::unit(1, "in")))
#' uplatexGrob("日本語")
#' uplatexGrob("日本語", height = grid::unit(1, "in"))
#' }
#' @seealso \code{\link{minipagePackage}}
#' @seealso \code{\link{xdvir::grid_latex}}
#' @seealso \code{\link{xdvir::latexGrob}}
#' @seealso \code{\link{grid::unit}}
grid.uplatex <- function(text, ..., direction = 1, verbose = FALSE) {
    .clearFontCache()
    if (verbose) {
        .innerGridUplatex(text, ..., direction = direction)
    } else {
        quiet(.innerGridUplatex(text, ..., direction = direction))
    }
}

.innerGridUplatex <- function(text, ..., direction) {
    otherArgs <- list(...)
    pkgs <- c()
    dimToLimit <- if (direction == 1) otherArgs$gp$height else otherArgs$gp$width
    if (!is.null(dimToLimit)) {
        pkgs <- c(pkgs, list(minipagePackage(dimToLimit)))
    }
    message(otherArgs)
    if (length(otherArgs$packages) > 0) {
        pkgs <- c(pkgs, list(otherArgs$packages))
        otherArgs$packages <- NULL
    }
    message(pkgs)
    args <- c(
        list(tex = suppressLigatures(text)),
        otherArgs,
        list(packages = pkgs),
        fixedParameters(direction)
    )
    do.call(xdvir::grid.latex, args)
}

#' @title element_uplatex
#' @description \code{ggplot2} theme element for vertically typesetting
#' text using the up\LaTeX{} engine.
#' @param height  Height is interpreted by \code{minipagePackage}. So it
#' can be a number, or a
#' \code{grid::unit}. Default: 0
#' @param direction Can be either 0 or 1. If 0, text is typeset horizontally,
#'  else vertically. Default: 1.
#' @param verbose If \code{TRUE}, prints trace logging. Default: \code{FALSE}
#' @param angle The angle to which the text is to be rotated. Default -0
#' for vertical typesetting, else 0.
#' @param vjust The vertical justification. Default 0.5 for vertical
#' typesetting, else 0.
#' @param \dots Additional parameters sent to \code{xdvir::element_latex}
#' @export
#' @importFrom xdvir element_latex
#' @seealso \code{\link{minipagePackage}}
#' @seealso \code{\link{xdvir::element_uplatex}}
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
    if (!is.null(dimToLimit)) {
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

#' @rdname grid.uplatex
#' @export
#' @importFrom xdvir latexGrob
uplatexGrob <- function(text, ..., height = 0, direction = 1, verbose = FALSE) {
    .clearFontCache()
    if (verbose) {
        .innerUplatexGrob(text, ..., height = height, direction = direction)
    } else {
        quiet(.innerUplatexGrob(text, ..., height = height, direction = direction))
    }
}

.innerUplatexGrob <- function(text, ..., height, direction) {
    otherArgs <- list(...)
    pkgs <- c()
    dimToLimit <- if (direction == 1) height else otherArgs$width
    if (!is.null(dimToLimit)) {
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
            list(tex = suppressLigatures(text)),
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

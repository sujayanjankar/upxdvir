#' @title grid.uplatex
#' @description Draws a glyph grob on the specified graphics device.
#' @param text The up\LaTeX{} fragment to typeset.
#' @param direction Can be either \code{horizontal} or \code{vertical}.
#' Default: \code{vertical}.
#' @param verbose If \code{TRUE}, prints trace logging. Default: \code{FALSE}
#' @param \dots Additional parameters sent to \code{xdvir::grid.latex}
#' @details Height should be supplied as a part of the
#' graphical parameters (\code{gpar}s). It can be a number (interpreted as
#' \code{npc}), or a \code{grid::unit}. Default: unset.
#' @export
#' @importFrom xdvir grid.latex
#' @examples \dontrun{# Needs upLaTeX and grid.
#' grid.uplatex("Text")
#' grid.uplatex("Text", gp = grid::gpar(height = grid::unit(1, "in")))
#' }
#' @seealso \link{minipagePackage}
#' @seealso \code{xdvir::grid.latex}
#' @seealso \code{xdvir::latexGrob}
#' @seealso \code{grid::unit}
grid.uplatex <- function(text, direction = "vertical", verbose = FALSE, ...) {
    .clearFontCache()
    if (verbose) {
        .innerGridUplatex(text, ..., direction = direction)
    } else {
        quiet(.innerGridUplatex(text, ..., direction = direction))
    }
}

.innerGridUplatex <- function(text, direction, ...) {
    otherArgs <- list(...)
    pkgs <- c()
    dimToLimit <- if (resolveDirection(direction) == "vertical") {
        otherArgs$gp$height
    } else {
        otherArgs$gp$width
    }
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
#' @param height Can be a number (interpreted as \code{npc} units), or a
#' \code{grid::unit}. Default: unset.
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
#' @seealso \link{minipagePackage}
#' @seealso \code{xdvir::element_latex}
element_uplatex <- function(
  height = 0, direction = "vertical",
  angle = if (resolveDirection(direction) == "vertical") -0 else 0,
  vjust = if (resolveDirection(direction) == "vertical") 0.5 else 0,
  verbose = FALSE, ...
) {
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

.innerElementUplatex <- function(height, direction, ...) {
    otherArgs <- list(...)
    pkgs <- c()
    dimToLimit <- if (resolveDirection(direction) == "vertical") {
        height
    } else {
        otherArgs$width
    }
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

#' @title uplatexGrob
#' @description Produces a \code{xdvir::DVIgrob} object to be drawn on graphics
#' devices.
#' @param text The up\LaTeX{} fragment to typeset.
#' @param direction Can be either \code{horizontal} or \code{vertical}.
#' Default: \code{vertical}.
#' @param verbose If \code{TRUE}, prints trace logging. Default: \code{FALSE}
#' @param height For \code{grid.uplatex}, height is supplied as a part of the
#' graphical parameters (\code{gpar}s). For \code{uplatexGrob}, height is a
#' parameter of its own. Height is interpreted by \code{minipagePackage}.
#' So it can be a number (as \code{npc}), or a \code{grid::unit}. Default: 0
#' @param \dots Additional parameters sent to \code{xdvir::latexGrob}
#' @examples \dontrun{# Needs upLaTeX and grid.
#' uplatexGrob("Text")
#' uplatexGrob("Text", height = grid::unit(1, "in"))
#' }
#' @seealso \link{minipagePackage}
#' @seealso \code{xdvir::grid.latex}
#' @seealso \code{xdvir::latexGrob}
#' @seealso \code{grid::unit}
#' @export
#' @importFrom xdvir latexGrob
#' @return A \code{xdvir::DVIgrob} object
uplatexGrob <- function(
  text, height = 0, direction = "vertical", verbose = FALSE, ...
) {
    .clearFontCache()
    if (verbose) {
        .innerUplatexGrob(text, ...,
            height = height,
            direction = direction
        )
    } else {
        quiet(.innerUplatexGrob(text, ...,
            height = height,
            direction = direction
        ))
    }
}

.innerUplatexGrob <- function(text, height, direction, ...) {
    otherArgs <- list(...)
    pkgs <- c()
    dimToLimit <- if (resolveDirection(direction) == "vertical") {
        height
    } else {
        otherArgs$width
    }
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
        list(engine = "upLaTeX"),
        list(fontLib = HBfontLibrary),
        list(documentClass = if (resolveDirection(direction) == "vertical") {
            "utarticle"
        } else {
            "ujarticle"
        })
    )
}

# Applies the \begin{minipage} prefix.
.minipagePrefix <- \(limit) ifelse(
    limit > 0,
    paste0("\\begin{minipage}{", limit, "in}"),
    ""
)

# Applies the \end{minipage} suffix.
.minipageSuffix <- \(limit) ifelse(
    limit > 0,
    "\\end{minipage}",
    ""
)

#' @export
#' @name minipagePackage
#' @title LaTeX Package for \code{minipage}
#' @description Wraps the \LaTeX{} fragment in a \code{minipage} environment.
#' The output resembles:
#' \code{\\begin[limit]{minipage}<fragment>\\end{minipage}}
#' @param limit This is either the height or width to which the typesetting is
#' to be limited. Interpretation depends on whether the typesetting is vertical
#' or horizontal. When specified just as a number, it needs to be in
#' \eqn{[0, 1]}.
#' @details This function creates a \code{LaTeXpackage} object.
#' The specified \code{limit} is by default in \code{grid} NPC units.
#' A \code{grid.unit} may also be specified.
#' @examples
#' \dontrun{# Needs upLaTeX and grid.
#' grid.uplatex("Abc", packages = minipagePackage(limit = 1))
#' }
#' @seealso \code{xdvir::LaTeXpackage}
#' @seealso \code{grid::unit}
#' @keywords LaTeXpackage
#' @return A \code{LaTeXpackage} object.
minipagePackage <- function(limit = NULL) {
    limitAsUnit <- convertUnitToInches(limit)
    LaTeXpackage(
        name = "",
        prefix = .minipagePrefix(limitAsUnit),
        suffix = .minipageSuffix(limitAsUnit)
    )
}

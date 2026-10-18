.minipagePrefix <- \(height) ifelse(
    height > 0,
    paste0("\\begin{minipage}{", height, "in}"),
    ""
)


.minipageSuffix <- \(height) ifelse(
    height > 0,
    "\\end{minipage}",
    ""
)

#' @export
#' @name minipagePackage
#' @title LaTeX package for \code{minipage}
#' @aliases minipagePackage
#' @description Wraps the \LaTeX{} fragment in a \code{\begin[limit]{minipage}<fragment>\end{minipage}}
#' @usage minipagePackage()
#' @details This function creates a \code{LaTeXpackage} object.
#' @return A \code{LaTeXpackage} object.
#' @examples grid.uplatex("TeX fragment", packages = c(minipagePackage(unit(2, "in"))))
minipagePackage <- function(height = NULL) {
    heightAsUnit <- convertUnitToInches(height)
    LaTeXpackage(
        name = "",
        prefix = .minipagePrefix(heightAsUnit),
        suffix = .minipageSuffix(heightAsUnit)
    )
}

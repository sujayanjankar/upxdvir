require(grid)
require(xdvir)

grid.uplatex <- function(text) {
    grid.draw(xdvir::latexGrob(text))
}

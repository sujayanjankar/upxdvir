drawGrid <- function(border = TRUE) {
    grid.segments(
        c(0, .5),
        c(.5, 0),
        c(1, .5),
        c(.5, 1),
        gp = gpar(lty = 4, col = "gray", alpha = .5)
    )
    if (border) {
        grid.rect(gp = gpar(lwd = 10, col = 2, fill = NA))
    }
}

setKnitrPresets <- function(
    height = 3, width = 3, error = TRUE, align = "center"
) {
    chunkSet <- knitr::opts_chunk$set
    chunkSet(error = error)
    chunkSet(fig.height = height)
    chunkSet(fig.width = width)
    chunkSet(fig.align = align)
}

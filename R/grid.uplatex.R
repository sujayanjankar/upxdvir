require(grid)
require(xdvir)

grid.uplatex <- function(text, ..., verbose = FALSE) {
    wrapper <- if (verbose) {
        \(...) actual_execution(...)
    } else {
        \(...) suppressMessages(suppressWarnings(actual_execution(...)))
    }
    wrapper(text, ..., verbose = FALSE)
}

actual_execution <- function(text, ..., verbose = FALSE) {
    other_args <- list(...)
    pkgs <- c("xcolor")
    tex_file_content <- xdvir::author(text,
        documentClass = "utarticle",
        packages = pkgs
    )
    dvi_file <- xdvir::typeset(tex_file_content)
    args <- c(
        list(dvi = dvi_file),
        other_args,
        list(packages = pkgs)
    )
    do.call(xdvir::render, args)
}

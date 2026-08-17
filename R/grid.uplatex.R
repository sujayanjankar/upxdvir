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
    pkgs <- c()
    tex_content <- xdvir::author(text, document_class = "utarticle")
    tex_file_name <- write_temp_file(tex_content)
    dvi_file <- typeset_uptex(tex_file_name, pkgs)
    args <- c(
        list(dvi = dvi_file),
        other_args,
        list(packages = pkgs)
    )
    dvi_grob <- do.call(dviGrob, args)
    grid.draw(dvi_grob)
}

write_temp_file <- function(doc) {
    tex_file_name <- tempfile(fileext = ".tex")
    message("TeX content written to: ", tex_file_name)
    writeLines(doc, tex_file_name)
    tex_file_name
}

typeset_uptex <- function(tex_file_name, packages = NULL) {
    package_sig <-  buildSignature(getOption("xdvir.engine"), packages)
    dir_name <- dirname(tex_file_name)
    options(tinytex.output_dir = dir_name)
    options <- paste0(
        '-latex="uplatex -output-comment=\'',
        package_sig,
        "' '-output-directory=",
        dir_name,
        '\'"'
    )
    message("Options: ", options, collapse = " ")
    dvi_file_name <- tinytex::latexmk(
        tex_file_name,
        engine = "latex",
        engine_args = options,
        emulation = FALSE
    )
    message("DVI output written to: ", dvi_file_name)
    readDVI(dvi_file_name)
}

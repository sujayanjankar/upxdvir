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
        document_class = "utarticle",
        packages = pkgs
    )
    dvi_file <- typeset_uptex(tex_file_content, pkgs)
    args <- c(
        list(dvi = dvi_file),
        other_args,
        list(packages = pkgs)
    )
    do.call(xdvir::render, args)
}

typeset_uptex <- function(doc, packages = NULL) {
    tex_file_name <- tempfile(fileext = ".tex")
    writeLines(doc, tex_file_name)
    message("TeX content written to: ", tex_file_name)
    package_sig <- buildSignature(getOption("xdvir.engine"), packages)
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

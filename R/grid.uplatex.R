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
    tex_file_name <- author_uptex(text)
    dvi_file <- typeset_uptex(tex_file_name)
    args <- c(
        list(dvi = dvi_file),
        other_args,
        list(packages = pkgs)
    )
    dvi_grob <- do.call(dviGrob, args)
    grid.draw(dvi_grob)
}

doc_from_fragment <- function(fragment) {
    tex <- paste(
        "\\documentclass{utarticle}",
        "\\usepackage{xcolor}",
        "\\pagestyle{empty}",
        # "\\usepackage{amsfonts}",
        "\\begin{document}",
        fragment,
        "\\end{document}",
        collapse = "\n"
    )
    message("TeX template: ", tex)
    tex
}

author_uptex <- function(text) {
    doc <- doc_from_fragment(text)
    tex_file_name <- tempfile(fileext = ".tex")
    message("TeX content written to: ", tex_file_name)
    writeLines(doc, tex_file_name)
    tex_file_name
}

typeset_uptex <- function(tex_file_name) {
    dvi_file_name <- paste0(gsub("[.]tex", "", tex_file_name), ".dvi")
    package_sig <- paste0(
        "R package xdvir_0.2.0; ",
        "engine name: upTeX; ",
        "engine version: e-upTeX 3.141592653-p4.1.2-u2.02-251130-2.6; ",
        "packages: xcolor"
    )
    dir_name <- dirname(dvi_file_name)
    options(tinytex.output_dir = dir_name)
    options <- paste0(
        '-latex="uplatex -output-comment=\'',
        package_sig,
        "' \'-output-directory=",
        dir_name,
        '\'"'
    )
    message("Options: ", paste(options, collapse = " "))
    tinytex::latexmk(
        tex_file_name,
        engine = "latex",
        engine_args = options,
        emulation = FALSE,
        max_times = 1
    )
    message("DVI output written to: ", dvi_file_name)
    readDVI(dvi_file_name)
}

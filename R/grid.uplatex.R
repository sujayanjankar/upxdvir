require(grid)
require(xdvir)

xcolorPreamble <- "\\usepackage{xcolor}"

grid.uplatex <- function(text, verbose = FALSE) {
    doc <- doc_from_fragment(text)
    tex_file_name <- write_tex_file(doc)
    dvi_file <- generate_dvi(tex_file_name)
    dvi_grob_wrapper <- if (verbose) {
        dviGrob
    } else {
        \(...) suppressMessages(suppressWarnings(dviGrob(...)))
    }
    dvi_grob <- dvi_grob_wrapper(dvi_file, packages = c("xcolor"))
    grid.draw(dvi_grob)
}

doc_from_fragment <- function(fragment) {
    tex <- paste(
        "\\documentclass{utarticle}",
        xcolorPreamble,
        "\\begin{document}",
        fragment,
        "\\end{document}",
        collapse = "\n"
    )
    message("TeX template: ", tex)
    tex
}

write_tex_file <- function(doc) {
    tex_file_name <- tempfile(fileext = ".tex")
    message("TeX content written to: ", tex_file_name)
    writeLines(doc, tex_file_name)
    tex_file_name
}

generate_dvi <- function(tex_file_name) {
    dvi_file_name <- paste0(gsub("[.]tex", "", tex_file_name), ".dvi")
    package_sig <- paste0(
        "R package xdvir_0.2.0; ",
        "engine name: upTeX; ",
        "engine version: e-upTeX 3.141592653-p4.1.2-u2.02-251130-2.6; ",
        "packages: xcolor"
    )
    # TODO: Add -output-dir here. May also need the tinytex option to be set.
    options <- paste0('-latex="uplatex -output-comment=\'', package_sig, '\'"')
    message("Options: ", paste(options, collapse = " "))
    tinytex::latexmk(
        tex_file_name,
        engine = "latex",
        engine_args = options,
        emulation = FALSE
    )
    message("DVI output written to: ", dvi_file_name)
    readDVI(dvi_file_name)
}

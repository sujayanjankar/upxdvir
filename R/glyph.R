uptex_glyph_index <- function(raw, fontname, fontLib) {
    font_lib <- options("xdvir.fontLib")$xdvir.fontLib
    font_lib$glyphIndex(raw, fontname, fontLib)
}

glyph_mapping <- function(dvi_file = "inst/dvi/minimal-uptex.dvi") {
    if (!file.exists(dvi_file)) {
        stop("DVI file ", dvi_file, " does not exist!")
    }
    dvi <- xdvir::readDVI(dvi_file)
    codes <- xdvir:::opCodes(dvi)
    params <- xdvir:::opParams(dvi)
    set_idx <- which(codes %in% 128:131)
    res_dec <- unlist(params[set_idx])
    # res_unicode <- sprintf("%04X", unlist(params[set_idx]))
    font_path <- up_font_file("upjisr-v")
    font_lib <- options("xdvir.fontLib")$xdvir.fontLib
    # sapply(res_dec, \(x) font_lib$glyphIndex(as.integer(x), font_path))
    indices <- sapply(
        res_dec,
        \(x) font_lib$glyphIndex(as.integer(x), font_path)
    )
    sapply(indices, \(x) font_lib$glyphBounds(as.integer(x), font_path))
}

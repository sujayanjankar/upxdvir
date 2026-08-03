lookup_kpathsea <- function(file_name) {
    print(paste("Looking up:", file_name))
    system2("kpsewhich", args = file_name, stdout = TRUE, stderr = TRUE)
}

read_string_from_binary <- function(file_path) {
    print(paste("Reading strings from:", file_path))
    system2("strings", args = file_path, stdout = TRUE, stderr = TRUE)
}

extract_font_defs <- function(file) {
    dvi <- readDVI(file)
    codes <- xdvir:::opCodes(dvi)
    params <- xdvir:::opParams(dvi)
    # Standard DVI font definitions (opcodes 243–246)
    fnt_idx <- which(codes %in% 243:246)
    font_defs <- sapply(fnt_idx, function(i) {
        paste0(params[[i]]$fontname.name, collapse = "")
    })
    unique(font_defs)
}

fonts <- extract_font_defs("/Users/sujay/Documents/Workspace/xdvir/inst/DVI/minimal-uptex.dvi")

sapply(fonts, up_font_file)

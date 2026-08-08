init_fonts <- function() {
    pdftex_map_path <- lookup_kpathsea("pdftex.map")
    kanjix_map_path <- lookup_kpathsea("kanjix.map")
    if (length(pdftex_map_path) > 0) {
        set("pdftex.map.path", pdftex_map_path)
    }
    if (length(kanjix_map_path) > 0) {
        set("kanjix.map.path", kanjix_map_path)
    }
    set("fonts.initialised", TRUE)
}

lookup_fonts <- function(lookup_str, lookup_path) {
    font_mapping_row <- grepv(lookup_str,
        readLines(lookup_path),
        ignore.case = TRUE
    )
    if (length(font_mapping_row) > 0) {
        font_file_name <- strsplit(font_mapping_row, "\\s")[[1]][3]
        # Remove any characters that shouldn't be in filenames.
        font_file_name <- gsub("[^a-zA-Z0-9 ._-]", "", font_file_name)
        if (length(strsplit(font_file_name, "\\.")[[1]]) == 2) {
            file_lookup_res <- lookup_kpathsea(font_file_name)
            if (
                length(file_lookup_res) <= 0 &&
                    attr(file_lookup_res, "status") > 0
            ) {
                warning(paste("File", font_file_name, "not found!"))
            } else {
                return(file_lookup_res)
            }
        } else {
            warning(
                "Font file name: ",
                font_file_name,
                "not found in",
                lookup_path
            )
        }
    }
}

up_font_file <- function(font_name_wo_extn) {
    if (!isTRUE(get("font.initialised"))) {
        init_fonts()
    }
    font_name_with_extn <- paste0(font_name_wo_extn, ".vf")
    file_path <- lookup_kpathsea(font_name_with_extn)
    exit_status <- attr(file_path, "status")
    roman_font <- cjk_font <- NULL
    # If the `.vf` file was not found, try the lookup in the roman font map.
    if (length(file_path) <= 0 && exit_status > 0) {
        roman_font <- lookup_fonts(font_name_wo_extn, get("pdftex.map.path"))
    } else {
        str_content_file <- read_string_from_binary(file_path)
        cjk_font <- lookup_fonts(str_content_file, get("kanjix.map.path"))
    }
    ifelse(length(cjk_font) > 0, cjk_font, roman_font)
}

extract_font_defs <- function(dvi_file, verbose = FALSE) {
    if (!file.exists(dvi_file)) {
        stop("DVI file ", dvi_file, " does not exist!")
    }
    dvi <- xdvir::readDVI(dvi_file)
    codes <- xdvir:::opCodes(dvi)
    params <- xdvir:::opParams(dvi)
    # Standard DVI font definitions (opcodes 243–246)
    fnt_idx <- which(codes %in% 243:246)

    sapply(fnt_idx, function(i) {
        paste0(params[[i]]$fontname.name, collapse = "")
    })
}

norun <- function(dvi_path = "inst/tex/minimal-uptex.dvi", verbose = FALSE) {
    f1 <- if (verbose) {
        init_fonts
    } else {
        \(...) suppressMessages(suppressWarnings(init_fonts(...)))
    }
    f1()
    font_defs <- extract_font_defs(dvi_path)
    f2 <- if (verbose) {
        up_font_file
    } else {
        \(...) suppressMessages(suppressWarnings(up_font_file(...)))
    }
    sapply(unique(font_defs), f2)
}

FONT_CACHE_PREFIX <- "up-font-def-"

.initFonts <- function() {
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

.lookupFont <- function(lookup_str, lookup_path, font_name_idx = 3) {
    font_mapping_row <- grep(
        lookup_str,
        readLines(lookup_path),
        ignore.case = TRUE,
        value = TRUE
    )
    if (length(font_mapping_row) > 0) {
        font_file_name <- strsplit(font_mapping_row, "\\s")[[1]][font_name_idx]
        # Remove any characters that shouldn't be in filenames.
        font_file_name <- fs::path_sanitize(font_file_name)
        has_extn <- grepl("\\.[^/.]+$", font_file_name)
        # Assume otf, if no extension.
        filename_to_search <- paste0(font_file_name, ifelse(has_extn, "", ".otf"))
        file_lookup_res <- lookup_kpathsea(filename_to_search)
        if (length(file_lookup_res) <= 0) {
            # Lookup lowercase if the as-is lookup returns nothing.
            file_lookup_res <- lookup_kpathsea(tolower(filename_to_search))
        }
        if (
            length(file_lookup_res) <= 0 &&
                attr(file_lookup_res, "status") > 0
        ) {
            message("File", font_file_name, "not found!")
        } else {
            return(file_lookup_res)
        }
    }
}

upFontFile <- function(font_name_wo_extn) {
    if (!isTRUE(get("fonts.initialised"))) {
        .initFonts()
    }
    font_cache_key <- paste0(FONT_CACHE_PREFIX, font_name_wo_extn)
    cached_font_path <- get(font_cache_key)
    if (length(cached_font_path) > 0) {
        return(cached_font_path)
    }
    font_name_with_extn <- paste0(font_name_wo_extn, ".vf")
    file_path <- lookup_kpathsea(font_name_with_extn)
    exit_status <- attr(file_path, "status")
    latin_font <- cjk_font <- NULL
    # If the `.vf` file was not found, try the lookup in the latin font map.
    if (length(file_path) <= 0 && exit_status > 0) {
        # Modern roman fonts have their OTF font name as the second column
        # in the font map.
        latin_font <- .lookupFont(font_name_wo_extn,
            get("pdftex.map.path"),
            font_name_idx = 2
        )
        # message("Found: ", latin_font)
    } else {
        str_content_file <- read_string_from_binary(file_path)
        # Kanji fonts have their OTF font name as the final column
        # in the font map.
        cjk_font <- .lookupFont(str_content_file, get("kanjix.map.path"))
        # message("Found: ", cjk_font)
    }
    if (isFALSE(length(cjk_font) > 0 || length(latin_font) > 0)) {
        stop("No font could be resolved.")
    }
    res <- ifelse(length(cjk_font) > 0, cjk_font, latin_font)
    set(font_cache_key, res)
    res
}

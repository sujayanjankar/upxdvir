lm_family <- c(
    cmr = "LMRoman",
    cmbx = "LMRoman",
    cmti = "LMRoman",
    cmsl = "LMRoman",
    cmss = "LMSans",
    cmssbx = "LMSans",
    cmtt = "LMMono",
    cmcsc = "LMRomanCaps"
)

lm_style <- c(
    cmr = "Regular", cmbx = "Bold", cmti = "Italic",
    cmsl = "Oblique", cmss = "Regular", cmssbx = "Bold",
    cmtt = "Regular", cmcsc = "Regular"
)

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

lookup_font <- function(lookup_str, lookup_path) {
    font_mapping_row <- grep(
        lookup_str,
        readLines(lookup_path),
        ignore.case = TRUE,
        value = TRUE
    )
    if (length(font_mapping_row) > 0) {
        font_file_name <- strsplit(font_mapping_row, "\\s")[[1]][3]
        # Remove any characters that shouldn't be in filenames.
        font_file_name <- fs::path_sanitize(font_file_name)
        if (length(strsplit(font_file_name, "\\.")[[1]]) == 2) {
            file_lookup_res <- lookup_kpathsea(font_file_name)
            if (
                length(file_lookup_res) <= 0 &&
                    attr(file_lookup_res, "status") > 0
            ) {
                message(paste("File", font_file_name, "not found!"))
            } else {
                return(file_lookup_res)
            }
        } else {
            message(
                "Font file name: ",
                font_file_name,
                "not found in",
                lookup_path
            )
        }
    }
}

latin_font <- function(cm_name) {
    prefix <- sub("[0-9]+$", "", cm_name)
    size <- sub("^[a-z]+", "", cm_name)
    fam <- lm_family[[prefix]]
    sty <- lm_style[[prefix]]
    if (is.null(fam)) stop("unmapped CM prefix: ", prefix)
    tolower(sprintf("%s%s-%s.otf", fam, size, sty))
}

up_font_file <- function(font_name_wo_extn) {
    if (!isTRUE(get("fonts.initialised"))) {
        init_fonts()
    }
    font_cache_key <- paste0("up-font-def-", font_name_wo_extn)
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
        latin_font <- lookup_kpathsea(latin_font(font_name_wo_extn))
        message("Found: ", latin_font)
    } else {
        str_content_file <- read_string_from_binary(file_path)
        cjk_font <- lookup_font(str_content_file, get("kanjix.map.path"))
        message("Found: ", cjk_font)
    }
    if (isFALSE(length(cjk_font) > 0 || length(latin_font) > 0)) {
        stop("No font could be resolved.")
    }
    res <- ifelse(length(cjk_font) > 0, cjk_font, latin_font)
    set(font_cache_key, res)
    res
}

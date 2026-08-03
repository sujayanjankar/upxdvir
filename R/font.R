up_font_file <- function(font_name) {
    font_name_with_extn <- paste0(font_name, ".vf")
    file_path <- lookup_kpathsea(font_name_with_extn)
    exit_status <- attr(file_path, "status")
    if (length(file_path) <= 0 && exit_status > 0) {
        warning("Font ", font_name_with_extn, " not found.")
        return(NULL)
    }
    str_content_file <- read_string_from_binary(file_path)
    kanjix_map_path <- lookup_kpathsea("pdftex.map")
    exit_status <- attr(kanjix_map_path, "status")
    if (length(kanjix_map_path) <= 0 && exit_status > 0) {
        warning(paste("kanjix.map not found!"))
        return(NULL)
    }
    font_mapping_row <- grepv(str_content_file, readLines(kanjix_map_path))
    font_file_name <- strsplit(font_mapping_row, "\\s")[[1]][3]
    if (length(strsplit(font_file_name, "\\.")[[1]]) == 2) {
        lookup_kpathsea(font_file_name)
    } else {
        warning("Bad font file name: ", font_file_name)
    }
}

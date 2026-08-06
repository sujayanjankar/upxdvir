lookup_kpathsea <- function(file_name) {
    message("Looking up: ", file_name)
    system2("kpsewhich", args = file_name, stdout = TRUE, stderr = TRUE)
}

read_string_from_binary <- function(file_path) {
    message("Reading strings from: ", file_path)
    system2("strings", args = file_path, stdout = TRUE, stderr = TRUE)
}

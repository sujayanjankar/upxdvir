lookup_kpathsea <- function(file_name) {
    # message("Looking up: ", file_name)
    suppressWarnings(system2("kpsewhich", args = file_name, stdout = TRUE, stderr = TRUE))
}

read_string_from_binary <- function(file_path) {
    # message("Resolving from VF: ", file_path)
    res <- readVF(file_path)
    rawToChar(res[[2]]$blocks[["op.opparams.fontname.name"]]$fileRaw)
}

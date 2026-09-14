lookupKpathsea <- function(fileName) {
    # message("Looking up: ", fileName)
    suppressWarnings(system2("kpsewhich", args = fileName, stdout = TRUE, stderr = TRUE))
}

readVirtualFontName <- function(filePath) {
    # message("Resolving from VF: ", file_path)
    res <- readVF(filePath)
    rawToChar(res[[2]]$blocks[["op.opparams.fontname.name"]]$fileRaw)
}

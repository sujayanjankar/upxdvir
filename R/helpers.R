lookupKpathsea <- function(fileName) {
    # message("Looking up: ", fileName)
    suppressWarnings(system2("kpsewhich", args = fileName, stdout = TRUE, stderr = TRUE))
}

readVirtualFontName <- function(filePath) {
    # message("Resolving from VF: ", file_path)
    res <- readVF(filePath)
    rawToChar(res[[2]]$blocks[["op.opparams.fontname.name"]]$fileRaw)
}

convertUnitToInches <- function(dim, unit = "npc") {
    if (is.null(dim)) {
        0
    } else {
        if (!is.unit(dim)) {
            dim <- unit(dim, unit)
        }
        convertUnit(dim, "in", valueOnly = TRUE)
    }
}

quiet <- function(fun) {
    \(...) suppressMessages(suppressWarnings(fun(...)))
}

lookupKpathsea <- function(fileName, wrapArgs = TRUE) {
    args <- ifelse(wrapArgs, shQuote(fileName), fileName)
    out <- suppressWarnings(
        system2("kpsewhich", args = args, stdout = TRUE, stderr = FALSE)
    )
    status <- attr(out, "status")
    if (!is.null(status) && status != 0L) {
        return(NA_character_)
    }
    out <- out[nzchar(out)]
    if (length(out) == 0L) {
        return(NA_character_)
    }
    out[1L]
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

quiet <- function(expr) suppressMessages(suppressWarnings(expr))
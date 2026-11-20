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
        if (!grid::is.unit(dim)) {
            dim <- grid::unit(dim, unit)
        }
        round(grid::convertUnit(dim, "in", valueOnly = TRUE), 2)
    }
}

quiet <- function(expr) suppressMessages(suppressWarnings(expr))

# TODO: Super hack, see if a nicer way out can be found.
# May not even be be needed with the pfb font support.
suppressLigatures <- function(text) {
    gsub("f([fil])", "f{}\\1", text)
}

resolveDirection <- function(method = c("horizontal", "vertical")) {
    method <- tryCatch(
        match.arg(method),
        error = function(e) {
            warning("Invalid direction provided. Defaulting to 'vertical'.")
            return("vertical")
        }
    )
    method
}

isEmptyString <- function(x) !isTRUE(nzchar(x, keepNA = TRUE))
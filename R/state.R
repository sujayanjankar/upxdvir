## Package global state
upxdvir_state <- new.env()

get <- function(name) {
    base::get0(name, envir = upxdvir_state, inherits = FALSE)
}

mget <- function(names) {
    base::mget(names, envir = upxdvir_state, inherits = FALSE)
}

set <- function(name, value) {
    assign(name, value, envir = upxdvir_state)
}

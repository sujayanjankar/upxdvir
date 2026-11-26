require(upxdvir)
require(testthat)

test_that("empty is empty", {
    expect_true(isEmptyString(NULL))
    expect_true(isEmptyString(""))
    expect_true(isEmptyString(NA))
})

test_that("not empty is not empty", {
    expect_false(isEmptyString(" "))
    expect_false(isEmptyString("123"))
})

test_that("resolve horizontal", {
    expect_equal(resolveDirection("h"), "horizontal")
    expect_equal(resolveDirection("ho"), "horizontal")
    expect_equal(resolveDirection("hor"), "horizontal")
})

test_that("resolve vertical", {
    expect_equal(resolveDirection("v"), "vertical")
    expect_equal(resolveDirection("ve"), "vertical")
    expect_equal(resolveDirection("ver"), "vertical")
})

test_that("bad direction is bad", {
    expect_warning(r <- resolveDirection("lol"))
    expect_equal(r, "vertical")
})

mock_sys <- function(result) {
    local_mocked_bindings(
        system2 = function(...) result, .package = "base",
        .env = parent.frame()
    )
}

test_that("returns first path on success", {
    mock_sys(c("/a/article.cls", "/b/article.cls"))
    expect_identical(lookupKpathsea("article.cls"), "/a/article.cls")
})

test_that("returns NA on non-zero status", {
    mock_sys(structure(character(0), status = 1L))
    expect_identical(lookupKpathsea("missing.sty"), NA_character_)
})

test_that("returns NA on empty or blank output", {
    mock_sys(character(0))
    expect_identical(lookupKpathsea("x.sty"), NA_character_)
    mock_sys(c("", ""))
    expect_identical(lookupKpathsea("x.sty"), NA_character_)
})

test_that("skips blank lines before taking first result", {
    mock_sys(c("", "/real/path.sty"))
    expect_identical(lookupKpathsea("path.sty"), "/real/path.sty")
})

test_that("wrapArgs controls quoting", {
    seen <- NULL
    local_mocked_bindings(
        system2 = function(command, args, ...) {
            seen <<- args
            "/p"
        },
        .package = "base"
    )
    lookupKpathsea("my file.sty", wrapArgs = TRUE)
    expect_identical(seen, shQuote("my file.sty"))
    lookupKpathsea("my file.sty", wrapArgs = FALSE)
    expect_identical(seen, "my file.sty")
})

test_that("readVirtualFontName extracts the font name", {
    fake_vf <- list(
        NULL,
        list(blocks = list(
            "op.opparams.fontname.name" = list(fileRaw = charToRaw("cmr10"))
        ))
    )
    local_mocked_bindings(readVF = function(filePath) fake_vf)
    expect_identical(readVirtualFontName("x.vf"), "cmr10")
})

test_that("quiet suppresses messages and warnings but returns the value", {
    expect_no_message(expect_no_warning(
        res <- quiet({
            message("hi")
            warning("uh oh")
            42
        })
    ))
    expect_identical(res, 42)
})

test_that("suppressLigatures breaks f-ligature pairs", {
    expect_identical(suppressLigatures("fi"), "f{}i")
    expect_identical(suppressLigatures("fl"), "f{}l")
    expect_identical(suppressLigatures("ff"), "f{}f")
    expect_identical(suppressLigatures("hello"), "hello")
})

require(upxdvir)
require(testthat)

test_that("can initialise the engine", {
    suppressWarnings(upxdvir:::initialiseEngine())
    e <- xdvir:::getEngine.character("uptex")
    expect_equal(e$name, "upTeX")
    expect_equal(e$preamble, c(
        "\\pagestyle{empty}",
        "\\usepackage{pxrubrica}",
        "\\usepackage{plext}",
        "\\setlength{\\parindent}{0pt}"
    ))
})

test_that("can build uptex args", {
    expect_equal(
        upxdvir:::buildUpTeXargs("signature", "/path/to/nowhere"),
        paste0(
            "-latex=\"uplatex -output-comment='signature'",
            " '-output-directory=/path/to/nowhere'\" -auxdir=/path/to/nowhere",
            " -outdir=/path/to/nowhere -dvi"
        )
    )
})


test_that("can build uptex args for windows", {
    local_mocked_bindings(
        get_os_type = \() "windows",
        .package = "upxdvir"
    )
    expect_equal(
        upxdvir:::buildUpTeXargs("signature", "/path/to/nowhere"),
        # Extra quoting hell for windows.
        paste0(
            "-latex=\"uplatex -output-comment='signature'\" ",
            "'-output-directory=/path/to/nowhere' ",
            "-auxdir=/path/to/nowhere -outdir=/path/to/nowhere -dvi"
        )
    )
})

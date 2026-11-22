test_that("can initialise with defaults", {
    pp <- upxdvir::pxchfonPackage()
    expect_equal(class(pp), "LaTeXpackage")
    expect_equal(pp$name, "pxchfon")
    expect_equal(pp$preamble, paste0(
        "\\usepackage[T1]{fontenc}\n\\usepackage{lmodern}\n",
        "\\usepackage{mathastext}\n\\usepackage[deluxe,uplatex]{otf}\n",
        "\\usepackage[dvipdfmx,unicode,noalphabet,haranoaji]{pxchfon}"
    ))
    expect_equal(pp$prefix, " \\gtfamily\\sffamily")
})


test_that("can resolve font file from specials", {
    pp <- upxdvir::pxchfonPackage()
    called <- FALSE
    resolvedFont <- ""
    local_mocked_bindings(
        set = function(name, value) {
            called <<- TRUE
            resolvedFont <<- value
            return(name)
        }, .package = "upxdvir"
    )
    pp$special("pdf:mapline fontName blah fontFile", "")
    expect_true(called)
    expect_equal(resolvedFont[[1]], "fontFile")
})

test_that("can handle serif", {
    pp <- upxdvir::pxchfonPackage("serif")
    expect_equal(pp$prefix, " \\mcfamily\\rmfamily")
})

test_that("can handle mono", {
    pp <- upxdvir::pxchfonPackage("mono")
    expect_equal(pp$prefix, " \\gtfamily\\ttfamily")
})

test_that("can handle bold", {
    pp <- upxdvir::pxchfonPackage(fontFamily = NULL, fontFace = "bold")
    expect_equal(pp$prefix, " \\bfseries \\gtfamily\\sffamily")
})

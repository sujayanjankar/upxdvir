require(upxdvir)

test_that("can define a font size", {
    res <- upFontPreset("", "", 12, 1, NA)
    expected <- paste0(
        "\\fontsize{12}{12}\n",
        "\\selectfont{}\n",
        "\\definecolor{upxdvir}{RGB}{255,255,255}\n",
        "\\color{upxdvir}\n"
    )
    attr(expected, "packages") <- list(pxchfonPackage("", ""), "xcolor")
    expect_equal(res, expected)
})


test_that("can define a font color", {
    res <- upFontPreset("", "", 12, 1, "red")
    expected <- paste0(
        "\\fontsize{12}{12}\n",
        "\\selectfont{}\n",
        "\\definecolor{upxdvir}{RGB}{255,0,0}\n",
        "\\color{upxdvir}\n"
    )
    attr(expected, "packages") <- list(pxchfonPackage("", ""), "xcolor")
    expect_equal(res, expected)
})

test_that("can define a font family", {
    res <- upFontPreset("ipaex", "", 12, 1, "red")
    expected <- paste0(
        "\\fontsize{12}{12}\n",
        "\\selectfont{}\n",
        "\\definecolor{upxdvir}{RGB}{255,0,0}\n",
        "\\color{upxdvir}\n"
    )
    attr(expected, "packages") <- list(pxchfonPackage("ipaex", ""), "xcolor")
    expect_equal(res, expected)
})


test_that("can define a font face", {
    res <- upFontPreset("ipaex", "bold", 12, 1, "red")
    expected <- paste0(
        "\\fontsize{12}{12}\n",
        "\\selectfont{}\n",
        "\\definecolor{upxdvir}{RGB}{255,0,0}\n",
        "\\color{upxdvir}\n"
    )
    attr(expected, "packages") <- list(
        pxchfonPackage("ipaex", "bold"),
        "xcolor"
    )
    expect_equal(res, expected)
})

test_that("can initialise font maps", {
    pdftexMockPath <- "mockpdftex.map"
    kanjixMockPath <- "mockkanjix.map"

    local_mocked_bindings(
        lookupKpathsea = function(key, wrapArgs) {
            if (key == "kanjix.map") {
                return(kanjixMockPath)
            }
            if (key == "pdftex.map") {
                return(pdftexMockPath)
            }
            return(key)
        }, .package = "upxdvir"
    )
    local_mocked_bindings(
        .loadPtexFontMaps = function() {
            # Noop.
            return(NULL)
        }, .package = "upxdvir"
    )
    calledPdftex <- TRUE
    calledKanjix <- TRUE
    local_mocked_bindings(
        set = function(key, value) {
            if (key == "kanjix.map") {
                expect_equal(value, kanjixMockPath)
                calledKanjix <<- TRUE
            }
            if (key == "pdftex.map") {
                expect_equal(valuem, pdftexMockPath)
                calledPdftex <<- TRUE
            }
            return(key)
        }, .package = "upxdvir"
    )

    expect_message(.initFonts(), "Fonts initialised.")
    expect_equal(calledPdftex, TRUE)
    expect_equal(calledKanjix, TRUE)
})

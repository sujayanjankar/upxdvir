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

test_that("can load ptex-fontmaps by default", {
    local_mocked_bindings(
        lookupKpathsea = function(key, wrapArgs) {
            if (key == "-var-value TEXMFDIST") {
                return("/mock/tex/home")
            }
            return(key)
        }, .package = "upxdvir"
    )
    local_mocked_bindings(
        system2 = function(cmd, path, stdout, stderr) {
            if (cmd == "ls") {
                expect_equal(
                    as.character(path),
                    paste0(
                        "/mock/tex/home/",
                        "fonts/map/dvipdfmx/ptex-fontmaps"
                    )
                )
            }
            c("mockfont1")
        }, .package = "base",
        .env = parent.frame()
    )
    expect_equal(.loadPtexFontMaps(), c("mockfont1"))
})

test_that("can load ptex-fontmaps by override", {
    local_mocked_bindings(
        lookupKpathsea = function(key, wrapArgs) {
            if (key == "-var-value TEXMFDIST") {
                return(NULL)
            }
            return(key)
        }, .package = "upxdvir"
    )
    local_mocked_bindings(
        options = function(...) "/mocked/ptex/path",
        system2 = function(cmd, path, stdout, stderr) {
            if (cmd == "ls") {
                expect_equal(path, "/mocked/ptex/path")
            }
            c("mockfont2")
        },
        .package = "base"
    )
    expect_equal(.loadPtexFontMaps(), c("mockfont2"))
})

test_that("can complain if TeX home or ptex maps are not set", {
    local_mocked_bindings(
        lookupKpathsea = function(key, wrapArgs) {
            if (key == "-var-value TEXMFDIST") {
                return(NULL)
            }
            return(key)
        }, .package = "upxdvir"
    )
    local_mocked_bindings(
        options = function(...) NULL,
        .package = "base"
    )
    expect_message(
        .loadPtexFontMaps(),
        "TeX home can't be resolved, ptex-fontmaps can't be validated."
    )
})

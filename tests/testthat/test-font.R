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

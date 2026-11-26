require(upxdvir)

test_that("npc coordinates are converted to inches", {
    mp <- upxdvir::minipagePackage(0.5)
    expect_equal(class(mp), "LaTeXpackage")
    expect_match(mp$prefix, "[0-9]in}$")
    expect_equal(mp$suffix, "\\end{minipage}")
})

test_that("grid::unit coordinates are not converted", {
    mp <- upxdvir::minipagePackage(grid::unit(1, "cm"))
    expect_equal(class(mp), "LaTeXpackage")
    expect_equal(mp$prefix, "\\begin{minipage}{0.39in}")
    expect_equal(mp$suffix, "\\end{minipage}")
})

test_that("nulls don't generate a wrapper", {
    mp <- upxdvir::minipagePackage(NULL)
    expect_equal(class(mp), "LaTeXpackage")
    expect_match(mp$prefix, "")
    expect_equal(mp$suffix, "")
})

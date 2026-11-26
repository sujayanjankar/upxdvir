require(testthat)
require(upxdvir)

setup_mocks <- function(noisy = FALSE, env = parent.frame()) {
    cap <- new.env()
    record <- function(...) {
        if (noisy) message("latex")
        cap$args <- list(...)
    }
    local_mocked_bindings(
        .clearFontCache = function() cap$cleared <- TRUE,
        resolveDirection = function(d) d,
        minipagePackage = function(d) "mp",
        fixedParameters = function(d) list(fixed = d),
        .env = env
    )
    local_mocked_bindings(
        grid.latex = record, element_latex = record, latexGrob = record,
        .package = "xdvir", .env = env
    )
    cap
}

test_that(".innerGridUplatex suppresses ligatures and adds fixed params", {
    cap <- setup_mocks()
    .innerGridUplatex("office", direction = "vertical")
    expect_identical(cap$args$tex, "of{}fice")
    expect_identical(cap$args$fixed, "vertical")
})

test_that(".innerGridUplatex takes minipage from gp height/width", {
    cap <- setup_mocks()
    .innerGridUplatex("a", direction = "vertical", gp = list(height = 5))
    expect_identical(cap$args$packages, list("mp"))
    .innerGridUplatex("a", direction = "horizontal", gp = list(width = 5))
    expect_identical(cap$args$packages, list("mp"))
    .innerGridUplatex("a", direction = "horizontal", gp = list(height = 5))
    expect_null(cap$args$packages)
})

test_that(".innerGridUplatex merges user packages with minipage", {
    cap <- setup_mocks()
    .innerGridUplatex("a",
        direction = "vertical",
        gp = list(height = 5), packages = "pkgA"
    )
    expect_identical(cap$args$packages, list("mp", "pkgA"))
})

test_that("grid.uplatex clears cache and respects verbose", {
    cap <- setup_mocks(noisy = TRUE)
    expect_no_message(grid.uplatex("a", verbose = FALSE))
    expect_true(cap$cleared)
    expect_message(grid.uplatex("a", verbose = TRUE), "latex")
})

test_that("uplatexGrob suppresses ligatures and adds fixed params", {
    cap <- setup_mocks()
    uplatexGrob("office")
    expect_identical(cap$args$tex, "of{}fice")
    expect_identical(cap$args$fixed, "vertical")
})

test_that("uplatexGrob takes minipage from height/width", {
    cap <- setup_mocks()
    uplatexGrob("a", height = 5, direction = "vertical")
    expect_identical(cap$args$packages, list("mp"))
    expect_null(cap$args$height) # consumed, not forwarded
    uplatexGrob("a", direction = "horizontal", width = 5)
    expect_identical(cap$args$packages, list("mp"))
    uplatexGrob("a", height = 5, direction = "horizontal")
    expect_null(cap$args$packages)
})

test_that("uplatexGrob merges user packages with minipage", {
    cap <- setup_mocks()
    uplatexGrob("a", height = 5, packages = "pkgA")
    expect_identical(cap$args$packages, list("mp", "pkgA"))
})

test_that("uplatexGrob clears cache and respects verbose", {
    cap <- setup_mocks(noisy = TRUE)
    expect_no_message(uplatexGrob("a", verbose = FALSE))
    expect_true(cap$cleared)
    expect_message(uplatexGrob("a", verbose = TRUE), "latex")
})

test_that("element_uplatex passes direction defaults and fixed params", {
    cap <- setup_mocks()
    element_uplatex(direction = "vertical")
    expect_identical(cap$args$vjust, 0.5)
    expect_identical(cap$args$fixed, "vertical")
    element_uplatex(direction = "horizontal")
    expect_identical(cap$args$vjust, 0)
})

test_that("element_uplatex takes minipage from height/width", {
    cap <- setup_mocks()
    element_uplatex(height = 5, direction = "vertical")
    expect_identical(cap$args$packages, list("mp"))
    expect_null(cap$args$height) # consumed, not forwarded
    element_uplatex(direction = "horizontal", width = 5)
    expect_identical(cap$args$packages, list("mp"))
    element_uplatex(height = 5, direction = "horizontal")
    expect_null(cap$args$packages)
})

test_that("element_uplatex merges user packages with minipage", {
    cap <- setup_mocks()
    element_uplatex(height = 5, packages = "pkgA")
    expect_identical(cap$args$packages, list("mp", "pkgA"))
})

test_that("element_uplatex clears cache and respects verbose", {
    cap <- setup_mocks(noisy = TRUE)
    expect_no_message(element_uplatex(verbose = FALSE))
    expect_true(cap$cleared)
    expect_message(element_uplatex(verbose = TRUE), "latex")
})

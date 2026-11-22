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

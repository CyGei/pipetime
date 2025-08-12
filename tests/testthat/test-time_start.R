test_that("time_start adds timing attributes", {
  x <- mtcars
  y <- time_start(x, "test step")
  expect_equal(attr(y, "time_label"), "test step")
  expect_s3_class(attr(y, "time_start"), "POSIXct")
})



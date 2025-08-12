test_that("time_end removes attributes and returns object", {
  x <- time_start(mtcars, "test step")
  Sys.sleep(0.01)
  y <- time_end(x, console = FALSE)
  expect_false("time_start" %in% names(attributes(y)))
  expect_false("time_label" %in% names(attributes(y)))
  expect_equal(y, mtcars)
})

test_that("time_end warns if time_start not called", {
  expect_warning(time_end(mtcars, console = FALSE))
})


test_that("time_end time equals expected", {
  sleep_time <- 1
  log_file <- tempfile()

  mtcars |>
    time_start("sleep test") |>
    dplyr::mutate(sleep = {Sys.sleep(sleep_time); sleep_time}) |>
    time_end(log_file = log_file, console = FALSE)

  log_content <- readLines(log_file)

  # Extract numeric time value using regex
  elapsed <- as.numeric(sub(".*: ([0-9.]+) .* elapsed", "\\1", log_content))

  expect_equal(elapsed, sleep_time, tolerance = 0.1)
})

test_that("timer returns evaluated result", {
  res <- timer({1 + 1}, console = FALSE)
  expect_equal(res, 2)
})

test_that("timer logs to file", {
  log_file <- tempfile()
  timer({Sys.sleep(0.01)}, label = "log test", log_file = log_file, console = FALSE)
  log_content <- readLines(log_file)
  expect_true(any(grepl("log test", log_content)))
})

test_that("timer time equals expected", {
  sleep_time <- 1
  log_file <- tempfile()

  mtcars |>
    dplyr::mutate(sleep = {Sys.sleep(sleep_time); sleep_time}) |>
    timer(label = "sleep test", log_file = log_file, console = FALSE)

  log_content <- readLines(log_file)

  # Extract numeric time value using regex
  elapsed <- as.numeric(sub(".*: ([0-9.]+) .* elapsed", "\\1", log_content))

  expect_equal(elapsed, sleep_time, tolerance = 0.1)
})

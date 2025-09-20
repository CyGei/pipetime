test_that("time_pipe returns input unchanged", {
  df <- data.frame(x = 1:3)
  out <- df |> time_pipe("test", console = FALSE)
  expect_identical(out, df)
})

test_that("time_pipe generates default label", {
  mydataframe <- data.frame(x = 1:3)
  expect_message(mydataframe |> time_pipe(), regexp = "mydataframe")
})

test_that("time_pipe generates custom label", {
  df <- data.frame(x = 1:3)
  expect_message(df |> time_pipe("custom label"), regexp = "custom label")
})

test_that("logging to file works", {
  f <- tempfile()
  df <- data.frame(x = 1:3)
  df |> time_pipe("log test", log_file = f, console = FALSE)
  log <- readLines(f)
  expect_true(any(grepl("log test", log)))
  unlink(f)
})

test_that("invalid time_unit raises error", {
  df <- data.frame(x = 1:3)
  expect_error(
    df |> time_pipe("test", time_unit = "microsec"),
    regexp = "should be one of"
  )
})

test_that("different time units are accepted", {
  df <- data.frame(x = 1:3)
  for (u in c("secs", "mins", "hours", "days", "weeks")) {
    expect_message(df |> time_pipe("time unit test", time_unit = u), regexp = u)
  }
})

test_that("time_pipe time is as expected", {
  f <- tempfile()
  data.frame(x = 1:3) |>
    time_pipe(
      "pre-sleep",
      time_unit = "secs",
      log_file = f,
      console = FALSE
    ) |>
    dplyr::mutate(result = Sys.sleep(0.5)) |>
    time_pipe(
      "post-sleep",
      time_unit = "secs",
      log_file = f,
      console = FALSE
    )
  log <- readLines(f)
  pre_time <- as.numeric(sub(
    ".*: (.*) secs",
    "\\1",
    log[grepl("pre-sleep", log)]
  ))
  post_time <- as.numeric(sub(
    ".*: (.*) secs",
    "\\1",
    log[grepl("post-sleep", log)]
  ))

  expect_true(post_time >= 0.5)
  expect_true(pre_time < 0.5)
  unlink(f)
})


test_that("time_pipe throws error if df is not character", {
  df_input <- data.frame(x = 1:3)
  expect_error(
    df_input |> time_pipe("test", df = data.frame()),
    regexp = "df must be a character string"
  )
})


test_that("time_pipe stores timings in a data frame", {
  data.frame(x = 1:3) |>
    dplyr::mutate(y = x * 2) |>
    time_pipe("step 1", console = FALSE, df = "temp_df") |>
    dplyr::mutate(z = y / 2) |>
    time_pipe("step 2", console = FALSE, df = "temp_df")

  expect_true(exists("temp_df", envir = .GlobalEnv))
  stored <- get("temp_df", envir = .GlobalEnv)
  expect_s3_class(stored, "data.frame")
  expect_equal(nrow(stored), 2)
  expect_equal(stored$label, c("step 1", "step 2"))
  expect_equal(stored$timestamp[[1]], stored$timestamp[[2]])
  rm(list = c("temp_df"), envir = .GlobalEnv)
})

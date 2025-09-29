test_that("time_pipe returns input unchanged", {
  df <- data.frame(x = 1:3)
  out <- df |> time_pipe("test", console = FALSE)
  expect_identical(out, df)
})

test_that("labels are generated correctly", {
  df <- data.frame(x = 1:3)
  expect_message(df |> time_pipe(), regexp = "df") # default label
  expect_message(df |> time_pipe("custom"), regexp = "custom") # custom label
})

test_that("invalid and valid units behave as expected", {
  df <- data.frame(x = 1:3)
  expect_error(df |> time_pipe("bad", unit = "microsec"))
  for (u in c("secs", "mins", "hours", "days", "weeks")) {
    expect_message(df |> time_pipe("ok", unit = u), regexp = u)
  }
})

test_that("log must be character", {
  df <- data.frame(x = 1:3)
  expect_error(df |> time_pipe("bad", log = data.frame()))
})

test_that("timings are stored in a log", {
  data.frame(x = 1:3) |>
    dplyr::mutate(y = x * 2) |>
    time_pipe("step1", console = FALSE, log = "log1") |>
    dplyr::mutate(z = y / 2) |>
    time_pipe("step2", console = FALSE, log = "log1")

  stored <- get_log("log1")
  expect_s3_class(stored, "data.frame")
  expect_equal(nrow(stored), 2)
  expect_equal(stored$label, c("step1", "step2"))

  rm_log("log1")
  expect_false(exists("log1", envir = .pipetime_env))
})

test_that("durations reflect elapsed time", {
  data.frame(x = 1:3) |>
    time_pipe("pre", unit = "secs", log = "log2", console = FALSE) |>
    dplyr::mutate(result = Sys.sleep(0.5)) |>
    time_pipe("post", unit = "secs", log = "log2", console = FALSE)

  times <- get_log("log2")
  expect_true(times$duration[2] >= 0.5)
  expect_true(times$duration[1] < 0.5)

  rm_log("log2")
})

test_that("multiple logs can be used independently", {
  df <- data.frame(x = 1:3)
  df |> time_pipe("a1", log = "loga", console = FALSE)
  df |> time_pipe("b1", log = "logb", console = FALSE)

  logs <- get_log(NULL) # all logs
  expect_named(logs, c("loga", "logb"))
  expect_equal(nrow(logs$loga), 1)
  expect_equal(nrow(logs$logb), 1)

  rm_log(NULL, force = TRUE) # clear all
  expect_length(get_log(NULL), 0)
})

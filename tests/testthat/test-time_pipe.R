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

test_that("invalid unit raises error", {
  df <- data.frame(x = 1:3)
  expect_error(
    df |> time_pipe("test", unit = "microsec"),
    regexp = "should be one of"
  )
})

test_that("different time units are accepted", {
  df <- data.frame(x = 1:3)
  for (u in c("secs", "mins", "hours", "days", "weeks")) {
    expect_message(df |> time_pipe("time unit test", unit = u), regexp = u)
  }
})

test_that("time_pipe throws error if log is not character", {
  df_input <- data.frame(x = 1:3)
  expect_error(
    df_input |> time_pipe("test", log = data.frame()),
    regexp = "'log' must be a character string"
  )
})

test_that("time_pipe stores timings in a data frame", {
  data.frame(x = 1:3) |>
    dplyr::mutate(y = x * 2) |>
    time_pipe("step 1", console = FALSE, log = "times") |>
    dplyr::mutate(z = y / 2) |>
    time_pipe("step 2", console = FALSE, log = "times")

  expect_true(exists("times", envir = .pipetime_env))

  # Load the stored data frame
  stored <- get_log("times")
  expect_s3_class(stored, "data.frame")
  expect_equal(nrow(stored), 2)
  expect_equal(stored$label, c("step 1", "step 2"))

  # Remove the stored data frame
  rm_log("times")
  expect_false(exists("times", envir = .pipetime_env))
})


test_that("time_pipe time is as expected", {
  data.frame(x = 1:3) |>
    time_pipe(
      "pre-sleep",
      unit = "secs",
      log = "times",
      console = FALSE
    ) |>
    dplyr::mutate(result = Sys.sleep(0.5)) |>
    time_pipe(
      "post-sleep",
      unit = "secs",
      log = "times",
      console = FALSE
    )
  times <- get_log("times")
  pre_time <- times$duration[1]
  post_time <- times$duration[2]

  expect_true(post_time >= 0.5)
  expect_true(pre_time < 0.5)
  rm_log("times")
})

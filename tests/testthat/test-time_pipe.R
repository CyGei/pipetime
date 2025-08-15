
test_that("time_pipe timing is similar to microbenchmark", {
  df <- data.frame(x = 1:20, group = rep(letters[1:2], each = 10))

  # Reference timing with microbenchmark (mean in seconds)
  mb <- microbenchmark::microbenchmark(
    {
      df |>
        dplyr::group_by(group) |>
        dplyr::mutate(sleep = Sys.sleep(1)) |>
        dplyr::ungroup() |>
        dplyr::summarise(mean_x = mean(x))
    },
    times = 1L,
    unit = "seconds"
  ) |> summary()

  # time_pipe
  pipe_file <- tempfile(fileext = ".log")
  df |>
    dplyr::group_by(group) |>
    dplyr::mutate(sleep = Sys.sleep(1)) |>
    dplyr::ungroup() |>
    dplyr::summarise(mean_x = mean(x)) |>
    time_pipe("summary", log_file = pipe_file, console = FALSE)

  pt <- as.numeric(sub(".*: ([0-9.]+) secs", "\\1", readLines(pipe_file)[1]))
  file.remove(pipe_file)

  expect_equal(mb$median, pt, tolerance = 0.25)
})



test_that("time_pipe step timing matches microbenchmark for each step", {
  df <- data.frame(x = 1:20, group = rep(letters[1:2], each = 10))

  #####################
  # group_by
  #####################
  mb <- microbenchmark::microbenchmark(
    { df |> dplyr::group_by(group) },
    times = 1L,
    unit = "seconds"
  ) |> summary()

  pipe_file <- tempfile(fileext = ".log")
  df |>
    dplyr::group_by(group) |>
    time_pipe("group_by", log_file = pipe_file, console = FALSE)

  pt <- as.numeric(sub(".*: ([0-9.]+) secs", "\\1", readLines(pipe_file)[1]))

  expect_equal(mb$median, pt, tolerance = 0.1)
  rm(list = c("mb", "pt"))

  # Step 2: mutate with sleep
  mb <- microbenchmark::microbenchmark(
    { df |> dplyr::group_by(group) |> dplyr::mutate(sleep = Sys.sleep(1)) },
    times = 1L,
    unit = "seconds"
  ) |> summary()

  pipe_file <- tempfile(fileext = ".log")
  df |>
    dplyr::group_by(group) |>
    dplyr::mutate(sleep = Sys.sleep(1)) |>
    time_pipe("mutate", log_file = pipe_file, console = FALSE)

  pt <- as.numeric(sub(".*: ([0-9.]+) secs", "\\1", readLines(pipe_file)[1]))
  file.remove(pipe_file)

  expect_equal(mb$median, pt, tolerance = 0.25)
})

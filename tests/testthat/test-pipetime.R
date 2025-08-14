
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
    times = 1L
  )
  ref_time <- mean(mb$time) / 1e9  # convert nanoseconds to seconds

  # time_pipe
  pipe_file <- tempfile(fileext = ".log")
  p <- df |>
    dplyr::group_by(group) |>
    dplyr::mutate(sleep = Sys.sleep(1)) |>
    dplyr::ungroup() |>
    dplyr::summarise(mean_x = mean(x)) |>
    time_pipe("summary", log_file = pipe_file, console = FALSE)

  pipe_lines <- readLines(pipe_file)
  pipe_val <- as.numeric(sub(".*: ([0-9.]+) secs elapsed ", "\\1", pipe_lines[1]))
  file.remove(pipe_file)

  expect_equal(ref_time, pipe_val, tolerance = 0.25)
})



test_that("time_pipe step timing matches microbenchmark for each step", {
  df <- data.frame(x = 1:20, group = rep(letters[1:2], each = 10))

  # Step 1: group_by
  mb_group <- microbenchmark::microbenchmark(
    { df |> dplyr::group_by(group) },
    times = 1L
  )
  ref_group <- mean(mb_group$time) / 1e9

  pipe_file <- tempfile(fileext = ".log")
  df |>
    dplyr::group_by(group) |>
    time_pipe("group_by", log_file = pipe_file, console = FALSE)

  step_lines <- readLines(pipe_file)
  pipe_group <- as.numeric(sub(".*: ([0-9.]+) secs elapsed ", "\\1", step_lines[1]))
  file.remove(pipe_file)

  expect_equal(ref_group, pipe_group, tolerance = 0.1)

  # Step 2: mutate with sleep
  mb_mutate <- microbenchmark::microbenchmark(
    { df |> dplyr::group_by(group) |> dplyr::mutate(sleep = Sys.sleep(1)) },
    times = 1L
  )
  ref_mutate <- mean(mb_mutate$time) / 1e9

  pipe_file <- tempfile(fileext = ".log")
  df |>
    dplyr::group_by(group) |>
    dplyr::mutate(sleep = Sys.sleep(1)) |>
    time_pipe("mutate", log_file = pipe_file, console = FALSE)

  step_lines <- readLines(pipe_file)
  pipe_mutate <- as.numeric(sub(".*: ([0-9.]+) secs elapsed ", "\\1", step_lines[1]))
  file.remove(pipe_file)

  expect_equal(ref_mutate, pipe_mutate, tolerance = 0.25)
})

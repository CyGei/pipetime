
# pipetime <img src="man/figures/logo.png" align="right" height="127"/>

The `pipetime` package lets you measure how long your pipeline (`|>`)
operations take. It works with the native R pipe and fits naturally into
**tidy workflows**.

# Installation

``` r
# devtools::install_github("CyGei/pipetime")
library(pipetime)
library(dplyr)
```

# Example

Place `time_pipe()` at any point in a pipeline to measure elapsed time
**from the start** up to that point:

``` r
data.frame(x = 1:3) |>
  mutate(sleep = Sys.sleep(0.1)) |> # e.g. a complex operation
  summarise(mean_x = mean(x)) |>
  time_pipe("total pipeline") # ~0.1 sec
#> [2025-08-15 16:09:10.884] total pipeline: 0.1103 secs
#>   mean_x
#> 1      2
```

- The timing includes all operations before `time_pipe()`.

- You can insert multiple `time_pipe()` calls to create **checkpoints**
  along the pipeline:

``` r
complex_fn <- function(duration,x) {
  Sys.sleep(duration)  # Simulate a time-consuming operation
  rnorm(n = length(x), mean = x, sd = 1)
}

data.frame(x = 1:5) |> 
  dplyr::mutate(y = complex_fn(0.5, x)) |>
  time_pipe("compute y") |> 
  dplyr::mutate(z = complex_fn(0.5, y)) |> 
  time_pipe("compute z") |>
  dplyr::summarise(mean_z = mean(z)) |>
  time_pipe("total pipeline")
#> [2025-08-15 16:09:11.011] compute y: 0.5145 secs
#> [2025-08-15 16:09:11.011] compute z: 1.0311 secs
#> [2025-08-15 16:09:11.011] total pipeline: 1.0337 secs
#>     mean_z
#> 1 3.358939
```

- Each `time_pipe()` reports the cumulative time since the start of the
  pipeline.

# Logging to a File

You can save timing logs to a file using the `log_file` argument:

``` r
log <- tempfile(fileext = ".log")

df <- data.frame(x = 1:5) |> 
  dplyr::mutate(y = complex_fn(0.1, x)) |>
  time_pipe("compute y", log_file = log, console = FALSE ) |> 
  dplyr::mutate(z = complex_fn(0.1, y)) |> 
  time_pipe("compute z", log_file = log, console = FALSE) |>
  dplyr::summarise(mean_z = mean(z)) |>
  time_pipe("total pipeline",log_file = log, console = FALSE)

readLines(log)
#> [1] "[2025-08-15 16:09:12.064] compute y: 0.1111 secs "     
#> [2] "[2025-08-15 16:09:12.064] compute z: 0.2218 secs "     
#> [3] "[2025-08-15 16:09:12.064] total pipeline: 0.2235 secs "
```

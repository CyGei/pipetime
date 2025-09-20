
# pipetime <img src="man/figures/logo.png" align="right" height="127"/>

<!-- badges: start -->

[![R-CMD-check](https://github.com/CyGei/pipetime/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/CyGei/pipetime/actions/workflows/R-CMD-check.yaml)
[![CodeFactor](https://www.codefactor.io/repository/github/cygei/pipetime/badge)](https://www.codefactor.io/repository/github/cygei/pipetime)
<!-- badges: end -->

`pipetime` measures the runtime of your pipeline operations. It works
with the native R pipe (`|>`) and fits naturally into ‘*tidy
workflows*’.

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
#> [2025-09-20 15:57:03.973] total pipeline: 0.1092 secs
#>   mean_x
#> 1      2
```

- The timing includes all operations before `time_pipe()`.

- You can insert multiple `time_pipe()` calls to add **checkpoints**
  along the pipeline:

``` r
complex_fn <- function(duration,x) {
  Sys.sleep(duration)  # Simulate a time-consuming operation
  rnorm(n = length(x), mean = x, sd = 1)
}

data.frame(x = 1:5) |> 
  mutate(y = complex_fn(0.5, x)) |>
  time_pipe("compute y") |> 
  mutate(z = complex_fn(0.5, y)) |> 
  time_pipe("compute z") |>
  summarise(mean_z = mean(z)) |>
  time_pipe("total pipeline")
#> [2025-09-20 15:57:04.090] compute y: 0.5069 secs
#> [2025-09-20 15:57:04.090] compute z: 1.0118 secs
#> [2025-09-20 15:57:04.090] total pipeline: 1.0142 secs
#>     mean_z
#> 1 3.134429
```

- Each `time_pipe()` reports the cumulative time since the start of the
  pipeline.

# Logging to a dataframe

You can save timing logs to a dataframe using the `df` argument. Provide
`df` as a character string naming the dataframe. Each time `time_pipe()`
is called, the dataframe in your `.GlobalEnv` will be created (if
needed) and updated with a new row.

``` r
df_1 <- data.frame(x = 1:5) |> 
  mutate(y = complex_fn(0.5, x)) |>
  time_pipe("compute y", df = "log_df")
#> [2025-09-20 15:57:05.113] compute y: 0.5072 secs

df_2 <- df_1 |> 
  mutate(z = complex_fn(0.5, y)) |>
  time_pipe("compute z", df = "log_df")
#> [2025-09-20 15:57:05.625] compute z: 0.5064 secs

log_df
#>                 timestamp     label duration time_unit
#> 1 2025-09-20 15:57:05.113 compute y   0.5072      secs
#> 2 2025-09-20 15:57:05.625 compute z   0.5064      secs
```

Alternatively, you can set a global default for the session using
`options()`: `options(pipetime.df = "log_df")`. Then you can omit the
`df` argument in `time_pipe()` calls.

# Logging to a file

You can save timing logs to a file using the `log_file` argument. For
simplicity, you can set a global default for the session using
`options()`:

``` r
options(pipetime.log_file = "pipetime.log")
df <- data.frame(x = 1:5) |> 
  mutate(y = complex_fn(0.1, x)) |>
  time_pipe("compute y",console = FALSE ) |> 
  mutate(z = complex_fn(0.1, y)) |> 
  time_pipe("compute z",console = FALSE) |>
  summarise(mean_z = mean(z)) |>
  time_pipe("total pipeline",console = FALSE)
```

All timing messages will then be logged to `pipetime.log` in the working
directory.

``` r
readLines("pipetime.log")
```

    #> [1] "[2025-09-20 15:57:06.148] compute y: 0.1073 secs"     
    #> [2] "[2025-09-20 15:57:06.148] compute z: 0.2165 secs"     
    #> [3] "[2025-09-20 15:57:06.148] total pipeline: 0.2199 secs"

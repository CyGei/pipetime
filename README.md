
# pipetime <img src="man/figures/logo.png" align="right" height="136" alt="" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/CyGei/pipetime/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/CyGei/pipetime/actions/workflows/R-CMD-check.yaml)
[![CodeFactor](https://www.codefactor.io/repository/github/cygei/pipetime/badge)](https://www.codefactor.io/repository/github/cygei/pipetime)
[![Codecov test
coverage](https://codecov.io/gh/CyGei/pipetime/graph/badge.svg)](https://app.codecov.io/gh/CyGei/pipetime)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

⏳ `pipetime` measures elapsed time in R pipelines.

Insert `time_pipe()` anywhere in a pipeline to print or log the time
since the pipeline started. It works with the native R pipe (`|>`) and
fits naturally into [tidyverse](https://www.tidyverse.org/) workflows.

# Installation

Install from GitHub and load alongside `dplyr` for examples:

``` r
# devtools::install_github("CyGei/pipetime")
library(pipetime)
library(dplyr)
```

# Example

Place `time_pipe()` at the end of a pipeline to measure total elapsed
time:

``` r
slow_op <- function(delay, x) {
  Sys.sleep(delay)  # Simulate a time-consuming operation
  rnorm(n = length(x), mean = x, sd = 1)
}

data.frame(x = 1:3) |>
  mutate(sleep = slow_op(0.1, x)) |>
  summarise(mean_x = mean(x)) |>
  time_pipe("total pipeline") # ~+0.1 sec
#> [2025-10-07 20:30:09.774] total pipeline: +0.1098 secs
#>   mean_x
#> 1      2
```

Use multiple `time_pipe()` calls to mark steps along a pipeline:

``` r
data.frame(x = 1:5) |> 
  mutate(y = slow_op(0.5, x)) |>
  time_pipe("compute y") |> 
  mutate(z = slow_op(0.5, y)) |> 
  time_pipe("compute z") |>
  summarise(mean_z = mean(z)) |>
  time_pipe("total pipeline")
#> [2025-10-07 20:30:09.893] compute y: +0.5068 secs
#> [2025-10-07 20:30:09.893] compute z: +1.0175 secs
#> [2025-10-07 20:30:09.893] total pipeline: +1.0191 secs
#>     mean_z
#> 1 3.250673
```

⏱️ **Each `time_pipe()` reports the cumulative time since the pipeline
started.**

# Logging

📝 Use `log` to save timings to a hidden environment (`.pipetime_env`):

``` r
df <- data.frame(x = 1:5) |> 
  mutate(y = slow_op(0.5, x)) |>
  time_pipe("compute y", log = "timings") |>
  mutate(z = slow_op(0.5, y)) |>
  time_pipe("compute z", log = "timings")
#> [2025-10-07 20:30:10.918] compute y: +0.5067 secs
#> [2025-10-07 20:30:10.918] compute z: +1.0141 secs

get_log("timings")
#>             timestamp     label duration unit
#> 1 2025-10-07 20:30:10 compute y 0.506748 secs
#> 2 2025-10-07 20:30:10 compute z 1.014136 secs
rm_log("timings") #delete the dataframe in .pipetime_env
```

## Managing logs

- `get_log("name")` → return one log

- `get_log(NULL)` → return all logs as a named list

- `rm_log("name")` → remove one log

- `rm_log(NULL, force = TRUE)` → remove all logs

# Options

You can also set **session‑wide** defaults:

``` r
options(pipetime.log = "timings",
        pipetime.console = TRUE,
        pipetime.unit = "secs")
```

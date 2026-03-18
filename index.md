# pipetime

⏳ `pipetime` measures elapsed time in R pipelines.

Insert
[`time_pipe()`](https://cygei.github.io/pipetime/reference/time_pipe.md)
anywhere in a pipeline to print or log the time since the pipeline
started. It works with the native R pipe (`|>`) and fits naturally into
[tidyverse](https://www.tidyverse.org/) workflows.

# Installation

Install **pipetime** from CRAN:

``` r
install.packages("pipetime")
library(pipetime)
```

Or install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("CyGei/pipetime")
```

# Example

Place
[`time_pipe()`](https://cygei.github.io/pipetime/reference/time_pipe.md)
at the end of a pipeline to measure total elapsed time:

``` r
library(dplyr)

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

Use multiple
[`time_pipe()`](https://cygei.github.io/pipetime/reference/time_pipe.md)
calls to mark steps along a pipeline:

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

⏱️ **Each
[`time_pipe()`](https://cygei.github.io/pipetime/reference/time_pipe.md)
reports the cumulative time since the pipeline started.**

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

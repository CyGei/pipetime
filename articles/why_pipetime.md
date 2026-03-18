# Why pipetime?

``` r
library(pipetime)
library(dplyr)
```

R pipelines (`|>`) allow chaining operations in a readable, sequential
way. Existing timing tools
(e.g. [`system.time()`](https://rdrr.io/r/base/system.time.html),
`tictoc`) do not integrate naturally with pipelines and tidy workflows.
`pipetime` solves this by letting you measure time inline, without
interrupting the pipeline.

## Examples

``` r
slow_op <- function(x) {
  Sys.sleep(0.1)  # Simulate a time-consuming operation
  x^2
}
```

### `system.time()`

``` r
# Must wrap the entire pipeline, breaking the flow
the_time <- system.time({
  df <- data.frame(x = 1:3) |>
    mutate(y = slow_op(x)) |>
    summarise(mean_y = mean(y))
})
the_time
#>    user  system elapsed 
#>   0.009   0.000   0.110
df
#>     mean_y
#> 1 4.666667

# system.time() cannot be inserted inline in a pipeline:
data.frame(x = 1:3) |>
  mutate(y = slow_op(x)) |>
  # system.time() would break the pipeline here
  summarise(mean_y = mean(y))
#>     mean_y
#> 1 4.666667
```

### `tictoc`

``` r
library(tictoc)

# Requires manual start/stop
tic("total pipeline")
df <- data.frame(x = 1:3) |>
  mutate(y = slow_op(x)) |>
  summarise(mean_y = mean(y))
toc()
#> total pipeline: 0.104 sec elapsed
df
#>     mean_y
#> 1 4.666667
```

### `time_pipe`

``` r
# Inline timing checkpoints, pipeline stays intact
data.frame(x = 1:3) |>
  mutate(y = slow_op(x)) |>
  time_pipe("after mutate") |>
  summarise(mean_y = mean(y)) |>
  time_pipe("total pipeline")
#> [2026-03-18 14:34:46.331] after mutate: +0.1018 secs
#> [2026-03-18 14:34:46.331] total pipeline: +0.1082 secs
#>     mean_y
#> 1 4.666667
```

## Why `pipetime`?

- Works directly inside pipelines.

- Supports multiple checkpoints.

- Prints or logs timings in `.pipetime_env` (see
  [`?get_log`](https://cygei.github.io/pipetime/reference/get_log.md)).

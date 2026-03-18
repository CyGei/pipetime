# Measure execution time in a pipeline

Records the runtime of a pipeline (`|>`) from its start to the point
where `time_pipe()` is called. Prints results to the console and/or logs
them in `.pipetime_env`. Defaults can be set via `options(pipetime.*)`.

## Usage

``` r
time_pipe(
  .data,
  label = NULL,
  log = getOption("pipetime.log", NULL),
  console = getOption("pipetime.console", TRUE),
  unit = getOption("pipetime.unit", "secs")
)
```

## Arguments

- .data:

  Input object passed through the pipeline.

- label:

  Character string. Operation name. Defaults to the expression if
  `NULL`.

- log:

  Character string or `NULL`. Name of a log data frame in
  `.pipetime_env`. Default: `NULL`.

- console:

  Logical. Print timing to console? Default: `TRUE`.

- unit:

  Character string. Time unit for
  [`base::difftime()`](https://rdrr.io/r/base/difftime.html). One of
  `"secs"`, `"mins"`, `"hours"`, `"days"`, `"weeks"`. Default: `"secs"`.

## Value

`.data`, unchanged. Timing information is printed and/or stored
separately.

## Details

`time_pipe()` measures elapsed time from pipeline start to the call. If
`log` is set, results are appended to a data frame in `.pipetime_env`
with columns:

- `timestamp`: Pipeline start time (`POSIXct`)

- `label`: Operation label

- `duration`: Elapsed time since pipeline start (`numeric`)

- `unit`: Time unit used

Stored logs can be retrieved with
[`get_log()`](https://cygei.github.io/pipetime/reference/get_log.md).

## Examples

``` r
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
data.frame(x = 1:3) |>
mutate(y = {Sys.sleep(0.5); x*2 }) |>
time_pipe("calc 1") |>
mutate(z = {Sys.sleep(0.5); x/2 }) |>
time_pipe("total pipeline")
#> [2026-03-18 14:34:36.133] calc 1: +0.5065 secs
#> [2026-03-18 14:34:36.133] total pipeline: +1.0137 secs
#>   x y   z
#> 1 1 2 0.5
#> 2 2 4 1.0
#> 3 3 6 1.5
```

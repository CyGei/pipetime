
# pipetime <img src="man/figures/logo.png" align="right" height="127" alt="" />

The `pipetime` package lets you measure how long your pipeline (`|>`)
operations take. It works with the native R pipe and fits naturally into
**tidy workflows**.

You can use `time_pipe()` in two ways:

1.  **Time a single step:** wrap `time_pipe()` around a specific `dplyr`
    operation. Only that step is measured.

2.  **Time a whole pipeline up to a point:** place `time_pipe()` at the
    end of a pipeline. It will report the total time for all steps up to
    that point.

Timing messages can be printed to the console or saved to a file.

``` r
# devtools::install_github("CyGei/pipetime")
library(pipetime)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

# Timing a Single Step

Wrap `time_pipe()` around a specific operation:

``` r
data.frame(x = 1:6) |>
  time_pipe(mutate(y = {Sys.sleep(0.2); rnorm(n(), mean = x)}), "random draw") |>
  mutate(y2 = y^2) |>
  summarise(avg_y = mean(y))
#> [2025-08-14 20:07:12.871] random draw: 0.2080 secs elapsed
#>      avg_y
#> 1 3.618334
```

Only the `mutate(y = …)` step is timed.

# Timing a Whole Pipeline

Place `time_pipe()` on the data at the end (or after multiple steps):

``` r
data.frame(x = 1:6) |>
  mutate(y = {Sys.sleep(0.2); rnorm(n(), mean = x)}) |> 
  mutate(z = {Sys.sleep(0.2); rnorm(n(), mean = x^2)}) |> 
  summarise(avg_y = mean(y),
            avg_z = mean(z)) |>
  time_pipe("total pipeline time")
#> [2025-08-14 20:07:13.097] total pipeline time: 0.4279 secs elapsed
#>      avg_y    avg_z
#> 1 4.194857 15.51165
```

Here, the timing includes **all previous operations** in the pipeline,
giving the total time.

You can place `time_pipe()` at several points in a pipeline to
**cumulatively measure total time up to each point**. Each `time_pipe()`
marks a checkpoint and records the elapsed time for all operations since
the start of the pipeline:

``` r
data.frame(x = 1) |> 
  # Step 1: small operation
  mutate(a = { Sys.sleep(1); 1}) |> 
  time_pipe("Step 1") |>   # ~1 sec
  
  # Step 2: multiple operations
  mutate(b = { Sys.sleep(1); 1},
         c = { Sys.sleep(1); 1}) |> 
  time_pipe("Step 2") |>   # ~3 sec
  
  # Step 3: final summarise
  summarise(total = sum(a + b + c),
            pause = {Sys.sleep(1); 1}) |> 
  time_pipe("Total Pipeline")  # ~4 sec
#> [2025-08-14 20:07:13.537] Step 1: 1.0132 secs elapsed
#> [2025-08-14 20:07:13.537] Step 2: 3.0460 secs elapsed
#> [2025-08-14 20:07:13.537] Total Pipeline: 4.0619 secs elapsed
#>   total pause
#> 1     3     1
```

# Logging to a File

You can save timing logs to a file using the `log_file` argument:

``` r
log_file <- tempfile(fileext = ".log")

df <- mtcars |>
  mutate(hp2 = {Sys.sleep(0.1); hp * 2}) |>
  time_pipe("Step 1", log_file = log_file, console = FALSE) |>
  mutate(hp3 = {Sys.sleep(0.1); hp * 3}) |>
  time_pipe("Step 2", log_file = log_file, console = FALSE)

# View log
cat(readLines(log_file), sep = "\n")
#> [2025-08-14 20:07:17.618] Step 1: 0.1087 secs elapsed 
#> [2025-08-14 20:07:17.618] Step 2: 0.2219 secs elapsed
```

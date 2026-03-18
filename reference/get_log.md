# Retrieve a timing log (or all logs)

Return a stored timing log from `.pipetime_env`. If `log = NULL`, return
all logs as a named list.

## Usage

``` r
get_log(log = NULL)
```

## Arguments

- log:

  Character string or `NULL`. Name of the log to retrieve. If `NULL`,
  all logs are returned.

## Value

Either:

- A data frame with columns:

  - `timestamp` (`POSIXct`): Pipeline start time

  - `label` (`character`): Operation label

  - `duration` (`numeric`): Elapsed time since pipeline start

  - `unit` (`character`): Time unit used

- Or, if `log = NULL`, a named list of such data frames.

## See also

[`rm_log()`](https://cygei.github.io/pipetime/reference/rm_log.md)

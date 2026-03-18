# Remove a timing log (or all logs)

Delete a timing log from `.pipetime_env`. If `log = NULL`, all logs are
removed, but only when `force = TRUE`.

## Usage

``` r
rm_log(log = NULL, force = FALSE)
```

## Arguments

- log:

  Character string or `NULL`. Name of the log to remove. If `NULL`, all
  logs are targeted.

- force:

  Logical. To remove all logs, `force` must be `TRUE`. Default: `FALSE`.

## Value

Invisibly, `TRUE`.

## See also

[`get_log()`](https://cygei.github.io/pipetime/reference/get_log.md)

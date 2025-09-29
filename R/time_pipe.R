#' Measure execution time in a pipeline
#'
#' Records the runtime of a pipeline (`|>`) from its start to the point where `time_pipe()` is called.
#' Prints results to the console and/or logs them in `.pipetime_env`.
#' Defaults can be set via `options(pipetime.*)`.
#'
#' @param .data Input object passed through the pipeline.
#' @param label Character string. Operation name. Defaults to the expression if `NULL`.
#' @param log Character string or `NULL`. Name of a log data frame in `.pipetime_env`. Default: `NULL`.
#' @param console Logical. Print timing to console? Default: `TRUE`.
#' @param unit Character string. Time unit for [base::difftime()]. One of `"secs"`, `"mins"`, `"hours"`, `"days"`, `"weeks"`. Default: `"secs"`.
#'
#' @return `.data`, unchanged. Timing information is printed and/or stored separately.
#'
#' @details
#' `time_pipe()` measures elapsed time from pipeline start to the call.
#' If `log` is set, results are appended to a data frame in `.pipetime_env` with columns:
#' - `timestamp`: Pipeline start time (`POSIXct`)
#' - `label`: Operation label
#' - `duration`: Elapsed time since pipeline start (`numeric`)
#' - `unit`: Time unit used
#'
#' Stored logs can be retrieved with [get_log()].
#'
#' @examples
#' library(dplyr)
#' data.frame(x = 1:3) |>
#' mutate(y = {Sys.sleep(0.5); x*2 }) |>
#' time_pipe("calc 1") |>
#' mutate(z = {Sys.sleep(0.5); x/2 }) |>
#' time_pipe("total pipeline")
#'
#' @export
time_pipe <- function(
  .data,
  label = NULL,
  log = getOption("pipetime.log", NULL),
  console = getOption("pipetime.console", TRUE),
  unit = getOption("pipetime.unit", "secs")
) {
  # Track pipeline start
  if (!is.null(log)) {
    if (is.null(.pipetime_env$start_times[[log]])) {
      .pipetime_env$start_times[[log]] <- Sys.time()
      on.exit(.pipetime_env$start_times[[log]] <- NULL, add = TRUE)
    }
    start_time <- .pipetime_env$start_times[[log]]
  } else {
    start_time <- Sys.time()
  }

  # Force evaluation and calculate duration
  result <- .data
  end_time <- Sys.time()
  duration <- as.numeric(difftime(end_time, start_time, units = unit))

  # Generate label if not provided
  if (is.null(label)) {
    label <- paste(deparse(substitute(.data)), collapse = "")
    label <- gsub("\\s+", " ", trimws(label))
  }

  # Output results
  emit_time(start_time, duration, label, unit, console, log)

  result
}

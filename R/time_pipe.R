#' Measure execution time in a pipeline
#'
#' Records the runtime of a pipeline (|>) operation.
#' Can print the timing to the console, log it to a file, and/or save results
#' into a data frame for later use. Arguments can also be set globally via options().
#'
#' @param .data The input object passed through the pipeline.
#' @param label Optional. Name for the operation. Defaults to the expression if not provided.
#' @param df Optional. Name of a data frame in which to store timing results. Defaults to NULL (no storage).
#' @param log_file Optional. File path to append timing logs. Defaults to NULL (no logging).
#' @param console Logical. Print messages to the console? Defaults to TRUE.
#' @param time_unit Character. Unit of time. Must be one of "secs", "mins", "hours", "days", or "weeks".
#' Passed directly to [base::difftime()]. Defaults to "secs".
#'
#' @return The input object, unchanged. Timing is printed, logged, or stored separately.
#'
#' @details
#' `time_pipe()` measures the elapsed time of the operation from the start of the pipeline to the point where `time_pipe()` is called.
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
#'
time_pipe <- function(
  .data,
  label = NULL,
  df = getOption("pipetime.df", NULL),
  log_file = getOption("pipetime.log_file", NULL),
  console = getOption("pipetime.console", TRUE),
  time_unit = getOption("pipetime.time_unit", "secs")
) {
  time_unit <- match.arg(
    time_unit,
    choices = c("secs", "mins", "hours", "days", "weeks")
  )

  start <- Sys.time()
  result <- .data
  end <- Sys.time()

  if (is.null(label)) {
    expr <- substitute(.data)
    label <- gsub("\\s+", "", paste(deparse(expr), collapse = ""))
  }

  emit(start, end, label, time_unit, console, log_file, df)

  result
}

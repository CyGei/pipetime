#' Measure execution time in a pipeline
#'
#' Record the runtime of a pipeline (|>) operation. Can print to the console
#' or log to a file. Arguments can also be set globally via options().
#'
#' @param .data The input object to pass through the pipeline.
#' @param label Optional. Name for the operation. Defaults to the expression if not provided.
#' @param log_file Optional. File to write timing logs. Defaults to NULL (no logging).
#' @param console Logical. Print messages to the console? Defaults to TRUE.
#' @param time_unit Character. Unit of time. Must be one of "secs", "mins", "hours", "days", or "weeks".
#' Passed directly to [base::difftime()]. Defaults to "secs".
#'
#' @return The input object, unchanged. Timing messages are printed or logged separately.
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
time_pipe <- function(.data,
                      label = NULL,
                      log_file = getOption("pipetime.log_file", NULL),
                      console = getOption("pipetime.console", TRUE),
                      time_unit = getOption("pipetime.time_unit", "secs")) {

  time_unit <- match.arg(time_unit, choices = c("secs", "mins", "hours", "days", "weeks"))

  start <- Sys.time()
  result <- .data
  end <- Sys.time()

  if (is.null(label)) {
    expr <- substitute(.data)
    label <- gsub("\\s+", "", paste(deparse(expr), collapse = ""))
  }

  emit(start, end, label, time_unit, console, log_file)

  result
}

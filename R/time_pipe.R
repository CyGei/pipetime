#' Measure execution time in a pipeline
#'
#' Record how long a step in a pipeline (`|>`) takes.
#' Can print to the console or log to a file.
#'
#' @param .data The input object to pass through the pipeline.
#' @param label Optional. Name for the operation. Defaults to the expression if not provided.
#' @param log_file Optional. File to write timing logs.
#'   A global default can be set with `options(pipetime.log_file = "filename.log")`.
#' @param console Logical. Print messages to the console? Default `TRUE`.
#' @param time_unit Character. Unit of time: `"secs"`, `"millisecs"`, `"mins"`, or `"hours"`. Default to `"secs"`.
#'
#' @return The input object, unchanged. Timing messages are printed or logged separately.
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
                      log_file = NULL,
                      console = TRUE,
                      time_unit = c("secs", "millisecs", "mins", "hours")) {

  # Check if user has provided a log file option
  if (is.null(log_file)) {
    log_file <- getOption("pipetime.log_file", NULL)
  }


  time_unit <- match.arg(time_unit)

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

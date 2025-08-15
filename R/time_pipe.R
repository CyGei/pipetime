#' Time operations in a pipeline
#' Measure how long a data operation or function takes within a pipeline (`|>`).
#' This can be used to check performance of steps in your data workflow.
#'
#' @param .data A data object to pass through the pipeline.
#' @param label Optional. A descriptive name for the operation. If not provided, the expression will be passed.
#' @param log_file Optional. File path to write timing logs. If `NULL`, messages are only printed to the console.
#' @param console Logical. Whether to print timing messages to the console. Default is `TRUE`.
#' @param time_unit Character. Unit of time to report. One of `"secs"`, `"millisecs"`, `"mins"` or `"hours"`.
#'
#' @return Returns the result of the pipeline step, unchanged. Timing messages are printed or logged separately.
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

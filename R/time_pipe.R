#' Measure execution time in a pipeline
#'
#' Records the runtime of pipeline (|>) operation.
#' Can print the timing to the console and optionally log it to a data frame in `.pipetime_env`.
#' Defaults can be set via `options()`.
#'
#' @param .data Input object passed through the pipeline.
#' @param label Optional. Name for the operation. Defaults to the expression if not provided.
#' @param log Character or NULL. Name of a data frame to store logs in `.pipetime_env`. Defaults to NULL (no storage).
#' @param console Logical. Print timing to the console? Defaults to TRUE.
#' @param unit Character. Time unit passed to [base::difftime()]. One of `"secs"`, `"mins"`, `"hours"`, `"days"`, or `"weeks"`. Defaults to `"secs"`.
#'
#' @return The input object, unchanged. Timing information is printed or stored separately.
#'
#' @details
#' `time_pipe()` measures the elapsed time of the pipeline from its start to the point where `time_pipe()` is called.
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
  log = getOption("pipetime.log", NULL),
  console = getOption("pipetime.console", TRUE),
  unit = getOption("pipetime.unit", "secs")
) {
  unit <- match.arg(
    unit,
    choices = c("secs", "mins", "hours", "days", "weeks")
  )

  start <- Sys.time()
  result <- .data
  end <- Sys.time()

  if (is.null(label)) {
    expr <- substitute(.data)
    label <- gsub("\\s+", "", paste(deparse(expr), collapse = ""))
  }

  emit(start, end, label, unit, console, log)

  result
}

#' Time operations in a pipeline
#' Measure how long a data operation or function takes within a pipeline (`|>`).
#' This can be used to check performance of steps in your data workflow.
#'
#' @param .data A data object to pass through the pipeline.
#' @param action Optional. A function call to apply to `.data`. If not provided, the function will time `.data` itself.
#' @param label Optional. A descriptive name for the operation. If not provided, a name will be generated automatically.
#' @param log_file Optional. File path to write timing logs. If `NULL`, messages are only printed to the console.
#' @param console Logical. Whether to print timing messages to the console. Default is `TRUE`.
#' @param time_unit Character. Unit of time to report. One of `"secs"`, `"millisecs"`, or `"mins"`.
#'
#' @return Returns the result of the pipeline step, unchanged. Timing messages are printed or logged separately.
#' @examples
#' library(dplyr)
#' mtcars |>
#'   pipetime(group_by(cyl), "grouping") |>
#'   pipetime(summarise(avg_hp = mean(hp)), "aggregation")
#'
#' mtcars |>
#'   mutate(hp2 = {
#'     Sys.sleep(1)
#'     hp * 2
#'   }) |>
#'   pipetime("entire pipeline")
#'
#' @export
#'
pipetime <- function(.data,
                     action = NULL,
                     label = NULL,
                     log_file = NULL,
                     console = TRUE,
                     time_unit = c("secs", "millisecs", "mins")) {
  time_unit <- match.arg(time_unit)

  # Capture the unevaluated expressions
  action_expr <- substitute(action)
  data_expr   <- substitute(.data)

  # --- Dispatch to appropriate case ---
  if (!missing(action) && is.call(action_expr)) {
    # Case 1: action is a call -> apply it to .data
    time_action_call(
      data = .data,
      action_expr = action_expr,
      label = label,
      time_unit = time_unit,
      console = console,
      log_file = log_file
    )
  } else {
    # Case 2: action is not a call -> time the evaluation of .data or just use label
    time_data_eval(
      data = .data,
      data_expr = data_expr,
      label = label,
      action = action,
      time_unit = time_unit,
      console = console,
      log_file = log_file
    )
  }
}

#' Time the evaluation of a data object
#'
#' This helper measures how long it takes to evaluate a data object (or expression)
#' when no function call is provided.
#' Used internally by `time_pipe()`.
#'
#' @param data The data object.
#' @param data_expr The unevaluated data expression.
#' @param label Optional descriptive name for the operation.
#' @param action Optional label provided by the user.
#' @param time_unit The unit of time to report: `"secs"`, `"millisecs"`, or `"mins"`.
#' @param console Logical. Whether to print timing messages to the console.
#' @param log_file Optional file path to save timing logs.
#'
#' @return The evaluated data object. Timing messages are printed or logged separately.
#' @keywords internal
#'
time_data_eval <- function(data, data_expr, label, action, time_unit, console, log_file) {
  if (is.null(label)) {
    if (!missing(action) && is.character(action)) {
      label <- action
    } else {
      label <- clean_label(data_expr)
    }
  }

  start <- Sys.time()
  result <- if (!is.symbol(data_expr) && !is.call(data_expr)) {
    data
  } else {
    tryCatch(eval(data_expr, envir = parent.frame()), error = function(e) data)
  }
  end <- Sys.time()

  emit(start, end, label, time_unit, console, log_file)
  result
}

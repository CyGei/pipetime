#' Time a function call applied to data
#'
#' This helper evaluates a function call on a data object and measures how long it takes.
#' Used internally by `time_pipe()`.
#'
#' @param data The data object to pass as the first argument to the function.
#' @param action_expr The function call to execute on the data.
#' @param label A descriptive name for the operation. If `NULL`, a label will be generated automatically.
#' @param time_unit The unit of time to report: `"secs"`, `"millisecs"`, or `"mins"`.
#' @param console Logical. Whether to print timing messages to the console.
#' @param log_file Optional file path to save timing logs.
#'
#' @return The result of evaluating the function call on `data`.
#' @keywords internal
time_action_call <- function(data, action_expr, label, time_unit, console, log_file) {
  if (is.null(label)) label <- clean_label(action_expr)
  fn <- action_expr[[1]]
  args <- as.list(action_expr)[-1]
  call_to_eval <- as.call(c(list(fn, data), args))

  start <- Sys.time()
  result <- eval(call_to_eval, envir = parent.frame())
  end <- Sys.time()

  emit(start, end, label, time_unit, console, log_file)
  result
}

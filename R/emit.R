#' Emit a timing message
#'
#' Logs or prints the execution duration of an operation.
#'
#' @param start A `POSIXct` object indicating the start time.
#' @param end A `POSIXct` object indicating the end time.
#' @param label Character string to describe the operation being timed.
#' @param time_unit Character; the unit in which to report the duration.
#' @param console Logical; whether to print the message to the console.
#' @param log_file Optional character path to a file to append the message.
#'
#' @return Invisibly returns the duration of the operation.
#' @keywords internal
emit <- function(start, end, label, time_unit, console = TRUE, log_file = NULL) {
  duration <- format_duration(start, end, time_unit)
  msg <- sprintf("[%s] %s: %.4f %s elapsed",
                 format(start, "%Y-%m-%d %H:%M:%OS3"),
                 label,
                 duration,
                 time_unit)
  if (console) message(msg)
  if (!is.null(log_file)) cat(msg, "\n", file = log_file, append = TRUE)
  invisible(duration)
}

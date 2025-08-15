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
#' @importFrom crayon blue green
#' @keywords internal
emit <- function(start, end, label, time_unit, console = TRUE, log_file = NULL) {

  duration <- as.numeric(difftime(end, start, units = time_unit))
  duration <- format(round(duration, 4), nsmall = 4)
  timestamp <- format(start, "%Y-%m-%d %H:%M:%OS3")

  build_msg <- function(timestamp, label, duration, time_unit) {
    paste0("[", timestamp, "] ", label, ": ", duration, " ", time_unit)
  }

  if (console) {
    console_msg <- build_msg(
      timestamp,
      crayon::blue(label),
      crayon::green(duration),
      crayon::green(time_unit)
    )
    message(console_msg)
  }

  if (!is.null(log_file)) {
    log_msg <- build_msg(
      timestamp,
      label,
      duration,
      time_unit
    )

    cat(log_msg, "\n", file = log_file, append = TRUE)
  }

  invisible(duration)
}

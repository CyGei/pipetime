#' Emit a timing message
#'
#' Logs or prints the execution duration of an operation.
#'
#' @param start A `POSIXct` object indicating the start time.
#' @param end A `POSIXct` object indicating the end time.
#' @param label Character string to describe the operation being timed.
#' @param time_unit Character; the unit in which to report the duration.
#' @param console Logical; whether to print the message to the console.
#' @param log_file Character; path to a file to append the message.
#'
#' @return Invisibly returns the duration of the operation.
#' @keywords internal
#' @noRd
emit <- function(start,
                 end,
                 label,
                 time_unit,
                 console,
                 log_file) {
  duration <- as.numeric(difftime(end, start, units = time_unit))
  duration <- sprintf("%.4f", duration)
  timestamp <- format(start, "%Y-%m-%d %H:%M:%OS3")

  build_msg <- function(timestamp, label, duration, time_unit) {
    paste0("[", timestamp, "] ", label, ": ", duration, " ", time_unit)
  }

  # Console message
  if (isTRUE(console)) {
    if (requireNamespace("crayon", quietly = TRUE)) {
      console_msg <- build_msg(
        timestamp,
        crayon::blue(label),
        crayon::green(duration),
        crayon::green(time_unit)
      )
    } else {
      console_msg <- build_msg(timestamp, label, duration, time_unit)
    }
    message(console_msg)
  }

  # Log file message
  if (!is.null(log_file)) {
    log_msg <- build_msg(timestamp, label, duration, time_unit)
    tryCatch(
      write(log_msg, file = log_file, append = TRUE),
      error = function(e)
        warning("Could not write to log file: ", log_file)
    )
  }

  invisible(duration)
}

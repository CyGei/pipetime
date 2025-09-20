#' Emit a timing message
#'
#' Logs, prints, or saves the execution time of an operation.
#'
#' @param start POSIXct. Start time of the operation.
#' @param end POSIXct. End time of the operation.
#' @param label Character or NULL. Name of the operation being timed.
#' @param time_unit Character. Unit to report duration ("secs", "mins", "hours", "days", or "weeks").
#' @param console Logical. Print timing to the console?
#' @param log_file Character or NULL. File path to append timing logs.
#' @param df Character or NULL. Name of a data frame to store timing results.
#'
#' @return Invisibly returns the duration of the operation.
#' @keywords internal
#' @noRd
emit <- function(start, end, label, time_unit, console, log_file, df) {
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
      error = function(e) {
        warning("Could not write to log file: ", log_file)
      }
    )
  }

  # Save to R dataframe
  if (!is.null(df)) {
    if (!is.character(df)) {
      stop("df must be a character string naming a data frame.")
    }

    new_row <- data.frame(
      timestamp = timestamp,
      label = label,
      duration = as.numeric(duration),
      time_unit = time_unit,
      stringsAsFactors = FALSE
    )

    if (exists(df, envir = .GlobalEnv)) {
      assign(
        df,
        rbind(get(df, envir = .GlobalEnv), new_row),
        envir = .GlobalEnv
      )
    } else {
      assign(df, new_row, envir = .GlobalEnv)
    }
  }
  invisible(duration)
}

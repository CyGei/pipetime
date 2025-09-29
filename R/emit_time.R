#' Emit a timing result
#'
#' Prints and/or logs the execution time of an operation.
#'
#' @param start_time POSIXct. Pipeline start time.
#' @param duration Numeric. Duration since pipeline start.
#' @param label Character. Operation label.
#' @param unit Character. Time unit ("secs", "mins", "hours", "days", or "weeks").
#' @param console Logical. Print timing to the console?
#' @param log Character or NULL. Name of a data frame in `.pipetime_env` for logging.
#'
#' @return Invisibly, the numeric duration of the operation.
#' @keywords internal
#' @noRd
emit_time <- function(start_time, duration, label, unit, console, log) {
  duration_fmt <- sprintf("%.4f", duration)
  timestamp_fmt <- format(start_time, "%Y-%m-%d %H:%M:%OS3")

  build_msg <- function(ts, label, dur, unit) {
    paste0("[", ts, "] ", label, ": ", dur, " ", unit)
  }

  # Console
  if (isTRUE(console)) {
    if (requireNamespace("crayon", quietly = TRUE)) {
      msg <- build_msg(
        timestamp_fmt,
        crayon::blue(label),
        crayon::green(paste0("+", duration_fmt)),
        crayon::green(unit)
      )
    } else {
      msg <- build_msg(timestamp_fmt, label, paste0("+", duration_fmt), unit)
    }
    message(msg)
  }

  # Log
  if (!is.null(log)) {
    stopifnot(is.character(log), length(log) == 1)
    new_row <- data.frame(
      timestamp = start_time,
      label = label,
      duration = duration,
      unit = unit,
      stringsAsFactors = FALSE
    )

    if (exists(log, envir = .pipetime_env, inherits = FALSE)) {
      assign(
        log,
        rbind(get(log, envir = .pipetime_env), new_row),
        envir = .pipetime_env
      )
    } else {
      assign(log, new_row, envir = .pipetime_env)
    }
  }
  invisible(duration)
}

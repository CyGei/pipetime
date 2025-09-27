#' Emit a timing result
#'
#' Prints and/or logs the execution time of an operation.
#'
#' @param start POSIXct. Operation start time.
#' @param end POSIXct. Operation end time.
#' @param label Character. Operation label.
#' @param unit Character. Time unit ("secs", "mins", "hours", "days", or "weeks").
#' @param console Logical. Print timing to the console?
#' @param log Character or NULL. Name of a data frame in .pipetime_env for logging.
#' @param pipe_id Numeric. The ID of the current pipeline.
#'
#' @return Invisibly, the numeric duration of the operation.
#' @keywords internal
#' @noRd
emit <- function(start, end, label, unit, console, log, pipe_id) {
  duration <- as.numeric(difftime(end, start, units = unit))
  duration_fmt <- sprintf("%.4f", duration)
  timestamp <- format(end, "%Y-%m-%d %H:%M:%OS3")

  build_msg <- function(ts, lbl, dur, unit) {
    paste0("[", ts, "] ", lbl, ": ", dur, " ", unit)
  }

  if (isTRUE(console)) {
    if (requireNamespace("crayon", quietly = TRUE)) {
      console_msg <- build_msg(
        timestamp,
        crayon::blue(label),
        crayon::green(duration_fmt),
        crayon::green(unit)
      )
    } else {
      console_msg <- build_msg(timestamp, label, duration_fmt, unit)
    }
    message(console_msg)
  }

  if (!is.null(log)) {
    if (!is.character(log)) {
      stop("'log' must be a character string.")
    }

    new_row <- data.frame(
      pipe_id = pipe_id,
      timestamp = timestamp,
      label = label,
      duration = as.numeric(duration),
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

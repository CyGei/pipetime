#' Time the execution of an expression
#'
#' Evaluates an expression and measures the execution time.
#' Optionally logs the time to a file and/or prints it to the console.
#'
#' @param .data Expression or object to evaluate.
#' @param label Character string naming the timed step. Default is \code{"pipeline"}.
#' @param log_file Optional file path to append the time log.
#' @param console Logical. If \code{TRUE}, print the elapsed time to the console.
#' @param time_unit Time unit for the elapsed time: \code{"secs"}, \code{"millisecs"}, or \code{"mins"}. Default is \code{"secs"}.
#'
#' @return The evaluated result of \code{.data}.
#' @export
#'
#' @examples
#' mtcars |>
#'   dplyr::mutate(hp2 = {Sys.sleep(1); hp * 2}) |>
#'   timer("doubling horsepower")
timer <- function(.data, label = "pipeline", log_file = NULL, console = TRUE, time_unit = c("secs", "millisecs", "mins")) {
  time_unit <- match.arg(time_unit)

  start <- Sys.time()
  result <- eval(substitute(.data), envir = parent.frame())
  end <- Sys.time()

  duration <- as.numeric(difftime(end, start, units = "secs"))
  duration <- switch(time_unit,
                     secs = duration,
                     millisecs = duration * 1000,
                     mins = duration / 60)

  log_msg <- sprintf("[%s] %s: %.4f %s elapsed",
                     format(start, "%Y-%m-%d %H:%M:%OS3"),
                     label,
                     duration,
                     time_unit)

  if (console) message(log_msg)
  if (!is.null(log_file)) cat(log_msg, "\n", file = log_file, append = TRUE)

  invisible(result)
}

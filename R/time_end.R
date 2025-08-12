#' End timing a pipeline step
#'
#' Completes timing for a step started with \code{\link{time_start}}.
#' Calculates the elapsed time, optionally logs it to a file, and/or prints it to the console.
#'
#' @param .data Any R object passed through the pipe with timing attributes. See \code{\link{time_start}}.
#' @param log_file Optional file path to append the time log.
#' @param console Logical. If \code{TRUE}, print the elapsed time to the console.
#' @param time_unit Time unit for the elapsed time: \code{"secs"}, \code{"millisecs"}, or \code{"mins"}. Default is \code{"secs"}.
#'
#' @return The original object (\code{.data}) with timing attributes removed.
#' @seealso \code{\link{time_start}}
#' @export
#'
#' @examples
#' mtcars |>
#'   time_start("Calculating hp2") |>
#'   dplyr::mutate(hp2 = {Sys.sleep(1); hp * 2}) |>
#'   time_end()
time_end <- function(.data, log_file = NULL, console = TRUE, time_unit = c("secs", "millisecs", "mins")) {
  time_unit <- match.arg(time_unit)
  start <- attr(.data, "time_start")
  label <- attr(.data, "time_label")

  if (is.null(start)) {
    warning("time_start() was not called. Cannot report time.", call. = FALSE)
    return(invisible(.data))
  }

  end <- Sys.time()
  duration <- as.numeric(difftime(end, start, units = "secs"))
  duration <- switch(time_unit,
                     secs = duration,
                     millisecs = duration * 1000,
                     mins = duration / 60)

  label <- if (!is.null(label)) label else "pipeline"

  log_msg <- sprintf("[%s] %s: %.3f %s elapsed",
                     format(end, "%Y-%m-%d %H:%M:%OS3"),
                     label,
                     duration,
                     time_unit)

  if (console) message(log_msg)
  if (!is.null(log_file)) cat(log_msg, "\n", file = log_file, append = TRUE)

  attr(.data, "time_start") <- NULL
  attr(.data, "time_label") <- NULL

  invisible(.data)
}


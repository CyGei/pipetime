#' Start timing a pipeline step
#'
#' Records the current time and a label as attributes of \code{.data}.
#' Use at the start of a pipe to mark the beginning of a timed step.
#' The recorded time is later used by \code{\link{time_end}} to calculate
#' the elapsed time.
#'
#' @param .data Any R object passed through the pipe.
#' @param label Character string naming the timed step. Default is \code{"pipeline"}.
#'
#' @return The input object with timing attributes added.
#' @seealso \code{\link{time_end}}, \code{\link{timer}}
#' @export
time_start <- function(.data, label = "pipeline") {
  attr(.data, "time_start") <- Sys.time()
  attr(.data, "time_label") <- label
  invisible(.data)
}

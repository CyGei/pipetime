#' Format duration between two time points
#'
#' Converts a start and end time into a numeric duration, expressed in the chosen unit.
#'
#' @param start A `POSIXct` object indicating the start time.
#' @param end A `POSIXct` object indicating the end time.
#' @param time_unit Character; one of `"secs"`, `"millisecs"`, or `"mins"`. Determines the unit of the returned duration.
#'
#' @return Numeric value of the duration between `start` and `end` in the chosen unit.
#' @keywords internal
format_duration <- function(start, end, time_unit) {
  secs <- as.numeric(difftime(end, start, units = "secs"))
  switch(
    time_unit,
    secs = secs,
    millisecs = secs * 1000,
    mins = secs / 60
  )
}

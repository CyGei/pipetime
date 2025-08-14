#' Clean label text
#'
#' Converts an unevaluated R expression to a single, whitespace-free string
#' suitable for labelling timed operations.
#'
#' @param expr An R expression or call.
#'
#' @return Character string with no whitespace.
#' @keywords internal
clean_label <- function(expr) {
  gsub("\\s+", "", paste(deparse(expr), collapse = ""))
}

#' Remove a stored timing log
#'
#' @param log Character. Name of the timing log to delete from `.pipetime_env`.
#'
#' @export
rm_log <- function(log) {
  if (!is.character(log) || length(log) != 1) {
    stop("`log` must be a single character string.")
  }
  if (exists(log, envir = .pipetime_env, inherits = FALSE)) {
    rm(list = log, envir = .pipetime_env)
    invisible(TRUE)
  } else {
    warning("No data frame named '", log, "' found in pipetime environment.")
    invisible(FALSE)
  }
}

#' Retrieve a stored timing log
#'
#' @param log Character. Name of the data frame to load from `.pipetime_env`.
#'
#' @return A data frame of timing logs.
#' @export
get_log <- function(log) {
  if (exists(log, envir = .pipetime_env, inherits = FALSE)) {
    get(log, envir = .pipetime_env)
  } else {
    stop("No data frame named '", log, "' found in .pipetime_env.")
  }
}

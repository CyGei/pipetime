#' Remove a timing log (or all logs)
#'
#' Delete a timing log from `.pipetime_env`.
#' If `log = NULL`, all logs are removed, but only when `force = TRUE`.
#'
#' @param log Character string or `NULL`. Name of the log to remove. If `NULL`, all logs are targeted.
#' @param force Logical. To remove all logs, `force` must be `TRUE`. Default: `FALSE`.
#'
#' @return Invisibly, `TRUE`.
#' @seealso [get_log()]
#' @export
rm_log <- function(log = NULL, force = FALSE) {
  logs <- setdiff(ls(envir = .pipetime_env), "start_times")
  if (!length(logs)) {
    warning("No logs to remove.")
    return(invisible(FALSE))
  }

  if (is.null(log)) {
    if (!force) {
      stop("To remove all logs, set force = TRUE.")
    }
    rm(list = logs, envir = .pipetime_env)
    .pipetime_env$start_times <- list()
  } else {
    if (!is.character(log) || length(log) != 1) {
      stop("`log` must be a single character string.")
    }
    if (!exists(log, envir = .pipetime_env, inherits = FALSE)) {
      stop("No log named '", log, "' found in .pipetime_env.")
    }
    rm(list = log, envir = .pipetime_env)
    .pipetime_env$start_times[[log]] <- NULL
  }
  invisible(TRUE)
}

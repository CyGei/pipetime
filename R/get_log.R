#' Retrieve a timing log (or all logs)
#'
#' Return a stored timing log from `.pipetime_env`.
#' If `log = NULL`, return all logs as a named list.
#'
#' @param log Character string or `NULL`. Name of the log to retrieve. If `NULL`, all logs are returned.
#'
#' @return Either:
#' - A data frame with columns:
#'   - `timestamp` (`POSIXct`): Pipeline start time
#'   - `label` (`character`): Operation label
#'   - `duration` (`numeric`): Elapsed time since pipeline start
#'   - `unit` (`character`): Time unit used
#' - Or, if `log = NULL`, a named list of such data frames.
#'
#' @seealso [rm_log()]
#'
#' @importFrom stats setNames
#'
#' @export
get_log <- function(log = NULL) {
  logs <- setdiff(ls(envir = .pipetime_env), "start_times")
  if (!length(logs)) {
    return(list())
  }

  if (is.null(log)) {
    # Return all logs
    stats::setNames(
      lapply(logs, function(x) get(x, envir = .pipetime_env)),
      logs
    )
  } else {
    stopifnot(is.character(log), length(log) == 1)
    if (!exists(log, envir = .pipetime_env, inherits = FALSE)) {
      stop("No log named '", log, "' found in .pipetime_env.")
    }
    get(log, envir = .pipetime_env)
  }
}

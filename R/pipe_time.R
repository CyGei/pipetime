#' Time a single step in a pipeline
#'
#' Measures and reports the execution time of a function or expression applied
#' to data within a native R pipe (`|>`). Returns the result invisibly for further piping.
#'
#' @param .data Any R object passed through the pipe.
#' @param expr An expression or function call to evaluate using `.data` as the first argument.
#' @param label Optional character string to label the timing output. Defaults to the expression itself.
#'
#' @return The result of evaluating `expr` with `.data`, invisibly, so it can be piped further.
#'
#' @examples
#' library(dplyr)
#' mtcars |>
#'   time_pipe(group_by(cyl), "grouping") |>
#'   time_pipe(summarise(avg_hp = mean(hp))) |>
#'   mutate(no_time = 1:n()) |>
#'   time_pipe(mutate(a_complex_fun = { Sys.sleep(1); avg_hp * 2 }), "complex function")
#'
#' @export
time_pipe <- function(.data, expr, label = NULL) {
  expr <- substitute(expr)
  fn <- expr[[1]]
  args <- as.list(expr)[-1]
  new_call <- as.call(c(fn, quote(.data), args))
  env <- new.env(parent = parent.frame())
  env$.data <- .data
  timing <- system.time({
    result <- eval(new_call, envir = env)
  })[["elapsed"]]
  if (is.null(label)) label <- paste(deparse(expr), collapse = " ")
  message(sprintf("%s: %.4f seconds", label, timing))
  invisible(result)
}

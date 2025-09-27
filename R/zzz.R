.pipetime_env <- new.env(parent = emptyenv())

# Each log will have its own counter
.pipetime_env$pipe_counters <- list()

# Track whether we’re inside a run for each log
.pipetime_env$active_runs <- list()

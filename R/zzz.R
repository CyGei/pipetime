.pipetime_env <- new.env(parent = emptyenv())

# Global counter for pipeline IDs
.pipetime_env$pipe_counter <- 0L

# Track whether we’re already inside a pipeline run
.pipetime_env$active_run <- FALSE

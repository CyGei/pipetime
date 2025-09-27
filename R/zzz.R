.pipetime_env <- new.env(parent = emptyenv())

# Global counter for pipeline IDs
.pipetime_env$pipe_counter <- 0L

# Store last pipeline hash
.pipetime_env$last_hash <- NULL

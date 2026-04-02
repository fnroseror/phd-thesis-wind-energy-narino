check_required_columns <- function(df, required_cols) {
  missing <- setdiff(required_cols, names(df))
  if (length(missing) > 0) {
    stop(
      paste("Missing required columns:", paste(missing, collapse = ", ")),
      call. = FALSE
    )
  }
}

check_file_exists <- function(path) {
  if (!file.exists(path)) {
    stop(paste("File not found:", path), call. = FALSE)
  }
}

check_non_empty <- function(df, object_name = "data frame") {
  if (is.null(df) || nrow(df) == 0) {
    stop(paste("Empty", object_name), call. = FALSE)
  }
}

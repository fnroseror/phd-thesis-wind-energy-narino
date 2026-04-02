# 05_validation_helpers.R
# Input and output validation helpers

check_file_exists <- function(path) {
  if (!file.exists(path)) {
    stop(sprintf("Required file not found: %s", path), call. = FALSE)
  }
  invisible(TRUE)
}

check_required_columns <- function(df, required_cols) {
  missing_cols <- setdiff(required_cols, names(df))
  if (length(missing_cols) > 0) {
    stop(
      sprintf("Missing required columns: %s", paste(missing_cols, collapse = ", ")),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

check_non_empty <- function(x, object_name = "object") {
  is_empty_df <- is.data.frame(x) && nrow(x) == 0
  is_empty_vec <- is.atomic(x) && length(x) == 0

  if (is.null(x) || is_empty_df || is_empty_vec) {
    stop(sprintf("Empty %s.", object_name), call. = FALSE)
  }
  invisible(TRUE)
}

check_missing_rate <- function(df, cols, threshold = 0.5) {
  check_required_columns(df, cols)

  rates <- vapply(cols, function(col) mean(is.na(df[[col]])), numeric(1))
  bad <- names(rates)[rates > threshold]

  if (length(bad) > 0) {
    stop(
      sprintf(
        "Missingness above threshold in: %s",
        paste(sprintf("%s (%.2f)", bad, rates[bad]), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  invisible(rates)
}

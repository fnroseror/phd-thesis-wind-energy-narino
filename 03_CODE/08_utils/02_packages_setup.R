required_packages <- c(
  "data.table", "dplyr", "ggplot2", "forecast", "tseries",
  "Metrics", "readr", "xgboost", "ranger", "KFAS"
)

check_required_packages <- function(pkgs = required_packages) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    stop(
      paste(
        "Missing required packages:",
        paste(missing, collapse = ", "),
        "\nInstall them before running the pipeline."
      ),
      call. = FALSE
    )
  }
}

load_required_packages <- function(pkgs = required_packages) {
  invisible(lapply(pkgs, library, character.only = TRUE))
}

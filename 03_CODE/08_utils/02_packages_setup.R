# 02_packages_setup.R
# Package verification and loading

required_packages <- c(
  "data.table",
  "dplyr",
  "ggplot2",
  "readr",
  "forecast",
  "Metrics",
  "ranger",
  "xgboost",
  "KFAS"
)

check_required_packages <- function(pkgs = required_packages) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]

  if (length(missing) > 0) {
    stop(
      paste0(
        "Missing required packages: ",
        paste(missing, collapse = ", "),
        ". Install them before running the pipeline."
      ),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

load_required_packages <- function(pkgs = required_packages) {
  check_required_packages(pkgs)
  invisible(lapply(pkgs, library, character.only = TRUE))
}

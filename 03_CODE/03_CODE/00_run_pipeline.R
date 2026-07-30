# 00_run_pipeline.R
# Conservative entry point. It never overwrites approved canonical results.

args <- commandArgs(trailingOnly = TRUE)
mode <- if (length(args)) args[[1]] else "--check"
source(file.path("03_CODE", "00_config.R"))

cat("TDQ repository:", TDQ_REPO_ROOT, "\n")
cat("Restricted data:", TDQ_DATA_FILE, "\n")
cat("Work directory:", TDQ_WORK_DIR, "\n")
cat("Mode:", mode, "\n")

if (identical(mode, "--check")) {
  if (!file.exists(TDQ_DATA_FILE)) {
    cat("CHECK PASSED WITH RESTRICTED DATA UNAVAILABLE: set TDQ_DATA_FILE to execute numerical stages.\n")
  } else {
    cat("CHECK PASSED: restricted data source is available.\n")
  }
  quit(save = "no", status = 0)
}

if (identical(mode, "--preprocess")) {
  if (!file.exists(TDQ_DATA_FILE)) stop("Restricted source not found: ", TDQ_DATA_FILE)
  source(file.path("03_CODE", "01_preprocessing", "01_build_station_hour_dataset.R"))
  quit(save = "no", status = 0)
}

stop("Unsupported mode. Use --check or --preprocess.")

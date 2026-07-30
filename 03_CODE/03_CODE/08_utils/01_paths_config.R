# 01_paths_config.R
# Compatibility wrapper around the final central configuration.
source(file.path("03_CODE","00_config.R"))
TDQ_PATHS <- list(
  root=TDQ_REPO_ROOT,
  thesis=file.path(TDQ_REPO_ROOT,"01_THESIS"),
  metadata=file.path(TDQ_REPO_ROOT,"02_DATA_METADATA"),
  code=file.path(TDQ_REPO_ROOT,"03_CODE"),
  results=file.path(TDQ_REPO_ROOT,"04_RESULTS_COMPLETE"),
  appendices=file.path(TDQ_REPO_ROOT,"05_APPENDICES_SUPPORT"),
  products=file.path(TDQ_REPO_ROOT,"06_PRODUCTS"),
  reproducibility=file.path(TDQ_REPO_ROOT,"07_REPRODUCIBILITY"),
  work=TDQ_WORK_DIR
)
ensure_dir <- function(path){if(!dir.exists(path))dir.create(path,recursive=TRUE,showWarnings=FALSE);invisible(path)}

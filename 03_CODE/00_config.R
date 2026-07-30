# 00_config.R
# Portable configuration for the TDQ doctoral repository.
# Run scripts from the repository root.

find_tdq_repo_root <- function(start = getwd()) {
  env_root <- Sys.getenv("TDQ_REPO_ROOT", unset = "")
  if (nzchar(env_root)) {
    return(normalizePath(env_root, winslash = "/", mustWork = TRUE))
  }

  current <- normalizePath(start, winslash = "/", mustWork = TRUE)
  repeat {
    required <- c("01_THESIS", "02_DATA_METADATA", "03_CODE")
    if (all(dir.exists(file.path(current, required)))) return(current)
    parent <- dirname(current)
    if (identical(parent, current)) {
      stop("TDQ repository root not found. Run from the repository root or define TDQ_REPO_ROOT.", call. = FALSE)
    }
    current <- parent
  }
}

TDQ_REPO_ROOT <- find_tdq_repo_root()
TDQ_DATA_FILE <- Sys.getenv(
  "TDQ_DATA_FILE",
  unset = file.path(TDQ_REPO_ROOT, "02_DATA_METADATA", "data", "Datos.txt")
)
TDQ_WORK_DIR <- Sys.getenv(
  "TDQ_WORK_DIR",
  unset = file.path(TDQ_REPO_ROOT, "local_work")
)
TDQ_CANONICAL_RESULTS_DIR <- file.path(TDQ_REPO_ROOT, "04_RESULTS_COMPLETE")
TDQ_TIMEZONE <- "America/Bogota"
TDQ_RHO_REFERENCE <- 1.10
TDQ_R_DRY_AIR <- 287.05
TDQ_W0 <- 1.0
TDQ_EPS <- 1e-12

if (!dir.exists(TDQ_WORK_DIR)) dir.create(TDQ_WORK_DIR, recursive = TRUE, showWarnings = FALSE)

# Check the R/RStudio environment without running scientific models.
# Run from repository root:
# source("07_REPRODUCIBILITY/02_validation/check_environment.R")

resolve_this_file <- function() {
  ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (!is.null(ofile)) return(normalizePath(ofile, winslash = "/", mustWork = TRUE))
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 1) return(normalizePath(sub("^--file=", "", hit), winslash = "/", mustWork = TRUE))
  stop("No fue posible resolver la ruta del script.")
}

script <- resolve_this_file()
repo <- normalizePath(file.path(dirname(script), "..", ".."), winslash = "/", mustWork = TRUE)
deps_path <- file.path(repo, "07_REPRODUCIBILITY", "00_environment", "package_dependencies_from_R_scripts.csv")
deps <- read.csv(deps_path, stringsAsFactors = FALSE, check.names = FALSE)

installed <- rownames(installed.packages())
missing <- setdiff(deps$package, installed)

cat("R version:", R.version.string, "\n")
cat("Platform:", R.version$platform, "\n")
cat("Time zone:", Sys.timezone(), "\n")
cat("Required external packages:", nrow(deps), "\n")
cat("Missing packages:", length(missing), "\n")

if (length(missing)) {
  cat(paste(missing, collapse = "\n"), "\n")
  stop("ENVIRONMENT CHECK FAILED: install the missing packages before scientific execution.", call. = FALSE)
}

cat("ENVIRONMENT CHECK PASSED\n")

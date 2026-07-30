# Optional helper for installing missing CRAN packages.
# This script does not execute scientific models.
# It installs current repository versions, not guaranteed historical versions.

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
deps <- read.csv(
  file.path(repo, "07_REPRODUCIBILITY", "00_environment", "package_dependencies_from_R_scripts.csv"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

installed <- rownames(installed.packages())
missing <- setdiff(deps$package, installed)

if (!length(missing)) {
  cat("No missing packages detected.\n")
} else {
  cat("Installing missing packages from the configured CRAN repository:\n")
  cat(paste(missing, collapse = "\n"), "\n")
  install.packages(missing)
}

cat("Installation helper completed. Run check_environment.R next.\n")

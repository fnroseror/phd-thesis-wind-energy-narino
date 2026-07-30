# Root convenience wrapper.
# Open the repository RStudio project, then run:
# source("00_check_environment.R")

resolve_root <- function() {
  ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (!is.null(ofile)) return(dirname(normalizePath(ofile, winslash = "/", mustWork = TRUE)))
  normalizePath(getwd(), winslash = "/", mustWork = TRUE)
}

repo_root <- resolve_root()
script <- file.path(repo_root, "07_REPRODUCIBILITY", "02_validation", "check_environment.R")

if (!file.exists(script)) {
  stop("No se encontró el verificador de ambiente: ", script, call. = FALSE)
}

source(script, local = new.env(parent = globalenv()), encoding = "UTF-8")

# Generate a candidate SHA-256 manifest for inspection.
# The canonical manifest is not overwritten automatically.

resolve_this_file <- function() {
  ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (!is.null(ofile)) return(normalizePath(ofile, winslash = "/", mustWork = TRUE))
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 1) return(normalizePath(sub("^--file=", "", hit), winslash = "/", mustWork = TRUE))
  stop("No fue posible resolver la ruta del script.")
}

if (!requireNamespace("digest", quietly = TRUE)) {
  stop("Se requiere el paquete R 'digest'.", call. = FALSE)
}

script <- resolve_this_file()
repo <- normalizePath(file.path(dirname(script), "..", ".."), winslash = "/", mustWork = TRUE)
folders <- sprintf("%02d_%s", 1:7, c(
  "THESIS", "DATA_METADATA", "CODE", "RESULTS_COMPLETE",
  "APPENDICES_SUPPORT", "PRODUCTS", "REPRODUCIBILITY"
))

paths <- character()
for (folder in folders) {
  root <- file.path(repo, folder)
  if (dir.exists(root)) {
    listed <- list.files(root, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
    listed <- listed[file.info(listed)$isdir %in% FALSE]
    paths <- c(paths, listed)
  }
}

paths <- sort(unique(paths))
rel <- substring(normalizePath(paths, winslash = "/", mustWork = TRUE), nchar(repo) + 2)
candidate <- data.frame(
  path = rel,
  size_bytes = file.info(paths)$size,
  sha256 = vapply(paths, digest::digest, character(1), file = TRUE, algo = "sha256", serialize = FALSE),
  stringsAsFactors = FALSE
)

out <- file.path(repo, "07_REPRODUCIBILITY", "05_logs", "candidate_repository_manifest.csv")
write.csv(candidate, out, row.names = FALSE, fileEncoding = "UTF-8")
cat("Candidate manifest written to:", out, "\n")
cat("It is not automatically promoted to canonical status.\n")

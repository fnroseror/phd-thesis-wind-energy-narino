# Validate 07_REPRODUCIBILITY itself.
# Run from RStudio:
# source("07_REPRODUCIBILITY/02_validation/validate_reproducibility.R")

resolve_this_file <- function() {
  ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (!is.null(ofile)) return(normalizePath(ofile, winslash = "/", mustWork = TRUE))
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 1) return(normalizePath(sub("^--file=", "", hit), winslash = "/", mustWork = TRUE))
  stop("No fue posible resolver la ruta del validador.")
}

script <- resolve_this_file()
root <- normalizePath(file.path(dirname(script), ".."), winslash = "/", mustWork = TRUE)
errors <- character()

required <- c(
  "README.md",
  "00_environment/README.md",
  "00_environment/observed_environment_profiles.csv",
  "00_environment/package_dependencies_from_R_scripts.csv",
  "01_manifests/repository_snapshot_manifest_01_06.csv",
  "01_manifests/folder_summary_01_06.csv",
  "01_manifests/delivery_zip_hashes.csv",
  "01_manifests/thesis_pdf_hash_register.csv",
  "02_validation/validate_repository.R",
  "02_validation/check_environment.R",
  "02_validation/generate_candidate_manifest.R",
  "03_protocols/clean_clone_validation_protocol.md",
  "04_release_control/release_gates.csv",
  "_manifest_sha256.csv"
)

for (rel in required) {
  if (!file.exists(file.path(root, rel))) errors <- c(errors, paste0("Missing required file: ", rel))
}

all_files <- list.files(root, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
all_files <- all_files[file.info(all_files)$isdir %in% FALSE]

python_files <- all_files[tolower(tools::file_ext(all_files)) == "py"]
if (length(python_files)) errors <- c(errors, paste0("Python validator/file not permitted: ", python_files))

oversize <- all_files[file.info(all_files)$size > 100 * 1024^2]
if (length(oversize)) errors <- c(errors, paste0("File above 100 MB: ", oversize))

if (!requireNamespace("digest", quietly = TRUE)) {
  errors <- c(errors, "R package 'digest' is required.")
} else {
  manifest <- read.csv(file.path(root, "_manifest_sha256.csv"), stringsAsFactors = FALSE, check.names = FALSE)
  for (i in seq_len(nrow(manifest))) {
    p <- file.path(root, manifest$path[i])
    if (!file.exists(p)) {
      errors <- c(errors, paste0("Manifest path missing: ", manifest$path[i]))
    } else {
      actual <- digest::digest(file = p, algo = "sha256", serialize = FALSE)
      if (!identical(tolower(actual), tolower(manifest$sha256[i]))) {
        errors <- c(errors, paste0("Hash mismatch: ", manifest$path[i]))
      }
    }
  }
}

if (length(errors)) {
  cat("REPRODUCIBILITY VALIDATION FAILED\n")
  cat(paste(errors, collapse = "\n"), "\n")
  stop("07_REPRODUCIBILITY validation failed.", call. = FALSE)
}

cat("REPRODUCIBILITY VALIDATION PASSED\n")

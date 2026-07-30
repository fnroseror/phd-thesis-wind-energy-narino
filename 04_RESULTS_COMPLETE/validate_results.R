# Static validator for 04_RESULTS_COMPLETE
# Intended for execution in RStudio or with: Rscript validate_results.R

options(stringsAsFactors = FALSE)

script_path <- tryCatch(normalizePath(sys.frame(1)$ofile, winslash = "/", mustWork = TRUE),
                        error = function(e) NA_character_)
root <- if (!is.na(script_path)) dirname(script_path) else normalizePath(getwd(), winslash = "/")

errors <- character(0)

read_index <- function(relative_path) {
  path <- file.path(root, relative_path)
  if (!file.exists(path)) {
    errors <<- c(errors, paste0("Missing index file: ", relative_path))
    return(data.frame())
  }
  tryCatch(
    read.csv(path, check.names = FALSE, encoding = "UTF-8"),
    error = function(e) {
      errors <<- c(errors, paste0("Cannot read ", relative_path, ": ", conditionMessage(e)))
      data.frame()
    }
  )
}

sha256_file <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Package 'digest' is required. Install it with install.packages('digest').")
  }
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

figures <- read_index("00_CANONICAL_INDEX/figures_index.csv")
tables  <- read_index("00_CANONICAL_INDEX/tables_index.csv")

if (nrow(figures) != 31L) errors <- c(errors, sprintf("Expected 31 figures, found %d", nrow(figures)))
if (nrow(tables)  != 25L) errors <- c(errors, sprintf("Expected 25 tables, found %d", nrow(tables)))

if (nrow(figures) > 0L) {
  if (!"figure_id" %in% names(figures)) {
    errors <- c(errors, "Column 'figure_id' is missing from figures_index.csv")
  } else if (length(unique(figures$figure_id)) != 31L) {
    errors <- c(errors, "Duplicate or missing figure IDs")
  }

  if (!"evidence_file" %in% names(figures)) {
    errors <- c(errors, "Column 'evidence_file' is missing from figures_index.csv")
  } else {
    for (i in seq_len(nrow(figures))) {
      rel <- figures$evidence_file[i]
      if (!file.exists(file.path(root, rel))) {
        id <- if ("figure_id" %in% names(figures)) figures$figure_id[i] else i
        errors <- c(errors, paste0("Missing figure evidence: ", id, " -> ", rel))
      }
    }
  }
}

if (nrow(tables) > 0L) {
  if (!"table_id" %in% names(tables)) {
    errors <- c(errors, "Column 'table_id' is missing from tables_index.csv")
  } else if (length(unique(tables$table_id)) != 25L) {
    errors <- c(errors, "Duplicate or missing table IDs")
  }

  if (!"evidence_files" %in% names(tables)) {
    errors <- c(errors, "Column 'evidence_files' is missing from tables_index.csv")
  } else {
    for (i in seq_len(nrow(tables))) {
      rels <- strsplit(tables$evidence_files[i], " \\| ")[[1]]
      rels <- rels[nzchar(rels)]
      for (rel in rels) {
        if (!file.exists(file.path(root, rel))) {
          id <- if ("table_id" %in% names(tables)) tables$table_id[i] else i
          errors <- c(errors, paste0("Missing table evidence: ", id, " -> ", rel))
        }
      }
    }
  }
}

manifest_path <- file.path(root, "_manifest_sha256.csv")
if (!file.exists(manifest_path)) {
  errors <- c(errors, "Missing _manifest_sha256.csv")
} else {
  manifest <- read_index("_manifest_sha256.csv")
  required_columns <- c("relative_path", "size_bytes", "sha256")
  missing_columns <- setdiff(required_columns, names(manifest))
  if (length(missing_columns) > 0L) {
    errors <- c(errors, paste0("Manifest columns missing: ", paste(missing_columns, collapse = ", ")))
  } else {
    for (i in seq_len(nrow(manifest))) {
      rel <- manifest$relative_path[i]
      path <- file.path(root, rel)
      if (!file.exists(path)) {
        errors <- c(errors, paste0("Manifest missing file: ", rel))
        next
      }
      actual_size <- file.info(path)$size
      if (!is.na(manifest$size_bytes[i]) && actual_size != as.numeric(manifest$size_bytes[i])) {
        errors <- c(errors, paste0("Size mismatch: ", rel))
      }
      actual_hash <- tryCatch(
        sha256_file(path),
        error = function(e) {
          errors <<- c(errors, conditionMessage(e))
          NA_character_
        }
      )
      if (!is.na(actual_hash) && tolower(actual_hash) != tolower(manifest$sha256[i])) {
        errors <- c(errors, paste0("Hash mismatch: ", rel))
      }
    }
  }
}

all_files <- list.files(root, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
all_files <- all_files[file.info(all_files)$isdir %in% FALSE]
if (length(all_files) > 0L) {
  file_sizes <- file.info(all_files)$size
  oversized <- all_files[!is.na(file_sizes) & file_sizes > 100 * 1024^2]
  if (length(oversized) > 0L) {
    relative <- substring(normalizePath(oversized, winslash = "/"), nchar(normalizePath(root, winslash = "/")) + 2L)
    errors <- c(errors, paste0("File exceeds 100 MiB: ", relative))
  }
}

if (length(errors) == 0L) {
  output <- c(
    "RESULTS VALIDATION PASSED",
    sprintf("Figures: %d/31", nrow(figures)),
    sprintf("Tables: %d/25", nrow(tables))
  )
  status <- 0L
} else {
  output <- c("RESULTS VALIDATION FAILED", paste0("- ", unique(errors)))
  status <- 1L
}

writeLines(output, file.path(root, "VALIDATION_REPORT.txt"), useBytes = TRUE)
cat(paste(output, collapse = "\n"), "\n")

if (!interactive()) quit(status = status, save = "no")
invisible(status)

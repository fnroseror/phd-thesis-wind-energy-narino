# Global final repository validator.
# Run only after all folders and root files have been copied.
#
# From RStudio:
# source("07_REPRODUCIBILITY/02_validation/validate_repository.R")
#
# Final expected line:
# VALIDATION PASSED

resolve_this_file <- function() {
  ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (!is.null(ofile)) return(normalizePath(ofile, winslash = "/", mustWork = TRUE))
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 1) return(normalizePath(sub("^--file=", "", hit), winslash = "/", mustWork = TRUE))
  stop("No fue posible resolver la ruta del validador.")
}

script <- resolve_this_file()
repo <- normalizePath(file.path(dirname(script), "..", ".."), winslash = "/", mustWork = TRUE)

errors <- character()
warnings <- character()

add_error <- function(x) errors <<- c(errors, x)
add_warning <- function(x) warnings <<- c(warnings, x)

if (!requireNamespace("digest", quietly = TRUE)) {
  add_error("R package 'digest' is required.")
}

required_folders <- c(
  "01_THESIS", "02_DATA_METADATA", "03_CODE", "04_RESULTS_COMPLETE",
  "05_APPENDICES_SUPPORT", "06_PRODUCTS", "07_REPRODUCIBILITY"
)
for (folder in required_folders) {
  if (!dir.exists(file.path(repo, folder))) add_error(paste0("Missing repository folder: ", folder))
}

required_root_files <- c(
  "README.md",
  ".gitignore",
  ".gitattributes",
  "CITATION.cff",
  "LICENSE.md",
  "RELEASE_NOTES.md",
  "REPOSITORY_STATUS.md",
  "phd-thesis-wind-energy-narino.Rproj",
  "00_check_environment.R",
  "00_validate_repository.R",
  "ROOT_VALIDATION_REPORT.txt",
  "_root_manifest_sha256.csv"
)

for (root_file in required_root_files) {
  if (!file.exists(file.path(repo, root_file))) add_error(paste0("Missing root file: ", root_file))
}

root_manifest_path <- file.path(repo, "_root_manifest_sha256.csv")
if (file.exists(root_manifest_path) && requireNamespace("digest", quietly = TRUE)) {
  root_manifest <- read.csv(root_manifest_path, stringsAsFactors = FALSE, check.names = FALSE)
  for (i in seq_len(nrow(root_manifest))) {
    p <- file.path(repo, root_manifest$path[i])
    if (!file.exists(p)) {
      add_error(paste0("Root manifest path missing: ", root_manifest$path[i]))
    } else {
      actual <- digest::digest(file = p, algo = "sha256", serialize = FALSE)
      if (!identical(tolower(actual), tolower(root_manifest$sha256[i]))) {
        add_error(paste0("Root hash mismatch: ", root_manifest$path[i]))
      }
    }
  }
}

# Validate the frozen 01-06 snapshot.
snapshot_path <- file.path(repo, "07_REPRODUCIBILITY", "01_manifests", "repository_snapshot_manifest_01_06.csv")
if (!file.exists(snapshot_path)) {
  add_error("Missing canonical 01-06 snapshot manifest.")
} else if (requireNamespace("digest", quietly = TRUE)) {
  snapshot <- read.csv(snapshot_path, stringsAsFactors = FALSE, check.names = FALSE)
  for (i in seq_len(nrow(snapshot))) {
    p <- file.path(repo, snapshot$path[i])
    if (!file.exists(p)) {
      add_error(paste0("Canonical file missing: ", snapshot$path[i]))
    } else {
      actual <- digest::digest(file = p, algo = "sha256", serialize = FALSE)
      if (!identical(tolower(actual), tolower(snapshot$sha256[i]))) {
        add_error(paste0("Canonical file changed: ", snapshot$path[i]))
      }
    }
  }

  current <- character()
  for (folder in required_folders[1:6]) {
    root <- file.path(repo, folder)
    if (dir.exists(root)) {
      listed <- list.files(root, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
      listed <- listed[file.info(listed)$isdir %in% FALSE]
      if (length(listed)) {
        current <- c(current, substring(normalizePath(listed, winslash = "/", mustWork = TRUE), nchar(repo) + 2))
      }
    }
  }

  allowed_optional <- c("01_THESIS/Tesis_Doctoral_Corregida_1053833697.pdf")
  extra <- setdiff(sort(current), c(sort(snapshot$path), allowed_optional))
  if (length(extra)) add_error(paste0("Unexpected file outside frozen snapshot: ", extra))
}

# Internal manifests in folders 02-07.
manifest_folders <- c(
  "02_DATA_METADATA", "03_CODE", "04_RESULTS_COMPLETE",
  "05_APPENDICES_SUPPORT", "06_PRODUCTS", "07_REPRODUCIBILITY"
)
if (requireNamespace("digest", quietly = TRUE)) {
  for (folder in manifest_folders) {
    manifest_path <- file.path(repo, folder, "_manifest_sha256.csv")
    if (!file.exists(manifest_path)) {
      add_error(paste0("Missing internal manifest: ", folder))
      next
    }
    manifest <- read.csv(manifest_path, stringsAsFactors = FALSE, check.names = FALSE)
    for (i in seq_len(nrow(manifest))) {
      p <- file.path(repo, folder, manifest$path[i])
      if (!file.exists(p)) {
        add_error(paste0("Internal manifest path missing: ", folder, "/", manifest$path[i]))
      } else {
        actual <- digest::digest(file = p, algo = "sha256", serialize = FALSE)
        if (!identical(tolower(actual), tolower(manifest$sha256[i]))) {
          add_error(paste0("Internal hash mismatch: ", folder, "/", manifest$path[i]))
        }
      }
    }
  }
}

# Scientific evidence counts.
counts_path <- file.path(repo, "04_RESULTS_COMPLETE", "00_CANONICAL_INDEX", "scientific_output_counts.csv")
if (!file.exists(counts_path)) {
  add_error("Missing scientific output count table.")
} else {
  counts <- read.csv(counts_path, stringsAsFactors = FALSE, check.names = FALSE)
  fig <- counts[counts$output_type == "figures", ]
  tab <- counts[counts$output_type == "tables", ]
  if (nrow(fig) != 1 || fig$expected != 31 || fig$indexed != 31) add_error("Figures are not validated as 31/31.")
  if (nrow(tab) != 1 || tab$expected != 25 || tab$indexed != 25) add_error("Tables are not validated as 25/25.")
}

# Data metadata counts.
stations_path <- file.path(repo, "02_DATA_METADATA", "tables", "station_inventory.csv")
if (!file.exists(stations_path)) {
  add_error("Missing station inventory.")
} else {
  stations <- read.csv(stations_path, stringsAsFactors = FALSE, check.names = FALSE)
  if (nrow(stations) != 16) add_error(paste0("Expected 16 stations; found ", nrow(stations), "."))
  if (length(unique(stations$zone)) != 4) add_error("Expected four analytical zones.")
}

# Product preservation.
products_registry <- file.path(repo, "06_PRODUCTS", "00_REPOSITORY_INDEX", "PRODUCTS_REGISTRY.csv")
preservation_manifest <- file.path(repo, "06_PRODUCTS", "00_REPOSITORY_INDEX", "SOURCE_PRESERVATION_MANIFEST.csv")
if (!file.exists(products_registry)) {
  add_error("Missing product registry.")
} else {
  products <- read.csv(products_registry, stringsAsFactors = FALSE, check.names = FALSE)
  if (nrow(products) != 19) add_error(paste0("Expected 19 products; found ", nrow(products), "."))
}
if (!file.exists(preservation_manifest)) {
  add_error("Missing source preservation manifest.")
} else {
  preserved <- read.csv(preservation_manifest, stringsAsFactors = FALSE, check.names = FALSE)
  if (nrow(preserved) != 129) add_error(paste0("Expected 129 preserved source evidence files; found ", nrow(preserved), "."))
  if (any(preserved$preservation_status != "PRESERVED_EXACTLY")) add_error("One or more product evidence files are not marked PRESERVED_EXACTLY.")
}

# Thesis PDF gate.
thesis_reference <- file.path(repo, "01_THESIS", "canonical_thesis_reference.txt")
if (!file.exists(thesis_reference)) {
  add_error("Missing canonical thesis reference.")
} else if (requireNamespace("digest", quietly = TRUE)) {
  ref_lines <- readLines(thesis_reference, warn = FALSE, encoding = "UTF-8")
  ref <- strsplit(ref_lines, "=", fixed = TRUE)
  ref <- setNames(vapply(ref, function(x) paste(x[-1], collapse = "="), character(1)),
                  vapply(ref, `[`, character(1), 1))
  pdfs <- list.files(file.path(repo, "01_THESIS"), pattern = "\\.pdf$", full.names = TRUE, ignore.case = TRUE)
  superseded_hash <- "262ead6e745e758abcf1c73a8802df42a99d6d166518fc043c27d13d85ad24d4"

  if (!length(pdfs)) {
    add_warning("Thesis PDF remains withheld. This is permitted while the institutional similarity gate is active.")
  } else if (length(pdfs) > 1) {
    add_error("More than one thesis PDF is present in 01_THESIS.")
  } else {
    actual <- digest::digest(file = pdfs[1], algo = "sha256", serialize = FALSE)
    if (identical(tolower(actual), superseded_hash)) add_error("The superseded first-version thesis PDF is present.")
    if (!identical(tolower(actual), tolower(ref[["sha256"]]))) add_error("The thesis PDF does not match the canonical corrected-file hash.")
  }
}

# File-size and temporary-file checks.
all_files <- list.files(repo, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
all_files <- all_files[file.info(all_files)$isdir %in% FALSE]

oversize <- all_files[file.info(all_files)$size > 100 * 1024^2]
if (length(oversize)) add_error(paste0("File above 100 MB: ", oversize))

temporary_patterns <- c("~$", "\\.tmp$", "\\.bak$", "\\.DS_Store$", "Thumbs\\.db$")
temporary <- all_files[vapply(basename(all_files), function(x) any(grepl(paste(temporary_patterns, collapse = "|"), x, ignore.case = TRUE)), logical(1))]
if (length(temporary)) add_error(paste0("Temporary operating-system/editor file present: ", temporary))

# Code validation must remain in R/RStudio.
python_in_code_or_validation <- all_files[
  tolower(tools::file_ext(all_files)) == "py" &
  grepl("/(03_CODE|07_REPRODUCIBILITY)/", gsub("\\\\", "/", all_files))
]
if (length(python_in_code_or_validation)) add_error(paste0("Python file present in executable code/validation scope: ", python_in_code_or_validation))

# Relative Markdown links.
md_files <- all_files[tolower(tools::file_ext(all_files)) == "md"]
for (md in md_files) {
  lines <- readLines(md, warn = FALSE, encoding = "UTF-8")
  txt <- paste(lines, collapse = "\n")
  matches <- gregexpr("\\[[^]]*\\]\\(([^)]+)\\)", txt, perl = TRUE)
  raw <- regmatches(txt, matches)[[1]]
  if (length(raw) && raw[1] != "-1") {
    for (item in raw) {
      link <- sub("^.*\\]\\(([^)]+)\\)$", "\\1", item)
      link <- sub("[#?].*$", "", link)
      link <- URLdecode(link)
      if (!nzchar(link) || grepl("^(https?|mailto):", link, ignore.case = TRUE) || startsWith(link, "#")) next
      target_path <- normalizePath(file.path(dirname(md), link), winslash = "/", mustWork = FALSE)
      if (!file.exists(target_path)) add_error(paste0("Broken relative Markdown link in ", substring(md, nchar(repo) + 2), ": ", link))
    }
  }
}

# Execute child validators.
child_validators <- c(
  "03_CODE/08_utils/06_static_code_validation.R",
  "04_RESULTS_COMPLETE/validate_results.R",
  "05_APPENDICES_SUPPORT/validate_appendices.R",
  "06_PRODUCTS/validate_products.R",
  "07_REPRODUCIBILITY/02_validation/validate_reproducibility.R"
)

for (rel in child_validators) {
  p <- file.path(repo, rel)
  if (!file.exists(p)) {
    add_error(paste0("Missing child validator: ", rel))
  } else {
    result <- tryCatch({
      out <- capture.output(source(p, local = new.env(parent = globalenv()), encoding = "UTF-8"))
      paste(out, collapse = "\n")
    }, error = function(e) {
      add_error(paste0("Child validator failed: ", rel, " -> ", conditionMessage(e)))
      ""
    })
  }
}

if (length(warnings)) {
  cat("WARNINGS\n")
  cat(paste(unique(warnings), collapse = "\n"), "\n")
}

if (length(errors)) {
  cat("VALIDATION FAILED\n")
  cat(paste(unique(errors), collapse = "\n"), "\n")
  stop("Final repository validation failed.", call. = FALSE)
}

cat("Folders: 7/7\n")
cat("Figures: 31/31\n")
cat("Tables: 25/25\n")
cat("Stations: 16\n")
cat("Zones: 4\n")
cat("Products: 19/19\n")
cat("Preserved product evidence: 129/129\n")
cat("VALIDATION PASSED\n")

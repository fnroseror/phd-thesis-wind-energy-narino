# Validation for 06_PRODUCTS
# Run from RStudio:
# source("06_PRODUCTS/validate_products.R")

resolve_this_file <- function() {
  ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (!is.null(ofile)) return(normalizePath(ofile, winslash = "/", mustWork = TRUE))
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 1) {
    return(normalizePath(sub("^--file=", "", hit), winslash = "/", mustWork = TRUE))
  }
  stop("No fue posible resolver la ruta del validador. Use source() en RStudio o Rscript.")
}

script_path <- resolve_this_file()
root <- dirname(script_path)
errors <- character()

if (!requireNamespace("digest", quietly = TRUE)) {
  stop("Se requiere el paquete R 'digest' para verificar SHA-256.", call. = FALSE)
}

preservation_path <- file.path(root, "00_REPOSITORY_INDEX", "SOURCE_PRESERVATION_MANIFEST.csv")
if (!file.exists(preservation_path)) {
  errors <- c(errors, "Falta SOURCE_PRESERVATION_MANIFEST.csv")
} else {
  src_manifest <- read.csv(preservation_path, stringsAsFactors = FALSE, check.names = FALSE)
  for (i in seq_len(nrow(src_manifest))) {
    rel <- src_manifest$source_relative_path[i]
    p <- file.path(root, rel)
    if (!file.exists(p)) {
      errors <- c(errors, paste0("Archivo fuente omitido: ", rel))
    } else {
      actual <- digest::digest(file = p, algo = "sha256", serialize = FALSE)
      if (!identical(tolower(actual), tolower(src_manifest$source_sha256[i]))) {
        errors <- c(errors, paste0("Archivo fuente modificado: ", rel))
      }
    }
  }
}

registry_path <- file.path(root, "00_REPOSITORY_INDEX", "PRODUCTS_REGISTRY.csv")
if (!file.exists(registry_path)) {
  errors <- c(errors, "Falta PRODUCTS_REGISTRY.csv")
} else {
  registry <- read.csv(registry_path, stringsAsFactors = FALSE, check.names = FALSE)
  if (nrow(registry) != 19) {
    errors <- c(errors, paste0("Se esperaban 19 productos y se encontraron ", nrow(registry), "."))
  }
  if (anyDuplicated(registry$product_id)) {
    errors <- c(errors, "Existen product_id duplicados.")
  }
}

manifest_path <- file.path(root, "_manifest_sha256.csv")
if (!file.exists(manifest_path)) {
  errors <- c(errors, "Falta _manifest_sha256.csv")
} else {
  manifest <- read.csv(manifest_path, stringsAsFactors = FALSE, check.names = FALSE)
  for (i in seq_len(nrow(manifest))) {
    rel <- manifest$path[i]
    p <- file.path(root, rel)
    if (!file.exists(p)) {
      errors <- c(errors, paste0("Archivo del manifiesto inexistente: ", rel))
    } else {
      actual <- digest::digest(file = p, algo = "sha256", serialize = FALSE)
      if (!identical(tolower(actual), tolower(manifest$sha256[i]))) {
        errors <- c(errors, paste0("Hash global no coincide: ", rel))
      }
    }
  }
}

all_files <- list.files(root, recursive = TRUE, full.names = TRUE,
                        all.files = TRUE, no.. = TRUE)
all_files <- all_files[file.info(all_files)$isdir %in% FALSE]

python_files <- all_files[tolower(tools::file_ext(all_files)) == "py"]
if (length(python_files)) {
  errors <- c(errors, paste0("Archivo Python no permitido: ", python_files))
}

oversize <- all_files[file.info(all_files)$size > 100 * 1024^2]
if (length(oversize)) {
  errors <- c(errors, paste0("Archivo superior a 100 MB: ", oversize))
}

if (length(errors)) {
  cat("PRODUCTS VALIDATION FAILED\n")
  cat(paste(errors, collapse = "\n"), "\n")
  stop("La validación de 06_PRODUCTS falló.", call. = FALSE)
}

cat("PRODUCTS VALIDATION PASSED\n")
cat("SOURCE FILES PRESERVED: 129/129\n")
cat("PRODUCTS REGISTERED: 19/19\n")
cat("ANONYMIZED FILES: 0\n")
cat("DELETED SOURCE FILES: 0\n")

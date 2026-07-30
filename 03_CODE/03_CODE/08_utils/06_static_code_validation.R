# Static validation for 03_CODE
# This script does not execute or recalculate scientific models.
# Run from RStudio with:
# source("03_CODE/08_utils/06_static_code_validation.R")

resolve_this_file <- function() {
  ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (!is.null(ofile)) return(normalizePath(ofile, winslash = "/", mustWork = TRUE))
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 1) {
    return(normalizePath(sub("^--file=", "", hit), winslash = "/", mustWork = TRUE))
  }
  stop("No fue posible resolver la ruta del validador. Ejecútelo con source() desde RStudio o mediante Rscript.")
}

script_path <- resolve_this_file()
root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)

errors <- character()
all_files <- list.files(root, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
all_files <- all_files[file.info(all_files)$isdir %in% FALSE]

oversize <- all_files[file.info(all_files)$size > 100 * 1024^2]
if (length(oversize)) {
  errors <- c(errors, paste0("Archivo superior a 100 MB: ", oversize))
}

text_files <- all_files[tolower(tools::file_ext(all_files)) %in% c("r", "md", "csv", "txt")]
for (f in text_files) {
  txt <- paste(readLines(f, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  if (grepl("[A-Za-z]:[/\\\\]", txt, perl = TRUE)) {
    errors <- c(errors, paste0("Ruta absoluta de Windows: ", f))
  }
  if (grepl("Datos_demo\\.csv", txt, ignore.case = TRUE, perl = TRUE) &&
      normalizePath(f, winslash = "/", mustWork = TRUE) != normalizePath(script_path, winslash = "/", mustWork = TRUE)) {
    errors <- c(errors, paste0("Referencia a datos sintéticos: ", f))
  }
  if (grepl("(api[_-]?key|password|secret)\\s*[=:]\\s*['\"][^'\"]+", txt,
            ignore.case = TRUE, perl = TRUE)) {
    errors <- c(errors, paste0("Posible secreto embebido: ", f))
  }
}

required <- c(
  "00_config.R",
  "00_run_pipeline.R",
  "06_hybrid_tdq/01_cap3_tdq_piess_kfas.R",
  "07_energy_projection/01_cap4_quarterly_scenario_2022Q3_2028Q4.R"
)

for (rel in required) {
  if (!file.exists(file.path(root, rel))) {
    errors <- c(errors, paste0("Archivo requerido inexistente: ", rel))
  }
}

python_files <- all_files[tolower(tools::file_ext(all_files)) == "py"]
if (length(python_files)) {
  errors <- c(errors, paste0("Archivo Python no permitido: ", python_files))
}

if (length(errors)) {
  cat("CODE VALIDATION FAILED\n")
  cat(paste(errors, collapse = "\n"), "\n")
  stop("La validación estática de 03_CODE falló.", call. = FALSE)
}

cat("CODE VALIDATION PASSED\n")

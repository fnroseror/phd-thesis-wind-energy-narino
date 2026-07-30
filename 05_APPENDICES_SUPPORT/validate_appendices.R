# Validation for 05_APPENDICES_SUPPORT
# Run from RStudio:
# source("05_APPENDICES_SUPPORT/validate_appendices.R")

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

required_docs <- c(
  "README.md",
  "Anexo_A_Trazabilidad_Datos_Control_Calidad.md",
  "Anexo_B_Resultados_Extendidos_Caracterizacion.md",
  "Anexo_C_Configuraciones_Resultados_Pipeline_Predictivo.md",
  "Anexo_D_Congelamiento_Reproducibilidad_Capitulo_3.md",
  "Anexo_E_Analisis_Complementario_Robustez_Capitulo_3.md",
  "Anexo_F_Distincion_I_TDQ_FNRR.md",
  "Anexo_G_Paquete_Canonico_Capitulo_4.md",
  "Anexo_H_Reproducibilidad_Computacional.md",
  "annex_index.csv",
  "canonical_reference_map.csv",
  "_manifest_sha256.csv"
)

for (f in required_docs) {
  if (!file.exists(file.path(root, f))) errors <- c(errors, paste0("Falta archivo requerido: ", f))
}

all_files <- list.files(root, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
all_files <- all_files[file.info(all_files)$isdir %in% FALSE]

python_files <- all_files[tolower(tools::file_ext(all_files)) == "py"]
if (length(python_files)) errors <- c(errors, paste0("Archivo Python no permitido: ", python_files))

oversize <- all_files[file.info(all_files)$size > 100 * 1024^2]
if (length(oversize)) errors <- c(errors, paste0("Archivo superior a 100 MB: ", oversize))

f_doc <- paste(readLines(file.path(root, "Anexo_F_Distincion_I_TDQ_FNRR.md"),
                         warn = FALSE, encoding = "UTF-8"), collapse = "\n")
for (term in c("I_TDQ", "Q0.50", "Q*0.90", "W0 = 1 W/m²", "E_usable")) {
  if (!grepl(term, f_doc, fixed = TRUE)) errors <- c(errors, paste0("Anexo F no contiene: ", term))
}

if (!requireNamespace("digest", quietly = TRUE)) {
  errors <- c(errors, "Falta el paquete R 'digest' para verificar SHA-256.")
} else {
  manifest <- read.csv(file.path(root, "_manifest_sha256.csv"),
                       stringsAsFactors = FALSE, check.names = FALSE)
  for (i in seq_len(nrow(manifest))) {
    p <- file.path(root, manifest$path[i])
    if (!file.exists(p)) {
      errors <- c(errors, paste0("Archivo del manifiesto inexistente: ", manifest$path[i]))
    } else {
      actual <- digest::digest(file = p, algo = "sha256", serialize = FALSE)
      if (!identical(tolower(actual), tolower(manifest$sha256[i]))) {
        errors <- c(errors, paste0("Hash no coincide: ", manifest$path[i]))
      }
    }
  }
}

if (length(errors)) {
  cat("APPENDICES VALIDATION FAILED\n")
  cat(paste(errors, collapse = "\n"), "\n")
  stop("La validación de 05_APPENDICES_SUPPORT falló.", call. = FALSE)
}

cat("APPENDICES VALIDATION PASSED\n")

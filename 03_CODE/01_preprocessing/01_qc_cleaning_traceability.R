# ============================================================
# 01_qc_cleaning_traceability.R
# Preprocesamiento inicial + control de calidad + trazabilidad
# Tesis doctoral - Favio Nicolás Rosero Rodríguez
# ============================================================

rm(list = ls())
gc()

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
  library(stringr)
})

# ============================================================
# 1. RUTA OFICIAL UNIFICADA
# ============================================================

BASE_FILE <- "H:/Mi unidad/Academia/UNAL/DOCTORADO/Cierre Tesis/Datos.txt"
stopifnot(file.exists(BASE_FILE))

BASE_DIR <- dirname(BASE_FILE)
OUT_DIR  <- file.path(BASE_DIR, "SALIDAS_PREPROCESSING", "01_QC")
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

# ============================================================
# 2. FUNCIONES AUXILIARES
# ============================================================

logi <- function(...) {
  cat(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "|", ..., "\n")
}

read_any_delim <- function(path) {
  dt <- tryCatch(
    fread(path, sep = "\t", header = TRUE, data.table = TRUE, showProgress = TRUE, encoding = "UTF-8"),
    error = function(e) NULL
  )

  if (is.null(dt)) {
    dt <- fread(path, header = TRUE, data.table = TRUE, showProgress = TRUE, encoding = "UTF-8")
  }

  if (ncol(dt) == 1L) {
    x <- dt[[1]]
    tmp <- tstrsplit(x, split = ";", fixed = TRUE)
    if (length(tmp) < 5) tmp <- tstrsplit(x, split = ",", fixed = TRUE)
    if (length(tmp) < 5) tmp <- tstrsplit(x, split = "\\s+", perl = TRUE)

    if (length(tmp) >= 5) {
      dt <- as.data.table(tmp)[, 1:5]
      setnames(dt, c("Estación", "FechaYHora", "Valor", "Zona", "Variable"))
    }
  }

  if (!("Estación" %in% names(dt)) && ("Estacion" %in% names(dt))) {
    setnames(dt, "Estacion", "Estación")
  }

  dt
}

parse_dt <- function(x, tz = "America/Bogota") {
  x <- str_trim(as.character(x))
  x <- str_replace_all(x, fixed("a. m."), "AM")
  x <- str_replace_all(x, fixed("p. m."), "PM")
  x <- str_replace_all(x, fixed("a.m."), "AM")
  x <- str_replace_all(x, fixed("p.m."), "PM")
  x <- str_replace_all(x, fixed(" am"), " AM")
  x <- str_replace_all(x, fixed(" pm"), " PM")

  y <- suppressWarnings(ymd_hms(x, tz = tz))
  if (all(is.na(y))) y <- suppressWarnings(ymd_hm(x, tz = tz))
  if (all(is.na(y))) y <- suppressWarnings(dmy_hms(x, tz = tz))
  if (all(is.na(y))) y <- suppressWarnings(dmy_hm(x, tz = tz))
  if (all(is.na(y))) y <- suppressWarnings(mdy_hms(x, tz = tz))
  if (all(is.na(y))) y <- suppressWarnings(mdy_hm(x, tz = tz))

  if (all(is.na(y))) {
    y <- suppressWarnings(parse_date_time(
      x,
      orders = c(
        "Ymd HMS", "Ymd HM",
        "dmY HMS", "dmY HM",
        "mdY HMS", "mdY HM",
        "d/m/Y I:M:S p", "d/m/Y I:M p",
        "m/d/Y I:M:S p", "m/d/Y I:M p"
      ),
      tz = tz
    ))
  }

  y
}

norm_var <- function(v) {
  v <- toupper(trimws(as.character(v)))
  v <- gsub("\\s+", "", v)

  if (v %in% c("VV", "VELVIENTO", "VELOCIDADVIENTO", "WINDSPEED", "WS")) return("VV")
  if (v %in% c("DV", "DIRVIENTO", "DIRECCIONVIENTO", "DIRECCIÓNVIENTO", "WINDDIR")) return("DV")
  if (v %in% c("PA", "PRESION", "PRESIONATM", "PRESIONATMOSFERICA", "PRESIÓNATMOSFÉRICA", "PRESSURE")) return("PA")
  if (v %in% c("HR", "HUMEDADRELATIVA", "RH")) return("HR")
  if (v %in% c("EV", "EVAPORACION", "EVAPORACIÓN")) return("EV")
  if (v %in% c("NU", "NUBOSIDAD", "CLOUDINESS")) return("NU")
  if (v %in% c("PR", "PRECIPITACION", "PRECIPITACIÓN", "PREC")) return("PR")
  if (v %in% c("FA", "FENOMENOATMOSFERICO", "FENÓMENOATMOSFÉRICO")) return("FA")
  if (v %in% c("TM", "TEMP", "TEMPERATURA", "TMEAN", "T")) return("TM")
  if (v %in% c("TMIN", "TEMPERATURAMINIMA", "TEMPERATURAMÍNIMA")) return("TMIN")
  if (v %in% c("TMAX", "TEMPERATURAMAXIMA", "TEMPERATURAMÁXIMA")) return("TMAX")

  v
}

is_nonphysical_negative <- function(var, value) {
  if (!is.finite(value)) return(FALSE)
  var <- as.character(var)

  if (var %in% c("VV", "DV", "PA", "HR", "EV", "NU", "PR")) {
    return(value < 0)
  }

  FALSE
}

calc_resolution <- function(d) {
  d <- d[order(FechaHora)]
  if (nrow(d) < 3) return(NA_real_)

  mins <- as.numeric(diff(d$FechaHora), units = "mins")
  mins <- mins[is.finite(mins) & mins > 0]

  if (length(mins) == 0) return(NA_real_)
  median(mins, na.rm = TRUE)
}

# ============================================================
# 3. LECTURA DE DATOS
# ============================================================

logi("Leyendo archivo fuente:", BASE_FILE)
DT <- read_any_delim(BASE_FILE)

req_cols <- c("Estación", "FechaYHora", "Valor", "Zona", "Variable")
miss <- setdiff(req_cols, names(DT))

if (length(miss) > 0) {
  stop("Faltan columnas requeridas: ", paste(miss, collapse = ", "))
}

setnames(DT, old = names(DT), new = str_trim(names(DT)))

TRACE_GLOBAL <- data.table(
  paso = c(
    "01_inicial",
    "02_parseo_campos",
    "03_remover_NA_esenciales",
    "04_remover_negativos_no_fisicos",
    "05_final_qc"
  ),
  n = NA_integer_
)

TRACE_GLOBAL[paso == "01_inicial", n := nrow(DT)]

# ============================================================
# 4. PARSEO Y NORMALIZACIÓN
# ============================================================

DT[, Valor_raw     := Valor]
DT[, Variable_raw  := Variable]
DT[, FechaYHora_raw := FechaYHora]

DT[, Valor    := suppressWarnings(as.numeric(gsub(",", ".", as.character(Valor))))]
DT[, Zona     := suppressWarnings(as.integer(as.character(Zona)))]
DT[, Variable := vapply(Variable, norm_var, character(1))]
DT[, FechaHora := parse_dt(FechaYHora)]

TRACE_GLOBAL[paso == "02_parseo_campos", n := nrow(DT)]

# ============================================================
# 5. CONTROL DE CALIDAD GENERAL
# ============================================================

DT[, neg_no_fisico := mapply(is_nonphysical_negative, Variable, Valor)]

A1 <- data.table(
  n_rows_raw   = nrow(DT),
  n_cols_raw   = ncol(DT),
  n_zonas      = uniqueN(DT$Zona, na.rm = TRUE),
  n_variables  = uniqueN(DT$Variable, na.rm = TRUE),
  n_estaciones = uniqueN(DT$`Estación`),
  fecha_min    = suppressWarnings(min(DT$FechaHora, na.rm = TRUE)),
  fecha_max    = suppressWarnings(max(DT$FechaHora, na.rm = TRUE))
)
fwrite(A1, file.path(OUT_DIR, "01_A1_QC_General.csv"))

A2 <- DT[, .(
  n = .N,
  na_valor = sum(is.na(Valor) | !is.finite(Valor)),
  na_fecha = sum(is.na(FechaHora)),
  na_zona  = sum(is.na(Zona)),
  negativos_no_fisicos = sum(neg_no_fisico, na.rm = TRUE)
), by = .(Variable)][order(Variable)]
fwrite(A2, file.path(OUT_DIR, "02_A2_QC_NA_y_Negativos_por_Variable.csv"))

DT1 <- DT[
  !is.na(Valor) & is.finite(Valor) &
    !is.na(FechaHora) &
    !is.na(Zona) &
    !is.na(Variable)
]
TRACE_GLOBAL[paso == "03_remover_NA_esenciales", n := nrow(DT1)]

DT2 <- DT1[neg_no_fisico == FALSE]
TRACE_GLOBAL[paso == "04_remover_negativos_no_fisicos", n := nrow(DT2)]

setorder(DT2, Zona, `Estación`, Variable, FechaHora)

TRACE_GLOBAL[paso == "05_final_qc", n := nrow(DT2)]
fwrite(TRACE_GLOBAL, file.path(OUT_DIR, "03_TRACE_Global_Limpieza.csv"))

# ============================================================
# 6. TRAZABILIDAD ESPECÍFICA PARA VV
# ============================================================

DT_VV0 <- DT[Variable == "VV"]

TRACE_VV <- data.table(
  paso = c(
    "Inicial VV",
    "Quitar NA/Inf",
    "Quitar negativos (v < 0)"
  ),
  n = NA_integer_
)

TRACE_VV[paso == "Inicial VV", n := nrow(DT_VV0)]

DT_VV1 <- DT_VV0[
  !is.na(Valor) &
    is.finite(Valor) &
    !is.na(FechaHora)
]
TRACE_VV[paso == "Quitar NA/Inf", n := nrow(DT_VV1)]

DT_VV2 <- DT_VV1[Valor >= 0]
TRACE_VV[paso == "Quitar negativos (v < 0)", n := nrow(DT_VV2)]

fwrite(TRACE_VV, file.path(OUT_DIR, "04_TRACE_VV_Limpieza.csv"))

# ============================================================
# 7. RESOLUCIÓN TEMPORAL
# ============================================================

A3 <- DT2[, .(
  delta_min_mediana = calc_resolution(.SD),
  n = .N
), by = .(Zona, `Estación`, Variable)]

setorder(A3, Zona, `Estación`, Variable)
fwrite(A3, file.path(OUT_DIR, "05_A3_Resolucion_Temporal_por_Zona_Estacion_Variable.csv"))

# ============================================================
# 8. TRAZABILIDAD ESTACIÓN-ZONA
# ============================================================

A4 <- unique(DT2[, .(Zona, `Estación`)])[order(Zona, `Estación`)]
fwrite(A4, file.path(OUT_DIR, "06_A4_Trazabilidad_Estacion_Zona.csv"))

# ============================================================
# 9. EXPORTAR DATASET LIMPIO EN FORMATO LARGO
# ============================================================

DT_CLEAN <- DT2[, .(
  Estación,
  FechaHora,
  Valor,
  Zona,
  Variable
)]

fwrite(
  DT_CLEAN,
  file.path(OUT_DIR, "07_Datos_Largos_QC.txt"),
  sep = "\t"
)

# ============================================================
# 10. SESSION INFO
# ============================================================

sink(file.path(OUT_DIR, "08_sessionInfo.txt"))
print(sessionInfo())
sink()

# ============================================================
# 11. CIERRE
# ============================================================

logi("QC finalizado correctamente.")
logi("Salida principal:", OUT_DIR)
logi("Archivo limpio:", file.path(OUT_DIR, "07_Datos_Largos_QC.txt"))

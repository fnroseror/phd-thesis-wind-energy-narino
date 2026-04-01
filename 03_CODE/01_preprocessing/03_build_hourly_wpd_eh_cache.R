# ============================================================
# 03_build_hourly_wpd_eh_cache.R
# Construcción del cache horario WPD + Eh por zona
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

QC_FILE <- file.path(
  BASE_DIR, "SALIDAS_PREPROCESSING", "01_QC", "07_Datos_Largos_QC.txt"
)

OUT_DIR <- file.path(
  BASE_DIR, "SALIDAS_PREPROCESSING", "03_WPD_EH_CACHE"
)

OUT_FILE <- file.path(
  OUT_DIR, "WPD_Eh_hourly_por_zona.csv"
)

LOG_FILE <- file.path(
  OUT_DIR, "03_build_hourly_wpd_eh_cache_log.txt"
)

dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

# ============================================================
# 2. CONFIGURACIÓN
# ============================================================

TZ_LOCAL      <- "America/Bogota"
R_AIR         <- 287.05
RHO0_DEFAULT  <- 1.10
RESAMPLE_UNIT <- "hour"

# ============================================================
# 3. FUNCIONES AUXILIARES
# ============================================================

logi <- function(...) {
  msg <- paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "|", paste(..., collapse = " "))
  cat(msg, "\n")
  cat(msg, "\n", file = LOG_FILE, append = TRUE)
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

parse_dt <- function(x, tz = TZ_LOCAL) {
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
  if (v %in% c("PA", "PRESION", "PRESIONATM", "PRESIONATMOSFERICA", "PRESIÓNATMOSFÉRICA", "PRESSURE")) return("PA")
  if (v %in% c("TM", "TEMP", "TEMPERATURA", "TMEAN", "T")) return("TM")
  if (v %in% c("TMIN", "TEMPERATURAMINIMA", "TEMPERATURAMÍNIMA")) return("TMIN")
  if (v %in% c("TMAX", "TEMPERATURAMAXIMA", "TEMPERATURAMÁXIMA")) return("TMAX")

  v
}

to_pa <- function(p) {
  p <- as.numeric(p)
  med <- median(p, na.rm = TRUE)
  if (is.finite(med) && med < 2000) p * 100 else p
}

to_kelvin <- function(t) {
  t <- as.numeric(t)
  med <- median(t, na.rm = TRUE)
  if (is.finite(med) && med < 100) t + 273.15 else t
}

agg_fun <- function(varname, x) {
  vn <- tolower(as.character(varname))
  if (vn %in% c("pr", "prec", "precipitacion", "precipitación")) {
    return(sum(x, na.rm = TRUE))
  }
  mean(x, na.rm = TRUE)
}

# ============================================================
# 4. LECTURA DE LA FUENTE
# ============================================================

SOURCE_FILE <- if (file.exists(QC_FILE)) QC_FILE else BASE_FILE
logi("Fuente seleccionada:", SOURCE_FILE)

DT <- read_any_delim(SOURCE_FILE)

# Si viene del archivo limpio
if (all(c("Estación", "FechaHora", "Valor", "Zona", "Variable") %in% names(DT))) {
  DT[, FechaHora := as.POSIXct(FechaHora, tz = TZ_LOCAL)]
}

# Si viene del archivo bruto
if (!("FechaHora" %in% names(DT))) {
  req_cols <- c("Estación", "FechaYHora", "Valor", "Zona", "Variable")
  miss <- setdiff(req_cols, names(DT))
  if (length(miss) > 0) {
    stop("Faltan columnas requeridas: ", paste(miss, collapse = ", "))
  }

  DT[, FechaHora := parse_dt(FechaYHora)]
}

DT[, Zona := suppressWarnings(as.integer(as.character(Zona)))]
DT[, Valor := suppressWarnings(as.numeric(gsub(",", ".", as.character(Valor))))]
DT[, Variable := vapply(Variable, norm_var, character(1))]

DT <- DT[
  !is.na(Zona) &
    !is.na(FechaHora) &
    is.finite(Valor)
]

# Variables necesarias para rho, WPD y Eh base
DT <- DT[Variable %in% c("VV", "PA", "TM", "TMIN", "TMAX")]

if (nrow(DT) == 0) {
  stop("No quedaron datos útiles para construir WPD y Eh.")
}

setorder(DT, Zona, Variable, FechaHora)
logi("Lectura y filtrado OK | filas:", nrow(DT), "| zonas:", paste(sort(unique(DT$Zona)), collapse = ","))

# ============================================================
# 5. AGREGACIÓN HORARIA
# ============================================================

DT[, FechaHora := floor_date(FechaHora, unit = RESAMPLE_UNIT)]

H <- DT[, .(
  Valor = agg_fun(Variable[1], Valor)
), by = .(Zona, FechaHora, Variable)]

W <- dcast(H, Zona + FechaHora ~ Variable, value.var = "Valor")
setorder(W, Zona, FechaHora)

logi("Agregación horaria OK | filas:", nrow(W), "| columnas:", ncol(W))

# ============================================================
# 6. CONSTRUCCIÓN FÍSICA
# ============================================================

if (!("TM" %in% names(W))) {
  if (all(c("TMIN", "TMAX") %in% names(W))) {
    W[, TM := (TMIN + TMAX) / 2]
  } else {
    stop("No se encontró TM ni la combinación TMIN/TMAX.")
  }
}

if (!("PA" %in% names(W))) stop("No se encontró PA.")
if (!("VV" %in% names(W))) stop("No se encontró VV.")

W[, VV := pmax(as.numeric(VV), 0)]
W[, PA := to_pa(PA)]
W[, TM := to_kelvin(TM)]

W[, rho := fifelse(
  is.finite(PA) & is.finite(TM) & TM > 0,
  PA / (R_AIR * TM),
  RHO0_DEFAULT
)]

W[, WPD := 0.5 * rho * (VV^3)]

# Eh horario base:
# este Eh NO es todavía la energía integrada por horizonte h;
# esa integración se hace después en ML/DL con calc_Eh(x, h).
W[, Eh := WPD / 1000]

# ============================================================
# 7. CONTROL FÍSICO BÁSICO
# ============================================================

W[!(is.finite(rho) & rho > 0.5 & rho < 2.0), rho := NA_real_]
W[!(is.finite(WPD) & WPD >= 0), WPD := NA_real_]
W[!(is.finite(Eh)  & Eh  >= 0), Eh  := NA_real_]

# ============================================================
# 8. RESÚMENES DE TRAZABILIDAD
# ============================================================

RES_ZONA <- W[, .(
  n_rows   = .N,
  fecha_min = min(FechaHora, na.rm = TRUE),
  fecha_max = max(FechaHora, na.rm = TRUE),
  n_vv   = sum(is.finite(VV)),
  n_pa   = sum(is.finite(PA)),
  n_tm   = sum(is.finite(TM)),
  n_rho  = sum(is.finite(rho)),
  n_wpd  = sum(is.finite(WPD)),
  n_eh   = sum(is.finite(Eh)),
  rho_mean = mean(rho, na.rm = TRUE),
  wpd_mean = mean(WPD, na.rm = TRUE),
  eh_mean  = mean(Eh, na.rm = TRUE)
), by = Zona]

fwrite(RES_ZONA, file.path(OUT_DIR, "01_resumen_wpd_eh_por_zona.csv"))

RES_GLOBAL <- data.table(
  n_rows      = nrow(W),
  n_zonas     = uniqueN(W$Zona),
  fecha_min   = min(W$FechaHora, na.rm = TRUE),
  fecha_max   = max(W$FechaHora, na.rm = TRUE),
  n_wpd_valid = sum(is.finite(W$WPD)),
  n_eh_valid  = sum(is.finite(W$Eh)),
  rho_mean    = mean(W$rho, na.rm = TRUE),
  wpd_mean    = mean(W$WPD, na.rm = TRUE),
  eh_mean     = mean(W$Eh, na.rm = TRUE)
)

fwrite(RES_GLOBAL, file.path(OUT_DIR, "02_resumen_global_wpd_eh_cache.csv"))

# ============================================================
# 9. EXPORTACIÓN DEL CACHE FINAL
# ============================================================

CACHE_WPD_EH <- W[, .(
  Zona,
  FechaHora,
  VV,
  PA,
  TM,
  rho,
  WPD,
  Eh
)]

fwrite(CACHE_WPD_EH, OUT_FILE)
logi("Cache exportado:", OUT_FILE)

# ============================================================
# 10. SESSION INFO
# ============================================================

sink(file.path(OUT_DIR, "03_sessionInfo.txt"))
print(sessionInfo())
sink()

# ============================================================
# 11. CIERRE
# ============================================================

logi("Script finalizado correctamente.")
logi("Nota científica: Eh en este archivo es horario base (WPD/1000).")
logi("La integración por horizonte h se realiza en los pipelines de modelado.")

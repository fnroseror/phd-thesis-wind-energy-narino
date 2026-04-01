# ============================================================
# 04_physical_variable_construction.R
# Funciones físicas reutilizables del repositorio doctoral
# Tesis doctoral - Favio Nicolás Rosero Rodríguez
# ============================================================

rm(list = ls())
gc()

suppressPackageStartupMessages({
  library(data.table)
})

# ============================================================
# 1. CONSTANTES FÍSICAS
# ============================================================

R_AIR <- 287.05          # J/(kg·K), constante específica del aire seco
RHO0_DEFAULT <- 1.10     # valor de respaldo cuando faltan P o T

# ============================================================
# 2. NORMALIZACIÓN DE VARIABLES
# ============================================================

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

# ============================================================
# 3. CONVERSIONES FÍSICAS DE UNIDADES
# ============================================================

to_pa <- function(p) {
  p <- as.numeric(p)
  med <- median(p, na.rm = TRUE)

  # Si la presión viene en hPa, se convierte a Pa
  if (is.finite(med) && med < 2000) {
    return(p * 100)
  }

  p
}

to_kelvin <- function(t) {
  t <- as.numeric(t)
  med <- median(t, na.rm = TRUE)

  # Si la temperatura parece estar en °C, se convierte a K
  if (is.finite(med) && med < 100) {
    return(t + 273.15)
  }

  t
}

# ============================================================
# 4. DENSIDAD DEL AIRE
# ============================================================

compute_rho <- function(PA, TM, fallback = RHO0_DEFAULT) {
  PA <- as.numeric(PA)
  TM <- as.numeric(TM)

  rho <- ifelse(
    is.finite(PA) & is.finite(TM) & TM > 0,
    PA / (R_AIR * TM),
    fallback
  )

  as.numeric(rho)
}

# ============================================================
# 5. DENSIDAD DE POTENCIA EÓLICA
# ============================================================

compute_wpd <- function(VV, rho) {
  VV  <- pmax(as.numeric(VV), 0)
  rho <- as.numeric(rho)

  WPD <- 0.5 * rho * (VV^3)
  WPD[!(is.finite(WPD) & WPD >= 0)] <- NA_real_

  as.numeric(WPD)
}

# ============================================================
# 6. ENERGÍA HORARIA BASE
# ============================================================
# Nota:
# En varios scripts finales se usa Eh = WPD / 1000 como cantidad
# horaria base en kWh/m² por hora.
# Esto NO reemplaza la integración por horizonte.
# ============================================================

compute_eh_hourly_base <- function(WPD) {
  Eh <- as.numeric(WPD) / 1000
  Eh[!(is.finite(Eh) & Eh >= 0)] <- NA_real_

  as.numeric(Eh)
}

# ============================================================
# 7. ENERGÍA INTEGRADA POR HORIZONTE
# ============================================================
# Esta función corresponde a la lógica usada después en ML/DL:
# suma acumulada por ventana h.
# ============================================================

compute_eh_horizon <- function(x, h) {
  x <- as.numeric(x)

  if (!is.finite(h) || h < 1) {
    stop("El horizonte h debe ser un entero positivo.")
  }

  if (length(x) < h) {
    return(rep(NA_real_, length(x)))
  }

  as.numeric(stats::filter(x, rep(1, h), sides = 1))
}

# ============================================================
# 8. CONSTRUCCIÓN FÍSICA DIRECTA SOBRE UN DATASET ANCHO
# ============================================================
# Requiere al menos:
#   - VV
#   - PA o equivalente
#   - TM o la combinación TMIN/TMAX
# ============================================================

build_physical_variables <- function(W, fallback_rho = RHO0_DEFAULT) {
  W <- as.data.table(copy(W))

  # -------------------------
  # Verificación mínima
  # -------------------------
  if (!("VV" %in% names(W))) {
    stop("La tabla no contiene la variable VV.")
  }

  if (!("PA" %in% names(W))) {
    stop("La tabla no contiene la variable PA.")
  }

  if (!("TM" %in% names(W))) {
    if (all(c("TMIN", "TMAX") %in% names(W))) {
      W[, TM := (TMIN + TMAX) / 2]
    } else {
      stop("La tabla no contiene TM ni la combinación TMIN/TMAX.")
    }
  }

  # -------------------------
  # Conversión de unidades
  # -------------------------
  W[, VV := pmax(as.numeric(VV), 0)]
  W[, PA := to_pa(PA)]
  W[, TM := to_kelvin(TM)]

  # -------------------------
  # Variables físicas
  # -------------------------
  W[, rho := compute_rho(PA, TM, fallback = fallback_rho)]
  W[, WPD := compute_wpd(VV, rho)]
  W[, Eh  := compute_eh_hourly_base(WPD)]

  # -------------------------
  # Control físico básico
  # -------------------------
  W[!(is.finite(rho) & rho > 0.5 & rho < 2.0), rho := NA_real_]
  W[!(is.finite(WPD) & WPD >= 0), WPD := NA_real_]
  W[!(is.finite(Eh)  & Eh  >= 0), Eh  := NA_real_]

  W[]
}

# ============================================================
# 9. RESUMEN FÍSICO BÁSICO
# ============================================================

summarize_physical_variables <- function(W, by_zone = TRUE) {
  W <- as.data.table(copy(W))

  req <- c("VV", "PA", "TM", "rho", "WPD", "Eh")
  miss <- setdiff(req, names(W))

  if (length(miss) > 0) {
    stop("Faltan columnas para el resumen físico: ", paste(miss, collapse = ", "))
  }

  if (by_zone) {
    if (!("Zona" %in% names(W))) {
      stop("No existe la columna Zona.")
    }

    return(
      W[, .(
        n_rows   = .N,
        n_vv     = sum(is.finite(VV)),
        n_pa     = sum(is.finite(PA)),
        n_tm     = sum(is.finite(TM)),
        n_rho    = sum(is.finite(rho)),
        n_wpd    = sum(is.finite(WPD)),
        n_eh     = sum(is.finite(Eh)),
        vv_mean  = mean(VV,  na.rm = TRUE),
        rho_mean = mean(rho, na.rm = TRUE),
        wpd_mean = mean(WPD, na.rm = TRUE),
        eh_mean  = mean(Eh,  na.rm = TRUE)
      ), by = Zona]
    )
  }

  data.table(
    n_rows   = nrow(W),
    n_vv     = sum(is.finite(W$VV)),
    n_pa     = sum(is.finite(W$PA)),
    n_tm     = sum(is.finite(W$TM)),
    n_rho    = sum(is.finite(W$rho)),
    n_wpd    = sum(is.finite(W$WPD)),
    n_eh     = sum(is.finite(W$Eh)),
    vv_mean  = mean(W$VV,  na.rm = TRUE),
    rho_mean = mean(W$rho, na.rm = TRUE),
    wpd_mean = mean(W$WPD, na.rm = TRUE),
    eh_mean  = mean(W$Eh,  na.rm = TRUE)
  )
}

# ============================================================
# 10. NOTA FINAL
# ============================================================
# Este archivo centraliza las fórmulas físicas del repositorio.
# Puede ser cargado con source() desde otros scripts para evitar
# duplicación de código y mantener coherencia metodológica.
# ============================================================

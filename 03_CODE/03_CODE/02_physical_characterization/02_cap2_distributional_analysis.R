# -*- coding: UTF-8 -*-
# ============================================================
# 02_cap2_B_analisis_fisico_estadistico_multizona_V2.R
# CAPÍTULO 2 — PARTE B
# Análisis físico-estadístico multizona de VV y WPD — V2 depurada
# Tesis doctoral
# Favio Nicolás Rosero Rodríguez
# ============================================================
#
# Propósito:
#   Generar de manera limpia y reproducible los productos ya
#   consolidados para la Parte B del Capítulo 2:
#
#   1. Dataset principal VV/WPD con control de calidad del Artículo 1.
#   2. Estadísticos descriptivos por zona.
#   3. Series mensuales de VV y WPD por zona.
#   4. Distribuciones de VV y WPD por zona.
#   5. Ajustes Weibull/Rayleigh para VV positiva por zona.
#   6. Métricas de ajuste y mejor distribución por zona.
#   7. Figuras en español para tesis.
#   8. Versiones complementarias con eje común y zoom visual para WPD.
#
# Entrada principal esperada:
#   02E_article_main_wpd_dataset_after_qc.rds
#
# Columnas esperadas:
#   zone, datetime, VV, WPD, rho_used
#
# Nota:
#   Este script recalcula los resultados para tesis a partir del
#   dataset principal QC del Artículo 1. No depende de figuras previas.
#
# ============================================================

rm(list = ls())
gc()

source(file.path("03_CODE", "00_config.R"))


options(warn = 1)

cat("\n============================================================\n")
cat("CAPÍTULO 2 — PARTE B: ANÁLISIS FÍSICO-ESTADÍSTICO MULTIZONA\n")
cat("Inicio:", as.character(Sys.time()), "\n")
cat("============================================================\n\n")

# ============================================================
# 1. PAQUETES
# ============================================================

required_packages <- c(
  "data.table",
  "dplyr",
  "lubridate",
  "stringr",
  "ggplot2",
  "scales",
  "fitdistrplus",
  "moments",
  "openxlsx",
  "ragg",
  "svglite"
)

install_if_missing <- function(pkgs) {
  installed <- rownames(installed.packages())
  missing <- pkgs[!pkgs %in% installed]

  if (length(missing) > 0) {
    for (pkg in missing) {
      install.packages(pkg, dependencies = TRUE)
    }
  }
}

install_if_missing(required_packages)

suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(lubridate)
  library(stringr)
  library(ggplot2)
  library(scales)
  library(fitdistrplus)
  library(moments)
  library(openxlsx)
})

# ============================================================
# 2. RUTAS
# ============================================================

# Carpeta de salida oficial del Capítulo 2.
CAP_DIR <- file.path(TDQ_WORK_DIR, "02_physical_characterization")

DIR_INPUTS    <- file.path(CAP_DIR, "00_inputs")
DIR_CODE      <- file.path(CAP_DIR, "01_code")
DIR_TABLES    <- file.path(CAP_DIR, "02_tables")
DIR_FIGURES   <- file.path(CAP_DIR, "03_figures")
DIR_TEXTOS    <- file.path(CAP_DIR, "04_textos_para_insertar")
DIR_LOGS      <- file.path(CAP_DIR, "05_logs")
DIR_PROCESSED <- file.path(CAP_DIR, "06_processed")

dirs <- c(
  CAP_DIR, DIR_INPUTS, DIR_CODE, DIR_TABLES,
  DIR_FIGURES, DIR_TEXTOS, DIR_LOGS, DIR_PROCESSED
)

invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))

# Posibles ubicaciones del flujo del Artículo 1.
ARTICLE_ROOT_CANDIDATES <- c(
  file.path(TDQ_REPO_ROOT, "06_PRODUCTS", "01_articles", "article_01_energy_reports"),
  file.path(TDQ_WORK_DIR, "external_inputs", "article_01"),
  file.path(CAP_DIR, "00_inputs", "article_01_energy_reports")
)

# ============================================================
# 3. LOG Y EXPORTACIÓN
# ============================================================

LOG_FILE <- file.path(
  DIR_LOGS,
  paste0("log_cap2_B_analisis_fisico_estadistico_multizona_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
)

logi <- function(...) {
  msg <- paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "|", paste(..., collapse = " "))
  cat(msg, "\n")
  cat(msg, "\n", file = LOG_FILE, append = TRUE)
}

exportar_tabla <- function(df, nombre_archivo) {
  ruta_csv  <- file.path(DIR_TABLES, paste0(nombre_archivo, ".csv"))
  ruta_xlsx <- file.path(DIR_TABLES, paste0(nombre_archivo, ".xlsx"))

  data.table::fwrite(as.data.frame(df), ruta_csv, bom = TRUE)
  openxlsx::write.xlsx(as.data.frame(df), ruta_xlsx, overwrite = TRUE)

  logi("Tabla exportada:", ruta_csv)
  invisible(ruta_csv)
}

exportar_figura <- function(plot_obj, nombre_archivo, width = 9, height = 6.6, dpi = 600) {
  ruta_png <- file.path(DIR_FIGURES, paste0(nombre_archivo, ".png"))
  ruta_pdf <- file.path(DIR_FIGURES, paste0(nombre_archivo, ".pdf"))
  ruta_svg <- file.path(DIR_FIGURES, paste0(nombre_archivo, ".svg"))

  ggplot2::ggsave(
    filename = ruta_png,
    plot = plot_obj,
    width = width,
    height = height,
    units = "in",
    dpi = dpi,
    bg = "white",
    device = ragg::agg_png
  )

  ggplot2::ggsave(
    filename = ruta_pdf,
    plot = plot_obj,
    width = width,
    height = height,
    units = "in",
    bg = "white",
    device = grDevices::cairo_pdf
  )

  ggplot2::ggsave(
    filename = ruta_svg,
    plot = plot_obj,
    width = width,
    height = height,
    units = "in",
    bg = "white",
    device = svglite::svglite
  )

  logi("Figura exportada:", ruta_png)
  invisible(ruta_png)
}

# ============================================================
# 4. LOCALIZACIÓN ROBUSTA DEL DATASET VV/WPD
# ============================================================

buscar_archivo <- function(nombre_archivo, roots) {
  # Búsqueda directa en rutas esperadas.
  directos <- character(0)

  for (root in roots) {
    directos <- c(
      directos,
      file.path(root, "01_data_processed", nombre_archivo),
      file.path(root, nombre_archivo)
    )
  }

  directos <- directos[file.exists(directos)]

  if (length(directos) > 0) {
    return(normalizePath(directos[1], winslash = "/", mustWork = TRUE))
  }

  # Búsqueda recursiva controlada.
  roots_existentes <- roots[dir.exists(roots)]

  for (root in roots_existentes) {
    candidatos <- list.files(
      root,
      pattern = paste0("^", gsub("\\.", "\\\\.", nombre_archivo), "$"),
      recursive = TRUE,
      full.names = TRUE
    )

    if (length(candidatos) > 0) {
      return(normalizePath(candidatos[1], winslash = "/", mustWork = TRUE))
    }
  }

  NA_character_
}

INPUT_MAIN_WPD_RDS <- buscar_archivo(
  "02E_article_main_wpd_dataset_after_qc.rds",
  ARTICLE_ROOT_CANDIDATES
)

INPUT_MAIN_WPD_CSV <- buscar_archivo(
  "02E_article_main_wpd_dataset_after_qc.csv",
  ARTICLE_ROOT_CANDIDATES
)

if (is.na(INPUT_MAIN_WPD_RDS) && is.na(INPUT_MAIN_WPD_CSV)) {
  stop(
    "No se encontró el dataset principal VV/WPD del Artículo 1. ",
    "Ejecute primero el flujo del Artículo 1 hasta 02E, o copie ",
    "02E_article_main_wpd_dataset_after_qc.rds/csv a una ruta dentro del artículo."
  )
}

logi("Dataset RDS localizado:", INPUT_MAIN_WPD_RDS)
logi("Dataset CSV localizado:", INPUT_MAIN_WPD_CSV)

# ============================================================
# 5. CARGA Y ESTANDARIZACIÓN
# ============================================================

if (!is.na(INPUT_MAIN_WPD_RDS)) {
  dt_main <- readRDS(INPUT_MAIN_WPD_RDS)
} else {
  dt_main <- data.table::fread(INPUT_MAIN_WPD_CSV, encoding = "UTF-8")
}

dt_main <- data.table::as.data.table(dt_main)

normalizar_columna_si_existe <- function(dt, candidatos, nuevo) {
  hit <- candidatos[candidatos %in% names(dt)]
  if (length(hit) > 0 && !(nuevo %in% names(dt))) {
    data.table::setnames(dt, hit[1], nuevo)
  }
  invisible(dt)
}

normalizar_columna_si_existe(dt_main, c("Zona", "zone", "Zone", "analytical_zone"), "zone")
normalizar_columna_si_existe(dt_main, c("FechaYHora", "datetime", "DateTime", "fecha_hora"), "datetime")
normalizar_columna_si_existe(dt_main, c("VV", "wind_speed", "WindSpeed", "Vv"), "VV")
normalizar_columna_si_existe(dt_main, c("WPD", "wind_power_density", "WindPowerDensity"), "WPD")
normalizar_columna_si_existe(dt_main, c("rho_used", "rho", "air_density", "rho_daily_zone"), "rho_used")

required_main_columns <- c("zone", "datetime", "VV", "WPD")

missing_main_columns <- setdiff(required_main_columns, names(dt_main))

if (length(missing_main_columns) > 0) {
  stop(
    "El dataset principal no contiene las columnas requeridas: ",
    paste(missing_main_columns, collapse = ", "),
    ". Columnas disponibles: ",
    paste(names(dt_main), collapse = ", ")
  )
}

dt_main[, datetime := as.POSIXct(datetime, tz = "America/Bogota")]
dt_main[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
dt_main[, VV := suppressWarnings(as.numeric(VV))]
dt_main[, WPD := suppressWarnings(as.numeric(WPD))]

if ("rho_used" %in% names(dt_main)) {
  dt_main[, rho_used := suppressWarnings(as.numeric(rho_used))]
} else {
  dt_main[, rho_used := NA_real_]
}

dt_main <- dt_main[
  !is.na(zone) &
    !is.na(datetime) &
    !is.na(VV) &
    !is.na(WPD) &
    is.finite(VV) &
    is.finite(WPD) &
    VV >= 0 &
    WPD >= 0
]

dt_main[, fecha := as.Date(datetime)]
dt_main[, year := lubridate::year(datetime)]
dt_main[, month := lubridate::month(datetime)]
dt_main[, year_month := format(datetime, "%Y-%m")]
dt_main[, date_month := as.Date(paste0(year_month, "-01"))]

data.table::setorder(dt_main, zone, datetime)

saveRDS(
  dt_main,
  file.path(DIR_PROCESSED, "cap2_B_dataset_principal_VV_WPD_QC_articulo1.rds")
)

data.table::fwrite(
  dt_main,
  file.path(DIR_PROCESSED, "cap2_B_dataset_principal_VV_WPD_QC_articulo1.csv"),
  bom = TRUE
)

logi("Dataset principal cargado.")
logi("Filas:", nrow(dt_main))
logi("Zonas:", paste(levels(dt_main$zone), collapse = ", "))
logi("Fecha mínima:", as.character(min(dt_main$datetime, na.rm = TRUE)))
logi("Fecha máxima:", as.character(max(dt_main$datetime, na.rm = TRUE)))

# ============================================================
# 6. ETIQUETAS, PALETAS Y TEMA
# ============================================================

zone_labels <- c(
  "1" = "Zona 1",
  "2" = "Zona 2",
  "3" = "Zona 3",
  "4" = "Zona 4"
)

zone_palette <- c(
  "1" = "#E41A1C",
  "2" = "#377EB8",
  "3" = "#1B9E77",
  "4" = "#984EA3"
)

curve_palette_density <- c(
  "Densidad empírica" = "#000000",
  "Weibull"           = "#0072B2",
  "Rayleigh"          = "#D55E00"
)

curve_linetypes_density <- c(
  "Densidad empírica" = "solid",
  "Weibull"           = "dotted",
  "Rayleigh"          = "dashed"
)

curve_palette_cdf <- c(
  "CDF empírica" = "#000000",
  "Weibull"      = "#0072B2",
  "Rayleigh"     = "#D55E00"
)

curve_linetypes_cdf <- c(
  "CDF empírica" = "solid",
  "Weibull"      = "dotted",
  "Rayleigh"     = "dashed"
)

theme_tesis <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = base_size + 4, hjust = 0.5),
      plot.subtitle = ggplot2::element_text(size = base_size, hjust = 0.5),
      axis.title = ggplot2::element_text(face = "bold", size = base_size + 1),
      axis.text = ggplot2::element_text(color = "black", size = base_size - 1),
      legend.title = ggplot2::element_text(face = "bold", size = base_size),
      legend.text = ggplot2::element_text(size = base_size - 1),
      strip.text = ggplot2::element_text(face = "bold", size = base_size),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(color = "grey85", linewidth = 0.3),
      panel.border = ggplot2::element_rect(color = "black", fill = NA, linewidth = 0.5),
      strip.background = ggplot2::element_rect(fill = "white", color = "black", linewidth = 0.5),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      legend.position = "bottom"
    )
}

# ============================================================
# 7. ESTADÍSTICOS DESCRIPTIVOS POR ZONA
# ============================================================

safe_q <- function(x, p) {
  as.numeric(stats::quantile(x, probs = p, na.rm = TRUE, names = FALSE, type = 7))
}

station_col <- intersect(
  c("station_code", "Estacion", "codigo_estacion", "station_id"),
  names(dt_main)
)

if (length(station_col) == 0) {
  station_col <- NA_character_
} else {
  station_col <- station_col[1]
}

# Número de estaciones por zona tomado de la Parte A ya auditada.
# Se incorpora aquí para evitar una columna vacía cuando el dataset QC
# del Artículo 1 no conserva explícitamente el identificador de estación.
estaciones_por_zona_A <- data.table::data.table(
  zone = factor(c("1", "2", "3", "4"), levels = c("1", "2", "3", "4")),
  n_estaciones_A = c(5L, 4L, 5L, 2L)
)

tabla_descriptiva_zona <- dt_main[
  ,
  .(
    n_registros = .N,
    n_estaciones = if (!is.na(station_col)) data.table::uniqueN(get(station_col)) else NA_integer_,
    fecha_min = min(datetime, na.rm = TRUE),
    fecha_max = max(datetime, na.rm = TRUE),

    VV_min = min(VV, na.rm = TRUE),
    VV_p05 = safe_q(VV, 0.05),
    VV_p25 = safe_q(VV, 0.25),
    VV_media = mean(VV, na.rm = TRUE),
    VV_mediana = median(VV, na.rm = TRUE),
    VV_p75 = safe_q(VV, 0.75),
    VV_p95 = safe_q(VV, 0.95),
    VV_max = max(VV, na.rm = TRUE),
    VV_sd = stats::sd(VV, na.rm = TRUE),
    VV_cv = stats::sd(VV, na.rm = TRUE) / mean(VV, na.rm = TRUE),
    VV_asimetria = moments::skewness(VV, na.rm = TRUE),
    VV_curtosis = moments::kurtosis(VV, na.rm = TRUE),

    WPD_min = min(WPD, na.rm = TRUE),
    WPD_p05 = safe_q(WPD, 0.05),
    WPD_p25 = safe_q(WPD, 0.25),
    WPD_media = mean(WPD, na.rm = TRUE),
    WPD_mediana = median(WPD, na.rm = TRUE),
    WPD_p75 = safe_q(WPD, 0.75),
    WPD_p95 = safe_q(WPD, 0.95),
    WPD_max = max(WPD, na.rm = TRUE),
    WPD_sd = stats::sd(WPD, na.rm = TRUE),
    WPD_cv = stats::sd(WPD, na.rm = TRUE) / mean(WPD, na.rm = TRUE),
    WPD_asimetria = moments::skewness(WPD, na.rm = TRUE),
    WPD_curtosis = moments::kurtosis(WPD, na.rm = TRUE),

    rho_media = mean(rho_used, na.rm = TRUE),
    rho_mediana = median(rho_used, na.rm = TRUE),
    rho_sd = stats::sd(rho_used, na.rm = TRUE)
  ),
  by = zone
][order(zone)]

tabla_descriptiva_zona <- merge(
  tabla_descriptiva_zona,
  estaciones_por_zona_A,
  by = "zone",
  all.x = TRUE
)

tabla_descriptiva_zona[
  is.na(n_estaciones) | !is.finite(n_estaciones),
  n_estaciones := n_estaciones_A
]

tabla_descriptiva_zona[, n_estaciones_A := NULL]
tabla_descriptiva_zona[, zona := zone_labels[as.character(zone)]]
data.table::setcolorder(tabla_descriptiva_zona, c("zone", "zona"))

exportar_tabla(
  tabla_descriptiva_zona,
  "Tabla_Cap2_B01_Resumen_Descriptivo_VV_WPD_por_Zona_FINAL"
)

# ============================================================
# 8. RESUMEN MENSUAL CON BRECHAS TEMPORALES EXPLÍCITAS
# ============================================================

monthly_main <- dt_main[
  ,
  .(
    mean_VV = mean(VV, na.rm = TRUE),
    median_VV = median(VV, na.rm = TRUE),
    mean_WPD = mean(WPD, na.rm = TRUE),
    median_WPD = median(WPD, na.rm = TRUE),
    n_records = .N
  ),
  by = .(zone, date_month, year_month)
]

start_month <- as.Date(format(min(dt_main$datetime, na.rm = TRUE), "%Y-%m-01"))
end_month <- as.Date(format(max(dt_main$datetime, na.rm = TRUE), "%Y-%m-01"))

full_grid <- data.table::as.data.table(
  expand.grid(
    zone = c("1", "2", "3", "4"),
    date_month = seq.Date(start_month, end_month, by = "month"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
)

full_grid[, zone := factor(zone, levels = c("1", "2", "3", "4"))]
full_grid[, year_month := format(date_month, "%Y-%m")]

monthly_plot_data <- merge(
  full_grid,
  monthly_main,
  by = c("zone", "date_month", "year_month"),
  all.x = TRUE
)

monthly_plot_data[, zona := zone_labels[as.character(zone)]]
data.table::setorder(monthly_plot_data, zone, date_month)

exportar_tabla(
  monthly_plot_data,
  "Tabla_Cap2_B02_Resumen_Mensual_VV_WPD_por_Zona_FINAL"
)

data.table::fwrite(
  monthly_plot_data,
  file.path(DIR_PROCESSED, "cap2_B_datos_mensuales_VV_WPD_por_zona.csv"),
  bom = TRUE
)

# ============================================================
# 9. FUNCIONES WEIBULL/RAYLEIGH
# ============================================================

drayleigh_tesis <- function(x, sigma) {
  out <- ifelse(
    x >= 0 & sigma > 0,
    (x / sigma^2) * exp(-(x^2) / (2 * sigma^2)),
    0
  )
  out[!is.finite(out)] <- 0
  out
}

prayleigh_tesis <- function(q, sigma) {
  out <- ifelse(
    q < 0,
    0,
    1 - exp(-(q^2) / (2 * sigma^2))
  )
  out[!is.finite(out)] <- NA_real_
  out
}

fit_zona <- function(df_zona, z) {
  x_raw <- df_zona$VV
  x_pos <- x_raw[is.finite(x_raw) & x_raw > 0]

  n_total <- length(x_raw[is.finite(x_raw)])
  n_positive <- length(x_pos)
  n_zero <- sum(x_raw == 0, na.rm = TRUE)

  if (n_positive < 30) {
    warning("Zona ", z, ": menos de 30 valores positivos. No se ajustan distribuciones.")
    return(list(
      parametros = data.table(),
      metricas = data.table(),
      density_curve = data.table(),
      cdf_curve = data.table()
    ))
  }

  fit_weibull <- fitdistrplus::fitdist(x_pos, "weibull")

  weib_shape <- unname(fit_weibull$estimate["shape"])
  weib_scale <- unname(fit_weibull$estimate["scale"])
  weib_loglik <- as.numeric(fit_weibull$loglik)
  weib_aic <- stats::AIC(fit_weibull)
  weib_bic <- stats::BIC(fit_weibull)

  ray_sigma <- sqrt(mean(x_pos^2, na.rm = TRUE) / 2)
  ray_density_obs <- drayleigh_tesis(x_pos, sigma = ray_sigma)
  ray_loglik <- sum(log(pmax(ray_density_obs, .Machine$double.xmin)), na.rm = TRUE)
  ray_aic <- 2 * 1 - 2 * ray_loglik
  ray_bic <- log(n_positive) * 1 - 2 * ray_loglik

  ks_weibull <- suppressWarnings(
    stats::ks.test(x_pos, "pweibull", shape = weib_shape, scale = weib_scale)$statistic
  )

  ks_rayleigh <- suppressWarnings(
    stats::ks.test(x_pos, prayleigh_tesis, sigma = ray_sigma)$statistic
  )

  x_min_density <- max(0, min(x_pos, na.rm = TRUE))
  x_max_density <- as.numeric(stats::quantile(x_pos, probs = 0.995, na.rm = TRUE, names = FALSE))

  if (!is.finite(x_max_density) || x_max_density <= x_min_density) {
    x_max_density <- max(x_pos, na.rm = TRUE)
  }

  dens_emp <- stats::density(
    x_pos,
    n = 512,
    from = x_min_density,
    to = x_max_density,
    na.rm = TRUE
  )

  density_grid <- data.table::data.table(
    x = dens_emp$x,
    Densidad_empirica = dens_emp$y
  )

  density_grid[, Weibull := stats::dweibull(x, shape = weib_shape, scale = weib_scale)]
  density_grid[, Rayleigh := drayleigh_tesis(x, sigma = ray_sigma)]

  cdf_grid <- data.table::data.table(
    x = seq(0, x_max_density, length.out = 512)
  )

  ecdf_fun <- stats::ecdf(x_pos)
  cdf_grid[, CDF_empirica := ecdf_fun(x)]
  cdf_grid[, Weibull := stats::pweibull(x, shape = weib_shape, scale = weib_scale)]
  cdf_grid[, Rayleigh := prayleigh_tesis(x, sigma = ray_sigma)]

  rmse <- function(a, b) {
    valid <- is.finite(a) & is.finite(b)
    sqrt(mean((a[valid] - b[valid])^2, na.rm = TRUE))
  }

  mae <- function(a, b) {
    valid <- is.finite(a) & is.finite(b)
    mean(abs(a[valid] - b[valid]), na.rm = TRUE)
  }

  parametros <- data.table::data.table(
    zone = z,
    distribution = c("Weibull", "Rayleigh"),
    n_total = n_total,
    n_positive = n_positive,
    n_zero = n_zero,
    porcentaje_ceros = round(100 * n_zero / n_total, 5),
    shape = c(weib_shape, NA_real_),
    scale = c(weib_scale, NA_real_),
    sigma = c(NA_real_, ray_sigma)
  )

  metricas <- data.table::data.table(
    zone = z,
    distribution = c("Weibull", "Rayleigh"),
    n_positive = n_positive,
    logLik = c(weib_loglik, ray_loglik),
    AIC = c(weib_aic, ray_aic),
    BIC = c(weib_bic, ray_bic),
    KS = c(as.numeric(ks_weibull), as.numeric(ks_rayleigh)),
    RMSE_density = c(
      rmse(density_grid$Densidad_empirica, density_grid$Weibull),
      rmse(density_grid$Densidad_empirica, density_grid$Rayleigh)
    ),
    MAE_density = c(
      mae(density_grid$Densidad_empirica, density_grid$Weibull),
      mae(density_grid$Densidad_empirica, density_grid$Rayleigh)
    ),
    RMSE_CDF = c(
      rmse(cdf_grid$CDF_empirica, cdf_grid$Weibull),
      rmse(cdf_grid$CDF_empirica, cdf_grid$Rayleigh)
    ),
    MAE_CDF = c(
      mae(cdf_grid$CDF_empirica, cdf_grid$Weibull),
      mae(cdf_grid$CDF_empirica, cdf_grid$Rayleigh)
    )
  )

  density_curve <- data.table::melt(
    density_grid,
    id.vars = "x",
    variable.name = "curve_type",
    value.name = "density"
  )

  density_curve[, zone := z]
  density_curve[, curve_label := as.character(curve_type)]
  density_curve[curve_label == "Densidad_empirica", curve_label := "Densidad empírica"]
  density_curve[, curve_label := factor(
    curve_label,
    levels = c("Densidad empírica", "Weibull", "Rayleigh")
  )]

  cdf_curve <- data.table::melt(
    cdf_grid,
    id.vars = "x",
    variable.name = "curve_type",
    value.name = "CDF"
  )

  cdf_curve[, zone := z]
  cdf_curve[, curve_label := as.character(curve_type)]
  cdf_curve[curve_label == "CDF_empirica", curve_label := "CDF empírica"]
  cdf_curve[, curve_label := factor(
    curve_label,
    levels = c("CDF empírica", "Weibull", "Rayleigh")
  )]

  list(
    parametros = parametros,
    metricas = metricas,
    density_curve = density_curve,
    cdf_curve = cdf_curve
  )
}

# ============================================================
# 10. AJUSTE DE DISTRIBUCIONES POR ZONA
# ============================================================

logi("Iniciando ajuste Weibull/Rayleigh por zona.")

fit_results <- list()

for (z in levels(dt_main$zone)) {
  df_z <- dt_main[zone == z]
  logi("Ajustando zona:", z, "| n:", nrow(df_z))
  fit_results[[z]] <- fit_zona(df_z, z)
}

tabla_parametros <- data.table::rbindlist(
  lapply(fit_results, `[[`, "parametros"),
  use.names = TRUE,
  fill = TRUE
)

tabla_metricas <- data.table::rbindlist(
  lapply(fit_results, `[[`, "metricas"),
  use.names = TRUE,
  fill = TRUE
)

density_plot_data <- data.table::rbindlist(
  lapply(fit_results, `[[`, "density_curve"),
  use.names = TRUE,
  fill = TRUE
)

cdf_plot_data <- data.table::rbindlist(
  lapply(fit_results, `[[`, "cdf_curve"),
  use.names = TRUE,
  fill = TRUE
)

tabla_metricas[, rank_AIC := data.table::frank(AIC, ties.method = "min"), by = zone]
tabla_metricas[, rank_BIC := data.table::frank(BIC, ties.method = "min"), by = zone]
tabla_metricas[, rank_KS := data.table::frank(KS, ties.method = "min"), by = zone]
tabla_metricas[, rank_RMSE_density := data.table::frank(RMSE_density, ties.method = "min"), by = zone]
tabla_metricas[, rank_RMSE_CDF := data.table::frank(RMSE_CDF, ties.method = "min"), by = zone]

tabla_metricas[
  ,
  score_global := rank_AIC + rank_BIC + rank_KS + rank_RMSE_density + rank_RMSE_CDF
]

tabla_mejor_distribucion <- tabla_metricas[
  ,
  .SD[which.min(score_global)],
  by = zone
][
  ,
  .(
    zone,
    mejor_distribucion = distribution,
    AIC,
    BIC,
    KS,
    RMSE_density,
    RMSE_CDF,
    score_global
  )
]

tabla_parametros[, zona := zone_labels[as.character(zone)]]
tabla_metricas[, zona := zone_labels[as.character(zone)]]
tabla_mejor_distribucion[, zona := zone_labels[as.character(zone)]]

data.table::setcolorder(tabla_parametros, c("zone", "zona"))
data.table::setcolorder(tabla_metricas, c("zone", "zona"))
data.table::setcolorder(tabla_mejor_distribucion, c("zone", "zona"))

exportar_tabla(
  tabla_parametros,
  "Tabla_Cap2_B03_Parametros_Weibull_Rayleigh_VV_por_Zona_FINAL"
)

exportar_tabla(
  tabla_metricas,
  "Tabla_Cap2_B04_Metricas_Ajuste_Weibull_Rayleigh_VV_por_Zona_FINAL"
)

exportar_tabla(
  tabla_mejor_distribucion,
  "Tabla_Cap2_B05_Mejor_Distribucion_VV_por_Zona_FINAL"
)

saveRDS(
  list(
    parametros = tabla_parametros,
    metricas = tabla_metricas,
    mejor_distribucion = tabla_mejor_distribucion,
    density_plot_data = density_plot_data,
    cdf_plot_data = cdf_plot_data
  ),
  file.path(DIR_PROCESSED, "cap2_B_resultados_weibull_rayleigh_VV_por_zona.rds")
)

# ============================================================
# 11. FIGURAS
# ============================================================

# 11.1 Media mensual de VV
fig_B01_monthly_vv <- ggplot(
  monthly_plot_data,
  aes(x = date_month, y = mean_VV, color = zone, group = zone)
) +
  geom_line(linewidth = 0.85, na.rm = FALSE) +
  geom_point(size = 1.5, alpha = 0.75, na.rm = TRUE) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Media mensual de la velocidad del viento por zona analítica",
    subtitle = "Escenario principal de control de calidad: VV ≤ 20 m s⁻¹",
    x = "Mes",
    y = expression("Media mensual de " * V[V] * " (m s"^-1 * ")")
  ) +
  theme_tesis()

exportar_figura(
  fig_B01_monthly_vv,
  "Fig_Cap2_B01_Media_Mensual_VV_por_Zona_FINAL",
  width = 9,
  height = 6.6
)

# 11.2 Media mensual de WPD
fig_B02_monthly_wpd <- ggplot(
  monthly_plot_data,
  aes(x = date_month, y = mean_WPD, color = zone, group = zone)
) +
  geom_line(linewidth = 0.85, na.rm = FALSE) +
  geom_point(size = 1.5, alpha = 0.75, na.rm = TRUE) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(labels = scales::label_number(accuracy = 0.1, big.mark = " ")) +
  labs(
    title = "Media mensual de la densidad de potencia eólica por zona analítica",
    subtitle = "WPD calculada con densidad diaria del aire a nivel de zona",
    x = "Mes",
    y = expression("Media mensual de WPD (W m"^-2 * ")")
  ) +
  theme_tesis()

exportar_figura(
  fig_B02_monthly_wpd,
  "Fig_Cap2_B02_Media_Mensual_WPD_por_Zona_FINAL",
  width = 9,
  height = 6.6
)

# 11.2B Media mensual de VV con eje común
fig_B01B_monthly_vv_common_axis <- ggplot(
  monthly_plot_data,
  aes(x = date_month, y = mean_VV, color = zone, group = zone)
) +
  geom_line(linewidth = 0.85, na.rm = FALSE) +
  geom_point(size = 1.5, alpha = 0.75, na.rm = TRUE) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "fixed",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Media mensual de la velocidad del viento por zona analítica",
    subtitle = "Comparación directa con eje Y común; escenario principal: VV ≤ 20 m s⁻¹",
    x = "Mes",
    y = expression("Media mensual de " * V[V] * " (m s"^-1 * ")")
  ) +
  theme_tesis()

exportar_figura(
  fig_B01B_monthly_vv_common_axis,
  "Fig_Cap2_B01B_Media_Mensual_VV_por_Zona_Eje_Comun_FINAL",
  width = 9,
  height = 6.6
)

# 11.2C Media mensual de WPD con eje común pseudo-log
fig_B02B_monthly_wpd_common_axis <- ggplot(
  monthly_plot_data,
  aes(x = date_month, y = mean_WPD, color = zone, group = zone)
) +
  geom_line(linewidth = 0.85, na.rm = FALSE) +
  geom_point(size = 1.5, alpha = 0.75, na.rm = TRUE) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "fixed",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(
    trans = scales::pseudo_log_trans(base = 10, sigma = 1),
    labels = scales::label_number(accuracy = 0.1, big.mark = " ")
  ) +
  labs(
    title = "Media mensual de la densidad de potencia eólica por zona analítica",
    subtitle = "Comparación directa con eje Y común pseudo-log; WPD con densidad diaria del aire por zona",
    x = "Mes",
    y = expression("Media mensual de WPD (W m"^-2 * ", escala pseudo-log)")
  ) +
  theme_tesis()

exportar_figura(
  fig_B02B_monthly_wpd_common_axis,
  "Fig_Cap2_B02B_Media_Mensual_WPD_por_Zona_Eje_Comun_PseudoLog_FINAL",
  width = 9,
  height = 6.6
)

# 11.3 Distribución de VV
fig_B03_vv_distribution <- ggplot(
  dt_main,
  aes(x = zone, y = VV, fill = zone)
) +
  geom_violin(
    trim = TRUE,
    alpha = 0.42,
    color = "black",
    linewidth = 0.45
  ) +
  geom_boxplot(
    width = 0.18,
    outlier.shape = NA,
    fill = "white",
    color = "black",
    linewidth = 0.45
  ) +
  stat_summary(
    fun = mean,
    geom = "point",
    shape = 23,
    size = 2.6,
    fill = "#F0E442",
    color = "black"
  ) +
  scale_fill_manual(values = zone_palette, guide = "none") +
  scale_x_discrete(labels = zone_labels) +
  labs(
    title = "Distribución de la velocidad del viento por zona analítica",
    subtitle = "Escenario principal de control de calidad: VV ≤ 20 m s⁻¹",
    x = "Zona analítica",
    y = expression("Velocidad del viento, " * V[V] * " (m s"^-1 * ")")
  ) +
  theme_tesis()

exportar_figura(
  fig_B03_vv_distribution,
  "Fig_Cap2_B03_Distribucion_VV_por_Zona_FINAL",
  width = 8.2,
  height = 6
)

# 11.4 Distribución de WPD
fig_B04_wpd_distribution <- ggplot(
  dt_main,
  aes(x = zone, y = WPD, fill = zone)
) +
  geom_violin(
    trim = TRUE,
    alpha = 0.42,
    color = "black",
    linewidth = 0.45
  ) +
  geom_boxplot(
    width = 0.18,
    outlier.shape = NA,
    fill = "white",
    color = "black",
    linewidth = 0.45
  ) +
  stat_summary(
    fun = mean,
    geom = "point",
    shape = 23,
    size = 2.6,
    fill = "#F0E442",
    color = "black"
  ) +
  scale_fill_manual(values = zone_palette, guide = "none") +
  scale_x_discrete(labels = zone_labels) +
  scale_y_continuous(
    trans = scales::pseudo_log_trans(base = 10, sigma = 1),
    labels = scales::label_number(accuracy = 0.1, big.mark = " ")
  ) +
  labs(
    title = "Distribución de la densidad de potencia eólica por zona analítica",
    subtitle = "WPD calculada con densidad diaria del aire a nivel de zona",
    x = "Zona analítica",
    y = expression("WPD (W m"^-2 * ", escala pseudo-log)")
  ) +
  theme_tesis()

exportar_figura(
  fig_B04_wpd_distribution,
  "Fig_Cap2_B04_Distribucion_WPD_por_Zona_FINAL",
  width = 8.2,
  height = 6
)

# 11.4B Distribución de WPD con zoom hasta percentil 99
wpd_p99 <- as.numeric(stats::quantile(dt_main$WPD, probs = 0.99, na.rm = TRUE, names = FALSE))

fig_B04B_wpd_distribution_zoom_p99 <- ggplot(
  dt_main,
  aes(x = zone, y = WPD, fill = zone)
) +
  geom_violin(
    trim = TRUE,
    alpha = 0.42,
    color = "black",
    linewidth = 0.45
  ) +
  geom_boxplot(
    width = 0.18,
    outlier.shape = NA,
    fill = "white",
    color = "black",
    linewidth = 0.45
  ) +
  stat_summary(
    fun = mean,
    geom = "point",
    shape = 23,
    size = 2.6,
    fill = "#F0E442",
    color = "black"
  ) +
  coord_cartesian(ylim = c(0, wpd_p99)) +
  scale_fill_manual(values = zone_palette, guide = "none") +
  scale_x_discrete(labels = zone_labels) +
  scale_y_continuous(labels = scales::label_number(accuracy = 0.1, big.mark = " ")) +
  labs(
    title = "Distribución de la densidad de potencia eólica por zona analítica",
    subtitle = "Zoom visual hasta el percentil 99; los valores extremos no se eliminan del análisis",
    x = "Zona analítica",
    y = expression("WPD (W m"^-2 * ")")
  ) +
  theme_tesis()

exportar_figura(
  fig_B04B_wpd_distribution_zoom_p99,
  "Fig_Cap2_B04B_Distribucion_WPD_por_Zona_Zoom_P99_FINAL",
  width = 8.2,
  height = 6
)

# 11.5 Ajuste de densidades Weibull/Rayleigh
density_plot_data[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
density_plot_data <- density_plot_data[
  is.finite(x) &
    is.finite(density) &
    !is.na(curve_label)
]

fig_B05_density_fit <- ggplot(
  density_plot_data,
  aes(x = x, y = density, color = curve_label, linetype = curve_label)
) +
  geom_line(linewidth = 0.9, na.rm = TRUE) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = curve_palette_density) +
  scale_linetype_manual(values = curve_linetypes_density) +
  labs(
    title = "Densidad empírica y ajustes Weibull/Rayleigh de la velocidad del viento",
    subtitle = "Ajustes realizados sobre VV > 0 en el dataset principal con control de calidad",
    x = expression("Velocidad del viento, " * V[V] * " (m s"^-1 * ")"),
    y = "Densidad de probabilidad",
    color = "Curva",
    linetype = "Curva"
  ) +
  theme_tesis()

exportar_figura(
  fig_B05_density_fit,
  "Fig_Cap2_B05_Ajuste_Densidad_Weibull_Rayleigh_VV_por_Zona_FINAL",
  width = 9,
  height = 6.6
)

# 11.6 Ajuste de funciones acumuladas Weibull/Rayleigh
cdf_plot_data[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
cdf_plot_data <- cdf_plot_data[
  is.finite(x) &
    is.finite(CDF) &
    !is.na(curve_label)
]

fig_B06_cdf_fit <- ggplot(
  cdf_plot_data,
  aes(x = x, y = CDF, color = curve_label, linetype = curve_label)
) +
  geom_line(linewidth = 0.9, na.rm = TRUE) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = curve_palette_cdf) +
  scale_linetype_manual(values = curve_linetypes_cdf) +
  labs(
    title = "Función acumulada empírica y ajustes Weibull/Rayleigh",
    subtitle = "Ajustes realizados sobre VV > 0 en el dataset principal con control de calidad",
    x = expression("Velocidad del viento, " * V[V] * " (m s"^-1 * ")"),
    y = "Probabilidad acumulada",
    color = "Curva",
    linetype = "Curva"
  ) +
  theme_tesis()

exportar_figura(
  fig_B06_cdf_fit,
  "Fig_Cap2_B06_Ajuste_CDF_Weibull_Rayleigh_VV_por_Zona_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 12. GUÍA DE INSERCIÓN
# ============================================================

guia <- c(
  "# Capítulo 2 — Parte B: guía de inserción",
  "",
  "## Figuras principales sugeridas",
  "",
  "1. Fig_Cap2_B01_Media_Mensual_VV_por_Zona_FINAL",
  "2. Fig_Cap2_B02_Media_Mensual_WPD_por_Zona_FINAL",
  "3. Fig_Cap2_B03_Distribucion_VV_por_Zona_FINAL",
  "4. Fig_Cap2_B04_Distribucion_WPD_por_Zona_FINAL",
  "5. Fig_Cap2_B01B_Media_Mensual_VV_por_Zona_Eje_Comun_FINAL",
  "6. Fig_Cap2_B02B_Media_Mensual_WPD_por_Zona_Eje_Comun_PseudoLog_FINAL",
  "7. Fig_Cap2_B04B_Distribucion_WPD_por_Zona_Zoom_P99_FINAL",
  "8. Fig_Cap2_B05_Ajuste_Densidad_Weibull_Rayleigh_VV_por_Zona_FINAL",
  "9. Fig_Cap2_B06_Ajuste_CDF_Weibull_Rayleigh_VV_por_Zona_FINAL",
  "",
  "## Tablas principales sugeridas",
  "",
  "1. Tabla_Cap2_B01_Resumen_Descriptivo_VV_WPD_por_Zona_FINAL",
  "2. Tabla_Cap2_B03_Parametros_Weibull_Rayleigh_VV_por_Zona_FINAL",
  "3. Tabla_Cap2_B04_Metricas_Ajuste_Weibull_Rayleigh_VV_por_Zona_FINAL",
  "4. Tabla_Cap2_B05_Mejor_Distribucion_VV_por_Zona_FINAL",
  "",
  "## Decisiones metodológicas",
  "",
  "- La Parte B usa el dataset principal del Artículo 1 posterior al control de calidad.",
  "- La WPD se conserva como variable energética principal calculada con densidad diaria del aire a nivel de zona.",
  "- Los ajustes Weibull/Rayleigh se realizan sobre valores positivos de VV.",
  "- Las figuras se generan en español y con estructura multizona para responder a la solicitud de comparación entre zonas.",
  "- Se agregan versiones complementarias con eje Y común para facilitar la comparación directa entre zonas.",
  "- La distribución de WPD conserva la versión pseudo-log y añade un zoom visual al percentil 99 sin eliminar valores del análisis.",
  "",
  "## Siguiente bloque",
  "",
  "La siguiente parte debe integrar dependencia temporal y estructura espectral: ACF/PACF, FFT y Wavelet Morlet multizona."
)

writeLines(
  guia,
  file.path(DIR_TEXTOS, "cap2_B_guia_insercion_analisis_fisico_estadistico_multizona.md"),
  useBytes = TRUE
)

manifest <- data.table::data.table(
  tipo = c(
    rep("tabla", 5),
    rep("figura", 9),
    "procesado",
    "procesado"
  ),
  archivo = c(
    "Tabla_Cap2_B01_Resumen_Descriptivo_VV_WPD_por_Zona_FINAL.csv/xlsx",
    "Tabla_Cap2_B02_Resumen_Mensual_VV_WPD_por_Zona_FINAL.csv/xlsx",
    "Tabla_Cap2_B03_Parametros_Weibull_Rayleigh_VV_por_Zona_FINAL.csv/xlsx",
    "Tabla_Cap2_B04_Metricas_Ajuste_Weibull_Rayleigh_VV_por_Zona_FINAL.csv/xlsx",
    "Tabla_Cap2_B05_Mejor_Distribucion_VV_por_Zona_FINAL.csv/xlsx",
    "Fig_Cap2_B01_Media_Mensual_VV_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_B02_Media_Mensual_WPD_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_B01B_Media_Mensual_VV_por_Zona_Eje_Comun_FINAL.png/pdf/svg",
    "Fig_Cap2_B02B_Media_Mensual_WPD_por_Zona_Eje_Comun_PseudoLog_FINAL.png/pdf/svg",
    "Fig_Cap2_B03_Distribucion_VV_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_B04_Distribucion_WPD_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_B04B_Distribucion_WPD_por_Zona_Zoom_P99_FINAL.png/pdf/svg",
    "Fig_Cap2_B05_Ajuste_Densidad_Weibull_Rayleigh_VV_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_B06_Ajuste_CDF_Weibull_Rayleigh_VV_por_Zona_FINAL.png/pdf/svg",
    "cap2_B_dataset_principal_VV_WPD_QC_articulo1.rds/csv",
    "cap2_B_resultados_weibull_rayleigh_VV_por_zona.rds"
  ),
  ubicacion = c(
    rep(DIR_TABLES, 5),
    rep(DIR_FIGURES, 9),
    DIR_PROCESSED,
    DIR_PROCESSED
  ),
  uso_sugerido = c(
    "Cuerpo del capítulo: resumen físico-estadístico por zona",
    "Soporte o anexo: serie mensual con brechas explícitas",
    "Cuerpo o anexo: parámetros de distribución",
    "Cuerpo o anexo: comparación de ajuste",
    "Cuerpo: selección de distribución por zona",
    "Cuerpo: variabilidad temporal mensual de VV",
    "Cuerpo: variabilidad temporal mensual de WPD",
    "Soporte: comparación directa de VV con eje común",
    "Soporte: comparación directa de WPD con eje común pseudo-log",
    "Cuerpo: distribución de VV por zona",
    "Cuerpo o anexo: distribución de WPD en escala pseudo-log",
    "Cuerpo o anexo: distribución de WPD con zoom visual p99",
    "Cuerpo: ajuste Weibull/Rayleigh en densidad",
    "Cuerpo o anexo: ajuste Weibull/Rayleigh en CDF",
    "Entrada oficial para siguientes análisis",
    "Trazabilidad de ajustes de distribución"
  )
)

data.table::fwrite(
  manifest,
  file.path(DIR_LOGS, "manifest_cap2_B_analisis_fisico_estadistico_multizona.csv"),
  bom = TRUE
)

writeLines(
  capture.output(sessionInfo()),
  file.path(DIR_LOGS, "sessionInfo_cap2_B_analisis_fisico_estadistico_multizona.txt"),
  useBytes = TRUE
)

logi("CAPÍTULO 2 — PARTE B V2 FINALIZADA")
logi("Fin:", as.character(Sys.time()))
logi("============================================================")

cat("\n============================================================\n")
cat("CAPÍTULO 2 — PARTE B V2 FINALIZADA\n")
cat("Fin:", as.character(Sys.time()), "\n")
cat("============================================================\n")

# -*- coding: UTF-8 -*-
# ============================================================
# 03_cap2_C_dependencia_temporal_espectral_wavelet_V3.R
# CAPÍTULO 2 — PARTE C
# Dependencia temporal y estructura espectral multizona — V3 fina
# ACF, PACF, FFT y Wavelet Morlet
# Tesis doctoral
# Favio Nicolás Rosero Rodríguez
# ============================================================
#
# Propósito:
#   Generar de manera limpia y reproducible los productos de la
#   Parte C del Capítulo 2:
#
#   1. Agregación diaria por zona para VV y WPD.
#   2. Regularización temporal con interpolación controlada de brechas cortas.
#   3. ACF y PACF diaria para VV y WPD.
#   4. Resumen de persistencia temporal por zona.
#   5. FFT por zona y variable.
#   6. Energía espectral por bandas temporales.
#   7. Wavelet Morlet multizona para VV.
#   8. Figuras Wavelet: eje común, segmento útil y versión fina X libre / Y común.
#   9. Nota metodológica explícita sobre cobertura y comparabilidad Wavelet.
#
# Decisión metodológica:
#   - ACF/PACF y FFT se calculan para VV y WPD.
#   - La figura Wavelet principal se calcula para VV, porque el
#     Capítulo 2 caracteriza físicamente el régimen de viento.
#   - WPD queda incorporada como variable energética en ACF/FFT.
#
# Entrada principal esperada:
#   06_processed/cap2_B_dataset_principal_VV_WPD_QC_articulo1.rds
#
# Respaldo:
#   Si no existe, busca el dataset 02E del Artículo 1.
#
# ============================================================

rm(list = ls())
gc()

source(file.path("03_CODE", "00_config.R"))


options(warn = 1)

cat("\n============================================================\n")
cat("CAPÍTULO 2 — PARTE C: DEPENDENCIA TEMPORAL Y ESPECTRAL\n")
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
  "zoo",
  "openxlsx",
  "ragg",
  "svglite",
  "WaveletComp"
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
  library(zoo)
  library(openxlsx)
  library(WaveletComp)
})

# ============================================================
# 2. RUTAS
# ============================================================

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

ARTICLE_ROOT_CANDIDATES <- c(
  file.path(TDQ_REPO_ROOT, "06_PRODUCTS", "01_articles", "article_01_energy_reports"),
  file.path(TDQ_WORK_DIR, "external_inputs", "article_01"),
  file.path(TDQ_WORK_DIR, "external_inputs", "article_01", "Proceso"),
  file.path(CAP_DIR, "00_inputs", "article_01_energy_reports")
)

# ============================================================
# 3. LOG Y EXPORTACIÓN
# ============================================================

LOG_FILE <- file.path(
  DIR_LOGS,
  paste0("log_cap2_C_dependencia_temporal_espectral_wavelet_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
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
# 4. LOCALIZACIÓN DEL DATASET PRINCIPAL
# ============================================================

buscar_archivo <- function(nombre_archivo, roots) {
  directos <- c(
    file.path(DIR_PROCESSED, nombre_archivo),
    file.path(DIR_INPUTS, nombre_archivo)
  )

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

INPUT_PART_B_RDS <- file.path(DIR_PROCESSED, "cap2_B_dataset_principal_VV_WPD_QC_articulo1.rds")

INPUT_ARTICLE_RDS <- buscar_archivo(
  "02E_article_main_wpd_dataset_after_qc.rds",
  ARTICLE_ROOT_CANDIDATES
)

INPUT_ARTICLE_CSV <- buscar_archivo(
  "02E_article_main_wpd_dataset_after_qc.csv",
  ARTICLE_ROOT_CANDIDATES
)

if (file.exists(INPUT_PART_B_RDS)) {
  INPUT_MAIN <- INPUT_PART_B_RDS
  dt_main <- readRDS(INPUT_MAIN)
} else if (!is.na(INPUT_ARTICLE_RDS)) {
  INPUT_MAIN <- INPUT_ARTICLE_RDS
  dt_main <- readRDS(INPUT_MAIN)
} else if (!is.na(INPUT_ARTICLE_CSV)) {
  INPUT_MAIN <- INPUT_ARTICLE_CSV
  dt_main <- data.table::fread(INPUT_MAIN, encoding = "UTF-8")
} else {
  stop(
    "No se encontró dataset principal para la Parte C. ",
    "Ejecute primero la Parte B o ubique 02E_article_main_wpd_dataset_after_qc.rds/csv."
  )
}

logi("Dataset principal localizado:", INPUT_MAIN)

# ============================================================
# 5. CARGA Y ESTANDARIZACIÓN
# ============================================================

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

required_main_columns <- c("zone", "datetime", "VV", "WPD")
missing_main_columns <- setdiff(required_main_columns, names(dt_main))

if (length(missing_main_columns) > 0) {
  stop(
    "El dataset principal no contiene columnas requeridas: ",
    paste(missing_main_columns, collapse = ", "),
    ". Columnas disponibles: ",
    paste(names(dt_main), collapse = ", ")
  )
}

dt_main[, datetime := as.POSIXct(datetime, tz = "America/Bogota")]
dt_main[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
dt_main[, VV := suppressWarnings(as.numeric(VV))]
dt_main[, WPD := suppressWarnings(as.numeric(WPD))]

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

dt_main[, date := as.Date(datetime)]
data.table::setorder(dt_main, zone, datetime)

logi("Dataset cargado.")
logi("Filas:", nrow(dt_main))
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

band_palette <- c(
  "2–30 días"    = "#E41A1C",
  "30–120 días"  = "#377EB8",
  "120–400 días" = "#1B9E77",
  ">400 días"    = "#984EA3"
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
# 7. AGREGACIÓN DIARIA Y REGULARIZACIÓN
# ============================================================

daily_obs <- dt_main[
  ,
  .(
    VV = mean(VV, na.rm = TRUE),
    WPD = mean(WPD, na.rm = TRUE),
    n_records = .N
  ),
  by = .(zone, date)
]

start_date <- min(daily_obs$date, na.rm = TRUE)
end_date <- max(daily_obs$date, na.rm = TRUE)

daily_grid <- data.table::as.data.table(
  expand.grid(
    zone = c("1", "2", "3", "4"),
    date = seq.Date(start_date, end_date, by = "day"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
)

daily_grid[, zone := factor(zone, levels = c("1", "2", "3", "4"))]

daily_series <- merge(
  daily_grid,
  daily_obs,
  by = c("zone", "date"),
  all.x = TRUE
)

daily_series[, has_VV := !is.na(VV) & is.finite(VV)]
daily_series[, has_WPD := !is.na(WPD) & is.finite(WPD)]

daily_series[
  ,
  VV_interp := zoo::na.approx(VV, x = as.numeric(date), na.rm = FALSE, maxgap = 7),
  by = zone
]

daily_series[
  ,
  WPD_interp := zoo::na.approx(WPD, x = as.numeric(date), na.rm = FALSE, maxgap = 7),
  by = zone
]

daily_series[, zona := zone_labels[as.character(zone)]]
data.table::setorder(daily_series, zone, date)

tabla_cobertura_diaria <- daily_series[
  ,
  .(
    n_dias_esperados = .N,
    n_dias_VV_observado = sum(has_VV, na.rm = TRUE),
    n_dias_WPD_observado = sum(has_WPD, na.rm = TRUE),
    cobertura_VV_pct = round(100 * sum(has_VV, na.rm = TRUE) / .N, 3),
    cobertura_WPD_pct = round(100 * sum(has_WPD, na.rm = TRUE) / .N, 3),
    n_dias_VV_interpolado = sum(!is.na(VV_interp) & is.finite(VV_interp)),
    n_dias_WPD_interpolado = sum(!is.na(WPD_interp) & is.finite(WPD_interp)),
    cobertura_VV_interpolada_pct = round(100 * sum(!is.na(VV_interp) & is.finite(VV_interp)) / .N, 3),
    cobertura_WPD_interpolada_pct = round(100 * sum(!is.na(WPD_interp) & is.finite(WPD_interp)) / .N, 3),
    fecha_min = min(date),
    fecha_max = max(date)
  ),
  by = zone
][order(zone)]

tabla_cobertura_diaria[, zona := zone_labels[as.character(zone)]]
data.table::setcolorder(tabla_cobertura_diaria, c("zone", "zona"))

exportar_tabla(
  tabla_cobertura_diaria,
  "Tabla_Cap2_C01_Cobertura_Diaria_Regularizada_por_Zona_FINAL"
)

data.table::fwrite(
  daily_series,
  file.path(DIR_PROCESSED, "cap2_C_series_diarias_regularizadas_VV_WPD_por_zona.csv"),
  bom = TRUE
)

saveRDS(
  daily_series,
  file.path(DIR_PROCESSED, "cap2_C_series_diarias_regularizadas_VV_WPD_por_zona.rds")
)

# ============================================================
# 8. FUNCIONES AUXILIARES TEMPORALES
# ============================================================

get_longest_complete_segment <- function(dt_zone, value_col) {
  x <- dt_zone[[value_col]]
  valid <- !is.na(x) & is.finite(x)

  if (!any(valid)) {
    return(dt_zone[0])
  }

  rr <- rle(valid)
  ends <- cumsum(rr$lengths)
  starts <- ends - rr$lengths + 1

  runs <- data.table::data.table(
    start = starts,
    end = ends,
    length = rr$lengths,
    valid = rr$values
  )

  runs <- runs[valid == TRUE]

  if (nrow(runs) == 0) {
    return(dt_zone[0])
  }

  best <- runs[which.max(length)]
  dt_zone[best$start:best$end]
}

calc_acf_pacf_for_segment <- function(segment_dt, variable_name, value_col, lag_max = 60) {
  x <- segment_dt[[value_col]]
  x <- x[is.finite(x)]

  if (length(x) < lag_max + 5) {
    return(list(
      acf = data.table(),
      pacf = data.table(),
      summary = data.table()
    ))
  }

  x_centered <- x - mean(x, na.rm = TRUE)

  acf_obj <- stats::acf(
    x_centered,
    lag.max = lag_max,
    plot = FALSE,
    na.action = na.omit
  )

  pacf_obj <- stats::pacf(
    x_centered,
    lag.max = lag_max,
    plot = FALSE,
    na.action = na.omit
  )

  acf_dt <- data.table::data.table(
    lag = as.numeric(acf_obj$lag),
    value = as.numeric(acf_obj$acf),
    diagnostic = "ACF",
    variable = variable_name
  )

  acf_dt <- acf_dt[lag > 0]

  pacf_dt <- data.table::data.table(
    lag = as.numeric(pacf_obj$lag),
    value = as.numeric(pacf_obj$acf),
    diagnostic = "PACF",
    variable = variable_name
  )

  acf_lag1 <- acf_dt[lag == 1, value]
  acf_lag7 <- acf_dt[lag == 7, value]
  acf_lag30 <- acf_dt[lag == 30, value]
  pacf_lag1 <- pacf_dt[lag == 1, value]

  first_below_e <- acf_dt[value < exp(-1), min(lag)]
  if (!is.finite(first_below_e)) first_below_e <- NA_real_

  first_negative <- acf_dt[value < 0, min(lag)]
  if (!is.finite(first_negative)) first_negative <- NA_real_

  summary_dt <- data.table::data.table(
    variable = variable_name,
    n_days_segment = length(x),
    segment_start = min(segment_dt$date, na.rm = TRUE),
    segment_end = max(segment_dt$date, na.rm = TRUE),
    ACF_lag1 = acf_lag1,
    ACF_lag7 = acf_lag7,
    ACF_lag30 = acf_lag30,
    PACF_lag1 = pacf_lag1,
    first_lag_ACF_below_1e = first_below_e,
    first_lag_ACF_negative = first_negative,
    confidence_95 = 1.96 / sqrt(length(x))
  )

  list(
    acf = acf_dt,
    pacf = pacf_dt,
    summary = summary_dt
  )
}

# ============================================================
# 9. ACF/PACF POR ZONA Y VARIABLE
# ============================================================

logi("Calculando ACF/PACF diaria por zona y variable.")

variables_temporales <- data.table::data.table(
  variable = c("VV", "WPD"),
  value_col = c("VV_interp", "WPD_interp")
)

acf_list <- list()
pacf_list <- list()
temporal_summary_list <- list()

for (z in levels(daily_series$zone)) {
  dt_z <- daily_series[zone == z]

  for (i in seq_len(nrow(variables_temporales))) {
    var_name <- variables_temporales$variable[i]
    col_name <- variables_temporales$value_col[i]

    seg <- get_longest_complete_segment(dt_z, col_name)

    logi(
      "ACF/PACF | Zona:", z,
      "| Variable:", var_name,
      "| Días segmento:", nrow(seg)
    )

    res <- calc_acf_pacf_for_segment(
      segment_dt = seg,
      variable_name = var_name,
      value_col = col_name,
      lag_max = 60
    )

    if (nrow(res$acf) > 0) {
      res$acf[, zone := z]
      acf_list[[paste(z, var_name, sep = "_")]] <- res$acf
    }

    if (nrow(res$pacf) > 0) {
      res$pacf[, zone := z]
      pacf_list[[paste(z, var_name, sep = "_")]] <- res$pacf
    }

    if (nrow(res$summary) > 0) {
      res$summary[, zone := z]
      temporal_summary_list[[paste(z, var_name, sep = "_")]] <- res$summary
    }
  }
}

acf_values <- data.table::rbindlist(acf_list, use.names = TRUE, fill = TRUE)
pacf_values <- data.table::rbindlist(pacf_list, use.names = TRUE, fill = TRUE)
temporal_summary <- data.table::rbindlist(temporal_summary_list, use.names = TRUE, fill = TRUE)

acf_values[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
pacf_values[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
temporal_summary[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]

acf_values[, zona := zone_labels[as.character(zone)]]
pacf_values[, zona := zone_labels[as.character(zone)]]
temporal_summary[, zona := zone_labels[as.character(zone)]]

data.table::setcolorder(acf_values, c("zone", "zona", "variable", "diagnostic"))
data.table::setcolorder(pacf_values, c("zone", "zona", "variable", "diagnostic"))
data.table::setcolorder(temporal_summary, c("zone", "zona", "variable"))

exportar_tabla(
  acf_values,
  "Tabla_Cap2_C02_Valores_ACF_Diaria_VV_WPD_por_Zona_FINAL"
)

exportar_tabla(
  pacf_values,
  "Tabla_Cap2_C03_Valores_PACF_Diaria_VV_WPD_por_Zona_FINAL"
)

exportar_tabla(
  temporal_summary,
  "Tabla_Cap2_C04_Resumen_Dependencia_Temporal_VV_WPD_por_Zona_FINAL"
)

# ============================================================
# 10. FUNCIONES FFT
# ============================================================

compute_fft_spectrum <- function(segment_dt, variable_name, value_col) {
  x <- segment_dt[[value_col]]
  x <- x[is.finite(x)]
  n <- length(x)

  if (n < 64) {
    return(list(
      spectrum = data.table(),
      summary = data.table(),
      top_periods = data.table(),
      bands = data.table()
    ))
  }

  x <- x - mean(x, na.rm = TRUE)

  # Ventana Hann para reducir fuga espectral.
  hann <- 0.5 * (1 - cos(2 * pi * (0:(n - 1)) / (n - 1)))
  xw <- x * hann

  fft_values <- stats::fft(xw)
  power <- (Mod(fft_values)^2) / n
  freq <- (0:(n - 1)) / n

  positive_idx <- 2:floor(n / 2)

  spectrum <- data.table::data.table(
    frequency_cycles_day = freq[positive_idx],
    period_days = 1 / freq[positive_idx],
    power = power[positive_idx]
  )

  spectrum <- spectrum[
    is.finite(period_days) &
      is.finite(power) &
      period_days >= 2
  ]

  spectrum[, power_fraction := power / sum(power, na.rm = TRUE)]
  spectrum[, variable := variable_name]

  top_periods <- spectrum[
    order(-power_fraction)
  ][
    1:min(.N, 10)
  ][
    ,
    .(
      variable,
      period_days,
      frequency_cycles_day,
      power,
      power_fraction
    )
  ]

  spectrum[, band := dplyr::case_when(
    period_days >= 2   & period_days < 30  ~ "2–30 días",
    period_days >= 30  & period_days < 120 ~ "30–120 días",
    period_days >= 120 & period_days < 400 ~ "120–400 días",
    period_days >= 400                     ~ ">400 días",
    TRUE                                   ~ NA_character_
  )]

  bands <- spectrum[
    !is.na(band),
    .(
      band_power = sum(power, na.rm = TRUE),
      band_power_fraction = sum(power_fraction, na.rm = TRUE)
    ),
    by = .(variable, band)
  ]

  bands[, band_power_pct := 100 * band_power_fraction]
  bands[, band := factor(
    band,
    levels = c("2–30 días", "30–120 días", "120–400 días", ">400 días")
  )]

  summary <- data.table::data.table(
    variable = variable_name,
    n_days_segment = n,
    segment_start = min(segment_dt$date, na.rm = TRUE),
    segment_end = max(segment_dt$date, na.rm = TRUE),
    min_period_days = min(spectrum$period_days, na.rm = TRUE),
    max_period_days = max(spectrum$period_days, na.rm = TRUE),
    dominant_period_days = top_periods$period_days[1],
    dominant_power_fraction = top_periods$power_fraction[1]
  )

  list(
    spectrum = spectrum,
    summary = summary,
    top_periods = top_periods,
    bands = bands
  )
}

# ============================================================
# 11. FFT POR ZONA Y VARIABLE
# ============================================================

logi("Calculando FFT diaria por zona y variable.")

fft_spectrum_list <- list()
fft_summary_list <- list()
fft_top_list <- list()
fft_band_list <- list()

for (z in levels(daily_series$zone)) {
  dt_z <- daily_series[zone == z]

  for (i in seq_len(nrow(variables_temporales))) {
    var_name <- variables_temporales$variable[i]
    col_name <- variables_temporales$value_col[i]

    seg <- get_longest_complete_segment(dt_z, col_name)

    logi(
      "FFT | Zona:", z,
      "| Variable:", var_name,
      "| Días segmento:", nrow(seg)
    )

    res_fft <- compute_fft_spectrum(
      segment_dt = seg,
      variable_name = var_name,
      value_col = col_name
    )

    if (nrow(res_fft$spectrum) > 0) {
      res_fft$spectrum[, zone := z]
      fft_spectrum_list[[paste(z, var_name, sep = "_")]] <- res_fft$spectrum
    }

    if (nrow(res_fft$summary) > 0) {
      res_fft$summary[, zone := z]
      fft_summary_list[[paste(z, var_name, sep = "_")]] <- res_fft$summary
    }

    if (nrow(res_fft$top_periods) > 0) {
      res_fft$top_periods[, zone := z]
      res_fft$top_periods[, rank := seq_len(.N)]
      fft_top_list[[paste(z, var_name, sep = "_")]] <- res_fft$top_periods
    }

    if (nrow(res_fft$bands) > 0) {
      res_fft$bands[, zone := z]
      fft_band_list[[paste(z, var_name, sep = "_")]] <- res_fft$bands
    }
  }
}

fft_spectrum <- data.table::rbindlist(fft_spectrum_list, use.names = TRUE, fill = TRUE)
fft_summary <- data.table::rbindlist(fft_summary_list, use.names = TRUE, fill = TRUE)
fft_top_periods <- data.table::rbindlist(fft_top_list, use.names = TRUE, fill = TRUE)
fft_bands <- data.table::rbindlist(fft_band_list, use.names = TRUE, fill = TRUE)

for (obj_name in c("fft_spectrum", "fft_summary", "fft_top_periods", "fft_bands")) {
  obj <- get(obj_name)
  if (nrow(obj) > 0) {
    obj[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
    obj[, zona := zone_labels[as.character(zone)]]
    assign(obj_name, obj)
  }
}

data.table::setcolorder(fft_summary, c("zone", "zona", "variable"))
data.table::setcolorder(fft_top_periods, c("zone", "zona", "variable"))
data.table::setcolorder(fft_bands, c("zone", "zona", "variable"))

exportar_tabla(
  fft_summary,
  "Tabla_Cap2_C05_FFT_Resumen_Segmentos_VV_WPD_por_Zona_FINAL"
)

exportar_tabla(
  fft_top_periods,
  "Tabla_Cap2_C06_FFT_Periodos_Dominantes_VV_WPD_por_Zona_FINAL"
)

exportar_tabla(
  fft_bands,
  "Tabla_Cap2_C07_FFT_Energia_Bandas_VV_WPD_por_Zona_FINAL"
)

data.table::fwrite(
  fft_spectrum,
  file.path(DIR_PROCESSED, "cap2_C_FFT_espectro_completo_VV_WPD_por_zona.csv"),
  bom = TRUE
)

saveRDS(
  list(
    spectrum = fft_spectrum,
    summary = fft_summary,
    top_periods = fft_top_periods,
    bands = fft_bands
  ),
  file.path(DIR_PROCESSED, "cap2_C_resultados_FFT_VV_WPD_por_zona.rds")
)

# ============================================================
# 12. WAVELET MORLET PARA VV
# ============================================================

logi("Calculando Wavelet Morlet multizona para VV.")

compute_wavelet_morlet <- function(segment_dt, value_col = "VV_interp") {
  x <- segment_dt[[value_col]]
  valid <- is.finite(x)
  segment_dt <- segment_dt[valid]
  x <- segment_dt[[value_col]]

  n <- length(x)

  if (n < 128) {
    return(list(
      power = data.table(),
      summary = data.table()
    ))
  }

  x_scaled <- as.numeric(scale(x))
  x_scaled[!is.finite(x_scaled)] <- 0

  wave_data <- data.frame(
    t = seq_len(n),
    serie = x_scaled
  )

  upper_period <- min(512, floor(n / 2))

  wt <- WaveletComp::analyze.wavelet(
    my.data = wave_data,
    my.series = "serie",
    loess.span = 0,
    dt = 1,
    dj = 1 / 20,
    lowerPeriod = 2,
    upperPeriod = upper_period,
    make.pval = FALSE,
    n.sim = 0
  )

  power_matrix <- wt$Power
  periods <- wt$Period

  wave_df <- expand.grid(
    period_days = periods,
    time_index = seq_len(ncol(power_matrix)),
    KEEP.OUT.ATTRS = FALSE
  )

  wave_df <- data.table::as.data.table(wave_df)
  wave_df[, power := as.vector(power_matrix)]
  wave_df[, log_power := log10(power + .Machine$double.eps)]
  wave_df[, date := segment_dt$date[time_index]]

  summary_dt <- data.table::data.table(
    n_days_segment = n,
    segment_start = min(segment_dt$date, na.rm = TRUE),
    segment_end = max(segment_dt$date, na.rm = TRUE),
    lower_period_days = min(periods, na.rm = TRUE),
    upper_period_days = max(periods, na.rm = TRUE),
    mean_power = mean(power_matrix, na.rm = TRUE),
    max_power = max(power_matrix, na.rm = TRUE)
  )

  list(
    power = wave_df,
    summary = summary_dt
  )
}

wavelet_power_list <- list()
wavelet_summary_list <- list()

for (z in levels(daily_series$zone)) {
  dt_z <- daily_series[zone == z]
  seg <- get_longest_complete_segment(dt_z, "VV_interp")

  logi(
    "Wavelet Morlet | Zona:", z,
    "| Variable: VV",
    "| Días segmento:", nrow(seg)
  )

  res_wave <- compute_wavelet_morlet(seg, "VV_interp")

  if (nrow(res_wave$power) > 0) {
    res_wave$power[, zone := z]
    wavelet_power_list[[z]] <- res_wave$power
  }

  if (nrow(res_wave$summary) > 0) {
    res_wave$summary[, zone := z]
    wavelet_summary_list[[z]] <- res_wave$summary
  }
}

wavelet_power <- data.table::rbindlist(wavelet_power_list, use.names = TRUE, fill = TRUE)
wavelet_summary <- data.table::rbindlist(wavelet_summary_list, use.names = TRUE, fill = TRUE)

if (nrow(wavelet_power) > 0) {
  wavelet_power[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
  wavelet_power[, zona := zone_labels[as.character(zone)]]
}

if (nrow(wavelet_summary) > 0) {
  wavelet_summary[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
  wavelet_summary[, zona := zone_labels[as.character(zone)]]
  data.table::setcolorder(wavelet_summary, c("zone", "zona"))
}

exportar_tabla(
  wavelet_summary,
  "Tabla_Cap2_C08_Wavelet_Morlet_Resumen_Segmentos_VV_por_Zona_FINAL"
)

# Nota metodológica específica para interpretar la Wavelet Morlet.
# Esta tabla deja explícito que la comparabilidad depende de la longitud
# del segmento continuo regularizado disponible por zona.
wavelet_note <- data.table::copy(wavelet_summary)

if (nrow(wavelet_note) > 0) {
  wavelet_note[, limitacion_interpretativa := data.table::fifelse(
    n_days_segment < 365,
    "Segmento corto: no representa el periodo completo 2017–2022 y limita la interpretación de periodos largos.",
    "Segmento multianual: permite interpretación temporal más amplia dentro del tramo continuo disponible."
  )]

  wavelet_note[, uso_recomendado := data.table::fifelse(
    n_days_segment < 365,
    "Usar como evidencia de análisis multizona, pero discutir con cautela; no comparar bajas frecuencias largas con zonas de mayor cobertura.",
    "Usar para interpretación comparativa de patrones temporales dentro del segmento disponible."
  )]

  wavelet_note[, nota_general := paste0(
    "La Wavelet se calculó sobre el segmento continuo regularizado más largo. ",
    "Los espacios en blanco en la figura de eje común indican ausencia de datos continuos suficientes, no error gráfico."
  )]
}

exportar_tabla(
  wavelet_note,
  "Tabla_Cap2_C09_Nota_Interpretacion_Wavelet_Morlet_VV_por_Zona_FINAL"
)

data.table::fwrite(
  wavelet_power,
  file.path(DIR_PROCESSED, "cap2_C_wavelet_morlet_power_VV_por_zona.csv"),
  bom = TRUE
)

saveRDS(
  list(
    power = wavelet_power,
    summary = wavelet_summary
  ),
  file.path(DIR_PROCESSED, "cap2_C_resultados_wavelet_morlet_VV_por_zona.rds")
)

# ============================================================
# 13. FIGURAS ACF/PACF
# ============================================================

conf_acf <- temporal_summary[
  ,
  .(
    zone,
    variable,
    confidence_95 = unique(confidence_95)
  )
]

# 13.1 ACF WPD
fig_C01_acf_wpd <- ggplot(
  acf_values[variable == "WPD"],
  aes(x = lag, y = value, color = zone)
) +
  geom_hline(yintercept = 0, linewidth = 0.35, color = "black") +
  geom_hline(
    data = conf_acf[variable == "WPD"],
    aes(yintercept = confidence_95),
    inherit.aes = FALSE,
    linetype = "dashed",
    color = "grey35",
    linewidth = 0.35
  ) +
  geom_hline(
    data = conf_acf[variable == "WPD"],
    aes(yintercept = -confidence_95),
    inherit.aes = FALSE,
    linetype = "dashed",
    color = "grey35",
    linewidth = 0.35
  ) +
  geom_segment(aes(xend = lag, y = 0, yend = value), linewidth = 0.6) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_continuous(breaks = seq(0, 60, by = 10), limits = c(0, 60)) +
  labs(
    title = "Autocorrelación diaria de la densidad de potencia eólica por zona",
    subtitle = "ACF de WPD sobre series diarias regularizadas con interpolación de brechas cortas",
    x = "Rezago temporal (días)",
    y = "ACF"
  ) +
  theme_tesis()

exportar_figura(
  fig_C01_acf_wpd,
  "Fig_Cap2_C01_ACF_Diaria_WPD_por_Zona_FINAL",
  width = 9,
  height = 6.6
)

# 13.2 PACF WPD
fig_C02_pacf_wpd <- ggplot(
  pacf_values[variable == "WPD"],
  aes(x = lag, y = value, color = zone)
) +
  geom_hline(yintercept = 0, linewidth = 0.35, color = "black") +
  geom_hline(
    data = conf_acf[variable == "WPD"],
    aes(yintercept = confidence_95),
    inherit.aes = FALSE,
    linetype = "dashed",
    color = "grey35",
    linewidth = 0.35
  ) +
  geom_hline(
    data = conf_acf[variable == "WPD"],
    aes(yintercept = -confidence_95),
    inherit.aes = FALSE,
    linetype = "dashed",
    color = "grey35",
    linewidth = 0.35
  ) +
  geom_segment(aes(xend = lag, y = 0, yend = value), linewidth = 0.6) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_continuous(breaks = seq(0, 60, by = 10), limits = c(0, 60)) +
  labs(
    title = "Autocorrelación parcial diaria de la densidad de potencia eólica por zona",
    subtitle = "PACF de WPD sobre series diarias regularizadas con interpolación de brechas cortas",
    x = "Rezago temporal (días)",
    y = "PACF"
  ) +
  theme_tesis()

exportar_figura(
  fig_C02_pacf_wpd,
  "Fig_Cap2_C02_PACF_Diaria_WPD_por_Zona_FINAL",
  width = 9,
  height = 6.6
)

# 13.3 ACF VV
fig_C03_acf_vv <- ggplot(
  acf_values[variable == "VV"],
  aes(x = lag, y = value, color = zone)
) +
  geom_hline(yintercept = 0, linewidth = 0.35, color = "black") +
  geom_hline(
    data = conf_acf[variable == "VV"],
    aes(yintercept = confidence_95),
    inherit.aes = FALSE,
    linetype = "dashed",
    color = "grey35",
    linewidth = 0.35
  ) +
  geom_hline(
    data = conf_acf[variable == "VV"],
    aes(yintercept = -confidence_95),
    inherit.aes = FALSE,
    linetype = "dashed",
    color = "grey35",
    linewidth = 0.35
  ) +
  geom_segment(aes(xend = lag, y = 0, yend = value), linewidth = 0.6) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_continuous(breaks = seq(0, 60, by = 10), limits = c(0, 60)) +
  labs(
    title = "Autocorrelación diaria de la velocidad del viento por zona",
    subtitle = "ACF de VV sobre series diarias regularizadas con interpolación de brechas cortas",
    x = "Rezago temporal (días)",
    y = "ACF"
  ) +
  theme_tesis()

exportar_figura(
  fig_C03_acf_vv,
  "Fig_Cap2_C03_ACF_Diaria_VV_por_Zona_FINAL",
  width = 9,
  height = 6.6
)

# 13.4 PACF VV
fig_C04_pacf_vv <- ggplot(
  pacf_values[variable == "VV"],
  aes(x = lag, y = value, color = zone)
) +
  geom_hline(yintercept = 0, linewidth = 0.35, color = "black") +
  geom_hline(
    data = conf_acf[variable == "VV"],
    aes(yintercept = confidence_95),
    inherit.aes = FALSE,
    linetype = "dashed",
    color = "grey35",
    linewidth = 0.35
  ) +
  geom_hline(
    data = conf_acf[variable == "VV"],
    aes(yintercept = -confidence_95),
    inherit.aes = FALSE,
    linetype = "dashed",
    color = "grey35",
    linewidth = 0.35
  ) +
  geom_segment(aes(xend = lag, y = 0, yend = value), linewidth = 0.6) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_continuous(breaks = seq(0, 60, by = 10), limits = c(0, 60)) +
  labs(
    title = "Autocorrelación parcial diaria de la velocidad del viento por zona",
    subtitle = "PACF de VV sobre series diarias regularizadas con interpolación de brechas cortas",
    x = "Rezago temporal (días)",
    y = "PACF"
  ) +
  theme_tesis()

exportar_figura(
  fig_C04_pacf_vv,
  "Fig_Cap2_C04_PACF_Diaria_VV_por_Zona_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 14. FIGURAS FFT
# ============================================================

fft_spectrum_plot <- fft_spectrum[
  period_days >= 2 &
    period_days <= 730 &
    is.finite(power_fraction)
]

# 14.1 Espectro WPD
fig_C05_fft_wpd_spectrum <- ggplot(
  fft_spectrum_plot[variable == "WPD"],
  aes(x = period_days, y = power_fraction, color = zone)
) +
  geom_line(linewidth = 0.75, alpha = 0.9) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_log10(
    breaks = c(2, 7, 30, 90, 180, 365, 730),
    labels = c("2", "7", "30", "90", "180", "365", "730")
  ) +
  labs(
    title = "Espectro FFT diario de la densidad de potencia eólica por zona",
    subtitle = "Potencia espectral normalizada de WPD en función del periodo temporal",
    x = "Periodo temporal (días, escala log10)",
    y = "Fracción de potencia espectral"
  ) +
  theme_tesis()

exportar_figura(
  fig_C05_fft_wpd_spectrum,
  "Fig_Cap2_C05_FFT_Espectro_Diario_WPD_por_Zona_FINAL",
  width = 9,
  height = 6.6
)

# 14.2 Energía espectral WPD por bandas
fig_C06_fft_wpd_bands <- ggplot(
  fft_bands[variable == "WPD"],
  aes(x = zone, y = band_power_pct, fill = band)
) +
  geom_col(color = "black", linewidth = 0.35, width = 0.72) +
  scale_fill_manual(values = band_palette, name = "Banda temporal") +
  scale_x_discrete(labels = zone_labels) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "Distribución de energía espectral de WPD por banda temporal",
    subtitle = "Bandas calculadas a partir del espectro FFT diario por zona",
    x = "Zona analítica",
    y = "Participación de energía espectral"
  ) +
  theme_tesis()

exportar_figura(
  fig_C06_fft_wpd_bands,
  "Fig_Cap2_C06_FFT_Energia_Bandas_WPD_por_Zona_FINAL",
  width = 8.6,
  height = 6.2
)

# 14.3 Espectro VV
fig_C07_fft_vv_spectrum <- ggplot(
  fft_spectrum_plot[variable == "VV"],
  aes(x = period_days, y = power_fraction, color = zone)
) +
  geom_line(linewidth = 0.75, alpha = 0.9) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_log10(
    breaks = c(2, 7, 30, 90, 180, 365, 730),
    labels = c("2", "7", "30", "90", "180", "365", "730")
  ) +
  labs(
    title = "Espectro FFT diario de la velocidad del viento por zona",
    subtitle = "Potencia espectral normalizada de VV en función del periodo temporal",
    x = "Periodo temporal (días, escala log10)",
    y = "Fracción de potencia espectral"
  ) +
  theme_tesis()

exportar_figura(
  fig_C07_fft_vv_spectrum,
  "Fig_Cap2_C07_FFT_Espectro_Diario_VV_por_Zona_FINAL",
  width = 9,
  height = 6.6
)

# 14.4 Energía espectral VV por bandas
fig_C08_fft_vv_bands <- ggplot(
  fft_bands[variable == "VV"],
  aes(x = zone, y = band_power_pct, fill = band)
) +
  geom_col(color = "black", linewidth = 0.35, width = 0.72) +
  scale_fill_manual(values = band_palette, name = "Banda temporal") +
  scale_x_discrete(labels = zone_labels) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "Distribución de energía espectral de VV por banda temporal",
    subtitle = "Bandas calculadas a partir del espectro FFT diario por zona",
    x = "Zona analítica",
    y = "Participación de energía espectral"
  ) +
  theme_tesis()

exportar_figura(
  fig_C08_fft_vv_bands,
  "Fig_Cap2_C08_FFT_Energia_Bandas_VV_por_Zona_FINAL",
  width = 8.6,
  height = 6.2
)

# ============================================================
# 15. FIGURAS WAVELET MORLET VV MULTIZONA
# ============================================================

if (nrow(wavelet_power) > 0) {

  # 15.1 Figura Wavelet con eje común.
  # Uso: evidencia metodológica; muestra honestamente los huecos temporales.
  fig_C09A_wavelet_vv_common_axis <- ggplot(
    wavelet_power,
    aes(x = date, y = period_days, fill = log_power)
  ) +
    geom_raster(interpolate = FALSE) +
    facet_wrap(
      ~ zone,
      ncol = 2,
      labeller = labeller(zone = zone_labels)
    ) +
    scale_y_log10(
      breaks = c(2, 7, 15, 30, 60, 120, 240, 365, 512),
      labels = c("2", "7", "15", "30", "60", "120", "240", "365", "512")
    ) +
    scale_fill_gradientn(
      colors = c("#08306B", "#2171B5", "#6BAED6", "#FEE391", "#F16913", "#A50F15"),
      name = expression(log[10] * "(potencia)")
    ) +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    labs(
      title = "Espectro Wavelet Morlet de la velocidad del viento por zona",
      subtitle = "Eje común 2017–2022; los espacios blancos indican ausencia de segmento continuo regularizado",
      x = "Año",
      y = "Periodo temporal (días, escala log10)"
    ) +
    theme_tesis() +
    theme(
      legend.position = "right",
      panel.grid.major.x = ggplot2::element_line(color = "grey85", linewidth = 0.25)
    )

  exportar_figura(
    fig_C09A_wavelet_vv_common_axis,
    "Fig_Cap2_C09A_Wavelet_Morlet_VV_Eje_Comun_por_Zona_FINAL",
    width = 10.5,
    height = 7.4
  )

  # 15.2 Figura Wavelet con segmento útil por zona.
  # Uso: figura principal recomendada; mejora legibilidad visual.
  # Nota: escalas libres en X e Y para mostrar el tramo resoluble de cada zona.
  fig_C09B_wavelet_vv_useful_segment <- ggplot(
    wavelet_power,
    aes(x = date, y = period_days, fill = log_power)
  ) +
    geom_raster(interpolate = FALSE) +
    facet_wrap(
      ~ zone,
      ncol = 2,
      scales = "free",
      labeller = labeller(zone = zone_labels)
    ) +
    scale_y_log10(
      breaks = c(2, 7, 15, 30, 60, 120, 240, 365, 512),
      labels = c("2", "7", "15", "30", "60", "120", "240", "365", "512")
    ) +
    scale_fill_gradientn(
      colors = c("#08306B", "#2171B5", "#6BAED6", "#FEE391", "#F16913", "#A50F15"),
      name = expression(log[10] * "(potencia)")
    ) +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    labs(
      title = "Espectro Wavelet Morlet de la velocidad del viento por zona",
      subtitle = "Segmento continuo útil por zona; escalas libres para mejorar la lectura del patrón interno",
      x = "Año",
      y = "Periodo temporal (días, escala log10)"
    ) +
    theme_tesis() +
    theme(
      legend.position = "right",
      panel.grid.major.x = ggplot2::element_line(color = "grey85", linewidth = 0.25)
    )

  exportar_figura(
    fig_C09B_wavelet_vv_useful_segment,
    "Fig_Cap2_C09B_Wavelet_Morlet_VV_Segmento_Util_por_Zona_FINAL",
    width = 10.5,
    height = 7.4
  )

  # 15.3 Figura Wavelet fina: X libre y Y común.
  # Uso recomendado como figura principal en tesis.
  # Ventaja: cada zona muestra su segmento útil, pero la escala de periodos
  # permanece comparable entre zonas.
  fig_C09C_wavelet_vv_free_x_common_y <- ggplot(
    wavelet_power,
    aes(x = date, y = period_days, fill = log_power)
  ) +
    geom_raster(interpolate = FALSE) +
    facet_wrap(
      ~ zone,
      ncol = 2,
      scales = "free_x",
      labeller = labeller(zone = zone_labels)
    ) +
    scale_y_log10(
      limits = c(2, 512),
      breaks = c(2, 7, 15, 30, 60, 120, 240, 365, 512),
      labels = c("2", "7", "15", "30", "60", "120", "240", "365", "512")
    ) +
    scale_fill_gradientn(
      colors = c("#08306B", "#2171B5", "#6BAED6", "#FEE391", "#F16913", "#A50F15"),
      name = expression(log[10] * "(potencia)")
    ) +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    labs(
      title = "Espectro Wavelet Morlet de la velocidad del viento por zona",
      subtitle = "Segmento continuo útil por zona; eje X libre y eje de periodos común para comparación",
      x = "Año",
      y = "Periodo temporal (días, escala log10)"
    ) +
    theme_tesis() +
    theme(
      legend.position = "right",
      panel.grid.major.x = ggplot2::element_line(color = "grey85", linewidth = 0.25)
    )

  exportar_figura(
    fig_C09C_wavelet_vv_free_x_common_y,
    "Fig_Cap2_C09C_Wavelet_Morlet_VV_X_Libre_Y_Comun_por_Zona_FINAL",
    width = 10.5,
    height = 7.4
  )

} else {
  logi("No se generaron figuras Wavelet: no hubo segmentos suficientes.")
}

# ============================================================
# 16. GUÍA DE INSERCIÓN Y MANIFIESTO
# ============================================================

guia <- c(
  "# Capítulo 2 — Parte C: guía de inserción V2",
  "",
  "## Figuras principales sugeridas",
  "",
  "1. Fig_Cap2_C01_ACF_Diaria_WPD_por_Zona_FINAL",
  "2. Fig_Cap2_C05_FFT_Espectro_Diario_WPD_por_Zona_FINAL",
  "3. Fig_Cap2_C06_FFT_Energia_Bandas_WPD_por_Zona_FINAL",
  "4. Fig_Cap2_C09C_Wavelet_Morlet_VV_X_Libre_Y_Comun_por_Zona_FINAL",
  "",
  "## Figuras de soporte metodológico o anexo",
  "",
  "- Fig_Cap2_C09A_Wavelet_Morlet_VV_Eje_Comun_por_Zona_FINAL
  - Fig_Cap2_C09B_Wavelet_Morlet_VV_Segmento_Util_por_Zona_FINAL",
  "- Fig_Cap2_C02_PACF_Diaria_WPD_por_Zona_FINAL",
  "- Fig_Cap2_C03_ACF_Diaria_VV_por_Zona_FINAL",
  "- Fig_Cap2_C04_PACF_Diaria_VV_por_Zona_FINAL",
  "- Fig_Cap2_C07_FFT_Espectro_Diario_VV_por_Zona_FINAL",
  "- Fig_Cap2_C08_FFT_Energia_Bandas_VV_por_Zona_FINAL",
  "",
  "## Tablas principales sugeridas",
  "",
  "1. Tabla_Cap2_C01_Cobertura_Diaria_Regularizada_por_Zona_FINAL",
  "2. Tabla_Cap2_C04_Resumen_Dependencia_Temporal_VV_WPD_por_Zona_FINAL",
  "3. Tabla_Cap2_C05_FFT_Resumen_Segmentos_VV_WPD_por_Zona_FINAL",
  "4. Tabla_Cap2_C06_FFT_Periodos_Dominantes_VV_WPD_por_Zona_FINAL",
  "5. Tabla_Cap2_C07_FFT_Energia_Bandas_VV_WPD_por_Zona_FINAL",
  "6. Tabla_Cap2_C08_Wavelet_Morlet_Resumen_Segmentos_VV_por_Zona_FINAL",
  "7. Tabla_Cap2_C09_Nota_Interpretacion_Wavelet_Morlet_VV_por_Zona_FINAL",
  "",
  "## Decisiones metodológicas",
  "",
  "- La agregación diaria reduce ruido subdiario y permite comparar persistencia temporal entre zonas.",
  "- Las brechas cortas se interpolan hasta un máximo de 7 días para ACF/PACF, FFT y Wavelet.",
  "- Los análisis temporales usan el segmento diario regularizado continuo más largo de cada zona.",
  "- ACF/PACF y FFT se calculan para VV y WPD.",
  "- La Wavelet Morlet se presenta para VV como variable física central del Capítulo 2.",
  "- Se generan tres versiones Wavelet: eje común 2017–2022, segmento útil con escalas libres y versión fina con eje X libre y eje de periodos común.",
  "- WPD se conserva como variable energética principal en ACF y FFT.",
  "",
  "## Nota obligatoria para interpretar la Wavelet",
  "",
  "La comparación Wavelet debe leerse considerando la longitud desigual de los segmentos continuos disponibles. La Zona 4 presenta un segmento más corto que las demás zonas, por lo que su espectro Wavelet no representa todo el periodo 2017–2022 y no debe interpretarse en bajas frecuencias largas con la misma fuerza que las zonas 1, 2 y 3.",
  "",
  "## Advertencia de interpretación",
  "",
  "La interpolación controlada se usa solo para diagnóstico temporal/espectral. No reemplaza los datos originales ni se usa para recalcular los estadísticos descriptivos de la Parte B."
)

writeLines(
  guia,
  file.path(DIR_TEXTOS, "cap2_C_guia_insercion_dependencia_temporal_espectral_wavelet_V3.md"),
  useBytes = TRUE
)

manifest <- data.table::data.table(
  tipo = c(
    rep("tabla", 9),
    rep("figura", 11),
    rep("procesado", 5)
  ),
  archivo = c(
    "Tabla_Cap2_C01_Cobertura_Diaria_Regularizada_por_Zona_FINAL.csv/xlsx",
    "Tabla_Cap2_C02_Valores_ACF_Diaria_VV_WPD_por_Zona_FINAL.csv/xlsx",
    "Tabla_Cap2_C03_Valores_PACF_Diaria_VV_WPD_por_Zona_FINAL.csv/xlsx",
    "Tabla_Cap2_C04_Resumen_Dependencia_Temporal_VV_WPD_por_Zona_FINAL.csv/xlsx",
    "Tabla_Cap2_C05_FFT_Resumen_Segmentos_VV_WPD_por_Zona_FINAL.csv/xlsx",
    "Tabla_Cap2_C06_FFT_Periodos_Dominantes_VV_WPD_por_Zona_FINAL.csv/xlsx",
    "Tabla_Cap2_C07_FFT_Energia_Bandas_VV_WPD_por_Zona_FINAL.csv/xlsx",
    "Tabla_Cap2_C08_Wavelet_Morlet_Resumen_Segmentos_VV_por_Zona_FINAL.csv/xlsx",
    "Tabla_Cap2_C09_Nota_Interpretacion_Wavelet_Morlet_VV_por_Zona_FINAL.csv/xlsx",
    "Fig_Cap2_C01_ACF_Diaria_WPD_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_C02_PACF_Diaria_WPD_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_C03_ACF_Diaria_VV_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_C04_PACF_Diaria_VV_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_C05_FFT_Espectro_Diario_WPD_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_C06_FFT_Energia_Bandas_WPD_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_C07_FFT_Espectro_Diario_VV_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_C08_FFT_Energia_Bandas_VV_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_C09A_Wavelet_Morlet_VV_Eje_Comun_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_C09B_Wavelet_Morlet_VV_Segmento_Util_por_Zona_FINAL.png/pdf/svg",
    "Fig_Cap2_C09C_Wavelet_Morlet_VV_X_Libre_Y_Comun_por_Zona_FINAL.png/pdf/svg",
    "cap2_C_series_diarias_regularizadas_VV_WPD_por_zona.rds/csv",
    "cap2_C_resultados_FFT_VV_WPD_por_zona.rds",
    "cap2_C_FFT_espectro_completo_VV_WPD_por_zona.csv",
    "cap2_C_resultados_wavelet_morlet_VV_por_zona.rds",
    "cap2_C_wavelet_morlet_power_VV_por_zona.csv"
  ),
  ubicacion = c(
    rep(DIR_TABLES, 9),
    rep(DIR_FIGURES, 11),
    rep(DIR_PROCESSED, 5)
  ),
  uso_sugerido = c(
    "Cuerpo o anexo: trazabilidad de cobertura diaria",
    "Anexo: valores completos ACF",
    "Anexo: valores completos PACF",
    "Cuerpo: resumen de persistencia temporal",
    "Cuerpo o anexo: segmentos usados para FFT",
    "Cuerpo o anexo: periodos dominantes",
    "Cuerpo: energía espectral por bandas",
    "Cuerpo o anexo: segmentos Wavelet",
    "Cuerpo o anexo: nota interpretativa obligatoria de Wavelet",
    "Cuerpo: persistencia diaria de WPD",
    "Anexo: PACF diaria de WPD",
    "Anexo: ACF diaria de VV",
    "Anexo: PACF diaria de VV",
    "Cuerpo: espectro FFT de WPD",
    "Cuerpo: energía espectral WPD por bandas",
    "Anexo: espectro FFT de VV",
    "Anexo: energía espectral VV por bandas",
    "Soporte metodológico: Wavelet con eje común 2017–2022",
    "Soporte visual: Wavelet por segmento útil con escalas libres",
    "Cuerpo: Wavelet Morlet multizona con X libre e Y común",
    "Entrada regularizada para trazabilidad temporal",
    "Resultados FFT reproducibles",
    "Espectro FFT completo",
    "Resultados Wavelet reproducibles",
    "Potencia Wavelet completa"
  )
)

data.table::fwrite(
  manifest,
  file.path(DIR_LOGS, "manifest_cap2_C_dependencia_temporal_espectral_wavelet_V3.csv"),
  bom = TRUE
)

writeLines(
  capture.output(sessionInfo()),
  file.path(DIR_LOGS, "sessionInfo_cap2_C_dependencia_temporal_espectral_wavelet_V3.txt"),
  useBytes = TRUE
)

logi("CAPÍTULO 2 — PARTE C V3 FINALIZADA")
logi("Fin:", as.character(Sys.time()))
logi("============================================================")

cat("\n============================================================\n")
cat("CAPÍTULO 2 — PARTE C V3 FINALIZADA\n")
cat("Fin:", as.character(Sys.time()), "\n")
cat("============================================================\n")

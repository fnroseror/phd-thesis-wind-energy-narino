# ============================================================
# 01_cap4_structural_projection_2017_2028.R
# CAPÍTULO 4 - PROYECCIÓN ESTRUCTURAL 2017–2028
# Tesis doctoral - Favio Nicolás Rosero Rodríguez
# ============================================================

rm(list = ls())
gc()

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
  library(ggplot2)
})

# ============================================================
# 1. RUTAS OFICIALES
# ============================================================

BASE_FILE <- "H:/Mi unidad/Academia/UNAL/DOCTORADO/Cierre Tesis/Datos.txt"
stopifnot(file.exists(BASE_FILE))

BASE_DIR <- dirname(BASE_FILE)

PREDS_FILE <- file.path(
  BASE_DIR,
  "SALIDAS_CAP3_TDQ_PIESS",
  "PREDICCIONES",
  "TDQ_PIESS_PREDS_GLOBAL.csv"
)

stopifnot(file.exists(PREDS_FILE))

OUT_DIR <- file.path(BASE_DIR, "SALIDAS_CAP4_STRUCTURAL_PROJECTION")
TAB_DIR <- file.path(OUT_DIR, "TABLAS")
FIG_DIR <- file.path(OUT_DIR, "FIGURAS")
LOG_FILE <- file.path(OUT_DIR, "CAP4_STRUCTURAL_PROJECTION_LOG.txt")

dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(TAB_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

# ============================================================
# 2. UTILIDADES
# ============================================================

logi <- function(...) {
  msg <- paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "|", paste(..., collapse = " "))
  cat(msg, "\n")
  cat(msg, "\n", file = LOG_FILE, append = TRUE)
}

theme_pub <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.major = element_line(color = "grey90"),
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold"),
      legend.position = "bottom"
    )
}

save_plot <- function(p, stem, w = 10, h = 6, dpi = 300) {
  ggsave(file.path(FIG_DIR, paste0(stem, ".png")), p, width = w, height = h, dpi = dpi)
  ggsave(file.path(FIG_DIR, paste0(stem, ".pdf")), p, width = w, height = h)
}

# ============================================================
# 3. CARGA DE PREDICCIONES TDQ–PIESS
# ============================================================

logi("Leyendo archivo híbrido:", PREDS_FILE)

P <- fread(PREDS_FILE, showProgress = TRUE)

stopifnot(all(c("Zona", "Horizonte", "FechaHora", "y_true", "PI_low90", "PI_high90", "FNRR") %in% names(P)))

P[, FechaHora := as.POSIXct(FechaHora, tz = "America/Bogota")]

P <- P[
  is.finite(y_true) &
    is.finite(PI_low90) &
    is.finite(PI_high90) &
    is.finite(FNRR) &
    !is.na(Zona) &
    !is.na(Horizonte) &
    !is.na(FechaHora)
]

P[, Zona := as.integer(Zona)]
P[, Year := year(FechaHora)]

logi("Registros válidos:", nrow(P))

# ============================================================
# 4. ENERGÍA ANUAL HISTÓRICA
# ============================================================

ENERG_HIST <- P[, .(
  E_true_kWh_m2 = sum(y_true, na.rm = TRUE) / 1000,
  E_low_kWh_m2  = sum(PI_low90, na.rm = TRUE) / 1000,
  E_high_kWh_m2 = sum(PI_high90, na.rm = TRUE) / 1000,
  FNRR_mean_year = mean(FNRR, na.rm = TRUE)
), by = .(Zona, Horizonte, Year)]

setorder(ENERG_HIST, Zona, Horizonte, Year)

# ============================================================
# 5. RESUMEN ESTRUCTURAL 2017–2022
# ============================================================

RES_STRUCT <- ENERG_HIST[, .(
  E_mean_2017_2022 = mean(E_true_kWh_m2, na.rm = TRUE),
  E_sd_2017_2022   = sd(E_true_kWh_m2, na.rm = TRUE),
  E_p05_2017_2022  = as.numeric(quantile(E_true_kWh_m2, 0.05, na.rm = TRUE)),
  E_p95_2017_2022  = as.numeric(quantile(E_true_kWh_m2, 0.95, na.rm = TRUE)),
  FNRR_structural  = mean(FNRR_mean_year, na.rm = TRUE)
), by = .(Zona, Horizonte)]

setorder(RES_STRUCT, Zona, Horizonte)

# ============================================================
# 6. PROYECCIÓN ESTRUCTURAL 2023–2028
# ============================================================

YEARS_FUT <- 2023:2028
PROY_LIST <- list()

for (yy in YEARS_FUT) {
  tmp <- RES_STRUCT[, .(
    Zona,
    Horizonte,
    Year = yy,
    E_proj_kWh_m2 = E_mean_2017_2022,
    E_p05_kWh_m2  = E_p05_2017_2022,
    E_p95_kWh_m2  = E_p95_2017_2022,
    FNRR_mean_year = FNRR_structural
  )]
  PROY_LIST[[length(PROY_LIST) + 1]] <- tmp
}

ENERG_PROY <- rbindlist(PROY_LIST)
setorder(ENERG_PROY, Zona, Horizonte, Year)

# ============================================================
# 7. ESCENARIO 2028
# ============================================================

SCENARIO_2028 <- ENERG_PROY[Year == 2028, .(
  Zona,
  Escenario_Conservador = round(E_p05_kWh_m2, 2),
  Escenario_Central     = round(E_proj_kWh_m2, 2),
  Escenario_Optimista   = round(E_p95_kWh_m2, 2)
), by = .(Zona, Horizonte)]

setorder(SCENARIO_2028, Zona, Horizonte)

# ============================================================
# 8. EXPORTACIÓN DE TABLAS
# ============================================================

fwrite(ENERG_HIST, file.path(TAB_DIR, "01_ENERGIA_ANUAL_HISTORICA.csv"))
fwrite(RES_STRUCT, file.path(TAB_DIR, "02_RESUMEN_ESTRUCTURAL_2017_2022.csv"))
fwrite(ENERG_PROY, file.path(TAB_DIR, "03_PROYECCION_ESTRUCTURAL_2023_2028.csv"))
fwrite(SCENARIO_2028, file.path(TAB_DIR, "04_ESCENARIO_ENERGETICO_2028.csv"))

# ============================================================
# 9. FIGURAS PUBLICABLES
# ============================================================

p_energy <- ggplot() +
  geom_line(
    data = ENERG_HIST,
    aes(x = Year, y = E_true_kWh_m2, color = factor(Zona)),
    linewidth = 0.8
  ) +
  geom_line(
    data = ENERG_PROY,
    aes(x = Year, y = E_proj_kWh_m2, color = factor(Zona)),
    linetype = "dashed",
    linewidth = 0.8
  ) +
  facet_wrap(~Horizonte, scales = "free_y") +
  labs(
    title = "Energía Eólica Anual: Histórico vs Proyección Estructural",
    y = "Energía (kWh/m²)",
    x = "Año",
    color = "Zona"
  ) +
  theme_pub()

save_plot(p_energy, "05_FIG_ENERGIA_HIST_PROY", w = 10, h = 6, dpi = 300)

p_fnrr <- ggplot() +
  geom_line(
    data = ENERG_HIST,
    aes(x = Year, y = FNRR_mean_year, color = factor(Zona)),
    linewidth = 0.8
  ) +
  geom_line(
    data = ENERG_PROY,
    aes(x = Year, y = FNRR_mean_year, color = factor(Zona)),
    linetype = "dashed",
    linewidth = 0.8
  ) +
  facet_wrap(~Horizonte) +
  labs(
    title = "FNRR Anual: Firma Regional Estructural",
    y = "FNRR",
    x = "Año",
    color = "Zona"
  ) +
  theme_pub()

save_plot(p_fnrr, "06_FIG_FNRR_HIST_PROY", w = 10, h = 6, dpi = 300)

# ============================================================
# 10. SESSION INFO
# ============================================================

sink(file.path(OUT_DIR, "sessionInfo_structural_projection.txt"))
print(sessionInfo())
sink()

# ============================================================
# 11. CIERRE
# ============================================================

logi("CAPÍTULO 4 COMPLETADO")
logi("Resultados en:", OUT_DIR)
logi("Tabla histórica:", file.path(TAB_DIR, "01_ENERGIA_ANUAL_HISTORICA.csv"))
logi("Tabla estructural:", file.path(TAB_DIR, "02_RESUMEN_ESTRUCTURAL_2017_2022.csv"))
logi("Tabla proyección:", file.path(TAB_DIR, "03_PROYECCION_ESTRUCTURAL_2023_2028.csv"))
logi("Escenario 2028:", file.path(TAB_DIR, "04_ESCENARIO_ENERGETICO_2028.csv"))

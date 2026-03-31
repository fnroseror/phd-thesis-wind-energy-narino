# ============================================================
# CAP2 – Physical & Spectral Analysis (VV)
# PURPOSE: Chapter 2 analysis: QC + descriptives + Weibull/Rayleigh + FFT/Wavelet/ACF/PACF + exports
# INPUTS: IDEAM long-format data (Estación, FechaYHora, Valor, Zona, Variable) OR your prepared dataset
# OUTPUTS: Figures (PNG) + Tables (CSV) for main doc and annexes
# NOTE: This script was extracted from the working thesis pipeline and
#       lightly cleaned for GitHub (paths made configurable, unicode normalized).
# ============================================================

Código análisis físico espectral
# ============================================================
# CAPÍTULO 2 - PIPELINE REPRODUCIBLE (VV) - Favio Rosero
# Datos IDEAM (formato largo): Estación, FechaYHora, Valor, Zona, Variable
# Salidas: Tablas (CSV) + Figuras (PNG) estilo Nature/Q1:
#          Principal + Anexos
# Incluye:
#  - QC (A1/A2/A3) + trazabilidad limpieza VV
#  - Descriptivos por zona + boxplot/hist
#  - Weibull vs Rayleigh (MLE): tabla + PDF/CDF + QQ/PP
#  - Señal zonal (ensamble por timestamp) + paso dominante
#  - FFT por zona (anexos) + FFT zona representativa (principal)
#  - Wavelet por zona (anexos) + Wavelet representativa (principal)
#  - ACF/PACF por zona (anexos) + representativa (principal)
#  - Tabla maestra final
# NOTA CLAVE (asesor): se justifican parámetros con:
#  - dt_min inferido (mediana de diffs)
#  - resample regular con límite MAX_GRID (anti 950 GB)
#  - Wavelet con ventana (último año) y MAX_N (downsample) para estabilidad
# ============================================================

rm(list = ls()); gc()

# ---------------------------
# 0) PAQUETES
# ---------------------------
pkgs <- c(
  "data.table","lubridate","stringr",
  "ggplot2","scales",
  "moments","fitdistrplus",
  "zoo","biwavelet"
)
to_install <- pkgs[!pkgs %in% installed.packages()[,"Package"]]
if (length(to_install) > 0) install.packages(to_install, dependencies = TRUE)
invisible(lapply(pkgs, library, character.only = TRUE))

# (Opcional recomendado para PNG nítidos)
# install.packages("ragg")

# ---------------------------
# 1) RUTAS
# ---------------------------
base_dir <- ""  # <-- set path
data_path <- file.path(base_dir, "Datos.txt")
out_dir   <- file.path(base_dir, "Capitulo 2")

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir_main_fig <- file.path(out_dir, "Figuras_Principal")
dir_ann_fig  <- file.path(out_dir, "Figuras_Anexos")
dir_tables   <- file.path(out_dir, "Tablas")
dir.create(dir_main_fig, recursive = TRUE, showWarnings = FALSE)
dir.create(dir_ann_fig,  recursive = TRUE, showWarnings = FALSE)
dir.create(dir_tables,   recursive = TRUE, showWarnings = FALSE)

# ---------------------------
# 2) CONFIG (DEFENDIBLE / ANTI-ERRORES)
# ---------------------------
CFG <- list(
  TARGET_VAR = "VV",
  TZ = "America/Bogota",

  # limpieza mínima (ajustable si asesor pide umbral):
  MIN_V = 0,

  # inferencia y resample (anti grillas gigantes)
  STEP_MIN_MIN = 1,       # mínimo 1 min
  STEP_MIN_MAX = 180,     # máximo 180 min (si >, se fuerza 60)
  STEP_FALLBACK = 60,     # fallback 60 min
  MAX_GRID = 200000,      # límite de puntos en grilla regular (anti 950 GB)
  MAX_LAG_H = 240,        # ACF/PACF hasta 240 horas

  # ventana wavelet/memoria/espectral (justificable)
  WINDOW_DAYS = 365,      # último año (cambia a 730 si quieres 2 años)

  # wavelet (anti memoria/tiempo excesivo)
  WAVELET_MAX_N = 20000,  # máximo puntos tras downsample (stride)
  WAVELET_DJ = 1/20       # resolución escala
)

# ---------------------------
# 3) ESTILO NATURE/Q1 (GRANDE + ANTI-RECORTE)
# ---------------------------
pal_zona <- c("1"="#1B9E77","2"="#D95F02","3"="#7570B3","4"="#E7298A")

BASE_SIZE <- 16
TITLE_SIZE <- 18
SUBTITLE_SIZE <- 15
AXIS_TITLE_SIZE <- 17
AXIS_TEXT_SIZE <- 15
LEGEND_TITLE_SIZE <- 15
LEGEND_TEXT_SIZE  <- 14
STRIP_TEXT_SIZE   <- 15

nature_theme <- theme_classic(base_size = BASE_SIZE) +
  theme(
    plot.title = element_text(face="bold", size=TITLE_SIZE, hjust=0.5, margin=margin(b=10)),
    plot.subtitle = element_text(size=SUBTITLE_SIZE, hjust=0.5, margin=margin(b=8)),
    axis.title = element_text(face="bold", size=AXIS_TITLE_SIZE),
    axis.text  = element_text(size=AXIS_TEXT_SIZE, color="black"),
    axis.line  = element_line(linewidth=0.7, color="black"),
    axis.ticks = element_line(linewidth=0.7, color="black"),
    panel.grid.major = element_line(linewidth=0.25, color="grey88"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face="bold", size=LEGEND_TITLE_SIZE),
    legend.text  = element_text(size=LEGEND_TEXT_SIZE),
    strip.text = element_text(face="bold", size=STRIP_TEXT_SIZE),
    plot.margin = margin(18, 18, 18, 18),
    plot.background = element_rect(fill="white", color=NA)
  )

save_fig <- function(p, path, w=7.8, h=5.2, dpi=520) {
  if (requireNamespace("ragg", quietly = TRUE)) {
    ragg::agg_png(filename = path, width = w, height = h, units = "in", res = dpi, background = "white")
    print(p); dev.off()
  } else {
    ggsave(filename = path, plot = p, width = w, height = h, dpi = dpi,
           units = "in", bg = "white", limitsize = FALSE)
  }
}

# ---------------------------
# 4) FUNCIONES AUXILIARES (ROBUSTEZ)
# ---------------------------

# Parseo robusto FechaYHora (incluye AM/PM "a. m." "p. m.")
parse_dt <- function(x, tz = CFG$TZ) {
  x <- stringr::str_trim(x)
  x <- stringr::str_replace_all(x, fixed("a. m."), "AM")
  x <- stringr::str_replace_all(x, fixed("p. m."), "PM")
  x <- stringr::str_replace_all(x, fixed("a.m."), "AM")
  x <- stringr::str_replace_all(x, fixed("p.m."), "PM")
  x <- stringr::str_replace_all(x, fixed(" am"), " AM")
  x <- stringr::str_replace_all(x, fixed(" pm"), " PM")

  y <- suppressWarnings(lubridate::ymd_hms(x, tz = tz))
  if (all(is.na(y))) y <- suppressWarnings(lubridate::ymd_hm(x, tz = tz))
  if (all(is.na(y))) y <- suppressWarnings(lubridate::dmy_hms(x, tz = tz))
  if (all(is.na(y))) y <- suppressWarnings(lubridate::dmy_hm(x, tz = tz))
  if (all(is.na(y))) y <- suppressWarnings(lubridate::mdy_hms(x, tz = tz))
  if (all(is.na(y))) y <- suppressWarnings(lubridate::mdy_hm(x, tz = tz))
  y
}

# Resolución temporal robusta (mediana de diffs > 0)
infer_step_minutes <- function(d) {
  d <- d[order(FechaYHora)]
  if (nrow(d) < 10) return(NA_real_)
  mins <- as.numeric(diff(d$FechaYHora), units = "mins")
  mins <- mins[is.finite(mins) & mins > 0]
  if (length(mins) < 10) return(NA_real_)
  step <- median(mins)

  if (!is.finite(step) || step <= 0) return(NA_real_)
  if (step < CFG$STEP_MIN_MIN) step <- CFG$STEP_MIN_MIN
  if (step > CFG$STEP_MIN_MAX) step <- CFG$STEP_FALLBACK
  round(step, 0)
}

# Resample regular con BLINDAJE anti 950 GB
resample_regular <- function(d, step_min, fallback_min = CFG$STEP_FALLBACK, MAX_GRID = CFG$MAX_GRID) {
  d <- d[order(FechaYHora)]
  if (nrow(d) < 2) return(NULL)
  if (!is.finite(step_min) || step_min <= 0) step_min <- fallback_min
  if (step_min < 1) step_min <- 1

  start <- min(d$FechaYHora, na.rm = TRUE)
  end   <- max(d$FechaYHora, na.rm = TRUE)
  if (!is.finite(start) || !is.finite(end) || end <= start) return(NULL)

  span_min <- as.numeric(difftime(end, start, units = "mins"))
  n_grid <- floor(span_min / step_min) + 1
  if (!is.finite(n_grid) || n_grid < 10) return(NULL)

  # si excede el máximo, sube step_min automáticamente
  if (n_grid > MAX_GRID) {
    step_min <- ceiling(span_min / (MAX_GRID - 1))
    if (step_min < 1) step_min <- 1
    n_grid <- floor(span_min / step_min) + 1
  }

  grid <- data.table(FechaYHora = seq(from = start, to = end,
                                      by = as.difftime(step_min, units = "mins")))
  out <- merge(grid, d, by = "FechaYHora", all.x = TRUE)
  out[, v := zoo::na.approx(v, na.rm = FALSE)]
  out
}

# Ventana final (últimos WINDOW_DAYS) para spectral/memoria/wavelet
apply_window <- function(d, days = CFG$WINDOW_DAYS) {
  if (nrow(d) < 2) return(d)
  end_t <- max(d$FechaYHora, na.rm = TRUE)
  start_t <- end_t - lubridate::days(days)
  d[FechaYHora >= start_t & FechaYHora <= end_t]
}

# Rayleigh helpers
drayleigh <- function(x, sigma) ifelse(x < 0, 0, (x/(sigma^2)) * exp(-(x^2)/(2*sigma^2)))
prayleigh <- function(x, sigma) ifelse(x < 0, 0, 1 - exp(-(x^2)/(2*sigma^2)))
qrayleigh <- function(p, sigma) sigma * sqrt(-2*log(1 - p))

# Weibull + Rayleigh por zona (MLE)
fit_models_zone <- function(x) {
  x <- x[is.finite(x)]
  x_pos <- x[x > 0]
  prop_zero <- mean(x == 0)

  if (length(x_pos) < 80) return(list(ok = FALSE, prop_zero = prop_zero))

  fitW <- fitdistrplus::fitdist(x_pos, "weibull", method = "mle")
  k <- unname(fitW$estimate["shape"])
  c <- unname(fitW$estimate["scale"])
  se_k <- unname(fitW$sd["shape"])
  se_c <- unname(fitW$sd["scale"])

  sigma <- sqrt(mean(x_pos^2) / 2)

  llW <- sum(dweibull(x_pos, shape = k, scale = c, log = TRUE))
  llR <- sum(log(drayleigh(x_pos, sigma = sigma)))

  aicW <- 2*2 - 2*llW
  bicW <- log(length(x_pos))*2 - 2*llW
  aicR <- 2*1 - 2*llR
  bicR <- log(length(x_pos))*1 - 2*llR

  xs <- if (length(x_pos) > 5000) sample(x_pos, 5000) else x_pos
  ksW <- suppressWarnings(ks.test(xs, "pweibull", shape = k, scale = c))
  ksR <- suppressWarnings(ks.test(xs, prayleigh, sigma = sigma))

  Ev3_W <- c^3 * gamma(1 + 3/k)
  Ev3_R <- sigma^3 * (2^(3/2)) * gamma(2.5)

  list(
    ok = TRUE, prop_zero = prop_zero,
    k_shape = k, c_scale = c, se_k = se_k, se_c = se_c,
    sigma = sigma,
    AIC_W = aicW, BIC_W = bicW, KS_W = unname(ksW$statistic), KS_p_W = unname(ksW$p.value),
    AIC_R = aicR, BIC_R = bicR, KS_R = unname(ksR$statistic), KS_p_R = unname(ksR$p.value),
    Ev3_W = Ev3_W, Ev3_R = Ev3_R
  )
}

# QQ/PP para ambos modelos
make_qq_pp_models <- function(x, k, c, sigma, zona) {
  x_pos <- x[is.finite(x) & x > 0]
  if (length(x_pos) > 8000) x_pos <- sample(x_pos, 8000)
  x_pos <- sort(x_pos)
  p_emp <- ppoints(length(x_pos))

  qW <- qweibull(p_emp, shape = k, scale = c)
  pW <- pweibull(x_pos, shape = k, scale = c)
  qR <- qrayleigh(p_emp, sigma = sigma)
  pR <- prayleigh(x_pos, sigma = sigma)

  df_qqW <- data.frame(q_theo = qW, q_emp = x_pos)
  df_ppW <- data.frame(p_theo = pW, p_emp = p_emp)
  df_qqR <- data.frame(q_theo = qR, q_emp = x_pos)
  df_ppR <- data.frame(p_theo = pR, p_emp = p_emp)

  p1 <- ggplot(df_qqW, aes(q_theo, q_emp)) +
    geom_point(alpha = 0.35, size = 1, color = pal_zona[as.character(zona)]) +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    labs(title = paste0("Q-Q Weibull (Zona ", zona, ")"),
         x = "Cuantiles teóricos", y = "Cuantiles empíricos") +
    nature_theme

  p2 <- ggplot(df_ppW, aes(p_theo, p_emp)) +
    geom_point(alpha = 0.35, size = 1, color = pal_zona[as.character(zona)]) +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    labs(title = paste0("P-P Weibull (Zona ", zona, ")"),
         x = "Prob. teórica", y = "Prob. empírica") +
    nature_theme

  p3 <- ggplot(df_qqR, aes(q_theo, q_emp)) +
    geom_point(alpha = 0.35, size = 1, color = "black") +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    labs(title = paste0("Q-Q Rayleigh (Zona ", zona, ")"),
         x = "Cuantiles teóricos", y = "Cuantiles empíricos") +
    nature_theme

  p4 <- ggplot(df_ppR, aes(p_theo, p_emp)) +
    geom_point(alpha = 0.35, size = 1, color = "black") +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    labs(title = paste0("P-P Rayleigh (Zona ", zona, ")"),
         x = "Prob. teórica", y = "Prob. empírica") +
    nature_theme

  list(qqW = p1, ppW = p2, qqR = p3, ppR = p4)
}

# FFT plot
fft_zone_plot <- function(v, zona, dt_min) {
  v <- v[is.finite(v)]
  if (length(v) < 512) return(NULL)

  v <- v - mean(v)
  n <- length(v)

  fs_cpm <- 1 / dt_min # ciclos/min
  spec <- abs(fft(v))^2 / n
  freq <- (0:(n-1)) * (fs_cpm / n)

  half <- 1:floor(n/2)
  df <- data.frame(freq_cpm = freq[half], power = spec[half])
  df <- df[df$freq_cpm > 0, ]
  df$freq_cph <- df$freq_cpm * 60 # ciclos/h

  nyq_cph <- 0.5 * (60 / dt_min)
  df <- df[df$freq_cph <= min(nyq_cph, 12), ]

  ggplot(df, aes(x = freq_cph, y = power)) +
    geom_line(linewidth = 0.95, color = pal_zona[as.character(zona)]) +
    scale_y_log10(labels = scales::label_number()) +
    scale_x_continuous(expand = expansion(mult = c(0.01, 0.03))) +
    labs(title = paste0("Espectro de potencia (FFT) - Zona ", zona),
         x = "Frecuencia (1/h)", y = "Potencia espectral (log10)") +
    nature_theme
}

# ACF/PACF plot
acf_pacf_plot <- function(v, zona, dt_min, max_lag_h = CFG$MAX_LAG_H) {
  v <- v[is.finite(v)]
  if (length(v) < 600) return(NULL)

  max_lag <- as.integer((max_lag_h * 60) / dt_min)
  if (!is.finite(max_lag) || max_lag < 10) return(NULL)

  ac <- acf(v, plot = FALSE, lag.max = max_lag)
  pc <- pacf(v, plot = FALSE, lag.max = max_lag)

  lag_h_ac <- as.numeric(ac$lag[-1]) * (dt_min/60)
  df_ac <- data.frame(lag_h = lag_h_ac, acf = ac$acf[-1])

  lag_h_pc <- as.numeric(pc$lag) * (dt_min/60)
  df_pc <- data.frame(lag_h = lag_h_pc, pacf = pc$acf)

  col_use <- pal_zona[as.character(zona)]

  p1 <- ggplot(df_ac, aes(x = lag_h, y = acf)) +
    geom_hline(yintercept = 0, linewidth = 0.45, color = "grey35") +
    geom_segment(aes(xend = lag_h, yend = 0), linewidth = 0.95, color = col_use) +
    scale_x_continuous(expand = expansion(mult = c(0.01, 0.03))) +
    labs(title = paste0("ACF - Zona ", zona),
         x = "Rezago (horas)", y = "ACF") +
    nature_theme

  p2 <- ggplot(df_pc, aes(x = lag_h, y = pacf)) +
    geom_hline(yintercept = 0, linewidth = 0.45, color = "grey35") +
    geom_segment(aes(xend = lag_h, yend = 0), linewidth = 0.95, color = col_use) +
    scale_x_continuous(expand = expansion(mult = c(0.01, 0.03))) +
    labs(title = paste0("PACF - Zona ", zona),
         x = "Rezago (horas)", y = "PACF") +
    nature_theme

  list(acf = p1, pacf = p2)
}

# Wavelet: letras grandes + NO recortes (colorbar)
wavelet_save <- function(v, dt_min, zona, out_png, MAX_N = CFG$WAVELET_MAX_N) {
  v <- v[is.finite(v)]
  if (length(v) < 512) return(FALSE)

  x <- as.numeric(scale(v))

  n <- length(x)
  if (n > MAX_N) {
    stride <- ceiling(n / MAX_N)
    x <- x[seq(1, n, by = stride)]
  }
  n <- length(x)

  dt_sec <- dt_min * 60
  t <- (0:(n - 1)) * dt_sec
  mat <- cbind(t, x)

  wt_obj <- biwavelet::wt(mat, dj = CFG$WAVELET_DJ, s0 = 2 * dt_sec, J1 = NULL, mother = "morlet")

  png(out_png, width = 3600, height = 1900, res = 320)
  op <- par(no.readonly = TRUE)
  par(
    mar = c(7.2, 9.0, 5.0, 16.5),
    mgp = c(3.6, 1.2, 0),
    xpd = NA,
    cex.main = 1.55,
    cex.lab  = 1.45,
    cex.axis = 1.35
  )
  plot(wt_obj, main = paste0("Wavelet (Morlet) - Zona ", zona), plot.cb = TRUE)
  par(op)
  dev.off()
  TRUE
}

# ---------------------------
# 5) LECTURA + NORMALIZACIÓN
# ---------------------------
message("Leyendo datos: ", data_path)

dt <- tryCatch(
  fread(data_path, sep = "\t", encoding = "UTF-8"),
  error = function(e) fread(data_path, sep = ",", encoding = "UTF-8")
)

setnames(dt, old = names(dt), new = str_trim(names(dt)))
req_cols <- c("Estación","FechaYHora","Valor","Zona","Variable")
stopifnot(all(req_cols %in% names(dt)))

dt[, Zona := as.integer(Zona)]
dt[, Valor := as.numeric(Valor)]
dt[, Variable := as.character(Variable)]
dt[, Estación := as.character(Estación)]
dt[, FechaYHora := parse_dt(FechaYHora, tz = CFG$TZ)]
stopifnot(!all(is.na(dt$FechaYHora)))

# ---------------------------
# 6) QC GLOBAL (ANEXOS) A1/A2/A3
# ---------------------------
A1 <- dt[, .(n = .N), by = .(Variable)][order(-n)]
fwrite(A1, file.path(dir_tables, "A1_Conteo_Registros_por_Variable.csv"))

A2 <- dt[, .(
  n = .N,
  n_NA  = sum(is.na(Valor)),
  n_inf = sum(!is.finite(Valor), na.rm = TRUE),
  n_neg = sum(Valor < 0, na.rm = TRUE)
), by = .(Variable)][order(Variable)]
fwrite(A2, file.path(dir_tables, "A2_QC_NA_y_Negativos_por_Variable.csv"))

calc_resolution <- function(d) {
  d <- d[order(FechaYHora)]
  if (nrow(d) < 3) return(NA_real_)
  dd <- diff(d$FechaYHora)
  as.numeric(median(dd, na.rm = TRUE), units = "mins")
}
A3 <- dt[!is.na(FechaYHora), .(
  delta_min_mediana = calc_resolution(.SD),
  n = .N
), by = .(Zona, Estación, Variable)]
fwrite(A3, file.path(dir_tables, "A3_Resolucion_Temporal_por_Zona_Estacion.csv"))

# ---------------------------
# 7) VV + TRAZABILIDAD LIMPIEZA
# ---------------------------
dt_vv0 <- dt[Variable == CFG$TARGET_VAR]

trace <- data.table(
  paso = c("Inicial VV", "Quitar NA/Inf", "Quitar negativos (v<0)"),
  n = NA_integer_
)
trace[paso=="Inicial VV", n := nrow(dt_vv0)]

dt_vv <- dt_vv0[!is.na(Valor) & is.finite(Valor) & !is.na(FechaYHora)]
trace[paso=="Quitar NA/Inf", n := nrow(dt_vv)]

dt_vv <- dt_vv[Valor >= CFG$MIN_V]
trace[paso=="Quitar negativos (v<0)", n := nrow(dt_vv)]

setorder(dt_vv, Zona, Estación, FechaYHora)
fwrite(trace, file.path(dir_tables, "VV_Trazabilidad_Limpieza.csv"))

message("Registros VV (post-limpieza): ", format(nrow(dt_vv), big.mark = "."))

# ---------------------------
# 8) DESCRIPTIVOS POR ZONA
# ---------------------------
desc_zone <- dt_vv[, .(
  n = .N,
  mean = mean(Valor),
  sd = sd(Valor),
  min = min(Valor),
  p05 = as.numeric(quantile(Valor, 0.05)),
  p25 = as.numeric(quantile(Valor, 0.25)),
  median = median(Valor),
  p75 = as.numeric(quantile(Valor, 0.75)),
  p95 = as.numeric(quantile(Valor, 0.95)),
  max = max(Valor),
  skew = moments::skewness(Valor),
  kurt = moments::kurtosis(Valor)
), by = .(Zona)][order(Zona)]
fwrite(desc_zone, file.path(dir_tables, "VV_Descriptivos_por_Zona.csv"))

# Boxplot (Principal)
p_box <- ggplot(dt_vv, aes(x = factor(Zona), y = Valor, color = factor(Zona))) +
  geom_boxplot(width = 0.55, outlier.alpha = 0.10, linewidth = 0.7) +
  scale_color_manual(values = pal_zona, guide = "none") +
  labs(title = "Velocidad del Viento (VV) por zona",
       x = "Zona", y = "v (m/s)") +
  nature_theme
save_fig(p_box, file.path(dir_main_fig, "VV_Boxplot_por_Zona.png"))

# Hist densidad (Anexos)
p_hist <- ggplot(dt_vv, aes(x = Valor, fill = factor(Zona))) +
  geom_histogram(aes(y = after_stat(density)), bins = 60, alpha = 0.82,
                 color = "white", linewidth = 0.25) +
  facet_wrap(~Zona, ncol = 2, scales = "free_y") +
  scale_fill_manual(values = pal_zona, guide = "none") +
  labs(title = "Distribución de VV por zona (densidad)",
       x = "v (m/s)", y = "Densidad") +
  nature_theme
save_fig(p_hist, file.path(dir_ann_fig, "VV_Hist_por_Zona.png"), w = 8.0, h = 6.4)

# ---------------------------
# 9) WEIBULL vs RAYLEIGH (MLE) + TABLA
# ---------------------------
fits <- dt_vv[, .(fit = list(fit_models_zone(Valor))), by = .(Zona)]
tab_fit <- fits[, {
  f <- fit[[1]]
  if (!isTRUE(f$ok)) {
    .(prop_zero=f$prop_zero,
      k_shape=NA_real_, c_scale=NA_real_, se_k=NA_real_, se_c=NA_real_,
      sigma=NA_real_,
      AIC_W=NA_real_, BIC_W=NA_real_, KS_W=NA_real_, KS_p_W=NA_real_,
      AIC_R=NA_real_, BIC_R=NA_real_, KS_R=NA_real_, KS_p_R=NA_real_,
      Ev3_W=NA_real_, Ev3_R=NA_real_)
  } else {
    .(prop_zero=f$prop_zero,
      k_shape=f$k_shape, c_scale=f$c_scale, se_k=f$se_k, se_c=f$se_c,
      sigma=f$sigma,
      AIC_W=f$AIC_W, BIC_W=f$BIC_W, KS_W=f$KS_W, KS_p_W=f$KS_p_W,
      AIC_R=f$AIC_R, BIC_R=f$BIC_R, KS_R=f$KS_R, KS_p_R=f$KS_p_R,
      Ev3_W=f$Ev3_W, Ev3_R=f$Ev3_R)
  }
}, by = Zona][order(Zona)]
fwrite(tab_fit, file.path(dir_tables, "VV_Weibull_vs_Rayleigh_por_Zona.csv"))

# Parámetros Weibull (Principal): k y c
p_k <- ggplot(tab_fit, aes(x = factor(Zona), y = k_shape, color = factor(Zona))) +
  geom_point(size = 3.3) +
  geom_line(aes(group = 1), linewidth = 0.75, color = "grey40") +
  scale_color_manual(values = pal_zona, guide = "none") +
  labs(title = "Weibull: parámetro de forma k por zona",
       x = "Zona", y = "k (forma)") +
  nature_theme
save_fig(p_k, file.path(dir_main_fig, "Weibull_k_por_Zona.png"))

p_c <- ggplot(tab_fit, aes(x = factor(Zona), y = c_scale, color = factor(Zona))) +
  geom_point(size = 3.3) +
  geom_line(aes(group = 1), linewidth = 0.75, color = "grey40") +
  scale_color_manual(values = pal_zona, guide = "none") +
  labs(title = "Weibull: parámetro de escala c por zona",
       x = "Zona", y = "c (m/s)") +
  nature_theme
save_fig(p_c, file.path(dir_main_fig, "Weibull_c_por_Zona.png"))

# ---------------------------
# 9.1) PDF/CDF Weibull vs Rayleigh (ANEXOS + PRINCIPAL zona rep provisional)
# ---------------------------
# zona rep provisional por varianza de observaciones (rápido)
var_fast <- dt_vv[, .(var = var(Valor, na.rm = TRUE)), by = Zona][order(-var)]
zona_rep_prov <- var_fast$Zona[1]

for (z in tab_fit$Zona) {
  rowz <- tab_fit[Zona == z]
  if (is.na(rowz$k_shape) || is.na(rowz$c_scale) || is.na(rowz$sigma)) next

  x <- dt_vv[Zona == z & Valor > 0]$Valor
  if (length(x) < 200) next

  df_plot <- data.frame(v = x)
  k <- rowz$k_shape; c <- rowz$c_scale; sg <- rowz$sigma

  p_pdf <- ggplot(df_plot, aes(x = v)) +
    geom_histogram(aes(y = after_stat(density)), bins = 60,
                   fill = "grey90", color = "white", linewidth = 0.25) +
    stat_function(fun = dweibull, args = list(shape = k, scale = c),
                  linewidth = 1.35, color = pal_zona[as.character(z)]) +
    stat_function(fun = drayleigh, args = list(sigma = sg),
                  linewidth = 1.15, color = "black", linetype = 2) +
    labs(title = paste0("PDF: Weibull vs Rayleigh (Zona ", z, ")"),
         x = "v (m/s)", y = "Densidad") +
    nature_theme
  save_fig(p_pdf, file.path(dir_ann_fig, paste0("PDF_Weibull_vs_Rayleigh_Zona", z, ".png")))

  p_cdf <- ggplot(df_plot, aes(x = v)) +
    stat_ecdf(geom = "step", linewidth = 0.9, color = "grey30", alpha = 0.9) +
    stat_function(fun = pweibull, args = list(shape = k, scale = c),
                  linewidth = 1.35, color = pal_zona[as.character(z)]) +
    stat_function(fun = prayleigh, args = list(sigma = sg),
                  linewidth = 1.15, color = "black", linetype = 2) +
    labs(title = paste0("CDF: Weibull vs Rayleigh (Zona ", z, ")"),
         x = "v (m/s)", y = "F(v)") +
    nature_theme
  save_fig(p_cdf, file.path(dir_ann_fig, paste0("CDF_Weibull_vs_Rayleigh_Zona", z, ".png")))

  if (z == zona_rep_prov) {
    save_fig(p_pdf, file.path(dir_main_fig, paste0("PDF_Weibull_vs_Rayleigh_ZonaRep_Z", z, ".png")))
    save_fig(p_cdf, file.path(dir_main_fig, paste0("CDF_Weibull_vs_Rayleigh_ZonaRep_Z", z, ".png")))
  }
}

# ---------------------------
# 9.2) Q-Q / P-P Weibull y Rayleigh (ANEXOS)
# ---------------------------
for (z in tab_fit$Zona) {
  rowz <- tab_fit[Zona == z]
  if (is.na(rowz$k_shape) || is.na(rowz$c_scale) || is.na(rowz$sigma)) next
  plots <- make_qq_pp_models(dt_vv[Zona == z]$Valor, rowz$k_shape, rowz$c_scale, rowz$sigma, z)
  save_fig(plots$qqW, file.path(dir_ann_fig, paste0("Weibull_QQ_Zona", z, ".png")))
  save_fig(plots$ppW, file.path(dir_ann_fig, paste0("Weibull_PP_Zona", z, ".png")))
  save_fig(plots$qqR, file.path(dir_ann_fig, paste0("Rayleigh_QQ_Zona", z, ".png")))
  save_fig(plots$ppR, file.path(dir_ann_fig, paste0("Rayleigh_PP_Zona", z, ".png")))
}

# ---------------------------
# 10) SEÑAL ZONAL (ENSAMBLE POR TIMESTAMP) + ZONA REPRESENTATIVA
# ---------------------------
# IMPORTANTE: En una zona hay muchos valores para la misma variable (múltiples estaciones).
# Aquí definimos "señal zonal" como promedio del ensamble por timestamp.
dt_zone <- dt_vv[
  !is.na(FechaYHora) & is.finite(Valor),
  .(v = mean(Valor, na.rm = TRUE),
    n_obs = .N,
    sd_obs = sd(Valor, na.rm = TRUE)),
  by = .(Zona, FechaYHora)
]
setorder(dt_zone, Zona, FechaYHora)

# seguridad anti-duplicado por zona-tiempo
dt_zone <- dt_zone[, .(
  v = mean(v, na.rm = TRUE),
  n_obs = sum(n_obs),
  sd_obs = mean(sd_obs, na.rm = TRUE)
), by = .(Zona, FechaYHora)]
setorder(dt_zone, Zona, FechaYHora)
stopifnot(all(dt_zone[, .N, by = .(Zona, FechaYHora)]$N == 1))

# zona representativa definitiva: mayor varianza de la señal zonal
var_zone <- dt_zone[, .(var = var(v, na.rm = TRUE)), by = Zona][order(-var)]
zona_rep <- var_zone$Zona[1]
message("Zona representativa (varianza señal zonal): ", zona_rep)

# ---------------------------
# 11) FFT (ANEXOS) + FFT ZONA REP (PRINCIPAL)
# ---------------------------
for (z in sort(unique(dt_zone$Zona))) {
  d <- dt_zone[Zona == z, .(FechaYHora, v)]
  d <- apply_window(d, days = CFG$WINDOW_DAYS)  # ventana defendible
  step_min <- infer_step_minutes(d)
  d_rs <- resample_regular(d, step_min, MAX_GRID = CFG$MAX_GRID)
  if (is.null(d_rs) || nrow(d_rs) < 600) next

  p_fft <- fft_zone_plot(d_rs$v, z, dt_min = step_min)
  if (is.null(p_fft)) next

  save_fig(p_fft, file.path(dir_ann_fig, paste0("FFT_Zona", z, ".png")), dpi = 560)

  if (z == zona_rep) {
    save_fig(p_fft, file.path(dir_main_fig, paste0("FFT_ZonaRepresentativa_Z", z, ".png")), dpi = 560)
  }
}

# ---------------------------
# 12) WAVELET (ANEXOS) + WAVELET ZONA REP (PRINCIPAL)
# ---------------------------
for (z in sort(unique(dt_zone$Zona))) {
  d <- dt_zone[Zona == z, .(FechaYHora, v)]
  d <- apply_window(d, days = CFG$WINDOW_DAYS)
  step_min <- infer_step_minutes(d)
  d_rs <- resample_regular(d, step_min, MAX_GRID = CFG$MAX_GRID)
  if (is.null(d_rs) || nrow(d_rs) < 600) next

  out_ann <- file.path(dir_ann_fig, paste0("Wavelet_Zona", z, ".png"))
  ok <- wavelet_save(d_rs$v, dt_min = step_min, zona = z, out_png = out_ann)
  if (!isTRUE(ok)) next

  if (z == zona_rep) {
    file.copy(out_ann, file.path(dir_main_fig, paste0("Wavelet_ZonaRepresentativa_Z", z, ".png")), overwrite = TRUE)
  }
}

# ---------------------------
# 13) ACF / PACF (ANEXOS) + REP (PRINCIPAL)
# ---------------------------
for (z in sort(unique(dt_zone$Zona))) {
  d <- dt_zone[Zona == z, .(FechaYHora, v)]
  d <- apply_window(d, days = CFG$WINDOW_DAYS)
  step_min <- infer_step_minutes(d)
  d_rs <- resample_regular(d, step_min, MAX_GRID = CFG$MAX_GRID)
  if (is.null(d_rs) || nrow(d_rs) < 600) next

  pp <- acf_pacf_plot(d_rs$v, zona = z, dt_min = step_min, max_lag_h = CFG$MAX_LAG_H)
  if (is.null(pp)) next

  save_fig(pp$acf,  file.path(dir_ann_fig, paste0("ACF_Zona", z, ".png")),  dpi = 560)
  save_fig(pp$pacf, file.path(dir_ann_fig, paste0("PACF_Zona", z, ".png")), dpi = 560)

  if (z == zona_rep) {
    save_fig(pp$acf,  file.path(dir_main_fig, paste0("ACF_ZonaRepresentativa_Z", z, ".png")),  dpi = 560)
    save_fig(pp$pacf, file.path(dir_main_fig, paste0("PACF_ZonaRepresentativa_Z", z, ".png")), dpi = 560)
  }
}

# ---------------------------
# 14) TABLA MAESTRA FINAL
# ---------------------------
tab_master <- merge(
  desc_zone,
  tab_fit[, .(Zona, prop_zero, k_shape, c_scale, se_k, se_c, sigma,
              AIC_W, BIC_W, KS_W, KS_p_W,
              AIC_R, BIC_R, KS_R, KS_p_R,
              Ev3_W, Ev3_R)],
  by = "Zona", all.x = TRUE
)
fwrite(tab_master, file.path(dir_tables, "VV_Tabla_Maestra_Zonas.csv"))

# ---------------------------
# 15) RESUMEN DE PARÁMETROS USADOS (DEFENDIBLE PARA ASESOR)
# ---------------------------
# Exporta por zona: ventana, step_min inferido, n_original, n_resample, y si se aplicó ajuste por MAX_GRID
param_log <- rbindlist(lapply(sort(unique(dt_zone$Zona)), function(z) {
  d <- dt_zone[Zona == z, .(FechaYHora, v)]
  d <- apply_window(d, days = CFG$WINDOW_DAYS)
  step_min <- infer_step_minutes(d)
  d_rs <- resample_regular(d, step_min, MAX_GRID = CFG$MAX_GRID)

  data.table(
    Zona = z,
    window_days = CFG$WINDOW_DAYS,
    step_min_inferido = step_min,
    n_irregular = nrow(d),
    n_resample = ifelse(is.null(d_rs), NA_integer_, nrow(d_rs)),
    MAX_GRID = CFG$MAX_GRID,
    WAVELET_MAX_N = CFG$WAVELET_MAX_N,
    MAX_LAG_H = CFG$MAX_LAG_H
  )
}), fill = TRUE)
fwrite(param_log, file.path(dir_tables, "VV_Log_Parametros_Procesamiento.csv"))

message("✅ Pipeline completado (PNG + CSV).")
message("Salidas en: ", out_dir)
message("Figuras principal: ", dir_main_fig)
message("Figuras anexos:    ", dir_ann_fig)
message("Tablas:            ", dir_tables)
message("Zona representativa (varianza señal zonal): ", zona_rep)

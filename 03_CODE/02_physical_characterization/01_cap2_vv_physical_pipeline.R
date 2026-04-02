# ============================================================
# 01_cap2_vv_physical_pipeline.R
# CAPÍTULO 2 - PIPELINE REPRODUCIBLE (VV)
# Tesis doctoral - Favio Nicolás Rosero Rodríguez
# ============================================================

rm(list = ls())
gc()

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
  library(stringr)
  library(ggplot2)
  library(scales)
  library(moments)
  library(fitdistrplus)
  library(zoo)
  library(biwavelet)
})

# ============================================================
# 1. RUTA OFICIAL UNIFICADA
# ============================================================

BASE_FILE <- "H:/Mi unidad/Academia/UNAL/DOCTORADO/Cierre Tesis/Datos.txt"
stopifnot(file.exists(BASE_FILE))

BASE_DIR <- dirname(BASE_FILE)
OUT_DIR  <- file.path(BASE_DIR, "SALIDAS_CAP2_VV")

DIR_MAIN_FIG <- file.path(OUT_DIR, "FIGURAS_PRINCIPAL")
DIR_ANN_FIG  <- file.path(OUT_DIR, "FIGURAS_ANEXOS")
DIR_TABLES   <- file.path(OUT_DIR, "TABLAS")
DIR_LOGS     <- file.path(OUT_DIR, "LOGS")

dir.create(OUT_DIR,      recursive = TRUE, showWarnings = FALSE)
dir.create(DIR_MAIN_FIG, recursive = TRUE, showWarnings = FALSE)
dir.create(DIR_ANN_FIG,  recursive = TRUE, showWarnings = FALSE)
dir.create(DIR_TABLES,   recursive = TRUE, showWarnings = FALSE)
dir.create(DIR_LOGS,     recursive = TRUE, showWarnings = FALSE)

# ============================================================
# 2. CONFIGURACIÓN
# ============================================================

CFG <- list(
  TARGET_VAR    = "VV",
  TZ            = "America/Bogota",
  MIN_V         = 0,
  STEP_MIN_MIN  = 1,
  STEP_MIN_MAX  = 180,
  STEP_FALLBACK = 60,
  MAX_GRID      = 200000,
  MAX_LAG_H     = 240,
  WINDOW_DAYS   = 365,
  WAVELET_MAX_N = 20000,
  WAVELET_DJ    = 1 / 20
)

# ============================================================
# 3. ESTILO GRÁFICO
# ============================================================

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
    plot.title = element_text(face = "bold", size = TITLE_SIZE, hjust = 0.5, margin = margin(b = 10)),
    plot.subtitle = element_text(size = SUBTITLE_SIZE, hjust = 0.5, margin = margin(b = 8)),
    axis.title = element_text(face = "bold", size = AXIS_TITLE_SIZE),
    axis.text  = element_text(size = AXIS_TEXT_SIZE, color = "black"),
    axis.line  = element_line(linewidth = 0.7, color = "black"),
    axis.ticks = element_line(linewidth = 0.7, color = "black"),
    panel.grid.major = element_line(linewidth = 0.25, color = "grey88"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = LEGEND_TITLE_SIZE),
    legend.text  = element_text(size = LEGEND_TEXT_SIZE),
    strip.text = element_text(face = "bold", size = STRIP_TEXT_SIZE),
    plot.margin = margin(18, 18, 18, 18),
    plot.background = element_rect(fill = "white", color = NA)
  )

save_fig <- function(p, path, w = 7.8, h = 5.2, dpi = 520) {
  if (requireNamespace("ragg", quietly = TRUE)) {
    ragg::agg_png(filename = path, width = w, height = h, units = "in", res = dpi, background = "white")
    print(p)
    dev.off()
  } else {
    ggsave(filename = path, plot = p, width = w, height = h, dpi = dpi,
           units = "in", bg = "white", limitsize = FALSE)
  }
}

# ============================================================
# 4. FUNCIONES AUXILIARES
# ============================================================

logi <- function(...) {
  msg <- paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "|", paste(..., collapse = " "))
  cat(msg, "\n")
  cat(msg, "\n", file = file.path(DIR_LOGS, "cap2_vv_pipeline_log.txt"), append = TRUE)
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

parse_dt <- function(x, tz = CFG$TZ) {
  x <- stringr::str_trim(as.character(x))
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

  if (n_grid > MAX_GRID) {
    step_min <- ceiling(span_min / (MAX_GRID - 1))
    if (step_min < 1) step_min <- 1
  }

  grid <- data.table(
    FechaYHora = seq(from = start, to = end, by = as.difftime(step_min, units = "mins"))
  )

  out <- merge(grid, d, by = "FechaYHora", all.x = TRUE)
  out[, v := zoo::na.approx(v, na.rm = FALSE)]
  out
}

apply_window <- function(d, days = CFG$WINDOW_DAYS) {
  if (nrow(d) < 2) return(d)
  end_t <- max(d$FechaYHora, na.rm = TRUE)
  start_t <- end_t - lubridate::days(days)
  d[FechaYHora >= start_t & FechaYHora <= end_t]
}

drayleigh <- function(x, sigma) {
  ifelse(x < 0, 0, (x/(sigma^2)) * exp(-(x^2)/(2*sigma^2)))
}

prayleigh <- function(x, sigma) {
  ifelse(x < 0, 0, 1 - exp(-(x^2)/(2*sigma^2)))
}

qrayleigh <- function(p, sigma) {
  sigma * sqrt(-2 * log(1 - p))
}

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

  aicW <- 2 * 2 - 2 * llW
  bicW <- log(length(x_pos)) * 2 - 2 * llW
  aicR <- 2 * 1 - 2 * llR
  bicR <- log(length(x_pos)) * 1 - 2 * llR

  xs <- if (length(x_pos) > 5000) sample(x_pos, 5000) else x_pos

  ksW <- suppressWarnings(ks.test(xs, "pweibull", shape = k, scale = c))
  ksR <- suppressWarnings(ks.test(xs, prayleigh, sigma = sigma))

  Ev3_W <- c^3 * gamma(1 + 3 / k)
  Ev3_R <- sigma^3 * (2^(3/2)) * gamma(2.5)

  list(
    ok = TRUE,
    prop_zero = prop_zero,
    k_shape = k,
    c_scale = c,
    se_k = se_k,
    se_c = se_c,
    sigma = sigma,
    AIC_W = aicW,
    BIC_W = bicW,
    KS_W = unname(ksW$statistic),
    KS_p_W = unname(ksW$p.value),
    AIC_R = aicR,
    BIC_R = bicR,
    KS_R = unname(ksR$statistic),
    KS_p_R = unname(ksR$p.value),
    Ev3_W = Ev3_W,
    Ev3_R = Ev3_R
  )
}

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

fft_zone_plot <- function(v, zona, dt_min) {
  v <- v[is.finite(v)]
  if (length(v) < 512) return(NULL)

  v <- v - mean(v)
  n <- length(v)

  fs_cpm <- 1 / dt_min
  spec <- abs(fft(v))^2 / n
  freq <- (0:(n - 1)) * (fs_cpm / n)

  half <- 1:floor(n / 2)
  df <- data.frame(freq_cpm = freq[half], power = spec[half])
  df <- df[df$freq_cpm > 0, ]
  df$freq_cph <- df$freq_cpm * 60

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

acf_pacf_plot <- function(v, zona, dt_min, max_lag_h = CFG$MAX_LAG_H) {
  v <- v[is.finite(v)]
  if (length(v) < 600) return(NULL)

  max_lag <- as.integer((max_lag_h * 60) / dt_min)
  if (!is.finite(max_lag) || max_lag < 10) return(NULL)

  ac <- acf(v, plot = FALSE, lag.max = max_lag)
  pc <- pacf(v, plot = FALSE, lag.max = max_lag)

  lag_h_ac <- as.numeric(ac$lag[-1]) * (dt_min / 60)
  lag_h_pc <- as.numeric(pc$lag) * (dt_min / 60)

  df_ac <- data.frame(lag_h = lag_h_ac, acf = ac$acf[-1])
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

  wt_obj <- biwavelet::wt(
    mat,
    dj = CFG$WAVELET_DJ,
    s0 = 2 * dt_sec,
    J1 = NULL,
    mother = "morlet"
  )

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

calc_resolution <- function(d) {
  d <- d[order(FechaYHora)]
  if (nrow(d) < 3) return(NA_real_)
  dd <- diff(d$FechaYHora)
  as.numeric(median(dd, na.rm = TRUE), units = "mins")
}

# ============================================================
# 5. LECTURA Y NORMALIZACIÓN
# ============================================================

logi("Leyendo datos:", BASE_FILE)

dt <- read_any_delim(BASE_FILE)

req_cols <- c("Estación", "FechaYHora", "Valor", "Zona", "Variable")
stopifnot(all(req_cols %in% names(dt)))

setnames(dt, old = names(dt), new = str_trim(names(dt)))

dt[, Zona := as.integer(Zona)]
dt[, Valor := suppressWarnings(as.numeric(gsub(",", ".", as.character(Valor))))]
dt[, Variable := as.character(Variable)]
dt[, Estación := as.character(Estación)]
dt[, FechaYHora := parse_dt(FechaYHora, tz = CFG$TZ)]

stopifnot(!all(is.na(dt$FechaYHora)))

# ============================================================
# 6. QC GLOBAL A1 / A2 / A3
# ============================================================

A1 <- dt[, .(n = .N), by = .(Variable)][order(-n)]
fwrite(A1, file.path(DIR_TABLES, "A1_Conteo_Registros_por_Variable.csv"))

A2 <- dt[, .(
  n = .N,
  n_NA  = sum(is.na(Valor)),
  n_inf = sum(!is.finite(Valor), na.rm = TRUE),
  n_neg = sum(Valor < 0, na.rm = TRUE)
), by = .(Variable)][order(Variable)]
fwrite(A2, file.path(DIR_TABLES, "A2_QC_NA_y_Negativos_por_Variable.csv"))

A3 <- dt[!is.na(FechaYHora), .(
  delta_min_mediana = calc_resolution(.SD),
  n = .N
), by = .(Zona, Estación, Variable)]
fwrite(A3, file.path(DIR_TABLES, "A3_Resolucion_Temporal_por_Zona_Estacion_Variable.csv"))

# ============================================================
# 7. VV + TRAZABILIDAD DE LIMPIEZA
# ============================================================

dt_vv0 <- dt[Variable == CFG$TARGET_VAR]

trace <- data.table(
  paso = c("Inicial VV", "Quitar NA/Inf", "Quitar negativos (v<0)"),
  n = NA_integer_
)

trace[paso == "Inicial VV", n := nrow(dt_vv0)]

dt_vv <- dt_vv0[!is.na(Valor) & is.finite(Valor) & !is.na(FechaYHora)]
trace[paso == "Quitar NA/Inf", n := nrow(dt_vv)]

dt_vv <- dt_vv[Valor >= CFG$MIN_V]
trace[paso == "Quitar negativos (v<0)", n := nrow(dt_vv)]

setorder(dt_vv, Zona, Estación, FechaYHora)
fwrite(trace, file.path(DIR_TABLES, "VV_Trazabilidad_Limpieza.csv"))

logi("Registros VV post-limpieza:", format(nrow(dt_vv), big.mark = "."))

# ============================================================
# 8. DESCRIPTIVOS POR ZONA
# ============================================================

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

fwrite(desc_zone, file.path(DIR_TABLES, "VV_Descriptivos_por_Zona.csv"))

p_box <- ggplot(dt_vv, aes(x = factor(Zona), y = Valor, color = factor(Zona))) +
  geom_boxplot(width = 0.55, outlier.alpha = 0.10, linewidth = 0.7) +
  scale_color_manual(values = pal_zona, guide = "none") +
  labs(title = "Velocidad del Viento (VV) por zona", x = "Zona", y = "v (m/s)") +
  nature_theme
save_fig(p_box, file.path(DIR_MAIN_FIG, "VV_Boxplot_por_Zona.png"))

p_hist <- ggplot(dt_vv, aes(x = Valor, fill = factor(Zona))) +
  geom_histogram(bins = 55, alpha = 0.55, position = "identity") +
  facet_wrap(~Zona, scales = "free_y", ncol = 2) +
  scale_fill_manual(values = pal_zona, guide = "none") +
  labs(title = "Distribución de VV por zona", x = "v (m/s)", y = "Frecuencia") +
  nature_theme
save_fig(p_hist, file.path(DIR_ANN_FIG, "VV_Histogramas_por_Zona.png"), w = 9.5, h = 6.8)

# ============================================================
# 9. WEIBULL VS RAYLEIGH
# ============================================================

fit_list <- lapply(sort(unique(dt_vv$Zona)), function(z) {
  x <- dt_vv[Zona == z, Valor]
  rr <- fit_models_zone(x)
  if (!isTRUE(rr$ok)) {
    return(data.table(Zona = z, ok = FALSE, prop_zero = rr$prop_zero))
  }
  data.table(
    Zona = z,
    ok = TRUE,
    prop_zero = rr$prop_zero,
    k_shape = rr$k_shape,
    c_scale = rr$c_scale,
    se_k = rr$se_k,
    se_c = rr$se_c,
    sigma = rr$sigma,
    AIC_W = rr$AIC_W,
    BIC_W = rr$BIC_W,
    KS_W = rr$KS_W,
    KS_p_W = rr$KS_p_W,
    AIC_R = rr$AIC_R,
    BIC_R = rr$BIC_R,
    KS_R = rr$KS_R,
    KS_p_R = rr$KS_p_R,
    Ev3_W = rr$Ev3_W,
    Ev3_R = rr$Ev3_R
  )
})

tab_fit <- rbindlist(fit_list, fill = TRUE)
fwrite(tab_fit, file.path(DIR_TABLES, "VV_Weibull_Rayleigh_Ajuste.csv"))

for (z in sort(unique(dt_vv$Zona))) {
  rowz <- tab_fit[Zona == z & ok == TRUE]
  if (nrow(rowz) != 1) next

  x <- dt_vv[Zona == z & Valor > 0, Valor]
  xs <- seq(min(x, na.rm = TRUE), max(x, na.rm = TRUE), length.out = 500)

  df_pdf <- data.table(
    x = xs,
    Weibull = dweibull(xs, shape = rowz$k_shape, scale = rowz$c_scale),
    Rayleigh = drayleigh(xs, sigma = rowz$sigma)
  )
  df_pdf <- melt(df_pdf, id.vars = "x", variable.name = "Modelo", value.name = "densidad")

  p_pdf <- ggplot(df_pdf, aes(x = x, y = densidad, color = Modelo)) +
    geom_line(linewidth = 1) +
    labs(title = paste0("PDF Weibull vs Rayleigh - Zona ", z),
         x = "v (m/s)", y = "Densidad") +
    nature_theme
  save_fig(p_pdf, file.path(DIR_ANN_FIG, paste0("VV_PDF_Zona", z, ".png")))

  df_cdf <- data.table(
    x = xs,
    Weibull = pweibull(xs, shape = rowz$k_shape, scale = rowz$c_scale),
    Rayleigh = prayleigh(xs, sigma = rowz$sigma)
  )
  df_cdf <- melt(df_cdf, id.vars = "x", variable.name = "Modelo", value.name = "cdf")

  p_cdf <- ggplot(df_cdf, aes(x = x, y = cdf, color = Modelo)) +
    geom_line(linewidth = 1) +
    labs(title = paste0("CDF Weibull vs Rayleigh - Zona ", z),
         x = "v (m/s)", y = "Probabilidad acumulada") +
    nature_theme
  save_fig(p_cdf, file.path(DIR_ANN_FIG, paste0("VV_CDF_Zona", z, ".png")))

  qqpp <- make_qq_pp_models(
    x = dt_vv[Zona == z, Valor],
    k = rowz$k_shape,
    c = rowz$c_scale,
    sigma = rowz$sigma,
    zona = z
  )

  save_fig(qqpp$qqW, file.path(DIR_ANN_FIG, paste0("VV_QQ_Weibull_Zona", z, ".png")))
  save_fig(qqpp$ppW, file.path(DIR_ANN_FIG, paste0("VV_PP_Weibull_Zona", z, ".png")))
  save_fig(qqpp$qqR, file.path(DIR_ANN_FIG, paste0("VV_QQ_Rayleigh_Zona", z, ".png")))
  save_fig(qqpp$ppR, file.path(DIR_ANN_FIG, paste0("VV_PP_Rayleigh_Zona", z, ".png")))
}

# ============================================================
# 10. SEÑAL ZONAL Y ZONA REPRESENTATIVA
# ============================================================

dt_zone <- dt_vv[, .(
  v = mean(Valor, na.rm = TRUE)
), by = .(Zona, FechaYHora)]

setorder(dt_zone, Zona, FechaYHora)

zone_signal_summary <- dt_zone[, .(
  n = .N,
  mean_signal = mean(v, na.rm = TRUE),
  sd_signal = sd(v, na.rm = TRUE),
  var_signal = var(v, na.rm = TRUE),
  fecha_min = min(FechaYHora, na.rm = TRUE),
  fecha_max = max(FechaYHora, na.rm = TRUE)
), by = Zona][order(Zona)]

fwrite(zone_signal_summary, file.path(DIR_TABLES, "VV_Senal_Zonal_Resumen.csv"))

zona_rep <- zone_signal_summary[which.max(var_signal), Zona]
fwrite(data.table(Zona_Representativa = zona_rep),
       file.path(DIR_TABLES, "VV_Zona_Representativa.csv"))

# ============================================================
# 11. FFT
# ============================================================

for (z in sort(unique(dt_zone$Zona))) {
  d <- dt_zone[Zona == z, .(FechaYHora, v)]
  d <- apply_window(d, days = CFG$WINDOW_DAYS)

  step_min <- infer_step_minutes(d)
  d_rs <- resample_regular(d, step_min, MAX_GRID = CFG$MAX_GRID)
  if (is.null(d_rs) || nrow(d_rs) < 600) next

  p_fft <- fft_zone_plot(d_rs$v, zona = z, dt_min = step_min)
  if (is.null(p_fft)) next

  save_fig(p_fft, file.path(DIR_ANN_FIG, paste0("FFT_Zona", z, ".png")), dpi = 560)

  if (z == zona_rep) {
    save_fig(p_fft,
             file.path(DIR_MAIN_FIG, paste0("FFT_ZonaRepresentativa_Z", z, ".png")),
             dpi = 560)
  }
}

# ============================================================
# 12. WAVELET
# ============================================================

for (z in sort(unique(dt_zone$Zona))) {
  d <- dt_zone[Zona == z, .(FechaYHora, v)]
  d <- apply_window(d, days = CFG$WINDOW_DAYS)

  step_min <- infer_step_minutes(d)
  d_rs <- resample_regular(d, step_min, MAX_GRID = CFG$MAX_GRID)
  if (is.null(d_rs) || nrow(d_rs) < 600) next

  ok_w <- wavelet_save(
    v = d_rs$v,
    dt_min = step_min,
    zona = z,
    out_png = file.path(DIR_ANN_FIG, paste0("Wavelet_Zona", z, ".png"))
  )

  if (isTRUE(ok_w) && z == zona_rep) {
    wavelet_save(
      v = d_rs$v,
      dt_min = step_min,
      zona = z,
      out_png = file.path(DIR_MAIN_FIG, paste0("Wavelet_ZonaRepresentativa_Z", z, ".png"))
    )
  }
}

# ============================================================
# 13. ACF / PACF
# ============================================================

for (z in sort(unique(dt_zone$Zona))) {
  d <- dt_zone[Zona == z, .(FechaYHora, v)]
  d <- apply_window(d, days = CFG$WINDOW_DAYS)

  step_min <- infer_step_minutes(d)
  d_rs <- resample_regular(d, step_min, MAX_GRID = CFG$MAX_GRID)
  if (is.null(d_rs) || nrow(d_rs) < 600) next

  pp <- acf_pacf_plot(d_rs$v, zona = z, dt_min = step_min, max_lag_h = CFG$MAX_LAG_H)
  if (is.null(pp)) next

  save_fig(pp$acf,  file.path(DIR_ANN_FIG, paste0("ACF_Zona", z, ".png")),  dpi = 560)
  save_fig(pp$pacf, file.path(DIR_ANN_FIG, paste0("PACF_Zona", z, ".png")), dpi = 560)

  if (z == zona_rep) {
    save_fig(pp$acf,
             file.path(DIR_MAIN_FIG, paste0("ACF_ZonaRepresentativa_Z", z, ".png")),
             dpi = 560)
    save_fig(pp$pacf,
             file.path(DIR_MAIN_FIG, paste0("PACF_ZonaRepresentativa_Z", z, ".png")),
             dpi = 560)
  }
}

# ============================================================
# 14. TABLA MAESTRA FINAL
# ============================================================

tab_master <- merge(
  desc_zone,
  tab_fit[, .(
    Zona, prop_zero, k_shape, c_scale, se_k, se_c, sigma,
    AIC_W, BIC_W, KS_W, KS_p_W,
    AIC_R, BIC_R, KS_R, KS_p_R,
    Ev3_W, Ev3_R
  )],
  by = "Zona",
  all.x = TRUE
)

fwrite(tab_master, file.path(DIR_TABLES, "VV_Tabla_Maestra_Zonas.csv"))

# ============================================================
# 15. LOG DE PARÁMETROS DE PROCESAMIENTO
# ============================================================

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

fwrite(param_log, file.path(DIR_TABLES, "VV_Log_Parametros_Procesamiento.csv"))

# ============================================================
# 16. SESSION INFO
# ============================================================

sink(file.path(DIR_LOGS, "sessionInfo_cap2_vv.txt"))
print(sessionInfo())
sink()

# ============================================================
# 17. CIERRE
# ============================================================

logi("Pipeline CAP2 completado.")
logi("Salidas en:", OUT_DIR)
logi("Figuras principal:", DIR_MAIN_FIG)
logi("Figuras anexos:", DIR_ANN_FIG)
logi("Tablas:", DIR_TABLES)
logi("Zona representativa:", zona_rep)

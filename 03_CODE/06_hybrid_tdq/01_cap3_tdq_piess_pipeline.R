# ============================================================
# 01_cap3_tdq_piess_pipeline.R
# CAPÍTULO 3 - TDQ–PIESS HÍBRIDO (WPD + FNRR + PI90 + KFAS)
# Tesis doctoral - Favio Nicolás Rosero Rodríguez
# ============================================================

rm(list = ls())
gc()

req_pkgs <- c("data.table", "lubridate", "zoo", "KFAS", "ggplot2")
for (p in req_pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) install.packages(p, dependencies = TRUE)
}

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
  library(zoo)
  library(KFAS)
  library(ggplot2)
})

# ============================================================
# 1. RUTA OFICIAL UNIFICADA
# ============================================================

BASE_FILE <- "H:/Mi unidad/Academia/UNAL/DOCTORADO/Cierre Tesis/Datos.txt"
stopifnot(file.exists(BASE_FILE))

BASE_DIR <- dirname(BASE_FILE)

OUT_DIR <- file.path(BASE_DIR, "SALIDAS_CAP3_TDQ_PIESS")
FIG_DIR <- file.path(OUT_DIR, "FIGURAS")
TAB_DIR <- file.path(OUT_DIR, "TABLAS")
PRED_DIR <- file.path(OUT_DIR, "PREDICCIONES")
LOG_FILE <- file.path(OUT_DIR, "TDQ_PIESS_LOG.txt")

dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(TAB_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(PRED_DIR, recursive = TRUE, showWarnings = FALSE)

# ============================================================
# 2. CONFIGURACIÓN
# ============================================================

HORIZ <- data.table(
  Horizonte = c("Corto", "Medio", "Largo"),
  h = c(1L, 12L, 72L)
)

TZ_LOCAL <- "America/Bogota"
eps <- 1e-8
K   <- 48L
TRAIN_FRAC <- 0.80
PI_LEVEL <- 0.90
Z_90 <- qnorm(0.95)
GAMMA_FNRR <- 1.2

# ============================================================
# 3. UTILIDADES
# ============================================================

log_msg <- function(...) {
  msg <- paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " | ", paste(..., collapse = " "))
  cat(msg, "\n")
  cat(msg, "\n", file = LOG_FILE, append = TRUE)
}

impute_locf <- function(x) {
  x <- zoo::na.locf(x, na.rm = FALSE)
  x <- zoo::na.locf(x, fromLast = TRUE, na.rm = FALSE)
  x
}

read_any_delim <- function(path) {
  dt <- fread(path, sep = "\t", header = TRUE, data.table = TRUE, showProgress = FALSE)
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

parse_dt <- function(x) {
  x <- trimws(as.character(x))
  x <- gsub("a\\.?\\s*m\\.?", "AM", x, ignore.case = TRUE)
  x <- gsub("p\\.?\\s*m\\.?", "PM", x, ignore.case = TRUE)

  suppressWarnings(parse_date_time(
    x,
    orders = c(
      "Ymd HMS", "Ymd HM",
      "dmY HMS", "dmY HM",
      "mdY HMS", "mdY HM",
      "Y-m-d H:M:S", "Y-m-d H:M",
      "d/m/Y H:M:S", "d/m/Y H:M",
      "m/d/Y H:M:S", "m/d/Y H:M",
      "d-m-Y H:M:S", "d-m-Y H:M",
      "Ymd IMS p", "dmY IMS p", "mdY IMS p",
      "d/m/Y IMS p", "m/d/Y IMS p"
    ),
    tz = TZ_LOCAL
  ))
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

rmean <- function(v) {
  m <- mean(v, na.rm = TRUE)
  ifelse(is.finite(m), m, NA_real_)
}

rsd <- function(v) {
  s <- sd(v, na.rm = TRUE)
  ifelse(is.finite(s), s, NA_real_)
}

roll_mean <- function(x, k) zoo::rollapplyr(x, k, mean, fill = NA_real_, partial = TRUE, na.rm = TRUE)
roll_sd   <- function(x, k) zoo::rollapplyr(x, k, sd,   fill = NA_real_, partial = TRUE, na.rm = TRUE)

metrics <- function(y, yhat) {
  ok <- is.finite(y) & is.finite(yhat)
  y <- y[ok]
  yhat <- yhat[ok]
  if (length(y) < 20) return(list(RMSE = NA_real_, MAE = NA_real_, R2 = NA_real_))
  rmse <- sqrt(mean((y - yhat)^2))
  mae  <- mean(abs(y - yhat))
  r2   <- 1 - sum((y - yhat)^2) / sum((y - mean(y))^2)
  list(RMSE = rmse, MAE = mae, R2 = r2)
}

persistence_forecast <- function(y, h) data.table::shift(y, h)

fit_kfas_reg_std <- function(y, X) {
  SSModel(y ~ -1 + SSMtrend(1, Q = list(NA)) + X, H = matrix(NA))
}

fit_kfas_reg_season24 <- function(y, X) {
  SSModel(
    y ~ -1 +
      SSMtrend(1, Q = list(NA)) +
      SSMseasonal(period = 24, sea.type = "trigonometric", Q = matrix(NA)) +
      X,
    H = matrix(NA)
  )
}

alpha_by_zona <- function(z) {
  if (z == 1L) return(0.992)
  if (z == 3L) return(0.985)
  0.970
}

save_plot <- function(p, stem, w = 9, h = 5.5, dpi = 300) {
  ggsave(file.path(FIG_DIR, paste0(stem, ".png")), p, width = w, height = h, dpi = dpi)
  ggsave(file.path(FIG_DIR, paste0(stem, ".pdf")), p, width = w, height = h)
}

# ============================================================
# 4. LECTURA + AGREGACIÓN HORARIA
# ============================================================

log_msg("START TDQ–PIESS | Input:", BASE_FILE)

dt <- read_any_delim(BASE_FILE)
stopifnot(all(c("Estación", "FechaYHora", "Valor", "Zona", "Variable") %in% names(dt)))

dt[, Zona := suppressWarnings(as.integer(as.character(Zona)))]
dt[, Valor := suppressWarnings(as.numeric(gsub(",", ".", as.character(Valor))))]
dt[, Variable := vapply(Variable, norm_var, character(1))]
dt[, Fecha := parse_dt(FechaYHora)]

dt <- dt[!is.na(Zona) & !is.na(Fecha) & is.finite(Valor)]
setorder(dt, Zona, Variable, Fecha)

log_msg("OK lectura + fechas | rows:", nrow(dt), "| zonas:", paste(sort(unique(dt$Zona)), collapse = ","))

dt[, FechaHora := floor_date(Fecha, unit = "hour")]

agg_fun <- function(varname, x) {
  vn <- tolower(varname)
  if (vn %in% c("pr", "prec", "precipitacion", "precipitación")) return(sum(x, na.rm = TRUE))
  mean(x, na.rm = TRUE)
}

dt_ag <- dt[, .(Valor = agg_fun(Variable[1], Valor)), by = .(Zona, FechaHora, Variable)]
wide0 <- dcast(dt_ag, Zona + FechaHora ~ Variable, value.var = "Valor")
setorder(wide0, Zona, FechaHora)

if (!("VV" %in% names(wide0))) stop("ERROR: No se encontró la variable 'VV'.")

# ============================================================
# 5. MALLA COMPLETA + IMPUTACIÓN CONTROLADA
# ============================================================

zonas <- sort(unique(wide0$Zona))

grid <- rbindlist(lapply(zonas, function(z) {
  wz <- wide0[Zona == z]
  data.table(Zona = z, FechaHora = seq(min(wz$FechaHora), max(wz$FechaHora), by = "hour"))
}))

wide <- merge(grid, wide0, by = c("Zona", "FechaHora"), all.x = TRUE)
setorder(wide, Zona, FechaHora)

wide[, VV := {
  v <- as.numeric(VV)
  mg <- if (.BY[[1]] == 1L) 72 else 24
  v <- zoo::na.approx(v, na.rm = FALSE, maxgap = mg)
  impute_locf(v)
}, by = Zona]

wide[, `:=`(
  hour = hour(FechaHora),
  wday = wday(FechaHora),
  hour_sin = sin(2 * pi * hour / 24),
  hour_cos = cos(2 * pi * hour / 24),
  wday_sin = sin(2 * pi * wday / 7),
  wday_cos = cos(2 * pi * wday / 7)
)]

# ============================================================
# 6. BASE FÍSICA: rho + WPD
# ============================================================

R_d <- 287.05

wide[, PA_Pa := if ("PA" %in% names(wide)) to_pa(PA) else NA_real_]

temp_col <- intersect(names(wide), c("TM", "T", "TEMP", "Temperatura"))
temp_col <- if (length(temp_col) > 0) temp_col[1] else NA_character_

if (is.na(temp_col) && all(c("TMIN", "TMAX") %in% names(wide))) {
  wide[, TM_aux := (TMIN + TMAX) / 2]
  temp_col <- "TM_aux"
}

wide[, T_K := if (!is.na(temp_col)) to_kelvin(get(temp_col)) else NA_real_]

wide[, PA_Pa := if (!all(is.na(PA_Pa))) impute_locf(PA_Pa) else PA_Pa, by = Zona]
wide[, T_K   := if (!all(is.na(T_K)))   impute_locf(T_K)   else T_K,   by = Zona]

wide[, rho := {
  if (all(is.na(PA_Pa)) || all(is.na(T_K))) 1.00 else impute_locf(PA_Pa / (R_d * T_K))
}, by = Zona]

wide[, WPD := 0.5 * rho * (VV^3)]
wide <- wide[is.finite(WPD)]

log_msg("OK física base | rows usable:", nrow(wide))

# ============================================================
# 7. VARIABLES TDQ
# ============================================================

wide[, VV_mean := zoo::rollapplyr(VV, K, rmean, fill = NA_real_, partial = TRUE), by = Zona]
wide[, VV_sd   := zoo::rollapplyr(VV, K, rsd,   fill = NA_real_, partial = TRUE), by = Zona]
wide[, VV_mean := impute_locf(VV_mean), by = Zona]
wide[, VV_sd   := pmax(impute_locf(VV_sd), eps), by = Zona]

wide[, T_eff := VV_sd]
wide[, CTI := log1p(abs(WPD)) / (1 + abs(VV_sd))]

bound_vars <- intersect(names(wide), c("PA_Pa", "T_K", "HR", "PR", "NU", "EV", "DV"))

for (v in bound_vars) {
  m <- roll_mean(wide[[v]], K)
  s <- roll_sd(wide[[v]], K)
  a <- (wide[[v]] - m) / (s + eps)
  uv <- abs(a)
  uv[!is.finite(uv)] <- 0
  set(wide, j = paste0("u_", v), value = uv)
}

w <- rep(1, length(bound_vars)); names(w) <- bound_vars
if ("PA_Pa" %in% bound_vars) w["PA_Pa"] <- 1.5
if ("T_K"  %in% bound_vars)  w["T_K"]  <- 1.2
if ("PR"   %in% bound_vars)  w["PR"]   <- 1.1
if ("HR"   %in% bound_vars)  w["HR"]   <- 1.0
if ("NU"   %in% bound_vars)  w["NU"]   <- 1.0
if ("EV"   %in% bound_vars)  w["EV"]   <- 0.9
if ("DV"   %in% bound_vars)  w["DV"]   <- 0.8

wide[, U_potential := 0]
if (length(bound_vars) > 0) {
  for (v in bound_vars) {
    uv <- wide[[paste0("u_", v)]]
    uv[!is.finite(uv)] <- 0
    wide[, U_potential := U_potential + w[v] * uv]
  }
}
wide[!is.finite(U_potential), U_potential := 0]

wide[, U0 := roll_mean(U_potential, K), by = Zona]
wide[, U0 := impute_locf(U0), by = Zona]
wide[!is.finite(U0), U0 := 0]

wide[, B_barrier := pmax(0, U_potential - U0)]
wide[, C_conf := B_barrier / (T_eff + eps)]
wide[, tau_trans := exp(-C_conf)]
wide[, Z_part := 1 + exp(-C_conf)]
wide[, F_free := -(T_eff) * log(Z_part + eps)]

wide[, M_memory := {
  a <- alpha_by_zona(.BY[[1]])
  m <- rep(0, .N)
  for (i in seq_len(.N)) {
    b <- B_barrier[i]
    if (!is.finite(b)) b <- 0
    if (i == 1) m[i] <- b else m[i] <- a * m[i - 1] + (1 - a) * b
  }
  m
}, by = Zona]

wide[, U_phys := log1p(C_conf) + log1p(T_eff) + log1p(M_memory)]
wide[!is.finite(U_phys), U_phys := 0]

wide[, `:=`(
  U_med = median(U_phys, na.rm = TRUE),
  U_iqr = IQR(U_phys, na.rm = TRUE)
), by = Zona]

wide[!is.finite(U_iqr) | U_iqr <= 0, U_iqr := 1, by = Zona]
wide[, U_z := (U_phys - U_med) / (U_iqr + eps)]
wide[, FNRR := 1 / (1 + exp(-GAMMA_FNRR * U_z))]
wide[!is.finite(FNRR), FNRR := 0.5]

wide[, regime_TDQ := cut(
  FNRR,
  breaks = c(-Inf, 0.33, 0.66, Inf),
  labels = c("Orden_Alto", "Orden_Medio", "Orden_Bajo")
)]

diag_zone <- wide[, .(
  N_total = .N,
  N_WPD = sum(is.finite(WPD)),
  N_FNRR = sum(is.finite(FNRR)),
  FNRR_p10 = quantile(FNRR, 0.10, na.rm = TRUE),
  FNRR_p50 = quantile(FNRR, 0.50, na.rm = TRUE),
  FNRR_p90 = quantile(FNRR, 0.90, na.rm = TRUE)
), by = Zona]

fwrite(diag_zone, file.path(TAB_DIR, "TDQ_DIAGNOSTICO_FILAS_POR_ZONA.csv"))

wide <- wide[is.finite(WPD) & is.finite(FNRR)]
log_msg("OK features TDQ | rows modelables:", nrow(wide))

# ============================================================
# 8. MODELADO HÍBRIDO KFAS + PI90
# ============================================================

run_zone_h <- function(dfz, h, horizon_name) {
  df <- copy(dfz)

  df[, y := shift(WPD, type = "lead", n = h)]
  df <- df[is.finite(y)]
  if (nrow(df) < 2000) return(NULL)

  reg_cols <- intersect(c(
    "WPD", "VV", "rho", "VV_mean", "VV_sd", "CTI",
    "U_potential", "B_barrier", "tau_trans", "F_free", "C_conf",
    "M_memory", "FNRR", "U_phys",
    "hour_sin", "hour_cos", "wday_sin", "wday_cos"
  ), names(df))

  X <- as.matrix(df[, ..reg_cols])

  for (j in seq_len(ncol(X))) {
    col <- X[, j]
    med <- median(col, na.rm = TRUE)
    if (!is.finite(med)) med <- 0
    col[!is.finite(col)] <- med
    X[, j] <- col
  }

  keep <- apply(X, 2, function(col) sd(col, na.rm = TRUE) > 0)
  X <- X[, keep, drop = FALSE]
  X <- scale(X)

  y <- df$y
  n <- length(y)
  n_test <- max(9630, floor(0.20 * n))
  idx_te <- (n - n_test + 1):n
  idx_cal <- setdiff(seq_len(n), idx_te)

  use_seasonal <- (df$Zona[1] == 1L) || (df$Zona[1] == 3L && h == 1L)

  if (use_seasonal) {
    qy <- quantile(y, c(0.005, 0.995), na.rm = TRUE)
    y <- pmin(pmax(y, qy[1]), qy[2])

    if (ncol(X) > 0) {
      X <- apply(X, 2, function(col) {
        if (!all(is.finite(col))) col[!is.finite(col)] <- median(col, na.rm = TRUE)
        qc <- quantile(col, c(0.001, 0.999), na.rm = TRUE)
        pmin(pmax(col, qc[1]), qc[2])
      })
      X <- as.matrix(X)
      X <- scale(X)
    }
  }

  model0 <- if (use_seasonal) fit_kfas_reg_season24(y, X) else fit_kfas_reg_std(y, X)

  v0 <- var(y, na.rm = TRUE)
  if (!is.finite(v0) || v0 <= 0) v0 <- 1

  n_inits <- if (use_seasonal) 3L else 2L
  init_vec <- rep(log(v0), n_inits)
  init_vec <- pmin(pmax(init_vec, log(1e-6)), log(1e6))

  fit <- tryCatch(
    fitSSM(model0, inits = init_vec, method = "BFGS", control = list(maxit = 300)),
    error = function(e) NULL
  )

  if (is.null(fit)) {
    model_fallback <- fit_kfas_reg_std(y, X)
    fit <- fitSSM(model_fallback, inits = rep(log(v0), 2L), method = "BFGS", control = list(maxit = 300))
  }

  kfs <- KFS(fit$model, filtering = "mean", smoothing = "state")
  yhat <- as.numeric(kfs$muhat)

  y_te <- y[idx_te]
  yhat_te <- yhat[idx_te]
  y_pers <- persistence_forecast(df$WPD, h)[idx_te]

  m <- metrics(y_te, yhat_te)
  mp <- metrics(y_te, y_pers)
  skill <- if (is.finite(m$RMSE) && is.finite(mp$RMSE) && mp$RMSE > 0) 1 - (m$RMSE / mp$RMSE) else NA_real_

  resid_all <- y - yhat
  sigma_base <- sd(resid_all[idx_cal], na.rm = TRUE)
  if (!is.finite(sigma_base) || sigma_base <= 0) sigma_base <- sd(diff(df$WPD), na.rm = TRUE)
  if (!is.finite(sigma_base) || sigma_base <= 0) sigma_base <- sd(df$WPD, na.rm = TRUE)
  if (!is.finite(sigma_base) || sigma_base <= 0) sigma_base <- 1

  # PI90 antes de calibración
  PI_low_before  <- yhat_te - Z_90 * sigma_base
  PI_high_before <- yhat_te + Z_90 * sigma_base
  coverage_before <- mean(y_te >= PI_low_before & y_te <= PI_high_before, na.rm = TRUE)

  # Calibración usando la parte no-test
  calib_ratio <- abs(resid_all[idx_cal]) / (Z_90 * sigma_base + eps)
  c_PI90 <- as.numeric(quantile(calib_ratio, PI_LEVEL, na.rm = TRUE))
  if (!is.finite(c_PI90) || c_PI90 <= 0) c_PI90 <- 1

  PI_low90  <- yhat_te - c_PI90 * Z_90 * sigma_base
  PI_high90 <- yhat_te + c_PI90 * Z_90 * sigma_base
  coverage_after <- mean(y_te >= PI_low90 & y_te <= PI_high90, na.rm = TRUE)

  preds <- data.table(
    Zona = df$Zona[1],
    Horizonte = horizon_name,
    h = h,
    FechaHora = df$FechaHora[idx_te],
    y_true = y_te,
    y_pred = yhat_te,
    y_persist = y_pers,
    PI_low90_before = PI_low_before,
    PI_high90_before = PI_high_before,
    PI_low90 = PI_low90,
    PI_high90 = PI_high90,
    Coverage_before = coverage_before,
    Coverage_after = coverage_after,
    c_PI90 = c_PI90,
    FNRR = df$FNRR[idx_te],
    FNRR_mean = mean(df$FNRR[idx_te], na.rm = TRUE)
  )

  summary_row <- data.table(
    Zona = df$Zona[1],
    Horizonte = horizon_name,
    h = h,
    Skill = skill,
    R2 = m$R2,
    RMSE = m$RMSE,
    MAE = m$MAE,
    Coverage_before = coverage_before,
    Coverage_after = coverage_after,
    c_PI90 = c_PI90,
    FNRR_mean = mean(df$FNRR[idx_te], na.rm = TRUE)
  )

  list(summary = summary_row, preds = preds)
}

# ============================================================
# 9. EJECUCIÓN GLOBAL
# ============================================================

TAB_GLOBAL <- data.table()
PREDS <- data.table()

for (z in zonas) {
  log_msg("Procesando zona", z)

  dfz <- copy(wide[Zona == z])
  setorder(dfz, FechaHora)

  for (ii in seq_len(nrow(HORIZ))) {
    hz <- HORIZ$h[ii]
    hn <- HORIZ$Horizonte[ii]

    log_msg("  Horizonte:", hn, "| h =", hz)

    out <- tryCatch(
      run_zone_h(dfz, h = hz, horizon_name = hn),
      error = function(e) {
        log_msg("  ERROR:", conditionMessage(e))
        NULL
      }
    )

    if (is.null(out)) next

    TAB_GLOBAL <- rbind(TAB_GLOBAL, out$summary, fill = TRUE)
    PREDS <- rbind(PREDS, out$preds, fill = TRUE)
  }
}

# ============================================================
# 10. EXPORTACIÓN
# ============================================================

fwrite(TAB_GLOBAL, file.path(TAB_DIR, "TDQ_PIESS_TABLA_GLOBAL.csv"))
fwrite(PREDS, file.path(PRED_DIR, "TDQ_PIESS_PREDS_GLOBAL.csv"))

# ============================================================
# 11. FIGURAS
# ============================================================

p_skill <- ggplot(TAB_GLOBAL, aes(x = factor(Zona), y = Skill, fill = Horizonte)) +
  geom_col(position = "dodge") +
  labs(title = "TDQ–PIESS | Skill por zona y horizonte", x = "Zona", y = "Skill") +
  theme_minimal(base_size = 12)
save_plot(p_skill, "01_Skill")

p_r2 <- ggplot(TAB_GLOBAL, aes(x = factor(Zona), y = R2, fill = Horizonte)) +
  geom_col(position = "dodge") +
  labs(title = "TDQ–PIESS | R² por zona y horizonte", x = "Zona", y = "R²") +
  theme_minimal(base_size = 12)
save_plot(p_r2, "02_R2")

p_rmse <- ggplot(TAB_GLOBAL, aes(x = factor(Zona), y = RMSE, fill = Horizonte)) +
  geom_col(position = "dodge") +
  labs(title = "TDQ–PIESS | RMSE por zona y horizonte", x = "Zona", y = "RMSE") +
  theme_minimal(base_size = 12)
save_plot(p_rmse, "03_RMSE")

p_cov <- ggplot(TAB_GLOBAL, aes(x = factor(Zona))) +
  geom_point(aes(y = Coverage_before), size = 3) +
  geom_point(aes(y = Coverage_after), size = 3) +
  facet_wrap(~Horizonte, nrow = 1) +
  labs(title = "TDQ–PIESS | Cobertura PI90 (antes vs calibrada)", x = "Zona", y = "Coverage") +
  theme_minimal(base_size = 12)
save_plot(p_cov, "04_Coverage_PI90_before_after")

p_fnrr <- ggplot(wide, aes(x = FNRR)) +
  geom_density() +
  facet_wrap(~Zona, nrow = 2) +
  labs(title = "FNRR | Distribución por zona", x = "FNRR", y = "Densidad") +
  theme_minimal(base_size = 12)
save_plot(p_fnrr, "05_FNRR_density_by_zone")

PREDS[, Zona := factor(Zona)]
PREDS[, Horizonte := factor(Horizonte, levels = c("Corto", "Medio", "Largo"))]

plot_example <- function(hz, hn) {
  ex <- PREDS[Horizonte == hn & h == hz]
  if (nrow(ex) == 0) return(NULL)

  ex <- ex[order(Zona, FechaHora)][, tail(.SD, 800), by = Zona]

  ggplot(ex, aes(x = FechaHora)) +
    geom_ribbon(aes(ymin = PI_low90, ymax = PI_high90), alpha = 0.20) +
    geom_line(aes(y = y_true), linewidth = 0.5) +
    geom_line(aes(y = y_pred), linewidth = 0.5) +
    facet_wrap(~Zona, scales = "free_y", nrow = 2) +
    labs(title = paste0("Real vs Pred + PI90 | ", hn, " (h=", hz, ")"),
         x = "FechaHora", y = "WPD") +
    theme_minimal(base_size = 12)
}

p_ex1 <- plot_example(1, "Corto")
if (!is.null(p_ex1)) save_plot(p_ex1, "06_Example_Corto_h1")

p_ex12 <- plot_example(12, "Medio")
if (!is.null(p_ex12)) save_plot(p_ex12, "07_Example_Medio_h12")

# ============================================================
# 12. SESSION INFO
# ============================================================

sink(file.path(OUT_DIR, "sessionInfo_final.txt"))
print(sessionInfo())
sink()

log_msg("OK -> TDQ_PIESS_TABLA_GLOBAL.csv + PREDS + FIGURAS")
log_msg("END TDQ–PIESS")

cat(
  "\n\n=== TDQ–PIESS LISTO ===\n",
  "Salida: ", OUT_DIR, "\n",
  "Tabla:  TDQ_PIESS_TABLA_GLOBAL.csv\n",
  "Preds:  TDQ_PIESS_PREDS_GLOBAL.csv\n",
  "Figs:   FIGURAS/*.png y *.pdf\n",
  sep = ""
)

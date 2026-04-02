# ============================================================
# 01_cap3_classical_models.R
# CAPÍTULO 3 - MODELOS CLÁSICOS (Persistencia + ARIMA + ARIMAX)
# Tesis doctoral - Favio Nicolás Rosero Rodríguez
# ============================================================

rm(list = ls())
gc()

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
  library(forecast)
  library(ggplot2)
})

# ============================================================
# 1. RUTA OFICIAL UNIFICADA
# ============================================================

BASE_FILE <- "H:/Mi unidad/Academia/UNAL/DOCTORADO/Cierre Tesis/Datos.txt"
stopifnot(file.exists(BASE_FILE))

BASE_DIR <- dirname(BASE_FILE)

CACHE_FILE <- file.path(
  BASE_DIR, "SALIDAS_PREPROCESSING", "02_WPD_CACHE", "WPD_hourly_por_zona.csv"
)

OUT_DIR <- file.path(BASE_DIR, "SALIDAS_CAP3_CLASICOS")
DIR_DOC   <- file.path(OUT_DIR, "DOC_PRINCIPAL")
DIR_ANX   <- file.path(OUT_DIR, "ANEXOS")
DIR_PRED  <- file.path(OUT_DIR, "PRED_CACHE")
DIR_FIG_N <- file.path(DIR_DOC, "FIG_NATURE")
DIR_FIG_E <- file.path(DIR_DOC, "FIG_ELSEVIER")
DIR_FIG_A <- file.path(DIR_ANX, "FIGS")
DIR_TAB_D <- file.path(DIR_DOC, "TABLAS")
DIR_TAB_A <- file.path(DIR_ANX, "TABLAS")
LOG_FILE  <- file.path(OUT_DIR, "CAP3_CLASICOS_LOG.txt")

for (d in c(OUT_DIR, DIR_DOC, DIR_ANX, DIR_PRED, DIR_FIG_N, DIR_FIG_E, DIR_FIG_A, DIR_TAB_D, DIR_TAB_A)) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

# ============================================================
# 2. CONFIGURACIÓN
# ============================================================

TZ_LOCAL <- "America/Bogota"
HORIZONS <- c(Corto = 1L, Medio = 12L, Largo = 72L)
TRAIN_FRAC <- 0.80
SEED <- 123

MAX_POINTS <- 2500
USE_LOG1P  <- TRUE

MIN_ZONE_ROWS_CLASSIC <- 2500
MIN_CC_TR <- 800
MIN_CC_TE <- 50

set.seed(SEED)

# ============================================================
# 3. LOG
# ============================================================

logi <- function(...) {
  msg <- paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "|", paste(..., collapse = " "))
  cat(msg, "\n")
  cat(msg, "\n", file = LOG_FILE, append = TRUE)
}

# ============================================================
# 4. FUNCIONES AUXILIARES
# ============================================================

read_any_delim <- function(path) {
  dt <- tryCatch(
    fread(path, sep = "\t", header = TRUE, data.table = TRUE, showProgress = TRUE, encoding = "UTF-8"),
    error = function(e) NULL
  )

  if (is.null(dt)) {
    dt <- fread(path, header = TRUE, data.table = TRUE, showProgress = TRUE, encoding = "UTF-8")
  }

  dt
}

rmse <- function(e) sqrt(mean(e^2, na.rm = TRUE))
mae  <- function(e) mean(abs(e), na.rm = TRUE)

r2_score <- function(y, yhat) {
  ok <- is.finite(y) & is.finite(yhat)
  if (sum(ok) < 10) return(NA_real_)

  y <- y[ok]
  yhat <- yhat[ok]

  sse <- sum((y - yhat)^2)
  sst <- sum((y - mean(y))^2)

  if (!is.finite(sst) || sst <= 0) return(NA_real_)

  r2 <- 1 - sse / sst
  if (!is.finite(r2)) return(NA_real_)

  min(r2, 1.0)
}

skill <- function(rmse_model, rmse_persist) {
  if (!is.finite(rmse_model) || !is.finite(rmse_persist) || rmse_persist <= 0) return(NA_real_)
  1 - rmse_model / rmse_persist
}

calc_Eh <- function(x, h) {
  if (length(x) < h) return(rep(NA_real_, length(x)))
  as.numeric(stats::filter(x, rep(1, h), sides = 1))
}

eval_h <- function(y_test, yhat_full, h) {
  n <- length(y_test)
  if (n <= h + 30) return(NULL)

  y_true <- y_test[(h + 1):n]
  y_pers <- y_test[1:(n - h)]
  y_hat  <- yhat_full[(h + 1):n]

  okm <- is.finite(y_true) & is.finite(y_hat)

  Eh_true <- calc_Eh(y_true, h)
  Eh_pers <- calc_Eh(y_pers, h)
  Eh_hat  <- calc_Eh(y_hat,  h)

  ok_eh_p <- is.finite(Eh_true) & is.finite(Eh_pers)
  ok_eh_m <- is.finite(Eh_true) & is.finite(Eh_hat)
  ok_eh   <- ok_eh_p & ok_eh_m

  list(
    y_true = y_true,
    y_pers = y_pers,
    y_hat  = y_hat,
    okm    = okm,
    Eh_true = Eh_true,
    Eh_pers = Eh_pers,
    Eh_hat  = Eh_hat,
    ok_eh_p = ok_eh_p,
    ok_eh_m = ok_eh_m,
    ok_eh   = ok_eh
  )
}

choose_winner <- function(tab_sub) {
  sub <- copy(tab_sub)
  sub[, R2_ord := fifelse(is.finite(R2), R2, -Inf)]
  sub[, Skill_ord := fifelse(is.finite(Skill_vs_Persist), Skill_vs_Persist, -Inf)]
  setorder(sub, -R2_ord, -Skill_ord, RMSE)
  sub[1]
}

make_pub_df <- function(t, real, pred, max_points = 2500, use_log1p = TRUE) {
  dfp <- data.frame(t = t, real = real, pred = pred)

  if (nrow(dfp) > max_points) {
    idx <- round(seq(1, nrow(dfp), length.out = max_points))
    dfp <- dfp[idx, , drop = FALSE]
  }

  if (use_log1p) {
    dfp$real <- log1p(dfp$real)
    dfp$pred <- log1p(dfp$pred)
  }

  dfp
}

plot_pub <- function(dfp, title, subtitle, ylab_txt, file_out,
                     style = c("nature", "elsevier")) {
  style <- match.arg(style)

  p <- ggplot(dfp, aes(x = t)) +
    geom_line(aes(y = real), color = "grey25", linewidth = 0.45, alpha = 0.85) +
    geom_line(aes(y = pred), color = "#0072B2", linewidth = 0.75, alpha = 0.95) +
    labs(title = title, subtitle = subtitle, x = "Tiempo", y = ylab_txt)

  if (style == "nature") {
    p <- p + theme_minimal(base_size = 12) +
      theme(
        plot.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey88"),
        axis.text = element_text(color = "black"),
        axis.title = element_text(color = "black")
      )
  } else {
    p <- p + theme_bw(base_size = 12) +
      theme(
        plot.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey90"),
        axis.text = element_text(color = "black"),
        axis.title = element_text(color = "black"),
        legend.position = "none"
      )
  }

  ggsave(file_out, p, width = 10.5, height = 4.6, dpi = 350)
}

save_pred_cache <- function(model_group, zona, hname, h, model, t_base, y_true_wpd, y_pred_wpd) {
  Eh_true <- calc_Eh(y_true_wpd, h)
  Eh_pred <- calc_Eh(y_pred_wpd, h)

  out <- data.table(
    Zona = zona,
    Horizonte = hname,
    h = h,
    Grupo = model_group,
    Modelo = model,
    Fecha = t_base,
    WPD_true = y_true_wpd,
    WPD_pred = y_pred_wpd,
    Eh_true = Eh_true,
    Eh_pred = Eh_pred
  )

  fdir <- file.path(DIR_PRED, paste0("Z", zona), paste0("H_", h))
  dir.create(fdir, recursive = TRUE, showWarnings = FALSE)

  fout <- file.path(fdir, paste0(model_group, "__", model, "__", hname, ".csv"))
  fwrite(out, fout)
  invisible(fout)
}

# ============================================================
# 5. CARGA DEL CACHE HORARIO
# ============================================================

if (!file.exists(CACHE_FILE)) {
  stop("No existe el cache requerido: ", CACHE_FILE,
       "\nEjecuta antes: 03_CODE/01_preprocessing/02_build_hourly_wpd_cache.R")
}

logi("Leyendo cache horario:", CACHE_FILE)
hourly <- read_any_delim(CACHE_FILE)

stopifnot(all(c("Zona", "FechaHora", "VV", "rho", "WPD") %in% names(hourly)))

hourly[, Zona := as.integer(Zona)]
hourly[, FechaHora := as.POSIXct(FechaHora, tz = TZ_LOCAL)]
hourly[, VV  := as.numeric(VV)]
hourly[, rho := as.numeric(rho)]
hourly[, WPD := as.numeric(WPD)]

hourly <- hourly[
  !is.na(Zona) &
    !is.na(FechaHora)
]

setorder(hourly, Zona, FechaHora)

zones <- sort(unique(hourly$Zona))
logi("Zonas detectadas:", paste(zones, collapse = ","))

# ============================================================
# 6. PIPELINE CLÁSICO
# ============================================================

rows_wpd <- list()
rows_eh  <- list()

for (z in zones) {

  logi("CLASICOS | ZONA", z)

  dz0 <- hourly[Zona == z][order(FechaHora)]
  dz0 <- dz0[is.finite(WPD)]

  if (nrow(dz0) < MIN_ZONE_ROWS_CLASSIC) {
    logi("Zona", z, "omitida por tamaño insuficiente:", nrow(dz0))
    next
  }

  n0 <- nrow(dz0)
  ntr0 <- floor(TRAIN_FRAC * n0)

  if (!is.finite(ntr0) || ntr0 < 800) {
    logi("Zona", z, "omitida por train insuficiente:", ntr0)
    next
  }

  train0 <- dz0[1:ntr0]
  test0  <- dz0[(ntr0 + 1):n0]

  y_test0 <- test0$WPD
  t_test0 <- test0$FechaHora

  # -------------------------
  # ARIMA
  # -------------------------
  fitA <- tryCatch(
    auto.arima(ts(train0$WPD, frequency = 24), seasonal = TRUE),
    error = function(e) NULL
  )

  yhatA_full <- rep(NA_real_, nrow(test0))
  if (!is.null(fitA)) {
    yhatA_full <- tryCatch(
      as.numeric(forecast(fitA, h = nrow(test0))$mean),
      error = function(e) rep(NA_real_, nrow(test0))
    )
  }

  # -------------------------
  # ARIMAX (VV, rho)
  # -------------------------
  xtr <- as.matrix(train0[, .(VV, rho)])
  xte <- as.matrix(test0[, .(VV, rho)])

  fitX <- NULL
  yhatX_full <- rep(NA_real_, nrow(test0))

  cc_trx <- complete.cases(xtr) & is.finite(train0$WPD)
  if (sum(cc_trx) > MIN_CC_TR) {
    fitX <- tryCatch(
      auto.arima(
        ts(train0$WPD[cc_trx], frequency = 24),
        xreg = xtr[cc_trx, , drop = FALSE],
        seasonal = TRUE
      ),
      error = function(e) NULL
    )
  }

  if (!is.null(fitX)) {
    cc_tex <- complete.cases(xte)
    if (sum(cc_tex) > MIN_CC_TE) {
      tmp <- rep(NA_real_, nrow(test0))
      tmp[cc_tex] <- tryCatch(
        as.numeric(forecast(fitX, xreg = xte[cc_tex, , drop = FALSE], h = sum(cc_tex))$mean),
        error = function(e) rep(NA_real_, sum(cc_tex))
      )
      yhatX_full <- tmp
    }
  }

  pred_classic <- list(
    Persistencia = y_test0,
    ARIMA = yhatA_full,
    ARIMAX = yhatX_full
  )

  # -------------------------
  # Evaluación por horizonte
  # -------------------------
  for (hname in names(HORIZONS)) {

    h <- HORIZONS[[hname]]

    evP <- eval_h(y_test0, pred_classic$Persistencia, h)
    if (is.null(evP)) next

    rmse_p <- rmse(evP$y_true - evP$y_pers)

    # Persistencia WPD
    rows_wpd[[length(rows_wpd) + 1]] <- data.frame(
      Zona = z,
      Horizonte = hname,
      h = h,
      Modelo = "Persistencia",
      n_test = length(evP$y_true),
      RMSE = rmse_p,
      MAE = mae(evP$y_true - evP$y_pers),
      R2 = r2_score(evP$y_true, evP$y_pers),
      Skill_vs_Persist = NA_real_
    )

    # Persistencia Eh
    if (sum(evP$ok_eh_p) > 200) {
      rmse_p_eh <- rmse(evP$Eh_true[evP$ok_eh_p] - evP$Eh_pers[evP$ok_eh_p])

      rows_eh[[length(rows_eh) + 1]] <- data.frame(
        Zona = z,
        Horizonte = hname,
        h = h,
        Modelo = "Persistencia",
        n_test = sum(evP$ok_eh_p),
        RMSE = rmse_p_eh,
        MAE = mae(evP$Eh_true[evP$ok_eh_p] - evP$Eh_pers[evP$ok_eh_p]),
        R2 = r2_score(evP$Eh_true[evP$ok_eh_p], evP$Eh_pers[evP$ok_eh_p]),
        Skill_vs_Persist = NA_real_
      )
    }

    # Cache persistencia alineado n-h
    n <- length(y_test0)
    if (n > h + 30) {
      t_base <- t_test0[1:(n - h)]
      y_true_wpd <- y_test0[(h + 1):n]
      y_pred_wpd <- y_test0[1:(n - h)]

      save_pred_cache("CLASICOS", z, hname, h, "Persistencia", t_base, y_true_wpd, y_pred_wpd)
    }

    # Modelos clásicos
    for (mname in c("ARIMA", "ARIMAX")) {
      evM <- eval_h(y_test0, pred_classic[[mname]], h)
      if (is.null(evM) || sum(evM$okm) < 200) next

      rmse_m <- rmse(evM$y_true[evM$okm] - evM$y_hat[evM$okm])

      rows_wpd[[length(rows_wpd) + 1]] <- data.frame(
        Zona = z,
        Horizonte = hname,
        h = h,
        Modelo = mname,
        n_test = sum(evM$okm),
        RMSE = rmse_m,
        MAE = mae(evM$y_true[evM$okm] - evM$y_hat[evM$okm]),
        R2 = r2_score(evM$y_true[evM$okm], evM$y_hat[evM$okm]),
        Skill_vs_Persist = skill(rmse_m, rmse_p)
      )

      if (sum(evM$ok_eh) > 200 && sum(evP$ok_eh_p) > 200) {
        rmse_p_eh <- rmse(evP$Eh_true[evP$ok_eh_p] - evP$Eh_pers[evP$ok_eh_p])
        rmse_m_eh <- rmse(evM$Eh_true[evM$ok_eh] - evM$Eh_hat[evM$ok_eh])

        rows_eh[[length(rows_eh) + 1]] <- data.frame(
          Zona = z,
          Horizonte = hname,
          h = h,
          Modelo = mname,
          n_test = sum(evM$ok_eh),
          RMSE = rmse_m_eh,
          MAE = mae(evM$Eh_true[evM$ok_eh] - evM$Eh_hat[evM$ok_eh]),
          R2 = r2_score(evM$Eh_true[evM$ok_eh], evM$Eh_hat[evM$ok_eh]),
          Skill_vs_Persist = skill(rmse_m_eh, rmse_p_eh)
        )
      }

      if (n > h + 30) {
        t_base <- t_test0[1:(n - h)]
        y_true_wpd <- y_test0[(h + 1):n]
        y_pred_wpd <- pred_classic[[mname]][(h + 1):n]

        save_pred_cache("CLASICOS", z, hname, h, mname, t_base, y_true_wpd, y_pred_wpd)
      }
    }
  }
}

# ============================================================
# 7. TABLAS FINALES
# ============================================================

TAB_WPD_C <- rbindlist(rows_wpd, fill = TRUE)
TAB_EH_C  <- rbindlist(rows_eh, fill = TRUE)

fwrite(TAB_WPD_C, file.path(DIR_TAB_D, "CAP3_CLASICOS_WPD.csv"))
fwrite(TAB_EH_C,  file.path(DIR_TAB_D, "CAP3_CLASICOS_EH.csv"))

fwrite(TAB_WPD_C, file.path(DIR_TAB_A, "CAP3_CLASICOS_WPD_COMPLETO.csv"))
fwrite(TAB_EH_C,  file.path(DIR_TAB_A, "CAP3_CLASICOS_EH_COMPLETO.csv"))

WINNERS_WPD <- TAB_WPD_C[, choose_winner(.SD), by = .(Zona, Horizonte)]
WINNERS_EH  <- TAB_EH_C[, choose_winner(.SD), by = .(Zona, Horizonte)]

fwrite(WINNERS_WPD, file.path(DIR_TAB_D, "CAP3_CLASICOS_WPD_GANADORES.csv"))
fwrite(WINNERS_EH,  file.path(DIR_TAB_D, "CAP3_CLASICOS_EH_GANADORES.csv"))

# ============================================================
# 8. FIGURAS PUBLICABLES DE GANADORES
# ============================================================

for (i in seq_len(nrow(WINNERS_WPD))) {
  rw <- WINNERS_WPD[i]

  fcache <- file.path(
    DIR_PRED,
    paste0("Z", rw$Zona),
    paste0("H_", rw$h),
    paste0("CLASICOS__", rw$Modelo, "__", rw$Horizonte, ".csv")
  )

  if (!file.exists(fcache)) next

  P <- fread(fcache)
  if (!all(c("Fecha", "WPD_true", "WPD_pred", "Eh_true", "Eh_pred") %in% names(P))) next

  P[, Fecha := as.POSIXct(Fecha, tz = TZ_LOCAL)]

  df_wpd <- make_pub_df(P$Fecha, P$WPD_true, P$WPD_pred, max_points = MAX_POINTS, use_log1p = USE_LOG1P)
  df_eh  <- make_pub_df(P$Fecha, P$Eh_true,  P$Eh_pred,  max_points = MAX_POINTS, use_log1p = USE_LOG1P)

  fout_n_wpd <- file.path(DIR_FIG_N, sprintf("CLASICOS_WPD_Z%d_%s_%s.png", rw$Zona, rw$Horizonte, rw$Modelo))
  fout_e_wpd <- file.path(DIR_FIG_E, sprintf("CLASICOS_WPD_Z%d_%s_%s.png", rw$Zona, rw$Horizonte, rw$Modelo))
  fout_n_eh  <- file.path(DIR_FIG_N, sprintf("CLASICOS_EH_Z%d_%s_%s.png",  rw$Zona, rw$Horizonte, rw$Modelo))
  fout_e_eh  <- file.path(DIR_FIG_E, sprintf("CLASICOS_EH_Z%d_%s_%s.png",  rw$Zona, rw$Horizonte, rw$Modelo))

  plot_pub(
    df_wpd,
    title = sprintf("WPD | Zona %d | %s", rw$Zona, rw$Horizonte),
    subtitle = sprintf("Modelo clásico ganador: %s", rw$Modelo),
    ylab_txt = ifelse(USE_LOG1P, "log(1 + WPD)", "WPD"),
    file_out = fout_n_wpd,
    style = "nature"
  )

  plot_pub(
    df_wpd,
    title = sprintf("WPD | Zona %d | %s", rw$Zona, rw$Horizonte),
    subtitle = sprintf("Modelo clásico ganador: %s", rw$Modelo),
    ylab_txt = ifelse(USE_LOG1P, "log(1 + WPD)", "WPD"),
    file_out = fout_e_wpd,
    style = "elsevier"
  )

  plot_pub(
    df_eh,
    title = sprintf("Eh | Zona %d | %s", rw$Zona, rw$Horizonte),
    subtitle = sprintf("Modelo clásico ganador: %s", rw$Modelo),
    ylab_txt = ifelse(USE_LOG1P, "log(1 + Eh)", "Eh"),
    file_out = fout_n_eh,
    style = "nature"
  )

  plot_pub(
    df_eh,
    title = sprintf("Eh | Zona %d | %s", rw$Zona, rw$Horizonte),
    subtitle = sprintf("Modelo clásico ganador: %s", rw$Modelo),
    ylab_txt = ifelse(USE_LOG1P, "log(1 + Eh)", "Eh"),
    file_out = fout_e_eh,
    style = "elsevier"
  )
}

# ============================================================
# 9. SESSION INFO
# ============================================================

writeLines(capture.output(sessionInfo()), file.path(OUT_DIR, "MASTER_sessionInfo.txt"))

# ============================================================
# 10. CIERRE
# ============================================================

logi("CAP3 clásicos completado.")
logi("Tablas documento:", DIR_TAB_D)
logi("Tablas anexos:", DIR_TAB_A)
logi("Pred cache:", DIR_PRED)
logi("Figuras Nature:", DIR_FIG_N)
logi("Figuras Elsevier:", DIR_FIG_E)

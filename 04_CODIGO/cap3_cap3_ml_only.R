# ============================================================
# CAP3 – ML-only Pipeline (Eh target)
# PURPOSE: Machine Learning pipeline (RF/XGB) with export of predictions
# INPUTS: Clean dataset and configured output folders
# OUTPUTS: ML metrics tables + figures + prediction cache vectors
# NOTE: This script was extracted from the working thesis pipeline and
#       lightly cleaned for GitHub (paths made configurable, unicode normalized).
# ============================================================

# ============================================================
# PIPELINE FINAL (CLASICOS + ML_BASE + ML_BAYES) + EXPORT PRED
# Target final: Eh (energía integrada / potencia usable)
# Además exporta: predicciones (vectores) para híbrido TDQ/FNRR
# RUTA: C:\Users\UMARIANA\Desktop\Datos.txt
# SALIDAS: carpeta "SALIDAS" (misma estructura)
# ============================================================

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
  library(forecast)
  library(ggplot2)
  library(ranger)
  library(xgboost)
  library(rBayesianOptimization)
})

# ---------------- CONFIG
data_path  <- file.path("data","Datos.txt")  # <-- set your local path
OUT <- "SALIDAS"
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

# Carpetas de exportación
DIR_DOC   <- file.path(OUT, "DOC_PRINCIPAL")   # figuras/tablas para documento
DIR_ANX   <- file.path(OUT, "ANEXOS")          # anexos (todas las figuras/tablas)
DIR_PRED  <- file.path(OUT, "PRED_CACHE")      # VECTORES (para híbrido sin reentrenar)
DIR_FIG_N <- file.path(DIR_DOC, "FIG_NATURE")  # figuras publicables tipo Nature
DIR_FIG_E <- file.path(DIR_DOC, "FIG_ELSEVIER")# figuras publicables tipo Elsevier
DIR_FIG_A <- file.path(DIR_ANX, "FIGS")        # todas las figuras anexos
DIR_TAB_D <- file.path(DIR_DOC, "TABLAS")
DIR_TAB_A <- file.path(DIR_ANX, "TABLAS")

for (d in c(DIR_DOC,DIR_ANX,DIR_PRED,DIR_FIG_N,DIR_FIG_E,DIR_FIG_A,DIR_TAB_D,DIR_TAB_A)) {
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
}

stopifnot(file.exists(data_path))

TZ_LOCAL <- "America/Bogota"
R_air <- 287
rho0_default <- 1.10
RESAMPLE_UNIT <- "hour"
HORIZONS <- c(Corto=1, Medio=12, Largo=72)
TRAIN_FRAC <- 0.80
SEED <- 123
set.seed(SEED)

# Plot configs (publicables)
MAX_POINTS <- 2500
USE_LOG1P  <- TRUE

# Mínimos
MIN_ZONE_ROWS_CLASSIC <- 2500
MIN_ZONE_ROWS_ML  <- 2500
MIN_TRAIN_ROWS_ML <- 1500
MIN_CC_TR <- 800
MIN_CC_TE <- 300

# XGB
TREE_METHOD <- "hist"
NROUNDS_XGB_BASE <- 800
MAX_NROUNDS <- 1800
EARLY_STOP  <- 40

# Bayes (rápido/estable)
INIT_POINTS_ML <- 6
N_ITER_ML      <- 8
N_FOLDS  <- 4
VAL_SIZE <- 1200
GAP      <- 0
MIN_FOLD_OK <- 2

# Optimización Bayes (ya lo tienes así)
OPT_TARGET <- "Eh"   # mantenemos para calidad en objetivo final
OPT_H      <- 12

# ---------------- LOG
logi <- function(...) cat(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "|", ..., "\n")
writeLines(capture.output(sessionInfo()), file.path(OUT, "MASTER_sessionInfo.txt"))

# ---------------- HELPERS
rmse <- function(e) sqrt(mean(e^2, na.rm=TRUE))
mae  <- function(e) mean(abs(e), na.rm=TRUE)

r2_score <- function(y, yhat){
  ok <- is.finite(y) & is.finite(yhat)
  if (sum(ok) < 10) return(NA_real_)
  y <- y[ok]; yhat <- yhat[ok]
  sse <- sum((y - yhat)^2)
  sst <- sum((y - mean(y))^2)
  if (!is.finite(sst) || sst <= 0) return(NA_real_)
  r2 <- 1 - sse/sst
  if (!is.finite(r2)) return(NA_real_)
  min(r2, 1.0)
}
skill <- function(rmse_model, rmse_persist){
  if (!is.finite(rmse_model) || !is.finite(rmse_persist) || rmse_persist <= 0) return(NA_real_)
  1 - rmse_model/rmse_persist
}
calc_Eh <- function(x, h){
  if (length(x) < h) return(rep(NA_real_, length(x)))
  as.numeric(stats::filter(x, rep(1, h), sides = 1))
}

eval_h <- function(y_test, yhat_full, h){
  n <- length(y_test)
  if (n <= h + 30) return(NULL)

  y_true <- y_test[(h+1):n]
  y_pers <- y_test[1:(n-h)]
  y_hat  <- yhat_full[(h+1):n]

  okm <- is.finite(y_true) & is.finite(y_hat)

  Eh_true <- calc_Eh(y_true, h)
  Eh_pers <- calc_Eh(y_pers, h)
  Eh_hat  <- calc_Eh(y_hat,  h)

  ok_eh_p <- is.finite(Eh_true) & is.finite(Eh_pers)
  ok_eh_m <- is.finite(Eh_true) & is.finite(Eh_hat)
  ok_eh   <- ok_eh_p & ok_eh_m

  list(
    y_true=y_true, y_pers=y_pers, y_hat=y_hat,
    okm=okm,
    Eh_true=Eh_true, Eh_pers=Eh_pers, Eh_hat=Eh_hat,
    ok_eh_p=ok_eh_p, ok_eh_m=ok_eh_m, ok_eh=ok_eh
  )
}

choose_winner <- function(tab_sub){
  sub <- copy(tab_sub)
  sub[, R2_ord := fifelse(is.finite(R2), R2, -Inf)]
  sub[, Skill_ord := fifelse(is.finite(Skill_vs_Persist), Skill_vs_Persist, -Inf)]
  setorder(sub, -R2_ord, -Skill_ord, RMSE)
  sub[1]
}

# --------- PUBLICABLE PLOT UTILS
make_pub_df <- function(t, real, pred, max_points=2500, use_log1p=TRUE){
  dfp <- data.frame(t=t, real=real, pred=pred)
  if (nrow(dfp) > max_points){
    idx <- round(seq(1, nrow(dfp), length.out = max_points))
    dfp <- dfp[idx, , drop=FALSE]
  }
  if (use_log1p){
    dfp$real <- log1p(dfp$real)
    dfp$pred <- log1p(dfp$pred)
  }
  dfp
}

plot_pub <- function(dfp, title, subtitle, ylab_txt, file_out,
                     style=c("nature","elsevier")){
  style <- match.arg(style)
  p <- ggplot(dfp, aes(x=t)) +
    geom_line(aes(y=real), color="grey25", linewidth=0.45, alpha=0.85) +
    geom_line(aes(y=pred),  color="#0072B2", linewidth=0.75, alpha=0.95) +
    labs(title=title, subtitle=subtitle, x="Tiempo", y=ylab_txt)

  if (style == "nature"){
    p <- p + theme_minimal(base_size = 12) +
      theme(
        plot.title = element_text(face="bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color="grey88"),
        axis.text = element_text(color="black"),
        axis.title = element_text(color="black")
      )
  } else {
    # Elsevier-like: más sobrio, líneas limpias
    p <- p + theme_bw(base_size = 12) +
      theme(
        plot.title = element_text(face="bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color="grey90"),
        axis.text = element_text(color="black"),
        axis.title = element_text(color="black"),
        legend.position = "none"
      )
  }
  ggsave(file_out, p, width=10.5, height=4.6, dpi=350)
}

# --------- FEATURES ML (solo hacia atrás)
add_features <- function(dz){
  dz <- copy(dz)
  dz[, `:=`(
    hour  = hour(FechaYHora),
    wday  = wday(FechaYHora, week_start = 1),
    month = month(FechaYHora)
  )]
  for (L in c(1,2,3,6,12,24,48,72)){
    dz[, paste0("WPD_lag",L) := shift(WPD, L)]
  }
  dz[, WPD_roll24 := frollmean(WPD, 24, align="right", na.rm=TRUE)]
  if ("VV" %in% names(dz)){
    for (L in c(1,2,3,6,12,24,48,72)){
      dz[, paste0("VV_lag",L) := shift(VV, L)]
    }
    dz[, VV_roll24 := frollmean(VV, 24, align="right", na.rm=TRUE)]
  }
  if ("rho" %in% names(dz)){
    for (L in c(1,2,3,6,12,24,48,72)){
      dz[, paste0("rho_lag",L) := shift(rho, L)]
    }
    dz[, rho_roll24 := frollmean(rho, 24, align="right", na.rm=TRUE)]
  }
  dz
}

make_time_folds <- function(n, n_folds=4, val_size=1200, gap=0){
  folds <- list()
  if (!is.finite(n) || n < 800) return(folds)
  val_size <- min(val_size, floor(0.20*n))
  val_size <- max(val_size, 300)
  for (k in seq_len(n_folds)){
    val_end   <- n - (k-1)*val_size
    val_start <- val_end - val_size + 1
    if (val_start <= 250) break
    tr_end <- val_start - 1 - gap
    if (tr_end <= 250) break
    folds[[length(folds)+1]] <- list(tr = 1:tr_end, va = val_start:val_end)
  }
  rev(folds)
}

score_skill_fold <- function(y_va, yhat_va, h, target=c("WPD","Eh")){
  target <- match.arg(target)
  if (length(y_va) <= h + 30) return(NA_real_)

  y_true <- y_va[(h+1):length(y_va)]
  y_pers <- y_va[1:(length(y_va)-h)]
  yhat_h <- yhat_va[(h+1):length(y_va)]

  if (target == "Eh"){
    Eh_true <- calc_Eh(y_true, h)
    Eh_pers <- calc_Eh(y_pers, h)
    Eh_hat  <- calc_Eh(yhat_h, h)
    ok <- is.finite(Eh_true) & is.finite(Eh_pers) & is.finite(Eh_hat)
    if (sum(ok) < 200) return(NA_real_)
    rmse_p <- rmse(Eh_true[ok] - Eh_pers[ok])
    rmse_m <- rmse(Eh_true[ok] - Eh_hat[ok])
    return(skill(rmse_m, rmse_p))
  } else {
    ok <- is.finite(y_true) & is.finite(y_pers) & is.finite(yhat_h)
    if (sum(ok) < 200) return(NA_real_)
    rmse_p <- rmse(y_true[ok] - y_pers[ok])
    rmse_m <- rmse(y_true[ok] - yhat_h[ok])
    return(skill(rmse_m, rmse_p))
  }
}

# ---- extractor Bayes sin $
safe_bestpar <- function(bo){
  if (is.null(bo)) return(NULL)
  bp <- NULL
  if (!is.null(bo[["Best_Par"]])) bp <- bo[["Best_Par"]]
  if (is.null(bp) && !is.null(bo[["Best_Parameters"]])) bp <- bo[["Best_Parameters"]]
  if (is.null(bp)) return(NULL)
  if (is.atomic(bp) && !is.null(names(bp))) bp <- as.list(bp)
  if (is.data.frame(bp) && nrow(bp) >= 1) bp <- as.list(bp[1, ])
  if (is.null(bp) || !length(bp)) return(NULL)
  bp
}
get_num <- function(lst, key, default){
  if (is.null(lst)) return(default)
  v <- lst[[key]]
  if (is.null(v)) return(default)
  v <- suppressWarnings(as.numeric(v))
  if (!is.finite(v)) return(default)
  v
}
get_int <- function(lst, key, default){
  as.integer(round(get_num(lst, key, default)))
}

# ============================================================
# STEP 0: INGESTA + HOURLY + WPD (CACHE)
# ============================================================
hourly_path <- file.path(OUT, "WPD_hourly_por_zona.csv")

if (file.exists(hourly_path)) {
  logi("Leyendo hourly cache:", hourly_path)
  hourly <- fread(hourly_path)
} else {
  logi("Creando hourly desde:", data_path)
  dt0 <- fread(data_path, sep="\t", encoding="UTF-8", showProgress=TRUE)
  setnames(dt0, c("Estación","FechaYHora","Valor","Zona","Variable"))

  dt0[, FechaYHora := trimws(FechaYHora)]
  dt0[, FechaYHora := gsub("a\\.?\\s*m\\.?","AM", FechaYHora, ignore.case=TRUE)]
  dt0[, FechaYHora := gsub("p\\.?\\s*m\\.?","PM", FechaYHora, ignore.case=TRUE)]
  dt0[, FechaYHora := gsub("\\s+"," ", FechaYHora)]

  dt0[, FechaYHora := parse_date_time(
    FechaYHora,
    orders = c("dmy HMS p", "dmy HM p", "dmy HMS", "dmy HM"),
    tz = TZ_LOCAL
  )]

  dt0[, Valor := as.numeric(gsub(",", ".", Valor))]
  dt0 <- dt0[is.finite(Valor) & !is.na(FechaYHora) & !is.na(Zona) & !is.na(Variable)]

  agg <- dt0[, .(Valor = mean(Valor, na.rm=TRUE)), by=.(Zona, FechaYHora, Variable)]
  wide <- dcast(agg, Zona + FechaYHora ~ Variable, value.var="Valor", fill=NA_real_)

  wide[, Hora := floor_date(FechaYHora, unit = RESAMPLE_UNIT)]
  hourly <- wide[, lapply(.SD, function(x) mean(x, na.rm=TRUE)),
                 by = .(Zona, Hora),
                 .SDcols = setdiff(names(wide), c("FechaYHora","Hora","Zona"))]
  setnames(hourly, "Hora", "FechaYHora")

  for (v in c("VV","TM","PA")) if (!v %in% names(hourly)) hourly[, (v) := NA_real_]

  hourly[, T_K := TM + 273.15]
  hourly[, PA_Pa := PA * 100]
  hourly[, rho := fifelse(is.finite(PA_Pa) & is.finite(T_K) & T_K > 0,
                          PA_Pa / (R_air * T_K),
                          rho0_default)]
  hourly[, WPD := 0.5 * rho * (VV^3)]
  hourly[!(is.finite(WPD) & WPD >= 0 & rho > 0.5 & rho < 2.0), WPD := NA_real_]

  fwrite(hourly, hourly_path)
  logi("OK ->", hourly_path, "| rows=", nrow(hourly))
}

setorder(hourly, Zona, FechaYHora)

# ============================================================
# EXPORTADOR DE PREDICCIONES (CACHE PARA HÍBRIDO TDQ)
# ============================================================
save_pred_cache <- function(model_group, zona, hname, h, model, t_base, y_true_wpd, y_pred_wpd){
  # Construye Eh alineado y guarda todo lo necesario para hibrido y plots
  # t_base: longitud = n-h (fechas base)
  # y_true_wpd: longitud = n-h (WPD verdadero alineado)
  # y_pred_wpd: longitud = n-h (WPD predicho alineado)
  Eh_true <- calc_Eh(y_true_wpd, h)
  Eh_pred <- calc_Eh(y_pred_wpd, h)

  out <- data.table(
    Zona = zona,
    Horizonte = hname,
    h = h,
    Grupo = model_group,      # CLASICOS / ML_BASE / ML_BAYES
    Modelo = model,
    Fecha = t_base,
    WPD_true = y_true_wpd,
    WPD_pred = y_pred_wpd,
    Eh_true = Eh_true,
    Eh_pred = Eh_pred
  )

  fdir <- file.path(DIR_PRED, paste0("Z", zona), paste0("H_", h))
  dir.create(fdir, showWarnings = FALSE, recursive = TRUE)
  fout <- file.path(fdir, paste0(model_group, "__", model, "__", hname, ".csv"))
  fwrite(out, fout)
  invisible(fout)
}

# ============================================================
# ====== 1) CLASICOS (Persist, ARIMA, ARIMAX) + CACHE
# ============================================================
logi("START CLASICOS")

rows_wpd <- list(); rows_eh <- list()
zones <- sort(unique(hourly$Zona))

for (z in zones){
  logi("CLASICOS | ZONA", z)
  dz0 <- hourly[Zona==z][order(FechaYHora)]
  dz0 <- dz0[is.finite(WPD)]
  if (nrow(dz0) < MIN_ZONE_ROWS_CLASSIC) next

  n0 <- nrow(dz0)
  ntr0 <- floor(TRAIN_FRAC*n0)
  if (!is.finite(ntr0) || ntr0 < 800) next

  train0 <- dz0[1:ntr0]
  test0  <- dz0[(ntr0+1):n0]
  y_test0 <- test0$WPD
  t_test0 <- test0$FechaYHora

  # ARIMA
  fitA <- tryCatch(auto.arima(ts(train0$WPD, frequency=24), seasonal=TRUE), error=function(e) NULL)
  yhatA_full <- rep(NA_real_, nrow(test0))
  if (!is.null(fitA)){
    yhatA_full <- tryCatch(as.numeric(forecast(fitA, h=nrow(test0))$mean),
                           error=function(e) rep(NA_real_, nrow(test0)))
  }

  # ARIMAX (VV,rho)
  xtr <- as.matrix(train0[, .(VV, rho)])
  xte <- as.matrix(test0[,  .(VV, rho)])
  fitX <- NULL
  yhatX_full <- rep(NA_real_, nrow(test0))
  cc_trx <- complete.cases(xtr) & is.finite(train0$WPD)
  if (sum(cc_trx) > 800){
    fitX <- tryCatch(
      auto.arima(ts(train0$WPD[cc_trx], frequency=24),
                 xreg=xtr[cc_trx, , drop=FALSE],
                 seasonal=TRUE),
      error=function(e) NULL
    )
  }
  if (!is.null(fitX)){
    cc_tex <- complete.cases(xte)
    if (sum(cc_tex) > 50){
      tmp <- rep(NA_real_, nrow(test0))
      tmp[cc_tex] <- tryCatch(
        as.numeric(forecast(fitX, xreg=xte[cc_tex, , drop=FALSE], h=sum(cc_tex))$mean),
        error=function(e) rep(NA_real_, sum(cc_tex))
      )
      yhatX_full <- tmp
    }
  }

  pred_classic <- list(
    Persistencia = y_test0,
    ARIMA = yhatA_full,
    ARIMAX = yhatX_full
  )

  # -------- eval + cache
  for (hname in names(HORIZONS)){
    h <- HORIZONS[[hname]]
    evP <- eval_h(y_test0, pred_classic$Persistencia, h)
    if (is.null(evP)) next

    rmse_p <- rmse(evP$y_true - evP$y_pers)

    # Persistencia (WPD)
    rows_wpd[[length(rows_wpd)+1]] <- data.frame(
      Zona=z, Horizonte=hname, h=h, Modelo="Persistencia",
      n_test=length(evP$y_true),
      RMSE=rmse_p, MAE=mae(evP$y_true-evP$y_pers),
      R2=r2_score(evP$y_true, evP$y_pers),
      Skill_vs_Persist=NA_real_
    )

    # Persistencia (Eh)
    if (sum(evP$ok_eh_p) > 200){
      rmse_p_eh <- rmse(evP$Eh_true[evP$ok_eh_p] - evP$Eh_pers[evP$ok_eh_p])
      rows_eh[[length(rows_eh)+1]] <- data.frame(
        Zona=z, Horizonte=hname, h=h, Modelo="Persistencia",
        n_test=sum(evP$ok_eh_p),
        RMSE=rmse_p_eh, MAE=mae(evP$Eh_true[evP$ok_eh_p]-evP$Eh_pers[evP$ok_eh_p]),
        R2=r2_score(evP$Eh_true[evP$ok_eh_p], evP$Eh_pers[evP$ok_eh_p]),
        Skill_vs_Persist=NA_real_
      )
    }

    # Cache persistencia (alineado a n-h)
    n <- length(y_test0)
    if (n > h + 30){
      t_base <- t_test0[1:(n-h)]
      y_true_wpd <- y_test0[(h+1):n] # WPD verdadero a t+h, alineado con base
      y_pred_wpd <- y_test0[1:(n-h)] # persistencia
      save_pred_cache("CLASICOS", z, hname, h, "Persistencia", t_base, y_true_wpd, y_pred_wpd)
    }

    # ARIMA / ARIMAX
    for (mname in c("ARIMA","ARIMAX")){
      evM <- eval_h(y_test0, pred_classic[[mname]], h)
      if (is.null(evM) || sum(evM$okm) < 200) next
      rmse_m <- rmse(evM$y_true[evM$okm] - evM$y_hat[evM$okm])

      rows_wpd[[length(rows_wpd)+1]] <- data.frame(
        Zona=z, Horizonte=hname, h=h, Modelo=mname,
        n_test=sum(evM$okm),
        RMSE=rmse_m, MAE=mae(evM$y_true[evM$okm]-evM$y_hat[evM$okm]),
        R2=r2_score(evM$y_true[evM$okm], evM$y_hat[evM$okm]),
        Skill_vs_Persist=skill(rmse_m, rmse_p)
      )

      if (sum(evM$ok_eh) > 200 && sum(evP$ok_eh_p) > 200){
        rmse_p_eh <- rmse(evP$Eh_true[evP$ok_eh_p] - evP$Eh_pers[evP$ok_eh_p])
        rmse_m_eh <- rmse(evM$Eh_true[evM$ok_eh] - evM$Eh_hat[evM$ok_eh])
        rows_eh[[length(rows_eh)+1]] <- data.frame(
          Zona=z, Horizonte=hname, h=h, Modelo=mname,
          n_test=sum(evM$ok_eh),
          RMSE=rmse_m_eh, MAE=mae(evM$Eh_true[evM$ok_eh]-evM$Eh_hat[evM$ok_eh]),
          R2=r2_score(evM$Eh_true[evM$ok_eh], evM$Eh_hat[evM$ok_eh]),
          Skill_vs_Persist=skill(rmse_m_eh, rmse_p_eh)
        )
      }

      # Cache ARIMA/ARIMAX (alineado)
      n <- length(y_test0)
      if (n > h + 30){
        t_base <- t_test0[1:(n-h)]
        y_true_wpd <- y_test0[(h+1):n]
        y_pred_wpd <- pred_classic[[mname]][(h+1):n]
        save_pred_cache("CLASICOS", z, hname, h, mname, t_base, y_true_wpd, y_pred_wpd)
      }
    }
  }
}

TAB_WPD_C <- rbindlist(rows_wpd, fill=TRUE)
TAB_EH_C  <- rbindlist(rows_eh,  fill=TRUE)

fwrite(TAB_WPD_C, file.path(DIR_TAB_A, "CLASICOS_TABLA_WPD.csv"))
fwrite(TAB_EH_C,  file.path(DIR_TAB_A, "CLASICOS_TABLA_Eh.csv"))

DEF_WPD_C <- TAB_WPD_C[, choose_winner(.SD), by=.(Zona, Horizonte, h)]
DEF_EH_C  <- TAB_EH_C[,  choose_winner(.SD), by=.(Zona, Horizonte, h)]

fwrite(DEF_WPD_C, file.path(DIR_TAB_D, "CLASICOS_DEFINITIVA_WPD.csv"))
fwrite(DEF_EH_C,  file.path(DIR_TAB_D, "CLASICOS_DEFINITIVA_Eh.csv"))

logi("OK CLASICOS (tablas + pred cache).")

# ============================================================
# ====== 2) ML BASE (RF + XGB) + CACHE
# ============================================================
logi("START ML_BASE")

rows_wpd <- list(); rows_eh <- list()

for (z in zones){
  logi("ML_BASE | ZONA", z)

  dz <- hourly[Zona==z][order(FechaYHora)]
  dz <- dz[is.finite(WPD)]
  if (nrow(dz) < MIN_ZONE_ROWS_ML) next

  dz <- add_features(dz)

  need <- c("hour","wday","month","WPD_roll24","WPD_lag72")
  vv_ok  <- ("VV" %in% names(dz))  && (sum(is.finite(dz$VV))  > 2000)
  rho_ok <- ("rho" %in% names(dz)) && (sum(is.finite(dz$rho)) > 2000)
  if (vv_ok)  need <- c(need, "VV_roll24", "VV_lag72")
  if (rho_ok) need <- c(need, "rho_roll24","rho_lag72")

  dz <- dz[complete.cases(dz[, ..need])]
  if (nrow(dz) < MIN_ZONE_ROWS_ML) next

  n <- nrow(dz)
  ntr <- floor(TRAIN_FRAC*n)
  if (!is.finite(ntr) || ntr < MIN_TRAIN_ROWS_ML) next

  train <- dz[1:ntr]
  test  <- dz[(ntr+1):n]
  y_test <- test$WPD
  t_test <- test$FechaYHora

  base_feats <- c("hour","wday","month",
                  paste0("WPD_lag", c(1,2,3,6,12,24,48,72)),
                  "WPD_roll24")

  feat_cols <- base_feats
  if (vv_ok)  feat_cols <- c(feat_cols, paste0("VV_lag", c(1,2,3,6,12,24,48,72)), "VV_roll24")
  if (rho_ok) feat_cols <- c(feat_cols, paste0("rho_lag", c(1,2,3,6,12,24,48,72)), "rho_roll24")
  feat_cols <- intersect(feat_cols, names(dz))

  trainX <- train[, ..feat_cols]
  testX  <- test[,  ..feat_cols]
  for (cc in names(trainX)){
    suppressWarnings({
      trainX[[cc]] <- as.numeric(trainX[[cc]])
      testX[[cc]]  <- as.numeric(testX[[cc]])
    })
  }
  cc_tr <- complete.cases(trainX) & is.finite(train$WPD)
  cc_te <- complete.cases(testX)  & is.finite(test$WPD)
  if (sum(cc_tr) < MIN_CC_TR || sum(cc_te) < MIN_CC_TE) next

  trainX2 <- trainX[cc_tr]
  ytr <- train$WPD[cc_tr]

  # RF base
  pred_rf <- rep(NA_real_, nrow(test))
  rf <- tryCatch(
    ranger(dependent.variable.name="WPD",
           data=data.frame(WPD=ytr, trainX2),
           num.trees=500,
           mtry=max(2, floor(sqrt(ncol(trainX2)))),
           min.node.size=10,
           sample.fraction=0.80,
           seed=SEED + z),
    error=function(e) NULL
  )
  if (!is.null(rf)){
    pred_rf[cc_te] <- tryCatch(predict(rf, data=testX[cc_te])$predictions,
                               error=function(e) rep(NA_real_, sum(cc_te)))
  }

  # XGB base
  pred_xgb <- rep(NA_real_, nrow(test))
  xgbm <- tryCatch({
    dtr <- xgb.DMatrix(as.matrix(trainX2), label=ytr)
    xgb.train(
      params=list(objective="reg:squarederror",
                  eta=0.05, max_depth=6,
                  subsample=0.8, colsample_bytree=0.8,
                  min_child_weight=1, tree_method=TREE_METHOD),
      data=dtr, nrounds=NROUNDS_XGB_BASE, verbose=0
    )
  }, error=function(e) NULL)
  if (!is.null(xgbm)){
    dte <- xgb.DMatrix(as.matrix(testX[cc_te]))
    pred_xgb[cc_te] <- tryCatch(as.numeric(predict(xgbm, dte)),
                                error=function(e) rep(NA_real_, sum(cc_te)))
  }

  pred <- list(Persistencia=y_test, RF=pred_rf, XGB=pred_xgb)

  for (hname in names(HORIZONS)){
    h <- HORIZONS[[hname]]
    evP <- eval_h(y_test, pred$Persistencia, h)
    if (is.null(evP)) next
    rmse_p <- rmse(evP$y_true - evP$y_pers)

    for (mname in c("RF","XGB")){
      evM <- eval_h(y_test, pred[[mname]], h)
      if (is.null(evM) || sum(evM$okm) < 200) next

      rmse_m <- rmse(evM$y_true[evM$okm] - evM$y_hat[evM$okm])
      rows_wpd[[length(rows_wpd)+1]] <- data.frame(
        Zona=z, Horizonte=hname, h=h, Modelo=mname,
        n_test=sum(evM$okm),
        RMSE=rmse_m, MAE=mae(evM$y_true[evM$okm]-evM$y_hat[evM$okm]),
        R2=r2_score(evM$y_true[evM$okm], evM$y_hat[evM$okm]),
        Skill_vs_Persist=skill(rmse_m, rmse_p)
      )

      if (sum(evP$ok_eh_p) > 200 && sum(evM$ok_eh) > 200){
        rmse_p_eh <- rmse(evP$Eh_true[evP$ok_eh_p] - evP$Eh_pers[evP$ok_eh_p])
        rmse_m_eh <- rmse(evM$Eh_true[evM$ok_eh] - evM$Eh_hat[evM$ok_eh])
        rows_eh[[length(rows_eh)+1]] <- data.frame(
          Zona=z, Horizonte=hname, h=h, Modelo=mname,
          n_test=sum(evM$ok_eh),
          RMSE=rmse_m_eh, MAE=mae(evM$Eh_true[evM$ok_eh]-evM$Eh_hat[evM$ok_eh]),
          R2=r2_score(evM$Eh_true[evM$ok_eh], evM$Eh_hat[evM$ok_eh]),
          Skill_vs_Persist=skill(rmse_m_eh, rmse_p_eh)
        )
      }

      # Cache (alineado a n-h)
      ntest <- length(y_test)
      if (ntest > h + 30){
        t_base <- t_test[1:(ntest-h)]
        y_true_wpd <- y_test[(h+1):ntest]
        y_pred_wpd <- pred[[mname]][(h+1):ntest]
        save_pred_cache("ML_BASE", z, hname, h, mname, t_base, y_true_wpd, y_pred_wpd)
      }
    }
  }
}

TAB_WPD_M <- rbindlist(rows_wpd, fill=TRUE)
TAB_EH_M  <- rbindlist(rows_eh,  fill=TRUE)

fwrite(TAB_WPD_M, file.path(DIR_TAB_A, "ML_BASE_TABLA_WPD.csv"))
fwrite(TAB_EH_M,  file.path(DIR_TAB_A, "ML_BASE_TABLA_Eh.csv"))

DEF_WPD_M <- TAB_WPD_M[, choose_winner(.SD), by=.(Zona, Horizonte, h)]
DEF_EH_M  <- TAB_EH_M[,  choose_winner(.SD), by=.(Zona, Horizonte, h)]

fwrite(DEF_WPD_M, file.path(DIR_TAB_D, "ML_BASE_DEFINITIVA_WPD.csv"))
fwrite(DEF_EH_M,  file.path(DIR_TAB_D, "ML_BASE_DEFINITIVA_Eh.csv"))

logi("OK ML_BASE (tablas + pred cache).")

# ============================================================
# ====== 3) ML BAYES (RF_Bayes + XGB_Bayes) + CACHE
# ============================================================
logi("START ML_BAYES")

rows_wpd <- list(); rows_eh <- list()
params_xgb <- list(); params_rf <- list()

for (z in zones){
  logi("ML_BAYES | ZONA", z)

  dz <- hourly[Zona==z][order(FechaYHora)]
  dz <- dz[is.finite(WPD)]
  if (nrow(dz) < MIN_ZONE_ROWS_ML) next

  dz <- add_features(dz)

  need <- c("hour","wday","month","WPD_roll24","WPD_lag72")
  vv_ok  <- ("VV" %in% names(dz))  && (sum(is.finite(dz$VV))  > 2000)
  rho_ok <- ("rho" %in% names(dz)) && (sum(is.finite(dz$rho)) > 2000)
  if (vv_ok)  need <- c(need, "VV_roll24", "VV_lag72")
  if (rho_ok) need <- c(need, "rho_roll24","rho_lag72")

  dz <- dz[complete.cases(dz[, ..need])]
  if (nrow(dz) < MIN_ZONE_ROWS_ML) next

  n <- nrow(dz)
  ntr <- floor(TRAIN_FRAC*n)
  if (!is.finite(ntr) || ntr < MIN_TRAIN_ROWS_ML) next

  train <- dz[1:ntr]
  test  <- dz[(ntr+1):n]
  y_test <- test$WPD
  t_test <- test$FechaYHora

  base_feats <- c("hour","wday","month",
                  paste0("WPD_lag", c(1,2,3,6,12,24,48,72)),
                  "WPD_roll24")

  feat_cols <- base_feats
  if (vv_ok)  feat_cols <- c(feat_cols, paste0("VV_lag", c(1,2,3,6,12,24,48,72)), "VV_roll24")
  if (rho_ok) feat_cols <- c(feat_cols, paste0("rho_lag", c(1,2,3,6,12,24,48,72)), "rho_roll24")
  feat_cols <- intersect(feat_cols, names(dz))

  trainX_dt <- train[, ..feat_cols]
  testX_dt  <- test[,  ..feat_cols]
  for (cc in names(trainX_dt)){
    suppressWarnings({
      trainX_dt[[cc]] <- as.numeric(trainX_dt[[cc]])
      testX_dt[[cc]]  <- as.numeric(testX_dt[[cc]])
    })
  }

  cc_tr <- complete.cases(trainX_dt) & is.finite(train$WPD)
  cc_te <- complete.cases(testX_dt)  & is.finite(test$WPD)
  if (sum(cc_tr) < MIN_CC_TR || sum(cc_te) < MIN_CC_TE) next

  trainX2_dt <- trainX_dt[cc_tr]
  ytr <- train$WPD[cc_tr]

  trainX <- as.matrix(trainX2_dt)
  testX  <- as.matrix(testX_dt[cc_te])

  folds <- make_time_folds(nrow(trainX), N_FOLDS, VAL_SIZE, GAP)

  # ===== BASELINES (para comparar y para cache también)
  pred_rf_base <- rep(NA_real_, nrow(test))
  pred_xgb_base <- rep(NA_real_, nrow(test))

  rf_base <- tryCatch(
    ranger(dependent.variable.name="WPD",
           data=data.frame(WPD=ytr, trainX2_dt),
           num.trees=500,
           mtry=max(2, floor(sqrt(ncol(trainX2_dt)))),
           min.node.size=10,
           sample.fraction=0.80,
           seed=SEED + z),
    error=function(e) NULL
  )
  if (!is.null(rf_base)){
    pred_rf_base[cc_te] <- tryCatch(predict(rf_base, data=testX_dt[cc_te])$predictions,
                                    error=function(e) rep(NA_real_, sum(cc_te)))
  }

  xgb_base <- tryCatch({
    dtr <- xgb.DMatrix(trainX, label=ytr)
    xgb.train(
      params=list(objective="reg:squarederror",
                  eta=0.05, max_depth=6,
                  subsample=0.8, colsample_bytree=0.8,
                  min_child_weight=1, tree_method=TREE_METHOD),
      data=dtr, nrounds=NROUNDS_XGB_BASE, verbose=0
    )
  }, error=function(e) NULL)
  if (!is.null(xgb_base)){
    dte <- xgb.DMatrix(testX)
    pred_xgb_base[cc_te] <- tryCatch(as.numeric(predict(xgb_base, dte)),
                                     error=function(e) rep(NA_real_, sum(cc_te)))
  }

  # ===== BAYES XGB
  pred_xgb_bayes <- rep(NA_real_, nrow(test))

  if (length(folds) >= MIN_FOLD_OK){
    bayes_xgb_fun <- function(max_depth, eta, subsample, colsample_bytree, min_child_weight, gamma, lambda){
      params <- list(
        objective="reg:squarederror",
        booster="gbtree",
        max_depth=as.integer(round(max_depth)),
        eta=eta,
        subsample=subsample,
        colsample_bytree=colsample_bytree,
        min_child_weight=min_child_weight,
        gamma=gamma,
        lambda=lambda,
        tree_method=TREE_METHOD
      )
      scs <- c()
      for (fk in seq_along(folds)){
        tr_idx <- folds[[fk]][["tr"]]
        va_idx <- folds[[fk]][["va"]]
        dtr <- xgb.DMatrix(data=trainX[tr_idx, , drop=FALSE], label=ytr[tr_idx])
        dva <- xgb.DMatrix(data=trainX[va_idx, , drop=FALSE], label=ytr[va_idx])
        m <- tryCatch(
          xgb.train(params=params, data=dtr, nrounds=MAX_NROUNDS,
                    watchlist=list(train=dtr, val=dva),
                    early_stopping_rounds=EARLY_STOP, verbose=0),
          error=function(e) NULL
        )
        if (is.null(m)) next
        pred_va <- tryCatch(as.numeric(predict(m, dva)), error=function(e) rep(NA_real_, length(va_idx)))
        sc <- score_skill_fold(ytr[va_idx], pred_va, h=OPT_H, target=OPT_TARGET)
        if (is.finite(sc)) scs <- c(scs, sc)
      }
      Score <- if (length(scs) >= MIN_FOLD_OK) mean(scs) else -999
      list(Score=Score, Pred=0)
    }

    bounds_xgb <- list(
      max_depth        = c(3L, 10L),
      eta              = c(0.01, 0.20),
      subsample        = c(0.60, 0.95),
      colsample_bytree = c(0.60, 0.95),
      min_child_weight = c(1.0, 20.0),
      gamma            = c(0.0, 5.0),
      lambda           = c(0.0, 10.0)
    )

    set.seed(SEED + 8000 + z)
    bo_xgb <- tryCatch(
      BayesianOptimization(
        FUN=bayes_xgb_fun, bounds=bounds_xgb,
        init_points=INIT_POINTS_ML, n_iter=N_ITER_ML,
        acq="ucb", kappa=2.576, eps=0, verbose=FALSE
      ),
      error=function(e) NULL
    )
    best <- safe_bestpar(bo_xgb)

    if (!is.null(best)){
      final_params <- list(
        objective="reg:squarederror", booster="gbtree",
        max_depth=get_int(best, "max_depth", 6L),
        eta=get_num(best, "eta", 0.05),
        subsample=get_num(best, "subsample", 0.80),
        colsample_bytree=get_num(best, "colsample_bytree", 0.80),
        min_child_weight=get_num(best, "min_child_weight", 1.0),
        gamma=get_num(best, "gamma", 0.0),
        lambda=get_num(best, "lambda", 1.0),
        tree_method=TREE_METHOD
      )

      ntr2 <- nrow(trainX)
      tail_size <- min(2000, max(300, floor(0.2*ntr2)))
      tr_idx2 <- 1:(ntr2 - tail_size)
      va_idx2 <- (ntr2 - tail_size + 1):ntr2
      dtr2 <- xgb.DMatrix(data=trainX[tr_idx2, , drop=FALSE], label=ytr[tr_idx2])
      dva2 <- xgb.DMatrix(data=trainX[va_idx2, , drop=FALSE], label=ytr[va_idx2])

      final_xgb <- tryCatch(
        xgb.train(params=final_params, data=dtr2, nrounds=MAX_NROUNDS,
                  watchlist=list(train=dtr2, val=dva2),
                  early_stopping_rounds=EARLY_STOP, verbose=0),
        error=function(e) NULL
      )

      if (!is.null(final_xgb)){
        dte <- xgb.DMatrix(testX)
        pred_xgb_bayes[cc_te] <- tryCatch(as.numeric(predict(final_xgb, dte)),
                                          error=function(e) rep(NA_real_, sum(cc_te)))
        params_xgb[[length(params_xgb)+1]] <- data.frame(
          Zona=z, OptTarget=OPT_TARGET, OptH=OPT_H,
          max_depth=final_params[["max_depth"]],
          eta=final_params[["eta"]],
          subsample=final_params[["subsample"]],
          colsample_bytree=final_params[["colsample_bytree"]],
          min_child_weight=final_params[["min_child_weight"]],
          gamma=final_params[["gamma"]],
          lambda=final_params[["lambda"]],
          BestScore=if (!is.null(bo_xgb) && !is.null(bo_xgb[["Best_Value"]])) bo_xgb[["Best_Value"]] else NA_real_,
          BestNrounds=if (!is.null(final_xgb[["best_iteration"]])) final_xgb[["best_iteration"]] else NA_integer_
        )
      }
    }
  }

  # ===== BAYES RF
  pred_rf_bayes <- rep(NA_real_, nrow(test))
  if (length(folds) >= MIN_FOLD_OK){
    bayes_rf_fun <- function(mtry_frac, min_node, sample_frac, num_trees){
      p <- ncol(trainX2_dt)
      mtry <- max(2, min(p, as.integer(round(mtry_frac * p))))
      min_node <- max(1L, as.integer(round(min_node)))
      num_trees <- max(250L, as.integer(round(num_trees)))
      sample_frac <- max(0.60, min(0.95, sample_frac))

      scs <- c()
      for (fk in seq_along(folds)){
        tr_idx <- folds[[fk]][["tr"]]
        va_idx <- folds[[fk]][["va"]]
        dtr <- data.frame(WPD=ytr[tr_idx], trainX2_dt[tr_idx, , drop=FALSE])
        dva <- trainX2_dt[va_idx, , drop=FALSE]
        rf <- tryCatch(
          ranger(dependent.variable.name="WPD", data=dtr,
                 num.trees=num_trees, mtry=mtry,
                 min.node.size=min_node, sample.fraction=sample_frac,
                 seed=SEED + 4000 + z*10 + fk),
          error=function(e) NULL
        )
        if (is.null(rf)) next
        pred_va <- tryCatch(predict(rf, data=dva)$predictions,
                            error=function(e) rep(NA_real_, nrow(dva)))
        sc <- score_skill_fold(ytr[va_idx], pred_va, h=OPT_H, target=OPT_TARGET)
        if (is.finite(sc)) scs <- c(scs, sc)
      }
      Score <- if (length(scs) >= MIN_FOLD_OK) mean(scs) else -999
      list(Score=Score, Pred=0)
    }

    bounds_rf <- list(
      mtry_frac   = c(0.10, 0.70),
      min_node    = c(2L, 30L),
      sample_frac = c(0.60, 0.95),
      num_trees   = c(300L, 900L)
    )

    set.seed(SEED + 9000 + z)
    bo_rf <- tryCatch(
      BayesianOptimization(
        FUN=bayes_rf_fun, bounds=bounds_rf,
        init_points=INIT_POINTS_ML, n_iter=N_ITER_ML,
        acq="ucb", kappa=2.576, eps=0, verbose=FALSE
      ),
      error=function(e) NULL
    )
    best <- safe_bestpar(bo_rf)

    if (!is.null(best)){
      p <- ncol(trainX2_dt)
      best_mtry <- max(2, min(p, as.integer(round(get_num(best, "mtry_frac", 0.3) * p))))
      best_min  <- max(1L, as.integer(round(get_num(best, "min_node", 10))))
      best_sf   <- max(0.60, min(0.95, get_num(best, "sample_frac", 0.80)))
      best_nt   <- max(250L, as.integer(round(get_num(best, "num_trees", 500))))

      rf_b <- tryCatch(
        ranger(dependent.variable.name="WPD",
               data=data.frame(WPD=ytr, trainX2_dt),
               num.trees=best_nt, mtry=best_mtry,
               min.node.size=best_min, sample.fraction=best_sf,
               seed=SEED + 7000 + z),
        error=function(e) NULL
      )

      if (!is.null(rf_b)){
        pred_rf_bayes[cc_te] <- tryCatch(predict(rf_b, data=testX_dt[cc_te])$predictions,
                                         error=function(e) rep(NA_real_, sum(cc_te)))
        params_rf[[length(params_rf)+1]] <- data.frame(
          Zona=z, OptTarget=OPT_TARGET, OptH=OPT_H,
          mtry=best_mtry, min_node=best_min,
          sample_frac=best_sf, num_trees=best_nt,
          BestScore=if (!is.null(bo_rf) && !is.null(bo_rf[["Best_Value"]])) bo_rf[["Best_Value"]] else NA_real_
        )
      }
    }
  }

  pred <- list(
    Persistencia = y_test,
    RF = pred_rf_base,
    XGB = pred_xgb_base,
    RF_Bayes = pred_rf_bayes,
    XGB_Bayes = pred_xgb_bayes
  )

  for (hname in names(HORIZONS)){
    h <- HORIZONS[[hname]]
    evP <- eval_h(y_test, pred[["Persistencia"]], h)
    if (is.null(evP)) next
    rmse_p <- rmse(evP$y_true - evP$y_pers)

    for (mname in c("RF","XGB","RF_Bayes","XGB_Bayes")){
      evM <- eval_h(y_test, pred[[mname]], h)
      if (is.null(evM) || sum(evM$okm) < 200) next

      rmse_m <- rmse(evM$y_true[evM$okm] - evM$y_hat[evM$okm])
      rows_wpd[[length(rows_wpd)+1]] <- data.frame(
        Zona=z, Horizonte=hname, h=h, Modelo=mname,
        n_test=sum(evM$okm),
        RMSE=rmse_m, MAE=mae(evM$y_true[evM$okm]-evM$y_hat[evM$okm]),
        R2=r2_score(evM$y_true[evM$okm], evM$y_hat[evM$okm]),
        Skill_vs_Persist=skill(rmse_m, rmse_p)
      )

      if (sum(evP$ok_eh_p) > 200 && sum(evM$ok_eh) > 200){
        rmse_p_eh <- rmse(evP$Eh_true[evP$ok_eh_p] - evP$Eh_pers[evP$ok_eh_p])
        rmse_m_eh <- rmse(evM$Eh_true[evM$ok_eh] - evM$Eh_hat[evM$ok_eh])
        rows_eh[[length(rows_eh)+1]] <- data.frame(
          Zona=z, Horizonte=hname, h=h, Modelo=mname,
          n_test=sum(evM$ok_eh),
          RMSE=rmse_m_eh, MAE=mae(evM$Eh_true[evM$ok_eh]-evM$Eh_hat[evM$ok_eh]),
          R2=r2_score(evM$Eh_true[evM$ok_eh], evM$Eh_hat[evM$ok_eh]),
          Skill_vs_Persist=skill(rmse_m_eh, rmse_p_eh)
        )
      }

      # Cache para híbrido (clave): guarda vectores
      ntest <- length(y_test)
      if (ntest > h + 30){
        t_base <- t_test[1:(ntest-h)]
        y_true_wpd <- y_test[(h+1):ntest]
        y_pred_wpd <- pred[[mname]][(h+1):ntest]
        save_pred_cache("ML_BAYES", z, hname, h, mname, t_base, y_true_wpd, y_pred_wpd)
      }
    }
  }
}

TAB_WPD_B <- rbindlist(rows_wpd, fill=TRUE)
TAB_EH_B  <- rbindlist(rows_eh,  fill=TRUE)

fwrite(TAB_WPD_B, file.path(DIR_TAB_A, "ML_BAYES_TABLA_WPD.csv"))
fwrite(TAB_EH_B,  file.path(DIR_TAB_A, "ML_BAYES_TABLA_Eh.csv"))

DEF_WPD_B <- TAB_WPD_B[, choose_winner(.SD), by=.(Zona, Horizonte, h)]
DEF_EH_B  <- TAB_EH_B[,  choose_winner(.SD), by=.(Zona, Horizonte, h)]

fwrite(DEF_WPD_B, file.path(DIR_TAB_D, "ML_BAYES_DEFINITIVA_WPD.csv"))
fwrite(DEF_EH_B,  file.path(DIR_TAB_D, "ML_BAYES_DEFINITIVA_Eh.csv"))

if (length(params_xgb) > 0) fwrite(rbindlist(params_xgb, fill=TRUE), file.path(DIR_TAB_A, "ML_BAYES_PARAMS_XGB.csv"))
if (length(params_rf)  > 0) fwrite(rbindlist(params_rf,  fill=TRUE), file.path(DIR_TAB_A, "ML_BAYES_PARAMS_RF.csv"))

logi("OK ML_BAYES (tablas + pred cache).")

# ============================================================
# ====== 4) FIGURAS PUBLICABLES (GANADORES) + ANEXOS
#  - Documento principal: solo ganadores (ML_BAYES por defecto)
#  - Anexos: ganadores + (opcional) algunos adicionales
# ============================================================

logi("START FIGURAS")

# Elegimos ganador final por zona/horizonte usando ML_BAYES_DEFINITIVA_Eh (target final)
# y si no existe esa combinación, cae a CLASICOS o ML_BASE.
pick_final_winner <- function(zona, h){
  # prioridad: ML_BAYES -> ML_BASE -> CLASICOS
  if (nrow(DEF_EH_B[Zona==zona & h==h]) > 0) return(list(grp="ML_BAYES", model=DEF_EH_B[Zona==zona & h==h]$Modelo[1]))
  if (exists("DEF_EH_M") && nrow(DEF_EH_M[Zona==zona & h==h]) > 0) return(list(grp="ML_BASE", model=DEF_EH_M[Zona==zona & h==h]$Modelo[1]))
  if (nrow(DEF_EH_C[Zona==zona & h==h]) > 0) return(list(grp="CLASICOS", model=DEF_EH_C[Zona==zona & h==h]$Modelo[1]))
  list(grp="CLASICOS", model="Persistencia")
}

# Cargar un cache específico (grupo/modelo/zona/h)
read_cache <- function(grp, model, zona, h){
  f <- file.path(DIR_PRED, paste0("Z", zona), paste0("H_", h), paste0(grp, "__", model, "__", names(HORIZONS)[match(h, HORIZONS)], ".csv"))
  # fallback: buscar por patrón si el nombre exacto no cuadra
  if (!file.exists(f)){
    fdir <- file.path(DIR_PRED, paste0("Z", zona), paste0("H_", h))
    if (!dir.exists(fdir)) return(NULL)
    patt <- paste0("^", grp, "__", model, "__")
    ff <- list.files(fdir, pattern=patt, full.names=TRUE)
    if (length(ff) == 0) return(NULL)
    f <- ff[1]
  }
  fread(f)
}

# Para cada zona, hacemos figuras Eh para h = 1,12,72 (las mismas comparables)
for (z in zones){
  for (hname in names(HORIZONS)){
    h <- HORIZONS[[hname]]
    win <- pick_final_winner(z, h)

    # leer cache ganador
    fdir <- file.path(DIR_PRED, paste0("Z", z), paste0("H_", h))
    # buscamos archivo exacto en carpeta por patrón
    patt <- paste0("^", win$grp, "__", win$model, "__", hname, "\\.csv$")
    ff <- list.files(fdir, pattern=patt, full.names=TRUE)
    if (length(ff) == 0) next
    dtp <- fread(ff[1])

    # Usamos Eh_true/Eh_pred
    ok <- is.finite(dtp$Eh_true) & is.finite(dtp$Eh_pred) & !is.na(dtp$Fecha)
    if (sum(ok) < 300) next

    dfp <- make_pub_df(dtp$Fecha[ok], dtp$Eh_true[ok], dtp$Eh_pred[ok], MAX_POINTS, USE_LOG1P)

    ttl <- paste0("Zona ", z, " - E_h (", h, "h)")
    sub <- paste0("Ganador: ", win$grp, " / ", win$model, if (USE_LOG1P) " | log(1+E_h)" else "")
    ylab <- if (USE_LOG1P) "log(1+Eh) (Wh/m^2)" else "Eh (Wh/m^2)"

    # Documento principal: Nature + Elsevier (dos versiones)
    foutN <- file.path(DIR_FIG_N, paste0("NATURE_Eh_Z", z, "_", hname, ".png"))
    foutE <- file.path(DIR_FIG_E, paste0("ELSEVIER_Eh_Z", z, "_", hname, ".png"))
    plot_pub(dfp, ttl, sub, ylab, foutN, style="nature")
    plot_pub(dfp, ttl, sub, ylab, foutE, style="elsevier")

    # Anexos: guardamos también la versión Nature (y puedes ampliar luego)
    foutA <- file.path(DIR_FIG_A, paste0("ANEXO_Eh_Z", z, "_", hname, "_", win$grp, "_", win$model, ".png"))
    plot_pub(dfp, ttl, sub, ylab, foutA, style="nature")

    logi("FIG OK | Z", z, hname, "->", basename(foutN))
  }
}

logi("LISTO: tablas, pred cache y figuras publicables.")
logi("PRED_CACHE para híbrido TDQ en:", DIR_PRED)
logi("DOC_PRINCIPAL en:", DIR_DOC)
logi("ANEXOS en:", DIR_ANX)
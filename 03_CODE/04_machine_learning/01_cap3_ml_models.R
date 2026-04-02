# ============================================================
# 01_cap3_ml_models.R
# CAPÍTULO 3 - MACHINE LEARNING (RF + XGB + BAYES)
# Tesis doctoral - Favio Nicolás Rosero Rodríguez
# ============================================================

rm(list = ls())
gc()

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
  library(ggplot2)
  library(ranger)
  library(xgboost)
  library(rBayesianOptimization)
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

OUT_DIR <- file.path(BASE_DIR, "SALIDAS_CAP3_ML")
DIR_DOC   <- file.path(OUT_DIR, "DOC_PRINCIPAL")
DIR_ANX   <- file.path(OUT_DIR, "ANEXOS")
DIR_PRED  <- file.path(OUT_DIR, "PRED_CACHE")
DIR_FIG_N <- file.path(DIR_DOC, "FIG_NATURE")
DIR_FIG_E <- file.path(DIR_DOC, "FIG_ELSEVIER")
DIR_FIG_A <- file.path(DIR_ANX, "FIGS")
DIR_TAB_D <- file.path(DIR_DOC, "TABLAS")
DIR_TAB_A <- file.path(DIR_ANX, "TABLAS")
DIR_BAYES <- file.path(OUT_DIR, "BAYES")
LOG_FILE  <- file.path(OUT_DIR, "CAP3_ML_LOG.txt")

for (d in c(OUT_DIR, DIR_DOC, DIR_ANX, DIR_PRED, DIR_FIG_N, DIR_FIG_E, DIR_FIG_A, DIR_TAB_D, DIR_TAB_A, DIR_BAYES)) {
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

MIN_ZONE_ROWS_ML  <- 2500
MIN_TRAIN_ROWS_ML <- 1500
MIN_CC_TR <- 800
MIN_CC_TE <- 300

TREE_METHOD <- "hist"
NROUNDS_XGB_BASE <- 800
MAX_NROUNDS <- 1800
EARLY_STOP  <- 40

INIT_POINTS_ML <- 6
N_ITER_ML      <- 8
N_FOLDS  <- 4
VAL_SIZE <- 1200
GAP      <- 0
MIN_FOLD_OK <- 2

OPT_TARGET <- "Eh"
OPT_H      <- 12L

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
  if (is.null(dt)) dt <- fread(path, header = TRUE, data.table = TRUE, showProgress = TRUE, encoding = "UTF-8")
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
    okm = okm,
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

plot_pub <- function(dfp, title, subtitle, ylab_txt, file_out, style = c("nature", "elsevier")) {
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
  dir.create(fdir, showWarnings = FALSE, recursive = TRUE)
  fout <- file.path(fdir, paste0(model_group, "__", model, "__", hname, ".csv"))
  fwrite(out, fout)
  invisible(fout)
}

add_features <- function(dz) {
  dz <- copy(dz)

  dz[, `:=`(
    hour  = hour(FechaHora),
    wday  = wday(FechaHora, week_start = 1),
    month = month(FechaHora)
  )]

  for (L in c(1, 2, 3, 6, 12, 24, 48, 72)) {
    dz[, paste0("WPD_lag", L) := shift(WPD, L)]
  }
  dz[, WPD_roll24 := frollmean(WPD, 24, align = "right", na.rm = TRUE)]

  if ("VV" %in% names(dz)) {
    for (L in c(1, 2, 3, 6, 12, 24, 48, 72)) {
      dz[, paste0("VV_lag", L) := shift(VV, L)]
    }
    dz[, VV_roll24 := frollmean(VV, 24, align = "right", na.rm = TRUE)]
  }

  if ("rho" %in% names(dz)) {
    for (L in c(1, 2, 3, 6, 12, 24, 48, 72)) {
      dz[, paste0("rho_lag", L) := shift(rho, L)]
    }
    dz[, rho_roll24 := frollmean(rho, 24, align = "right", na.rm = TRUE)]
  }

  dz
}

make_time_folds <- function(n, n_folds = 4, val_size = 1200, gap = 0) {
  folds <- list()
  if (!is.finite(n) || n < 800) return(folds)

  val_size <- min(val_size, floor(0.20 * n))
  val_size <- max(val_size, 300)

  for (k in seq_len(n_folds)) {
    val_end   <- n - (k - 1) * val_size
    val_start <- val_end - val_size + 1
    if (val_start <= 250) break

    tr_end <- val_start - 1 - gap
    if (tr_end <= 250) break

    folds[[length(folds) + 1]] <- list(tr = 1:tr_end, va = val_start:val_end)
  }

  rev(folds)
}

score_skill_fold <- function(y_va, yhat_va, h, target = c("WPD", "Eh")) {
  target <- match.arg(target)

  if (length(y_va) <= h + 30) return(NA_real_)

  y_true <- y_va[(h + 1):length(y_va)]
  y_pers <- y_va[1:(length(y_va) - h)]
  yhat_h <- yhat_va[(h + 1):length(y_va)]

  if (target == "Eh") {
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

safe_bestpar <- function(bo) {
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

get_num <- function(lst, key, default) {
  if (is.null(lst)) return(default)
  v <- lst[[key]]
  if (is.null(v)) return(default)
  v <- suppressWarnings(as.numeric(v))
  if (!is.finite(v)) return(default)
  v
}

get_int <- function(lst, key, default) {
  as.integer(round(get_num(lst, key, default)))
}

# ============================================================
# 5. LECTURA DEL CACHE HORARIO
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
# 6. FUNCIONES DE MODELOS ML
# ============================================================

fit_rf_predict <- function(train_dt, test_dt, feature_cols, target_col,
                           num.trees = 700, mtry = NULL, min.node.size = 5, sample.fraction = 0.80) {
  tr <- train_dt[, c(feature_cols, target_col), with = FALSE]
  te <- test_dt[, c(feature_cols, target_col), with = FALSE]

  tr <- tr[complete.cases(tr)]
  te <- te[complete.cases(te)]

  if (nrow(tr) < MIN_CC_TR || nrow(te) < MIN_CC_TE) {
    return(rep(NA_real_, nrow(test_dt)))
  }

  if (is.null(mtry)) {
    mtry <- max(1, floor(sqrt(length(feature_cols))))
  }

  fit <- ranger::ranger(
    formula = as.formula(paste(target_col, "~ .")),
    data = tr,
    num.trees = as.integer(num.trees),
    mtry = as.integer(mtry),
    min.node.size = as.integer(min.node.size),
    sample.fraction = sample.fraction,
    seed = SEED
  )

  pred_full <- rep(NA_real_, nrow(test_dt))
  idx_te <- which(complete.cases(te))
  pred_full[which(complete.cases(test_dt[, c(feature_cols, target_col), with = FALSE]))] <- as.numeric(predict(fit, data = te)$predictions)
  pred_full
}

fit_xgb_predict <- function(train_dt, test_dt, feature_cols, target_col,
                            eta = 0.05, max_depth = 6, min_child_weight = 3,
                            subsample = 0.80, colsample_bytree = 0.80,
                            nrounds = NROUNDS_XGB_BASE) {
  tr <- train_dt[, c(feature_cols, target_col), with = FALSE]
  te <- test_dt[, c(feature_cols, target_col), with = FALSE]

  tr <- tr[complete.cases(tr)]
  te <- te[complete.cases(te)]

  if (nrow(tr) < MIN_CC_TR || nrow(te) < MIN_CC_TE) {
    return(rep(NA_real_, nrow(test_dt)))
  }

  dtrain <- xgb.DMatrix(data = as.matrix(tr[, ..feature_cols]), label = tr[[target_col]])
  dtest  <- xgb.DMatrix(data = as.matrix(te[, ..feature_cols]), label = te[[target_col]])

  fit <- xgboost::xgb.train(
    params = list(
      objective = "reg:squarederror",
      eta = eta,
      max_depth = as.integer(max_depth),
      min_child_weight = min_child_weight,
      subsample = subsample,
      colsample_bytree = colsample_bytree,
      tree_method = TREE_METHOD,
      eval_metric = "rmse"
    ),
    data = dtrain,
    nrounds = as.integer(nrounds),
    watchlist = list(train = dtrain, eval = dtest),
    early_stopping_rounds = EARLY_STOP,
    verbose = 0
  )

  pred_full <- rep(NA_real_, nrow(test_dt))
  idx_map <- which(complete.cases(test_dt[, c(feature_cols, target_col), with = FALSE]))
  pred_full[idx_map] <- as.numeric(predict(fit, newdata = dtest))
  pred_full
}

bayes_rf <- function(train_dt, feature_cols, target_col, h, target_eval = "Eh", zona, hname) {
  folds <- make_time_folds(nrow(train_dt), n_folds = N_FOLDS, val_size = VAL_SIZE, gap = GAP)
  if (length(folds) < MIN_FOLD_OK) return(NULL)

  FUN <- function(mtry, min_node_size, sample_fraction) {
    vals <- c()

    for (fd in folds) {
      tr <- train_dt[fd$tr]
      va <- train_dt[fd$va]

      pred <- fit_rf_predict(
        train_dt = tr,
        test_dt = va,
        feature_cols = feature_cols,
        target_col = target_col,
        num.trees = 700,
        mtry = as.integer(round(mtry)),
        min.node.size = as.integer(round(min_node_size)),
        sample.fraction = sample_fraction
      )

      sc <- score_skill_fold(va[[target_col]], pred, h = h, target = target_eval)
      vals <- c(vals, sc)
    }

    list(Score = mean(vals, na.rm = TRUE))
  }

  bo <- tryCatch(
    BayesianOptimization(
      FUN = FUN,
      bounds = list(
        mtry = c(2L, max(2L, min(length(feature_cols), 20L))),
        min_node_size = c(2L, 20L),
        sample_fraction = c(0.55, 0.95)
      ),
      init_points = INIT_POINTS_ML,
      n_iter = N_ITER_ML,
      verbose = FALSE
    ),
    error = function(e) NULL
  )

  if (!is.null(bo) && !is.null(bo$History)) {
    fwrite(as.data.table(bo$History),
           file.path(DIR_BAYES, sprintf("BAYES_RF_Z%d_%s.csv", zona, hname)))
  }

  safe_bestpar(bo)
}

bayes_xgb <- function(train_dt, feature_cols, target_col, h, target_eval = "Eh", zona, hname) {
  folds <- make_time_folds(nrow(train_dt), n_folds = N_FOLDS, val_size = VAL_SIZE, gap = GAP)
  if (length(folds) < MIN_FOLD_OK) return(NULL)

  FUN <- function(eta, max_depth, min_child_weight, subsample, colsample_bytree, nrounds) {
    vals <- c()

    for (fd in folds) {
      tr <- train_dt[fd$tr]
      va <- train_dt[fd$va]

      pred <- fit_xgb_predict(
        train_dt = tr,
        test_dt = va,
        feature_cols = feature_cols,
        target_col = target_col,
        eta = eta,
        max_depth = as.integer(round(max_depth)),
        min_child_weight = min_child_weight,
        subsample = subsample,
        colsample_bytree = colsample_bytree,
        nrounds = as.integer(round(nrounds))
      )

      sc <- score_skill_fold(va[[target_col]], pred, h = h, target = target_eval)
      vals <- c(vals, sc)
    }

    list(Score = mean(vals, na.rm = TRUE))
  }

  bo <- tryCatch(
    BayesianOptimization(
      FUN = FUN,
      bounds = list(
        eta = c(0.01, 0.20),
        max_depth = c(3L, 10L),
        min_child_weight = c(1, 10),
        subsample = c(0.55, 0.95),
        colsample_bytree = c(0.55, 0.95),
        nrounds = c(300L, MAX_NROUNDS)
      ),
      init_points = INIT_POINTS_ML,
      n_iter = N_ITER_ML,
      verbose = FALSE
    ),
    error = function(e) NULL
  )

  if (!is.null(bo) && !is.null(bo$History)) {
    fwrite(as.data.table(bo$History),
           file.path(DIR_BAYES, sprintf("BAYES_XGB_Z%d_%s.csv", zona, hname)))
  }

  safe_bestpar(bo)
}

# ============================================================
# 7. PIPELINE ML
# ============================================================

rows_wpd <- list()
rows_eh  <- list()

for (z in zones) {

  logi("ML | ZONA", z)

  dz0 <- hourly[Zona == z][order(FechaHora)]
  dz0 <- dz0[is.finite(WPD)]

  if (nrow(dz0) < MIN_ZONE_ROWS_ML) {
    logi("Zona", z, "omitida por tamaño insuficiente:", nrow(dz0))
    next
  }

  dz0 <- add_features(dz0)

  for (hname in names(HORIZONS)) {

    h <- HORIZONS[[hname]]
    logi("ML | Zona", z, "| Horizonte", hname, "| h =", h)

    dz <- copy(dz0)
    dz[, y := shift(WPD, type = "lead", n = h)]

    feature_cols <- setdiff(names(dz), c("Zona", "FechaHora", "y"))
    feature_cols <- feature_cols[sapply(dz[, ..feature_cols], is.numeric)]

    dz <- dz[complete.cases(dz[, c(feature_cols, "y"), with = FALSE])]

    if (nrow(dz) < MIN_ZONE_ROWS_ML) {
      logi("Zona", z, "|", hname, "omitido por tamaño post-feature:", nrow(dz))
      next
    }

    n0 <- nrow(dz)
    ntr0 <- floor(TRAIN_FRAC * n0)

    if (!is.finite(ntr0) || ntr0 < MIN_TRAIN_ROWS_ML) {
      logi("Zona", z, "|", hname, "omitido por train insuficiente:", ntr0)
      next
    }

    train0 <- dz[1:ntr0]
    test0  <- dz[(ntr0 + 1):n0]

    y_test0 <- test0$y
    t_test0 <- test0$FechaHora

    # --------------------------------------------------------
    # Base models
    # --------------------------------------------------------
    pred_rf_base <- fit_rf_predict(
      train_dt = train0,
      test_dt = test0,
      feature_cols = feature_cols,
      target_col = "y",
      num.trees = 700
    )

    pred_xgb_base <- fit_xgb_predict(
      train_dt = train0,
      test_dt = test0,
      feature_cols = feature_cols,
      target_col = "y",
      eta = 0.05,
      max_depth = 6,
      min_child_weight = 3,
      subsample = 0.80,
      colsample_bytree = 0.80,
      nrounds = NROUNDS_XGB_BASE
    )

    # --------------------------------------------------------
    # Bayesian models
    # --------------------------------------------------------
    rf_bp <- bayes_rf(
      train_dt = train0,
      feature_cols = feature_cols,
      target_col = "y",
      h = h,
      target_eval = OPT_TARGET,
      zona = z,
      hname = hname
    )

    pred_rf_bayes <- if (is.null(rf_bp)) {
      rep(NA_real_, nrow(test0))
    } else {
      fit_rf_predict(
        train_dt = train0,
        test_dt = test0,
        feature_cols = feature_cols,
        target_col = "y",
        num.trees = 800,
        mtry = get_int(rf_bp, "mtry", max(1, floor(sqrt(length(feature_cols))))),
        min.node.size = get_int(rf_bp, "min_node_size", 5),
        sample.fraction = get_num(rf_bp, "sample_fraction", 0.80)
      )
    }

    xgb_bp <- bayes_xgb(
      train_dt = train0,
      feature_cols = feature_cols,
      target_col = "y",
      h = h,
      target_eval = OPT_TARGET,
      zona = z,
      hname = hname
    )

    pred_xgb_bayes <- if (is.null(xgb_bp)) {
      rep(NA_real_, nrow(test0))
    } else {
      fit_xgb_predict(
        train_dt = train0,
        test_dt = test0,
        feature_cols = feature_cols,
        target_col = "y",
        eta = get_num(xgb_bp, "eta", 0.05),
        max_depth = get_int(xgb_bp, "max_depth", 6),
        min_child_weight = get_num(xgb_bp, "min_child_weight", 3),
        subsample = get_num(xgb_bp, "subsample", 0.80),
        colsample_bytree = get_num(xgb_bp, "colsample_bytree", 0.80),
        nrounds = get_int(xgb_bp, "nrounds", NROUNDS_XGB_BASE)
      )
    }

    pred_ml <- list(
      RF_BASE = pred_rf_base,
      XGB_BASE = pred_xgb_base,
      RF_BAYES = pred_rf_bayes,
      XGB_BAYES = pred_xgb_bayes
    )

    # --------------------------------------------------------
    # Evaluación contra persistencia
    # --------------------------------------------------------
    for (mname in names(pred_ml)) {
      evP <- eval_h(y_test0, y_test0, h)
      evM <- eval_h(y_test0, pred_ml[[mname]], h)

      if (is.null(evP) || is.null(evM) || sum(evM$okm) < 200) next

      rmse_p <- rmse(evP$y_true - evP$y_pers)
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

      n <- length(y_test0)
      if (n > h + 30) {
        t_base <- t_test0[1:(n - h)]
        y_true_wpd <- y_test0[(h + 1):n]
        y_pred_wpd <- pred_ml[[mname]][(h + 1):n]

        group_name <- if (grepl("BAYES", mname)) "ML_BAYES" else "ML_BASE"
        save_pred_cache(group_name, z, hname, h, mname, t_base, y_true_wpd, y_pred_wpd)
      }
    }
  }
}

# ============================================================
# 8. TABLAS FINALES
# ============================================================

TAB_WPD_ML <- rbindlist(rows_wpd, fill = TRUE)
TAB_EH_ML  <- rbindlist(rows_eh, fill = TRUE)

fwrite(TAB_WPD_ML, file.path(DIR_TAB_D, "CAP3_ML_WPD.csv"))
fwrite(TAB_EH_ML,  file.path(DIR_TAB_D, "CAP3_ML_EH.csv"))

fwrite(TAB_WPD_ML, file.path(DIR_TAB_A, "CAP3_ML_WPD_COMPLETO.csv"))
fwrite(TAB_EH_ML,  file.path(DIR_TAB_A, "CAP3_ML_EH_COMPLETO.csv"))

WINNERS_WPD <- TAB_WPD_ML[, choose_winner(.SD), by = .(Zona, Horizonte)]
WINNERS_EH  <- TAB_EH_ML[, choose_winner(.SD), by = .(Zona, Horizonte)]

fwrite(WINNERS_WPD, file.path(DIR_TAB_D, "CAP3_ML_WPD_GANADORES.csv"))
fwrite(WINNERS_EH,  file.path(DIR_TAB_D, "CAP3_ML_EH_GANADORES.csv"))

# ============================================================
# 9. FIGURAS PUBLICABLES DE GANADORES
# ============================================================

for (i in seq_len(nrow(WINNERS_WPD))) {
  rw <- WINNERS_WPD[i]

  group_name <- if (grepl("BAYES", rw$Modelo)) "ML_BAYES" else "ML_BASE"

  fcache <- file.path(
    DIR_PRED,
    paste0("Z", rw$Zona),
    paste0("H_", rw$h),
    paste0(group_name, "__", rw$Modelo, "__", rw$Horizonte, ".csv")
  )

  if (!file.exists(fcache)) next

  P <- fread(fcache)
  if (!all(c("Fecha", "WPD_true", "WPD_pred", "Eh_true", "Eh_pred") %in% names(P))) next

  P[, Fecha := as.POSIXct(Fecha, tz = TZ_LOCAL)]

  df_wpd <- make_pub_df(P$Fecha, P$WPD_true, P$WPD_pred, max_points = MAX_POINTS, use_log1p = USE_LOG1P)
  df_eh  <- make_pub_df(P$Fecha, P$Eh_true,  P$Eh_pred,  max_points = MAX_POINTS, use_log1p = USE_LOG1P)

  fout_n_wpd <- file.path(DIR_FIG_N, sprintf("ML_WPD_Z%d_%s_%s.png", rw$Zona, rw$Horizonte, rw$Modelo))
  fout_e_wpd <- file.path(DIR_FIG_E, sprintf("ML_WPD_Z%d_%s_%s.png", rw$Zona, rw$Horizonte, rw$Modelo))
  fout_n_eh  <- file.path(DIR_FIG_N, sprintf("ML_EH_Z%d_%s_%s.png",  rw$Zona, rw$Horizonte, rw$Modelo))
  fout_e_eh  <- file.path(DIR_FIG_E, sprintf("ML_EH_Z%d_%s_%s.png",  rw$Zona, rw$Horizonte, rw$Modelo))

  plot_pub(
    df_wpd,
    title = sprintf("WPD | Zona %d | %s", rw$Zona, rw$Horizonte),
    subtitle = sprintf("Modelo ML ganador: %s", rw$Modelo),
    ylab_txt = ifelse(USE_LOG1P, "log(1 + WPD)", "WPD"),
    file_out = fout_n_wpd,
    style = "nature"
  )

  plot_pub(
    df_wpd,
    title = sprintf("WPD | Zona %d | %s", rw$Zona, rw$Horizonte),
    subtitle = sprintf("Modelo ML ganador: %s", rw$Modelo),
    ylab_txt = ifelse(USE_LOG1P, "log(1 + WPD)", "WPD"),
    file_out = fout_e_wpd,
    style = "elsevier"
  )

  plot_pub(
    df_eh,
    title = sprintf("Eh | Zona %d | %s", rw$Zona, rw$Horizonte),
    subtitle = sprintf("Modelo ML ganador: %s", rw$Modelo),
    ylab_txt = ifelse(USE_LOG1P, "log(1 + Eh)", "Eh"),
    file_out = fout_n_eh,
    style = "nature"
  )

  plot_pub(
    df_eh,
    title = sprintf("Eh | Zona %d | %s", rw$Zona, rw$Horizonte),
    subtitle = sprintf("Modelo ML ganador: %s", rw$Modelo),
    ylab_txt = ifelse(USE_LOG1P, "log(1 + Eh)", "Eh"),
    file_out = fout_e_eh,
    style = "elsevier"
  )
}

# ============================================================
# 10. SESSION INFO
# ============================================================

writeLines(capture.output(sessionInfo()), file.path(OUT_DIR, "MASTER_sessionInfo.txt"))

# ============================================================
# 11. CIERRE
# ============================================================

logi("CAP3 ML completado.")
logi("Tablas documento:", DIR_TAB_D)
logi("Tablas anexos:", DIR_TAB_A)
logi("Pred cache:", DIR_PRED)
logi("Bayes logs:", DIR_BAYES)
logi("Figuras Nature:", DIR_FIG_N)
logi("Figuras Elsevier:", DIR_FIG_E)

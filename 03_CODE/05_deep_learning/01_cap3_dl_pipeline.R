# ============================================================
# 01_cap3_dl_pipeline.R
# CAPÍTULO 3 - DEEP LEARNING (LSTM_ONLY + LSTM_TDQ_BAYES)
# Tesis doctoral - Favio Nicolás Rosero Rodríguez
# ============================================================

rm(list = ls())
gc()

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(tensorflow)
})

Sys.setenv(TF_CPP_MIN_LOG_LEVEL = "2")

# ============================================================
# 1. RUTA OFICIAL UNIFICADA
# ============================================================

BASE_FILE <- "H:/Mi unidad/Academia/UNAL/DOCTORADO/Cierre Tesis/Datos.txt"
stopifnot(file.exists(BASE_FILE))

BASE_DIR <- dirname(BASE_FILE)

CACHE_FILE <- file.path(
  BASE_DIR, "SALIDAS_PREPROCESSING", "02_WPD_CACHE", "WPD_hourly_por_zona.csv"
)

OUT_DIR <- file.path(BASE_DIR, "SALIDAS_CAP3_DL")
DIR_TABLAS <- file.path(OUT_DIR, "TABLAS")
DIR_PREDS  <- file.path(OUT_DIR, "PREDICCIONES")
DIR_MODELS <- file.path(OUT_DIR, "MODELOS")
DIR_PUB    <- file.path(OUT_DIR, "FIG_PUBLICABLE")
DIR_ANEX   <- file.path(OUT_DIR, "FIG_ANEXOS")
LOG_FILE   <- file.path(OUT_DIR, "DL_LOG.txt")

for (d in c(OUT_DIR, DIR_TABLAS, DIR_PREDS, DIR_MODELS, DIR_PUB, DIR_ANEX)) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

# ============================================================
# 2. CONFIGURACIÓN
# ============================================================

CFG <- list(
  mode = "DL_TDQ_BAYES",   # "DL_ONLY" o "DL_TDQ_BAYES"

  input_file = CACHE_FILE,
  out_dir    = OUT_DIR,
  seed       = 123,

  horizons = data.table(Horizonte = c("Corto", "Medio", "Largo"),
                        h = c(1L, 12L, 72L)),

  lookback_map = list(
    Corto = 48L,
    Medio = 168L,
    Largo = 336L
  ),

  stride_map = list(
    Corto = 2L,
    Medio = 4L,
    Largo = 8L
  ),

  test_frac = 0.15,
  val_frac  = 0.15,

  max_windows_total = 20000L,
  max_train_rows    = 60000L,
  max_val_windows   = 5000L,
  max_test_windows  = 5000L,

  epochs   = 28L,
  patience = 5L,
  batch_candidates = c(256L, 512L),

  base_hp = list(
    units1 = 64L,
    units2 = 32L,
    dropout = 0.15,
    lr = 1e-3,
    batch = 512L
  ),

  tune_zone = 2L,
  xfer_zone = 3L,
  bayes_init = 3L,
  bayes_iter = 8L,
  topk_transfer = 2L,

  units1_grid = c(32L, 64L, 96L, 128L),
  units2_grid = c(16L, 32L, 48L, 64L),
  dropout_min = 0.05,
  dropout_max = 0.35,
  lr_min = 3e-4,
  lr_max = 3e-3,

  tz_read = "America/Bogota"
)

# ============================================================
# 3. FUNCIONES AUXILIARES
# ============================================================

logi <- function(...) {
  msg <- paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "|", paste(..., collapse = " "))
  cat(msg, "\n")
  cat(msg, "\n", file = LOG_FILE, append = TRUE)
}

normp <- function(p) {
  p <- gsub("\\\\", "/", p)
  gsub("/+$", "", p)
}

as_tensor32 <- function(x, name = "x") {
  storage.mode(x) <- "double"
  if (any(!is.finite(x))) {
    stop(sprintf("[DATA ERROR] %s contiene NA/Inf.", name))
  }
  tf$convert_to_tensor(x, dtype = tf$float32)
}

scale_fit <- function(x) {
  mu <- mean(x, na.rm = TRUE)
  sdv <- sd(x, na.rm = TRUE)
  if (!is.finite(sdv) || sdv == 0) sdv <- 1
  list(mu = mu, sd = sdv)
}

scale_apply <- function(x, fit) {
  (x - fit$mu) / fit$sd
}

rmse <- function(y, yh) sqrt(mean((y - yh)^2, na.rm = TRUE))
mae  <- function(y, yh) mean(abs(y - yh), na.rm = TRUE)

safe_r2 <- function(y, yh) {
  ok <- is.finite(y) & is.finite(yh)
  y  <- y[ok]
  yh <- yh[ok]

  if (length(y) < 3) return(NA_real_)

  sst <- sum((y - mean(y))^2)
  sse <- sum((y - yh)^2)

  if (!is.finite(sst) || sst <= 0) return(NA_real_)

  r2 <- 1 - sse / sst
  max(min(r2, 1), -Inf)
}

persistence_pred <- function(y, lag_steps = 1L) {
  yh <- rep(NA_real_, length(y))
  if (lag_steps < length(y)) {
    yh[(lag_steps + 1):length(y)] <- y[1:(length(y) - lag_steps)]
  }
  yh
}

calc_Eh <- function(x, h) {
  if (length(x) < h) return(rep(NA_real_, length(x)))
  as.numeric(stats::filter(x, rep(1, h), sides = 1))
}

`%||%` <- function(a, b) if (is.null(a)) b else a

hp_to_row <- function(horizonte, h, hp) {
  data.table(
    Horizonte   = as.character(horizonte),
    h           = as.integer(h),
    units1      = as.integer(hp$units1 %||% NA_integer_),
    units2      = as.integer(hp$units2 %||% NA_integer_),
    dropout     = as.numeric(hp$dropout %||% NA_real_),
    lr          = as.numeric(hp$lr %||% NA_real_),
    batch       = as.integer(hp$batch %||% NA_integer_),
    note        = as.character(hp$note %||% ""),
    tuning_file = as.character(hp$tuning_file %||% "")
  )
}

make_windows <- function(y, time, lookback, h, stride) {
  n <- length(y)
  last_t <- n - h
  if (last_t <= lookback) return(NULL)

  t_idx <- seq.int(from = lookback, to = last_t, by = stride)
  m <- length(t_idx)
  if (m < 250) return(NULL)

  X  <- array(0, dim = c(m, lookback, 1))
  yt <- numeric(m)
  tt <- as.POSIXct(rep(NA, m), origin = "1970-01-01", tz = "UTC")

  for (i in seq_len(m)) {
    t <- t_idx[i]
    X[i, , 1] <- y[(t - lookback + 1):t]
    yt[i] <- y[t + h]
    tt[i] <- time[t + h]
  }

  ok <- is.finite(yt) &
    is.finite(as.numeric(tt)) &
    apply(X, 1, function(v) all(is.finite(v)))

  if (!any(ok)) return(NULL)

  X  <- X[ok, , , drop = FALSE]
  yt <- yt[ok]
  tt <- tt[ok]

  if (dim(X)[1] > CFG$max_windows_total) {
    idx <- sort(sample.int(dim(X)[1], CFG$max_windows_total))
    X  <- X[idx, , , drop = FALSE]
    yt <- yt[idx]
    tt <- tt[idx]
  }

  list(X = X, y = yt, t = tt)
}

make_dataset <- function(X, y, batch) {
  tf$data$Dataset$from_tensor_slices(tuple(X, y))$
    batch(as.integer(batch))$
    prefetch(tf$data$AUTOTUNE)
}

build_model <- function(lookback, units1, units2, dropout, lr) {
  k <- tf$keras

  inputs <- k$Input(shape = tuple(as.integer(lookback), 1L))
  x <- k$layers$LSTM(units = as.integer(units1), return_sequences = TRUE)(inputs)
  x <- k$layers$Dropout(rate = dropout)(x)
  x <- k$layers$LSTM(units = as.integer(units2), return_sequences = FALSE)(x)
  x <- k$layers$Dropout(rate = dropout)(x)
  outputs <- k$layers$Dense(units = 1L, activation = "linear")(x)

  model <- k$Model(inputs = inputs, outputs = outputs)
  model$compile(
    optimizer = k$optimizers$Adam(learning_rate = lr),
    loss = "mse",
    metrics = list("mae")
  )
  model
}

run_train <- function(d, hp) {
  k <- tf$keras
  k$backend$clear_session()
  gc()

  model <- build_model(
    lookback = d$lookback,
    units1 = hp$units1,
    units2 = hp$units2,
    dropout = hp$dropout,
    lr = hp$lr
  )

  cb_early <- k$callbacks$EarlyStopping(
    monitor = "val_loss",
    patience = CFG$patience,
    restore_best_weights = TRUE
  )

  cb_lr <- k$callbacks$ReduceLROnPlateau(
    monitor = "val_loss",
    factor = 0.5,
    patience = 2L,
    min_lr = 1e-5
  )

  ds_tr <- make_dataset(d$X_train_t, d$y_train_t, hp$batch)
  ds_va <- make_dataset(d$X_val_t,   d$y_val_t,   hp$batch)

  hist <- model$fit(
    ds_tr,
    validation_data = ds_va,
    epochs = as.integer(CFG$epochs),
    verbose = 0L,
    callbacks = list(cb_early, cb_lr)
  )

  list(
    model = model,
    hist = hist,
    best_val = min(as.numeric(hist$history$val_loss))
  )
}

theme_pub <- function() {
  theme_classic(base_size = 11) +
    theme(
      plot.title = element_text(face = "bold"),
      axis.title = element_text(face = "bold"),
      legend.position = "top",
      legend.title = element_blank()
    )
}

plot_pub_series <- function(df, file_png, title_txt) {
  p <- ggplot(df, aes(x = Fecha)) +
    geom_line(aes(y = Actual, linetype = "Actual")) +
    geom_line(aes(y = Pred,   linetype = "Predicción")) +
    labs(title = title_txt, x = NULL, y = NULL) +
    theme_pub()

  ggsave(file_png, p, width = 8.2, height = 3.2, dpi = 300)
}

plot_pub_resid <- function(df, file_png, title_txt) {
  p <- ggplot(df, aes(x = Fecha, y = Resid)) +
    geom_hline(yintercept = 0) +
    geom_line() +
    labs(title = title_txt, x = NULL, y = "Residuo") +
    theme_pub()

  ggsave(file_png, p, width = 8.2, height = 3.0, dpi = 300)
}

plot_anexo_curve <- function(hist, file_png, title_txt) {
  loss <- as.numeric(hist$history$loss)
  val_loss <- as.numeric(hist$history$val_loss)

  df <- data.table(
    epoch = seq_along(loss),
    loss = loss,
    val_loss = val_loss
  )

  p <- ggplot(df, aes(epoch)) +
    geom_line(aes(y = loss)) +
    geom_line(aes(y = val_loss)) +
    labs(title = title_txt, x = "Epoch", y = "Loss (MSE)") +
    theme_classic(base_size = 10)

  ggsave(file_png, p, width = 7, height = 4, dpi = 160)
}

prep_combo <- function(dt, z, horizonte, h, lookback, stride) {
  dzone <- dt[Zona == z, .(FechaHora, y = WPD)]
  dzone <- dzone[is.finite(y)]
  setorder(dzone, FechaHora)

  if (nrow(dzone) < 800) return(NULL)

  win <- make_windows(dzone$y, dzone$FechaHora, lookback, h, stride)
  if (is.null(win)) return(NULL)

  X  <- win$X
  y  <- win$y
  tt <- win$t
  n  <- length(y)

  n_test  <- max(1L, floor(n * CFG$test_frac))
  n_val   <- max(1L, floor(n * CFG$val_frac))
  n_train <- n - n_test - n_val

  if (n_train < 300) return(NULL)

  if (n_train > CFG$max_train_rows) {
    shift <- n_train - CFG$max_train_rows
    train_idx <- (1L + shift):n_train
  } else {
    train_idx <- 1L:n_train
  }

  val_idx  <- (n_train + 1L):(n_train + n_val)
  test_idx <- (n_train + n_val + 1L):n

  X_train <- X[train_idx, , , drop = FALSE]
  y_train <- y[train_idx]

  X_val <- X[val_idx, , , drop = FALSE]
  y_val <- y[val_idx]

  X_test <- X[test_idx, , , drop = FALSE]
  y_test <- y[test_idx]
  t_test <- tt[test_idx]

  if (dim(X_val)[1] > CFG$max_val_windows) {
    idx <- sort(sample.int(dim(X_val)[1], CFG$max_val_windows))
    X_val <- X_val[idx, , , drop = FALSE]
    y_val <- y_val[idx]
  }

  if (dim(X_test)[1] > CFG$max_test_windows) {
    idx <- sort(sample.int(dim(X_test)[1], CFG$max_test_windows))
    X_test <- X_test[idx, , , drop = FALSE]
    y_test <- y_test[idx]
    t_test <- t_test[idx]
  }

  fitX <- scale_fit(as.numeric(X_train))
  X_train_s <- scale_apply(X_train, fitX)
  X_val_s   <- scale_apply(X_val, fitX)
  X_test_s  <- scale_apply(X_test, fitX)

  fitY <- scale_fit(y_train)
  y_train_s <- scale_apply(y_train, fitY)
  y_val_s   <- scale_apply(y_val, fitY)

  list(
    lookback = lookback,
    stride   = stride,
    h        = h,
    X_train_t = as_tensor32(X_train_s, "X_train"),
    y_train_t = as_tensor32(as.matrix(y_train_s), "y_train"),
    X_val_t   = as_tensor32(X_val_s, "X_val"),
    y_val_t   = as_tensor32(as.matrix(y_val_s), "y_val"),
    X_test_t  = as_tensor32(X_test_s, "X_test"),
    y_test = y_test,
    t_test = t_test,
    y_train_raw = y_train,
    y_val_raw = y_val,
    fitY = fitY,
    n_total_windows = n,
    n_train = length(train_idx),
    n_val = length(y_val),
    n_test = length(y_test)
  )
}

# ============================================================
# 4. TUNING GLOBAL TDQ POR HORIZONTE
# ============================================================

HP_GLOBAL <- data.table()

tune_global_hp <- function(dt, horizonte, h, lookback, stride) {
  logi(sprintf("[TDQ-TUNE] WPD | %s (h=%d)", horizonte, h))

  d2 <- prep_combo(dt, CFG$tune_zone, horizonte, h, lookback, stride)
  if (is.null(d2)) {
    logi("  -> tuning no posible en Ztune. Usando base_hp.")
    return(c(CFG$base_hp, list(note = "fallback_base_hp", tuning_file = "")))
  }

  d3 <- if (!is.na(CFG$xfer_zone)) {
    prep_combo(dt, CFG$xfer_zone, horizonte, h, lookback, stride)
  } else {
    NULL
  }

  objective <- function(hp) {
    out <- run_train(d2, hp)
    out$best_val
  }

  tune_tbl <- data.table()
  set.seed(CFG$seed + ifelse(horizonte == "Corto", 1, ifelse(horizonte == "Medio", 2, 3)))

  for (i in seq_len(CFG$bayes_init)) {
    hp <- list(
      units1 = sample(CFG$units1_grid, 1),
      units2 = sample(CFG$units2_grid, 1),
      dropout = runif(1, CFG$dropout_min, CFG$dropout_max),
      lr = 10^runif(1, log10(CFG$lr_min), log10(CFG$lr_max)),
      batch = sample(CFG$batch_candidates, 1)
    )

    v <- objective(hp)

    tune_tbl <- rbind(
      tune_tbl,
      cbind(data.table(iter = i, val_Z2 = v), as.data.table(hp)),
      fill = TRUE
    )

    logi(sprintf("  init %d/%d -> val_Z2=%.6f", i, CFG$bayes_init, v))
  }

  best <- tune_tbl[which.min(val_Z2)]

  if (CFG$bayes_iter > CFG$bayes_init) {
    for (i in (CFG$bayes_init + 1L):CFG$bayes_iter) {
      hp <- list(
        units1 = sample(c(best$units1, CFG$units1_grid), 1),
        units2 = sample(c(best$units2, CFG$units2_grid), 1),
        dropout = min(max(best$dropout + rnorm(1, 0, 0.05), 0.05), 0.40),
        lr = {
          x <- 10^(log10(best$lr) + rnorm(1, 0, 0.20))
          min(max(x, 2e-4), 5e-3)
        },
        batch = sample(c(best$batch, CFG$batch_candidates), 1)
      )

      v <- objective(hp)

      tune_tbl <- rbind(
        tune_tbl,
        cbind(data.table(iter = i, val_Z2 = v), as.data.table(hp)),
        fill = TRUE
      )

      best <- tune_tbl[which.min(val_Z2)]
      logi(sprintf("  iter %d/%d -> val_Z2=%.6f | best=%.6f", i, CFG$bayes_iter, v, best$val_Z2))
    }
  }

  tune_tbl[, rk := frank(val_Z2, ties.method = "first")]
  cand <- tune_tbl[order(rk)][1:min(CFG$topk_transfer, .N)]

  if (!is.null(d3)) {
    cand[, val_Z3 := NA_real_]

    for (j in seq_len(nrow(cand))) {
      hp <- list(
        units1 = cand$units1[j],
        units2 = cand$units2[j],
        dropout = cand$dropout[j],
        lr = cand$lr[j],
        batch = cand$batch[j]
      )

      out3 <- run_train(d3, hp)
      cand$val_Z3[j] <- out3$best_val
    }

    cand[, score := (val_Z2 + val_Z3) / 2]
    pick <- cand[which.min(score)]
    note <- "tuned_Z2_transfer_Z3"
  } else {
    pick <- cand[which.min(val_Z2)]
    note <- "tuned_Z2_only"
  }

  tunefile <- file.path(DIR_TABLAS, sprintf("DL_TUNING_WPD_%s_h%d.csv", horizonte, h))
  fwrite(tune_tbl, tunefile)

  list(
    units1 = as.integer(pick$units1),
    units2 = as.integer(pick$units2),
    dropout = as.numeric(pick$dropout),
    lr = as.numeric(pick$lr),
    batch = as.integer(pick$batch),
    note = note,
    tuning_file = normp(tunefile)
  )
}

get_hp <- function(horizonte) {
  if (CFG$mode == "DL_ONLY") return(CFG$base_hp)

  row <- HP_GLOBAL[Horizonte == horizonte]
  if (nrow(row) != 1) return(CFG$base_hp)

  list(
    units1 = row$units1,
    units2 = row$units2,
    dropout = row$dropout,
    lr = row$lr,
    batch = row$batch
  )
}

# ============================================================
# 5. LECTURA DEL CACHE HORARIO
# ============================================================

if (!file.exists(CFG$input_file)) {
  stop("No existe el cache requerido: ", CFG$input_file,
       "\nEjecuta antes: 03_CODE/01_preprocessing/02_build_hourly_wpd_cache.R")
}

logi("Leyendo cache horario:", CFG$input_file)

dt <- fread(CFG$input_file, showProgress = TRUE)

stopifnot(all(c("Zona", "FechaHora", "WPD") %in% names(dt)))

dt[, Zona := as.integer(Zona)]
dt[, FechaHora := as.POSIXct(
  FechaHora,
  tz = CFG$tz_read,
  tryFormats = c(
    "%Y-%m-%d %H:%M:%S",
    "%Y/%m/%d %H:%M:%S",
    "%d/%m/%Y %H:%M",
    "%d/%m/%Y %H:%M:%S",
    "%Y-%m-%d %H:%M"
  )
)]

dt <- dt[!is.na(FechaHora)]
dt[, WPD := as.numeric(WPD)]
setorder(dt, Zona, FechaHora)

zones <- sort(unique(dt$Zona))
logi("Zonas:", paste(zones, collapse = ", "))

if (!(CFG$tune_zone %in% zones)) CFG$tune_zone <- zones[1]
if (!(CFG$xfer_zone %in% zones)) CFG$xfer_zone <- NA_integer_

set.seed(CFG$seed)
tf$random$set_seed(CFG$seed)

# ============================================================
# 6. FASE TDQ: HP GLOBALES
# ============================================================

if (CFG$mode == "DL_TDQ_BAYES") {
  logi("=== FASE TDQ: HP globales ===")

  for (ii in seq_len(nrow(CFG$horizons))) {
    horizonte <- CFG$horizons[ii]$Horizonte
    h <- as.integer(CFG$horizons[ii]$h)
    lookback <- as.integer(CFG$lookback_map[[horizonte]])
    stride   <- as.integer(CFG$stride_map[[horizonte]])

    if (horizonte == "Largo") {
      med <- HP_GLOBAL[Horizonte == "Medio"]

      if (nrow(med) == 1) {
        hpL <- list(
          units1 = as.integer(med$units1),
          units2 = as.integer(med$units2),
          dropout = min(max(as.numeric(med$dropout) + 0.05, 0.05), 0.40),
          lr = max(as.numeric(med$lr) * 0.85, 2e-4),
          batch = as.integer(med$batch),
          note = "largo_derived_from_medio",
          tuning_file = ""
        )
      } else {
        hpL <- c(CFG$base_hp, list(note = "largo_fallback_base", tuning_file = ""))
      }

      HP_GLOBAL <- rbind(HP_GLOBAL, hp_to_row("Largo", h, hpL), fill = TRUE)
      next
    }

    hp <- tune_global_hp(dt, horizonte, h, lookback, stride)
    HP_GLOBAL <- rbind(HP_GLOBAL, hp_to_row(horizonte, h, hp), fill = TRUE)
  }

  hpfile <- file.path(DIR_TABLAS, "DL_HP_GLOBAL_TDQ.csv")
  fwrite(HP_GLOBAL, hpfile)
  logi("HP globales:", normp(hpfile))
}

# ============================================================
# 7. ENTRENAMIENTO Y EXPORTACIÓN
# ============================================================

TABLA <- data.table()
PRED_ALL <- data.table()

for (z in zones) {

  logi("=== ZONA:", z, "===")

  for (ii in seq_len(nrow(CFG$horizons))) {

    horizonte <- CFG$horizons[ii]$Horizonte
    h <- as.integer(CFG$horizons[ii]$h)
    lookback <- as.integer(CFG$lookback_map[[horizonte]])
    stride   <- as.integer(CFG$stride_map[[horizonte]])

    hp <- get_hp(horizonte)
    modelo_tag <- ifelse(CFG$mode == "DL_TDQ_BAYES", "LSTM_TDQ_BAYES", "LSTM_ONLY")

    logi(sprintf("Zona %d | %s (h=%d) | %s", z, horizonte, h, modelo_tag))

    d <- prep_combo(dt, z, horizonte, h, lookback, stride)
    if (is.null(d)) {
      logi("  -> sin datos/ventanas")
      next
    }

    out <- tryCatch(
      run_train(d, hp),
      error = function(e) {
        logi("[ERROR]", conditionMessage(e))
        NULL
      }
    )

    if (is.null(out)) next

    yhat_s <- as.numeric(out$model$predict(d$X_test_t, verbose = 0L))
    yhat   <- yhat_s * d$fitY$sd + d$fitY$mu

    y_all <- c(d$y_train_raw, d$y_val_raw, d$y_test)
    yhat_p <- persistence_pred(y_all, 1L)

    nT <- length(d$y_test)
    if (nT <= h + 30) {
      logi("  -> test muy corto para Eh")
      next
    }

    t_base <- d$t_test[1:(nT - h)]
    WPD_true <- d$y_test[(h + 1):nT]
    WPD_pred <- yhat[(h + 1):nT]
    WPD_pers <- d$y_test[1:(nT - h)]

    Eh_true <- calc_Eh(WPD_true, h)
    Eh_pred <- calc_Eh(WPD_pred, h)
    Eh_pers <- calc_Eh(WPD_pers, h)

    pred_dt <- data.table(
      Zona = z,
      Horizonte = horizonte,
      h = h,
      Modelo = modelo_tag,
      Fecha = t_base,
      WPD_true = WPD_true,
      WPD_pred = WPD_pred,
      WPD_persist = WPD_pers,
      Eh_true = Eh_true,
      Eh_pred = Eh_pred,
      Eh_persist = Eh_pers
    )

    pred_dt[, `:=`(
      Resid_WPD = WPD_true - WPD_pred,
      Resid_Eh  = Eh_true - Eh_pred
    )]

    pred_file <- file.path(
      DIR_PREDS,
      sprintf("DL_PRED_WPD_Eh_Z%d_%s_h%d_%s.csv", z, horizonte, h, modelo_tag)
    )

    fwrite(pred_dt, pred_file)
    PRED_ALL <- rbind(PRED_ALL, cbind(pred_dt, file_pred = normp(pred_file)), fill = TRUE)

    RMSE_WPD <- rmse(WPD_true, WPD_pred)
    MAE_WPD  <- mae(WPD_true, WPD_pred)
    R2_WPD   <- safe_r2(WPD_true, WPD_pred)
    RMSEp_WPD <- rmse(WPD_true, WPD_pers)
    Skill_WPD <- ifelse(is.finite(RMSEp_WPD) && RMSEp_WPD > 0, 1 - (RMSE_WPD / RMSEp_WPD), NA_real_)

    okE <- is.finite(Eh_true) & is.finite(Eh_pred) & is.finite(Eh_pers)

    RMSE_Eh <- if (sum(okE) > 200) rmse(Eh_true[okE], Eh_pred[okE]) else NA_real_
    MAE_Eh  <- if (sum(okE) > 200) mae(Eh_true[okE], Eh_pred[okE]) else NA_real_
    R2_Eh   <- if (sum(okE) > 200) safe_r2(Eh_true[okE], Eh_pred[okE]) else NA_real_
    RMSEp_Eh <- if (sum(okE) > 200) rmse(Eh_true[okE], Eh_pers[okE]) else NA_real_
    Skill_Eh <- ifelse(is.finite(RMSEp_Eh) && RMSEp_Eh > 0, 1 - (RMSE_Eh / RMSEp_Eh), NA_real_)

    model_file <- file.path(
      DIR_MODELS,
      sprintf("DL_MODEL_WPD_Z%d_%s_h%d_%s.keras", z, horizonte, h, modelo_tag)
    )

    try(out$model$save(model_file), silent = TRUE)

    pub_wpd <- file.path(DIR_PUB, sprintf("SERIE_WPD_Z%d_%s_h%d_%s.png", z, horizonte, h, modelo_tag))
    pub_eh  <- file.path(DIR_PUB, sprintf("SERIE_Eh_Z%d_%s_h%d_%s.png", z, horizonte, h, modelo_tag))
    res_wpd <- file.path(DIR_PUB, sprintf("RESID_WPD_Z%d_%s_h%d_%s.png", z, horizonte, h, modelo_tag))
    res_eh  <- file.path(DIR_PUB, sprintf("RESID_Eh_Z%d_%s_h%d_%s.png", z, horizonte, h, modelo_tag))
    anex_curve <- file.path(DIR_ANEX, sprintf("CURVA_WPD_Z%d_%s_h%d_%s.png", z, horizonte, h, modelo_tag))

    plot_pub_series(
      pred_dt[, .(Fecha, Actual = WPD_true, Pred = WPD_pred)],
      pub_wpd,
      sprintf("WPD | Z%d | %s (h=%d)", z, horizonte, h)
    )

    if (sum(okE) > 200) {
      plot_pub_series(
        pred_dt[okE, .(Fecha, Actual = Eh_true, Pred = Eh_pred)],
        pub_eh,
        sprintf("Eh | Z%d | %s (h=%d)", z, horizonte, h)
      )

      plot_pub_resid(
        pred_dt[okE, .(Fecha, Resid = Resid_Eh)],
        res_eh,
        sprintf("Residuos Eh | Z%d | %s (h=%d)", z, horizonte, h)
      )
    }

    plot_pub_resid(
      pred_dt[, .(Fecha, Resid = Resid_WPD)],
      res_wpd,
      sprintf("Residuos WPD | Z%d | %s (h=%d)", z, horizonte, h)
    )

    plot_anexo_curve(
      out$hist,
      anex_curve,
      sprintf("Curva LSTM | Z%d | %s (h=%d)", z, horizonte, h)
    )

    TABLA <- rbind(TABLA, data.table(
      Zona = z,
      Horizonte = horizonte,
      h = h,
      Target = "WPD",
      Modelo = modelo_tag,
      n_total_windows = d$n_total_windows,
      n_train = d$n_train,
      n_val = d$n_val,
      n_test = nT,
      RMSE = RMSE_WPD,
      MAE = MAE_WPD,
      R2 = R2_WPD,
      Skill_vs_Persist = Skill_WPD,
      Lookback = lookback,
      Stride = stride,
      Epochs_ran = length(as.numeric(out$hist$history$loss)),
      Batch = hp$batch,
      units1 = hp$units1,
      units2 = hp$units2,
      dropout = hp$dropout,
      lr = hp$lr,
      ModeloFile = normp(model_file),
      PredFile = normp(pred_file),
      FigSerie = normp(pub_wpd),
      FigResid = normp(res_wpd),
      FigCurva = normp(anex_curve)
    ), fill = TRUE)

    TABLA <- rbind(TABLA, data.table(
      Zona = z,
      Horizonte = horizonte,
      h = h,
      Target = "Eh",
      Modelo = modelo_tag,
      n_total_windows = d$n_total_windows,
      n_train = d$n_train,
      n_val = d$n_val,
      n_test = sum(okE),
      RMSE = RMSE_Eh,
      MAE = MAE_Eh,
      R2 = R2_Eh,
      Skill_vs_Persist = Skill_Eh,
      Lookback = lookback,
      Stride = stride,
      Epochs_ran = length(as.numeric(out$hist$history$loss)),
      Batch = hp$batch,
      units1 = hp$units1,
      units2 = hp$units2,
      dropout = hp$dropout,
      lr = hp$lr,
      ModeloFile = normp(model_file),
      PredFile = normp(pred_file),
      FigSerie = normp(pub_eh),
      FigResid = normp(res_eh),
      FigCurva = normp(anex_curve)
    ), fill = TRUE)

    fwrite(TABLA, file.path(DIR_TABLAS, "DL_TABLA_COMBINADA_DEFINITIVA.csv"))
    fwrite(PRED_ALL, file.path(DIR_PREDS, "DL_PRED_TODO_COMBINADO.csv"))

    logi(sprintf("  -> WPD RMSE=%.4f | R2=%.4f | Skill=%.4f", RMSE_WPD, R2_WPD, Skill_WPD))
    logi(sprintf("  -> Eh  RMSE=%.4f | R2=%.4f | Skill=%.4f (ok=%d)", RMSE_Eh, R2_Eh, Skill_Eh, sum(okE)))
  }
}

# ============================================================
# 8. EXPORTACIÓN FINAL
# ============================================================

f_all <- file.path(DIR_TABLAS, "DL_TABLA_COMBINADA_DEFINITIVA.csv")
f_wpd <- file.path(DIR_TABLAS, "DL_TABLA_WPD_COMPLETA.csv")
f_eh  <- file.path(DIR_TABLAS, "DL_TABLA_EH_COMPLETA.csv")
f_pred_all <- file.path(DIR_PREDS, "DL_PRED_TODO_COMBINADO.csv")

fwrite(TABLA, f_all)
fwrite(TABLA[Target == "WPD"], f_wpd)
fwrite(TABLA[Target == "Eh"],  f_eh)
fwrite(PRED_ALL, f_pred_all)

writeLines(capture.output(sessionInfo()), file.path(OUT_DIR, "MASTER_sessionInfo.txt"))

logi("=== EXPORTACIÓN ===")
logi("TABLA ALL:", normp(f_all))
logi("TABLA WPD:", normp(f_wpd))
logi("TABLA EH:", normp(f_eh))
logi("PRED ALL:", normp(f_pred_all))
logi("Figuras publicables:", normp(DIR_PUB))
logi("Figuras anexos:", normp(DIR_ANEX))
logi("Modelos:", normp(DIR_MODELS))
logi("=== DL PIPELINE (fin) ===")

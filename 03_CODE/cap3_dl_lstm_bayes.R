# ============================================================
# CAP3 – Deep Learning Pipeline (LSTM Bayes) for WPD/Eh
# PURPOSE: DL pipeline producing comparable metrics, figures, and prediction cache; supports TDQ mode
# INPUTS: Prepared hourly zonal dataset (WPD_hourly_por_zona.csv) under SALIDAS/ or configure path
# OUTPUTS: DL metrics tables + figures + prediction cache vectors
# NOTE: This script was extracted from the working thesis pipeline and
#       lightly cleaned for GitHub (paths made configurable, unicode normalized).
# ============================================================

Código DL Total
# ============================================================
# PIPELINE DL DEFINITIVO (DL_ONLY + DL_TDQ_BAYES) - WPD + Eh + PRED_CACHE
# - Eh se deriva EXACTO como tu pipeline (filter sumatoria por horizonte h)
# - Exporta predicciones alineadas (n-h) para híbrido TDQ sin reentrenar
# - Tablas comparables con Clásicos/ML + figuras publicables + anexos
# - FIX CRÍTICO: HP_GLOBAL 100% ATÓMICO (sin columnas lista/NULL) -> fwrite estable
# ============================================================

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(tensorflow)
})

Sys.setenv(TF_CPP_MIN_LOG_LEVEL="2")

# -----------------------------
# CONFIG
# -----------------------------
CFG <- list(
  mode = "DL_TDQ_BAYES",         # "DL_ONLY" o "DL_TDQ_BAYES"

  input_path = file.path("SALIDAS","WPD_hourly_por_zona.csv"),
  out_dir    = "SALIDAS",
  seed       = 123,

  horizons = data.table(Horizonte=c("Corto","Medio","Largo"), h=c(1L,12L,72L)),
  lookback_map = list(Corto=48L, Medio=168L, Largo=336L),

  # TDQ: bajar costo sin perder comparabilidad
  stride_map = list(Corto=2L, Medio=4L, Largo=8L),

  test_frac = 0.15,
  val_frac  = 0.15,

  # control costo
  max_windows_total = 20000L,
  max_train_rows    = 60000L,
  max_val_windows   = 5000L,
  max_test_windows  = 5000L,

  epochs   = 28L,
  patience = 5L,
  batch_candidates = c(256L, 512L),

  # baseline hp (DL_ONLY)
  base_hp = list(units1=64L, units2=32L, dropout=0.15, lr=1e-3, batch=512L),

  # TDQ Bayes global por horizonte: tunear en Z2 (y opcional transfer Z3)
  tune_zone = 2L,
  xfer_zone = 3L,
  bayes_init = 3L,
  bayes_iter = 8L,
  topk_transfer = 2L,

  units1_grid = c(32L,64L,96L,128L),
  units2_grid = c(16L,32L,48L,64L),
  dropout_min = 0.05, dropout_max = 0.35,
  lr_min = 3e-4, lr_max = 3e-3,

  # carpetas
  dir_tablas = "TABLAS",
  dir_preds  = "PREDICCIONES",
  dir_models = "MODELOS",
  dir_pub    = "FIG_PUBLICABLE",
  dir_anex   = "FIG_ANEXOS",
  log_file   = "DL_LOG.txt"
)

# -----------------------------
# HELPERS
# -----------------------------
normp <- function(p){ p <- gsub("\\\\","/",p); gsub("/+$","",p) }

as_tensor32 <- function(x, name="x"){
  storage.mode(x) <- "double"
  if (any(!is.finite(x))) stop(sprintf("[DATA ERROR] %s contiene NA/Inf.", name))
  tf$convert_to_tensor(x, dtype=tf$float32)
}

scale_fit <- function(x){
  mu <- mean(x, na.rm=TRUE); sdv <- sd(x, na.rm=TRUE)
  if (!is.finite(sdv) || sdv==0) sdv <- 1
  list(mu=mu, sd=sdv)
}
scale_apply <- function(x, fit) (x - fit$mu)/fit$sd

rmse <- function(y,yh) sqrt(mean((y-yh)^2, na.rm=TRUE))
mae  <- function(y,yh) mean(abs(y-yh), na.rm=TRUE)
safe_r2 <- function(y,yh){
  ok <- is.finite(y) & is.finite(yh)
  y <- y[ok]; yh <- yh[ok]
  if (length(y) < 3) return(NA_real_)
  sst <- sum((y-mean(y))^2)
  sse <- sum((y-yh)^2)
  if (!is.finite(sst) || sst <= 0) return(NA_real_)
  r2 <- 1 - sse/sst
  max(min(r2,1), -Inf)
}

persistence_pred <- function(y, lag_steps=1L){
  yh <- rep(NA_real_, length(y))
  if (lag_steps < length(y)) yh[(lag_steps+1):length(y)] <- y[1:(length(y)-lag_steps)]
  yh
}

# Eh EXACTO como tu pipeline ML
calc_Eh <- function(x, h){
  if (length(x) < h) return(rep(NA_real_, length(x)))
  as.numeric(stats::filter(x, rep(1, h), sides = 1))
}

# -------- FIX CLAVE HP_GLOBAL: todo atómico
`%||%` <- function(a,b) if (is.null(a)) b else a
hp_to_row <- function(horizonte, h, hp){
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

# Ventanas + timestamps
make_windows <- function(y, time, lookback, h, stride){
  n <- length(y)
  last_t <- n - h
  if (last_t <= lookback) return(NULL)

  t_idx <- seq.int(from=lookback, to=last_t, by=stride)
  m <- length(t_idx)
  if (m < 250) return(NULL)

  X  <- array(0, dim=c(m, lookback, 1))
  yt <- numeric(m)
  tt <- as.POSIXct(rep(NA, m), origin="1970-01-01", tz="UTC")

  for (i in seq_len(m)){
    t <- t_idx[i]
    X[i,,1] <- y[(t-lookback+1):t]
    yt[i]   <- y[t+h]
    tt[i]   <- time[t+h]
  }

  ok <- is.finite(yt) & is.finite(as.numeric(tt)) & apply(X,1,function(v) all(is.finite(v)))
  if (!any(ok)) return(NULL)

  X <- X[ok,,,drop=FALSE]
  yt <- yt[ok]
  tt <- tt[ok]

  if (nrow(X) > CFG$max_windows_total){
    idx <- sort(sample.int(nrow(X), CFG$max_windows_total))
    X <- X[idx,,,drop=FALSE]; yt <- yt[idx]; tt <- tt[idx]
  }

  list(X=X, y=yt, t=tt)
}

make_dataset <- function(X, y, batch){
  tf$data$Dataset$from_tensor_slices(tuple(X,y))$
    batch(as.integer(batch))$
    prefetch(tf$data$AUTOTUNE)
}

# Modelo estable: Input() explícito
build_model <- function(lookback, units1, units2, dropout, lr){
  k <- tf$keras
  inputs <- k$Input(shape = tuple(as.integer(lookback), 1L))
  x <- k$layers$LSTM(units=as.integer(units1), return_sequences=TRUE)(inputs)
  x <- k$layers$Dropout(rate=dropout)(x)
  x <- k$layers$LSTM(units=as.integer(units2), return_sequences=FALSE)(x)
  x <- k$layers$Dropout(rate=dropout)(x)
  outputs <- k$layers$Dense(units=1L, activation="linear")(x)
  model <- k$Model(inputs=inputs, outputs=outputs)
  model$compile(optimizer=k$optimizers$Adam(learning_rate=lr), loss="mse", metrics=list("mae"))
  model
}

run_train <- function(d, hp){
  k <- tf$keras
  k$backend$clear_session(); gc()

  model <- build_model(d$lookback, hp$units1, hp$units2, hp$dropout, hp$lr)
  cb_early <- k$callbacks$EarlyStopping(monitor="val_loss", patience=CFG$patience, restore_best_weights=TRUE)
  cb_lr <- k$callbacks$ReduceLROnPlateau(monitor="val_loss", factor=0.5, patience=2L, min_lr=1e-5)

  ds_tr <- make_dataset(d$X_train_t, d$y_train_t, hp$batch)
  ds_va <- make_dataset(d$X_val_t,   d$y_val_t,   hp$batch)

  hist <- model$fit(
    ds_tr,
    validation_data=ds_va,
    epochs=as.integer(CFG$epochs),
    verbose=0L,
    callbacks=list(cb_early, cb_lr)
  )

  list(model=model, hist=hist, best_val=min(as.numeric(hist$history$val_loss)))
}

# Publicable
theme_pub <- function(){
  theme_classic(base_size = 11) +
    theme(
      plot.title = element_text(face="bold"),
      axis.title = element_text(face="bold"),
      legend.position = "top",
      legend.title = element_blank()
    )
}
plot_pub_series <- function(df, file_png, title_txt){
  p <- ggplot(df, aes(x=Fecha)) +
    geom_line(aes(y=Actual, linetype="Actual")) +
    geom_line(aes(y=Pred,   linetype="Predicción")) +
    labs(title=title_txt, x=NULL, y=NULL) +
    theme_pub()
  ggsave(file_png, p, width=8.2, height=3.2, dpi=300)
}
plot_pub_resid <- function(df, file_png, title_txt){
  p <- ggplot(df, aes(x=Fecha, y=Resid)) +
    geom_hline(yintercept=0) +
    geom_line() +
    labs(title=title_txt, x=NULL, y="Residuo") +
    theme_pub()
  ggsave(file_png, p, width=8.2, height=3.0, dpi=300)
}
plot_anexo_curve <- function(hist, file_png, title_txt){
  loss <- as.numeric(hist$history$loss)
  val_loss <- as.numeric(hist$history$val_loss)
  df <- data.table(epoch=seq_along(loss), loss=loss, val_loss=val_loss)
  p <- ggplot(df, aes(epoch)) +
    geom_line(aes(y=loss)) +
    geom_line(aes(y=val_loss)) +
    labs(title=title_txt, x="Epoch", y="Loss (MSE)") +
    theme_classic(base_size = 10)
  ggsave(file_png, p, width=7, height=4, dpi=160)
}

# Preparación combo por zona/horizonte
prep_combo <- function(dt, z, horizonte, h, lookback, stride){

  dzone <- dt[Zona==z, .(FechaYHora, y=WPD)]
  dzone <- dzone[is.finite(y)]
  setorder(dzone, FechaYHora)
  if (nrow(dzone) < 800) return(NULL)

  win <- make_windows(dzone$y, dzone$FechaYHora, lookback, h, stride)
  if (is.null(win)) return(NULL)

  X <- win$X; y <- win$y; tt <- win$t
  n <- length(y)

  n_test  <- max(1L, floor(n*CFG$test_frac))
  n_val   <- max(1L, floor(n*CFG$val_frac))
  n_train <- n - n_test - n_val
  if (n_train < 300) return(NULL)

  if (n_train > CFG$max_train_rows){
    shift <- n_train - CFG$max_train_rows
    train_idx <- (1L+shift):n_train
  } else train_idx <- 1L:n_train

  val_idx  <- (n_train+1L):(n_train+n_val)
  test_idx <- (n_train+n_val+1L):n

  X_train <- X[train_idx,,,drop=FALSE]; y_train <- y[train_idx]
  X_val   <- X[val_idx,,,drop=FALSE];   y_val   <- y[val_idx]
  X_test  <- X[test_idx,,,drop=FALSE];  y_test  <- y[test_idx]
  t_test  <- tt[test_idx]

  if (nrow(X_val) > CFG$max_val_windows){
    idx <- sort(sample.int(nrow(X_val), CFG$max_val_windows))
    X_val <- X_val[idx,,,drop=FALSE]; y_val <- y_val[idx]
  }
  if (nrow(X_test) > CFG$max_test_windows){
    idx <- sort(sample.int(nrow(X_test), CFG$max_test_windows))
    X_test <- X_test[idx,,,drop=FALSE]; y_test <- y_test[idx]; t_test <- t_test[idx]
  }

  fitX <- scale_fit(as.numeric(X_train))
  X_train_s <- scale_apply(X_train, fitX)
  X_val_s   <- scale_apply(X_val, fitX)
  X_test_s  <- scale_apply(X_test, fitX)

  fitY <- scale_fit(y_train)
  y_train_s <- scale_apply(y_train, fitY)
  y_val_s   <- scale_apply(y_val, fitY)

  list(
    lookback=lookback, stride=stride, h=h,
    X_train_t=as_tensor32(X_train_s,"X_train"),
    y_train_t=as_tensor32(as.matrix(y_train_s),"y_train"),
    X_val_t  =as_tensor32(X_val_s,"X_val"),
    y_val_t  =as_tensor32(as.matrix(y_val_s),"y_val"),
    X_test_t =as_tensor32(X_test_s,"X_test"),
    y_test=y_test, t_test=t_test,
    y_train_raw=y_train, y_val_raw=y_val,
    fitY=fitY,
    n_total_windows=n,
    n_train=length(train_idx), n_val=length(y_val), n_test=length(y_test)
  )
}

# -----------------------------
# I/O + LOG
# -----------------------------
dir.create(CFG$out_dir, showWarnings=FALSE, recursive=TRUE)
for (d in c(CFG$dir_tablas,CFG$dir_preds,CFG$dir_models,CFG$dir_pub,CFG$dir_anex)){
  dir.create(file.path(CFG$out_dir,d), showWarnings=FALSE, recursive=TRUE)
}

sink(file.path(CFG$out_dir, CFG$log_file), split=TRUE)
cat("=== DL PIPELINE (inicio) ===\n")
cat("Modo:", CFG$mode, "\n")
cat("getwd():", normp(getwd()), "\n")
cat("Input :", normp(file.path(getwd(), CFG$input_path)), "\n")
cat("TensorFlow:", tf$version$VERSION, "\n")

set.seed(CFG$seed)
tf$random$set_seed(CFG$seed)

infile <- file.path(getwd(), CFG$input_path)
stopifnot(file.exists(infile))
dt <- fread(infile, showProgress=FALSE)

stopifnot("Zona"%in%names(dt), "FechaYHora"%in%names(dt), "WPD"%in%names(dt))

dt[, FechaYHora := as.POSIXct(FechaYHora, tz="UTC", tryFormats=c(
  "%Y-%m-%d %H:%M:%S","%Y/%m/%d %H:%M:%S",
  "%d/%m/%Y %H:%M","%d/%m/%Y %H:%M:%S",
  "%Y-%m-%d %H:%M"
))]
dt <- dt[!is.na(FechaYHora)]
setorder(dt, Zona, FechaYHora)

zones <- sort(unique(dt$Zona))
cat("Zonas:", paste(zones, collapse=", "), "\n\n")

if (!(CFG$tune_zone %in% zones)) CFG$tune_zone <- zones[1]
if (!(CFG$xfer_zone %in% zones)) CFG$xfer_zone <- NA_integer_

# -----------------------------
# TDQ Bayes global por horizonte (WPD)
# -----------------------------
HP_GLOBAL <- data.table()

tune_global_hp <- function(horizonte, h, lookback, stride){

  cat(sprintf("[TDQ-TUNE] WPD | %s (h=%d)\n", horizonte, h))

  d2 <- prep_combo(dt, CFG$tune_zone, horizonte, h, lookback, stride)
  if (is.null(d2)){
    cat("  -> tuning no posible (Ztune). Usando base_hp.\n")
    return(c(CFG$base_hp, list(note="fallback_base_hp", tuning_file="")))
  }

  d3 <- if (!is.na(CFG$xfer_zone)) prep_combo(dt, CFG$xfer_zone, horizonte, h, lookback, stride) else NULL

  objective <- function(hp){
    out <- run_train(d2, hp)
    out$best_val
  }

  tune_tbl <- data.table()
  set.seed(CFG$seed + ifelse(horizonte=="Corto",1,ifelse(horizonte=="Medio",2,3)))

  for (i in seq_len(CFG$bayes_init)){
    hp <- list(
      units1 = sample(CFG$units1_grid,1),
      units2 = sample(CFG$units2_grid,1),
      dropout = runif(1, CFG$dropout_min, CFG$dropout_max),
      lr = 10^runif(1, log10(CFG$lr_min), log10(CFG$lr_max)),
      batch = sample(CFG$batch_candidates,1)
    )
    v <- objective(hp)
    tune_tbl <- rbind(tune_tbl, cbind(data.table(iter=i, val_Z2=v), as.data.table(hp)), fill=TRUE)
    cat(sprintf("  init %d/%d -> val_Z2=%.6f\n", i, CFG$bayes_init, v))
  }

  best <- tune_tbl[which.min(val_Z2)]
  if (CFG$bayes_iter > CFG$bayes_init){
    for (i in (CFG$bayes_init+1L):CFG$bayes_iter){
      hp <- list(
        units1 = sample(c(best$units1, CFG$units1_grid),1),
        units2 = sample(c(best$units2, CFG$units2_grid),1),
        dropout = min(max(best$dropout + rnorm(1,0,0.05), 0.05), 0.40),
        lr = {
          x <- 10^(log10(best$lr) + rnorm(1,0,0.20))
          min(max(x,2e-4),5e-3)
        },
        batch = sample(c(best$batch, CFG$batch_candidates),1)
      )
      v <- objective(hp)
      tune_tbl <- rbind(tune_tbl, cbind(data.table(iter=i, val_Z2=v), as.data.table(hp)), fill=TRUE)
      best <- tune_tbl[which.min(val_Z2)]
      cat(sprintf("  iter %d/%d -> val_Z2=%.6f | best=%.6f\n", i, CFG$bayes_iter, v, best$val_Z2))
    }
  }

  # transfer check topK
  tune_tbl[, rk := frank(val_Z2, ties.method="first")]
  cand <- tune_tbl[order(rk)][1:min(CFG$topk_transfer, .N)]

  if (!is.null(d3)){
    cand[, val_Z3 := NA_real_]
    for (j in seq_len(nrow(cand))){
      hp <- list(units1=cand$units1[j], units2=cand$units2[j], dropout=cand$dropout[j], lr=cand$lr[j], batch=cand$batch[j])
      out3 <- run_train(d3, hp)
      cand$val_Z3[j] <- out3$best_val
    }
    cand[, score := (val_Z2 + val_Z3)/2]
    pick <- cand[which.min(score)]
    note <- "tuned_Z2_transfer_Z3"
  } else {
    pick <- cand[which.min(val_Z2)]
    note <- "tuned_Z2_only"
  }

  tunefile <- file.path(CFG$out_dir, CFG$dir_tablas,
                        sprintf("DL_TUNING_WPD_%s_h%d.csv", horizonte, h))
  fwrite(tune_tbl, tunefile)

  list(
    units1=as.integer(pick$units1), units2=as.integer(pick$units2),
    dropout=as.numeric(pick$dropout), lr=as.numeric(pick$lr),
    batch=as.integer(pick$batch),
    note=note,
    tuning_file=normp(tunefile)
  )
}

get_hp <- function(horizonte){
  if (CFG$mode == "DL_ONLY") return(CFG$base_hp)
  row <- HP_GLOBAL[Horizonte==horizonte]
  if (nrow(row)!=1) return(CFG$base_hp)
  list(units1=row$units1, units2=row$units2, dropout=row$dropout, lr=row$lr, batch=row$batch)
}

if (CFG$mode == "DL_TDQ_BAYES"){
  cat("=== FASE TDQ: HP globales ===\n")

  for (ii in seq_len(nrow(CFG$horizons))){
    horizonte <- CFG$horizons[ii]$Horizonte
    h <- as.integer(CFG$horizons[ii]$h)
    lookback <- as.integer(CFG$lookback_map[[horizonte]])
    stride   <- as.integer(CFG$stride_map[[horizonte]])

    if (horizonte == "Largo"){
      med <- HP_GLOBAL[Horizonte=="Medio"]
      if (nrow(med)==1){
        hpL <- list(
          units1=as.integer(med$units1),
          units2=as.integer(med$units2),
          dropout=min(max(as.numeric(med$dropout)+0.05,0.05),0.40),
          lr=max(as.numeric(med$lr)*0.85,2e-4),
          batch=as.integer(med$batch),
          note="largo_derived_from_medio",
          tuning_file=""
        )
      } else {
        hpL <- c(CFG$base_hp, list(note="largo_fallback_base", tuning_file=""))
      }
      HP_GLOBAL <- rbind(HP_GLOBAL, hp_to_row("Largo", h, hpL), fill=TRUE)
      next
    }

    hp <- tune_global_hp(horizonte, h, lookback, stride)
    HP_GLOBAL <- rbind(HP_GLOBAL, hp_to_row(horizonte, h, hp), fill=TRUE)
  }

  hpfile <- file.path(CFG$out_dir, CFG$dir_tablas, "DL_HP_GLOBAL_TDQ.csv")
  fwrite(HP_GLOBAL, hpfile)
  cat("HP globales:", normp(hpfile), "\n\n")
}

# -----------------------------
# FULL training + export
# -----------------------------
TABLA <- data.table()
PRED_ALL <- data.table()

for (z in zones){
  cat("\n=== ZONA:", z, "===\n")

  for (ii in seq_len(nrow(CFG$horizons))){

    horizonte <- CFG$horizons[ii]$Horizonte
    h <- as.integer(CFG$horizons[ii]$h)
    lookback <- as.integer(CFG$lookback_map[[horizonte]])
    stride   <- as.integer(CFG$stride_map[[horizonte]])

    hp <- get_hp(horizonte)
    modelo_tag <- ifelse(CFG$mode=="DL_TDQ_BAYES", "LSTM_TDQ_BAYES", "LSTM_ONLY")

    cat(sprintf("Zona %d | %s (h=%d) | %s\n", z, horizonte, h, modelo_tag))

    d <- prep_combo(dt, z, horizonte, h, lookback, stride)
    if (is.null(d)) { cat("  -> sin datos/ventanas\n"); next }

    out <- tryCatch(run_train(d, hp), error=function(e){ cat("  [ERROR] ", conditionMessage(e), "\n"); NULL })
    if (is.null(out)) next

    # predicción WPD test
    yhat_s <- as.numeric(out$model$predict(d$X_test_t, verbose=0L))
    yhat   <- yhat_s * d$fitY$sd + d$fitY$mu

    # persistencia WPD
    y_all <- c(d$y_train_raw, d$y_val_raw, d$y_test)
    yhat_p <- persistence_pred(y_all, 1L)
    yhat_p_test <- tail(yhat_p, length(d$y_test))

    # PRED_CACHE alineado n-h (idéntico a tu pipeline)
    nT <- length(d$y_test)
    if (nT <= h + 30){
      cat("  -> test muy corto para Eh\n"); next
    }

    t_base <- d$t_test[1:(nT-h)]
    WPD_true <- d$y_test[(h+1):nT]
    WPD_pred <- yhat[(h+1):nT]
    WPD_pers <- d$y_test[1:(nT-h)]

    Eh_true <- calc_Eh(WPD_true, h)
    Eh_pred <- calc_Eh(WPD_pred, h)
    Eh_pers <- calc_Eh(WPD_pers, h)

    pred_dt <- data.table(
      Zona=z, Horizonte=horizonte, h=h,
      Modelo=modelo_tag,
      Fecha=t_base,
      WPD_true=WPD_true, WPD_pred=WPD_pred, WPD_persist=WPD_pers,
      Eh_true=Eh_true,   Eh_pred=Eh_pred,   Eh_persist=Eh_pers
    )
    pred_dt[, `:=`(Resid_WPD=WPD_true-WPD_pred, Resid_Eh=Eh_true-Eh_pred)]

    pred_file <- file.path(CFG$out_dir, CFG$dir_preds,
                           sprintf("DL_PRED_WPD_Eh_Z%d_%s_h%d_%s.csv", z, horizonte, h, modelo_tag)
    )
    fwrite(pred_dt, pred_file)
    PRED_ALL <- rbind(PRED_ALL, cbind(pred_dt, file_pred=normp(pred_file)), fill=TRUE)

    # métricas WPD (alineado)
    RMSE_WPD <- rmse(WPD_true, WPD_pred)
    MAE_WPD  <- mae(WPD_true, WPD_pred)
    R2_WPD   <- safe_r2(WPD_true, WPD_pred)
    RMSEp_WPD <- rmse(WPD_true, WPD_pers)
    Skill_WPD <- ifelse(is.finite(RMSEp_WPD) && RMSEp_WPD>0, 1-(RMSE_WPD/RMSEp_WPD), NA_real_)

    # métricas Eh
    okE <- is.finite(Eh_true) & is.finite(Eh_pred) & is.finite(Eh_pers)
    RMSE_Eh <- if (sum(okE)>200) rmse(Eh_true[okE], Eh_pred[okE]) else NA_real_
    MAE_Eh  <- if (sum(okE)>200) mae(Eh_true[okE], Eh_pred[okE])  else NA_real_
    R2_Eh   <- if (sum(okE)>200) safe_r2(Eh_true[okE], Eh_pred[okE]) else NA_real_
    RMSEp_Eh <- if (sum(okE)>200) rmse(Eh_true[okE], Eh_pers[okE]) else NA_real_
    Skill_Eh <- ifelse(is.finite(RMSEp_Eh) && RMSEp_Eh>0, 1-(RMSE_Eh/RMSEp_Eh), NA_real_)

    # guardar modelo
    model_file <- file.path(CFG$out_dir, CFG$dir_models,
                            sprintf("DL_MODEL_WPD_Z%d_%s_h%d_%s.keras", z, horizonte, h, modelo_tag)
    )
    try(out$model$save(model_file), silent=TRUE)

    # figuras
    pub_wpd <- file.path(CFG$out_dir, CFG$dir_pub,
                         sprintf("SERIE_WPD_Z%d_%s_h%d_%s.png", z, horizonte, h, modelo_tag)
    )
    pub_eh <- file.path(CFG$out_dir, CFG$dir_pub,
                        sprintf("SERIE_Eh_Z%d_%s_h%d_%s.png", z, horizonte, h, modelo_tag)
    )
    res_wpd <- file.path(CFG$out_dir, CFG$dir_pub,
                         sprintf("RESID_WPD_Z%d_%s_h%d_%s.png", z, horizonte, h, modelo_tag)
    )
    res_eh <- file.path(CFG$out_dir, CFG$dir_pub,
                        sprintf("RESID_Eh_Z%d_%s_h%d_%s.png", z, horizonte, h, modelo_tag)
    )

    plot_pub_series(pred_dt[,.(Fecha, Actual=WPD_true, Pred=WPD_pred)], pub_wpd,
                    sprintf("WPD | Z%d | %s (h=%d)", z, horizonte, h))
    if (sum(okE)>200){
      plot_pub_series(pred_dt[okE,.(Fecha, Actual=Eh_true, Pred=Eh_pred)], pub_eh,
                      sprintf("Eh | Z%d | %s (h=%d)", z, horizonte, h))
      plot_pub_resid(pred_dt[okE,.(Fecha, Resid=Resid_Eh)], res_eh,
                     sprintf("Residuos Eh | Z%d | %s (h=%d)", z, horizonte, h))
    }
    plot_pub_resid(pred_dt[,.(Fecha, Resid=Resid_WPD)], res_wpd,
                   sprintf("Residuos WPD | Z%d | %s (h=%d)", z, horizonte, h))

    anex_curve <- file.path(CFG$out_dir, CFG$dir_anex,
                            sprintf("CURVA_WPD_Z%d_%s_h%d_%s.png", z, horizonte, h, modelo_tag)
    )
    plot_anexo_curve(out$hist, anex_curve,
                     sprintf("Curva LSTM | Z%d | %s (h=%d)", z, horizonte, h))

    # tabla (2 filas: WPD y Eh)
    TABLA <- rbind(TABLA, data.table(
      Zona=z, Horizonte=horizonte, h=h, Target="WPD", Modelo=modelo_tag,
      n_total_windows=d$n_total_windows, n_train=d$n_train, n_val=d$n_val, n_test=nT,
      RMSE=RMSE_WPD, MAE=MAE_WPD, R2=R2_WPD, Skill_vs_Persist=Skill_WPD,
      Lookback=lookback, Stride=stride,
      Epochs_ran=length(as.numeric(out$hist$history$loss)),
      Batch=hp$batch, units1=hp$units1, units2=hp$units2, dropout=hp$dropout, lr=hp$lr,
      ModeloFile=normp(model_file), PredFile=normp(pred_file),
      FigSerie=normp(pub_wpd), FigResid=normp(res_wpd), FigCurva=normp(anex_curve)
    ), fill=TRUE)

    TABLA <- rbind(TABLA, data.table(
      Zona=z, Horizonte=horizonte, h=h, Target="Eh", Modelo=modelo_tag,
      n_total_windows=d$n_total_windows, n_train=d$n_train, n_val=d$n_val, n_test=sum(okE),
      RMSE=RMSE_Eh, MAE=MAE_Eh, R2=R2_Eh, Skill_vs_Persist=Skill_Eh,
      Lookback=lookback, Stride=stride,
      Epochs_ran=length(as.numeric(out$hist$history$loss)),
      Batch=hp$batch, units1=hp$units1, units2=hp$units2, dropout=hp$dropout, lr=hp$lr,
      ModeloFile=normp(model_file), PredFile=normp(pred_file),
      FigSerie=normp(pub_eh), FigResid=normp(res_eh), FigCurva=normp(anex_curve)
    ), fill=TRUE)

    # guardado incremental
    fwrite(TABLA, file.path(CFG$out_dir, CFG$dir_tablas, "DL_TABLA_COMBINADA_DEFINITIVA.csv"))
    fwrite(PRED_ALL, file.path(CFG$out_dir, CFG$dir_preds, "DL_PRED_TODO_COMBINADO.csv"))

    cat(sprintf("  -> WPD RMSE=%.4f | R2=%.4f | Skill=%.4f\n", RMSE_WPD, R2_WPD, Skill_WPD))
    cat(sprintf("  -> Eh  RMSE=%.4f | R2=%.4f | Skill=%.4f (ok=%d)\n", RMSE_Eh, R2_Eh, Skill_Eh, sum(okE)))
  }
}

# Export finales
f_all <- file.path(CFG$out_dir, CFG$dir_tablas, "DL_TABLA_COMBINADA_DEFINITIVA.csv")
f_wpd <- file.path(CFG$out_dir, CFG$dir_tablas, "DL_TABLA_WPD_COMPLETA.csv")
f_eh  <- file.path(CFG$out_dir, CFG$dir_tablas, "DL_TABLA_Eh_COMPLETA.csv")
f_pred_all <- file.path(CFG$out_dir, CFG$dir_preds, "DL_PRED_TODO_COMBINADO.csv")

fwrite(TABLA, f_all)
fwrite(TABLA[Target=="WPD"], f_wpd)
fwrite(TABLA[Target=="Eh"],  f_eh)
fwrite(PRED_ALL, f_pred_all)

cat("\n=== EXPORTACIÓN ===\n")
cat("TABLA ALL:", normp(f_all), "\n")
cat("TABLA WPD:", normp(f_wpd), "\n")
cat("TABLA Eh :", normp(f_eh), "\n")
cat("PRED ALL :", normp(f_pred_all), "\n")
cat("Figuras publicables:", normp(file.path(CFG$out_dir, CFG$dir_pub)), "\n")
cat("Figuras anexos     :", normp(file.path(CFG$out_dir, CFG$dir_anex)), "\n")
cat("Modelos            :", normp(file.path(CFG$out_dir, CFG$dir_models)), "\n")
cat("\n=== DL PIPELINE (fin) ===\n")

sink()
message("Listo. Tablas: ", normp(f_all), " | Pred: ", normp(f_pred_all))


TDQ
# ============================================================
# TDQ-PIESS vFINAL (Z1BOOST + mini-Z3BOOST-h1) - ESTABLE
# - Base TDQ (caja térmica + pozo + memoria + FNRR)
# - KFAS (estado-espacio) + calibración PI90 (Coverage ~0.90)
# - Exporta: tablas + predicciones + figuras
#
# Boosts (quirúrgicos, sin romper Z2/Z4):
#   Z1: VV maxgap=72, alpha=0.992, KFAS con estacionalidad 24h
#   Z3: alpha=0.985 y SOLO para (Z3,h=1) KFAS con estacionalidad 24h
#
# Robustez:
#   - Contornos faltantes => energía 0 (U_potential nunca NA)
#   - Winsorización suave SOLO cuando se usa estacionalidad (evita KFAS NA/Inf)
#   - inits acotados + fallback a modelo estándar si KFAS falla
#
# Input : C:/Users/UMARIANA/Desktop/Datos.txt
# Output: ./SALIDAS_TDQ_FINAL/
# ============================================================

req_pkgs <- c("data.table","lubridate","zoo","KFAS","ggplot2")
for (p in req_pkgs) if (!requireNamespace(p, quietly=TRUE)) install.packages(p, dependencies=TRUE)
suppressPackageStartupMessages({
  library(data.table); library(lubridate); library(zoo); library(KFAS); library(ggplot2)
})

INPUT_FILE <- ""  # <-- set path
OUT_DIR <- file.path(getwd(), "SALIDAS_TDQ_FINAL")
FIG_DIR <- file.path(OUT_DIR, "FIGURAS")
dir.create(OUT_DIR, showWarnings=FALSE, recursive=TRUE)
dir.create(FIG_DIR, showWarnings=FALSE, recursive=TRUE)

LOG_FILE <- file.path(OUT_DIR, "TDQ_FINAL_LOG.txt")
log_msg <- function(...) {
  msg <- paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " | ", paste(..., collapse=" "))
  cat(msg, "\n"); cat(msg, "\n", file=LOG_FILE, append=TRUE)
}
log_msg("START TDQ-PIESS FINAL | Input:", INPUT_FILE)

HORIZ <- data.table(Horizonte=c("Corto","Medio","Largo"), h=c(1,12,72))
eps <- 1e-8
K   <- 48

# -----------------------------
# Helpers
# -----------------------------
impute_locf <- function(x) {
  x <- na.locf(x, na.rm=FALSE)
  x <- na.locf(x, fromLast=TRUE, na.rm=FALSE)
  x
}
read_any_delim <- function(path) {
  dt <- fread(path, sep="\t", header=TRUE, data.table=TRUE, showProgress=FALSE)
  if (ncol(dt) == 1L) {
    x <- dt[[1]]
    tmp <- tstrsplit(x, split=";", fixed=TRUE)
    if (length(tmp) < 5) tmp <- tstrsplit(x, split=",", fixed=TRUE)
    if (length(tmp) < 5) tmp <- tstrsplit(x, split="\\s+", perl=TRUE)
    if (length(tmp) >= 5) {
      dt <- as.data.table(tmp)[,1:5]
      setnames(dt, c("Estación","FechaYHora","Valor","Zona","Variable"))
    }
  }
  if (!all(c("Estación","FechaYHora","Valor","Zona","Variable") %in% names(dt))) {
    if (ncol(dt) >= 5) setnames(dt, names(dt)[1:5], c("Estación","FechaYHora","Valor","Zona","Variable"))
  }
  dt
}
parse_dt <- function(x) {
  x <- trimws(as.character(x))
  x <- gsub("a\\.?\\s*m\\.?","AM", x, ignore.case=TRUE)
  x <- gsub("p\\.?\\s*m\\.?","PM", x, ignore.case=TRUE)
  suppressWarnings(parse_date_time(
    x,
    orders=c(
      "Ymd HMS","Ymd HM","dmY HMS","dmY HM","mdY HMS","mdY HM",
      "Y-m-d H:M:S","Y-m-d H:M","d/m/Y H:M:S","d/m/Y H:M",
      "m/d/Y H:M:S","m/d/Y H:M","d-m-Y H:M:S","d-m-Y H:M",
      "Ymd IMS p","dmY IMS p","mdY IMS p","d/m/Y IMS p","m/d/Y IMS p"
    ),
    tz="America/Bogota"
  ))
}
roll_apply_safe <- function(x, k, fun) {
  zoo::rollapplyr(x, width=k, FUN=function(v) fun(v), fill=NA_real_, partial=TRUE, by.column=FALSE)
}
rmean <- function(v) { m <- mean(v, na.rm=TRUE); ifelse(is.finite(m), m, NA_real_) }
rsd   <- function(v) { s <- sd(v, na.rm=TRUE);   ifelse(is.finite(s), s, NA_real_) }
roll_mean <- function(x,k) zoo::rollapplyr(x, k, mean, fill=NA_real_, partial=TRUE, na.rm=TRUE)
roll_sd   <- function(x,k) zoo::rollapplyr(x, k, sd,   fill=NA_real_, partial=TRUE, na.rm=TRUE)

metrics <- function(y, yhat) {
  ok <- is.finite(y) & is.finite(yhat); y <- y[ok]; yhat <- yhat[ok]
  if (length(y) < 20) return(list(RMSE=NA, MAE=NA, R2=NA))
  rmse <- sqrt(mean((y-yhat)^2))
  mae  <- mean(abs(y-yhat))
  r2   <- 1 - sum((y-yhat)^2) / sum((y-mean(y))^2)
  list(RMSE=rmse, MAE=mae, R2=r2)
}
persistence_forecast <- function(y, h) shift(y, h)

# KFAS models
fit_kfas_reg_std <- function(y, X) {
  SSModel(y ~ -1 + SSMtrend(1, Q=list(NA)) + X, H=matrix(NA))
}
fit_kfas_reg_season24 <- function(y, X) {
  SSModel(
    y ~ -1 +
      SSMtrend(1, Q=list(NA)) +
      SSMseasonal(period=24, sea.type="trigonometric", Q=matrix(NA)) +
      X,
    H=matrix(NA)
  )
}

# TDQ memory alpha per zone
alpha_by_zona <- function(z) {
  if (z == 1L) return(0.992)
  if (z == 3L) return(0.985)
  0.97
}

# ============================================================
# 1) Load + hourly
# ============================================================
dt <- read_any_delim(INPUT_FILE)
stopifnot(all(c("Estación","FechaYHora","Valor","Zona","Variable") %in% names(dt)))

dt[, Zona := suppressWarnings(as.integer(as.character(Zona)))]
dt[, Valor := suppressWarnings(as.numeric(as.character(Valor)))]
dt <- dt[!is.na(Zona) & !is.na(Valor)]
dt[, Variable := trimws(as.character(Variable))]
dt[, Fecha := parse_dt(FechaYHora)]
dt <- dt[!is.na(Fecha)]
setorder(dt, Zona, Variable, Fecha)
log_msg("OK lectura + fechas | rows:", nrow(dt), "| zonas:", paste(sort(unique(dt$Zona)), collapse=","))

dt[, FechaHora := floor_date(Fecha, unit="hour")]

agg_fun <- function(varname, x) {
  vn <- tolower(varname)
  if (vn %in% c("pr","prec","precipitacion","precipitación")) return(sum(x, na.rm=TRUE))
  mean(x, na.rm=TRUE)
}
dt_ag <- dt[, .(Valor = agg_fun(Variable[1], Valor)), by=.(Zona, FechaHora, Variable)]
wide0 <- dcast(dt_ag, Zona + FechaHora ~ Variable, value.var="Valor")
setorder(wide0, Zona, FechaHora)

if (!("VV" %in% names(wide0))) stop("ERROR: No se encontró la variable 'VV' en el archivo.")
log_msg("OK hourly wide | rows:", nrow(wide0), "| cols:", ncol(wide0))

# ============================================================
# 2) Completar malla por zona + imputación VV (Z1 maxgap=72)
# ============================================================
zonas <- sort(unique(wide0$Zona))
grid <- rbindlist(lapply(zonas, function(z){
  wz <- wide0[Zona==z]
  data.table(Zona=z, FechaHora=seq(min(wz$FechaHora), max(wz$FechaHora), by="hour"))
}))
wide <- merge(grid, wide0, by=c("Zona","FechaHora"), all.x=TRUE)
setorder(wide, Zona, FechaHora)
log_msg("OK malla completa | rows:", nrow(wide))

wide[, VV := {
  v <- as.numeric(VV)
  mg <- if (.BY[[1]] == 1L) 72 else 24
  v <- na.approx(v, na.rm=FALSE, maxgap=mg)
  v <- impute_locf(v)
  v
}, by=Zona]

# Features temporales (fase)
wide[, hour := hour(FechaHora)]
wide[, wday := wday(FechaHora)]
wide[, hour_sin := sin(2*pi*hour/24)]
wide[, hour_cos := cos(2*pi*hour/24)]
wide[, wday_sin := sin(2*pi*wday/7)]
wide[, wday_cos := cos(2*pi*wday/7)]

# ============================================================
# 3) Física base: rho(T,P) y WPD
# ============================================================
R_d <- 287.05
to_Pa <- function(p){
  p <- as.numeric(p); if (all(is.na(p))) return(p)
  med <- median(p, na.rm=TRUE); if (is.finite(med) && med < 2000) p*100 else p
}
to_K <- function(t){
  t <- as.numeric(t); if (all(is.na(t))) return(t)
  med <- median(t, na.rm=TRUE); if (is.finite(med) && med < 100) t+273.15 else t
}

wide[, PA_Pa := if ("PA" %in% names(wide)) to_Pa(PA) else NA_real_]
temp_col <- intersect(names(wide), c("TM","T","Temp","TEMP","Temperatura"))
temp_col <- if (length(temp_col)>0) temp_col[1] else NA_character_
wide[, T_K := if (!is.na(temp_col)) to_K(get(temp_col)) else NA_real_]

wide[, PA_Pa := if (!all(is.na(PA_Pa))) impute_locf(PA_Pa) else PA_Pa, by=Zona]
wide[, T_K   := if (!all(is.na(T_K)))   impute_locf(T_K)   else T_K,   by=Zona]

wide[, rho := {
  if (all(is.na(PA_Pa)) || all(is.na(T_K))) 1.00 else impute_locf(PA_Pa/(R_d*T_K))
}, by=Zona]

wide[, WPD := 0.5 * rho * (VV^3)]
wide <- wide[is.finite(WPD)]
log_msg("OK fisica base | rows usable:", nrow(wide))

# ============================================================
# 4) Ensamble rolling + CTI
# ============================================================
wide[, VV_mean := roll_apply_safe(VV, K, rmean), by=Zona]
wide[, VV_sd   := roll_apply_safe(VV, K, rsd),   by=Zona]
wide[, VV_mean := impute_locf(VV_mean), by=Zona]
wide[, VV_sd   := pmax(impute_locf(VV_sd), eps), by=Zona]
wide[, T_eff := VV_sd]
wide[, CTI := log1p(abs(WPD)) / (1 + abs(VV_sd))]

# ============================================================
# 5) Pozo de potencial (contornos faltantes => 0)
# ============================================================
bound_vars <- intersect(names(wide), c("PA_Pa","T_K","HR","PR","NU","EV","DV"))

for (v in bound_vars) {
  m <- roll_mean(wide[[v]], K)
  s <- roll_sd(wide[[v]], K)
  a <- (wide[[v]] - m) / (s + eps)
  uv <- abs(a); uv[!is.finite(uv)] <- 0
  set(wide, j=paste0("u_", v), value=uv)
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

wide[, U0 := roll_mean(U_potential, K), by=Zona]
wide[, U0 := impute_locf(U0), by=Zona]
wide[!is.finite(U0), U0 := 0]

wide[, B_barrier := pmax(0, U_potential - U0)]
wide[, C_conf := B_barrier / (T_eff + eps)]
wide[, tau_trans := exp(-C_conf)]
wide[, Z_part := 1 + exp(-C_conf)]
wide[, F_free := -(T_eff) * log(Z_part + eps)]

# ============================================================
# 6) Memoria + FNRR (alpha por zona)
# ============================================================
wide[, M_memory := {
  a <- alpha_by_zona(.BY[[1]])
  m <- rep(0, .N)
  for (i in seq_len(.N)) {
    b <- B_barrier[i]; if (!is.finite(b)) b <- 0
    if (i == 1) m[i] <- b else m[i] <- a*m[i-1] + (1-a)*b
  }
  m
}, by=Zona]

wide[, U_phys := log1p(C_conf) + log1p(T_eff) + log1p(M_memory)]
wide[!is.finite(U_phys), U_phys := 0]

wide[, `:=`(U_med = median(U_phys, na.rm=TRUE), U_iqr = IQR(U_phys, na.rm=TRUE)), by=Zona]
wide[!is.finite(U_iqr) | U_iqr <= 0, U_iqr := 1, by=Zona]
wide[, U_z := (U_phys - U_med) / (U_iqr + eps)]

gamma <- 1.2
wide[, FNRR := 1 / (1 + exp(-gamma * U_z))]
wide[!is.finite(FNRR), FNRR := 0.5]

wide[, regime_TDQ := cut(FNRR, breaks=c(-Inf,0.33,0.66,Inf),
                         labels=c("Orden_Alto","Orden_Medio","Orden_Bajo"))]

diag <- wide[, .(
  N_total=.N,
  N_WPD=sum(is.finite(WPD)),
  N_FNRR=sum(is.finite(FNRR)),
  FNRR_p10=quantile(FNRR, 0.10, na.rm=TRUE),
  FNRR_p50=quantile(FNRR, 0.50, na.rm=TRUE),
  FNRR_p90=quantile(FNRR, 0.90, na.rm=TRUE)
), by=Zona]
fwrite(diag, file.path(OUT_DIR, "DIAGNOSTICO_FILAS_POR_ZONA.csv"))

wide <- wide[is.finite(WPD) & is.finite(FNRR)]
log_msg("OK features TDQ | rows modelables:", nrow(wide))

# ============================================================
# 7) Modelado por zona/h + PI90 calibrado (Z1 y Z3(h1) seasonal)
# ============================================================
run_zone_h <- function(dfz, h, horizon_name) {
  df <- copy(dfz)
  df[, y := shift(WPD, type="lead", n=h)]
  df <- df[is.finite(y)]
  if (nrow(df) < 2000) return(NULL)

  reg_cols <- intersect(c(
    "WPD","VV","rho","VV_mean","VV_sd","CTI",
    "U_potential","B_barrier","tau_trans","F_free","C_conf",
    "M_memory","FNRR","U_phys",
    "hour_sin","hour_cos","wday_sin","wday_cos"
  ), names(df))

  X <- as.matrix(df[, ..reg_cols])
  for (j in seq_len(ncol(X))) {
    col <- X[,j]
    med <- median(col, na.rm=TRUE); if (!is.finite(med)) med <- 0
    col[!is.finite(col)] <- med
    X[,j] <- col
  }
  keep <- apply(X, 2, function(col) sd(col, na.rm=TRUE) > 0)
  X <- X[, keep, drop=FALSE]
  X <- scale(X)

  y <- df$y
  n <- length(y)
  n_test <- max(9630, floor(0.20*n))
  idx_te <- (n - n_test + 1):n

  # Condición de seasonal:
  use_seasonal <- (df$Zona[1] == 1L) || (df$Zona[1] == 3L && h == 1L)

  # Robustez: winsorizar SOLO cuando hay seasonal (evita KFAS singular)
  if (use_seasonal) {
    qy <- quantile(y, c(0.005, 0.995), na.rm=TRUE)
    y <- pmin(pmax(y, qy[1]), qy[2])

    if (ncol(X) > 0) {
      X <- apply(X, 2, function(col){
        if (!all(is.finite(col))) col[!is.finite(col)] <- median(col, na.rm=TRUE)
        qc <- quantile(col, c(0.001, 0.999), na.rm=TRUE)
        col <- pmin(pmax(col, qc[1]), qc[2])
        col
      })
      X <- as.matrix(X)
      X <- scale(X)
    }
  }

  model0 <- if (use_seasonal) fit_kfas_reg_season24(y, X) else fit_kfas_reg_std(y, X)

  v0 <- var(y, na.rm=TRUE); if (!is.finite(v0) || v0<=0) v0 <- 1
  init_vec <- rep(log(v0), 2)
  init_vec <- pmin(pmax(init_vec, log(1e-6)), log(1e6))

  ok_fit <- TRUE
  fit <- tryCatch(
    fitSSM(model0, inits=init_vec, method="BFGS", control=list(maxit=300)),
    error=function(e){ ok_fit <<- FALSE; e }
  )

  if (!ok_fit) {
    # Fallback (garantiza salida)
    model_fallback <- fit_kfas_reg_std(y, X)
    fit <- fitSSM(model_fallback, inits=init_vec, method="BFGS", control=list(maxit=300))
  }

  kfs <- KFS(fit$model, filtering="mean")
  yhat <- as.numeric(kfs$muhat)

  y_te <- y[idx_te]; yhat_te <- yhat[idx_te]
  y_pers <- persistence_forecast(df$WPD, h)[idx_te]

  m <- metrics(y_te, yhat_te)
  mp <- metrics(y_te, y_pers)
  skill <- if (is.finite(m$RMSE) && is.finite(mp$RMSE) && mp$RMSE>0) 1 - (m$RMSE/mp$RMSE) else NA_real_

  # PI90 base
  sigma_base <- sd(diff(df$WPD), na.rm=TRUE)
  if (!is.finite(sigma_base) || sigma_base<=0) sigma_base <- sd(df$WPD, na.rm=TRUE)
  if (!is.finite(sigma_base) || sigma_base<=0) sigma_base <- 1

  k0 <- 1.0; k1 <- 2.5; z <- 1.645
  sigma_t <- sigma_base * (k0 + k1 * df$FNRR[idx_te])

  PI_low90  <- yhat_te - z*sigma_t
  PI_high90 <- yhat_te + z*sigma_t
  cover90_before <- mean(y_te >= PI_low90 & y_te <= PI_high90, na.rm=TRUE)

  # Calibración PI90 (meta ~0.90)
  resid <- abs(y_te - yhat_te)
  ratio <- resid / (z*sigma_t + eps)
  c_PI90 <- as.numeric(quantile(ratio, 0.90, na.rm=TRUE))
  if (!is.finite(c_PI90) || c_PI90 <= 0) c_PI90 <- 1

  sigma_t_cal <- c_PI90 * sigma_t
  PI_low90_c  <- yhat_te - z*sigma_t_cal
  PI_high90_c <- yhat_te + z*sigma_t_cal
  cover90_after <- mean(y_te >= PI_low90_c & y_te <= PI_high90_c, na.rm=TRUE)

  tab <- data.table(
    Zona=df$Zona[1], Horizonte=horizon_name, h=h,
    Modelo=if (use_seasonal) "TDQ_PIESS_KFAS_SEASON24" else "TDQ_PIESS_KFAS",
    n_test=length(y_te),
    RMSE=m$RMSE, MAE=m$MAE, R2=m$R2,
    Skill_vs_Persist=skill,
    Coverage_PI90_before=cover90_before,
    Coverage_PI90_after=cover90_after,
    c_PI90=c_PI90,
    FNRR_mean_test=mean(df$FNRR[idx_te], na.rm=TRUE)
  )

  preds <- data.table(
    Zona=df$Zona[1], Horizonte=horizon_name, h=h,
    FechaHora=df$FechaHora[idx_te],
    y_true=y_te, y_pred=yhat_te, y_persist=y_pers,
    FNRR=df$FNRR[idx_te], regime_TDQ=as.character(df$regime_TDQ[idx_te]),
    PI_low90=PI_low90_c, PI_high90=PI_high90_c
  )

  list(tabla=tab, preds=preds)
}

tabs <- list(); preds_all <- list()

for (z in sort(unique(wide$Zona))) {
  log_msg("ZONA", z, "| start")
  dfz <- wide[Zona==z]
  for (i in 1:nrow(HORIZ)) {
    hz <- HORIZ$h[i]; hn <- HORIZ$Horizonte[i]
    log_msg("  ->", hn, "(h=", hz, ")")
    out <- run_zone_h(dfz, hz, hn)
    if (!is.null(out)) {
      tabs[[length(tabs)+1]] <- out$tabla
      preds_all[[length(preds_all)+1]] <- out$preds
      fwrite(out$preds, file.path(OUT_DIR, sprintf("TDQ_FINAL_PREDS_Z%d_%s_h%d.csv", z, hn, hz)))
    }
  }
  log_msg("ZONA", z, "| end")
}

TAB_GLOBAL <- rbindlist(tabs, fill=TRUE)
PREDS <- rbindlist(preds_all, fill=TRUE)

fwrite(TAB_GLOBAL, file.path(OUT_DIR, "TDQ_FINAL_TABLA_GLOBAL.csv"))
fwrite(PREDS, file.path(OUT_DIR, "TDQ_FINAL_PREDS_GLOBAL.csv"))

# ============================================================
# 8) Figuras (PNG + PDF)
# ============================================================
TAB_GLOBAL[, Zona := factor(Zona)]
TAB_GLOBAL[, Horizonte := factor(Horizonte, levels=c("Corto","Medio","Largo"))]

save_plot <- function(p, name){
  ggsave(filename=file.path(FIG_DIR, paste0(name, ".png")), plot=p, width=11, height=6, dpi=180)
  ggsave(filename=file.path(FIG_DIR, paste0(name, ".pdf")), plot=p, width=11, height=6)
}

p_skill <- ggplot(TAB_GLOBAL, aes(x=Zona, y=Skill_vs_Persist)) +
  geom_col() + facet_wrap(~Horizonte, nrow=1) +
  labs(title="TDQ FINAL | Skill vs Persistencia", x="Zona", y="Skill") +
  theme_minimal(base_size=12)
save_plot(p_skill, "01_Skill_vs_Persist")

p_r2 <- ggplot(TAB_GLOBAL, aes(x=Zona, y=R2)) +
  geom_col() + facet_wrap(~Horizonte, nrow=1) +
  labs(title="TDQ FINAL | R2 por Zona y Horizonte", x="Zona", y="R2") +
  theme_minimal(base_size=12)
save_plot(p_r2, "02_R2")

p_rmse <- ggplot(TAB_GLOBAL, aes(x=Zona, y=RMSE)) +
  geom_col() + facet_wrap(~Horizonte, nrow=1, scales="free_y") +
  labs(title="TDQ FINAL | RMSE por Zona y Horizonte", x="Zona", y="RMSE") +
  theme_minimal(base_size=12)
save_plot(p_rmse, "03_RMSE")

p_cov <- ggplot(TAB_GLOBAL, aes(x=Zona)) +
  geom_point(aes(y=Coverage_PI90_before), size=3) +
  geom_point(aes(y=Coverage_PI90_after), size=3) +
  facet_wrap(~Horizonte, nrow=1) +
  labs(title="TDQ FINAL | Cobertura PI90 (antes vs calibrada)", x="Zona", y="Coverage") +
  theme_minimal(base_size=12)
save_plot(p_cov, "04_Coverage_PI90_before_after")

# FNRR distribution
p_fnrr <- ggplot(wide, aes(x=FNRR)) +
  geom_density() + facet_wrap(~Zona, nrow=2) +
  labs(title="FNRR | Distribución por Zona", x="FNRR", y="Densidad") +
  theme_minimal(base_size=12)
save_plot(p_fnrr, "05_FNRR_density_by_zone")

# Example series (h=1 and h=12)
PREDS[, Zona := factor(Zona)]
PREDS[, Horizonte := factor(Horizonte, levels=c("Corto","Medio","Largo"))]

plot_example <- function(hz, hn){
  ex <- PREDS[Horizonte==hn & h==hz]
  if (nrow(ex) == 0) return(NULL)
  ex <- ex[order(Zona, FechaHora)][, tail(.SD, 800), by=Zona]
  ggplot(ex, aes(x=FechaHora)) +
    geom_ribbon(aes(ymin=PI_low90, ymax=PI_high90), alpha=0.20) +
    geom_line(aes(y=y_true), linewidth=0.5) +
    geom_line(aes(y=y_pred), linewidth=0.5) +
    facet_wrap(~Zona, scales="free_y", nrow=2) +
    labs(title=paste0("Real vs Pred + PI90 | ", hn, " (h=", hz, ")"),
         x="FechaHora", y="WPD") +
    theme_minimal(base_size=12)
}
p_ex1 <- plot_example(1, "Corto"); if (!is.null(p_ex1)) save_plot(p_ex1, "06_Example_Corto_h1")
p_ex12 <- plot_example(12, "Medio"); if (!is.null(p_ex12)) save_plot(p_ex12, "07_Example_Medio_h12")

sink(file.path(OUT_DIR, "sessionInfo_final.txt")); print(sessionInfo()); sink()
log_msg("OK -> TDQ_FINAL_TABLA_GLOBAL.csv + PREDS + FIGURAS")
log_msg("END TDQ-PIESS FINAL")

cat("\n\n=== TDQ FINAL LISTO ===\n",
    "Salida:", OUT_DIR, "\n",
    "Tabla:  TDQ_FINAL_TABLA_GLOBAL.csv\n",
    "Preds:  TDQ_FINAL_PREDS_GLOBAL.csv\n",
    "Figs:   FIGURAS/*.png y *.pdf\n", sep="")



TDQ-nueva
# ============================================================
# TDQ-PIESS vFINAL (Z1BOOST + mini-Z3BOOST-h1) - ESTABLE
# - Base TDQ (caja térmica + pozo + memoria + FNRR)
# - KFAS (estado-espacio) + calibración PI90 (Coverage ~0.90)
# - Exporta: tablas + predicciones + figuras
#
# Boosts (quirúrgicos, sin romper Z2/Z4):
#   Z1: VV maxgap=72, alpha=0.992, KFAS con estacionalidad 24h
#   Z3: alpha=0.985 y SOLO para (Z3,h=1) KFAS con estacionalidad 24h
#
# Robustez:
#   - Contornos faltantes => energía 0 (U_potential nunca NA)
#   - Winsorización suave SOLO cuando se usa estacionalidad (evita KFAS NA/Inf)
#   - inits acotados + fallback a modelo estándar si KFAS falla
#
# Input : C:/Users/UMARIANA/Desktop/Datos.txt
# Output: ./SALIDAS_TDQ_FINAL/
# ============================================================

req_pkgs <- c("data.table","lubridate","zoo","KFAS","ggplot2")
for (p in req_pkgs) if (!requireNamespace(p, quietly=TRUE)) install.packages(p, dependencies=TRUE)
suppressPackageStartupMessages({
  library(data.table); library(lubridate); library(zoo); library(KFAS); library(ggplot2)
})

INPUT_FILE <- ""  # <-- set path
OUT_DIR <- file.path(getwd(), "SALIDAS_TDQ_FINAL")
FIG_DIR <- file.path(OUT_DIR, "FIGURAS")
dir.create(OUT_DIR, showWarnings=FALSE, recursive=TRUE)
dir.create(FIG_DIR, showWarnings=FALSE, recursive=TRUE)

LOG_FILE <- file.path(OUT_DIR, "TDQ_FINAL_LOG.txt")
log_msg <- function(...) {
  msg <- paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " | ", paste(..., collapse=" "))
  cat(msg, "\n"); cat(msg, "\n", file=LOG_FILE, append=TRUE)
}
log_msg("START TDQ-PIESS FINAL | Input:", INPUT_FILE)

HORIZ <- data.table(Horizonte=c("Corto","Medio","Largo"), h=c(1,12,72))
eps <- 1e-8
K   <- 48

# -----------------------------
# Helpers
# -----------------------------
impute_locf <- function(x) {
  x <- na.locf(x, na.rm=FALSE)
  x <- na.locf(x, fromLast=TRUE, na.rm=FALSE)
  x
}
read_any_delim <- function(path) {
  dt <- fread(path, sep="\t", header=TRUE, data.table=TRUE, showProgress=FALSE)
  if (ncol(dt) == 1L) {
    x <- dt[[1]]
    tmp <- tstrsplit(x, split=";", fixed=TRUE)
    if (length(tmp) < 5) tmp <- tstrsplit(x, split=",", fixed=TRUE)
    if (length(tmp) < 5) tmp <- tstrsplit(x, split="\\s+", perl=TRUE)
    if (length(tmp) >= 5) {
      dt <- as.data.table(tmp)[,1:5]
      setnames(dt, c("Estación","FechaYHora","Valor","Zona","Variable"))
    }
  }
  if (!all(c("Estación","FechaYHora","Valor","Zona","Variable") %in% names(dt))) {
    if (ncol(dt) >= 5) setnames(dt, names(dt)[1:5], c("Estación","FechaYHora","Valor","Zona","Variable"))
  }
  dt
}
parse_dt <- function(x) {
  x <- trimws(as.character(x))
  x <- gsub("a\\.?\\s*m\\.?","AM", x, ignore.case=TRUE)
  x <- gsub("p\\.?\\s*m\\.?","PM", x, ignore.case=TRUE)
  suppressWarnings(parse_date_time(
    x,
    orders=c(
      "Ymd HMS","Ymd HM","dmY HMS","dmY HM","mdY HMS","mdY HM",
      "Y-m-d H:M:S","Y-m-d H:M","d/m/Y H:M:S","d/m/Y H:M",
      "m/d/Y H:M:S","m/d/Y H:M","d-m-Y H:M:S","d-m-Y H:M",
      "Ymd IMS p","dmY IMS p","mdY IMS p","d/m/Y IMS p","m/d/Y IMS p"
    ),
    tz="America/Bogota"
  ))
}
roll_apply_safe <- function(x, k, fun) {
  zoo::rollapplyr(x, width=k, FUN=function(v) fun(v), fill=NA_real_, partial=TRUE, by.column=FALSE)
}
rmean <- function(v) { m <- mean(v, na.rm=TRUE); ifelse(is.finite(m), m, NA_real_) }
rsd   <- function(v) { s <- sd(v, na.rm=TRUE);   ifelse(is.finite(s), s, NA_real_) }
roll_mean <- function(x,k) zoo::rollapplyr(x, k, mean, fill=NA_real_, partial=TRUE, na.rm=TRUE)
roll_sd   <- function(x,k) zoo::rollapplyr(x, k, sd,   fill=NA_real_, partial=TRUE, na.rm=TRUE)

metrics <- function(y, yhat) {
  ok <- is.finite(y) & is.finite(yhat); y <- y[ok]; yhat <- yhat[ok]
  if (length(y) < 20) return(list(RMSE=NA, MAE=NA, R2=NA))
  rmse <- sqrt(mean((y-yhat)^2))
  mae  <- mean(abs(y-yhat))
  r2   <- 1 - sum((y-yhat)^2) / sum((y-mean(y))^2)
  list(RMSE=rmse, MAE=mae, R2=r2)
}
persistence_forecast <- function(y, h) shift(y, h)

# KFAS models
fit_kfas_reg_std <- function(y, X) {
  SSModel(y ~ -1 + SSMtrend(1, Q=list(NA)) + X, H=matrix(NA))
}
fit_kfas_reg_season24 <- function(y, X) {
  SSModel(
    y ~ -1 +
      SSMtrend(1, Q=list(NA)) +
      SSMseasonal(period=24, sea.type="trigonometric", Q=matrix(NA)) +
      X,
    H=matrix(NA)
  )
}

# TDQ memory alpha per zone
alpha_by_zona <- function(z) {
  if (z == 1L) return(0.992)
  if (z == 3L) return(0.985)
  0.97
}

# ============================================================
# 1) Load + hourly
# ============================================================
dt <- read_any_delim(INPUT_FILE)
stopifnot(all(c("Estación","FechaYHora","Valor","Zona","Variable") %in% names(dt)))

dt[, Zona := suppressWarnings(as.integer(as.character(Zona)))]
dt[, Valor := suppressWarnings(as.numeric(as.character(Valor)))]
dt <- dt[!is.na(Zona) & !is.na(Valor)]
dt[, Variable := trimws(as.character(Variable))]
dt[, Fecha := parse_dt(FechaYHora)]
dt <- dt[!is.na(Fecha)]
setorder(dt, Zona, Variable, Fecha)
log_msg("OK lectura + fechas | rows:", nrow(dt), "| zonas:", paste(sort(unique(dt$Zona)), collapse=","))

dt[, FechaHora := floor_date(Fecha, unit="hour")]

agg_fun <- function(varname, x) {
  vn <- tolower(varname)
  if (vn %in% c("pr","prec","precipitacion","precipitación")) return(sum(x, na.rm=TRUE))
  mean(x, na.rm=TRUE)
}
dt_ag <- dt[, .(Valor = agg_fun(Variable[1], Valor)), by=.(Zona, FechaHora, Variable)]
wide0 <- dcast(dt_ag, Zona + FechaHora ~ Variable, value.var="Valor")
setorder(wide0, Zona, FechaHora)

if (!("VV" %in% names(wide0))) stop("ERROR: No se encontró la variable 'VV' en el archivo.")
log_msg("OK hourly wide | rows:", nrow(wide0), "| cols:", ncol(wide0))

# ============================================================
# 2) Completar malla por zona + imputación VV (Z1 maxgap=72)
# ============================================================
zonas <- sort(unique(wide0$Zona))
grid <- rbindlist(lapply(zonas, function(z){
  wz <- wide0[Zona==z]
  data.table(Zona=z, FechaHora=seq(min(wz$FechaHora), max(wz$FechaHora), by="hour"))
}))
wide <- merge(grid, wide0, by=c("Zona","FechaHora"), all.x=TRUE)
setorder(wide, Zona, FechaHora)
log_msg("OK malla completa | rows:", nrow(wide))

wide[, VV := {
  v <- as.numeric(VV)
  mg <- if (.BY[[1]] == 1L) 72 else 24
  v <- na.approx(v, na.rm=FALSE, maxgap=mg)
  v <- impute_locf(v)
  v
}, by=Zona]

# Features temporales (fase)
wide[, hour := hour(FechaHora)]
wide[, wday := wday(FechaHora)]
wide[, hour_sin := sin(2*pi*hour/24)]
wide[, hour_cos := cos(2*pi*hour/24)]
wide[, wday_sin := sin(2*pi*wday/7)]
wide[, wday_cos := cos(2*pi*wday/7)]

# ============================================================
# 3) Física base: rho(T,P) y WPD
# ============================================================
R_d <- 287.05
to_Pa <- function(p){
  p <- as.numeric(p); if (all(is.na(p))) return(p)
  med <- median(p, na.rm=TRUE); if (is.finite(med) && med < 2000) p*100 else p
}
to_K <- function(t){
  t <- as.numeric(t); if (all(is.na(t))) return(t)
  med <- median(t, na.rm=TRUE); if (is.finite(med) && med < 100) t+273.15 else t
}

wide[, PA_Pa := if ("PA" %in% names(wide)) to_Pa(PA) else NA_real_]
temp_col <- intersect(names(wide), c("TM","T","Temp","TEMP","Temperatura"))
temp_col <- if (length(temp_col)>0) temp_col[1] else NA_character_
wide[, T_K := if (!is.na(temp_col)) to_K(get(temp_col)) else NA_real_]

wide[, PA_Pa := if (!all(is.na(PA_Pa))) impute_locf(PA_Pa) else PA_Pa, by=Zona]
wide[, T_K   := if (!all(is.na(T_K)))   impute_locf(T_K)   else T_K,   by=Zona]

wide[, rho := {
  if (all(is.na(PA_Pa)) || all(is.na(T_K))) 1.00 else impute_locf(PA_Pa/(R_d*T_K))
}, by=Zona]

wide[, WPD := 0.5 * rho * (VV^3)]
wide <- wide[is.finite(WPD)]
log_msg("OK fisica base | rows usable:", nrow(wide))

# ============================================================
# 4) Ensamble rolling + CTI
# ============================================================
wide[, VV_mean := roll_apply_safe(VV, K, rmean), by=Zona]
wide[, VV_sd   := roll_apply_safe(VV, K, rsd),   by=Zona]
wide[, VV_mean := impute_locf(VV_mean), by=Zona]
wide[, VV_sd   := pmax(impute_locf(VV_sd), eps), by=Zona]
wide[, T_eff := VV_sd]
wide[, CTI := log1p(abs(WPD)) / (1 + abs(VV_sd))]

# ============================================================
# 5) Pozo de potencial (contornos faltantes => 0)
# ============================================================
bound_vars <- intersect(names(wide), c("PA_Pa","T_K","HR","PR","NU","EV","DV"))

for (v in bound_vars) {
  m <- roll_mean(wide[[v]], K)
  s <- roll_sd(wide[[v]], K)
  a <- (wide[[v]] - m) / (s + eps)
  uv <- abs(a); uv[!is.finite(uv)] <- 0
  set(wide, j=paste0("u_", v), value=uv)
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

wide[, U0 := roll_mean(U_potential, K), by=Zona]
wide[, U0 := impute_locf(U0), by=Zona]
wide[!is.finite(U0), U0 := 0]

wide[, B_barrier := pmax(0, U_potential - U0)]
wide[, C_conf := B_barrier / (T_eff + eps)]
wide[, tau_trans := exp(-C_conf)]
wide[, Z_part := 1 + exp(-C_conf)]
wide[, F_free := -(T_eff) * log(Z_part + eps)]

# ============================================================
# 6) Memoria + FNRR (alpha por zona)
# ============================================================
wide[, M_memory := {
  a <- alpha_by_zona(.BY[[1]])
  m <- rep(0, .N)
  for (i in seq_len(.N)) {
    b <- B_barrier[i]; if (!is.finite(b)) b <- 0
    if (i == 1) m[i] <- b else m[i] <- a*m[i-1] + (1-a)*b
  }
  m
}, by=Zona]

wide[, U_phys := log1p(C_conf) + log1p(T_eff) + log1p(M_memory)]
wide[!is.finite(U_phys), U_phys := 0]

wide[, `:=`(U_med = median(U_phys, na.rm=TRUE), U_iqr = IQR(U_phys, na.rm=TRUE)), by=Zona]
wide[!is.finite(U_iqr) | U_iqr <= 0, U_iqr := 1, by=Zona]
wide[, U_z := (U_phys - U_med) / (U_iqr + eps)]

gamma <- 1.2
wide[, FNRR := 1 / (1 + exp(-gamma * U_z))]
wide[!is.finite(FNRR), FNRR := 0.5]

wide[, regime_TDQ := cut(FNRR, breaks=c(-Inf,0.33,0.66,Inf),
                         labels=c("Orden_Alto","Orden_Medio","Orden_Bajo"))]

diag <- wide[, .(
  N_total=.N,
  N_WPD=sum(is.finite(WPD)),
  N_FNRR=sum(is.finite(FNRR)),
  FNRR_p10=quantile(FNRR, 0.10, na.rm=TRUE),
  FNRR_p50=quantile(FNRR, 0.50, na.rm=TRUE),
  FNRR_p90=quantile(FNRR, 0.90, na.rm=TRUE)
), by=Zona]
fwrite(diag, file.path(OUT_DIR, "DIAGNOSTICO_FILAS_POR_ZONA.csv"))

wide <- wide[is.finite(WPD) & is.finite(FNRR)]
log_msg("OK features TDQ | rows modelables:", nrow(wide))

# ============================================================
# 7) Modelado por zona/h + PI90 calibrado (Z1 y Z3(h1) seasonal)
# ============================================================
run_zone_h <- function(dfz, h, horizon_name) {
  df <- copy(dfz)
  df[, y := shift(WPD, type="lead", n=h)]
  df <- df[is.finite(y)]
  if (nrow(df) < 2000) return(NULL)

  reg_cols <- intersect(c(
    "WPD","VV","rho","VV_mean","VV_sd","CTI",
    "U_potential","B_barrier","tau_trans","F_free","C_conf",
    "M_memory","FNRR","U_phys",
    "hour_sin","hour_cos","wday_sin","wday_cos"
  ), names(df))

  X <- as.matrix(df[, ..reg_cols])
  for (j in seq_len(ncol(X))) {
    col <- X[,j]
    med <- median(col, na.rm=TRUE); if (!is.finite(med)) med <- 0
    col[!is.finite(col)] <- med
    X[,j] <- col
  }
  keep <- apply(X, 2, function(col) sd(col, na.rm=TRUE) > 0)
  X <- X[, keep, drop=FALSE]
  X <- scale(X)

  y <- df$y
  n <- length(y)
  n_test <- max(9630, floor(0.20*n))
  idx_te <- (n - n_test + 1):n

  # Condición de seasonal:
  use_seasonal <- (df$Zona[1] == 1L) || (df$Zona[1] == 3L && h == 1L)

  # Robustez: winsorizar SOLO cuando hay seasonal (evita KFAS singular)
  if (use_seasonal) {
    qy <- quantile(y, c(0.005, 0.995), na.rm=TRUE)
    y <- pmin(pmax(y, qy[1]), qy[2])

    if (ncol(X) > 0) {
      X <- apply(X, 2, function(col){
        if (!all(is.finite(col))) col[!is.finite(col)] <- median(col, na.rm=TRUE)
        qc <- quantile(col, c(0.001, 0.999), na.rm=TRUE)
        col <- pmin(pmax(col, qc[1]), qc[2])
        col
      })
      X <- as.matrix(X)
      X <- scale(X)
    }
  }

  model0 <- if (use_seasonal) fit_kfas_reg_season24(y, X) else fit_kfas_reg_std(y, X)

  v0 <- var(y, na.rm=TRUE); if (!is.finite(v0) || v0<=0) v0 <- 1
  init_vec <- rep(log(v0), 2)
  init_vec <- pmin(pmax(init_vec, log(1e-6)), log(1e6))

  ok_fit <- TRUE
  fit <- tryCatch(
    fitSSM(model0, inits=init_vec, method="BFGS", control=list(maxit=300)),
    error=function(e){ ok_fit <<- FALSE; e }
  )

  if (!ok_fit) {
    # Fallback (garantiza salida)
    model_fallback <- fit_kfas_reg_std(y, X)
    fit <- fitSSM(model_fallback, inits=init_vec, method="BFGS", control=list(maxit=300))
  }

  kfs <- KFS(fit$model, filtering="mean")
  yhat <- as.numeric(kfs$muhat)

  y_te <- y[idx_te]; yhat_te <- yhat[idx_te]
  y_pers <- persistence_forecast(df$WPD, h)[idx_te]

  m <- metrics(y_te, yhat_te)
  mp <- metrics(y_te, y_pers)
  skill <- if (is.finite(m$RMSE) && is.finite(mp$RMSE) && mp$RMSE>0) 1 - (m$RMSE/mp$RMSE) else NA_real_

  # PI90 base
  sigma_base <- sd(diff(df$WPD), na.rm=TRUE)
  if (!is.finite(sigma_base) || sigma_base<=0) sigma_base <- sd(df$WPD, na.rm=TRUE)
  if (!is.finite(sigma_base) || sigma_base<=0) sigma_base <- 1

  k0 <- 1.0; k1 <- 2.5; z <- 1.645
  sigma_t <- sigma_base * (k0 + k1 * df$FNRR[idx_te])

  PI_low90  <- yhat_te - z*sigma_t
  PI_high90 <- yhat_te + z*sigma_t
  cover90_before <- mean(y_te >= PI_low90 & y_te <= PI_high90, na.rm=TRUE)

  # Calibración PI90 (meta ~0.90)
  resid <- abs(y_te - yhat_te)
  ratio <- resid / (z*sigma_t + eps)
  c_PI90 <- as.numeric(quantile(ratio, 0.90, na.rm=TRUE))
  if (!is.finite(c_PI90) || c_PI90 <= 0) c_PI90 <- 1

  sigma_t_cal <- c_PI90 * sigma_t
  PI_low90_c  <- yhat_te - z*sigma_t_cal
  PI_high90_c <- yhat_te + z*sigma_t_cal
  cover90_after <- mean(y_te >= PI_low90_c & y_te <= PI_high90_c, na.rm=TRUE)

  tab <- data.table(
    Zona=df$Zona[1], Horizonte=horizon_name, h=h,
    Modelo=if (use_seasonal) "TDQ_PIESS_KFAS_SEASON24" else "TDQ_PIESS_KFAS",
    n_test=length(y_te),
    RMSE=m$RMSE, MAE=m$MAE, R2=m$R2,
    Skill_vs_Persist=skill,
    Coverage_PI90_before=cover90_before,
    Coverage_PI90_after=cover90_after,
    c_PI90=c_PI90,
    FNRR_mean_test=mean(df$FNRR[idx_te], na.rm=TRUE)
  )

  preds <- data.table(
    Zona=df$Zona[1], Horizonte=horizon_name, h=h,
    FechaHora=df$FechaHora[idx_te],
    y_true=y_te, y_pred=yhat_te, y_persist=y_pers,
    FNRR=df$FNRR[idx_te], regime_TDQ=as.character(df$regime_TDQ[idx_te]),
    PI_low90=PI_low90_c, PI_high90=PI_high90_c
  )

  list(tabla=tab, preds=preds)
}

tabs <- list(); preds_all <- list()

for (z in sort(unique(wide$Zona))) {
  log_msg("ZONA", z, "| start")
  dfz <- wide[Zona==z]
  for (i in 1:nrow(HORIZ)) {
    hz <- HORIZ$h[i]; hn <- HORIZ$Horizonte[i]
    log_msg("  ->", hn, "(h=", hz, ")")
    out <- run_zone_h(dfz, hz, hn)
    if (!is.null(out)) {
      tabs[[length(tabs)+1]] <- out$tabla
      preds_all[[length(preds_all)+1]] <- out$preds
      fwrite(out$preds, file.path(OUT_DIR, sprintf("TDQ_FINAL_PREDS_Z%d_%s_h%d.csv", z, hn, hz)))
    }
  }
  log_msg("ZONA", z, "| end")
}

TAB_GLOBAL <- rbindlist(tabs, fill=TRUE)
PREDS <- rbindlist(preds_all, fill=TRUE)

fwrite(TAB_GLOBAL, file.path(OUT_DIR, "TDQ_FINAL_TABLA_GLOBAL.csv"))
fwrite(PREDS, file.path(OUT_DIR, "TDQ_FINAL_PREDS_GLOBAL.csv"))

# ============================================================
# 8) Figuras (PNG + PDF)
# ============================================================
TAB_GLOBAL[, Zona := factor(Zona)]
TAB_GLOBAL[, Horizonte := factor(Horizonte, levels=c("Corto","Medio","Largo"))]

save_plot <- function(p, name){
  ggsave(filename=file.path(FIG_DIR, paste0(name, ".png")), plot=p, width=11, height=6, dpi=180)
  ggsave(filename=file.path(FIG_DIR, paste0(name, ".pdf")), plot=p, width=11, height=6)
}

p_skill <- ggplot(TAB_GLOBAL, aes(x=Zona, y=Skill_vs_Persist)) +
  geom_col() + facet_wrap(~Horizonte, nrow=1) +
  labs(title="TDQ FINAL | Skill vs Persistencia", x="Zona", y="Skill") +
  theme_minimal(base_size=12)
save_plot(p_skill, "01_Skill_vs_Persist")

p_r2 <- ggplot(TAB_GLOBAL, aes(x=Zona, y=R2)) +
  geom_col() + facet_wrap(~Horizonte, nrow=1) +
  labs(title="TDQ FINAL | R2 por Zona y Horizonte", x="Zona", y="R2") +
  theme_minimal(base_size=12)
save_plot(p_r2, "02_R2")

p_rmse <- ggplot(TAB_GLOBAL, aes(x=Zona, y=RMSE)) +
  geom_col() + facet_wrap(~Horizonte, nrow=1, scales="free_y") +
  labs(title="TDQ FINAL | RMSE por Zona y Horizonte", x="Zona", y="RMSE") +
  theme_minimal(base_size=12)
save_plot(p_rmse, "03_RMSE")

p_cov <- ggplot(TAB_GLOBAL, aes(x=Zona)) +
  geom_point(aes(y=Coverage_PI90_before), size=3) +
  geom_point(aes(y=Coverage_PI90_after), size=3) +
  facet_wrap(~Horizonte, nrow=1) +
  labs(title="TDQ FINAL | Cobertura PI90 (antes vs calibrada)", x="Zona", y="Coverage") +
  theme_minimal(base_size=12)
save_plot(p_cov, "04_Coverage_PI90_before_after")

# FNRR distribution
p_fnrr <- ggplot(wide, aes(x=FNRR)) +
  geom_density() + facet_wrap(~Zona, nrow=2) +
  labs(title="FNRR | Distribución por Zona", x="FNRR", y="Densidad") +
  theme_minimal(base_size=12)
save_plot(p_fnrr, "05_FNRR_density_by_zone")

# Example series (h=1 and h=12)
PREDS[, Zona := factor(Zona)]
PREDS[, Horizonte := factor(Horizonte, levels=c("Corto","Medio","Largo"))]

plot_example <- function(hz, hn){
  ex <- PREDS[Horizonte==hn & h==hz]
  if (nrow(ex) == 0) return(NULL)
  ex <- ex[order(Zona, FechaHora)][, tail(.SD, 800), by=Zona]
  ggplot(ex, aes(x=FechaHora)) +
    geom_ribbon(aes(ymin=PI_low90, ymax=PI_high90), alpha=0.20) +
    geom_line(aes(y=y_true), linewidth=0.5) +
    geom_line(aes(y=y_pred), linewidth=0.5) +
    facet_wrap(~Zona, scales="free_y", nrow=2) +
    labs(title=paste0("Real vs Pred + PI90 | ", hn, " (h=", hz, ")"),
         x="FechaHora", y="WPD") +
    theme_minimal(base_size=12)
}
p_ex1 <- plot_example(1, "Corto"); if (!is.null(p_ex1)) save_plot(p_ex1, "06_Example_Corto_h1")
p_ex12 <- plot_example(12, "Medio"); if (!is.null(p_ex12)) save_plot(p_ex12, "07_Example_Medio_h12")

sink(file.path(OUT_DIR, "sessionInfo_final.txt")); print(sessionInfo()); sink()
log_msg("OK -> TDQ_FINAL_TABLA_GLOBAL.csv + PREDS + FIGURAS")
log_msg("END TDQ-PIESS FINAL")

cat("\n\n=== TDQ FINAL LISTO ===\n",
    "Salida:", OUT_DIR, "\n",
    "Tabla:  TDQ_FINAL_TABLA_GLOBAL.csv\n",
    "Preds:  TDQ_FINAL_PREDS_GLOBAL.csv\n",
    "Figs:   FIGURAS/*.png y *.pdf\n", sep="")












# ============================================================
# TDQ-PIESS v1.7 - TDQ + Caja Térmica + Pozo + KFAS
# + Calibración PI90 + Export preds + Gráficas (PNG/PDF)
#
# Input : C:/Users/UMARIANA/Desktop/Datos.txt
# Output: ./SALIDAS_TDQ_PIESS/
# ============================================================

req_pkgs <- c("data.table","lubridate","zoo","KFAS","ggplot2")
for (p in req_pkgs) if (!requireNamespace(p, quietly=TRUE)) install.packages(p, dependencies=TRUE)
suppressPackageStartupMessages({
  library(data.table); library(lubridate); library(zoo); library(KFAS); library(ggplot2)
})

INPUT_FILE <- ""  # <-- set path
OUT_DIR <- file.path(getwd(), "SALIDAS_TDQ_PIESS")
FIG_DIR <- file.path(OUT_DIR, "FIGURAS")
dir.create(OUT_DIR, showWarnings=FALSE, recursive=TRUE)
dir.create(FIG_DIR, showWarnings=FALSE, recursive=TRUE)

LOG_FILE <- file.path(OUT_DIR, "TDQ_PIESS_LOG.txt")
log_msg <- function(...) {
  msg <- paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " | ", paste(..., collapse=" "))
  cat(msg, "\n"); cat(msg, "\n", file=LOG_FILE, append=TRUE)
}
log_msg("START TDQ-PIESS v1.7 | Input:", INPUT_FILE)

HORIZ <- data.table(Horizonte=c("Corto","Medio","Largo"), h=c(1,12,72))
eps <- 1e-8
K   <- 48

# -----------------------------
# Helpers
# -----------------------------
impute_locf <- function(x) {
  x <- na.locf(x, na.rm=FALSE)
  x <- na.locf(x, fromLast=TRUE, na.rm=FALSE)
  x
}
read_any_delim <- function(path) {
  dt <- fread(path, sep="\t", header=TRUE, data.table=TRUE, showProgress=FALSE)
  if (ncol(dt) == 1L) {
    x <- dt[[1]]
    tmp <- tstrsplit(x, split=";", fixed=TRUE)
    if (length(tmp) < 5) tmp <- tstrsplit(x, split=",", fixed=TRUE)
    if (length(tmp) < 5) tmp <- tstrsplit(x, split="\\s+", perl=TRUE)
    if (length(tmp) >= 5) {
      dt <- as.data.table(tmp)[,1:5]
      setnames(dt, c("Estación","FechaYHora","Valor","Zona","Variable"))
    }
  }
  if (!all(c("Estación","FechaYHora","Valor","Zona","Variable") %in% names(dt))) {
    if (ncol(dt) >= 5) setnames(dt, names(dt)[1:5], c("Estación","FechaYHora","Valor","Zona","Variable"))
  }
  dt
}
parse_dt <- function(x) {
  x <- trimws(as.character(x))
  x <- gsub("a\\.?\\s*m\\.?","AM", x, ignore.case=TRUE)
  x <- gsub("p\\.?\\s*m\\.?","PM", x, ignore.case=TRUE)
  suppressWarnings(parse_date_time(
    x,
    orders=c(
      "Ymd HMS","Ymd HM","dmY HMS","dmY HM","mdY HMS","mdY HM",
      "Y-m-d H:M:S","Y-m-d H:M","d/m/Y H:M:S","d/m/Y H:M",
      "m/d/Y H:M:S","m/d/Y H:M","d-m-Y H:M:S","d-m-Y H:M",
      "Ymd IMS p","dmY IMS p","mdY IMS p","d/m/Y IMS p","m/d/Y IMS p"
    ),
    tz="America/Bogota"
  ))
}
roll_apply_safe <- function(x, k, fun) {
  zoo::rollapplyr(x, width=k, FUN=function(v) fun(v), fill=NA_real_, partial=TRUE, by.column=FALSE)
}
rmean <- function(v) { m <- mean(v, na.rm=TRUE); ifelse(is.finite(m), m, NA_real_) }
rsd   <- function(v) { s <- sd(v, na.rm=TRUE);   ifelse(is.finite(s), s, NA_real_) }
roll_mean <- function(x,k) zoo::rollapplyr(x, k, mean, fill=NA_real_, partial=TRUE, na.rm=TRUE)
roll_sd   <- function(x,k) zoo::rollapplyr(x, k, sd,   fill=NA_real_, partial=TRUE, na.rm=TRUE)

metrics <- function(y, yhat) {
  ok <- is.finite(y) & is.finite(yhat); y <- y[ok]; yhat <- yhat[ok]
  if (length(y) < 20) return(list(RMSE=NA, MAE=NA, R2=NA))
  rmse <- sqrt(mean((y-yhat)^2))
  mae  <- mean(abs(y-yhat))
  r2   <- 1 - sum((y-yhat)^2) / sum((y-mean(y))^2)
  list(RMSE=rmse, MAE=mae, R2=r2)
}
persistence_forecast <- function(y, h) shift(y, h)
fit_kfas_reg <- function(y, X) SSModel(y ~ -1 + SSMtrend(1, Q=list(NA)) + X, H=matrix(NA))

# ============================================================
# 1) Load + hourly
# ============================================================
dt <- read_any_delim(INPUT_FILE)
stopifnot(all(c("Estación","FechaYHora","Valor","Zona","Variable") %in% names(dt)))

dt[, Zona := suppressWarnings(as.integer(as.character(Zona)))]
dt[, Valor := suppressWarnings(as.numeric(as.character(Valor)))]
dt <- dt[!is.na(Zona) & !is.na(Valor)]
dt[, Variable := trimws(as.character(Variable))]
dt[, Fecha := parse_dt(FechaYHora)]
dt <- dt[!is.na(Fecha)]
setorder(dt, Zona, Variable, Fecha)
log_msg("OK lectura + fechas | rows:", nrow(dt), "| zonas:", paste(sort(unique(dt$Zona)), collapse=","))

dt[, FechaHora := floor_date(Fecha, unit="hour")]

agg_fun <- function(varname, x) {
  vn <- tolower(varname)
  if (vn %in% c("pr","prec","precipitacion","precipitación")) return(sum(x, na.rm=TRUE))
  mean(x, na.rm=TRUE)
}
dt_ag <- dt[, .(Valor = agg_fun(Variable[1], Valor)), by=.(Zona, FechaHora, Variable)]
wide0 <- dcast(dt_ag, Zona + FechaHora ~ Variable, value.var="Valor")
setorder(wide0, Zona, FechaHora)

if (!("VV" %in% names(wide0))) stop("ERROR: No se encontró la variable 'VV' en el archivo.")
log_msg("OK hourly wide | rows:", nrow(wide0), "| cols:", ncol(wide0))

# ============================================================
# 2) Completar malla por zona + imputación mínima VV
# ============================================================
zonas <- sort(unique(wide0$Zona))
grid <- rbindlist(lapply(zonas, function(z){
  wz <- wide0[Zona==z]
  data.table(Zona=z, FechaHora=seq(min(wz$FechaHora), max(wz$FechaHora), by="hour"))
}))
wide <- merge(grid, wide0, by=c("Zona","FechaHora"), all.x=TRUE)
setorder(wide, Zona, FechaHora)
log_msg("OK malla completa | rows:", nrow(wide))

wide[, VV := {
  v <- as.numeric(VV)
  v <- na.approx(v, na.rm=FALSE, maxgap=24)
  v <- impute_locf(v)
  v
}, by=Zona]

# ============================================================
# 3) Física base: rho(T,P) y WPD
# ============================================================
R_d <- 287.05
to_Pa <- function(p){
  p <- as.numeric(p); if (all(is.na(p))) return(p)
  med <- median(p, na.rm=TRUE); if (is.finite(med) && med < 2000) p*100 else p
}
to_K <- function(t){
  t <- as.numeric(t); if (all(is.na(t))) return(t)
  med <- median(t, na.rm=TRUE); if (is.finite(med) && med < 100) t+273.15 else t
}

wide[, PA_Pa := if ("PA" %in% names(wide)) to_Pa(PA) else NA_real_]
temp_col <- intersect(names(wide), c("TM","T","Temp","TEMP","Temperatura"))
temp_col <- if (length(temp_col)>0) temp_col[1] else NA_character_
wide[, T_K := if (!is.na(temp_col)) to_K(get(temp_col)) else NA_real_]

wide[, PA_Pa := if (!all(is.na(PA_Pa))) impute_locf(PA_Pa) else PA_Pa, by=Zona]
wide[, T_K   := if (!all(is.na(T_K)))   impute_locf(T_K)   else T_K,   by=Zona]

wide[, rho := {
  if (all(is.na(PA_Pa)) || all(is.na(T_K))) 1.00 else impute_locf(PA_Pa/(R_d*T_K))
}, by=Zona]

wide[, WPD := 0.5 * rho * (VV^3)]
wide <- wide[is.finite(WPD)]
log_msg("OK fisica base | rows usable:", nrow(wide))

# ============================================================
# 4) Ensamble (rolling) + CTI
# ============================================================
wide[, VV_mean := roll_apply_safe(VV, K, rmean), by=Zona]
wide[, VV_sd   := roll_apply_safe(VV, K, rsd),   by=Zona]
wide[, VV_mean := impute_locf(VV_mean), by=Zona]
wide[, VV_sd   := pmax(impute_locf(VV_sd), eps), by=Zona]
wide[, T_eff := VV_sd]
wide[, CTI := log1p(abs(WPD)) / (1 + abs(VV_sd))]

# ============================================================
# 5) Pozo de potencial (contornos faltantes => 0 energía)
# ============================================================
bound_vars <- intersect(names(wide), c("PA_Pa","T_K","HR","PR","NU","EV","DV"))

for (v in bound_vars) {
  m <- roll_mean(wide[[v]], K)
  s <- roll_sd(wide[[v]], K)
  a <- (wide[[v]] - m) / (s + eps)
  uv <- abs(a); uv[!is.finite(uv)] <- 0
  set(wide, j=paste0("u_", v), value=uv)
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

wide[, U0 := roll_mean(U_potential, K), by=Zona]
wide[, U0 := impute_locf(U0), by=Zona]
wide[!is.finite(U0), U0 := 0]

wide[, B_barrier := pmax(0, U_potential - U0)]
wide[, C_conf := B_barrier / (T_eff + eps)]
wide[, tau_trans := exp(-C_conf)]
wide[, Z_part := 1 + exp(-C_conf)]
wide[, F_free := -(T_eff) * log(Z_part + eps)]

# ============================================================
# 6) Memoria + FNRR
# ============================================================
alpha <- 0.97
wide[, M_memory := {
  m <- rep(0, .N)
  for (i in seq_len(.N)) {
    b <- B_barrier[i]; if (!is.finite(b)) b <- 0
    if (i == 1) m[i] <- b else m[i] <- alpha*m[i-1] + (1-alpha)*b
  }
  m
}, by=Zona]

wide[, U_phys := log1p(C_conf) + log1p(T_eff) + log1p(M_memory)]
wide[!is.finite(U_phys), U_phys := 0]

wide[, `:=`(U_med = median(U_phys, na.rm=TRUE), U_iqr = IQR(U_phys, na.rm=TRUE)), by=Zona]
wide[!is.finite(U_iqr) | U_iqr <= 0, U_iqr := 1, by=Zona]
wide[, U_z := (U_phys - U_med) / (U_iqr + eps)]

gamma <- 1.2
wide[, FNRR := 1 / (1 + exp(-gamma * U_z))]
wide[!is.finite(FNRR), FNRR := 0.5]

wide[, regime_TDQ := cut(FNRR, breaks=c(-Inf,0.33,0.66,Inf),
                         labels=c("Orden_Alto","Orden_Medio","Orden_Bajo"))]

# Diagnóstico
diag <- wide[, .(
  N_total=.N,
  N_WPD=sum(is.finite(WPD)),
  N_FNRR=sum(is.finite(FNRR)),
  FNRR_p10=quantile(FNRR, 0.10, na.rm=TRUE),
  FNRR_p50=quantile(FNRR, 0.50, na.rm=TRUE),
  FNRR_p90=quantile(FNRR, 0.90, na.rm=TRUE)
), by=Zona]
fwrite(diag, file.path(OUT_DIR, "DIAGNOSTICO_FILAS_POR_ZONA.csv"))

wide <- wide[is.finite(WPD) & is.finite(FNRR)]
log_msg("OK features TDQ | rows modelables:", nrow(wide))

# ============================================================
# 7) Modelado por zona/h + PI90 calibrado
# ============================================================
run_zone_h <- function(dfz, h, horizon_name) {
  df <- copy(dfz)
  df[, y := shift(WPD, type="lead", n=h)]
  df <- df[is.finite(y)]
  if (nrow(df) < 2000) return(NULL)

  reg_cols <- intersect(c(
    "WPD","VV","rho","VV_mean","VV_sd","CTI",
    "U_potential","B_barrier","tau_trans","F_free","C_conf",
    "M_memory","FNRR","U_phys"
  ), names(df))

  X <- as.matrix(df[, ..reg_cols])

  # Orden TDQ: NA -> mediana columna
  for (j in seq_len(ncol(X))) {
    col <- X[,j]
    med <- median(col, na.rm=TRUE); if (!is.finite(med)) med <- 0
    col[!is.finite(col)] <- med
    X[,j] <- col
  }
  keep <- apply(X, 2, function(col) sd(col, na.rm=TRUE) > 0)
  X <- X[, keep, drop=FALSE]
  X <- scale(X)

  y <- df$y
  n <- length(y)
  n_test <- max(9630, floor(0.20*n))  # mantén comparable con tus resultados actuales
  idx_te <- (n - n_test + 1):n

  model0 <- fit_kfas_reg(y, X)
  v0 <- var(y, na.rm=TRUE); if (!is.finite(v0) || v0<=0) v0 <- 1
  fit <- fitSSM(model0, inits=rep(log(v0), 2), method="BFGS", control=list(maxit=200))
  kfs <- KFS(fit$model, filtering="mean")
  yhat <- as.numeric(kfs$muhat)

  y_te <- y[idx_te]; yhat_te <- yhat[idx_te]
  y_pers <- persistence_forecast(df$WPD, h)[idx_te]

  # Métricas
  m <- metrics(y_te, yhat_te)
  mp <- metrics(y_te, y_pers)
  skill <- if (is.finite(m$RMSE) && is.finite(mp$RMSE) && mp$RMSE>0) 1 - (m$RMSE/mp$RMSE) else NA_real_

  # PI90 base (antes) - como tu versión actual
  sigma_base <- sd(diff(df$WPD), na.rm=TRUE)
  if (!is.finite(sigma_base) || sigma_base<=0) sigma_base <- sd(df$WPD, na.rm=TRUE)
  if (!is.finite(sigma_base) || sigma_base<=0) sigma_base <- 1

  k0 <- 1.0
  k1 <- 2.5
  z  <- 1.645
  sigma_t <- sigma_base * (k0 + k1 * df$FNRR[idx_te])

  PI_low90  <- yhat_te - z*sigma_t
  PI_high90 <- yhat_te + z*sigma_t
  cover90_before <- mean(y_te >= PI_low90 & y_te <= PI_high90, na.rm=TRUE)

  # ---- CALIBRACIÓN TDQ DEL PI90 (meta: 0.90)
  resid <- abs(y_te - yhat_te)
  ratio <- resid / (z*sigma_t + eps)
  c_PI90 <- as.numeric(quantile(ratio, 0.90, na.rm=TRUE))
  if (!is.finite(c_PI90) || c_PI90 <= 0) c_PI90 <- 1

  sigma_t_cal <- c_PI90 * sigma_t
  PI_low90_c  <- yhat_te - z*sigma_t_cal
  PI_high90_c <- yhat_te + z*sigma_t_cal
  cover90_after <- mean(y_te >= PI_low90_c & y_te <= PI_high90_c, na.rm=TRUE)

  tab <- data.table(
    Zona=df$Zona[1], Horizonte=horizon_name, h=h, Modelo="TDQ_PIESS_KFAS",
    n_test=length(y_te),
    RMSE=m$RMSE, MAE=m$MAE, R2=m$R2,
    Skill_vs_Persist=skill,
    Coverage_PI90_before=cover90_before,
    Coverage_PI90_after=cover90_after,
    c_PI90=c_PI90,
    FNRR_mean_test=mean(df$FNRR[idx_te], na.rm=TRUE)
  )

  preds <- data.table(
    Zona=df$Zona[1], Horizonte=horizon_name, h=h,
    FechaHora=df$FechaHora[idx_te],
    y_true=y_te, y_pred=yhat_te, y_persist=y_pers,
    FNRR=df$FNRR[idx_te], regime_TDQ=as.character(df$regime_TDQ[idx_te]),
    PI_low90_before=PI_low90, PI_high90_before=PI_high90,
    PI_low90=PI_low90_c, PI_high90=PI_high90_c
  )

  list(tabla=tab, preds=preds)
}

tabs <- list()
preds_all <- list()

for (z in sort(unique(wide$Zona))) {
  log_msg("ZONA", z, "| start")
  dfz <- wide[Zona==z]
  for (i in 1:nrow(HORIZ)) {
    hz <- HORIZ$h[i]; hn <- HORIZ$Horizonte[i]
    log_msg("  ->", hn, "(h=", hz, ")")
    out <- run_zone_h(dfz, hz, hn)
    if (!is.null(out)) {
      tabs[[length(tabs)+1]] <- out$tabla
      preds_all[[length(preds_all)+1]] <- out$preds
      fwrite(out$preds, file.path(OUT_DIR, sprintf("TDQ_PIESS_PREDS_Z%d_%s_h%d.csv", z, hn, hz)))
    }
  }
  log_msg("ZONA", z, "| end")
}

TAB_GLOBAL <- rbindlist(tabs, fill=TRUE)
PREDS <- rbindlist(preds_all, fill=TRUE)

fwrite(TAB_GLOBAL, file.path(OUT_DIR, "TDQ_PIESS_TABLA_GLOBAL_MEJORADA.csv"))
fwrite(PREDS, file.path(OUT_DIR, "TDQ_PIESS_PREDS_GLOBAL.csv"))

# ============================================================
# 8) Gráficas (PNG + PDF)
# ============================================================
TAB_GLOBAL[, Zona := factor(Zona)]
TAB_GLOBAL[, Horizonte := factor(Horizonte, levels=c("Corto","Medio","Largo"))]

save_plot <- function(p, name){
  ggsave(filename=file.path(FIG_DIR, paste0(name, ".png")), plot=p, width=11, height=6, dpi=180)
  ggsave(filename=file.path(FIG_DIR, paste0(name, ".pdf")), plot=p, width=11, height=6)
}

p_skill <- ggplot(TAB_GLOBAL, aes(x=Zona, y=Skill_vs_Persist)) +
  geom_col() + facet_wrap(~Horizonte, nrow=1) +
  labs(title="TDQ-PIESS | Skill vs Persistencia", x="Zona", y="Skill (1 - RMSE/RMSE_persist)") +
  theme_minimal(base_size=12)
save_plot(p_skill, "01_Skill_vs_Persist")

p_r2 <- ggplot(TAB_GLOBAL, aes(x=Zona, y=R2)) +
  geom_col() + facet_wrap(~Horizonte, nrow=1) +
  labs(title="TDQ-PIESS | R2 por Zona y Horizonte", x="Zona", y="R2") +
  theme_minimal(base_size=12)
save_plot(p_r2, "02_R2")

p_rmse <- ggplot(TAB_GLOBAL, aes(x=Zona, y=RMSE)) +
  geom_col() + facet_wrap(~Horizonte, nrow=1, scales="free_y") +
  labs(title="TDQ-PIESS | RMSE por Zona y Horizonte", x="Zona", y="RMSE") +
  theme_minimal(base_size=12)
save_plot(p_rmse, "03_RMSE")

p_cov <- ggplot(TAB_GLOBAL, aes(x=Zona)) +
  geom_point(aes(y=Coverage_PI90_before), size=3) +
  geom_point(aes(y=Coverage_PI90_after), size=3) +
  facet_wrap(~Horizonte, nrow=1) +
  labs(title="TDQ-PIESS | Cobertura PI90 (antes vs calibrado)", x="Zona", y="Coverage") +
  theme_minimal(base_size=12)
save_plot(p_cov, "04_Coverage_PI90_before_after")

# FNRR density por zona (desde wide completo)
p_fnrr <- ggplot(wide, aes(x=FNRR)) +
  geom_density() + facet_wrap(~Zona, nrow=2) +
  labs(title="FNRR | Distribución por Zona", x="FNRR", y="Densidad") +
  theme_minimal(base_size=12)
save_plot(p_fnrr, "05_FNRR_density_by_zone")

# Serie ejemplo: real vs pred + PI (h=1 y h=12)
PREDS[, Zona := factor(Zona)]
PREDS[, Horizonte := factor(Horizonte, levels=c("Corto","Medio","Largo"))]

plot_example <- function(hz, hn){
  ex <- PREDS[Horizonte==hn & h==hz]
  if (nrow(ex) == 0) return(NULL)
  # sample para que sea legible (últimos 800 por zona)
  ex <- ex[order(Zona, FechaHora)]
  ex <- ex[, tail(.SD, 800), by=Zona]
  p <- ggplot(ex, aes(x=FechaHora)) +
    geom_ribbon(aes(ymin=PI_low90, ymax=PI_high90), alpha=0.20) +
    geom_line(aes(y=y_true), linewidth=0.5) +
    geom_line(aes(y=y_pred), linewidth=0.5) +
    facet_wrap(~Zona, scales="free_y", nrow=2) +
    labs(title=paste0("Ejemplo TDQ-PIESS | Real vs Pred + PI90 | ", hn, " (h=", hz, ")"),
         x="FechaHora", y="WPD") +
    theme_minimal(base_size=12)
  p
}

p_ex1 <- plot_example(1, "Corto"); if (!is.null(p_ex1)) save_plot(p_ex1, "06_Example_Corto_h1")
p_ex12 <- plot_example(12, "Medio"); if (!is.null(p_ex12)) save_plot(p_ex12, "07_Example_Medio_h12")

sink(file.path(OUT_DIR, "sessionInfo_v1.7.txt")); print(sessionInfo()); sink()
log_msg("OK -> TDQ_PIESS_TABLA_GLOBAL_MEJORADA.csv + PREDS + FIGURAS")
log_msg("END TDQ-PIESS v1.7")

cat("\n\n=== TDQ-PIESS v1.7 LISTO ===\n",
    "Salida:", OUT_DIR, "\n",
    "Tabla mejorada: TDQ_PIESS_TABLA_GLOBAL_MEJORADA.csv\n",
    "Preds global:   TDQ_PIESS_PREDS_GLOBAL.csv\n",
    "Figuras:        SALIDAS_TDQ_PIESS/FIGURAS/*.png y *.pdf\n", sep="")


Predicción años
library(data.table)
library(lubridate)

# --- Archivos reales detectados ---
TAB_FILE <- ""  # <-- set path
PREDS_FILE <- ""  # <-- set path

stopifnot(file.exists(TAB_FILE), file.exists(PREDS_FILE))

# --- Salidas en tu carpeta actual (Cap4) ---
OUT_DIR <- file.path(getwd(), "SALIDAS_CAP4_TDQ_PIESS")
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

TAB <- fread(TAB_FILE)
PREDS <- fread(PREDS_FILE)

# Parse datetime
PREDS[, FechaHora := as.POSIXct(FechaHora, tz="America/Bogota")]
PREDS <- PREDS[is.finite(y_true) & is.finite(y_pred)]

# ============================================================
# 1) ¿Cuál modelo ganó definitivamente?
# ============================================================
TAB[, Horizonte := factor(Horizonte, levels=c("Corto","Medio","Largo"))]

WIN_GLOBAL <- TAB[, .(
  Modelo = "TDQ_PIESS_KFAS",
  Skill_mean = mean(Skill_vs_Persist, na.rm=TRUE),
  RMSE_mean  = mean(RMSE, na.rm=TRUE),
  MAE_mean   = mean(MAE, na.rm=TRUE),
  R2_mean    = mean(R2, na.rm=TRUE),
  PI90_cov_mean = mean(Coverage_PI90_after, na.rm=TRUE),
  FNRR_test_mean = mean(FNRR_mean_test, na.rm=TRUE)
)]

WIN_BY_ZONE <- TAB[, .(
  Skill_mean = mean(Skill_vs_Persist, na.rm=TRUE),
  RMSE_mean  = mean(RMSE, na.rm=TRUE),
  MAE_mean   = mean(MAE, na.rm=TRUE),
  R2_mean    = mean(R2, na.rm=TRUE),
  PI90_cov_mean = mean(Coverage_PI90_after, na.rm=TRUE),
  FNRR_test_mean = mean(FNRR_mean_test, na.rm=TRUE)
), by=.(Zona, Horizonte)]

# ============================================================
# 2) ¿Qué valor promedio tiene FNRR en test?
# ============================================================
FNRR_TEST_PREDS <- PREDS[, .(
  FNRR_mean_test = mean(FNRR, na.rm=TRUE),
  FNRR_p10 = quantile(FNRR, 0.10, na.rm=TRUE),
  FNRR_p50 = quantile(FNRR, 0.50, na.rm=TRUE),
  FNRR_p90 = quantile(FNRR, 0.90, na.rm=TRUE)
), by=.(Zona, Horizonte)]

# ============================================================
# 3) ¿Energía anual promedio por zona? + 4) PI90 anual
#    Asumiendo WPD horaria en W/m^2:
#    Energia anual (kWh/m^2) = sum(WPD)/1000
# ============================================================
PREDS[, Year := year(FechaHora)]

ENERGY_ANNUAL <- PREDS[, .(
  # Observado (potencial histórico)
  E_true_kWh_m2 = sum(y_true, na.rm=TRUE)/1000,
  # Predicho (control)
  E_pred_kWh_m2 = sum(y_pred, na.rm=TRUE)/1000,
  # PI90 anual integrado
  E_PI90_low_kWh_m2  = sum(PI_low90,  na.rm=TRUE)/1000,
  E_PI90_high_kWh_m2 = sum(PI_high90, na.rm=TRUE)/1000,
  # FNRR anual asociado
  FNRR_mean_year = mean(FNRR, na.rm=TRUE),
  FNRR_p10_year  = quantile(FNRR, 0.10, na.rm=TRUE),
  FNRR_p50_year  = quantile(FNRR, 0.50, na.rm=TRUE),
  FNRR_p90_year  = quantile(FNRR, 0.90, na.rm=TRUE)
), by=.(Zona, Horizonte, Year)]

ENERGY_MEAN_2017_2022 <- ENERGY_ANNUAL[, .(
  E_true_mean_kWh_m2 = mean(E_true_kWh_m2, na.rm=TRUE),
  E_PI90_low_mean_kWh_m2  = mean(E_PI90_low_kWh_m2, na.rm=TRUE),
  E_PI90_high_mean_kWh_m2 = mean(E_PI90_high_kWh_m2, na.rm=TRUE),
  PI90_width_mean_kWh_m2  = mean(E_PI90_high_kWh_m2 - E_PI90_low_kWh_m2, na.rm=TRUE),
  FNRR_mean_2017_2022 = mean(FNRR_mean_year, na.rm=TRUE)
), by=.(Zona, Horizonte)]

# ============================================================
# Exportar
# ============================================================
fwrite(WIN_GLOBAL, file.path(OUT_DIR, "01_GANADOR_GLOBAL_TDQ_PIESS.csv"))
fwrite(WIN_BY_ZONE, file.path(OUT_DIR, "02_GANADOR_POR_ZONA_HORIZONTE.csv"))
fwrite(FNRR_TEST_PREDS, file.path(OUT_DIR, "03_FNRR_TEST_POR_ZONA_HORIZONTE.csv"))
fwrite(ENERGY_ANNUAL, file.path(OUT_DIR, "04_ENERGIA_ANUAL_POR_ZONA_HORIZONTE.csv"))
fwrite(ENERGY_MEAN_2017_2022, file.path(OUT_DIR, "05_ENERGIA_PROMEDIO_2017_2022.csv"))

cat("\nOK. Resultados CAP4 exportados en:\n", OUT_DIR, "\n\n")
print(WIN_GLOBAL)




Proyección años
library(data.table)
library(lubridate)

PREDS_FILE <- ""  # <-- set path
stopifnot(file.exists(PREDS_FILE))

OUT_DIR <- file.path(getwd(), "SALIDAS_CAP4_PROYECCION_CLIM_2023_2028")
dir.create(OUT_DIR, showWarnings=FALSE, recursive=TRUE)

P <- fread(PREDS_FILE)
P[, FechaHora := as.POSIXct(FechaHora, tz="America/Bogota")]
P <- P[is.finite(y_true) & is.finite(PI_low90) & is.finite(PI_high90) & is.finite(FNRR)]

# Climatología horaria por (Zona, Horizonte, doy, hour)
P[, doy := yday(FechaHora)]
P[, hour := hour(FechaHora)]

CLIM <- P[, .(
  WPD_clim = median(y_true, na.rm=TRUE),
  PI_low90_clim  = median(PI_low90,  na.rm=TRUE),
  PI_high90_clim = median(PI_high90, na.rm=TRUE),
  FNRR_clim = median(FNRR, na.rm=TRUE)
), by=.(Zona, Horizonte, doy, hour)]

# Grilla futura 2023-2028
ZONAS <- sort(unique(P$Zona))
HORIZ <- sort(unique(P$Horizonte))

future_grid <- rbindlist(lapply(ZONAS, function(z){
  data.table(
    Zona = z,
    FechaHora = seq(
      ymd_hms("2023-01-01 00:00:00", tz="America/Bogota"),
      ymd_hms("2028-12-31 23:00:00", tz="America/Bogota"),
      by="hour"
    )
  )
}))

future_grid[, doy := yday(FechaHora)]
future_grid[, hour := hour(FechaHora)]
future_grid[, Year := year(FechaHora)]

# Cross join con horizontes
future_grid[, key_tmp := 1L]
HDT <- data.table(Horizonte = HORIZ, key_tmp = 1L)
future_grid <- merge(future_grid, HDT, by="key_tmp", allow.cartesian=TRUE)
future_grid[, key_tmp := NULL]

# Unir con climatología
FUT <- merge(future_grid, CLIM, by=c("Zona","Horizonte","doy","hour"), all.x=TRUE)
setorder(FUT, Zona, Horizonte, FechaHora)

# Energía anual proyectada + PI90 anual (kWh/m^2)
ENERG_FUT <- FUT[, .(
  E_proj_kWh_m2 = sum(WPD_clim, na.rm=TRUE)/1000,
  E_PI90_low_kWh_m2  = sum(PI_low90_clim,  na.rm=TRUE)/1000,
  E_PI90_high_kWh_m2 = sum(PI_high90_clim, na.rm=TRUE)/1000,
  PI90_width_kWh_m2  = (sum(PI_high90_clim, na.rm=TRUE) - sum(PI_low90_clim, na.rm=TRUE))/1000,
  FNRR_mean_year = mean(FNRR_clim, na.rm=TRUE)
), by=.(Zona, Horizonte, Year)]

fwrite(ENERG_FUT, file.path(OUT_DIR, "ENERGIA_PROYECTADA_2023_2028_ANUAL.csv"))
cat("\nOK export:", OUT_DIR, "\n")
print(ENERG_FUT[order(Zona, Horizonte, Year)])




























Final Cap 4


# ============================================================
# CAPÍTULO 4 - TDQ_PIESS
# Proyección estructural 2017-2028
# Universidad Nacional de Colombia
# ============================================================

library(data.table)
library(lubridate)
library(ggplot2)

# -------------------------------
# 1. Rutas
# -------------------------------

BASE_FILE <- file.path("data","TDQ_PIESS_PREDS_GLOBAL.csv")  # <-- set your local path

stopifnot(file.exists(BASE_FILE))

OUT_DIR <- file.path(getwd(), "SALIDAS_CAP4_FINAL")
dir.create(OUT_DIR, showWarnings=FALSE, recursive=TRUE)

# -------------------------------
# 2. Cargar datos
# -------------------------------

P <- fread(BASE_FILE)
P[, FechaHora := as.POSIXct(FechaHora, tz="America/Bogota")]

P <- P[is.finite(y_true) & is.finite(PI_low90) &
         is.finite(PI_high90) & is.finite(FNRR)]

P[, Year := year(FechaHora)]

# -------------------------------
# 3. Energía anual histórica
# -------------------------------

ENERG_HIST <- P[, .(
  E_true_kWh_m2 = sum(y_true)/1000,
  E_low_kWh_m2  = sum(PI_low90)/1000,
  E_high_kWh_m2 = sum(PI_high90)/1000,
  FNRR_mean_year = mean(FNRR)
), by=.(Zona, Horizonte, Year)]

# -------------------------------
# 4. Resumen estructural 2017-2022
# -------------------------------

RES_STRUCT <- ENERG_HIST[, .(
  E_mean_2017_2022 = mean(E_true_kWh_m2),
  E_sd_2017_2022   = sd(E_true_kWh_m2),
  E_p05_2017_2022  = quantile(E_true_kWh_m2, 0.05),
  E_p95_2017_2022  = quantile(E_true_kWh_m2, 0.95),
  FNRR_structural  = mean(FNRR_mean_year)
), by=.(Zona, Horizonte)]

# -------------------------------
# 5. Proyección estructural 2023-2028
# -------------------------------

YEARS_FUT <- 2023:2028

PROY_LIST <- list()

for (yy in YEARS_FUT) {
  tmp <- RES_STRUCT[, .(
    Zona, Horizonte,
    Year = yy,
    E_proj_kWh_m2 = E_mean_2017_2022,
    E_p05_kWh_m2  = E_p05_2017_2022,
    E_p95_kWh_m2  = E_p95_2017_2022,
    FNRR_mean_year = FNRR_structural
  )]
  PROY_LIST[[length(PROY_LIST)+1]] <- tmp
}

ENERG_PROY <- rbindlist(PROY_LIST)

# -------------------------------
# 6. Exportar tablas
# -------------------------------

fwrite(ENERG_HIST, file.path(OUT_DIR, "01_ENERGIA_ANUAL_HISTORICA.csv"))
fwrite(RES_STRUCT, file.path(OUT_DIR, "02_RESUMEN_ESTRUCTURAL_2017_2022.csv"))
fwrite(ENERG_PROY, file.path(OUT_DIR, "03_PROYECCION_ESTRUCTURAL_2023_2028.csv"))

# -------------------------------
# 7. Figuras Publicables
# -------------------------------

theme_pub <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.major = element_line(color="grey90"),
    panel.grid.minor = element_blank(),
    plot.title = element_text(face="bold"),
    legend.position = "bottom"
  )

# ---- Figura Energía ----

p_energy <- ggplot() +
  geom_line(data=ENERG_HIST,
            aes(x=Year, y=E_true_kWh_m2, color=factor(Zona)),
            linewidth=0.8) +
  geom_line(data=ENERG_PROY,
            aes(x=Year, y=E_proj_kWh_m2, color=factor(Zona)),
            linetype="dashed", linewidth=0.8) +
  facet_wrap(~Horizonte, scales="free_y") +
  labs(title="Energía Eólica Anual: Histórico vs Proyección Estructural",
       y="Energía (kWh/m2)", x="Año",
       color="Zona") +
  theme_pub

ggsave(file.path(OUT_DIR, "04_FIG_ENERGIA_HIST_PROY.png"),
       p_energy, width=10, height=6, dpi=300)

# ---- Figura FNRR ----

p_fnrr <- ggplot() +
  geom_line(data=ENERG_HIST,
            aes(x=Year, y=FNRR_mean_year, color=factor(Zona)),
            linewidth=0.8) +
  geom_line(data=ENERG_PROY,
            aes(x=Year, y=FNRR_mean_year, color=factor(Zona)),
            linetype="dashed", linewidth=0.8) +
  facet_wrap(~Horizonte) +
  labs(title="FNRR Anual: Firma Regional Estructural",
       y="FNRR", x="Año",
       color="Zona") +
  theme_pub

ggsave(file.path(OUT_DIR, "05_FIG_FNRR_HIST_PROY.png"),
       p_fnrr, width=10, height=6, dpi=300)

cat("\nCAPÍTULO 4 COMPLETADO\n")
cat("Resultados en:", OUT_DIR, "\n")




suppressPackageStartupMessages({
  library(data.table); library(lubridate)
})

DATA_FILE <- ""  # <-- set path
OUT_DIR   <- file.path(getwd(), "SALIDAS_CAP4_CACHE")
dir.create(OUT_DIR, showWarnings=FALSE, recursive=TRUE)

logi <- function(...) cat(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "|", ..., "\n")

parse_dt <- function(x) {
  x <- trimws(as.character(x))
  x <- gsub("a\\.?\\s*m\\.?","AM", x, ignore.case=TRUE)
  x <- gsub("p\\.?\\s*m\\.?","PM", x, ignore.case=TRUE)
  suppressWarnings(parse_date_time(
    x,
    orders=c("Y-m-d H:M:S","Y-m-d H:M",
             "d/m/Y H:M:S","d/m/Y H:M",
             "m/d/Y H:M:S","m/d/Y H:M",
             "d-m-Y H:M:S","d-m-Y H:M",
             "Ymd HMS","Ymd HM",
             "d/m/Y I:M:S p","d/m/Y I:M p",
             "m/d/Y I:M:S p","m/d/Y I:M p"),
    tz="UTC"
  ))
}

norm_var <- function(v){
  v <- toupper(trimws(as.character(v))); v <- gsub("\\s+","", v)
  if (v %in% c("VV","VELVIENTO","VELOCIDADVIENTO","WINDSPEED","WS")) return("VV")
  if (v %in% c("PA","PRESION","PRESIONATM","PRESIONATMOSFERICA","PRESSURE")) return("PA")
  if (v %in% c("TM","TEMP","TEMPERATURA","TMEAN","T")) return("TM")
  if (v %in% c("TMIN","TEMPERATURAMINIMA")) return("TMIN")
  if (v %in% c("TMAX","TEMPERATURAMAXIMA")) return("TMAX")
  v
}

to_pa <- function(p){
  p <- as.numeric(p); med <- median(p, na.rm=TRUE)
  if (is.finite(med) && med < 2000) p*100 else p
}
to_kelvin <- function(t){
  t <- as.numeric(t); med <- median(t, na.rm=TRUE)
  if (is.finite(med) && med < 100) t+273.15 else t
}

logi("Leyendo:", DATA_FILE)
DT <- fread(DATA_FILE, showProgress=TRUE)
if (!("Estación" %in% names(DT)) && ("Estacion" %in% names(DT))) setnames(DT, "Estacion","Estación")

need <- c("FechaYHora","Valor","Zona","Variable")
miss <- setdiff(need, names(DT))
if (length(miss)>0) stop("Faltan columnas: ", paste(miss, collapse=", "))

DT[, Zona := as.integer(Zona)]
DT[, Variable := vapply(Variable, norm_var, character(1))]
DT <- DT[Variable %in% c("VV","PA","TM","TMIN","TMAX")]
DT[, Valor := suppressWarnings(as.numeric(Valor))]
DT[, Fecha := parse_dt(FechaYHora)]
DT <- DT[!is.na(Zona) & !is.na(Fecha)]
DT[, FechaHora := floor_date(Fecha, "hour")]

logi("Agregando a hourly por Zona-FechaHora...")
H <- DT[, .(Valor = mean(Valor, na.rm=TRUE)), by=.(Zona, FechaHora, Variable)]
W <- dcast(H, Zona + FechaHora ~ Variable, value.var="Valor")
setorder(W, Zona, FechaHora)

if (!("TM" %in% names(W))) {
  if (all(c("TMIN","TMAX") %in% names(W))) W[, TM := (TMIN+TMAX)/2]
  else stop("No encontré TM ni TMIN/TMAX.")
}
if (!("PA" %in% names(W))) stop("No encontré PA.")
if (!("VV" %in% names(W))) stop("No encontré VV.")

W[, PA := to_pa(PA)]
W[, TM := to_kelvin(TM)]
W[, VV := pmax(as.numeric(VV), 0)]

R <- 287.05
W[, rho := PA/(R*TM)]
W[, WPD := 0.5 * rho * (VV^3)]
W[, Eh  := WPD/1000]

OUT_FILE <- file.path(OUT_DIR, "WPD_Eh_hourly_por_zona.csv")
fwrite(W[, .(Zona, FechaHora, VV, PA, TM, rho, WPD, Eh)], OUT_FILE)

logi("OK cache:", OUT_FILE)


# ============================================================
# CAP4 - TDQ CIERRE FINAL (ANTI-ERRORES DEFINITIVO) | WPD + Eh + PI90 + FNRR
# SIN lubridate (evita tz(x)->as.POSIXlt.default)
# Trimestral + Anual, Forecast 2022Q3-2028Q4
# Regularización física Zona 1 (Weibull mu + 2sd) + coherencia energía
# FIX: Deduplicación (Zona,time) para evitar cartesian join
# ============================================================

req <- c("data.table","forecast","ggplot2","scales")
for (p in req) if (!requireNamespace(p, quietly=TRUE)) install.packages(p, dependencies=TRUE)
suppressPackageStartupMessages({
  library(data.table); library(forecast); library(ggplot2); library(scales)
})

# -------------------------
# 1) Rutas
# -------------------------
ROOT <- ""  # <-- set path
OUT  <- file.path(ROOT, "SALIDAS_CAP4_TDQ_FINAL")
dir.create(OUT, showWarnings=FALSE, recursive=TRUE)

CACHE_FILE <- file.path(ROOT, "SALIDAS_CAP4_CACHE", "WPD_Eh_hourly_por_zona.csv")
if (!file.exists(CACHE_FILE)) stop("No existe CACHE_FILE: ", CACHE_FILE)

# -------------------------
# 2) Parámetros
# -------------------------
LEVEL_PI <- 90
START_DT   <- as.POSIXct("2017-01-01 00:00:00", tz="UTC")
CUTOFF_END <- as.POSIXct("2022-06-30 23:00:00", tz="UTC")

LAST_OBS_Y <- 2022
LAST_OBS_Q <- 2
END_Y <- 2028
END_Q <- 4

WEIBULL_PARAMS <- data.table(
  Zona = c(1,2,3,4),
  c_w  = c(1.90, 3.20, 2.80, 3.85),
  k_w  = c(0.60, 1.35, 1.35, 1.95)
)

weibull_mu_sd <- function(c_w, k_w) {
  mu  <- c_w * gamma(1 + 1/k_w)
  var <- c_w^2 * (gamma(1 + 2/k_w) - (gamma(1 + 1/k_w))^2)
  sd  <- sqrt(pmax(var, 0))
  list(mu=mu, sd=sd)
}
cap_struct <- function(x, cap) pmin(x, cap)
clamp01 <- function(x) pmax(0, pmin(1, x))
fnrr_from_p <- function(p50, p90) {
  a <- log1p(p90); b <- log1p(p50)
  clamp01((a - b) / (a + 1e-12))
}

hours_in_q <- function(y, q) {
  m0 <- (q-1L)*3L + 1L
  st <- as.POSIXct(sprintf("%04d-%02d-01 00:00:00", y, m0), tz="UTC")
  y2 <- y + (q==4L)
  q2 <- if (q==4L) 1L else (q+1L)
  m1 <- (q2-1L)*3L + 1L
  en <- as.POSIXct(sprintf("%04d-%02d-01 00:00:00", y2, m1), tz="UTC")
  as.integer(difftime(en, st, units="hours"))
}

# -------------------------
# 3) Leer cache y CREAR time (parser multi-formato, sin tz(x))
# -------------------------
cat(format(Sys.time(), "%F %T"), "| Leyendo:", CACHE_FILE, "\n")
dt <- fread(CACHE_FILE, showProgress=TRUE)

clean_names <- function(x){
  x <- gsub("^\ufeff","", x)
  x <- gsub("[\r\n\t]","", x)
  trimws(x)
}
setnames(dt, clean_names(names(dt)))
nms_low <- tolower(names(dt))

time_idx <- which(nms_low %in% c("fechahora","fechayhora","fecha_hora","datetime","date_time","timestamp","time"))
if (length(time_idx) == 0) time_idx <- which(grepl("fecha", nms_low) & grepl("hora", nms_low))
if (length(time_idx) == 0) time_idx <- which(grepl("datetime|timestamp", nms_low))
if (length(time_idx) == 0) stop("No detecté columna tiempo. Columnas: ", paste(names(dt), collapse=", "))
TIME_COL <- names(dt)[time_idx[1]]

parse_time_base <- function(x, tz_out="UTC") {
  if (inherits(x,"POSIXct")) return(as.POSIXct(x, tz=tz_out))
  if (inherits(x,"POSIXlt")) return(as.POSIXct(x, tz=tz_out))
  if (inherits(x,"Date"))   return(as.POSIXct(x, tz=tz_out))
  if (is.factor(x) || is.ordered(x)) x <- as.character(x)

  if (!is.numeric(x) && !is.character(x)) {
    x <- tryCatch(as.character(x), error=function(e) rep(NA_character_, length(x)))
  }

  # epoch numérico
  if (is.numeric(x)) {
    xx <- x[is.finite(x)]
    if (length(xx)==0) return(as.POSIXct(rep(NA, length(x)), origin="1970-01-01", tz=tz_out))
    med <- median(xx, na.rm=TRUE)
    div <- if (med > 1e14) 1e6 else if (med > 1e11) 1e3 else 1
    return(as.POSIXct(x/div, origin="1970-01-01", tz=tz_out))
  }

  # character multi-format
  x <- as.character(x)
  x <- gsub("^\ufeff","", x)
  x <- trimws(gsub("[\r\n\t]", " ", x))
  x[x==""] <- NA_character_

  fmts <- c(
    "%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M",
    "%Y/%m/%d %H:%M:%S", "%Y/%m/%d %H:%M",
    "%Y%m%d %H:%M:%S",   "%Y%m%d %H:%M",
    "%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M",
    "%m/%d/%Y %H:%M:%S", "%m/%d/%Y %H:%M",
    "%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M",
    "%Y-%m-%d %I:%M:%S %p", "%Y-%m-%d %I:%M %p",
    "%d/%m/%Y %I:%M:%S %p", "%d/%m/%Y %I:%M %p",
    "%m/%d/%Y %I:%M:%S %p", "%m/%d/%Y %I:%M %p"
  )

  out <- rep(as.POSIXct(NA, tz=tz_out), length(x))
  for (fmt in fmts) {
    idx <- which(is.na(out) & !is.na(x))
    if (length(idx)==0) break
    tt <- suppressWarnings(as.POSIXct(strptime(x[idx], format=fmt, tz=tz_out), tz=tz_out))
    ok <- !is.na(tt)
    if (any(ok)) out[idx[ok]] <- tt[ok]
  }
  out
}

dt[, time := parse_time_base(dt[[TIME_COL]], tz_out="UTC")]
if (!inherits(dt$time, "POSIXct")) stop("time NO es POSIXct. class=", paste(class(dt$time), collapse=", "))

na_rate <- mean(is.na(dt$time))
if (!is.finite(na_rate)) na_rate <- 1
if (na_rate > 0.05) {
  bad <- unique(as.character(dt[is.na(time), ..TIME_COL][[1]]))
  bad <- bad[1:min(25, length(bad))]
  stop(
    "Fallo parseo time: NA rate=", round(100*na_rate,2), "% | TIME_COL=", TIME_COL, "\n",
    "Ejemplos que NO parsean:\n- ", paste(bad, collapse="\n- ")
  )
}

# Normalizar Zona/WPD/Eh
if (!"Zona" %in% names(dt)) stop("Falta 'Zona'.")
dt[, Zona := as.integer(Zona)]

if (!"WPD" %in% names(dt)) {
  widx <- which(tolower(names(dt)) %in% c("wpd","wpd_w_m2","wpd_wm2","wpd_tdq","wpd_mean"))
  if (length(widx)==0) stop("No detecté WPD. Columnas: ", paste(names(dt), collapse=", "))
  setnames(dt, names(dt)[widx[1]], "WPD")
}
dt[, WPD := pmax(as.numeric(WPD), 0)]

if (!"Eh" %in% names(dt)) {
  eidx <- which(tolower(names(dt)) %in% c("eh","eh_kwh_m2","eh_kwhm2","eh_tdq","energy"))
  if (length(eidx)==0) stop("No detecté Eh. Columnas: ", paste(names(dt), collapse=", "))
  setnames(dt, names(dt)[eidx[1]], "Eh")
}
dt[, Eh := pmax(as.numeric(Eh), 0)]

# ventana observada
dt <- dt[!is.na(Zona) & !is.na(time)]
dt <- dt[time >= START_DT & time <= CUTOFF_END]
dt <- dt[is.finite(WPD) & is.finite(Eh)]
setorder(dt, Zona, time)

zones <- sort(unique(dt$Zona))
if (length(zones) < 1) stop("No hay datos en 2017-01 a 2022-06.")
cat(format(Sys.time(), "%F %T"), "| OK | zones:", paste(zones, collapse=", "), "| rows:", nrow(dt), "\n")

# -------------------------
# 3.1) FIX CRÍTICO: eliminar duplicados (Zona,time) para evitar cartesian join
# -------------------------
dupN <- dt[, .N, by=.(Zona, time)][N > 1]
if (nrow(dupN) > 0) {
  cat("⚠️ Duplicados detectados en (Zona,time):", nrow(dupN), "claves con repetición.\n")
  print(head(dupN, 10))
  fwrite(dupN, file.path(OUT, "DEBUG_DUPLICADOS_Zona_time.csv"))

  dt <- dt[, .(
    WPD = mean(WPD, na.rm=TRUE),
    Eh  = mean(Eh , na.rm=TRUE)
  ), by=.(Zona, time)]
  setorder(dt, Zona, time)
  cat("✅ dt colapsado: filas =", nrow(dt), "y claves únicas (Zona,time).\n")
} else {
  cat("✅ No hay duplicados en (Zona,time).\n")
}

# -------------------------
# 4) TDQ orden: grilla completa + imputación Month-Hour
# -------------------------
full_grid <- rbindlist(lapply(zones, function(z){
  data.table(Zona=z, time=seq(START_DT, CUTOFF_END, by="hour"))
}))

setkey(full_grid, Zona, time)
setkey(dt, Zona, time)

obs <- copy(dt)

# join SEGURO (evita cartesian): grilla recibe observados
dt2 <- dt[full_grid, on=.(Zona, time)]

# blindajes post-join
dt2[, time := as.POSIXct(time, tz="UTC")]
obs[, time := as.POSIXct(time, tz="UTC")]

stopifnot(inherits(dt2$time, "POSIXct"))
stopifnot(length(dt2$time) == nrow(dt2))

# Month/Hour vectorizado real
dt2[, `:=`(
  Month = as.integer(format(time, "%m", tz="UTC")),
  Hour  = as.integer(format(time, "%H", tz="UTC"))
)]

prof_mh <- dt2[!is.na(WPD), .(
  WPD_med = median(WPD, na.rm=TRUE),
  Eh_med  = median(Eh , na.rm=TRUE)
), by=.(Zona, Month, Hour)]
setkey(prof_mh, Zona, Month, Hour)

prof_h <- dt2[!is.na(WPD), .(
  WPD_med2 = median(WPD, na.rm=TRUE),
  Eh_med2  = median(Eh , na.rm=TRUE)
), by=.(Zona, Hour)]
setkey(prof_h, Zona, Hour)

glob_wpd <- median(dt2$WPD, na.rm=TRUE); if (!is.finite(glob_wpd)) glob_wpd <- 0
glob_eh  <- median(dt2$Eh , na.rm=TRUE); if (!is.finite(glob_eh )) glob_eh  <- 0

dt2 <- prof_mh[dt2, on=.(Zona, Month, Hour)]
dt2 <- prof_h[dt2,  on=.(Zona, Hour)]

dt2[is.na(WPD), WPD := fifelse(!is.na(WPD_med), WPD_med,
                               fifelse(!is.na(WPD_med2), WPD_med2, glob_wpd))]
dt2[is.na(Eh),  Eh  := fifelse(!is.na(Eh_med),  Eh_med,
                               fifelse(!is.na(Eh_med2), Eh_med2,  glob_eh ))]
dt2[, c("WPD_med","Eh_med","WPD_med2","Eh_med2") := NULL]

# Regularización física Zona 1 (Weibull mu+2sd) + coherencia energía
row_w1 <- WEIBULL_PARAMS[Zona==1]
if (1 %in% zones && nrow(row_w1)==1 && row_w1$c_w>0 && row_w1$k_w>0) {
  ws1 <- weibull_mu_sd(row_w1$c_w, row_w1$k_w)
  cap1 <- ws1$mu + 2*ws1$sd
  dt2[Zona==1, WPD := cap_struct(WPD, cap1)]
  dt2[Zona==1, Eh  := WPD/1000]  # kWh/m2 por hora coherente
}

# -------------------------
# 5) Trimestral observado + coverage
# -------------------------
dt2[, `:=`(
  Year  = as.integer(format(time, "%Y", tz="UTC")),
  Month = as.integer(format(time, "%m", tz="UTC"))
)]
dt2[, Q  := ((Month - 1L) %/% 3L) + 1L]
dt2[, YQ := paste0(Year, " Q", Q)]

obs[, `:=`(
  Year  = as.integer(format(time, "%Y", tz="UTC")),
  Month = as.integer(format(time, "%m", tz="UTC"))
)]
obs[, Q  := ((Month - 1L) %/% 3L) + 1L]
obs[, YQ := paste0(Year, " Q", Q)]

obs_cov <- obs[, .(horas_obs=.N), by=.(Zona,Year,Q,YQ)]
obs_cov[, horas_teo := mapply(hours_in_q, Year, Q)]
obs_cov[, coverage  := pmin(1, horas_obs/horas_teo)]

tri <- dt2[, .(
  horas_teo = .N,
  WPD_p50   = as.numeric(quantile(WPD, 0.50, na.rm=TRUE)),
  WPD_p90   = as.numeric(quantile(WPD, 0.90, na.rm=TRUE)),
  WPD_mean  = mean(WPD, na.rm=TRUE),
  E_free    = sum(Eh, na.rm=TRUE)     # kWh/m2 por trimestre
), by=.(Zona,Year,Q,YQ)]

tri <- merge(tri, obs_cov[,.(Zona,Year,Q,YQ,horas_obs,coverage)],
             by=c("Zona","Year","Q","YQ"), all.x=TRUE)
tri[is.na(horas_obs), `:=`(horas_obs=0L, coverage=0)]

tri[, FNRR := fnrr_from_p(WPD_p50, WPD_p90)]
tri[, coh  := 1 - FNRR]
tri[, E_usable := E_free * coh]

# -------------------------
# 6) Forecast trimestral 2022Q3-2028Q4 (ARIMA estacional en log1p)
# -------------------------
future_yq <- c()
for (y in LAST_OBS_Y:END_Y) for (q in 1:4)
  if (y > LAST_OBS_Y || (y==LAST_OBS_Y && q > LAST_OBS_Q)) future_yq <- c(future_yq, paste0(y," Q",q))
h <- length(future_yq)

fit_fc <- function(x, h, level=90){
  x <- pmax(as.numeric(x), 0)
  lx <- log1p(x)
  if (anyNA(lx)) lx <- as.numeric(na.interp(ts(lx, frequency=4, start=c(2017,1))))
  tsx <- ts(lx, frequency=4, start=c(2017,1))
  fit <- auto.arima(tsx, seasonal=TRUE, stepwise=TRUE, approximation=TRUE)
  forecast(fit, h=h, level=level)
}
back <- function(fc){
  list(
    mean = pmax(expm1(as.numeric(fc$mean)), 0),
    lo   = pmax(expm1(as.numeric(fc$lower[,1])), 0),
    hi   = pmax(expm1(as.numeric(fc$upper[,1])), 0)
  )
}

future_list <- list()

for (z in zones) {
  tri_z <- tri[Zona==z][order(Year,Q)]

  base_yq <- c()
  for (y in 2017:LAST_OBS_Y) for (q in 1:4)
    if (y < LAST_OBS_Y || (y==LAST_OBS_Y && q<=LAST_OBS_Q)) base_yq <- c(base_yq, paste0(y," Q",q))

  base_dt <- data.table(YQ=base_yq)
  tri_z <- merge(base_dt, tri_z[,.(YQ, WPD_p50, WPD_p90, E_free)], by="YQ", all.x=TRUE)

  fc50 <- back(fit_fc(tri_z$WPD_p50, h=h, level=LEVEL_PI))
  fc90 <- back(fit_fc(tri_z$WPD_p90, h=h, level=LEVEL_PI))
  fcE  <- back(fit_fc(tri_z$E_free , h=h, level=LEVEL_PI))

  fut <- data.table(
    Zona=z,
    YQ=future_yq,
    Year=as.integer(substr(future_yq,1,4)),
    Q=as.integer(sub(".*Q","",future_yq)),
    horas_teo=mapply(hours_in_q,
                     as.integer(substr(future_yq,1,4)),
                     as.integer(sub(".*Q","",future_yq))),
    horas_obs=0L,
    coverage=1,

    WPD_p50=fc50$mean,
    WPD_p90=fc90$mean,
    E_free=fcE$mean,

    E_free_lo=fcE$lo,
    E_free_hi=fcE$hi
  )

  fut[, WPD_mean := 0.6*WPD_p50 + 0.4*WPD_p90]
  fut[, FNRR := fnrr_from_p(WPD_p50, WPD_p90)]
  fut[, coh  := 1 - FNRR]
  fut[, E_usable := E_free * coh]

  # Regularización física Zona 1 + coherencia física energía
  if (z==1 && nrow(row_w1)==1 && row_w1$c_w>0 && row_w1$k_w>0) {
    ws1 <- weibull_mu_sd(row_w1$c_w, row_w1$k_w)
    cap1 <- ws1$mu + 2*ws1$sd
    fut[, WPD_p50  := cap_struct(WPD_p50 , cap1)]
    fut[, WPD_p90  := cap_struct(WPD_p90 , cap1)]
    fut[, WPD_mean := cap_struct(WPD_mean, cap1)]
    fut[, E_free   := (WPD_mean/1000) * horas_teo]
    fut[, E_usable := E_free * (1 - FNRR)]
  }

  future_list[[as.character(z)]] <- fut
}

future_tri <- rbindlist(future_list, fill=TRUE)

tri_all <- rbindlist(list(
  tri[, .(Zona,Year,Q,YQ,horas_teo,horas_obs,coverage,WPD_p50,WPD_p90,WPD_mean,E_free,E_usable,FNRR,coh)],
  future_tri[, .(Zona,Year,Q,YQ,horas_teo,horas_obs,coverage,WPD_p50,WPD_p90,WPD_mean,E_free,E_usable,FNRR,coh,E_free_lo,E_free_hi)]
), fill=TRUE)
setorder(tri_all, Zona, Year, Q)

# -------------------------
# 7) Anual
# -------------------------
ann <- tri_all[, .(
  horas_teo = sum(horas_teo),
  horas_obs = sum(horas_obs),
  coverage  = weighted.mean(coverage, w=horas_teo),

  WPD_mean  = weighted.mean(WPD_mean, w=horas_teo),
  WPD_p50   = weighted.mean(WPD_p50 , w=horas_teo),
  WPD_p90   = weighted.mean(WPD_p90 , w=horas_teo),

  E_free    = sum(E_free),
  E_usable  = sum(E_usable),

  FNRR      = weighted.mean(FNRR, w=horas_teo),
  coh       = weighted.mean(coh , w=horas_teo),

  E_free_lo = sum(E_free_lo, na.rm=TRUE),
  E_free_hi = sum(E_free_hi, na.rm=TRUE)
), by=.(Zona,Year)]
ann[, E_usable_lo := E_free_lo * (1 - FNRR)]
ann[, E_usable_hi := E_free_hi * (1 - FNRR)]
setorder(ann, Zona, Year)

# -------------------------
# 8) Export
# -------------------------
fwrite(tri_all, file.path(OUT, "CAP4_TDQ_TRIMESTRAL_2017_2028.csv"))
fwrite(ann,     file.path(OUT, "CAP4_TDQ_ANUAL_2017_2028.csv"))

# -------------------------
# 9) Figuras publicables
# -------------------------
theme_pub <- theme_bw(base_size=12) +
  theme(panel.grid.minor=element_blank(),
        legend.position="bottom",
        plot.title=element_text(face="bold"),
        axis.title=element_text(face="bold"))

tri_plot <- copy(tri_all)
tri_plot[, t_index := as.Date(sprintf("%04d-%02d-01", Year, (Q-1L)*3L + 1L))]

p1 <- ggplot(tri_plot, aes(t_index, WPD_mean, color=factor(Zona), group=factor(Zona))) +
  geom_line(linewidth=0.9) + geom_point(size=1.2) +
  geom_vline(xintercept=as.Date("2022-04-01"), linetype="dashed") +
  labs(title="WPD trimestral TDQ (2017-2028)", x="Inicio de trimestre", y="WPD (W/m2)", color="Zona") +
  theme_pub
ggsave(file.path(OUT, "FIG_CAP4_WPD_TRIMESTRAL_TDQ_2017_2028.png"), p1, width=12, height=5, dpi=300)

p2 <- ggplot(ann, aes(Year)) +
  geom_ribbon(aes(ymin=E_free_lo, ymax=E_free_hi, fill=factor(Zona), group=factor(Zona)), alpha=0.15, color=NA) +
  geom_line(aes(y=E_free,   color=factor(Zona), group=factor(Zona)), linewidth=0.9) +
  geom_line(aes(y=E_usable, color=factor(Zona), group=factor(Zona)), linewidth=0.9, linetype="dotted") +
  geom_point(aes(y=E_free,   color=factor(Zona)), size=1.1) +
  geom_point(aes(y=E_usable, color=factor(Zona)), size=1.0, shape=1) +
  labs(title="Energía anual (kWh/m2): libre vs usable + PI90", x="Año", y="Energía (kWh/m2)", color="Zona", fill="Zona") +
  theme_pub
ggsave(file.path(OUT, "FIG_CAP4_ENERGIA_ANUAL_LIBRE_USABLE_PI90.png"), p2, width=12, height=5, dpi=300)

p3 <- ggplot(ann, aes(Year, FNRR, color=factor(Zona), group=factor(Zona))) +
  geom_line(linewidth=0.9) + geom_point(size=1.2) +
  scale_y_continuous(limits=c(0,1)) +
  labs(title="FNRR anual TDQ (2017-2028)", x="Año", y="FNRR (0-1)", color="Zona") +
  theme_pub
ggsave(file.path(OUT, "FIG_CAP4_FNRR_ANUAL_TDQ_2017_2028.png"), p3, width=12, height=5, dpi=300)

cat("\n==============================================\n")
cat("OK ✅ CAP4 TDQ FINAL (SIN lubridate)\nOUT:", OUT, "\n")
cat("Tablas: CAP4_TDQ_TRIMESTRAL_2017_2028.csv | CAP4_TDQ_ANUAL_2017_2028.csv\n")
cat("Figuras: WPD trimestral | Energía anual + PI90 | FNRR anual\n")
cat("==============================================\n")





# ============================================================
# CAP4 - TDQ CIERRE FINAL (ANTI-ERRORES + AJUSTE FINO) | WPD + Eh + PI90 + FNRR
# SIN lubridate
# Trimestral + Anual, Forecast 2022Q3-2028Q4
# Regularización física Zona 1 (Weibull mu + 2sd)
# PI90 ANUAL: por simulación (Monte Carlo) en log1p (nivel doctoral)
# ============================================================

req <- c("data.table","forecast","ggplot2","scales")
for (p in req) if (!requireNamespace(p, quietly=TRUE)) install.packages(p, dependencies=TRUE)
suppressPackageStartupMessages({
  library(data.table); library(forecast); library(ggplot2); library(scales)
})

# -------------------------
# 1) Rutas
# -------------------------
ROOT <- ""  # <-- set path
OUT  <- file.path(ROOT, "SALIDAS_CAP4_TDQ_FINAL")
dir.create(OUT, showWarnings=FALSE, recursive=TRUE)

CACHE_FILE <- file.path(ROOT, "SALIDAS_CAP4_CACHE", "WPD_Eh_hourly_por_zona.csv")
if (!file.exists(CACHE_FILE)) stop("No existe CACHE_FILE: ", CACHE_FILE)

# -------------------------
# 2) Parámetros
# -------------------------
LEVEL_PI <- 90
START_DT   <- as.POSIXct("2017-01-01 00:00:00", tz="UTC")
CUTOFF_END <- as.POSIXct("2022-06-30 23:00:00", tz="UTC")

LAST_OBS_Y <- 2022
LAST_OBS_Q <- 2
END_Y <- 2028
END_Q <- 4

# Simulación PI anual (sube a 5000 si quieres más suave)
NSIM_PI_ANUAL <- 3000

WEIBULL_PARAMS <- data.table(
  Zona = c(1,2,3,4),
  c_w  = c(1.90, 3.20, 2.80, 3.85),
  k_w  = c(0.60, 1.35, 1.35, 1.95)
)

weibull_mu_sd <- function(c_w, k_w) {
  mu  <- c_w * gamma(1 + 1/k_w)
  var <- c_w^2 * (gamma(1 + 2/k_w) - (gamma(1 + 1/k_w))^2)
  sd  <- sqrt(pmax(var, 0))
  list(mu=mu, sd=sd)
}
cap_struct <- function(x, cap) pmin(x, cap)
clamp01 <- function(x) pmax(0, pmin(1, x))
fnrr_from_p <- function(p50, p90) {
  a <- log1p(p90); b <- log1p(p50)
  clamp01((a - b) / (a + 1e-12))
}

hours_in_q <- function(y, q) {
  m0 <- (q-1L)*3L + 1L
  st <- as.POSIXct(sprintf("%04d-%02d-01 00:00:00", y, m0), tz="UTC")
  y2 <- y + (q==4L)
  q2 <- if (q==4L) 1L else (q+1L)
  m1 <- (q2-1L)*3L + 1L
  en <- as.POSIXct(sprintf("%04d-%02d-01 00:00:00", y2, m1), tz="UTC")
  as.integer(difftime(en, st, units="hours"))
}

# -------------------------
# 3) Leer cache y CREAR time (parser multi-formato)
# -------------------------
cat(format(Sys.time(), "%F %T"), "| Leyendo:", CACHE_FILE, "\n")
dt <- fread(CACHE_FILE, showProgress=TRUE)

clean_names <- function(x){
  x <- gsub("^\ufeff","", x)
  x <- gsub("[\r\n\t]","", x)
  trimws(x)
}
setnames(dt, clean_names(names(dt)))
nms_low <- tolower(names(dt))

time_idx <- which(nms_low %in% c("fechahora","fechayhora","fecha_hora","datetime","date_time","timestamp","time"))
if (length(time_idx) == 0) time_idx <- which(grepl("fecha", nms_low) & grepl("hora", nms_low))
if (length(time_idx) == 0) time_idx <- which(grepl("datetime|timestamp", nms_low))
if (length(time_idx) == 0) stop("No detecté columna tiempo. Columnas: ", paste(names(dt), collapse=", "))
TIME_COL <- names(dt)[time_idx[1]]

parse_time_base <- function(x, tz_out="UTC") {
  if (inherits(x,"POSIXct")) return(as.POSIXct(x, tz=tz_out))
  if (inherits(x,"POSIXlt")) return(as.POSIXct(x, tz=tz_out))
  if (inherits(x,"Date"))   return(as.POSIXct(x, tz=tz_out))
  if (is.factor(x) || is.ordered(x)) x <- as.character(x)

  if (!is.numeric(x) && !is.character(x)) {
    x <- tryCatch(as.character(x), error=function(e) rep(NA_character_, length(x)))
  }

  if (is.numeric(x)) {
    xx <- x[is.finite(x)]
    if (length(xx)==0) return(as.POSIXct(rep(NA, length(x)), origin="1970-01-01", tz=tz_out))
    med <- median(xx, na.rm=TRUE)
    div <- if (med > 1e14) 1e6 else if (med > 1e11) 1e3 else 1
    return(as.POSIXct(x/div, origin="1970-01-01", tz=tz_out))
  }

  x <- as.character(x)
  x <- gsub("^\ufeff","", x)
  x <- trimws(gsub("[\r\n\t]", " ", x))
  x[x==""] <- NA_character_

  fmts <- c(
    "%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M",
    "%Y/%m/%d %H:%M:%S", "%Y/%m/%d %H:%M",
    "%Y%m%d %H:%M:%S",   "%Y%m%d %H:%M",
    "%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M",
    "%m/%d/%Y %H:%M:%S", "%m/%d/%Y %H:%M",
    "%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M",
    "%Y-%m-%d %I:%M:%S %p", "%Y-%m-%d %I:%M %p",
    "%d/%m/%Y %I:%M:%S %p", "%d/%m/%Y %I:%M %p",
    "%m/%d/%Y %I:%M:%S %p", "%m/%d/%Y %I:%M %p"
  )

  out <- rep(as.POSIXct(NA, tz=tz_out), length(x))
  for (fmt in fmts) {
    idx <- which(is.na(out) & !is.na(x))
    if (length(idx)==0) break
    tt <- suppressWarnings(as.POSIXct(strptime(x[idx], format=fmt, tz=tz_out), tz=tz_out))
    ok <- !is.na(tt)
    if (any(ok)) out[idx[ok]] <- tt[ok]
  }
  out
}

dt[, time := parse_time_base(dt[[TIME_COL]], tz_out="UTC")]
if (!inherits(dt$time, "POSIXct")) stop("time NO es POSIXct. class=", paste(class(dt$time), collapse=", "))

na_rate <- mean(is.na(dt$time))
if (!is.finite(na_rate)) na_rate <- 1
if (na_rate > 0.05) {
  bad <- unique(as.character(dt[is.na(time), ..TIME_COL][[1]]))
  bad <- bad[1:min(25, length(bad))]
  stop(
    "Fallo parseo time: NA rate=", round(100*na_rate,2), "% | TIME_COL=", TIME_COL, "\n",
    "Ejemplos que NO parsean:\n- ", paste(bad, collapse="\n- ")
  )
}

# Normalizar Zona/WPD/Eh
if (!"Zona" %in% names(dt)) stop("Falta 'Zona'.")
dt[, Zona := as.integer(Zona)]

if (!"WPD" %in% names(dt)) {
  widx <- which(tolower(names(dt)) %in% c("wpd","wpd_w_m2","wpd_wm2","wpd_tdq","wpd_mean"))
  if (length(widx)==0) stop("No detecté WPD. Columnas: ", paste(names(dt), collapse=", "))
  setnames(dt, names(dt)[widx[1]], "WPD")
}
dt[, WPD := pmax(as.numeric(WPD), 0)]

if (!"Eh" %in% names(dt)) {
  eidx <- which(tolower(names(dt)) %in% c("eh","eh_kwh_m2","eh_kwhm2","eh_tdq","energy"))
  if (length(eidx)==0) stop("No detecté Eh. Columnas: ", paste(names(dt), collapse=", "))
  setnames(dt, names(dt)[eidx[1]], "Eh")
}
dt[, Eh := pmax(as.numeric(Eh), 0)]

# ventana observada
dt <- dt[!is.na(Zona) & !is.na(time)]
dt <- dt[time >= START_DT & time <= CUTOFF_END]
dt <- dt[is.finite(WPD) & is.finite(Eh)]
setorder(dt, Zona, time)

zones <- sort(unique(dt$Zona))
if (length(zones) < 1) stop("No hay datos en 2017-01 a 2022-06.")
cat(format(Sys.time(), "%F %T"), "| OK | zones:", paste(zones, collapse=", "), "| rows:", nrow(dt), "\n")

# -------------------------
# 3.1) FIX CRÍTICO: eliminar duplicados (Zona,time)
# -------------------------
dupN <- dt[, .N, by=.(Zona, time)][N > 1]
if (nrow(dupN) > 0) {
  cat("⚠️ Duplicados detectados en (Zona,time):", nrow(dupN), "claves con repetición.\n")
  print(head(dupN, 10))
  fwrite(dupN, file.path(OUT, "DEBUG_DUPLICADOS_Zona_time.csv"))

  dt <- dt[, .(
    WPD = mean(WPD, na.rm=TRUE),
    Eh  = mean(Eh , na.rm=TRUE)
  ), by=.(Zona, time)]
  setorder(dt, Zona, time)
  cat("✅ dt colapsado: filas =", nrow(dt), "y claves únicas (Zona,time).\n")
} else {
  cat("✅ No hay duplicados en (Zona,time).\n")
}

# -------------------------
# 4) TDQ orden: grilla completa + imputación Month-Hour
# -------------------------
full_grid <- rbindlist(lapply(zones, function(z){
  data.table(Zona=z, time=seq(START_DT, CUTOFF_END, by="hour"))
}))

setkey(full_grid, Zona, time)
setkey(dt, Zona, time)

obs <- copy(dt)

# join seguro: grilla recibe observados
dt2 <- dt[full_grid, on=.(Zona, time)]

dt2[, time := as.POSIXct(time, tz="UTC")]
obs[, time := as.POSIXct(time, tz="UTC")]

stopifnot(inherits(dt2$time, "POSIXct"))
stopifnot(length(dt2$time) == nrow(dt2))

dt2[, `:=`(
  Month = as.integer(format(time, "%m", tz="UTC")),
  Hour  = as.integer(format(time, "%H", tz="UTC"))
)]

prof_mh <- dt2[!is.na(WPD), .(
  WPD_med = median(WPD, na.rm=TRUE),
  Eh_med  = median(Eh , na.rm=TRUE)
), by=.(Zona, Month, Hour)]
setkey(prof_mh, Zona, Month, Hour)

prof_h <- dt2[!is.na(WPD), .(
  WPD_med2 = median(WPD, na.rm=TRUE),
  Eh_med2  = median(Eh , na.rm=TRUE)
), by=.(Zona, Hour)]
setkey(prof_h, Zona, Hour)

glob_wpd <- median(dt2$WPD, na.rm=TRUE); if (!is.finite(glob_wpd)) glob_wpd <- 0
glob_eh  <- median(dt2$Eh , na.rm=TRUE); if (!is.finite(glob_eh )) glob_eh  <- 0

dt2 <- prof_mh[dt2, on=.(Zona, Month, Hour)]
dt2 <- prof_h[dt2,  on=.(Zona, Hour)]

dt2[is.na(WPD), WPD := fifelse(!is.na(WPD_med), WPD_med,
                               fifelse(!is.na(WPD_med2), WPD_med2, glob_wpd))]
dt2[is.na(Eh),  Eh  := fifelse(!is.na(Eh_med),  Eh_med,
                               fifelse(!is.na(Eh_med2), Eh_med2,  glob_eh ))]
dt2[, c("WPD_med","Eh_med","WPD_med2","Eh_med2") := NULL]

# Regularización física Zona 1 (Weibull mu+2sd) + coherencia energía
row_w1 <- WEIBULL_PARAMS[Zona==1]
if (1 %in% zones && nrow(row_w1)==1 && row_w1$c_w>0 && row_w1$k_w>0) {
  ws1 <- weibull_mu_sd(row_w1$c_w, row_w1$k_w)
  cap1 <- ws1$mu + 2*ws1$sd
  dt2[Zona==1, WPD := cap_struct(WPD, cap1)]
  dt2[Zona==1, Eh  := WPD/1000]
}

# -------------------------
# 5) Trimestral observado + coverage
# -------------------------
dt2[, `:=`(
  Year  = as.integer(format(time, "%Y", tz="UTC")),
  Month = as.integer(format(time, "%m", tz="UTC"))
)]
dt2[, Q  := ((Month - 1L) %/% 3L) + 1L]
dt2[, YQ := paste0(Year, " Q", Q)]

obs[, `:=`(
  Year  = as.integer(format(time, "%Y", tz="UTC")),
  Month = as.integer(format(time, "%m", tz="UTC"))
)]
obs[, Q  := ((Month - 1L) %/% 3L) + 1L]
obs[, YQ := paste0(Year, " Q", Q)]

obs_cov <- obs[, .(horas_obs=.N), by=.(Zona,Year,Q,YQ)]
obs_cov[, horas_teo := mapply(hours_in_q, Year, Q)]
obs_cov[, coverage  := pmin(1, horas_obs/horas_teo)]

tri <- dt2[, .(
  horas_teo = .N,
  WPD_p50   = as.numeric(quantile(WPD, 0.50, na.rm=TRUE)),
  WPD_p90   = as.numeric(quantile(WPD, 0.90, na.rm=TRUE)),
  WPD_mean  = mean(WPD, na.rm=TRUE),
  E_free    = sum(Eh, na.rm=TRUE)
), by=.(Zona,Year,Q,YQ)]

tri <- merge(tri, obs_cov[,.(Zona,Year,Q,YQ,horas_obs,coverage)],
             by=c("Zona","Year","Q","YQ"), all.x=TRUE)
tri[is.na(horas_obs), `:=`(horas_obs=0L, coverage=0)]

tri[, FNRR := fnrr_from_p(WPD_p50, WPD_p90)]
tri[, coh  := 1 - FNRR]
tri[, E_usable := E_free * coh]

# -------------------------
# 5.1) CAP físico suave para E_free (p99.5 histórico por zona)
# -------------------------
E_CAP <- tri[, .(
  E_cap_p995 = as.numeric(quantile(E_free, 0.995, na.rm=TRUE))
), by=Zona]

cap_soft <- function(x, cap_hi) pmin(x, cap_hi)

# -------------------------
# 6) Forecast trimestral 2022Q3-2028Q4 (ARIMA estacional en log1p)
# -------------------------
future_yq <- c()
for (y in LAST_OBS_Y:END_Y) for (q in 1:4)
  if (y > LAST_OBS_Y || (y==LAST_OBS_Y && q > LAST_OBS_Q)) future_yq <- c(future_yq, paste0(y," Q",q))
h <- length(future_yq)

fit_fc <- function(x, h, level=90){
  x <- pmax(as.numeric(x), 0)
  lx <- log1p(x)
  if (anyNA(lx)) lx <- as.numeric(na.interp(ts(lx, frequency=4, start=c(2017,1))))
  tsx <- ts(lx, frequency=4, start=c(2017,1))
  fit <- auto.arima(tsx, seasonal=TRUE, stepwise=TRUE, approximation=TRUE)
  forecast(fit, h=h, level=level)
}
back <- function(fc){
  list(
    mean = pmax(expm1(as.numeric(fc$mean)), 0),
    lo   = pmax(expm1(as.numeric(fc$lower[,1])), 0),
    hi   = pmax(expm1(as.numeric(fc$upper[,1])), 0)
  )
}

future_list <- list()

for (z in zones) {
  tri_z <- tri[Zona==z][order(Year,Q)]

  base_yq <- c()
  for (y in 2017:LAST_OBS_Y) for (q in 1:4)
    if (y < LAST_OBS_Y || (y==LAST_OBS_Y && q<=LAST_OBS_Q)) base_yq <- c(base_yq, paste0(y," Q",q))

  base_dt <- data.table(YQ=base_yq)
  tri_z <- merge(base_dt, tri_z[,.(YQ, WPD_p50, WPD_p90, E_free)], by="YQ", all.x=TRUE)

  fc50 <- back(fit_fc(tri_z$WPD_p50, h=h, level=LEVEL_PI))
  fc90 <- back(fit_fc(tri_z$WPD_p90, h=h, level=LEVEL_PI))
  fcE  <- back(fit_fc(tri_z$E_free , h=h, level=LEVEL_PI))

  fut <- data.table(
    Zona=z,
    YQ=future_yq,
    Year=as.integer(substr(future_yq,1,4)),
    Q=as.integer(sub(".*Q","",future_yq)),
    horas_teo=mapply(hours_in_q,
                     as.integer(substr(future_yq,1,4)),
                     as.integer(sub(".*Q","",future_yq))),
    horas_obs=0L,
    coverage=1,

    WPD_p50=fc50$mean,
    WPD_p90=fc90$mean,
    E_free=fcE$mean,

    E_free_lo=fcE$lo,
    E_free_hi=fcE$hi
  )

  # cap suave energía futuro (evita explosión)
  capz <- E_CAP[Zona==z]$E_cap_p995
  if (length(capz)==1 && is.finite(capz) && capz>0) {
    fut[, E_free := cap_soft(E_free, capz)]
    fut[, E_free_lo := pmin(E_free_lo, capz)]
    fut[, E_free_hi := pmin(E_free_hi, capz)]
  }

  fut[, WPD_mean := 0.6*WPD_p50 + 0.4*WPD_p90]
  fut[, FNRR := fnrr_from_p(WPD_p50, WPD_p90)]
  fut[, coh  := 1 - FNRR]
  fut[, E_usable := E_free * coh]

  # Regularización física Zona 1 + coherencia energía
  if (z==1 && nrow(row_w1)==1 && row_w1$c_w>0 && row_w1$k_w>0) {
    ws1 <- weibull_mu_sd(row_w1$c_w, row_w1$k_w)
    cap1 <- ws1$mu + 2*ws1$sd
    fut[, WPD_p50  := cap_struct(WPD_p50 , cap1)]
    fut[, WPD_p90  := cap_struct(WPD_p90 , cap1)]
    fut[, WPD_mean := cap_struct(WPD_mean, cap1)]
    fut[, E_free   := (WPD_mean/1000) * horas_teo]
    # cap también aquí
    capz2 <- E_CAP[Zona==z]$E_cap_p995
    if (length(capz2)==1 && is.finite(capz2) && capz2>0) {
      fut[, E_free := cap_soft(E_free, capz2)]
    }
    fut[, E_usable := E_free * (1 - FNRR)]
  }

  future_list[[as.character(z)]] <- fut
}

future_tri <- rbindlist(future_list, fill=TRUE)

tri_all <- rbindlist(list(
  tri[, .(Zona,Year,Q,YQ,horas_teo,horas_obs,coverage,WPD_p50,WPD_p90,WPD_mean,E_free,E_usable,FNRR,coh)],
  future_tri[, .(Zona,Year,Q,YQ,horas_teo,horas_obs,coverage,WPD_p50,WPD_p90,WPD_mean,E_free,E_usable,FNRR,coh,E_free_lo,E_free_hi)]
), fill=TRUE)
setorder(tri_all, Zona, Year, Q)

# -------------------------
# 7) Anual (PI90 por simulación Monte Carlo en log1p) - NIVEL DOCTORAL
# -------------------------

# simulación desde forecast (en log1p), devuelve en escala original
sim_from_fc_log <- function(fc, nsim=2000){
  mu <- as.numeric(fc$mean)
  z  <- 1.64485362695147  # PI90
  lo <- as.numeric(fc$lower[,1])
  hi <- as.numeric(fc$upper[,1])
  sd <- (hi - lo) / (2*z)
  sd[!is.finite(sd) | sd<=0] <- median(sd[is.finite(sd) & sd>0], na.rm=TRUE)
  if (!is.finite(sd[1])) sd <- rep(0.0, length(mu))

  sims <- matrix(rnorm(length(mu)*nsim, mean=rep(mu, nsim), sd=rep(sd, nsim)),
                 nrow=length(mu), ncol=nsim)
  pmax(expm1(sims), 0)
}

# anual histórico: sin PI (observado)
ann_hist <- tri_all[Year <= LAST_OBS_Y, .(
  horas_teo = sum(horas_teo),
  horas_obs = sum(horas_obs),
  coverage  = weighted.mean(coverage, w=horas_teo),

  WPD_mean  = weighted.mean(WPD_mean, w=horas_teo),
  WPD_p50   = weighted.mean(WPD_p50 , w=horas_teo),
  WPD_p90   = weighted.mean(WPD_p90 , w=horas_teo),

  E_free    = sum(E_free),
  E_usable  = sum(E_usable),

  FNRR      = weighted.mean(FNRR, w=horas_teo),
  coh       = weighted.mean(coh , w=horas_teo),

  E_free_lo = NA_real_,
  E_free_hi = NA_real_
), by=.(Zona,Year)]

# mapa de trimestres futuros -> año
fut_map <- data.table(
  YQ=future_yq,
  Year=as.integer(substr(future_yq,1,4)),
  Q=as.integer(sub(".*Q","",future_yq))
)
years_fut <- sort(unique(fut_map$Year))

ann_fut_list <- list()

for (z in zones) {

  # reconstruir serie E_free trimestral observada (hasta 2022Q2)
  tri_z <- tri[Zona==z][order(Year,Q)]
  base_yq <- c()
  for (y in 2017:LAST_OBS_Y) for (q in 1:4)
    if (y < LAST_OBS_Y || (y==LAST_OBS_Y && q<=LAST_OBS_Q)) base_yq <- c(base_yq, paste0(y," Q",q))
  base_dt <- data.table(YQ=base_yq)
  tri_z <- merge(base_dt, tri_z[,.(YQ, E_free)], by="YQ", all.x=TRUE)

  x <- pmax(as.numeric(tri_z$E_free), 0)
  lx <- log1p(x)
  if (anyNA(lx)) lx <- as.numeric(na.interp(ts(lx, frequency=4, start=c(2017,1))))
  tsx <- ts(lx, frequency=4, start=c(2017,1))
  fit <- auto.arima(tsx, seasonal=TRUE, stepwise=TRUE, approximation=TRUE)
  fc  <- forecast(fit, h=h, level=LEVEL_PI)

  # sim trimestral futuro
  sim_q <- sim_from_fc_log(fc, nsim=NSIM_PI_ANUAL)  # (h x nsim)

  # cap físico suave aplicado a simulación
  capz <- E_CAP[Zona==z]$E_cap_p995
  if (length(capz)==1 && is.finite(capz) && capz>0) {
    sim_q <- pmin(sim_q, capz)
  }

  # anual por suma de 4 trimestres, por simulación
  rows <- list()
  for (yy in years_fut) {
    idx <- which(fut_map$Year == yy)
    if (length(idx)==0) next
    sY <- colSums(sim_q[idx, , drop=FALSE])
    rows[[as.character(yy)]] <- data.table(
      Zona=z,
      Year=yy,
      E_free_lo = as.numeric(quantile(sY, 0.05, na.rm=TRUE)),
      E_free_hi = as.numeric(quantile(sY, 0.95, na.rm=TRUE))
    )
  }
  ann_fut_list[[as.character(z)]] <- rbindlist(rows, fill=TRUE)
}

ann_fut_pi <- rbindlist(ann_fut_list, fill=TRUE)

# anual base (incluye futuro) desde tri_all (mean)
ann_base <- tri_all[, .(
  horas_teo = sum(horas_teo),
  horas_obs = sum(horas_obs),
  coverage  = weighted.mean(coverage, w=horas_teo),

  WPD_mean  = weighted.mean(WPD_mean, w=horas_teo),
  WPD_p50   = weighted.mean(WPD_p50 , w=horas_teo),
  WPD_p90   = weighted.mean(WPD_p90 , w=horas_teo),

  E_free    = sum(E_free),
  E_usable  = sum(E_usable),

  FNRR      = weighted.mean(FNRR, w=horas_teo),
  coh       = weighted.mean(coh , w=horas_teo)
), by=.(Zona,Year)]

ann <- merge(ann_base, ann_fut_pi, by=c("Zona","Year"), all.x=TRUE)

# usable bounds por coherencia anual
ann[, E_usable_lo := E_free_lo * (1 - FNRR)]
ann[, E_usable_hi := E_free_hi * (1 - FNRR)]

# unir histórico (para dejar PI NA donde no aplica) + base con PI (futuro)
ann <- rbindlist(list(ann_hist, ann[Year > LAST_OBS_Y]), fill=TRUE)
setorder(ann, Zona, Year)

# -------------------------
# 8) Export
# -------------------------
fwrite(tri_all, file.path(OUT, "CAP4_TDQ_TRIMESTRAL_2017_2028.csv"))
fwrite(ann,     file.path(OUT, "CAP4_TDQ_ANUAL_2017_2028.csv"))

# -------------------------
# 9) Figuras publicables
# -------------------------
theme_pub <- theme_bw(base_size=12) +
  theme(panel.grid.minor=element_blank(),
        legend.position="bottom",
        plot.title=element_text(face="bold"),
        axis.title=element_text(face="bold"))

tri_plot <- copy(tri_all)
tri_plot[, t_index := as.Date(sprintf("%04d-%02d-01", Year, (Q-1L)*3L + 1L))]

p1 <- ggplot(tri_plot, aes(t_index, WPD_mean, color=factor(Zona), group=factor(Zona))) +
  geom_line(linewidth=0.9) + geom_point(size=1.2) +
  geom_vline(xintercept=as.Date("2022-04-01"), linetype="dashed") +
  labs(title="WPD trimestral TDQ (2017-2028)", x="Inicio de trimestre", y="WPD (W/m2)", color="Zona") +
  theme_pub
ggsave(file.path(OUT, "FIG_CAP4_WPD_TRIMESTRAL_TDQ_2017_2028.png"), p1, width=12, height=5, dpi=300)

ann_plot <- copy(ann)
ann_plot[, is_fc := Year > 2022]  # forecast desde 2023

p2 <- ggplot() +
  # PI90 solo futuro
  geom_ribbon(
    data = ann_plot[is_fc==TRUE],
    aes(x=Year, ymin=E_free_lo, ymax=E_free_hi, fill=factor(Zona), group=factor(Zona)),
    alpha=0.15, color=NA
  ) +
  # líneas
  geom_line(
    data=ann_plot,
    aes(x=Year, y=E_free, color=factor(Zona), group=factor(Zona)),
    linewidth=0.9
  ) +
  geom_line(
    data=ann_plot,
    aes(x=Year, y=E_usable, color=factor(Zona), group=factor(Zona)),
    linewidth=0.9, linetype="dotted"
  ) +
  # corte
  geom_vline(xintercept=2022.5, linetype="dashed") +
  labs(
    title="Energía anual (kWh/m2): libre vs usable + PI90",
    x="Año", y="Energía (kWh/m2)", color="Zona", fill="Zona"
  ) +
  theme_pub +
  scale_y_continuous(labels=scales::comma)

ggsave(file.path(OUT, "FIG_CAP4_ENERGIA_ANUAL_LIBRE_USABLE_PI90.png"),
       p2, width=12, height=5, dpi=300)
p3 <- ggplot(ann, aes(Year, FNRR, color=factor(Zona), group=factor(Zona))) +
  geom_line(linewidth=0.9) + geom_point(size=1.2) +
  scale_y_continuous(limits=c(0,1)) +
  labs(title="FNRR anual TDQ (2017-2028)", x="Año", y="FNRR (0-1)", color="Zona") +
  theme_pub
ggsave(file.path(OUT, "FIG_CAP4_FNRR_ANUAL_TDQ_2017_2028.png"), p3, width=12, height=5, dpi=300)

cat("\n==============================================\n")
cat("OK ✅ CAP4 TDQ FINAL + AJUSTE FINO\nOUT:", OUT, "\n")
cat("Tablas: CAP4_TDQ_TRIMESTRAL_2017_2028.csv | CAP4_TDQ_ANUAL_2017_2028.csv\n")
cat("Figuras: WPD trimestral | Energía anual + PI90 (sim) | FNRR anual\n")
cat("==============================================\n")



# ============================================================
# CAP4 - TDQ CIERRE FINAL (ANTI-ERRORES + AJUSTE FINO) | WPD + Eh + PI90 + FNRR
# SIN lubridate
# Trimestral + Anual, Forecast 2022Q3-2028Q4
# Regularización física Zona 1 (Weibull mu + 2sd)
# PI90 ANUAL: por simulación (Monte Carlo) en log1p (nivel doctoral)
# ============================================================

req <- c("data.table","forecast","ggplot2","scales")
for (p in req) if (!requireNamespace(p, quietly=TRUE)) install.packages(p, dependencies=TRUE)
suppressPackageStartupMessages({
  library(data.table); library(forecast); library(ggplot2); library(scales)
})

# -------------------------
# 1) Rutas
# -------------------------
ROOT <- ""  # <-- set path
OUT  <- file.path(ROOT, "SALIDAS_CAP4_TDQ_FINAL")
dir.create(OUT, showWarnings=FALSE, recursive=TRUE)

CACHE_FILE <- file.path(ROOT, "SALIDAS_CAP4_CACHE", "WPD_Eh_hourly_por_zona.csv")
if (!file.exists(CACHE_FILE)) stop("No existe CACHE_FILE: ", CACHE_FILE)

# -------------------------
# 2) Parámetros
# -------------------------
LEVEL_PI <- 90
START_DT   <- as.POSIXct("2017-01-01 00:00:00", tz="UTC")
CUTOFF_END <- as.POSIXct("2022-06-30 23:00:00", tz="UTC")

LAST_OBS_Y <- 2022
LAST_OBS_Q <- 2
END_Y <- 2028
END_Q <- 4

# Simulación PI anual (sube a 5000 si quieres más suave)
NSIM_PI_ANUAL <- 3000

WEIBULL_PARAMS <- data.table(
  Zona = c(1,2,3,4),
  c_w  = c(1.90, 3.20, 2.80, 3.85),
  k_w  = c(0.60, 1.35, 1.35, 1.95)
)

weibull_mu_sd <- function(c_w, k_w) {
  mu  <- c_w * gamma(1 + 1/k_w)
  var <- c_w^2 * (gamma(1 + 2/k_w) - (gamma(1 + 1/k_w))^2)
  sd  <- sqrt(pmax(var, 0))
  list(mu=mu, sd=sd)
}
cap_struct <- function(x, cap) pmin(x, cap)
clamp01 <- function(x) pmax(0, pmin(1, x))
fnrr_from_p <- function(p50, p90) {
  a <- log1p(p90); b <- log1p(p50)
  clamp01((a - b) / (a + 1e-12))
}

hours_in_q <- function(y, q) {
  m0 <- (q-1L)*3L + 1L
  st <- as.POSIXct(sprintf("%04d-%02d-01 00:00:00", y, m0), tz="UTC")
  y2 <- y + (q==4L)
  q2 <- if (q==4L) 1L else (q+1L)
  m1 <- (q2-1L)*3L + 1L
  en <- as.POSIXct(sprintf("%04d-%02d-01 00:00:00", y2, m1), tz="UTC")
  as.integer(difftime(en, st, units="hours"))
}

# -------------------------
# 3) Leer cache y CREAR time (parser multi-formato)
# -------------------------
cat(format(Sys.time(), "%F %T"), "| Leyendo:", CACHE_FILE, "\n")
dt <- fread(CACHE_FILE, showProgress=TRUE)

clean_names <- function(x){
  x <- gsub("^\ufeff","", x)
  x <- gsub("[\r\n\t]","", x)
  trimws(x)
}
setnames(dt, clean_names(names(dt)))
nms_low <- tolower(names(dt))

time_idx <- which(nms_low %in% c("fechahora","fechayhora","fecha_hora","datetime","date_time","timestamp","time"))
if (length(time_idx) == 0) time_idx <- which(grepl("fecha", nms_low) & grepl("hora", nms_low))
if (length(time_idx) == 0) time_idx <- which(grepl("datetime|timestamp", nms_low))
if (length(time_idx) == 0) stop("No detecté columna tiempo. Columnas: ", paste(names(dt), collapse=", "))
TIME_COL <- names(dt)[time_idx[1]]

parse_time_base <- function(x, tz_out="UTC") {
  if (inherits(x,"POSIXct")) return(as.POSIXct(x, tz=tz_out))
  if (inherits(x,"POSIXlt")) return(as.POSIXct(x, tz=tz_out))
  if (inherits(x,"Date"))   return(as.POSIXct(x, tz=tz_out))
  if (is.factor(x) || is.ordered(x)) x <- as.character(x)

  if (!is.numeric(x) && !is.character(x)) {
    x <- tryCatch(as.character(x), error=function(e) rep(NA_character_, length(x)))
  }

  if (is.numeric(x)) {
    xx <- x[is.finite(x)]
    if (length(xx)==0) return(as.POSIXct(rep(NA, length(x)), origin="1970-01-01", tz=tz_out))
    med <- median(xx, na.rm=TRUE)
    div <- if (med > 1e14) 1e6 else if (med > 1e11) 1e3 else 1
    return(as.POSIXct(x/div, origin="1970-01-01", tz=tz_out))
  }

  x <- as.character(x)
  x <- gsub("^\ufeff","", x)
  x <- trimws(gsub("[\r\n\t]", " ", x))
  x[x==""] <- NA_character_

  fmts <- c(
    "%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M",
    "%Y/%m/%d %H:%M:%S", "%Y/%m/%d %H:%M",
    "%Y%m%d %H:%M:%S",   "%Y%m%d %H:%M",
    "%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M",
    "%m/%d/%Y %H:%M:%S", "%m/%d/%Y %H:%M",
    "%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M",
    "%Y-%m-%d %I:%M:%S %p", "%Y-%m-%d %I:%M %p",
    "%d/%m/%Y %I:%M:%S %p", "%d/%m/%Y %I:%M %p",
    "%m/%d/%Y %I:%M:%S %p", "%m/%d/%Y %I:%M %p"
  )

  out <- rep(as.POSIXct(NA, tz=tz_out), length(x))
  for (fmt in fmts) {
    idx <- which(is.na(out) & !is.na(x))
    if (length(idx)==0) break
    tt <- suppressWarnings(as.POSIXct(strptime(x[idx], format=fmt, tz=tz_out), tz=tz_out))
    ok <- !is.na(tt)
    if (any(ok)) out[idx[ok]] <- tt[ok]
  }
  out
}

dt[, time := parse_time_base(dt[[TIME_COL]], tz_out="UTC")]
if (!inherits(dt$time, "POSIXct")) stop("time NO es POSIXct. class=", paste(class(dt$time), collapse=", "))

na_rate <- mean(is.na(dt$time))
if (!is.finite(na_rate)) na_rate <- 1
if (na_rate > 0.05) {
  bad <- unique(as.character(dt[is.na(time), ..TIME_COL][[1]]))
  bad <- bad[1:min(25, length(bad))]
  stop(
    "Fallo parseo time: NA rate=", round(100*na_rate,2), "% | TIME_COL=", TIME_COL, "\n",
    "Ejemplos que NO parsean:\n- ", paste(bad, collapse="\n- ")
  )
}

# Normalizar Zona/WPD/Eh
if (!"Zona" %in% names(dt)) stop("Falta 'Zona'.")
dt[, Zona := as.integer(Zona)]

if (!"WPD" %in% names(dt)) {
  widx <- which(tolower(names(dt)) %in% c("wpd","wpd_w_m2","wpd_wm2","wpd_tdq","wpd_mean"))
  if (length(widx)==0) stop("No detecté WPD. Columnas: ", paste(names(dt), collapse=", "))
  setnames(dt, names(dt)[widx[1]], "WPD")
}
dt[, WPD := pmax(as.numeric(WPD), 0)]

if (!"Eh" %in% names(dt)) {
  eidx <- which(tolower(names(dt)) %in% c("eh","eh_kwh_m2","eh_kwhm2","eh_tdq","energy"))
  if (length(eidx)==0) stop("No detecté Eh. Columnas: ", paste(names(dt), collapse=", "))
  setnames(dt, names(dt)[eidx[1]], "Eh")
}
dt[, Eh := pmax(as.numeric(Eh), 0)]

# ventana observada
dt <- dt[!is.na(Zona) & !is.na(time)]
dt <- dt[time >= START_DT & time <= CUTOFF_END]
dt <- dt[is.finite(WPD) & is.finite(Eh)]
setorder(dt, Zona, time)

zones <- sort(unique(dt$Zona))
if (length(zones) < 1) stop("No hay datos en 2017-01 a 2022-06.")
cat(format(Sys.time(), "%F %T"), "| OK | zones:", paste(zones, collapse=", "), "| rows:", nrow(dt), "\n")

# -------------------------
# 3.1) FIX CRÍTICO: eliminar duplicados (Zona,time)
# -------------------------
dupN <- dt[, .N, by=.(Zona, time)][N > 1]
if (nrow(dupN) > 0) {
  cat("⚠️ Duplicados detectados en (Zona,time):", nrow(dupN), "claves con repetición.\n")
  print(head(dupN, 10))
  fwrite(dupN, file.path(OUT, "DEBUG_DUPLICADOS_Zona_time.csv"))

  dt <- dt[, .(
    WPD = mean(WPD, na.rm=TRUE),
    Eh  = mean(Eh , na.rm=TRUE)
  ), by=.(Zona, time)]
  setorder(dt, Zona, time)
  cat("✅ dt colapsado: filas =", nrow(dt), "y claves únicas (Zona,time).\n")
} else {
  cat("✅ No hay duplicados en (Zona,time).\n")
}

# -------------------------
# 4) TDQ orden: grilla completa + imputación Month-Hour
# -------------------------
full_grid <- rbindlist(lapply(zones, function(z){
  data.table(Zona=z, time=seq(START_DT, CUTOFF_END, by="hour"))
}))

setkey(full_grid, Zona, time)
setkey(dt, Zona, time)

obs <- copy(dt)

# join seguro: grilla recibe observados
dt2 <- dt[full_grid, on=.(Zona, time)]

dt2[, time := as.POSIXct(time, tz="UTC")]
obs[, time := as.POSIXct(time, tz="UTC")]

stopifnot(inherits(dt2$time, "POSIXct"))
stopifnot(length(dt2$time) == nrow(dt2))

dt2[, `:=`(
  Month = as.integer(format(time, "%m", tz="UTC")),
  Hour  = as.integer(format(time, "%H", tz="UTC"))
)]

prof_mh <- dt2[!is.na(WPD), .(
  WPD_med = median(WPD, na.rm=TRUE),
  Eh_med  = median(Eh , na.rm=TRUE)
), by=.(Zona, Month, Hour)]
setkey(prof_mh, Zona, Month, Hour)

prof_h <- dt2[!is.na(WPD), .(
  WPD_med2 = median(WPD, na.rm=TRUE),
  Eh_med2  = median(Eh , na.rm=TRUE)
), by=.(Zona, Hour)]
setkey(prof_h, Zona, Hour)

glob_wpd <- median(dt2$WPD, na.rm=TRUE); if (!is.finite(glob_wpd)) glob_wpd <- 0
glob_eh  <- median(dt2$Eh , na.rm=TRUE); if (!is.finite(glob_eh )) glob_eh  <- 0

dt2 <- prof_mh[dt2, on=.(Zona, Month, Hour)]
dt2 <- prof_h[dt2,  on=.(Zona, Hour)]

dt2[is.na(WPD), WPD := fifelse(!is.na(WPD_med), WPD_med,
                               fifelse(!is.na(WPD_med2), WPD_med2, glob_wpd))]
dt2[is.na(Eh),  Eh  := fifelse(!is.na(Eh_med),  Eh_med,
                               fifelse(!is.na(Eh_med2), Eh_med2,  glob_eh ))]
dt2[, c("WPD_med","Eh_med","WPD_med2","Eh_med2") := NULL]

# Regularización física Zona 1 (Weibull mu+2sd) + coherencia energía
row_w1 <- WEIBULL_PARAMS[Zona==1]
if (1 %in% zones && nrow(row_w1)==1 && row_w1$c_w>0 && row_w1$k_w>0) {
  ws1 <- weibull_mu_sd(row_w1$c_w, row_w1$k_w)
  cap1 <- ws1$mu + 2*ws1$sd
  dt2[Zona==1, WPD := cap_struct(WPD, cap1)]
  dt2[Zona==1, Eh  := WPD/1000]
}

# -------------------------
# 5) Trimestral observado + coverage
# -------------------------
dt2[, `:=`(
  Year  = as.integer(format(time, "%Y", tz="UTC")),
  Month = as.integer(format(time, "%m", tz="UTC"))
)]
dt2[, Q  := ((Month - 1L) %/% 3L) + 1L]
dt2[, YQ := paste0(Year, " Q", Q)]

obs[, `:=`(
  Year  = as.integer(format(time, "%Y", tz="UTC")),
  Month = as.integer(format(time, "%m", tz="UTC"))
)]
obs[, Q  := ((Month - 1L) %/% 3L) + 1L]
obs[, YQ := paste0(Year, " Q", Q)]

obs_cov <- obs[, .(horas_obs=.N), by=.(Zona,Year,Q,YQ)]
obs_cov[, horas_teo := mapply(hours_in_q, Year, Q)]
obs_cov[, coverage  := pmin(1, horas_obs/horas_teo)]

tri <- dt2[, .(
  horas_teo = .N,
  WPD_p50   = as.numeric(quantile(WPD, 0.50, na.rm=TRUE)),
  WPD_p90   = as.numeric(quantile(WPD, 0.90, na.rm=TRUE)),
  WPD_mean  = mean(WPD, na.rm=TRUE),
  E_free    = sum(Eh, na.rm=TRUE)
), by=.(Zona,Year,Q,YQ)]

tri <- merge(tri, obs_cov[,.(Zona,Year,Q,YQ,horas_obs,coverage)],
             by=c("Zona","Year","Q","YQ"), all.x=TRUE)
tri[is.na(horas_obs), `:=`(horas_obs=0L, coverage=0)]

tri[, FNRR := fnrr_from_p(WPD_p50, WPD_p90)]
tri[, coh  := 1 - FNRR]
tri[, E_usable := E_free * coh]

# -------------------------
# 5.1) CAP físico suave para E_free (p99.5 histórico por zona)
# -------------------------
E_CAP <- tri[, .(
  E_cap_p995 = as.numeric(quantile(E_free, 0.995, na.rm=TRUE))
), by=Zona]

cap_soft <- function(x, cap_hi) pmin(x, cap_hi)

# -------------------------
# 6) Forecast trimestral 2022Q3-2028Q4 (ARIMA estacional en log1p)
# -------------------------
future_yq <- c()
for (y in LAST_OBS_Y:END_Y) for (q in 1:4)
  if (y > LAST_OBS_Y || (y==LAST_OBS_Y && q > LAST_OBS_Q)) future_yq <- c(future_yq, paste0(y," Q",q))
h <- length(future_yq)

fit_fc <- function(x, h, level=90){
  x <- pmax(as.numeric(x), 0)
  lx <- log1p(x)
  if (anyNA(lx)) lx <- as.numeric(na.interp(ts(lx, frequency=4, start=c(2017,1))))
  tsx <- ts(lx, frequency=4, start=c(2017,1))
  fit <- auto.arima(tsx, seasonal=TRUE, stepwise=TRUE, approximation=TRUE)
  forecast(fit, h=h, level=level)
}
back <- function(fc){
  list(
    mean = pmax(expm1(as.numeric(fc$mean)), 0),
    lo   = pmax(expm1(as.numeric(fc$lower[,1])), 0),
    hi   = pmax(expm1(as.numeric(fc$upper[,1])), 0)
  )
}

future_list <- list()

for (z in zones) {
  tri_z <- tri[Zona==z][order(Year,Q)]

  base_yq <- c()
  for (y in 2017:LAST_OBS_Y) for (q in 1:4)
    if (y < LAST_OBS_Y || (y==LAST_OBS_Y && q<=LAST_OBS_Q)) base_yq <- c(base_yq, paste0(y," Q",q))

  base_dt <- data.table(YQ=base_yq)
  tri_z <- merge(base_dt, tri_z[,.(YQ, WPD_p50, WPD_p90, E_free)], by="YQ", all.x=TRUE)

  fc50 <- back(fit_fc(tri_z$WPD_p50, h=h, level=LEVEL_PI))
  fc90 <- back(fit_fc(tri_z$WPD_p90, h=h, level=LEVEL_PI))
  fcE  <- back(fit_fc(tri_z$E_free , h=h, level=LEVEL_PI))

  fut <- data.table(
    Zona=z,
    YQ=future_yq,
    Year=as.integer(substr(future_yq,1,4)),
    Q=as.integer(sub(".*Q","",future_yq)),
    horas_teo=mapply(hours_in_q,
                     as.integer(substr(future_yq,1,4)),
                     as.integer(sub(".*Q","",future_yq))),
    horas_obs=0L,
    coverage=1,

    WPD_p50=fc50$mean,
    WPD_p90=fc90$mean,
    E_free=fcE$mean,

    E_free_lo=fcE$lo,
    E_free_hi=fcE$hi
  )

  # cap suave energía futuro (evita explosión)
  capz <- E_CAP[Zona==z]$E_cap_p995
  if (length(capz)==1 && is.finite(capz) && capz>0) {
    fut[, E_free := cap_soft(E_free, capz)]
    fut[, E_free_lo := pmin(E_free_lo, capz)]
    fut[, E_free_hi := pmin(E_free_hi, capz)]
  }

  fut[, WPD_mean := 0.6*WPD_p50 + 0.4*WPD_p90]
  fut[, FNRR := fnrr_from_p(WPD_p50, WPD_p90)]
  fut[, coh  := 1 - FNRR]
  fut[, E_usable := E_free * coh]

  # Regularización física Zona 1 + coherencia energía
  if (z==1 && nrow(row_w1)==1 && row_w1$c_w>0 && row_w1$k_w>0) {
    ws1 <- weibull_mu_sd(row_w1$c_w, row_w1$k_w)
    cap1 <- ws1$mu + 2*ws1$sd
    fut[, WPD_p50  := cap_struct(WPD_p50 , cap1)]
    fut[, WPD_p90  := cap_struct(WPD_p90 , cap1)]
    fut[, WPD_mean := cap_struct(WPD_mean, cap1)]
    fut[, E_free   := (WPD_mean/1000) * horas_teo]
    # cap también aquí
    capz2 <- E_CAP[Zona==z]$E_cap_p995
    if (length(capz2)==1 && is.finite(capz2) && capz2>0) {
      fut[, E_free := cap_soft(E_free, capz2)]
    }
    fut[, E_usable := E_free * (1 - FNRR)]
  }

  future_list[[as.character(z)]] <- fut
}

future_tri <- rbindlist(future_list, fill=TRUE)

tri_all <- rbindlist(list(
  tri[, .(Zona,Year,Q,YQ,horas_teo,horas_obs,coverage,WPD_p50,WPD_p90,WPD_mean,E_free,E_usable,FNRR,coh)],
  future_tri[, .(Zona,Year,Q,YQ,horas_teo,horas_obs,coverage,WPD_p50,WPD_p90,WPD_mean,E_free,E_usable,FNRR,coh,E_free_lo,E_free_hi)]
), fill=TRUE)
setorder(tri_all, Zona, Year, Q)

# -------------------------
# 7) Anual (PI90 por simulación Monte Carlo en log1p) - NIVEL DOCTORAL
# -------------------------

# simulación desde forecast (en log1p), devuelve en escala original
sim_from_fc_log <- function(fc, nsim=2000){
  mu <- as.numeric(fc$mean)
  z  <- 1.64485362695147  # PI90
  lo <- as.numeric(fc$lower[,1])
  hi <- as.numeric(fc$upper[,1])
  sd <- (hi - lo) / (2*z)
  sd[!is.finite(sd) | sd<=0] <- median(sd[is.finite(sd) & sd>0], na.rm=TRUE)
  if (!is.finite(sd[1])) sd <- rep(0.0, length(mu))

  sims <- matrix(rnorm(length(mu)*nsim, mean=rep(mu, nsim), sd=rep(sd, nsim)),
                 nrow=length(mu), ncol=nsim)
  pmax(expm1(sims), 0)
}

# anual histórico: sin PI (observado)
ann_hist <- tri_all[Year <= LAST_OBS_Y, .(
  horas_teo = sum(horas_teo),
  horas_obs = sum(horas_obs),
  coverage  = weighted.mean(coverage, w=horas_teo),

  WPD_mean  = weighted.mean(WPD_mean, w=horas_teo),
  WPD_p50   = weighted.mean(WPD_p50 , w=horas_teo),
  WPD_p90   = weighted.mean(WPD_p90 , w=horas_teo),

  E_free    = sum(E_free),
  E_usable  = sum(E_usable),

  FNRR      = weighted.mean(FNRR, w=horas_teo),
  coh       = weighted.mean(coh , w=horas_teo),

  E_free_lo = NA_real_,
  E_free_hi = NA_real_
), by=.(Zona,Year)]

# mapa de trimestres futuros -> año
fut_map <- data.table(
  YQ=future_yq,
  Year=as.integer(substr(future_yq,1,4)),
  Q=as.integer(sub(".*Q","",future_yq))
)
years_fut <- sort(unique(fut_map$Year))

ann_fut_list <- list()

for (z in zones) {

  # reconstruir serie E_free trimestral observada (hasta 2022Q2)
  tri_z <- tri[Zona==z][order(Year,Q)]
  base_yq <- c()
  for (y in 2017:LAST_OBS_Y) for (q in 1:4)
    if (y < LAST_OBS_Y || (y==LAST_OBS_Y && q<=LAST_OBS_Q)) base_yq <- c(base_yq, paste0(y," Q",q))
  base_dt <- data.table(YQ=base_yq)
  tri_z <- merge(base_dt, tri_z[,.(YQ, E_free)], by="YQ", all.x=TRUE)

  x <- pmax(as.numeric(tri_z$E_free), 0)
  lx <- log1p(x)
  if (anyNA(lx)) lx <- as.numeric(na.interp(ts(lx, frequency=4, start=c(2017,1))))
  tsx <- ts(lx, frequency=4, start=c(2017,1))
  fit <- auto.arima(tsx, seasonal=TRUE, stepwise=TRUE, approximation=TRUE)
  fc  <- forecast(fit, h=h, level=LEVEL_PI)

  # sim trimestral futuro
  sim_q <- sim_from_fc_log(fc, nsim=NSIM_PI_ANUAL)  # (h x nsim)

  # cap físico suave aplicado a simulación
  capz <- E_CAP[Zona==z]$E_cap_p995
  if (length(capz)==1 && is.finite(capz) && capz>0) {
    sim_q <- pmin(sim_q, capz)
  }

  # anual por suma de 4 trimestres, por simulación
  rows <- list()
  for (yy in years_fut) {
    idx <- which(fut_map$Year == yy)
    if (length(idx)==0) next
    sY <- colSums(sim_q[idx, , drop=FALSE])
    rows[[as.character(yy)]] <- data.table(
      Zona=z,
      Year=yy,
      E_free_lo = as.numeric(quantile(sY, 0.05, na.rm=TRUE)),
      E_free_hi = as.numeric(quantile(sY, 0.95, na.rm=TRUE))
    )
  }
  ann_fut_list[[as.character(z)]] <- rbindlist(rows, fill=TRUE)
}

ann_fut_pi <- rbindlist(ann_fut_list, fill=TRUE)

# anual base (incluye futuro) desde tri_all (mean)
ann_base <- tri_all[, .(
  horas_teo = sum(horas_teo),
  horas_obs = sum(horas_obs),
  coverage  = weighted.mean(coverage, w=horas_teo),

  WPD_mean  = weighted.mean(WPD_mean, w=horas_teo),
  WPD_p50   = weighted.mean(WPD_p50 , w=horas_teo),
  WPD_p90   = weighted.mean(WPD_p90 , w=horas_teo),

  E_free    = sum(E_free),
  E_usable  = sum(E_usable),

  FNRR      = weighted.mean(FNRR, w=horas_teo),
  coh       = weighted.mean(coh , w=horas_teo)
), by=.(Zona,Year)]

ann <- merge(ann_base, ann_fut_pi, by=c("Zona","Year"), all.x=TRUE)

# usable bounds por coherencia anual
ann[, E_usable_lo := E_free_lo * (1 - FNRR)]
ann[, E_usable_hi := E_free_hi * (1 - FNRR)]

# unir histórico (para dejar PI NA donde no aplica) + base con PI (futuro)
ann <- rbindlist(list(ann_hist, ann[Year > LAST_OBS_Y]), fill=TRUE)
setorder(ann, Zona, Year)

# -------------------------
# 8) Export
# -------------------------
fwrite(tri_all, file.path(OUT, "CAP4_TDQ_TRIMESTRAL_2017_2028.csv"))
fwrite(ann,     file.path(OUT, "CAP4_TDQ_ANUAL_2017_2028.csv"))

# -------------------------
# -------------------------
# 9) Figuras publicables (FINAL - paper-ready)
# -------------------------
theme_pub <- theme_bw(base_size=12) +
  theme(panel.grid.minor=element_blank(),
        legend.position="bottom",
        plot.title=element_text(face="bold"),
        axis.title=element_text(face="bold"))

# =========
# FIG 1 - WPD trimestral
# =========
tri_plot <- copy(tri_all)
tri_plot[, t_index := as.Date(sprintf("%04d-%02d-01", Year, (Q-1L)*3L + 1L))]

p1 <- ggplot(tri_plot, aes(t_index, WPD_mean, color=factor(Zona), group=factor(Zona))) +
  geom_line(linewidth=0.9) +
  geom_point(size=1.2) +
  geom_vline(xintercept=as.Date("2022-04-01"), linetype="dashed") +
  labs(title="WPD trimestral TDQ (2017-2028)",
       x="Inicio de trimestre", y="WPD (W/m2)", color="Zona") +
  theme_pub

ggsave(file.path(OUT, "FIG_CAP4_WPD_TRIMESTRAL_TDQ_2017_2028.png"),
       p1, width=12, height=5, dpi=300)

# =========
# FIG 2 - Energía anual: libre vs usable + PI90 (PI SOLO FUTURO + puntos SOLO OBS)
# =========
ann_plot <- copy(ann)
ann_plot[, is_fc := Year > 2022]  # pronóstico desde 2023

# Para ubicar etiquetas arriba sin depender del rango exacto:
y_top <- max(ann_plot$E_free, ann_plot$E_free_hi, na.rm=TRUE)
if (!is.finite(y_top)) y_top <- 1

p2 <- ggplot() +
  # PI90 solo futuro
  geom_ribbon(
    data = ann_plot[is_fc==TRUE],
    aes(x=Year, ymin=E_free_lo, ymax=E_free_hi, fill=factor(Zona), group=factor(Zona)),
    alpha=0.15, color=NA
  ) +
  # líneas energía libre
  geom_line(
    data=ann_plot,
    aes(x=Year, y=E_free, color=factor(Zona), group=factor(Zona)),
    linewidth=0.95
  ) +
  # líneas energía usable (penalizada por FNRR)
  geom_line(
    data=ann_plot,
    aes(x=Year, y=E_usable, color=factor(Zona), group=factor(Zona)),
    linewidth=0.95, linetype="dotted"
  ) +
  # puntos SOLO en observado (limpio, editorial)
  geom_point(
    data=ann_plot[is_fc==FALSE],
    aes(x=Year, y=E_free, color=factor(Zona)),
    size=1.2
  ) +
  geom_point(
    data=ann_plot[is_fc==FALSE],
    aes(x=Year, y=E_usable, color=factor(Zona)),
    size=1.1, shape=1
  ) +
  # corte observado/pronóstico
  geom_vline(xintercept=2022.5, linetype="dashed") +
  # etiquetas observado/pronóstico
  annotate("text", x=2019.5, y=y_top, label="Observado", vjust=-0.6, fontface="bold") +
  annotate("text", x=2025.5, y=y_top, label="Pronóstico", vjust=-0.6, fontface="bold") +
  labs(title="Energía anual (kWh/m2): libre vs usable + PI90",
       x="Año", y="Energía (kWh/m2)", color="Zona", fill="Zona") +
  theme_pub +
  scale_y_continuous(labels=scales::comma)

# Si quieres lectura tipo Nature (opcional): descomenta
# p2 <- p2 + scale_y_continuous(trans="log1p", labels=scales::comma)

ggsave(file.path(OUT, "FIG_CAP4_ENERGIA_ANUAL_LIBRE_USABLE_PI90.png"),
       p2, width=12, height=5, dpi=300)

# =========
# FIG 3 - FNRR anual
# =========
p3 <- ggplot(ann, aes(Year, FNRR, color=factor(Zona), group=factor(Zona))) +
  geom_line(linewidth=0.9) +
  geom_point(size=1.2) +
  scale_y_continuous(limits=c(0,1)) +
  labs(title="FNRR anual TDQ (2017-2028)",
       x="Año", y="FNRR (0-1)", color="Zona") +
  theme_pub

ggsave(file.path(OUT, "FIG_CAP4_FNRR_ANUAL_TDQ_2017_2028.png"),
       p3, width=12, height=5, dpi=300)

cat("\n==============================================\n")
cat("OK ✅ FIGURAS CAP4 TDQ FINAL (paper-ready)\nOUT:", OUT, "\n")
cat("Exportadas:\n")
cat("- FIG_CAP4_WPD_TRIMESTRAL_TDQ_2017_2028.png\n")
cat("- FIG_CAP4_ENERGIA_ANUAL_LIBRE_USABLE_PI90.png\n")
cat("- FIG_CAP4_FNRR_ANUAL_TDQ_2017_2028.png\n")
cat("==============================================\n")

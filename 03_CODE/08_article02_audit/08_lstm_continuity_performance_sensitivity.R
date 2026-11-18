
suppressPackageStartupMessages(library(data.table))

ROOT <- "C:/Users/UMARIANA/Documents/GitHub/phd-thesis-wind-energy-narino"

DATA_FILE <- file.path(
  ROOT,
  "local_work/02_article02_dataset/article02_analytical_dataset_v1_0.rds"
)

PRED_FILE <- file.path(
  ROOT,
  "local_work/10_final_comparison/article02_master_external_predictions_v1_0.rds"
)

OUT <- file.path(ROOT, "local_work/12_manuscript/audit")
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

stopifnot(file.exists(DATA_FILE), file.exists(PRED_FILE))

D <- as.data.table(readRDS(DATA_FILE))
M <- as.data.table(readRDS(PRED_FILE))

normalize_time <- function(x) {
  if (inherits(x, "POSIXt") || is.numeric(x)) {
    return(as.POSIXct(
      as.numeric(x),
      origin = "1970-01-01",
      tz = "UTC"
    ))
  }
  as.POSIXct(x, tz = "UTC")
}

stopifnot(
  all(c("Estacion", "Hora") %in% names(D)),
  all(c("Zona", "Estacion", "horizon_h",
        "origin_time", "LSTM") %in% names(M))
)

TARGET <- intersect(
  c("WPD_target", "y_true", "WPD_actual"),
  names(M)
)

BASELINE <- intersect(
  c("persistence", "Persistence"),
  names(M)
)

if (!length(TARGET) || !length(BASELINE)) {
  stop(
    "Could not identify observed WPD or persistence column. ",
    "Available columns: ", paste(names(M), collapse = ", ")
  )
}

TARGET <- TARGET[1]
BASELINE <- BASELINE[1]

MODELS <- intersect(
  c("ARIMA", "KFAS", "RF", "XGBoost", "LSTM"),
  names(M)
)

stopifnot("LSTM" %in% MODELS)

D[, Estacion := as.character(Estacion)]
M[, Estacion := as.character(Estacion)]

D[, Hora := normalize_time(Hora)]
M[, origin_time := normalize_time(origin_time)]

stopifnot(
  D[, .N, by = .(Estacion, Hora)][N > 1L, .N] == 0L
)

setorder(D, Estacion, Hora)

# 72 observed positions must span exactly 71 elapsed hours.
D[, first_observed_72 := shift(Hora, 71L), by = Estacion]

D[, full_72_hours :=
  !is.na(first_observed_72) &
  abs(as.numeric(difftime(
    Hora, first_observed_72, units = "hours"
  )) - 71) < 1e-8
]

H <- D[, .(
  Estacion,
  origin_time = Hora,
  full_72_hours
)]

J <- merge(
  M,
  H,
  by = c("Estacion", "origin_time"),
  all.x = TRUE,
  sort = FALSE
)

if (nrow(J) != nrow(M) || anyNA(J$full_72_hours)) {
  stop("Origin correspondence failed; cannot score sensitivity.")
}

J[, continuity := fifelse(
  full_72_hours,
  "72h_contiguous",
  "72h_not_contiguous"
)]

cat("\n====================================================\n")
cat("STEP 08 — LSTM CONTINUITY SENSITIVITY\n")
cat("====================================================\n")

cat("\nRows:", nrow(J), "\n")
cat("Target:", TARGET, "\n")
cat("Baseline:", BASELINE, "\n")
cat("Comparison models:", paste(MODELS, collapse = ", "), "\n")

score_model <- function(model_name, grouping) {

  X <- J[
    is.finite(get(model_name)) &
    is.finite(get(TARGET)) &
    is.finite(get(BASELINE))
  ]

  S <- X[, {

    error <- get(model_name) - get(TARGET)
    error_base <- get(BASELINE) - get(TARGET)

    rmse <- sqrt(mean(error^2))
    rmse_base <- sqrt(mean(error_base^2))

    .(
      N = .N,
      MAE = mean(abs(error)),
      RMSE = rmse,
      Bias = mean(error),
      MAE_persistence = mean(abs(error_base)),
      RMSE_persistence = rmse_base,
      Skill_RMSE = if (rmse_base > 0) {
        1 - rmse / rmse_base
      } else {
        NA_real_
      }
    )

  }, by = grouping]

  S[, model := model_name]
  S[]
}

GLOBAL <- rbindlist(
  lapply(MODELS, score_model,
         grouping = c("horizon_h", "continuity")),
  fill = TRUE
)

BY_STATION <- rbindlist(
  lapply(MODELS, score_model,
         grouping = c(
           "Zona", "Estacion", "horizon_h", "continuity"
         )),
  fill = TRUE
)

setorder(GLOBAL, horizon_h, continuity, model)
setorder(BY_STATION, Zona, Estacion,
         horizon_h, continuity, model)

cat("\n====================================================\n")
cat("GLOBAL PERFORMANCE BY CLOCK CONTINUITY\n")
cat("====================================================\n\n")

print(
  GLOBAL[, .(
    model, horizon_h, continuity, N,
    RMSE, MAE, RMSE_persistence, Skill_RMSE
  )],
  nrows = Inf
)

cat("\n====================================================\n")
cat("LSTM SENSITIVITY — ALL STATIONS\n")
cat("====================================================\n\n")

print(
  BY_STATION[
    model == "LSTM",
    .(
      Zona, Estacion, horizon_h, continuity,
      N, RMSE, MAE, Skill_RMSE
    )
  ],
  nrows = Inf
)

cat("\n====================================================\n")
cat("CRITICAL STATIONS — 51025090 AND 52055230\n")
cat("====================================================\n\n")

print(
  BY_STATION[
    Estacion %in% c("51025090", "52055230"),
    .(
      model, Estacion, horizon_h, continuity,
      N, RMSE, Skill_RMSE
    )
  ],
  nrows = Inf
)

fwrite(
  GLOBAL,
  file.path(
    OUT,
    "lstm_continuity_performance_global_v1_0.csv"
  )
)

fwrite(
  BY_STATION,
  file.path(
    OUT,
    "lstm_continuity_performance_by_station_v1_0.csv"
  )
)

cat("\n====================================================\n")
cat("STEP 08 COMPLETE — NO MODEL RETRAINING\n")
cat("====================================================\n")

# Commit only this script. Push without force.
setwd(ROOT)

REL <- paste0(
  "03_CODE/08_article02_audit/",
  "08_lstm_continuity_performance_sensitivity.R"
)

staged <- system2(
  "git",
  c("diff", "--cached", "--name-only"),
  stdout = TRUE
)

if (length(staged)) {
  cat("Other staged files exist. Automatic commit skipped.\n")
} else {

  add <- system2(
    "git", c("add", "--", REL),
    stdout = TRUE, stderr = TRUE
  )

  add_status <- attr(add, "status")
  if (is.null(add_status)) add_status <- 0L
  if (add_status != 0L) stop("Git add failed.")

  commit <- system2(
    "git",
    c(
      "commit", "-m",
      shQuote("Audit LSTM performance by observed clock continuity")
    ),
    stdout = TRUE, stderr = TRUE
  )

  commit_status <- attr(commit, "status")
  if (is.null(commit_status)) commit_status <- 0L

  cat(paste(commit, collapse = "\n"), "\n")

  if (commit_status == 0L) {

    push <- system2(
      "git",
      c("push", "origin", "main"),
      stdout = TRUE, stderr = TRUE
    )

    push_status <- attr(push, "status")
    if (is.null(push_status)) push_status <- 0L

    cat("\nGIT PUSH:\n")
    cat(paste(push, collapse = "\n"), "\n")

    if (push_status != 0L) {
      cat("Push not completed. No force-push attempted.\n")
    }
  }
}



suppressPackageStartupMessages(library(data.table))

ROOT <- "C:/Users/UMARIANA/Documents/GitHub/phd-thesis-wind-energy-narino"

FEATURE_FILE <- file.path(
  ROOT, "local_work/06_random_forest/rf_pair_features_v1_0.rds"
)

MASTER_FILE <- file.path(
  ROOT,
  "local_work/10_final_comparison/article02_master_external_predictions_v1_0.rds"
)

OUT_DIR <- file.path(ROOT, "local_work/12_manuscript/audit")
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

stopifnot(file.exists(FEATURE_FILE), file.exists(MASTER_FILE))

F <- as.data.table(readRDS(FEATURE_FILE))
M <- as.data.table(readRDS(MASTER_FILE))

cat("\n============================================================\n")
cat("STEP 05 — PREDICTIONS ON INCOMPLETE FEATURE ROWS\n")
cat("============================================================\n\n")

BASE <- c(
  "WPD_t", "VV_t", "rho_t",
  paste0("WPD_lag_", c(1, 3, 6, 12, 24, 48, 72)),
  paste0("WPD_mean_", c(3, 6, 12, 24)),
  "origin_hour_sin", "origin_hour_cos",
  "origin_doy_sin", "origin_doy_cos",
  "target_hour_sin", "target_hour_cos",
  "target_doy_sin", "target_doy_cos"
)

KEY <- c(
  "Zona", "Estacion", "horizon_h",
  "origin_time", "target_time"
)

stopifnot(
  all(c(KEY, BASE, "split_v11") %in% names(F)),
  all(c(KEY, "RF", "XGBoost") %in% names(M))
)

F <- F[split_v11 == "test"]

normalize_time <- function(x) {
  if (inherits(x, "POSIXct")) {
    return(as.POSIXct(as.numeric(x),
      origin = "1970-01-01", tz = "UTC"))
  }
  if (is.numeric(x)) {
    return(as.POSIXct(x,
      origin = "1970-01-01", tz = "UTC"))
  }
  as.POSIXct(x, tz = "UTC")
}

for (D in list(F, M)) {
  D[, Estacion := as.character(Estacion)]
  D[, Zona := as.integer(Zona)]
  D[, horizon_h := as.integer(horizon_h)]

  D[, origin_time := normalize_time(origin_time)]
  D[, target_time := normalize_time(target_time)]
}

F[, n_na_22 := rowSums(is.na(as.matrix(.SD))),
  .SDcols = BASE
]

F[, has_missing := n_na_22 > 0L]

dup_f <- F[, .N, by = KEY][N > 1L]
dup_m <- M[, .N, by = KEY][N > 1L]

cat("Feature duplicates:", nrow(dup_f), "\n")
cat("Master duplicates:", nrow(dup_m), "\n")

if (nrow(dup_f) || nrow(dup_m)) {
  stop("Duplicate forecast keys; exact join not safe.")
}

F2 <- F[, c(KEY, "n_na_22", "has_missing"), with = FALSE]
F2[, feature_present := TRUE]

M2 <- M[, c(KEY, "RF", "XGBoost"), with = FALSE]
M2[, master_present := TRUE]

J <- merge(
  F2, M2,
  by = KEY,
  all = TRUE,
  sort = FALSE
)

MATCH <- J[
  feature_present == TRUE &
  master_present == TRUE
]

JOIN_AUDIT <- data.table(
  feature_test_rows = nrow(F),
  master_rows = nrow(M),
  joined_rows = nrow(J),
  matched_rows = nrow(MATCH),
  feature_only = J[
    feature_present == TRUE &
    is.na(master_present), .N
  ],
  master_only = J[
    master_present == TRUE &
    is.na(feature_present), .N
  ]
)

cat("\n============================================================\n")
cat("EXACT FORECAST KEY JOIN\n")
cat("============================================================\n\n")
print(JOIN_AUDIT)

if (
  JOIN_AUDIT$feature_only != 0L ||
  JOIN_AUDIT$master_only != 0L
) {
  stop("Incomplete master/feature join. Inspect keys.")
}

AUD <- rbindlist(
  lapply(c("RF", "XGBoost"), function(model_name) {

    ans <- MATCH[, .(
      N = .N,
      N_finite_predictions =
        sum(is.finite(get(model_name))),
      N_nonfinite_predictions =
        sum(!is.finite(get(model_name))),
      pct_finite =
        100 * mean(is.finite(get(model_name)))
    ), by = .(horizon_h, has_missing)]

    ans[, model := model_name]
    ans
  }),
  fill = TRUE
)

setcolorder(
  AUD,
  c(
    "model", "horizon_h", "has_missing",
    "N", "N_finite_predictions",
    "N_nonfinite_predictions", "pct_finite"
  )
)

setorder(AUD, model, horizon_h, has_missing)

cat("\n============================================================\n")
cat("RF/XGBOOST PREDICTION COVERAGE BY MISSINGNESS\n")
cat("============================================================\n\n")
print(AUD, nrows = Inf)

DIAG <- AUD[, .(
  incomplete_rows = sum(N[has_missing]),
  finite_predictions_on_incomplete =
    sum(N_finite_predictions[has_missing]),
  complete_rows = sum(N[!has_missing]),
  finite_predictions_on_complete =
    sum(N_finite_predictions[!has_missing])
), by = model]

DIAG[, interpretation := fifelse(
  finite_predictions_on_incomplete > 0,
  "INCOMPLETE FEATURE ROWS RECEIVED PREDICTIONS",
  "NO PREDICTIONS ON INCOMPLETE FEATURE ROWS"
)]

cat("\n============================================================\n")
cat("MODEL-LEVEL DIAGNOSTIC\n")
cat("============================================================\n\n")
print(DIAG)

fwrite(
  JOIN_AUDIT,
  file.path(OUT_DIR, "tabular_na_exact_join_v1_0.csv")
)

fwrite(
  AUD,
  file.path(OUT_DIR, "tabular_na_prediction_coverage_v1_0.csv")
)

fwrite(
  DIAG,
  file.path(OUT_DIR, "tabular_na_model_diagnostic_v1_0.csv")
)

cat("\n============================================================\n")
cat("STEP 05 COMPLETE — FROZEN MODELS NOT MODIFIED\n")
cat("============================================================\n")

setwd(ROOT)

REL <- "03_CODE/08_article02_audit/05_tabular_na_prediction_coverage.R"

staged <- system2(
  "git",
  c("diff", "--cached", "--name-only"),
  stdout = TRUE
)

if (length(staged) > 0L) {
  cat("\nExisting staged files detected; skipping automatic commit.\n")
} else {

  status <- system2(
    "git",
    c("status", "--porcelain", "--", REL),
    stdout = TRUE
  )

  if (length(status) > 0L) {
    add_out <- system2(
      "git", c("add", "--", REL),
      stdout = TRUE, stderr = TRUE
    )
    add_code <- attr(add_out, "status")
    if (is.null(add_code)) add_code <- 0L

    if (add_code != 0L) {
      stop("Git add failed.")
    }

    commit_out <- system2(
      "git",
      c("commit", "-m",
        shQuote("Audit RF and XGBoost prediction coverage on missing features")),
      stdout = TRUE, stderr = TRUE
    )

    cat(paste(commit_out, collapse = "\n"), "\n")
  }
}


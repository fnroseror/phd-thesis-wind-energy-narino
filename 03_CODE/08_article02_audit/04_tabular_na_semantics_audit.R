# ============================================================
# ARTICLE 2 — TABULAR NA SEMANTICS AUDIT
# STEP 04: RF/XGBoost actual missing-value behavior
# ============================================================

library(data.table)

ROOT <- "C:/Users/UMARIANA/Documents/GitHub/phd-thesis-wind-energy-narino"

FEATURE_FILE <- file.path(
  ROOT,
  "local_work/06_random_forest/rf_pair_features_v1_0.rds"
)

RF_DIR <- file.path(ROOT, "local_work/06_random_forest")
XGB_DIR <- file.path(ROOT, "local_work/07_xgboost")

OUT_DIR <- file.path(
  ROOT,
  "local_work/12_manuscript/audit"
)

dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

stopifnot(file.exists(FEATURE_FILE))

cat("\n============================================================\n")
cat("ARTICLE 2 — RF/XGBOOST NA SEMANTICS AUDIT\n")
cat("============================================================\n\n")

# ============================================================
# 1. Load frozen pair features
# ============================================================

F <- as.data.table(readRDS(FEATURE_FILE))

F[, Estacion := as.character(Estacion)]

BASE <- c(
  "WPD_t", "VV_t", "rho_t",
  "WPD_lag_1", "WPD_lag_3", "WPD_lag_6",
  "WPD_lag_12", "WPD_lag_24", "WPD_lag_48", "WPD_lag_72",
  "WPD_mean_3", "WPD_mean_6", "WPD_mean_12", "WPD_mean_24",
  "origin_hour_sin", "origin_hour_cos",
  "origin_doy_sin", "origin_doy_cos",
  "target_hour_sin", "target_hour_cos",
  "target_doy_sin", "target_doy_cos"
)

stopifnot(all(BASE %in% names(F)))

F[, complete_predictors :=
  complete.cases(.SD),
  .SDcols = BASE
]

cat("Rows:", nrow(F), "\n")
cat("Complete predictor rows:", F[complete_predictors == TRUE, .N], "\n")
cat("Incomplete predictor rows:", F[complete_predictors == FALSE, .N], "\n\n")

# ============================================================
# 2. Find candidate fold-definition artifacts
# ============================================================

SEARCH_ROOTS <- c(
  RF_DIR,
  XGB_DIR,
  file.path(ROOT, "local_work")
)

ALL <- unique(unlist(lapply(
  SEARCH_ROOTS[dir.exists(SEARCH_ROOTS)],
  function(d) list.files(d, recursive = TRUE, full.names = TRUE)
)))

INFO <- file.info(ALL)

CANDIDATE <- ALL[
  !is.na(INFO$size) &
  INFO$size < 20 * 1024^2 &
  tolower(tools::file_ext(ALL)) %in% c("csv", "rds")
]

FOLD_OBJECTS <- list()

for (ff in CANDIDATE) {

  ext <- tolower(tools::file_ext(ff))

  obj <- tryCatch(
    if (ext == "csv") fread(ff) else readRDS(ff),
    error = function(e) NULL
  )

  if (is.null(obj) || is.null(names(obj))) next

  nm <- names(obj)

  score <- sum(
    grepl(
      "fold|train|validation|boundary|origin|target|start|end",
      nm,
      ignore.case = TRUE
    )
  )

  if (score >= 3) {

    rel <- sub(
      paste0("^", normalizePath(ROOT, winslash = "/"), "/?"),
      "",
      normalizePath(ff, winslash = "/", mustWork = FALSE)
    )

    FOLD_OBJECTS[[rel]] <- data.table(
      file = rel,
      rows = ifelse(is.data.frame(obj), nrow(obj), NA_integer_),
      columns = paste(nm, collapse = " | ")
    )
  }
}

FOLD_INV <- if (length(FOLD_OBJECTS)) {
  rbindlist(FOLD_OBJECTS, fill = TRUE)
} else {
  data.table()
}

cat("============================================================\n")
cat("CANDIDATE FOLD / TRAIN-VALIDATION ARTIFACTS\n")
cat("============================================================\n\n")

if (nrow(FOLD_INV)) {
  print(FOLD_INV, nrows = 150)
} else {
  cat("No candidate fold artifacts found.\n")
}

# ============================================================
# 3. Load all RF/XGB checkpoint summaries
# ============================================================

read_checkpoints <- function(dir_path, prefix) {

  ff <- list.files(
    dir_path,
    recursive = TRUE,
    full.names = TRUE,
    pattern = "\\.rds$"
  )

  ans <- list()

  for (f in ff) {

    if (!grepl("checkpoint", f, ignore.case = TRUE)) next

    x <- tryCatch(readRDS(f), error = function(e) NULL)

    if (is.null(x) || !is.data.frame(x)) next

    needed <- c(
      "Zona", "Estacion", "horizon_h", "fold",
      "N_train", "N_validation"
    )

    if (!all(needed %in% names(x))) next

    y <- as.data.table(x)

    y[, model_family := prefix]
    y[, checkpoint_file := basename(f)]

    ans[[length(ans) + 1L]] <- y
  }

  if (!length(ans)) return(data.table())

  rbindlist(ans, fill = TRUE)
}

RF_CP <- read_checkpoints(RF_DIR, "RF")
XGB_CP <- read_checkpoints(XGB_DIR, "XGBoost")

CP <- rbindlist(
  list(RF_CP, XGB_CP),
  fill = TRUE
)

cat("\n============================================================\n")
cat("CHECKPOINT INVENTORY\n")
cat("============================================================\n\n")

cat("RF checkpoint rows:", nrow(RF_CP), "\n")
cat("XGBoost checkpoint rows:", nrow(XGB_CP), "\n")

if (nrow(CP)) {
  cat("Unique station-horizon-fold-model combinations:",
      uniqueN(CP[, .(model_family, Zona, Estacion, horizon_h, fold)]),
      "\n")
}

# ============================================================
# 4. Collapse checkpoint N counts across configurations
# ============================================================

if (nrow(CP)) {

  CP_N <- CP[, .(
    N_train_checkpoint_min = min(N_train),
    N_train_checkpoint_max = max(N_train),
    N_validation_checkpoint_min = min(N_validation),
    N_validation_checkpoint_max = max(N_validation),
    N_configs = uniqueN(config_id)
  ), by = .(
    model_family, Zona, Estacion, horizon_h, fold
  )]

} else {

  CP_N <- data.table()
}

cat("\n============================================================\n")
cat("CHECKPOINT N CONSISTENCY\n")
cat("============================================================\n\n")

if (nrow(CP_N)) {

  CP_N[, train_N_constant :=
    N_train_checkpoint_min == N_train_checkpoint_max
  ]

  CP_N[, validation_N_constant :=
    N_validation_checkpoint_min == N_validation_checkpoint_max
  ]

  print(CP_N)
}

# ============================================================
# 5. Search source/logs ONLY for model-specific NA semantics
# ============================================================

TEXT_FILES <- ALL[
  tolower(tools::file_ext(ALL)) %in%
    c("r", "rmd", "txt", "log", "md")
]

# Also include tracked repository source.
ROOT_TEXT <- list.files(
  file.path(ROOT, "03_CODE"),
  recursive = TRUE,
  full.names = TRUE,
  pattern = "\\.(R|r|Rmd|rmd|txt|log|md)$"
)

TEXT_FILES <- unique(c(TEXT_FILES, ROOT_TEXT))

MODEL_PAT <- paste(
  c(
    "ranger\\s*\\(",
    "randomForest\\s*\\(",
    "xgb\\.train\\s*\\(",
    "xgboost\\s*\\(",
    "xgb\\.DMatrix\\s*\\(",
    "complete\\.cases",
    "na\\.omit",
    "na\\.action",
    "na\\.learn",
    "missing\\s*=",
    "median\\s*\\(",
    "imput",
    "replace.*NA",
    "is\\.na.*<-",
    "scale\\s*\\("
  ),
  collapse = "|"
)

HITS <- list()

for (ff in TEXT_FILES) {

  txt <- tryCatch(
    readLines(ff, warn = FALSE, encoding = "UTF-8"),
    error = function(e) character(0)
  )

  if (!length(txt)) next

  idx <- grep(MODEL_PAT, txt, ignore.case = TRUE)

  if (!length(idx)) next

  rel <- sub(
    paste0("^", normalizePath(ROOT, winslash = "/"), "/?"),
    "",
    normalizePath(ff, winslash = "/", mustWork = FALSE)
  )

  # Keep context around each hit.
  for (i in idx) {

    lo <- max(1L, i - 4L)
    hi <- min(length(txt), i + 6L)

    context <- paste(
      sprintf("%05d | %s", lo:hi, txt[lo:hi]),
      collapse = "\n"
    )

    HITS[[length(HITS) + 1L]] <- data.table(
      file = rel,
      hit_line = i,
      hit = txt[i],
      context = context
    )
  }
}

HITS_DT <- if (length(HITS)) {
  rbindlist(HITS, fill = TRUE)
} else {
  data.table()
}

# Rank Article-2 / model-specific paths first.
if (nrow(HITS_DT)) {

  HITS_DT[, priority := fifelse(
    grepl(
      "06_random_forest|07_xgboost|article02|article_02|random_forest|xgboost",
      file,
      ignore.case = TRUE
    ),
    1L,
    2L
  )]

  setorder(HITS_DT, priority, file, hit_line)
}

cat("\n============================================================\n")
cat("MODEL-SPECIFIC PREPROCESSING CODE / LOG HITS\n")
cat("============================================================\n\n")

if (nrow(HITS_DT)) {

  TOP <- HITS_DT[1:min(.N, 120)]

  for (i in seq_len(nrow(TOP))) {
    cat("\n------------------------------------------------------------\n")
    cat(TOP$file[i], "\n")
    cat("Hit line:", TOP$hit_line[i], "\n")
    cat(TOP$context[i], "\n")
  }

} else {

  cat("No model-specific preprocessing code was located.\n")
}

# ============================================================
# 6. Inspect package missing-value defaults in current R env
#    Descriptive only — not assumed to prove historical behavior.
# ============================================================

PKG <- data.table(
  package = c("ranger", "xgboost"),
  installed = c(
    requireNamespace("ranger", quietly = TRUE),
    requireNamespace("xgboost", quietly = TRUE)
  )
)

PKG[, version := NA_character_]

if (PKG[package == "ranger", installed]) {
  PKG[package == "ranger", version :=
      as.character(packageVersion("ranger"))]
}

if (PKG[package == "xgboost", installed]) {
  PKG[package == "xgboost", version :=
      as.character(packageVersion("xgboost"))]
}

cat("\n============================================================\n")
cat("CURRENT PACKAGE ENVIRONMENT — DESCRIPTIVE ONLY\n")
cat("============================================================\n\n")

print(PKG)

# ============================================================
# 7. Save evidence
# ============================================================

if (nrow(FOLD_INV)) {
  fwrite(
    FOLD_INV,
    file.path(OUT_DIR, "tabular_fold_artifact_inventory_v1_0.csv")
  )
}

if (nrow(CP_N)) {
  fwrite(
    CP_N,
    file.path(OUT_DIR, "tabular_checkpoint_N_audit_v1_0.csv")
  )
}

if (nrow(HITS_DT)) {
  fwrite(
    HITS_DT,
    file.path(OUT_DIR, "tabular_na_semantics_code_hits_v1_0.csv")
  )
}

fwrite(
  PKG,
  file.path(OUT_DIR, "tabular_current_package_versions_v1_0.csv")
)

# ============================================================
# 8. Git traceability
# ============================================================

cat("\n============================================================\n")
cat("GIT TRACEABILITY\n")
cat("============================================================\n\n")

setwd(ROOT)

system2(
  "git",
  c(
    "add",
    "03_CODE/08_article02_audit/04_tabular_na_semantics_audit.R"
  )
)

staged <- system2(
  "git",
  c("diff", "--cached", "--name-only"),
  stdout = TRUE
)

if (length(staged)) {

  out <- system2(
    "git",
    c(
      "commit",
      "-m",
      shQuote("Audit RF/XGBoost missing-value semantics for Article 2")
    ),
    stdout = TRUE,
    stderr = TRUE
  )

  cat(paste(out, collapse = "\n"), "\n")
}

cat("\n============================================================\n")
cat("STEP 04 COMPLETE\n")
cat("============================================================\n")

# ============================================================
# ARTICLE 2 — TABULAR MODEL PREPROCESSING AUDIT
# STEP 03: RF / XGBoost missingness and preprocessing provenance
# ============================================================

library(data.table)

ROOT <- "C:/Users/UMARIANA/Documents/GitHub/phd-thesis-wind-energy-narino"

FEATURE_FILE <- file.path(
  ROOT,
  "local_work/06_random_forest/rf_pair_features_v1_0.rds"
)

RF_DIR <- file.path(
  ROOT,
  "local_work/06_random_forest"
)

XGB_DIR <- file.path(
  ROOT,
  "local_work/07_xgboost"
)

OUT_DIR <- file.path(
  ROOT,
  "local_work/12_manuscript/audit"
)

dir.create(
  OUT_DIR,
  recursive = TRUE,
  showWarnings = FALSE
)

stopifnot(file.exists(FEATURE_FILE))

cat("\n============================================================\n")
cat("ARTICLE 2 — RF / XGBOOST PREPROCESSING AUDIT\n")
cat("============================================================\n\n")

# ------------------------------------------------------------
# 1. Load frozen feature artifact
# ------------------------------------------------------------

F <- as.data.table(readRDS(FEATURE_FILE))

cat("Feature artifact rows:", nrow(F), "\n")
cat("Columns:", ncol(F), "\n\n")

cat("Feature artifact columns:\n")
print(names(F))

# ------------------------------------------------------------
# 2. Expected model predictors
# ------------------------------------------------------------

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

MISSING_COLUMNS <- setdiff(BASE, names(F))

cat("\n============================================================\n")
cat("EXPECTED PREDICTOR AUDIT\n")
cat("============================================================\n\n")

cat("Expected predictors:", length(BASE), "\n")
cat("Missing predictor columns:", length(MISSING_COLUMNS), "\n")

if (length(MISSING_COLUMNS)) print(MISSING_COLUMNS)

# ------------------------------------------------------------
# 3. Missingness by predictor
# ------------------------------------------------------------

AVAILABLE <- intersect(BASE, names(F))

MISS <- data.table(
  feature = AVAILABLE,
  N_missing = vapply(
    AVAILABLE,
    function(v) sum(is.na(F[[v]])),
    integer(1)
  )
)

MISS[, pct_missing := 100 * N_missing / nrow(F)]
setorder(MISS, -N_missing)

cat("\n============================================================\n")
cat("MISSINGNESS BY PREDICTOR\n")
cat("============================================================\n\n")

print(MISS)

# ------------------------------------------------------------
# 4. Missingness burden per row
# ------------------------------------------------------------

if (length(AVAILABLE) > 0L) {

  M <- is.na(as.matrix(F[, ..AVAILABLE]))

  ROWMISS <- rowSums(M)

  ROWMISS_SUMMARY <- data.table(
    n_missing = sort(unique(ROWMISS))
  )

  ROWMISS_SUMMARY[, N := vapply(
    n_missing,
    function(k) sum(ROWMISS == k),
    integer(1)
  )]

  ROWMISS_SUMMARY[, pct := 100 * N / nrow(F)]

} else {

  ROWMISS_SUMMARY <- data.table()
}

cat("\n============================================================\n")
cat("MISSING PREDICTORS PER ROW\n")
cat("============================================================\n\n")

print(ROWMISS_SUMMARY)

# ------------------------------------------------------------
# 5. Explicit missingness-indicator columns
# ------------------------------------------------------------

IND <- names(F)[
  grepl(
    "missing|miss_|_miss|is_na|_na$|indicator",
    names(F),
    ignore.case = TRUE
  )
]

cat("\n============================================================\n")
cat("EXPLICIT MISSINGNESS INDICATORS\n")
cat("============================================================\n\n")

cat("Detected:", length(IND), "\n")
print(IND)

# ------------------------------------------------------------
# 6. Missingness by horizon and split when available
# ------------------------------------------------------------

GROUP_COLS <- intersect(
  c("horizon_h", "split", "split_v11"),
  names(F)
)

if (length(GROUP_COLS) > 0L && length(AVAILABLE) > 0L) {

  TMP <- copy(F)

  TMP[, n_missing_predictors :=
    rowSums(is.na(as.matrix(.SD))),
    .SDcols = AVAILABLE
  ]

  BY_GROUP <- TMP[, .(
    N = .N,
    N_complete = sum(n_missing_predictors == 0L),
    pct_complete = 100 * mean(n_missing_predictors == 0L),
    median_missing = median(n_missing_predictors),
    max_missing = max(n_missing_predictors)
  ), by = GROUP_COLS]

} else {

  BY_GROUP <- data.table()
}

cat("\n============================================================\n")
cat("MISSINGNESS BY HORIZON / SPLIT\n")
cat("============================================================\n\n")

print(BY_GROUP)

# ------------------------------------------------------------
# 7. Inventory RF and XGBoost artifacts
# ------------------------------------------------------------

inventory_dir <- function(dir_path, model_name) {

  if (!dir.exists(dir_path)) {
    return(data.table())
  }

  ff <- list.files(
    dir_path,
    recursive = TRUE,
    full.names = TRUE
  )

  if (!length(ff)) return(data.table())

  info <- file.info(ff)

  data.table(
    model = model_name,
    path = gsub(
      "\\\\",
      "/",
      sub(
        paste0("^", normalizePath(ROOT, winslash = "/"), "/?"),
        "",
        normalizePath(ff, winslash = "/", mustWork = FALSE)
      )
    ),
    ext = tolower(tools::file_ext(ff)),
    size_MB = round(info$size / 1024^2, 4)
  )
}

INV <- rbindlist(
  list(
    inventory_dir(RF_DIR, "RF"),
    inventory_dir(XGB_DIR, "XGBoost")
  ),
  fill = TRUE
)

cat("\n============================================================\n")
cat("RF / XGBOOST ARTIFACT INVENTORY\n")
cat("============================================================\n\n")

cat("Files found:", nrow(INV), "\n")

if (nrow(INV)) {

  KEY_INV <- INV[
    grepl(
      "imput|median|missing|preprocess|transform|feature|train|validation|config|selection|audit",
      path,
      ignore.case = TRUE
    )
  ]

  print(KEY_INV)

} else {

  KEY_INV <- data.table()
}

# ------------------------------------------------------------
# 8. Search R source for actual NA handling
# ------------------------------------------------------------

SEARCH_DIRS <- unique(c(
  file.path(ROOT, "03_CODE"),
  RF_DIR,
  XGB_DIR
))

CODE <- unique(unlist(lapply(
  SEARCH_DIRS[dir.exists(SEARCH_DIRS)],
  function(d) {
    list.files(
      d,
      recursive = TRUE,
      full.names = TRUE,
      pattern = "\\.(R|r)$"
    )
  }
)))

PATTERN <- paste(
  c(
    "na\\.omit",
    "complete\\.cases",
    "is\\.na",
    "median\\(",
    "imput",
    "missing",
    "na\\.action",
    "ranger\\(",
    "xgb\\.DMatrix",
    "xgboost\\(",
    "scale\\(",
    "center"
  ),
  collapse = "|"
)

CODE_HITS <- list()

for (ff in CODE) {

  txt <- tryCatch(
    readLines(ff, warn = FALSE, encoding = "UTF-8"),
    error = function(e) character(0)
  )

  idx <- grep(PATTERN, txt, ignore.case = TRUE)

  if (!length(idx)) next

  rel <- sub(
    paste0("^", normalizePath(ROOT, winslash = "/"), "/?"),
    "",
    normalizePath(ff, winslash = "/", mustWork = FALSE)
  )

  CODE_HITS[[rel]] <- data.table(
    file = rel,
    line = idx,
    text = txt[idx]
  )
}

CODE_HITS_DT <- if (length(CODE_HITS)) {
  rbindlist(CODE_HITS, fill = TRUE)
} else {
  data.table()
}

cat("\n============================================================\n")
cat("NA / IMPUTATION / MODEL CODE HITS\n")
cat("============================================================\n\n")

if (nrow(CODE_HITS_DT)) {
  print(CODE_HITS_DT, nrows = 300)
} else {
  cat("No relevant source-code hits detected.\n")
}

# ------------------------------------------------------------
# 9. Inspect small CSV/RDS metadata objects for preprocessing
# ------------------------------------------------------------

SMALL_FILES <- character(0)

if (nrow(INV)) {

  FULL_PATH <- file.path(ROOT, INV$path)

  ok <- file.exists(FULL_PATH)

  FULL_PATH <- FULL_PATH[ok]
  INV2 <- INV[ok]

  SMALL_FILES <- FULL_PATH[
    INV2$size_MB < 10 &
    INV2$ext %in% c("csv", "rds")
  ]
}

FIELD_HITS <- list()

for (ff in SMALL_FILES) {

  ext <- tolower(tools::file_ext(ff))

  obj <- tryCatch(
    if (ext == "csv") fread(ff) else readRDS(ff),
    error = function(e) NULL
  )

  if (is.null(obj)) next

  nm <- names(obj)

  if (is.null(nm)) next

  hit <- nm[
    grepl(
      "median|imput|missing|na_|_na|scale|center|train|validation|preprocess",
      nm,
      ignore.case = TRUE
    )
  ]

  if (!length(hit)) next

  rel <- sub(
    paste0("^", normalizePath(ROOT, winslash = "/"), "/?"),
    "",
    normalizePath(ff, winslash = "/", mustWork = FALSE)
  )

  FIELD_HITS[[rel]] <- data.table(
    file = rel,
    field = hit
  )
}

FIELD_HITS_DT <- if (length(FIELD_HITS)) {
  rbindlist(FIELD_HITS, fill = TRUE)
} else {
  data.table()
}

cat("\n============================================================\n")
cat("PREPROCESSING FIELDS IN MODEL ARTIFACTS\n")
cat("============================================================\n\n")

if (nrow(FIELD_HITS_DT)) {
  print(FIELD_HITS_DT, nrows = 300)
} else {
  cat("No explicit preprocessing fields detected.\n")
}

# ------------------------------------------------------------
# 10. Representative checkpoint structures
# ------------------------------------------------------------

inspect_representative <- function(dir_path, label) {

  if (!dir.exists(dir_path)) {
    cat(label, ": directory not found.\n")
    return(invisible(NULL))
  }

  ff <- list.files(
    dir_path,
    recursive = TRUE,
    full.names = TRUE,
    pattern = "\\.rds$"
  )

  if (!length(ff)) {
    cat(label, ": no RDS objects found.\n")
    return(invisible(NULL))
  }

  sizes <- file.info(ff)$size
  ff <- ff[order(sizes)]

  # First readable object below 50 MB
  chosen <- NULL
  obj <- NULL

  for (candidate in ff[sizes[order(sizes)] < 50 * 1024^2]) {

    tmp <- tryCatch(
      readRDS(candidate),
      error = function(e) NULL
    )

    if (!is.null(tmp)) {
      chosen <- candidate
      obj <- tmp
      break
    }
  }

  if (is.null(chosen)) {
    cat(label, ": no suitable representative RDS found.\n")
    return(invisible(NULL))
  }

  cat("\n", label, " representative object:\n", sep = "")
  cat(
    sub(
      paste0("^", normalizePath(ROOT, winslash = "/"), "/?"),
      "",
      normalizePath(chosen, winslash = "/", mustWork = FALSE)
    ),
    "\n"
  )

  cat("Class:\n")
  print(class(obj))

  cat("Names:\n")
  print(names(obj))

  cat("Structure:\n")
  str(obj, max.level = 2, give.attr = FALSE)
}

cat("\n============================================================\n")
cat("REPRESENTATIVE MODEL OBJECTS\n")
cat("============================================================\n")

inspect_representative(RF_DIR, "RF")
inspect_representative(XGB_DIR, "XGBoost")

# ------------------------------------------------------------
# 11. Save audit tables
# ------------------------------------------------------------

fwrite(
  MISS,
  file.path(
    OUT_DIR,
    "tabular_predictor_missingness_v1_0.csv"
  )
)

if (nrow(ROWMISS_SUMMARY)) {
  fwrite(
    ROWMISS_SUMMARY,
    file.path(
      OUT_DIR,
      "tabular_row_missingness_distribution_v1_0.csv"
    )
  )
}

if (nrow(BY_GROUP)) {
  fwrite(
    BY_GROUP,
    file.path(
      OUT_DIR,
      "tabular_missingness_by_horizon_split_v1_0.csv"
    )
  )
}

if (nrow(INV)) {
  fwrite(
    INV,
    file.path(
      OUT_DIR,
      "rf_xgb_artifact_inventory_v1_0.csv"
    )
  )
}

if (nrow(CODE_HITS_DT)) {
  fwrite(
    CODE_HITS_DT,
    file.path(
      OUT_DIR,
      "rf_xgb_preprocessing_code_hits_v1_0.csv"
    )
  )
}

if (nrow(FIELD_HITS_DT)) {
  fwrite(
    FIELD_HITS_DT,
    file.path(
      OUT_DIR,
      "rf_xgb_preprocessing_field_hits_v1_0.csv"
    )
  )
}

# ------------------------------------------------------------
# 12. Git traceability
# ------------------------------------------------------------

cat("\n============================================================\n")
cat("GIT TRACEABILITY\n")
cat("============================================================\n\n")

setwd(ROOT)

git_files <- c(
  "03_CODE/08_article02_audit/02_cross_article_density_sensitivity.R",
  "03_CODE/08_article02_audit/03_tabular_preprocessing_audit.R"
)

git_files <- git_files[file.exists(file.path(ROOT, git_files))]

if (length(git_files)) {

  system2(
    "git",
    c("add", git_files),
    stdout = TRUE,
    stderr = TRUE
  )

  staged <- system2(
    "git",
    c("diff", "--cached", "--name-only"),
    stdout = TRUE,
    stderr = TRUE
  )

  if (length(staged)) {

    out <- system2(
      "git",
      c(
        "commit",
        "-m",
        shQuote(
          "Audit Article 2 WPD compatibility and tabular preprocessing"
        )
      ),
      stdout = TRUE,
      stderr = TRUE
    )

    cat(paste(out, collapse = "\n"), "\n")

  } else {

    cat("No new audit-script changes to commit.\n")
  }
}

cat("\n============================================================\n")
cat("STEP 03 COMPLETE\n")
cat("============================================================\n")


suppressPackageStartupMessages(library(data.table))

ROOT <- "C:/Users/UMARIANA/Documents/GitHub/phd-thesis-wind-energy-narino"

DATA_FILE <- file.path(
  ROOT,
  "local_work/02_article02_dataset/article02_analytical_dataset_v1_0.rds"
)

MASTER_FILE <- file.path(
  ROOT,
  "local_work/10_final_comparison/article02_master_external_predictions_v1_0.rds"
)

OUT <- file.path(ROOT, "local_work/12_manuscript/audit")
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

stopifnot(file.exists(DATA_FILE), file.exists(MASTER_FILE))

D <- as.data.table(readRDS(DATA_FILE))
M <- as.data.table(readRDS(MASTER_FILE))

stopifnot(
  all(c("Estacion", "Hora") %in% names(D)),
  all(c("Zona", "Estacion", "horizon_h",
        "origin_time", "LSTM") %in% names(M))
)

normalize_time <- function(x) {
  if (inherits(x, "POSIXct") || is.numeric(x)) {
    return(as.POSIXct(
      as.numeric(x),
      origin = "1970-01-01",
      tz = "UTC"
    ))
  }
  as.POSIXct(x, tz = "UTC")
}

D[, Estacion := as.character(Estacion)]
M[, Estacion := as.character(Estacion)]

D[, Hora := normalize_time(Hora)]
M[, origin_time := normalize_time(origin_time)]

cat("\n============================================\n")
cat("STEP 06 — LSTM CLOCK-HOUR AUDIT\n")
cat("============================================\n\n")

# Check unique station-hour observations
dup <- D[, .N, by = .(Estacion, Hora)][N > 1L]

cat("Duplicate station-hours:", nrow(dup), "\n")
if (nrow(dup)) stop("Station-hour duplicates detected.")

# Hypothetical 72-position window, including origin:
# positions t-71 through t.
setorder(D, Estacion, Hora)

D[, start_observation_72 := shift(Hora, 71L),
  by = Estacion
]

D[, span_72_obs_hours := as.numeric(
  difftime(Hora, start_observation_72, units = "hours")
)]

D[, full_72_clock_hours :=
  is.finite(span_72_obs_hours) &
  abs(span_72_obs_hours - 71) < 1e-8
]

H <- D[, .(
  Estacion,
  origin_time = Hora,
  span_72_obs_hours,
  full_72_clock_hours
)]

J <- merge(
  M[, .(Zona, Estacion, horizon_h, origin_time, LSTM)],
  H,
  by = c("Estacion", "origin_time"),
  all.x = TRUE,
  sort = FALSE
)

J[, origin_found := !is.na(full_72_clock_hours)]
J[, finite_prediction := is.finite(LSTM)]

cat("\n--------------------------------------------\n")
cat("ORIGIN JOIN\n")
cat("--------------------------------------------\n")

cat("External prediction rows:", nrow(M), "\n")
cat("Matched station-hour origins:",
    J[origin_found == TRUE, .N], "\n")
cat("Unmatched origins:",
    J[origin_found == FALSE, .N], "\n")

SUMMARY <- J[, .(
  N = .N,
  N_origin_found = sum(origin_found),
  N_full_72_clock_hours = sum(
    full_72_clock_hours %in% TRUE
  ),
  N_lstm_finite = sum(finite_prediction),
  N_prediction_without_full_72_hours = sum(
    finite_prediction &
    !(full_72_clock_hours %in% TRUE)
  ),
  pct_full_72_among_matched = if (
    sum(origin_found) > 0
  ) {
    100 * sum(full_72_clock_hours %in% TRUE) /
      sum(origin_found)
  } else NA_real_
), by = horizon_h][order(horizon_h)]

cat("\n--------------------------------------------\n")
cat("72-HOUR CLOCK CONTINUITY BY HORIZON\n")
cat("--------------------------------------------\n")
print(SUMMARY)

BY_STATION <- J[, .(
  N = .N,
  N_lstm_finite = sum(finite_prediction),
  N_prediction_without_full_72_hours = sum(
    finite_prediction &
    !(full_72_clock_hours %in% TRUE)
  ),
  pct_full_72 = 100 * mean(
    full_72_clock_hours %in% TRUE
  )
), by = .(Zona, Estacion, horizon_h)]

setorder(BY_STATION, Zona, Estacion, horizon_h)

cat("\n--------------------------------------------\n")
cat("72-HOUR CLOCK CONTINUITY BY STATION\n")
cat("--------------------------------------------\n")
print(BY_STATION, nrows = Inf)

EXAMPLES <- J[
  finite_prediction &
  origin_found &
  !(full_72_clock_hours %in% TRUE),
  .(
    Zona, Estacion, horizon_h,
    origin_time, span_72_obs_hours
  )
][1:min(.N, 15L)]

cat("\n--------------------------------------------\n")
cat("EXAMPLES OF NONCONSECUTIVE WINDOWS\n")
cat("--------------------------------------------\n")
print(EXAMPLES)

# Discover current LSTM training scripts and artifacts.
LOCAL_ROOT <- file.path(ROOT, "local_work")

LOCAL_CODE <- if (dir.exists(LOCAL_ROOT)) {
  list.files(
    LOCAL_ROOT,
    pattern = "\\.(R|r|Rmd|rmd)$",
    recursive = TRUE,
    full.names = TRUE
  )
} else character(0)

LOCAL_CODE <- LOCAL_CODE[
  grepl(
    "lstm|deep_learning|sequence",
    LOCAL_CODE,
    ignore.case = TRUE
  )
]

HISTORICAL <- file.path(
  ROOT,
  "03_CODE/05_deep_learning/01_cap3_dl_pipeline.R"
)

SOURCES <- unique(c(
  LOCAL_CODE,
  HISTORICAL[file.exists(HISTORICAL)]
))

SOURCE_AUDIT <- rbindlist(
  lapply(SOURCES, function(f) {
    x <- readLines(f, warn = FALSE)
    i <- grep(
      "make_windows|lookback|sequence|seq_len|shift\\(|origin_time|hour|gap|padding|mask",
      x,
      ignore.case = TRUE
    )
    if (!length(i)) return(NULL)
    data.table(
      file = substring(
        normalizePath(f, winslash = "/"),
        nchar(normalizePath(ROOT, winslash = "/")) + 2L
      ),
      line = i,
      code = x[i]
    )
  }),
  fill = TRUE
)

cat("\n--------------------------------------------\n")
cat("LSTM SOURCE PROVENANCE\n")
cat("--------------------------------------------\n")
cat("Current local LSTM source candidates:",
    length(LOCAL_CODE), "\n")
cat("Historical source is not proof of current implementation.\n")

if (nrow(SOURCE_AUDIT)) {
  print(head(SOURCE_AUDIT, 50L), nrows = 50)
} else {
  cat("No LSTM source-code matches found.\n")
}

# Local audit evidence
fwrite(
  SUMMARY,
  file.path(OUT, "lstm_72_clock_continuity_by_horizon_v1_0.csv")
)
fwrite(
  BY_STATION,
  file.path(OUT, "lstm_72_clock_continuity_by_station_v1_0.csv")
)
fwrite(
  EXAMPLES,
  file.path(OUT, "lstm_nonconsecutive_window_examples_v1_0.csv")
)
if (nrow(SOURCE_AUDIT)) {
  fwrite(
    SOURCE_AUDIT,
    file.path(OUT, "lstm_sequence_source_provenance_v1_0.csv")
  )
}

cat("\nSTEP 06 DIAGNOSTIC COMPLETE.\n")
cat("This does not independently verify the actual LSTM constructor.\n")

# Commit only this source file; never stage local_work.
setwd(ROOT)
REL <- "03_CODE/08_article02_audit/06_lstm_clock_hour_audit.R"

staged <- system2(
  "git", c("diff", "--cached", "--name-only"),
  stdout = TRUE
)

if (!length(staged)) {
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
      shQuote("Audit LSTM clock-hour sequence continuity")
    ),
    stdout = TRUE, stderr = TRUE
  )
  cat(paste(commit, collapse = "\n"), "\n")
} else {
  cat("Existing staged files detected; automatic commit skipped.\n")
}


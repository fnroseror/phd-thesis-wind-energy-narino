# ============================================================
# ENERGY REPORTS — REVISION R1
# R1_08_V2_core_LOSO_gap_audit_v2.R
#
# Manuscript: EGYR-D-26-02665
#
# Purpose:
# Final audit before freezing the revised analytical dataset (V2).
#
# The V2 architecture is:
#   raw VV -> station-hour mean -> QC 0 <= VV <= 20 m/s
#   -> station-hour WPD = 0.5 * rho_zone-hour * VV^3
#   -> equal-station mean within each zone-hour.
#
# This script:
#   1) reconstructs V2 from restricted raw IDEAM data;
#   2) validates the V2 zone-hour series against the R1-07
#      Architecture-C candidate;
#   3) quantifies station composition by zone-hour;
#   4) performs leave-one-station-out (LOSO) sensitivity under V2;
#   5) quantifies daily temporal coverage and missing-gap structure
#      (including maximum gap, requested by Reviewer 2);
#   6) saves the canonical V2 dataset only in the R1 workspace.
#
# IMPORTANT:
# - Raw IDEAM data remain local and are NOT copied to the repo.
# - Original/V1 outputs are NOT overwritten.
# - The V2 dataset is derived and saved only under 09_revision_R1.
# ============================================================

rm(list = ls())
gc()

# ============================================================
# 1. Packages
# ============================================================

required_packages <- c(
  "data.table",
  "stringr",
  "lubridate",
  "openxlsx"
)

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}

invisible(lapply(required_packages, install_if_missing))

suppressPackageStartupMessages({
  library(data.table)
  library(stringr)
  library(lubridate)
  library(openxlsx)
})

# ============================================================
# 2. Paths
# ============================================================

SOURCE_ROOT <- paste0(
  "E:/Academia/UNAL/DOCTORADO/",
  "Fase 2/Productos/Articulo 1/Proceso"
)

RAW_FILE <- file.path(
  SOURCE_ROOT,
  "Datos.txt"
)

SOURCE_DATA_DIR <- file.path(
  SOURCE_ROOT,
  "01_data_processed"
)

CANDIDATE_FILE <- file.path(
  SOURCE_DATA_DIR,
  "01D_final_wpd_candidate_dataset_corrected_datetime.rds"
)

MAIN_FILE <- file.path(
  SOURCE_DATA_DIR,
  "02E_article_main_wpd_dataset_after_qc.rds"
)

REPO_ROOT <- paste0(
  "C:/Users/UMARIANA/Documents/GitHub/",
  "phd-thesis-wind-energy-narino"
)

ARTICLE_REPO <- file.path(
  REPO_ROOT,
  "06_PRODUCTS",
  "01_articles",
  "article_01_energy_reports"
)

R1_ROOT <- file.path(
  ARTICLE_REPO,
  "09_revision_R1"
)

DIR_TABLES <- file.path(R1_ROOT, "02_tables")
DIR_RESULTS <- file.path(R1_ROOT, "04_results")
DIR_LOGS <- file.path(R1_ROOT, "06_logs")

R1_07_C_FILE <- file.path(
  DIR_RESULTS,
  "R1_07_candidate_architecture_C.rds"
)

invisible(lapply(
  c(DIR_TABLES, DIR_RESULTS, DIR_LOGS),
  dir.create,
  recursive = TRUE,
  showWarnings = FALSE
))

required_files <- c(
  RAW_FILE,
  CANDIDATE_FILE,
  MAIN_FILE,
  R1_07_C_FILE
)

missing_files <- required_files[!file.exists(required_files)]

if (length(missing_files) > 0L) {
  stop(
    "Missing required file(s):\n",
    paste(missing_files, collapse = "\n")
  )
}

# ============================================================
# 3. Logging
# ============================================================

LOG_FILE <- file.path(
  DIR_LOGS,
  "R1_08_V2_core_LOSO_gap_audit_log.txt"
)

SUMMARY_FILE <- file.path(
  DIR_RESULTS,
  "R1_08_UPLOAD_THIS_TO_CHAT.txt"
)

SESSION_FILE <- file.path(
  DIR_RESULTS,
  "R1_08_sessionInfo.txt"
)

if (file.exists(LOG_FILE)) file.remove(LOG_FILE)
if (file.exists(SUMMARY_FILE)) file.remove(SUMMARY_FILE)

log_msg <- function(...) {
  msg <- paste0(
    format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    " | ",
    paste(..., collapse = " ")
  )
  cat(msg, "\n")
  cat(msg, "\n", file = LOG_FILE, append = TRUE)
}

log_msg("Starting R1-08 V2 core / LOSO / gap audit.")

# ============================================================
# 4. Load frozen V1, candidate support, and R1-07 Architecture C
# ============================================================

candidate <- as.data.table(readRDS(CANDIDATE_FILE))
main <- as.data.table(readRDS(MAIN_FILE))
arch_C_reference <- as.data.table(readRDS(R1_07_C_FILE))

candidate[, zone := as.character(zone)]
main[, zone := as.character(zone)]
arch_C_reference[, zone := as.character(zone)]

v1_checksum <- main[, .(
  n = .N,
  mean_VV = mean(VV),
  mean_WPD = mean(WPD)
), by = zone][order(zone)]

expected <- data.table(
  zone = c("1", "2", "3", "4"),
  n_expected = c(42706L, 43618L, 42416L, 8744L),
  mean_WPD_expected = c(
    140.75903,
    15.81935,
    12.96353,
    16.94948
  )
)

v1_checksum <- merge(
  v1_checksum,
  expected,
  by = "zone",
  all.x = TRUE
)

v1_checksum[, `:=`(
  n_match = n == n_expected,
  WPD_abs_difference = abs(mean_WPD - mean_WPD_expected)
)]

if (!all(v1_checksum$n_match) ||
    any(v1_checksum$WPD_abs_difference > 1e-4)) {
  stop("V1 checksum FAILED.")
}

rho_key <- unique(
  candidate[, .(
    zone,
    datetime,
    date,
    rho_used
  )]
)

if (rho_key[, anyDuplicated(paste(zone, datetime))] > 0L) {
  stop("rho_key is not unique by zone + datetime.")
}

candidate_support <- unique(
  rho_key[, .(
    zone,
    datetime
  )]
)

log_msg("V1 checksum PASSED.")

# ============================================================
# 5. Read raw VV
# ============================================================

log_msg("Reading restricted raw IDEAM source.")

raw <- tryCatch(
  fread(
    RAW_FILE,
    encoding = "UTF-8",
    na.strings = c("", "NA", "NaN", "NULL", "null", "-", "N/A"),
    showProgress = TRUE
  ),
  error = function(e) {
    fread(
      RAW_FILE,
      encoding = "Latin-1",
      na.strings = c("", "NA", "NaN", "NULL", "null", "-", "N/A"),
      showProgress = TRUE
    )
  }
)

required_cols <- c(
  "Estación",
  "FechaYHora",
  "Valor",
  "Zona",
  "Variable"
)

miss <- setdiff(required_cols, names(raw))
if (length(miss) > 0L) {
  stop(
    "Missing raw columns: ",
    paste(miss, collapse = ", ")
  )
}

vv <- raw[
  toupper(trimws(as.character(Variable))) == "VV",
  .(
    station = as.character(`Estación`),
    raw_datetime = as.character(FechaYHora),
    value = suppressWarnings(as.numeric(Valor)),
    zone = as.character(Zona)
  )
]

rm(raw)
gc()

vv <- vv[
  zone %in% c("1", "2", "3", "4") &
    is.finite(value)
]

# ============================================================
# 6. Robust DMY datetime parser
# ============================================================

manual_parse_dmy <- function(x, tz = "America/Bogota") {

  x <- as.character(x)
  x <- stringr::str_squish(x)
  x <- stringr::str_replace_all(x, "T", " ")

  date_part <- sub("\\s+.*$", "", x)

  time_part <- ifelse(
    grepl("\\s+", x),
    sub("^\\S+\\s+", "", x),
    "00:00:00"
  )

  date_part <- gsub("[-.]", "/", date_part)

  parts <- data.table::tstrsplit(
    date_part,
    "/",
    fixed = TRUE,
    fill = NA
  )

  dd <- suppressWarnings(as.integer(parts[[1L]]))
  mm <- suppressWarnings(as.integer(parts[[2L]]))
  yy <- suppressWarnings(as.integer(parts[[3L]]))

  yy <- ifelse(!is.na(yy) & yy < 100, 2000 + yy, yy)

  time_part <- gsub("\\..*$", "", time_part)

  tparts <- data.table::tstrsplit(
    time_part,
    ":",
    fixed = TRUE,
    fill = "0"
  )

  HH <- if (length(tparts) >= 1L) {
    suppressWarnings(as.integer(tparts[[1L]]))
  } else {
    rep(0L, length(time_part))
  }

  MM <- if (length(tparts) >= 2L) {
    suppressWarnings(as.integer(tparts[[2L]]))
  } else {
    rep(0L, length(time_part))
  }

  SS <- if (length(tparts) >= 3L) {
    suppressWarnings(as.integer(tparts[[3L]]))
  } else {
    rep(0L, length(time_part))
  }

  HH[is.na(HH)] <- 0L
  MM[is.na(MM)] <- 0L
  SS[is.na(SS)] <- 0L

  valid <-
    !is.na(yy) &
    !is.na(mm) &
    !is.na(dd) &
    yy >= 1900 &
    yy <= 2100 &
    mm >= 1 &
    mm <= 12 &
    dd >= 1 &
    dd <= 31 &
    HH >= 0 &
    HH <= 23 &
    MM >= 0 &
    MM <= 59 &
    SS >= 0 &
    SS <= 59

  out <- rep(
    as.POSIXct(NA, tz = tz),
    length(x)
  )

  iso <- sprintf(
    "%04d-%02d-%02d %02d:%02d:%02d",
    yy,
    mm,
    dd,
    HH,
    MM,
    SS
  )

  out[valid] <- suppressWarnings(
    as.POSIXct(
      iso[valid],
      format = "%Y-%m-%d %H:%M:%S",
      tz = tz
    )
  )

  out
}

vv[, datetime := manual_parse_dmy(raw_datetime)]

study_start <- as.POSIXct(
  "2017-01-01 00:00:00",
  tz = "America/Bogota"
)

study_end <- as.POSIXct(
  "2023-01-01 00:00:00",
  tz = "America/Bogota"
)

vv <- vv[
  !is.na(datetime) &
    datetime >= study_start &
    datetime < study_end
]

vv[, datetime := lubridate::floor_date(datetime, unit = "hour")]

# ============================================================
# 7. Station-hour -> candidate support -> QC20
# ============================================================

station_hour <- vv[, .(
  VV_station_hour = mean(value, na.rm = TRUE),
  n_raw_records = .N
), by = .(
  zone,
  station,
  datetime
)]

rm(vv)
gc()

station_hour <- merge(
  station_hour,
  candidate_support,
  by = c("zone", "datetime"),
  all = FALSE
)

station_hour_qc <- station_hour[
  is.finite(VV_station_hour) &
    VV_station_hour >= 0 &
    VV_station_hour <= 20
]

qc_retention <- station_hour[, .(
  n_before = .N,
  n_after = sum(
    is.finite(VV_station_hour) &
      VV_station_hour >= 0 &
      VV_station_hour <= 20
  ),
  pct_after = 100 * mean(
    is.finite(VV_station_hour) &
      VV_station_hour >= 0 &
      VV_station_hour <= 20
  )
), by = .(
  zone,
  station
)]

# ============================================================
# 8. Join same frozen V1 zone-hour rho and calculate local WPD
# ============================================================

sh <- merge(
  station_hour_qc,
  rho_key,
  by = c("zone", "datetime"),
  all.x = TRUE
)

rho_audit <- sh[, .(
  n_station_hours = .N,
  n_with_rho = sum(is.finite(rho_used)),
  pct_with_rho = 100 * mean(is.finite(rho_used))
), by = zone][order(zone)]

if (any(rho_audit$pct_with_rho < 99.999)) {
  stop("Unexpected rho mismatch after candidate-support restriction.")
}

sh <- sh[is.finite(rho_used)]

sh[, WPD_station_hour := 0.5 * rho_used * VV_station_hour^3]

# ============================================================
# 9. Canonical V2 zone-hour dataset: Architecture C
# ============================================================

v2 <- sh[, .(
  VV = mean(VV_station_hour),
  WPD = mean(WPD_station_hour),
  rho_used = unique(rho_used)[1L],
  n_stations = uniqueN(station),
  stations_present = paste(
    sort(unique(station)),
    collapse = ";"
  )
), by = .(
  zone,
  datetime
)]

v2[, date := as.Date(datetime, tz = "America/Bogota")]

setcolorder(
  v2,
  c(
    "zone",
    "datetime",
    "date",
    "VV",
    "WPD",
    "rho_used",
    "n_stations",
    "stations_present"
  )
)

setorder(v2, zone, datetime)

# ============================================================
# 10. Exact validation against R1-07 Architecture C
# ============================================================

ref <- arch_C_reference[, .(
  zone,
  datetime,
  VV_ref = VV,
  WPD_ref = WPD,
  rho_ref = rho_used,
  n_stations_ref = n_stations
)]

validation <- merge(
  ref,
  v2[, .(
    zone,
    datetime,
    VV_v2 = VV,
    WPD_v2 = WPD,
    rho_v2 = rho_used,
    n_stations_v2 = n_stations
  )],
  by = c("zone", "datetime"),
  all = TRUE
)

validation_summary <- validation[, .(
  reference_rows = sum(is.finite(WPD_ref)),
  v2_rows = sum(is.finite(WPD_v2)),
  matched_rows = sum(
    is.finite(WPD_ref) &
      is.finite(WPD_v2)
  ),
  max_abs_VV_difference = max(
    abs(VV_ref - VV_v2),
    na.rm = TRUE
  ),
  max_abs_WPD_difference = max(
    abs(WPD_ref - WPD_v2),
    na.rm = TRUE
  ),
  max_abs_rho_difference = max(
    abs(rho_ref - rho_v2),
    na.rm = TRUE
  ),
  station_count_match = all(
    n_stations_ref == n_stations_v2,
    na.rm = TRUE
  )
)]

if (
  validation_summary$reference_rows != validation_summary$v2_rows ||
  validation_summary$matched_rows != validation_summary$reference_rows ||
  validation_summary$max_abs_VV_difference > 1e-10 ||
  validation_summary$max_abs_WPD_difference > 1e-8 ||
  validation_summary$max_abs_rho_difference > 1e-12 ||
  !validation_summary$station_count_match
) {
  stop("V2 reconstruction does not exactly reproduce R1-07 Architecture C.")
}

log_msg("V2 exactly reproduces R1-07 Architecture C.")

# ============================================================
# 11. V2 descriptive summary
# ============================================================

v2_summary <- v2[, .(
  n_zone_hours = .N,
  mean_VV = mean(VV),
  median_VV = median(VV),
  sd_VV = sd(VV),
  p05_VV = quantile(VV, 0.05, names = FALSE),
  p95_VV = quantile(VV, 0.95, names = FALSE),
  p99_VV = quantile(VV, 0.99, names = FALSE),
  max_VV = max(VV),
  mean_WPD = mean(WPD),
  median_WPD = median(WPD),
  sd_WPD = sd(WPD),
  p05_WPD = quantile(WPD, 0.05, names = FALSE),
  p95_WPD = quantile(WPD, 0.95, names = FALSE),
  p99_WPD = quantile(WPD, 0.99, names = FALSE),
  max_WPD = max(WPD),
  median_n_stations = as.numeric(median(n_stations)),
  min_n_stations = as.numeric(min(n_stations)),
  max_n_stations = as.numeric(max(n_stations))
), by = zone][order(zone)]

# ============================================================
# 12. Station-composition audit
# ============================================================

composition_by_zone <- v2[, .(
  n_zone_hours = .N,
  pct_one_station = 100 * mean(n_stations == 1L),
  pct_two_or_more = 100 * mean(n_stations >= 2L),
  pct_three_or_more = 100 * mean(n_stations >= 3L),
  median_n_stations = as.numeric(median(n_stations)),
  mean_n_stations = mean(n_stations),
  min_n_stations = as.numeric(min(n_stations)),
  max_n_stations = as.numeric(max(n_stations))
), by = zone][order(zone)]

composition_distribution <- v2[, .N, by = .(
  zone,
  n_stations
)][
  ,
  pct_zone_hours := 100 * N / sum(N),
  by = zone
][order(zone, n_stations)]

# ============================================================
# 13. V2 LOSO sensitivity
#
# Remove one station from the already-QC'd station-hour dataset.
# Recompute equal-station mean VV and mean station-hour WPD.
# Compare only on the resulting available zone-hour series.
# ============================================================

stations <- unique(
  sh[, .(
    zone,
    station
  )]
)

setorder(stations, zone, station)

loso_list <- vector(
  "list",
  nrow(stations)
)

for (i in seq_len(nrow(stations))) {

  z <- stations$zone[i]
  s <- stations$station[i]

  base_z <- v2[zone == z]

  reduced <- sh[
    zone == z &
      station != s,
    .(
      VV_loso = mean(VV_station_hour),
      WPD_loso = mean(WPD_station_hour),
      n_stations_loso = uniqueN(station)
    ),
    by = datetime
  ]

  loso_list[[i]] <- data.table(
    zone = z,
    removed_station = s,
    baseline_zone_hours = nrow(base_z),
    loso_zone_hours = nrow(reduced),
    pct_baseline_hours_retained =
      100 * nrow(reduced) / nrow(base_z),
    baseline_mean_VV = mean(base_z$VV),
    mean_VV_loso = if (nrow(reduced) > 0L) {
      mean(reduced$VV_loso)
    } else {
      NA_real_
    },
    pct_change_mean_VV = if (nrow(reduced) > 0L) {
      100 *
        (
          mean(reduced$VV_loso) -
            mean(base_z$VV)
        ) /
        mean(base_z$VV)
    } else {
      NA_real_
    },
    baseline_mean_WPD = mean(base_z$WPD),
    mean_WPD_loso = if (nrow(reduced) > 0L) {
      mean(reduced$WPD_loso)
    } else {
      NA_real_
    },
    pct_change_mean_WPD = if (nrow(reduced) > 0L) {
      100 *
        (
          mean(reduced$WPD_loso) -
            mean(base_z$WPD)
        ) /
        mean(base_z$WPD)
    } else {
      NA_real_
    }
  )
}

loso <- rbindlist(loso_list)

loso[, abs_pct_change_mean_WPD := abs(pct_change_mean_WPD)]
setorder(loso, zone, -abs_pct_change_mean_WPD)
loso[, abs_pct_change_mean_WPD := NULL]

loso_zone_summary <- loso[, .(
  n_stations_tested = .N,
  min_pct_change_mean_WPD =
    min(pct_change_mean_WPD, na.rm = TRUE),
  max_pct_change_mean_WPD =
    max(pct_change_mean_WPD, na.rm = TRUE),
  max_abs_pct_change_mean_WPD =
    max(abs(pct_change_mean_WPD), na.rm = TRUE),
  station_causing_max_abs_WPD_change =
    removed_station[
      which.max(abs(pct_change_mean_WPD))
    ],
  min_pct_change_mean_VV =
    min(pct_change_mean_VV, na.rm = TRUE),
  max_pct_change_mean_VV =
    max(pct_change_mean_VV, na.rm = TRUE),
  max_abs_pct_change_mean_VV =
    max(abs(pct_change_mean_VV), na.rm = TRUE),
  min_hours_retained_pct =
    min(pct_baseline_hours_retained, na.rm = TRUE)
), by = zone][order(zone)]

# ============================================================
# 14. Daily V2 series
# ============================================================

daily <- v2[, .(
  VV = mean(VV),
  WPD = mean(WPD),
  n_hours = .N,
  mean_n_stations = mean(n_stations)
), by = .(
  zone,
  date
)]

# Fixed calendar requested for comparable gap metrics.
calendar_start <- as.Date("2017-01-01")
calendar_end <- as.Date("2022-06-30")

calendar <- data.table(
  date = seq(
    calendar_start,
    calendar_end,
    by = "day"
  )
)

zones <- data.table(
  zone = c("1", "2", "3", "4")
)

# Explicit Cartesian product. data.table::merge() does not accept
# by = NULL as a cross join in all versions.
full_calendar <- data.table::CJ(
  zone = zones$zone,
  date = calendar$date,
  unique = TRUE
)

daily_full <- merge(
  full_calendar,
  daily,
  by = c("zone", "date"),
  all.x = TRUE
)

setorder(daily_full, zone, date)

# ============================================================
# 15. Missing-run helper
# ============================================================

missing_run_table <- function(
    dates,
    observed
) {

  x <- data.table(
    date = dates,
    missing = !observed
  )

  if (!any(x$missing)) {
    return(
      data.table(
        run_id = integer(),
        start_date = as.Date(character()),
        end_date = as.Date(character()),
        length_days = integer(),
        run_type = character()
      )
    )
  }

  x[, run_id := rleid(missing)]

  runs <- x[
    missing == TRUE,
    .(
      start_date = min(date),
      end_date = max(date),
      length_days = .N
    ),
    by = run_id
  ]

  first_obs <- min(
    x$date[!x$missing],
    na.rm = TRUE
  )

  last_obs <- max(
    x$date[!x$missing],
    na.rm = TRUE
  )

  runs[, run_type := fifelse(
    end_date < first_obs,
    "leading",
    fifelse(
      start_date > last_obs,
      "trailing",
      "internal"
    )
  )]

  runs[]
}

gap_tables <- list()
gap_summary_list <- list()

for (z in c("1", "2", "3", "4")) {

  dz <- daily_full[zone == z]
  observed <- is.finite(dz$WPD)

  runs <- missing_run_table(
    dz$date,
    observed
  )

  if (nrow(runs) > 0L) {
    runs[, zone := z]
    setcolorder(
      runs,
      c(
        "zone",
        "run_id",
        "start_date",
        "end_date",
        "length_days",
        "run_type"
      )
    )
  }

  gap_tables[[z]] <- runs

  internal <- runs[run_type == "internal"]
  leading <- runs[run_type == "leading"]
  trailing <- runs[run_type == "trailing"]

  gap_summary_list[[z]] <- data.table(
    zone = z,
    total_calendar_days = nrow(dz),
    observed_days = sum(observed),
    missing_days = sum(!observed),
    pct_observed_days = 100 * mean(observed),
    n_missing_runs = nrow(runs),
    max_missing_gap_days =
      if (nrow(runs) == 0L) 0L else max(runs$length_days),
    median_missing_gap_days =
      if (nrow(runs) == 0L) 0 else as.numeric(median(runs$length_days)),
    n_internal_gaps = nrow(internal),
    max_internal_gap_days =
      if (nrow(internal) == 0L) 0L else max(internal$length_days),
    median_internal_gap_days =
      if (nrow(internal) == 0L) 0 else as.numeric(median(internal$length_days)),
    n_internal_gaps_le_7 =
      sum(internal$length_days <= 7),
    n_internal_gaps_gt_7 =
      sum(internal$length_days > 7),
    leading_gap_days =
      if (nrow(leading) == 0L) 0L else max(leading$length_days),
    trailing_gap_days =
      if (nrow(trailing) == 0L) 0L else max(trailing$length_days)
  )
}

gap_runs <- rbindlist(
  gap_tables,
  fill = TRUE
)

gap_summary <- rbindlist(
  gap_summary_list,
  fill = TRUE
)

# ============================================================
# 16. Short-gap interpolation audit (<=7 days)
#     This closes the Reviewer-2 maximum-gap reporting need.
# ============================================================

interpolate_short_gaps <- function(x, maxgap = 7L) {

  n <- length(x)
  out <- x

  if (n <= 2L) return(out)

  miss <- is.na(out)

  if (!any(miss)) return(out)

  rr <- rle(miss)
  ends <- cumsum(rr$lengths)
  starts <- ends - rr$lengths + 1L

  for (j in seq_along(rr$values)) {

    if (!rr$values[j]) next

    len <- rr$lengths[j]
    st <- starts[j]
    en <- ends[j]

    # Only internal gaps and only <= maxgap.
    if (
      len <= maxgap &&
      st > 1L &&
      en < n &&
      is.finite(out[st - 1L]) &&
      is.finite(out[en + 1L])
    ) {
      out[st:en] <- approx(
        x = c(st - 1L, en + 1L),
        y = c(out[st - 1L], out[en + 1L]),
        xout = st:en
      )$y
    }
  }

  out
}

interp_summary <- daily_full[
  ,
  {
    original <- WPD
    interpolated <- interpolate_short_gaps(
      original,
      maxgap = 7L
    )

    original_obs <- is.finite(original)
    interp_obs <- is.finite(interpolated)

    remaining_runs <- missing_run_table(
      date,
      interp_obs
    )

    .(
      total_calendar_days = .N,
      original_observed_days = sum(original_obs),
      newly_interpolated_days =
        sum(!original_obs & interp_obs),
      pct_interpolated_total_calendar =
        100 * sum(!original_obs & interp_obs) / .N,
      remaining_missing_days =
        sum(!interp_obs),
      pct_remaining_missing =
        100 * mean(!interp_obs),
      max_remaining_gap_days =
        if (nrow(remaining_runs) == 0L) {
          0L
        } else {
          max(remaining_runs$length_days)
        }
    )
  },
  by = zone
][order(zone)]

# ============================================================
# 17. Save V2 and audit outputs
# ============================================================

V2_FILE <- file.path(
  DIR_RESULTS,
  "R1_V2_CANONICAL_zone_hour_dataset.rds"
)

saveRDS(
  v2,
  V2_FILE
)

write.xlsx(
  validation_summary,
  file.path(
    DIR_TABLES,
    "R1_08_V2_validation_against_R1_07.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  qc_retention,
  file.path(
    DIR_TABLES,
    "R1_08_station_QC20_retention.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  v2_summary,
  file.path(
    DIR_TABLES,
    "R1_08_V2_descriptive_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  composition_by_zone,
  file.path(
    DIR_TABLES,
    "R1_08_station_composition_by_zone.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  composition_distribution,
  file.path(
    DIR_TABLES,
    "R1_08_station_count_distribution.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  loso,
  file.path(
    DIR_TABLES,
    "R1_08_V2_LOSO_station_sensitivity.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  loso_zone_summary,
  file.path(
    DIR_TABLES,
    "R1_08_V2_LOSO_zone_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  gap_summary,
  file.path(
    DIR_TABLES,
    "R1_08_V2_daily_gap_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  gap_runs,
  file.path(
    DIR_TABLES,
    "R1_08_V2_all_missing_runs.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  interp_summary,
  file.path(
    DIR_TABLES,
    "R1_08_V2_shortgap_interpolation_summary.xlsx"
  ),
  overwrite = TRUE
)

saveRDS(
  list(
    V1_checksum = v1_checksum,
    V2_validation = validation_summary,
    station_QC20_retention = qc_retention,
    rho_audit = rho_audit,
    V2_summary = v2_summary,
    station_composition = composition_by_zone,
    station_count_distribution = composition_distribution,
    LOSO = loso,
    LOSO_zone_summary = loso_zone_summary,
    gap_summary = gap_summary,
    gap_runs = gap_runs,
    interpolation_summary = interp_summary
  ),
  file.path(
    DIR_RESULTS,
    "R1_08_V2_core_LOSO_gap_audit.rds"
  )
)

# ============================================================
# 18. Compact report
# ============================================================

summary_lines <- capture.output({

  cat("============================================================\n")
  cat("R1-08 V2 CORE / LOSO / GAP AUDIT — SUMMARY FOR CHATGPT\n")
  cat("============================================================\n")

  cat("\n============================================================\n")
  cat("V2 VALIDATION AGAINST R1-07 ARCHITECTURE C\n")
  cat("============================================================\n")
  print(validation_summary)

  cat("\n============================================================\n")
  cat("V2 DESCRIPTIVE SUMMARY\n")
  cat("============================================================\n")
  print(v2_summary)

  cat("\n============================================================\n")
  cat("STATION COMPOSITION BY ZONE\n")
  cat("============================================================\n")
  print(composition_by_zone)

  cat("\n============================================================\n")
  cat("STATION-COUNT DISTRIBUTION\n")
  cat("============================================================\n")
  print(composition_distribution)

  cat("\n============================================================\n")
  cat("V2 LOSO RESULTS\n")
  cat("============================================================\n")
  print(loso)

  cat("\n============================================================\n")
  cat("V2 LOSO ZONE SUMMARY\n")
  cat("============================================================\n")
  print(loso_zone_summary)

  cat("\n============================================================\n")
  cat("V2 DAILY GAP SUMMARY\n")
  cat("============================================================\n")
  print(gap_summary)

  cat("\n============================================================\n")
  cat("V2 SHORT-GAP INTERPOLATION SUMMARY\n")
  cat("============================================================\n")
  print(interp_summary)

  cat("\n============================================================\n")
  cat("DECISION RULE\n")
  cat("============================================================\n")
  cat(
    "Freeze V2 only if the Architecture-C reconstruction is exact and ",
    "the station-composition/LOSO results can be transparently reported. ",
    "Large LOSO sensitivity does not automatically invalidate V2, but it ",
    "requires the zones to be framed as analytical aggregation units rather ",
    "than homogeneous wind-resource classes. Maximum daily gaps must be ",
    "reported explicitly in the revised temporal-methods section.\n",
    sep = ""
  )

  cat("\nCanonical V2 file:\n")
  cat(V2_FILE, "\n")

  cat("\nR1-08 COMPLETED SUCCESSFULLY\n")
})

writeLines(
  summary_lines,
  SUMMARY_FILE,
  useBytes = TRUE
)

writeLines(
  capture.output(sessionInfo()),
  SESSION_FILE,
  useBytes = TRUE
)

cat(
  paste(summary_lines, collapse = "\n"),
  "\n"
)

cat("\n============================================================\n")
cat("NEXT ACTION\n")
cat("============================================================\n")
cat(
  "Upload this single file to ChatGPT:\n",
  SUMMARY_FILE,
  "\n",
  sep = ""
)

log_msg("R1-08 completed successfully.")
log_msg("Canonical V2:", V2_FILE)
log_msg("Summary to upload:", SUMMARY_FILE)

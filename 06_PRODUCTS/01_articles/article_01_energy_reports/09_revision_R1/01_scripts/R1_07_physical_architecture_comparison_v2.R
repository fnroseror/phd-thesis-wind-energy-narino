# ============================================================
# ENERGY REPORTS — REVISION R1
# R1_07_physical_architecture_comparison_v2.R
#
# Manuscript: EGYR-D-26-02665
#
# Purpose:
# Compare the submitted zone-hour WPD architecture with two
# corrected alternatives that apply the article's VV <= 20 m/s
# criterion BEFORE spatial aggregation.
#
# Architectures:
# A) V1 submitted reference:
#    raw records -> zone-hour mean VV -> QC20 -> WPD(mean VV)
#
# B) Corrected kinematic aggregation:
#    raw records -> station-hour mean VV -> QC20 ->
#    equal-station zone-hour mean VV -> WPD(mean VV)
#
# C) Physically preferred energetic aggregation:
#    raw records -> station-hour mean VV -> QC20 ->
#    station-hour WPD -> equal-station mean WPD by zone-hour
#
# C respects the nonlinearity:
# mean(v^3) != mean(v)^3.
#
# IMPORTANT:
# - This is a comparison/audit, not an automatic replacement of V1.
# - Raw IDEAM data remain local.
# - No original Article-1 output is overwritten.
# - Outputs go only to 09_revision_R1.
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

invisible(lapply(
  c(DIR_TABLES, DIR_RESULTS, DIR_LOGS),
  dir.create,
  recursive = TRUE,
  showWarnings = FALSE
))

for (f in c(RAW_FILE, CANDIDATE_FILE, MAIN_FILE)) {
  if (!file.exists(f)) stop("Required file not found: ", f)
}

# ============================================================
# 3. Logging
# ============================================================

LOG_FILE <- file.path(
  DIR_LOGS,
  "R1_07_physical_architecture_comparison_log.txt"
)

SUMMARY_FILE <- file.path(
  DIR_RESULTS,
  "R1_07_UPLOAD_THIS_TO_CHAT.txt"
)

SESSION_FILE <- file.path(
  DIR_RESULTS,
  "R1_07_sessionInfo.txt"
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

# ============================================================
# 4. Frozen Article-1 datasets and checksum
# ============================================================

candidate <- as.data.table(readRDS(CANDIDATE_FILE))
main <- as.data.table(readRDS(MAIN_FILE))

candidate[, zone := as.character(zone)]
main[, zone := as.character(zone)]

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

log_msg("V1 checksum PASSED.")

# Candidate rho key used by V1
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

# The raw IDEAM source contains station-hours outside the temporal
# support of the Article-1 candidate dataset. For a fair architecture
# comparison, all alternatives must use exactly the same zone-hour
# universe as V1. Therefore, retain only zone + datetime keys present
# in the frozen candidate dataset before QC and spatial aggregation.
candidate_time_support <- unique(
  rho_key[, .(
    zone,
    datetime
  )]
)

# ============================================================
# 5. Read raw source, VV only
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
  stop("Missing raw columns: ", paste(miss, collapse = ", "))
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
  } else rep(0L, length(time_part))

  MM <- if (length(tparts) >= 2L) {
    suppressWarnings(as.integer(tparts[[2L]]))
  } else rep(0L, length(time_part))

  SS <- if (length(tparts) >= 3L) {
    suppressWarnings(as.integer(tparts[[3L]]))
  } else rep(0L, length(time_part))

  HH[is.na(HH)] <- 0L
  MM[is.na(MM)] <- 0L
  SS[is.na(SS)] <- 0L

  valid <-
    !is.na(yy) & !is.na(mm) & !is.na(dd) &
    yy >= 1900 & yy <= 2100 &
    mm >= 1 & mm <= 12 &
    dd >= 1 & dd <= 31 &
    HH >= 0 & HH <= 23 &
    MM >= 0 & MM <= 59 &
    SS >= 0 & SS <= 59

  out <- rep(as.POSIXct(NA, tz = tz), length(x))

  iso <- sprintf(
    "%04d-%02d-%02d %02d:%02d:%02d",
    yy, mm, dd, HH, MM, SS
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

log_msg("VV raw rows in study period:", nrow(vv))
log_msg("Stations:", uniqueN(vv$station))

# ============================================================
# 7. Station-hour reconstruction
#
# First consolidate repeated/sub-hourly raw records for the same
# station and hour. Every station then contributes at most once
# to a given zone-hour.
# ============================================================

station_hour <- vv[, .(
  VV_station_hour = mean(value, na.rm = TRUE),
  n_raw_records = .N
), by = .(
  zone,
  station,
  datetime
)]

station_hour_total_before_support <- nrow(station_hour)

station_hour <- merge(
  station_hour,
  candidate_time_support,
  by = c("zone", "datetime"),
  all = FALSE
)

support_audit <- data.table(
  n_station_hours_before_candidate_support =
    station_hour_total_before_support,
  n_station_hours_on_candidate_support =
    nrow(station_hour),
  pct_station_hours_on_candidate_support =
    100 * nrow(station_hour) /
      station_hour_total_before_support
)

log_msg(
  "Station-hours restricted to frozen Article-1 candidate time support:",
  nrow(station_hour),
  "of",
  station_hour_total_before_support
)

# Article's stated conservative QC, now applied BEFORE spatial
# aggregation.
station_hour_qc20 <- station_hour[
  is.finite(VV_station_hour) &
    VV_station_hour >= 0 &
    VV_station_hour <= 20
]

log_msg(
  "Station-hours before QC20:",
  nrow(station_hour),
  "| after QC20:",
  nrow(station_hour_qc20)
)

station_qc_summary <- station_hour[, .(
  n_station_hours = .N,
  n_retained_QC20 = sum(
    is.finite(VV_station_hour) &
      VV_station_hour >= 0 &
      VV_station_hour <= 20
  ),
  pct_retained_QC20 = 100 * mean(
    is.finite(VV_station_hour) &
      VV_station_hour >= 0 &
      VV_station_hour <= 20
  ),
  mean_VV_before = mean(VV_station_hour),
  median_VV_before = median(VV_station_hour),
  mean_VV_after_QC20 = mean(
    VV_station_hour[
      VV_station_hour >= 0 &
        VV_station_hour <= 20
    ]
  ),
  median_VV_after_QC20 = median(
    VV_station_hour[
      VV_station_hour >= 0 &
        VV_station_hour <= 20
    ]
  )
), by = .(
  zone,
  station
)]

# ============================================================
# 8. Join V1 air density to each retained station-hour
# ============================================================

sh <- merge(
  station_hour_qc20,
  rho_key,
  by = c("zone", "datetime"),
  all.x = TRUE
)

rho_join_audit <- sh[, .(
  n_station_hours = .N,
  n_with_rho = sum(is.finite(rho_used)),
  pct_with_rho = 100 * mean(is.finite(rho_used))
), by = zone][order(zone)]

if (any(rho_join_audit$pct_with_rho < 99.999)) {
  stop(
    paste0(
      "Unexpected rho join mismatch after restricting to the frozen ",
      "Article-1 candidate time support. Inspect rho_key uniqueness and ",
      "datetime classes before proceeding."
    )
  )
}

sh <- sh[is.finite(rho_used)]

# Local/point energetic transform first
sh[, WPD_station_hour := 0.5 * rho_used * VV_station_hour^3]

# ============================================================
# 9. Architecture B:
#    Equal-station mean VV -> WPD(mean VV)
# ============================================================

arch_B <- sh[, .(
  n_stations = uniqueN(station),
  VV = mean(VV_station_hour),
  rho_used = unique(rho_used)[1L]
), by = .(
  zone,
  datetime
)]

arch_B[, WPD := 0.5 * rho_used * VV^3]
arch_B[, architecture := "B_stationhour_QC20_equal_station_meanVV_then_WPD"]

# ============================================================
# 10. Architecture C:
#     station-hour WPD -> equal-station mean WPD
# ============================================================

arch_C <- sh[, .(
  n_stations = uniqueN(station),
  VV = mean(VV_station_hour),
  rho_used = unique(rho_used)[1L],
  WPD = mean(WPD_station_hour)
), by = .(
  zone,
  datetime
)]

arch_C[, architecture := "C_stationhour_QC20_WPD_first_then_equal_station_mean"]

# ============================================================
# 11. Architecture A / V1 reference
# ============================================================

arch_A <- main[, .(
  zone,
  datetime,
  VV,
  rho_used,
  WPD
)]

arch_A[, n_stations := NA_integer_]
arch_A[, architecture := "A_V1_submitted_reference"]

# ============================================================
# 12. Standardized summaries
# ============================================================

summarize_arch <- function(d) {

  d[, .(
    n_zone_hours = .N,
    mean_VV = mean(VV),
    median_VV = median(VV),
    sd_VV = sd(VV),
    p95_VV = quantile(VV, 0.95, names = FALSE),
    p99_VV = quantile(VV, 0.99, names = FALSE),
    max_VV = max(VV),

    mean_WPD = mean(WPD),
    median_WPD = median(WPD),
    sd_WPD = sd(WPD),
    p95_WPD = quantile(WPD, 0.95, names = FALSE),
    p99_WPD = quantile(WPD, 0.99, names = FALSE),
    max_WPD = max(WPD),

    median_n_stations = if (
      all(is.na(n_stations))
    ) NA_real_ else median(n_stations, na.rm = TRUE),

    min_n_stations = if (
      all(is.na(n_stations))
    ) NA_real_ else min(n_stations, na.rm = TRUE),

    max_n_stations = if (
      all(is.na(n_stations))
    ) NA_real_ else max(n_stations, na.rm = TRUE)
  ), by = .(
    architecture,
    zone
  )]
}

all_arch <- rbindlist(
  list(
    arch_A,
    arch_B[, .(
      zone,
      datetime,
      VV,
      rho_used,
      WPD,
      n_stations,
      architecture
    )],
    arch_C[, .(
      zone,
      datetime,
      VV,
      rho_used,
      WPD,
      n_stations,
      architecture
    )]
  ),
  fill = TRUE
)

architecture_summary <- summarize_arch(all_arch)
setorder(architecture_summary, zone, architecture)

# ============================================================
# 13. Differences versus V1
# ============================================================

baseline <- architecture_summary[
  architecture == "A_V1_submitted_reference",
  .(
    zone,
    V1_n = n_zone_hours,
    V1_mean_VV = mean_VV,
    V1_mean_WPD = mean_WPD,
    V1_median_WPD = median_WPD,
    V1_p95_WPD = p95_WPD
  )
]

comparison <- merge(
  architecture_summary,
  baseline,
  by = "zone",
  all.x = TRUE
)

comparison[, `:=`(
  pct_change_n_vs_V1 =
    100 * (n_zone_hours - V1_n) / V1_n,
  pct_change_mean_VV_vs_V1 =
    100 * (mean_VV - V1_mean_VV) / V1_mean_VV,
  pct_change_mean_WPD_vs_V1 =
    100 * (mean_WPD - V1_mean_WPD) / V1_mean_WPD,
  pct_change_median_WPD_vs_V1 =
    100 * (median_WPD - V1_median_WPD) /
      ifelse(V1_median_WPD == 0, NA_real_, V1_median_WPD),
  pct_change_p95_WPD_vs_V1 =
    100 * (p95_WPD - V1_p95_WPD) /
      ifelse(V1_p95_WPD == 0, NA_real_, V1_p95_WPD)
)]

# ============================================================
# 14. Zonal rankings under each architecture
# ============================================================

ranking <- architecture_summary[
  ,
  .(
    zone,
    mean_VV,
    mean_WPD,
    rank_mean_VV = frank(-mean_VV, ties.method = "min"),
    rank_mean_WPD = frank(-mean_WPD, ties.method = "min")
  ),
  by = architecture
][order(
  architecture,
  rank_mean_WPD
)]

# ============================================================
# 15. Internal nonlinearity diagnostic:
#     C / B shows how much WPD changes solely from transform order
# ============================================================

Bsmall <- architecture_summary[
  architecture ==
    "B_stationhour_QC20_equal_station_meanVV_then_WPD",
  .(
    zone,
    mean_WPD_B = mean_WPD,
    median_WPD_B = median_WPD
  )
]

Csmall <- architecture_summary[
  architecture ==
    "C_stationhour_QC20_WPD_first_then_equal_station_mean",
  .(
    zone,
    mean_WPD_C = mean_WPD,
    median_WPD_C = median_WPD
  )
]

nonlinearity <- merge(
  Bsmall,
  Csmall,
  by = "zone"
)

nonlinearity[, `:=`(
  ratio_mean_C_over_B = mean_WPD_C / mean_WPD_B,
  pct_difference_C_vs_B =
    100 * (mean_WPD_C - mean_WPD_B) / mean_WPD_B
)]

# ============================================================
# 16. Save candidate corrected datasets (derived only)
# ============================================================

saveRDS(
  arch_B,
  file.path(
    DIR_RESULTS,
    "R1_07_candidate_architecture_B.rds"
  )
)

saveRDS(
  arch_C,
  file.path(
    DIR_RESULTS,
    "R1_07_candidate_architecture_C.rds"
  )
)

write.xlsx(
  v1_checksum,
  file.path(
    DIR_TABLES,
    "R1_07_V1_checksum.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  support_audit,
  file.path(
    DIR_TABLES,
    "R1_07_candidate_time_support_audit.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  station_qc_summary,
  file.path(
    DIR_TABLES,
    "R1_07_stationhour_QC20_retention.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  rho_join_audit,
  file.path(
    DIR_TABLES,
    "R1_07_rho_join_audit.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  architecture_summary,
  file.path(
    DIR_TABLES,
    "R1_07_architecture_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  comparison,
  file.path(
    DIR_TABLES,
    "R1_07_architecture_comparison_vs_V1.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  ranking,
  file.path(
    DIR_TABLES,
    "R1_07_zonal_rankings_by_architecture.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  nonlinearity,
  file.path(
    DIR_TABLES,
    "R1_07_nonlinearity_transform_order.xlsx"
  ),
  overwrite = TRUE
)

saveRDS(
  list(
    V1_checksum = v1_checksum,
    candidate_time_support_audit = support_audit,
    station_QC20 = station_qc_summary,
    rho_join_audit = rho_join_audit,
    architecture_summary = architecture_summary,
    comparison_vs_V1 = comparison,
    rankings = ranking,
    nonlinearity = nonlinearity
  ),
  file.path(
    DIR_RESULTS,
    "R1_07_physical_architecture_comparison.rds"
  )
)

# ============================================================
# 17. Compact report for ChatGPT
# ============================================================

summary_lines <- capture.output({

  cat("============================================================\n")
  cat("R1-07 PHYSICAL ARCHITECTURE COMPARISON — SUMMARY FOR CHATGPT\n")
  cat("============================================================\n")

  cat("\n============================================================\n")
  cat("V1 CHECKSUM\n")
  cat("============================================================\n")
  print(v1_checksum)

  cat("\n============================================================\n")
  cat("CANDIDATE TIME-SUPPORT AUDIT\n")
  cat("============================================================\n")
  print(support_audit)

  cat("\n============================================================\n")
  cat("STATION-HOUR QC20 RETENTION\n")
  cat("============================================================\n")
  print(station_qc_summary)

  cat("\n============================================================\n")
  cat("RHO JOIN AUDIT\n")
  cat("============================================================\n")
  print(rho_join_audit)

  cat("\n============================================================\n")
  cat("ARCHITECTURE SUMMARY\n")
  cat("============================================================\n")
  print(architecture_summary)

  cat("\n============================================================\n")
  cat("COMPARISON VERSUS V1\n")
  cat("============================================================\n")
  print(
    comparison[, .(
      zone,
      architecture,
      n_zone_hours,
      pct_change_n_vs_V1,
      mean_VV,
      pct_change_mean_VV_vs_V1,
      mean_WPD,
      pct_change_mean_WPD_vs_V1,
      median_WPD,
      p95_WPD
    )]
  )

  cat("\n============================================================\n")
  cat("ZONAL RANKINGS\n")
  cat("============================================================\n")
  print(ranking)

  cat("\n============================================================\n")
  cat("NONLINEARITY / ORDER-OF-OPERATIONS DIAGNOSTIC\n")
  cat("============================================================\n")
  print(nonlinearity)

  cat("\n============================================================\n")
  cat("DECISION RULE\n")
  cat("============================================================\n")
  cat(
    "Architecture C is physically preferred if the manuscript intends ",
    "to characterize average local available wind power density, because ",
    "the cubic transformation is applied before spatial averaging. ",
    "Architecture B preserves a zone-hour wind-speed representation but ",
    "does not preserve the mean of local kinetic power density. ",
    "No architecture should be selected because it reproduces a desired ",
    "zonal ranking.\n",
    sep = ""
  )

  cat("\nR1-07 COMPLETED SUCCESSFULLY\n")
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

cat(paste(summary_lines, collapse = "\n"), "\n")

cat("\n============================================================\n")
cat("NEXT ACTION\n")
cat("============================================================\n")
cat(
  "Upload this single file to ChatGPT:\n",
  SUMMARY_FILE,
  "\n",
  sep = ""
)

log_msg("R1-07 completed successfully.")
log_msg("Summary to upload:", SUMMARY_FILE)

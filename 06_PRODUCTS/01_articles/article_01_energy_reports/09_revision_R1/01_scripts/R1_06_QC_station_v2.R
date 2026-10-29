# ============================================================
# ENERGY REPORTS — REVISION R1
# R1_06_station_level_QC_sensitivity_v2.R
#
# Manuscript: EGYR-D-26-02665
#
# Purpose:
# Follow-up audit after R1-05 showed strong sensitivity of zonal
# mean WPD to individual stations, especially Zone 1 / station
# 51025060.
#
# This script tests whether the published zonal conclusions depend
# on applying the VV <= 20 m/s QC rule AFTER zone-hour aggregation.
#
# It evaluates:
#   1) Station-level and raw-record high-wind prevalence.
#   2) Temporal concentration of high-wind regimes by station.
#   3) Alternative pre-aggregation QC scenarios at 20/25/30 m/s.
#   4) Resulting zone-level mean VV and WPD using the same frozen
#      daily-zone air density as Article 1.
#
# IMPORTANT:
# - Raw IDEAM data remain local and are NOT copied to the repo.
# - Original Article-1 outputs are NOT overwritten.
# - Derived summaries only are written to 09_revision_R1.
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

dirs <- c(
  DIR_TABLES,
  DIR_RESULTS,
  DIR_LOGS
)

invisible(
  lapply(
    dirs,
    dir.create,
    recursive = TRUE,
    showWarnings = FALSE
  )
)

required_files <- c(
  RAW_FILE,
  CANDIDATE_FILE,
  MAIN_FILE
)

if (!all(file.exists(required_files))) {
  stop(
    "Missing required local file(s):\n",
    paste(
      required_files[!file.exists(required_files)],
      collapse = "\n"
    )
  )
}

# ============================================================
# 3. Logging
# ============================================================

LOG_FILE <- file.path(
  DIR_LOGS,
  "R1_06_station_level_QC_sensitivity_log.txt"
)

SUMMARY_FILE <- file.path(
  DIR_RESULTS,
  "R1_06_UPLOAD_THIS_TO_CHAT.txt"
)

SESSION_FILE <- file.path(
  DIR_RESULTS,
  "R1_06_sessionInfo.txt"
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

log_msg("Starting R1-06 station-level QC sensitivity audit.")

# ============================================================
# 4. Load frozen Article-1 datasets
# ============================================================

candidate <- as.data.table(
  readRDS(CANDIDATE_FILE)
)

main <- as.data.table(
  readRDS(MAIN_FILE)
)

candidate[, zone := as.character(zone)]
main[, zone := as.character(zone)]

main_checksum <- main[, .(
  n = .N,
  mean_VV = mean(VV),
  mean_WPD = mean(WPD)
), by = zone][order(zone)]

expected <- data.table(
  zone = c("1", "2", "3", "4"),
  n_expected = c(
    42706L,
    43618L,
    42416L,
    8744L
  ),
  mean_WPD_expected = c(
    140.75903,
    15.81935,
    12.96353,
    16.94948
  )
)

main_checksum <- merge(
  main_checksum,
  expected,
  by = "zone",
  all.x = TRUE
)

main_checksum[
  ,
  `:=`(
    n_match = n == n_expected,
    WPD_abs_difference =
      abs(mean_WPD - mean_WPD_expected)
  )
]

if (!all(main_checksum$n_match)) {
  stop("Frozen V1 checksum FAILED.")
}

if (
  any(
    main_checksum$WPD_abs_difference >
      1e-4
  )
) {
  stop("Frozen V1 WPD checksum FAILED.")
}

log_msg("Frozen V1 checksum: PASSED.")

# ============================================================
# 5. Read restricted raw data and retain only VV
# ============================================================

log_msg("Reading restricted raw IDEAM source.")

raw <- tryCatch(
  fread(
    RAW_FILE,
    encoding = "UTF-8",
    na.strings = c(
      "",
      "NA",
      "NaN",
      "NULL",
      "null",
      "-",
      "N/A"
    ),
    showProgress = TRUE
  ),
  error = function(e1) {
    fread(
      RAW_FILE,
      encoding = "Latin-1",
      na.strings = c(
        "",
        "NA",
        "NaN",
        "NULL",
        "null",
        "-",
        "N/A"
      ),
      showProgress = TRUE
    )
  }
)

required_raw_columns <- c(
  "Estación",
  "FechaYHora",
  "Valor",
  "Zona",
  "Variable"
)

missing_raw <- setdiff(
  required_raw_columns,
  names(raw)
)

if (length(missing_raw) > 0L) {
  stop(
    "Missing raw columns: ",
    paste(
      missing_raw,
      collapse = ", "
    )
  )
}

vv <- raw[
  toupper(
    trimws(
      as.character(Variable)
    )
  ) == "VV",
  .(
    station =
      as.character(`Estación`),
    raw_datetime =
      as.character(FechaYHora),
    value =
      suppressWarnings(
        as.numeric(Valor)
      ),
    zone =
      as.character(Zona)
  )
]

rm(raw)
gc()

vv <- vv[
  zone %in% c("1", "2", "3", "4") &
    is.finite(value)
]

log_msg("Raw VV rows retained:", nrow(vv))

# ============================================================
# 6. Robust DMY parser
# ============================================================

manual_parse_dmy <- function(
    x,
    tz = "America/Bogota"
) {

  x <- as.character(x)
  x <- stringr::str_squish(x)
  x <- stringr::str_replace_all(
    x,
    "T",
    " "
  )

  date_part <- sub(
    "\\s+.*$",
    "",
    x
  )

  time_part <- ifelse(
    grepl("\\s+", x),
    sub(
      "^\\S+\\s+",
      "",
      x
    ),
    "00:00:00"
  )

  date_part <- gsub(
    "[-.]",
    "/",
    date_part
  )

  parts <- data.table::tstrsplit(
    date_part,
    "/",
    fixed = TRUE,
    fill = NA
  )

  dd <- suppressWarnings(
    as.integer(parts[[1L]])
  )

  mm <- suppressWarnings(
    as.integer(parts[[2L]])
  )

  yy <- suppressWarnings(
    as.integer(parts[[3L]])
  )

  yy <- ifelse(
    !is.na(yy) &
      yy < 100,
    2000 + yy,
    yy
  )

  time_part <- gsub(
    "\\..*$",
    "",
    time_part
  )

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
    as.POSIXct(
      NA,
      tz = tz
    ),
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

vv[
  ,
  datetime :=
    manual_parse_dmy(
      raw_datetime
    )
]

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

vv[
  ,
  datetime_hour :=
    lubridate::floor_date(
      datetime,
      unit = "hour"
    )
]

vv[
  ,
  date :=
    as.Date(
      datetime_hour,
      tz = "America/Bogota"
    )
]

vv[
  ,
  year_month :=
    format(
      datetime_hour,
      "%Y-%m"
    )
]

log_msg("VV rows inside study period:", nrow(vv))
log_msg("Stations:", uniqueN(vv$station))

# ============================================================
# 7. Raw-record QC profile by station
# ============================================================

raw_station_qc <- vv[, .(
  n_raw = .N,
  n_days = uniqueN(date),
  mean_raw_VV = mean(value),
  median_raw_VV = median(value),
  sd_raw_VV = sd(value),
  p75_raw_VV =
    quantile(
      value,
      0.75,
      names = FALSE
    ),
  p95_raw_VV =
    quantile(
      value,
      0.95,
      names = FALSE
    ),
  p99_raw_VV =
    quantile(
      value,
      0.99,
      names = FALSE
    ),
  max_raw_VV = max(value),
  pct_raw_gt_10 =
    100 * mean(value > 10),
  pct_raw_gt_15 =
    100 * mean(value > 15),
  pct_raw_gt_20 =
    100 * mean(value > 20),
  pct_raw_gt_25 =
    100 * mean(value > 25),
  pct_raw_gt_30 =
    100 * mean(value > 30),
  pct_raw_gt_40 =
    100 * mean(value > 40),
  pct_raw_gt_50 =
    100 * mean(value > 50)
), by = .(
  zone,
  station
)]

setorder(
  raw_station_qc,
  zone,
  -pct_raw_gt_20
)

# ============================================================
# 8. Station-hour aggregation and QC profile
# ============================================================

station_hour <- vv[, .(
  VV_station_hour =
    mean(
      value,
      na.rm = TRUE
    ),
  n_raw_in_hour = .N,
  sum_raw_in_hour =
    sum(
      value,
      na.rm = TRUE
    )
), by = .(
  zone,
  station,
  datetime = datetime_hour
)]

station_hour[
  ,
  date :=
    as.Date(
      datetime,
      tz = "America/Bogota"
    )
]

station_hour[
  ,
  year_month :=
    format(
      datetime,
      "%Y-%m"
    )
]

station_hour_qc <- station_hour[, .(
  n_station_hours = .N,
  n_days = uniqueN(date),
  mean_VV = mean(VV_station_hour),
  median_VV = median(VV_station_hour),
  sd_VV = sd(VV_station_hour),
  p75_VV =
    quantile(
      VV_station_hour,
      0.75,
      names = FALSE
    ),
  p95_VV =
    quantile(
      VV_station_hour,
      0.95,
      names = FALSE
    ),
  p99_VV =
    quantile(
      VV_station_hour,
      0.99,
      names = FALSE
    ),
  max_VV = max(VV_station_hour),
  pct_hours_gt_10 =
    100 * mean(VV_station_hour > 10),
  pct_hours_gt_15 =
    100 * mean(VV_station_hour > 15),
  pct_hours_gt_20 =
    100 * mean(VV_station_hour > 20),
  pct_hours_gt_25 =
    100 * mean(VV_station_hour > 25),
  pct_hours_gt_30 =
    100 * mean(VV_station_hour > 30),
  pct_hours_gt_40 =
    100 * mean(VV_station_hour > 40),
  pct_hours_gt_50 =
    100 * mean(VV_station_hour > 50),
  median_raw_records_per_hour =
    as.numeric(
      median(n_raw_in_hour)
    ),
  max_raw_records_per_hour =
    as.numeric(
      max(n_raw_in_hour)
    )
), by = .(
  zone,
  station
)]

setorder(
  station_hour_qc,
  zone,
  -pct_hours_gt_20
)

# ============================================================
# 9. Monthly regime audit for influential stations
# ============================================================

influential_stations <- c(
  "51025060",
  "52055160",
  "52055150",
  "52055210",
  "52035040",
  "52040050"
)

monthly_influential <- station_hour[
  station %in% influential_stations,
  .(
    n_hours = .N,
    mean_VV =
      mean(VV_station_hour),
    median_VV =
      median(VV_station_hour),
    p75_VV =
      quantile(
        VV_station_hour,
        0.75,
        names = FALSE
      ),
    p95_VV =
      quantile(
        VV_station_hour,
        0.95,
        names = FALSE
      ),
    p99_VV =
      quantile(
        VV_station_hour,
        0.99,
        names = FALSE
      ),
    max_VV =
      max(VV_station_hour),
    pct_hours_gt_15 =
      100 *
        mean(
          VV_station_hour > 15
        ),
    pct_hours_gt_20 =
      100 *
        mean(
          VV_station_hour > 20
        ),
    pct_hours_gt_30 =
      100 *
        mean(
          VV_station_hour > 30
        )
  ),
  by = .(
    zone,
    station,
    year_month
  )
]

setorder(
  monthly_influential,
  station,
  year_month
)

# ============================================================
# 10. Candidate key and baseline reconstruction
# ============================================================

candidate_key <- candidate[, .(
  zone,
  datetime,
  date,
  rho_used,
  VV_candidate = VV
)]

baseline_zone_hour <- vv[, .(
  VV_scenario =
    mean(
      value,
      na.rm = TRUE
    ),
  n_raw_retained = .N,
  n_stations_retained =
    uniqueN(station)
), by = .(
  zone,
  datetime = datetime_hour
)]

baseline_validation <- merge(
  candidate_key,
  baseline_zone_hour,
  by = c(
    "zone",
    "datetime"
  ),
  all.x = TRUE
)

baseline_validation[
  ,
  abs_difference :=
    abs(
      VV_candidate -
        VV_scenario
    )
]

baseline_validation_summary <- baseline_validation[, .(
  n = .N,
  pct_matched =
    100 *
      mean(
        is.finite(VV_scenario)
      ),
  mean_abs_difference =
    mean(
      abs_difference,
      na.rm = TRUE
    ),
  max_abs_difference =
    max(
      abs_difference,
      na.rm = TRUE
    )
)]

if (
  baseline_validation_summary$pct_matched <
    99.9 ||
  baseline_validation_summary$mean_abs_difference >
    1e-6
) {
  stop(
    "Raw baseline reconstruction failed; QC sensitivity not executed."
  )
}

log_msg("Raw baseline reconstruction: PASSED.")

# ============================================================
# 11. Scenario builders
# ============================================================

summarize_scenario <- function(
    scenario_zone_hour,
    scenario_name
) {

  temp <- merge(
    candidate_key[
      ,
      .(
        zone,
        datetime,
        date,
        rho_used
      )
    ],
    scenario_zone_hour,
    by = c(
      "zone",
      "datetime"
    ),
    all.x = TRUE
  )

  # Same final Article-1 zone-hour QC rule
  temp[
    !is.finite(VV_scenario) |
      VV_scenario < 0 |
      VV_scenario > 20,
    VV_scenario := NA_real_
  ]

  temp[
    ,
    WPD_scenario :=
      0.5 *
      rho_used *
      VV_scenario^3
  ]

  out <- temp[
    is.finite(VV_scenario) &
      is.finite(WPD_scenario),
    .(
      n_zone_hours = .N,
      mean_VV =
        mean(VV_scenario),
      median_VV =
        median(VV_scenario),
      mean_WPD =
        mean(WPD_scenario),
      median_WPD =
        median(WPD_scenario)
    ),
    by = zone
  ]

  out[
    ,
    scenario := scenario_name
  ]

  out[]
}

build_raw_threshold_scenario <- function(
    threshold
) {

  vv[
    value >= 0 &
      value <= threshold,
    .(
      VV_scenario =
        mean(
          value,
          na.rm = TRUE
        ),
      n_raw_retained = .N,
      n_stations_retained =
        uniqueN(station)
    ),
    by = .(
      zone,
      datetime = datetime_hour
    )
  ]
}

build_stationhour_threshold_scenario <- function(
    threshold
) {

  sh <- station_hour[
    VV_station_hour >= 0 &
      VV_station_hour <= threshold
  ]

  # Preserve the original raw-record weighting across stations
  # by carrying each station-hour sum and count.
  sh[, .(
    VV_scenario =
      sum(
        sum_raw_in_hour
      ) /
      sum(
        n_raw_in_hour
      ),
    n_raw_retained =
      sum(
        n_raw_in_hour
      ),
    n_stations_retained =
      uniqueN(station)
  ), by = .(
    zone,
    datetime
  )]
}

# ============================================================
# 12. Run QC sensitivity scenarios
# ============================================================

scenario_results <- list()

scenario_results[[1L]] <-
  summarize_scenario(
    baseline_zone_hour,
    "Original_preQC_aggregation_then_zonehour_QC20"
  )

counter <- 2L

for (thr in c(20, 25, 30)) {

  scenario_results[[counter]] <-
    summarize_scenario(
      build_raw_threshold_scenario(
        thr
      ),
      paste0(
        "Raw_record_QC",
        thr,
        "_before_aggregation_then_zonehour_QC20"
      )
    )

  counter <- counter + 1L

  scenario_results[[counter]] <-
    summarize_scenario(
      build_stationhour_threshold_scenario(
        thr
      ),
      paste0(
        "Station_hour_QC",
        thr,
        "_before_aggregation_then_zonehour_QC20"
      )
    )

  counter <- counter + 1L
}

scenario_summary <- rbindlist(
  scenario_results,
  fill = TRUE
)

baseline_main <- main[, .(
  baseline_n = .N,
  baseline_mean_VV =
    mean(VV),
  baseline_mean_WPD =
    mean(WPD)
), by = zone]

scenario_summary <- merge(
  scenario_summary,
  baseline_main,
  by = "zone",
  all.x = TRUE
)

scenario_summary[
  ,
  `:=`(
    pct_change_mean_VV_vs_V1 =
      100 *
      (
        mean_VV -
          baseline_mean_VV
      ) /
      baseline_mean_VV,
    pct_change_mean_WPD_vs_V1 =
      100 *
      (
        mean_WPD -
          baseline_mean_WPD
      ) /
      baseline_mean_WPD,
    pct_V1_zone_hours_retained =
      100 *
      n_zone_hours /
      baseline_n
  )
]

setorder(
  scenario_summary,
  zone,
  scenario
)

# ============================================================
# 13. Concise Zone-1 / key-station audit
# ============================================================

zone1_focus <- station_hour_qc[
  zone == "1"
][order(
  -pct_hours_gt_20
)]

key_station_months <- monthly_influential[
  station == "51025060"
][order(
  year_month
)]

key_station_highest_months <- key_station_months[
  order(
    -pct_hours_gt_20,
    -mean_VV
  )
][1:min(
  20L,
  .N
)]

# ============================================================
# 14. Save derived outputs
# ============================================================

write.xlsx(
  main_checksum,
  file.path(
    DIR_TABLES,
    "R1_06_V1_scientific_checksum.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  baseline_validation_summary,
  file.path(
    DIR_TABLES,
    "R1_06_raw_baseline_reconstruction_check.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  raw_station_qc,
  file.path(
    DIR_TABLES,
    "R1_06_raw_record_QC_profile_by_station.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  station_hour_qc,
  file.path(
    DIR_TABLES,
    "R1_06_station_hour_QC_profile.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  monthly_influential,
  file.path(
    DIR_TABLES,
    "R1_06_influential_station_monthly_regimes.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  scenario_summary,
  file.path(
    DIR_TABLES,
    "R1_06_preaggregation_QC_sensitivity_by_zone.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  key_station_highest_months,
  file.path(
    DIR_TABLES,
    "R1_06_station_51025060_highest_months.xlsx"
  ),
  overwrite = TRUE
)

saveRDS(
  list(
    V1_checksum =
      main_checksum,
    baseline_reconstruction =
      baseline_validation_summary,
    raw_station_qc =
      raw_station_qc,
    station_hour_qc =
      station_hour_qc,
    monthly_influential =
      monthly_influential,
    scenario_summary =
      scenario_summary,
    zone1_focus =
      zone1_focus,
    station_51025060_highest_months =
      key_station_highest_months
  ),
  file.path(
    DIR_RESULTS,
    "R1_06_station_level_QC_sensitivity.rds"
  )
)

# ============================================================
# 15. Summary to upload
# ============================================================

summary_lines <- capture.output({

  cat("============================================================\n")
  cat("R1-06 STATION-LEVEL QC SENSITIVITY — SUMMARY FOR CHATGPT\n")
  cat("============================================================\n")

  cat("\n============================================================\n")
  cat("V1 SCIENTIFIC CHECKSUM\n")
  cat("============================================================\n")
  print(main_checksum)

  cat("\n============================================================\n")
  cat("RAW BASELINE RECONSTRUCTION CHECK\n")
  cat("============================================================\n")
  print(baseline_validation_summary)

  cat("\n============================================================\n")
  cat("ZONE 1 STATION-HOUR QC PROFILE\n")
  cat("============================================================\n")
  print(zone1_focus)

  cat("\n============================================================\n")
  cat("ALL STATIONS — HIGH-VV PROFILE\n")
  cat("============================================================\n")
  print(
    station_hour_qc[, .(
      zone,
      station,
      n_station_hours,
      n_days,
      mean_VV,
      median_VV,
      p75_VV,
      p95_VV,
      p99_VV,
      max_VV,
      pct_hours_gt_15,
      pct_hours_gt_20,
      pct_hours_gt_25,
      pct_hours_gt_30
    )]
  )

  cat("\n============================================================\n")
  cat("PRE-AGGREGATION QC SENSITIVITY\n")
  cat("============================================================\n")
  print(
    scenario_summary[, .(
      zone,
      scenario,
      n_zone_hours,
      pct_V1_zone_hours_retained,
      mean_VV,
      pct_change_mean_VV_vs_V1,
      mean_WPD,
      pct_change_mean_WPD_vs_V1
    )]
  )

  cat("\n============================================================\n")
  cat("STATION 51025060 — MONTHS WITH STRONGEST HIGH-WIND SIGNAL\n")
  cat("============================================================\n")
  print(key_station_highest_months)

  cat("\n============================================================\n")
  cat("INTERPRETATION RULE\n")
  cat("============================================================\n")
  cat(
    "If Zone 1 WPD changes materially when high station-level VV values ",
    "are filtered before zone-hour aggregation, the published energetic ",
    "dominance must be treated as station/QC-sensitive rather than a robust ",
    "zone-wide property until the influential station is independently validated.\n",
    sep = ""
  )

  cat("\nR1-06 COMPLETED SUCCESSFULLY\n")
})

writeLines(
  summary_lines,
  SUMMARY_FILE,
  useBytes = TRUE
)

writeLines(
  capture.output(
    sessionInfo()
  ),
  SESSION_FILE,
  useBytes = TRUE
)

cat(
  paste(
    summary_lines,
    collapse = "\n"
  ),
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

log_msg("R1-06 completed successfully.")
log_msg("Summary to upload:", SUMMARY_FILE)

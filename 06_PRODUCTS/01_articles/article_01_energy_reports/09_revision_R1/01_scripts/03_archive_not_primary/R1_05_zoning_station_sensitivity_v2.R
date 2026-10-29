# ============================================================
# ENERGY REPORTS — REVISION R1
# R1_05_zoning_station_sensitivity_v2.R
#
# Manuscript: EGYR-D-26-02665
# Reviewer 3 — zoning / regionalization concern
#
# Objective:
# 1) Reconstruct the Article-1 zone-hour VV aggregation from the
#    restricted raw IDEAM source.
# 2) Verify it against the frozen pre-QC Article-1 candidate dataset.
# 3) Quantify station-level heterogeneity within each analytical zone.
# 4) Perform leave-one-station-out (LOSO) sensitivity of zonal mean WPD.
#
# Scientific interpretation:
# The zones are tested as analytical/geographical groupings, not assumed
# to be homogeneous altitude classes. LOSO analysis evaluates whether
# zonal conclusions are dominated by a single station.
#
# IMPORTANT:
# - Raw IDEAM data remain local and are NOT copied to the repository.
# - No original Article-1 output is overwritten.
# - Only derived summaries are written to 09_revision_R1.
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
    "One or more required local source files are missing:\n",
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
  "R1_05_zoning_station_sensitivity_log.txt"
)

SUMMARY_FILE <- file.path(
  DIR_RESULTS,
  "R1_05_UPLOAD_THIS_TO_CHAT.txt"
)

SESSION_FILE <- file.path(
  DIR_RESULTS,
  "R1_05_sessionInfo.txt"
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

log_msg("Starting R1-05 zoning/station sensitivity analysis.")
log_msg("Restricted raw source:", RAW_FILE)

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

# Frozen V1 checksum
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
# 5. Read restricted raw source
# ============================================================

log_msg("Reading raw IDEAM source. This is the slowest I/O step.")

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

log_msg("Raw rows read:", nrow(raw))

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

# Keep only VV immediately to reduce memory.
vv <- raw[
  toupper(trimws(as.character(Variable))) ==
    "VV",
  .(
    station = as.character(`Estación`),
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

log_msg("Raw VV rows retained before datetime restriction:", nrow(vv))
log_msg("Stations present:", uniqueN(vv$station))

# ============================================================
# 6. Correct DMY datetime parser
#    Mirrors the manual logic used by the Article-1 correction script.
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
    as.integer(parts[[1]])
  )

  mm <- suppressWarnings(
    as.integer(parts[[2]])
  )

  yy <- suppressWarnings(
    as.integer(parts[[3]])
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

  # Some IDEAM timestamps contain HH:MM only (no seconds).
  # In that case tstrsplit() may return only two components,
  # so seconds must be created explicitly instead of indexing
  # a non-existent third element.
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
      format =
        "%Y-%m-%d %H:%M:%S",
      tz = tz
    )
  )

  out
}

log_msg("Parsing VV datetimes using DMY correction logic.")

vv[
  ,
  datetime :=
    manual_parse_dmy(
      raw_datetime
    )
]

datetime_audit <- data.table(
  n_VV_rows_before_date_filter = nrow(vv),
  n_valid_datetime = sum(!is.na(vv$datetime)),
  pct_valid_datetime = 100 * mean(!is.na(vv$datetime)),
  min_datetime = as.character(min(vv$datetime, na.rm = TRUE)),
  max_datetime = as.character(max(vv$datetime, na.rm = TRUE))
)

log_msg(
  "Datetime parsing valid rows:",
  datetime_audit$n_valid_datetime,
  "of",
  datetime_audit$n_VV_rows_before_date_filter,
  paste0(
    "(",
    round(datetime_audit$pct_valid_datetime, 4),
    "%)"
  )
)

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

log_msg("VV rows inside study period:", nrow(vv))
log_msg("Stations inside study period:", uniqueN(vv$station))

# ============================================================
# 7. Sufficient statistics by station-zone-hour
#
# Original Article-1 zone-hour VV used the arithmetic mean of
# all raw records contributing to a zone-hour.
# ============================================================

station_hour_components <- vv[, .(
  sum_value = sum(
    value,
    na.rm = TRUE
  ),
  n_value = .N,
  station_hour_mean =
    mean(
      value,
      na.rm = TRUE
    )
), by = .(
  zone,
  station,
  datetime = datetime_hour
)]

# Physical sanity filter at station-hour level only for descriptive
# station summaries. This does NOT alter the reconstruction totals.
station_hour_for_summary <- station_hour_components[
  is.finite(station_hour_mean) &
    station_hour_mean >= 0 &
    station_hour_mean <= 75
]

zone_hour_totals <- station_hour_components[, .(
  sum_all =
    sum(sum_value),
  n_all =
    sum(n_value),
  n_stations_contributing =
    .N
), by = .(
  zone,
  datetime
)]

zone_hour_totals[
  ,
  VV_rebuilt :=
    sum_all /
    n_all
]

zone_hour_totals[
  VV_rebuilt < 0 |
    VV_rebuilt > 75,
  VV_rebuilt := NA_real_
]

# ============================================================
# 8. Validate rebuilt zone-hour VV against frozen candidate
# ============================================================

candidate_key <- candidate[, .(
  zone,
  datetime,
  VV_candidate = VV,
  rho_used
)]

if (
  candidate_key[
    ,
    anyDuplicated(
      paste(
        zone,
        datetime
      )
    )
  ] > 0
) {
  stop(
    "Candidate dataset is not unique by zone + datetime."
  )
}

validation <- merge(
  candidate_key,
  zone_hour_totals[
    ,
    .(
      zone,
      datetime,
      VV_rebuilt,
      n_all,
      n_stations_contributing
    )
  ],
  by = c(
    "zone",
    "datetime"
  ),
  all.x = TRUE
)

validation[
  ,
  abs_difference :=
    abs(
      VV_candidate -
        VV_rebuilt
    )
]

reconstruction_summary <- validation[, .(
  candidate_rows = .N,
  matched_rows =
    sum(is.finite(VV_rebuilt)),
  pct_matched =
    100 *
      mean(
        is.finite(VV_rebuilt)
      ),
  mean_abs_difference =
    mean(
      abs_difference,
      na.rm = TRUE
    ),
  median_abs_difference =
    median(
      abs_difference,
      na.rm = TRUE
    ),
  max_abs_difference =
    max(
      abs_difference,
      na.rm = TRUE
    )
), by = zone][order(zone)]

global_reconstruction <- validation[, .(
  candidate_rows = .N,
  matched_rows =
    sum(is.finite(VV_rebuilt)),
  pct_matched =
    100 *
      mean(
        is.finite(VV_rebuilt)
      ),
  mean_abs_difference =
    mean(
      abs_difference,
      na.rm = TRUE
    ),
  median_abs_difference =
    median(
      abs_difference,
      na.rm = TRUE
    ),
  max_abs_difference =
    max(
      abs_difference,
      na.rm = TRUE
    )
)]

log_msg("Zone-hour reconstruction audit completed.")

# Hard stop only for material mismatch.
if (
  global_reconstruction$pct_matched <
    99
) {
  stop(
    "Reconstruction matched fewer than 99% of candidate zone-hours."
  )
}

if (
  global_reconstruction$mean_abs_difference >
    1e-3
) {
  stop(
    paste0(
      "Zone-hour reconstruction differs materially from the ",
      "frozen candidate dataset (mean absolute difference > 1e-3)."
    )
  )
}

log_msg("Zone-hour reconstruction validation: PASSED.")

# ============================================================
# 9. Station-level descriptive heterogeneity
# ============================================================

zone_raw_counts <- vv[, .(
  zone_raw_VV_records = .N
), by = zone]

station_summary <- station_hour_for_summary[, .(
  n_station_hours = .N,
  n_observed_days =
    uniqueN(
      as.Date(
        datetime,
        tz = "America/Bogota"
      )
    ),
  mean_VV =
    mean(station_hour_mean),
  median_VV =
    median(station_hour_mean),
  sd_VV =
    sd(station_hour_mean),
  p05_VV =
    quantile(
      station_hour_mean,
      0.05,
      names = FALSE
    ),
  p25_VV =
    quantile(
      station_hour_mean,
      0.25,
      names = FALSE
    ),
  p75_VV =
    quantile(
      station_hour_mean,
      0.75,
      names = FALSE
    ),
  p95_VV =
    quantile(
      station_hour_mean,
      0.95,
      names = FALSE
    ),
  p99_VV =
    quantile(
      station_hour_mean,
      0.99,
      names = FALSE
    ),
  max_VV =
    max(station_hour_mean),
  pct_station_hours_gt_10 =
    100 *
      mean(
        station_hour_mean > 10
      ),
  pct_station_hours_gt_15 =
    100 *
      mean(
        station_hour_mean > 15
      )
), by = .(
  zone,
  station
)]

raw_station_counts <- vv[, .(
  n_raw_VV_records = .N
), by = .(
  zone,
  station
)]

station_summary <- merge(
  station_summary,
  raw_station_counts,
  by = c(
    "zone",
    "station"
  ),
  all.x = TRUE
)

station_summary <- merge(
  station_summary,
  zone_raw_counts,
  by = "zone",
  all.x = TRUE
)

station_summary[
  ,
  raw_record_share_within_zone_pct :=
    100 *
      n_raw_VV_records /
      zone_raw_VV_records
]

setorder(
  station_summary,
  zone,
  station
)

zone_station_heterogeneity <- station_summary[, .(
  n_stations = .N,
  min_station_mean_VV =
    min(mean_VV),
  max_station_mean_VV =
    max(mean_VV),
  range_station_mean_VV =
    max(mean_VV) -
    min(mean_VV),
  mean_of_station_mean_VV =
    mean(mean_VV),
  sd_of_station_mean_VV =
    sd(mean_VV),
  CV_station_mean_VV_pct =
    100 *
      sd(mean_VV) /
      mean(mean_VV),
  min_station_median_VV =
    min(median_VV),
  max_station_median_VV =
    max(median_VV),
  max_raw_record_share_pct =
    max(
      raw_record_share_within_zone_pct
    )
), by = zone][order(zone)]

# ============================================================
# 10. Leave-one-station-out sensitivity
#
# Uses the same frozen daily-zone rho values from the pre-QC
# candidate dataset. The only quantity perturbed is the zone-hour
# VV composition after removing one station.
# ============================================================

baseline_main <- main[, .(
  baseline_n = .N,
  baseline_mean_VV =
    mean(VV),
  baseline_median_VV =
    median(VV),
  baseline_mean_WPD =
    mean(WPD),
  baseline_median_WPD =
    median(WPD)
), by = zone]

loso_results <- list()
counter <- 1L

for (z in c("1", "2", "3", "4")) {

  stations_z <- sort(
    unique(
      station_summary[
        zone == z,
        station
      ]
    )
  )

  base_z <- merge(
    candidate_key[
      zone == z
    ],
    zone_hour_totals[
      zone == z,
      .(
        zone,
        datetime,
        sum_all,
        n_all,
        n_stations_contributing
      )
    ],
    by = c(
      "zone",
      "datetime"
    ),
    all.x = TRUE
  )

  for (s in stations_z) {

    contribution <- station_hour_components[
      zone == z &
        station == s,
      .(
        zone,
        datetime,
        station_sum =
          sum_value,
        station_n =
          n_value
      )
    ]

    temp <- merge(
      base_z,
      contribution,
      by = c(
        "zone",
        "datetime"
      ),
      all.x = TRUE
    )

    temp[
      is.na(station_sum),
      station_sum := 0
    ]

    temp[
      is.na(station_n),
      station_n := 0L
    ]

    temp[
      ,
      remaining_n :=
        n_all -
        station_n
    ]

    temp[
      ,
      VV_loso :=
        fifelse(
          remaining_n > 0,
          (
            sum_all -
              station_sum
          ) /
            remaining_n,
          NA_real_
        )
    ]

    # Same main Article-1 QC rule.
    temp[
      VV_loso < 0 |
        VV_loso > 20,
      VV_loso := NA_real_
    ]

    temp[
      ,
      WPD_loso :=
        0.5 *
        rho_used *
        VV_loso^3
    ]

    valid <- temp[
      is.finite(VV_loso) &
        is.finite(WPD_loso)
    ]

    loso_results[[counter]] <-
      data.table(
        zone = z,
        removed_station = s,
        n_candidate_hours =
          nrow(temp),
        n_valid_loso_hours =
          nrow(valid),
        pct_candidate_hours_retained =
          100 *
            nrow(valid) /
            nrow(temp),
        mean_VV_loso =
          mean(
            valid$VV_loso,
            na.rm = TRUE
          ),
        median_VV_loso =
          median(
            valid$VV_loso,
            na.rm = TRUE
          ),
        mean_WPD_loso =
          mean(
            valid$WPD_loso,
            na.rm = TRUE
          ),
        median_WPD_loso =
          median(
            valid$WPD_loso,
            na.rm = TRUE
          )
      )

    counter <- counter + 1L
  }
}

loso <- rbindlist(
  loso_results,
  fill = TRUE
)

loso <- merge(
  loso,
  baseline_main,
  by = "zone",
  all.x = TRUE
)

loso[
  ,
  `:=`(
    delta_mean_VV =
      mean_VV_loso -
      baseline_mean_VV,
    pct_change_mean_VV =
      100 *
      (
        mean_VV_loso -
          baseline_mean_VV
      ) /
      baseline_mean_VV,
    delta_mean_WPD =
      mean_WPD_loso -
      baseline_mean_WPD,
    pct_change_mean_WPD =
      100 *
      (
        mean_WPD_loso -
          baseline_mean_WPD
      ) /
      baseline_mean_WPD
  )
]

setorder(
  loso,
  zone,
  -abs(pct_change_mean_WPD)
)

loso_zone_summary <- loso[, .(
  n_stations_tested = .N,
  min_pct_change_mean_WPD =
    min(
      pct_change_mean_WPD,
      na.rm = TRUE
    ),
  max_pct_change_mean_WPD =
    max(
      pct_change_mean_WPD,
      na.rm = TRUE
    ),
  max_abs_pct_change_mean_WPD =
    max(
      abs(
        pct_change_mean_WPD
      ),
      na.rm = TRUE
    ),
  station_causing_max_abs_WPD_change =
    removed_station[
      which.max(
        abs(
          pct_change_mean_WPD
        )
      )
    ],
  min_pct_change_mean_VV =
    min(
      pct_change_mean_VV,
      na.rm = TRUE
    ),
  max_pct_change_mean_VV =
    max(
      pct_change_mean_VV,
      na.rm = TRUE
    ),
  max_abs_pct_change_mean_VV =
    max(
      abs(
        pct_change_mean_VV
      ),
      na.rm = TRUE
    ),
  min_hours_retained_pct =
    min(
      pct_candidate_hours_retained,
      na.rm = TRUE
    )
), by = zone][order(zone)]

# ============================================================
# 11. Save outputs
# ============================================================

write.xlsx(
  main_checksum,
  file.path(
    DIR_TABLES,
    "R1_05_V1_scientific_checksum.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  datetime_audit,
  file.path(
    DIR_TABLES,
    "R1_05_datetime_parser_audit.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  reconstruction_summary,
  file.path(
    DIR_TABLES,
    "R1_05_zone_hour_reconstruction_validation_by_zone.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  global_reconstruction,
  file.path(
    DIR_TABLES,
    "R1_05_zone_hour_reconstruction_validation_global.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  station_summary,
  file.path(
    DIR_TABLES,
    "R1_05_station_level_VV_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  zone_station_heterogeneity,
  file.path(
    DIR_TABLES,
    "R1_05_within_zone_station_heterogeneity.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  loso,
  file.path(
    DIR_TABLES,
    "R1_05_leave_one_station_out_WPD.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  loso_zone_summary,
  file.path(
    DIR_TABLES,
    "R1_05_LOSO_zone_summary.xlsx"
  ),
  overwrite = TRUE
)

saveRDS(
  list(
    V1_checksum =
      main_checksum,
    datetime_audit =
      datetime_audit,
    reconstruction_by_zone =
      reconstruction_summary,
    reconstruction_global =
      global_reconstruction,
    station_summary =
      station_summary,
    zone_station_heterogeneity =
      zone_station_heterogeneity,
    loso =
      loso,
    loso_zone_summary =
      loso_zone_summary
  ),
  file.path(
    DIR_RESULTS,
    "R1_05_zoning_station_sensitivity.rds"
  )
)

# ============================================================
# 12. Summary for ChatGPT
# ============================================================

summary_lines <- capture.output({

  cat("============================================================\n")
  cat("R1-05 ZONING / STATION SENSITIVITY — SUMMARY FOR CHATGPT\n")
  cat("============================================================\n")

  cat("\n============================================================\n")
  cat("V1 SCIENTIFIC CHECKSUM\n")
  cat("============================================================\n")
  print(main_checksum)

  cat("\n============================================================\n")
  cat("DATETIME PARSER AUDIT\n")
  cat("============================================================\n")
  print(datetime_audit)

  cat("\n============================================================\n")
  cat("ZONE-HOUR RECONSTRUCTION — GLOBAL\n")
  cat("============================================================\n")
  print(global_reconstruction)

  cat("\n============================================================\n")
  cat("ZONE-HOUR RECONSTRUCTION — BY ZONE\n")
  cat("============================================================\n")
  print(reconstruction_summary)

  cat("\n============================================================\n")
  cat("STATION-LEVEL VV SUMMARY\n")
  cat("============================================================\n")
  print(station_summary)

  cat("\n============================================================\n")
  cat("WITHIN-ZONE STATION HETEROGENEITY\n")
  cat("============================================================\n")
  print(zone_station_heterogeneity)

  cat("\n============================================================\n")
  cat("LEAVE-ONE-STATION-OUT RESULTS\n")
  cat("============================================================\n")
  print(
    loso[, .(
      zone,
      removed_station,
      pct_candidate_hours_retained,
      mean_VV_loso,
      pct_change_mean_VV,
      mean_WPD_loso,
      pct_change_mean_WPD
    )]
  )

  cat("\n============================================================\n")
  cat("LOSO ZONE SUMMARY\n")
  cat("============================================================\n")
  print(loso_zone_summary)

  cat("\n============================================================\n")
  cat("INTERPRETATION RULE\n")
  cat("============================================================\n")
  cat(
    "Analytical zones must not be described as altitude-homogeneous ",
    "classes unless independently supported. Station-level heterogeneity ",
    "and LOSO sensitivity quantify how strongly each zonal result depends ",
    "on station composition.\n",
    sep = ""
  )

  cat("\nR1-05 COMPLETED SUCCESSFULLY\n")
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

log_msg("R1-05 completed successfully.")
log_msg("Summary to upload:", SUMMARY_FILE)

# ============================================================
# 02E_quality_control_daily_density_wpd.R
# ARTICLE 1 — ENERGY REPORTS
# Quality control for daily-zone-density WPD dataset
# Author: Favio Nicolás Rosero Rodríguez
# ============================================================

rm(list = ls())
gc()

# ============================================================
# 1. Packages
# ============================================================

required_packages <- c(
  "data.table",
  "dplyr",
  "lubridate",
  "stringr",
  "ggplot2",
  "scales",
  "moments",
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
  library(dplyr)
  library(lubridate)
  library(stringr)
  library(ggplot2)
  library(scales)
  library(moments)
  library(openxlsx)
})

# ============================================================
# 2. Paths
# ============================================================

ARTICLE_ROOT <- "E:/Academia/UNAL/DOCTORADO/Productos/Articulo 1"

DIR_DATA_PROCESSED <- file.path(ARTICLE_ROOT, "01_data_processed")
DIR_RESULTS <- file.path(ARTICLE_ROOT, "02_results")
DIR_FIGURES <- file.path(ARTICLE_ROOT, "03_figures")
DIR_FIGURES_DRAFT <- file.path(DIR_FIGURES, "draft")
DIR_FIGURES_FINAL <- file.path(DIR_FIGURES, "final")
DIR_TABLES <- file.path(ARTICLE_ROOT, "04_tables")
DIR_LOGS <- file.path(ARTICLE_ROOT, "logs")

dirs <- c(
  DIR_DATA_PROCESSED,
  DIR_RESULTS,
  DIR_FIGURES,
  DIR_FIGURES_DRAFT,
  DIR_FIGURES_FINAL,
  DIR_TABLES,
  DIR_LOGS
)

invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))

log_file <- file.path(DIR_LOGS, "02E_quality_control_daily_density_wpd_log.txt")

log_msg <- function(...) {
  msg <- paste0(
    format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    " | ",
    paste(..., collapse = " ")
  )
  cat(msg, "\n")
  cat(msg, "\n", file = log_file, append = TRUE)
}

log_msg("Starting quality control for daily-zone-density WPD dataset.")

# ============================================================
# 3. Robust file detection
# ============================================================

find_existing_file <- function(candidates, recursive_pattern = NULL, search_dir = NULL) {
  existing <- candidates[file.exists(candidates)]
  
  if (length(existing) > 0) {
    return(existing[1])
  }
  
  if (!is.null(recursive_pattern) && !is.null(search_dir) && dir.exists(search_dir)) {
    found <- list.files(
      path = search_dir,
      pattern = recursive_pattern,
      recursive = TRUE,
      full.names = TRUE
    )
    
    if (length(found) > 0) {
      return(found[1])
    }
  }
  
  return(NA_character_)
}

INPUT_WPD <- find_existing_file(
  candidates = c(
    file.path(DIR_DATA_PROCESSED, "01D_final_wpd_candidate_dataset_corrected_datetime.rds")
  ),
  recursive_pattern = "01D_final_wpd_candidate_dataset_corrected_datetime\\.rds$",
  search_dir = ARTICLE_ROOT
)

possible_corrected_long_files <- c(
  file.path(DIR_DATA_PROCESSED, "00C_article_period_2017_2022_correct_datetime.rds"),
  file.path(DIR_DATA_PROCESSED, "00C_all_records_correct_datetime.rds"),
  file.path(DIR_DATA_PROCESSED, "00B_article_period_2017_2022_fixed_dmy_datetime.rds")
)

INPUT_CORRECTED_LONG <- find_existing_file(
  candidates = possible_corrected_long_files,
  recursive_pattern = "00C_article_period_2017_2022_correct_datetime\\.rds$|00C_all_records_correct_datetime\\.rds$|00B_article_period_2017_2022_fixed_dmy_datetime\\.rds$",
  search_dir = ARTICLE_ROOT
)

if (is.na(INPUT_WPD)) {
  stop(
    "Input WPD dataset not found. Run script 01D first: ",
    "01D_rebuild_overlap_after_correct_datetime.R"
  )
}

if (is.na(INPUT_CORRECTED_LONG)) {
  warning(
    "Corrected long dataset was not found. ",
    "The script will continue using only the WPD candidate dataset."
  )
}

log_msg("Input WPD dataset:", INPUT_WPD)

if (!is.na(INPUT_CORRECTED_LONG)) {
  log_msg("Corrected long dataset:", INPUT_CORRECTED_LONG)
} else {
  log_msg("Corrected long dataset: not found; station-level raw VV audit will be skipped.")
}

# ============================================================
# 4. Load datasets
# ============================================================

wpd <- readRDS(INPUT_WPD)
wpd <- as.data.table(wpd)

if (!is.na(INPUT_CORRECTED_LONG) && file.exists(INPUT_CORRECTED_LONG)) {
  dt_long <- readRDS(INPUT_CORRECTED_LONG)
  dt_long <- as.data.table(dt_long)
} else {
  dt_long <- NULL
}

# ============================================================
# 5. Standardize WPD dataset
# ============================================================

required_wpd_columns <- c("zone", "datetime", "VV", "rho_used", "WPD", "density_strategy")

missing_wpd_columns <- setdiff(required_wpd_columns, names(wpd))

if (length(missing_wpd_columns) > 0) {
  stop(
    "The WPD dataset is missing required columns: ",
    paste(missing_wpd_columns, collapse = ", ")
  )
}

wpd[, datetime := as.POSIXct(datetime, tz = "America/Bogota")]
wpd[, date := as.Date(datetime)]
wpd[, year := year(datetime)]
wpd[, month := month(datetime)]
wpd[, year_month := format(datetime, "%Y-%m")]
wpd[, zone := as.character(zone)]
wpd[, VV := suppressWarnings(as.numeric(VV))]
wpd[, rho_used := suppressWarnings(as.numeric(rho_used))]
wpd[, WPD := suppressWarnings(as.numeric(WPD))]

wpd <- wpd[
  !is.na(datetime) &
    !is.na(zone) &
    !is.na(VV) &
    !is.na(rho_used) &
    !is.na(WPD) &
    VV >= 0 &
    rho_used > 0 &
    WPD >= 0
]

log_msg("WPD dataset loaded and standardized.")
log_msg("Rows:", nrow(wpd))
log_msg("Zones:", uniqueN(wpd$zone))
log_msg("Min datetime:", as.character(min(wpd$datetime, na.rm = TRUE)))
log_msg("Max datetime:", as.character(max(wpd$datetime, na.rm = TRUE)))

# ============================================================
# 6. Confirm density strategy
# ============================================================

density_strategy_summary <- wpd[, .(
  n_records = .N,
  n_zones = uniqueN(zone),
  min_datetime = min(datetime, na.rm = TRUE),
  max_datetime = max(datetime, na.rm = TRUE),
  mean_rho_used = mean(rho_used, na.rm = TRUE),
  median_rho_used = median(rho_used, na.rm = TRUE),
  min_rho_used = min(rho_used, na.rm = TRUE),
  max_rho_used = max(rho_used, na.rm = TRUE)
), by = density_strategy][order(-n_records)]

write.xlsx(
  density_strategy_summary,
  file.path(DIR_TABLES, "02E_density_strategy_summary.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 7. Raw VV audit at station-record level
# ============================================================

if (!is.null(dt_long)) {
  
  required_long_columns <- c("zone", "station", "datetime", "variable_clean", "value")
  
  if (all(required_long_columns %in% names(dt_long))) {
    
    dt_long[, datetime := as.POSIXct(datetime, tz = "America/Bogota")]
    dt_long[, variable_clean := stringr::str_to_upper(variable_clean)]
    dt_long[, zone := as.character(zone)]
    dt_long[, station := as.character(station)]
    dt_long[, value := suppressWarnings(as.numeric(value))]
    dt_long[, year := year(datetime)]
    dt_long[, month := month(datetime)]
    dt_long[, year_month := format(datetime, "%Y-%m")]
    
    vv_raw <- dt_long[
      variable_clean == "VV" &
        !is.na(value) &
        value >= 0
    ]
    
    vv_raw_station_summary <- vv_raw[, .(
      n_records = .N,
      min_datetime = min(datetime, na.rm = TRUE),
      max_datetime = max(datetime, na.rm = TRUE),
      mean_VV = mean(value, na.rm = TRUE),
      median_VV = median(value, na.rm = TRUE),
      sd_VV = sd(value, na.rm = TRUE),
      min_VV = min(value, na.rm = TRUE),
      p95_VV = quantile(value, 0.95, na.rm = TRUE),
      p99_VV = quantile(value, 0.99, na.rm = TRUE),
      p999_VV = quantile(value, 0.999, na.rm = TRUE),
      max_VV = max(value, na.rm = TRUE),
      n_VV_gt_20 = sum(value > 20, na.rm = TRUE),
      pct_VV_gt_20 = round(100 * mean(value > 20, na.rm = TRUE), 5),
      n_VV_gt_25 = sum(value > 25, na.rm = TRUE),
      pct_VV_gt_25 = round(100 * mean(value > 25, na.rm = TRUE), 5),
      n_VV_gt_30 = sum(value > 30, na.rm = TRUE),
      pct_VV_gt_30 = round(100 * mean(value > 30, na.rm = TRUE), 5)
    ), by = .(
      zone,
      station
    )][order(zone, -max_VV)]
    
    write.xlsx(
      vv_raw_station_summary,
      file.path(DIR_TABLES, "02E_raw_vv_quality_summary_by_station.xlsx"),
      overwrite = TRUE
    )
    
    vv_raw_zone_summary <- vv_raw[, .(
      n_records = .N,
      n_stations = uniqueN(station),
      min_datetime = min(datetime, na.rm = TRUE),
      max_datetime = max(datetime, na.rm = TRUE),
      mean_VV = mean(value, na.rm = TRUE),
      median_VV = median(value, na.rm = TRUE),
      sd_VV = sd(value, na.rm = TRUE),
      min_VV = min(value, na.rm = TRUE),
      p95_VV = quantile(value, 0.95, na.rm = TRUE),
      p99_VV = quantile(value, 0.99, na.rm = TRUE),
      p999_VV = quantile(value, 0.999, na.rm = TRUE),
      max_VV = max(value, na.rm = TRUE),
      n_VV_gt_20 = sum(value > 20, na.rm = TRUE),
      pct_VV_gt_20 = round(100 * mean(value > 20, na.rm = TRUE), 5),
      n_VV_gt_25 = sum(value > 25, na.rm = TRUE),
      pct_VV_gt_25 = round(100 * mean(value > 25, na.rm = TRUE), 5),
      n_VV_gt_30 = sum(value > 30, na.rm = TRUE),
      pct_VV_gt_30 = round(100 * mean(value > 30, na.rm = TRUE), 5)
    ), by = zone][order(zone)]
    
    write.xlsx(
      vv_raw_zone_summary,
      file.path(DIR_TABLES, "02E_raw_vv_quality_summary_by_zone.xlsx"),
      overwrite = TRUE
    )
    
    top_raw_vv_records <- vv_raw[
      order(-value)
    ][1:min(.N, 500)]
    
    write.xlsx(
      top_raw_vv_records,
      file.path(DIR_TABLES, "02E_top_raw_vv_extreme_records.xlsx"),
      overwrite = TRUE
    )
    
  } else {
    
    vv_raw_station_summary <- data.table(
      note = paste0(
        "Corrected long dataset was found but does not contain all required columns: ",
        paste(required_long_columns, collapse = ", ")
      )
    )
    
    vv_raw_zone_summary <- data.table(
      note = "Raw VV audit skipped because required columns were missing."
    )
    
    top_raw_vv_records <- data.table(
      note = "Raw VV extreme records were not exported."
    )
    
    write.xlsx(
      vv_raw_zone_summary,
      file.path(DIR_TABLES, "02E_raw_vv_quality_summary_by_zone.xlsx"),
      overwrite = TRUE
    )
  }
  
} else {
  
  vv_raw_station_summary <- data.table(
    note = "Corrected long dataset not found. Raw station-level VV audit was skipped."
  )
  
  vv_raw_zone_summary <- data.table(
    note = "Corrected long dataset not found. Raw zone-level VV audit was skipped."
  )
  
  top_raw_vv_records <- data.table(
    note = "Corrected long dataset not found. Extreme raw VV records were not exported."
  )
  
  write.xlsx(
    vv_raw_zone_summary,
    file.path(DIR_TABLES, "02E_raw_vv_quality_summary_by_zone.xlsx"),
    overwrite = TRUE
  )
}

# ============================================================
# 8. Zone-hour WPD dataset audit
# ============================================================

wpd_general_summary <- wpd[, .(
  n_records = .N,
  n_zones = uniqueN(zone),
  min_datetime = min(datetime, na.rm = TRUE),
  max_datetime = max(datetime, na.rm = TRUE),
  
  mean_VV = mean(VV, na.rm = TRUE),
  median_VV = median(VV, na.rm = TRUE),
  sd_VV = sd(VV, na.rm = TRUE),
  min_VV = min(VV, na.rm = TRUE),
  p95_VV = quantile(VV, 0.95, na.rm = TRUE),
  p99_VV = quantile(VV, 0.99, na.rm = TRUE),
  p999_VV = quantile(VV, 0.999, na.rm = TRUE),
  max_VV = max(VV, na.rm = TRUE),
  
  mean_rho_used = mean(rho_used, na.rm = TRUE),
  median_rho_used = median(rho_used, na.rm = TRUE),
  min_rho_used = min(rho_used, na.rm = TRUE),
  max_rho_used = max(rho_used, na.rm = TRUE),
  
  mean_WPD = mean(WPD, na.rm = TRUE),
  median_WPD = median(WPD, na.rm = TRUE),
  sd_WPD = sd(WPD, na.rm = TRUE),
  p25_WPD = quantile(WPD, 0.25, na.rm = TRUE),
  p75_WPD = quantile(WPD, 0.75, na.rm = TRUE),
  p95_WPD = quantile(WPD, 0.95, na.rm = TRUE),
  p99_WPD = quantile(WPD, 0.99, na.rm = TRUE),
  p999_WPD = quantile(WPD, 0.999, na.rm = TRUE),
  max_WPD = max(WPD, na.rm = TRUE),
  
  skewness_WPD = moments::skewness(WPD, na.rm = TRUE),
  kurtosis_WPD = moments::kurtosis(WPD, na.rm = TRUE),
  
  n_VV_gt_20 = sum(VV > 20, na.rm = TRUE),
  pct_VV_gt_20 = round(100 * mean(VV > 20, na.rm = TRUE), 5),
  n_VV_gt_25 = sum(VV > 25, na.rm = TRUE),
  pct_VV_gt_25 = round(100 * mean(VV > 25, na.rm = TRUE), 5),
  n_VV_gt_30 = sum(VV > 30, na.rm = TRUE),
  pct_VV_gt_30 = round(100 * mean(VV > 30, na.rm = TRUE), 5),
  
  n_WPD_gt_5000 = sum(WPD > 5000, na.rm = TRUE),
  pct_WPD_gt_5000 = round(100 * mean(WPD > 5000, na.rm = TRUE), 5)
)]

write.xlsx(
  wpd_general_summary,
  file.path(DIR_TABLES, "02E_wpd_general_quality_summary.xlsx"),
  overwrite = TRUE
)

wpd_zone_summary_raw <- wpd[, .(
  n_records = .N,
  
  mean_VV = mean(VV, na.rm = TRUE),
  median_VV = median(VV, na.rm = TRUE),
  sd_VV = sd(VV, na.rm = TRUE),
  min_VV = min(VV, na.rm = TRUE),
  p95_VV = quantile(VV, 0.95, na.rm = TRUE),
  p99_VV = quantile(VV, 0.99, na.rm = TRUE),
  p999_VV = quantile(VV, 0.999, na.rm = TRUE),
  max_VV = max(VV, na.rm = TRUE),
  
  mean_rho_used = mean(rho_used, na.rm = TRUE),
  median_rho_used = median(rho_used, na.rm = TRUE),
  
  mean_WPD = mean(WPD, na.rm = TRUE),
  median_WPD = median(WPD, na.rm = TRUE),
  sd_WPD = sd(WPD, na.rm = TRUE),
  p25_WPD = quantile(WPD, 0.25, na.rm = TRUE),
  p75_WPD = quantile(WPD, 0.75, na.rm = TRUE),
  p95_WPD = quantile(WPD, 0.95, na.rm = TRUE),
  p99_WPD = quantile(WPD, 0.99, na.rm = TRUE),
  p999_WPD = quantile(WPD, 0.999, na.rm = TRUE),
  max_WPD = max(WPD, na.rm = TRUE),
  
  skewness_WPD = moments::skewness(WPD, na.rm = TRUE),
  kurtosis_WPD = moments::kurtosis(WPD, na.rm = TRUE),
  
  n_VV_gt_20 = sum(VV > 20, na.rm = TRUE),
  pct_VV_gt_20 = round(100 * mean(VV > 20, na.rm = TRUE), 5),
  n_VV_gt_25 = sum(VV > 25, na.rm = TRUE),
  pct_VV_gt_25 = round(100 * mean(VV > 25, na.rm = TRUE), 5),
  n_VV_gt_30 = sum(VV > 30, na.rm = TRUE),
  pct_VV_gt_30 = round(100 * mean(VV > 30, na.rm = TRUE), 5),
  
  n_WPD_gt_5000 = sum(WPD > 5000, na.rm = TRUE),
  pct_WPD_gt_5000 = round(100 * mean(WPD > 5000, na.rm = TRUE), 5)
), by = zone][order(zone)]

write.xlsx(
  wpd_zone_summary_raw,
  file.path(DIR_TABLES, "02E_wpd_raw_summary_by_zone.xlsx"),
  overwrite = TRUE
)

top_wpd_records <- wpd[
  order(-WPD)
][1:min(.N, 500)]

write.xlsx(
  top_wpd_records,
  file.path(DIR_TABLES, "02E_top_wpd_extreme_records.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 9. QC scenarios
# ============================================================

qc_scenarios <- data.table(
  qc_scenario = c(
    "raw_daily_zone_rho",
    "qc_vv_le_30",
    "qc_vv_le_25",
    "qc_vv_le_20",
    "qc_wpd_le_5000",
    "qc_vv_le_25_and_wpd_le_5000"
  ),
  vv_upper_bound = c(
    Inf,
    30,
    25,
    20,
    Inf,
    25
  ),
  wpd_upper_bound = c(
    Inf,
    Inf,
    Inf,
    Inf,
    5000,
    5000
  ),
  interpretation = c(
    "Raw daily-zone-density WPD dataset without additional upper screening.",
    "Dataset excluding zone-hour wind-speed values above 30 m s^-1.",
    "Dataset excluding zone-hour wind-speed values above 25 m s^-1.",
    "Dataset excluding zone-hour wind-speed values above 20 m s^-1.",
    "Dataset excluding WPD values above 5000 W m^-2.",
    "Dataset excluding wind-speed values above 25 m s^-1 and WPD values above 5000 W m^-2."
  )
)

build_qc_dataset <- function(data, scenario_row) {
  
  scenario_name <- scenario_row$qc_scenario
  vv_upper <- scenario_row$vv_upper_bound
  wpd_upper <- scenario_row$wpd_upper_bound
  interpretation <- scenario_row$interpretation
  
  out <- copy(data)
  
  out <- out[
    !is.na(VV) &
      !is.na(rho_used) &
      !is.na(WPD) &
      VV >= 0 &
      WPD >= 0 &
      VV <= vv_upper &
      WPD <= wpd_upper
  ]
  
  out[, qc_scenario := scenario_name]
  out[, vv_upper_bound := vv_upper]
  out[, wpd_upper_bound := wpd_upper]
  out[, qc_interpretation := interpretation]
  
  return(out)
}

wpd_qc_all <- rbindlist(
  lapply(seq_len(nrow(qc_scenarios)), function(i) {
    build_qc_dataset(wpd, qc_scenarios[i])
  }),
  fill = TRUE
)

saveRDS(
  wpd_qc_all,
  file.path(DIR_DATA_PROCESSED, "02E_wpd_qc_scenarios_daily_zone_density.rds")
)

fwrite(
  wpd_qc_all,
  file.path(DIR_DATA_PROCESSED, "02E_wpd_qc_scenarios_daily_zone_density.csv"),
  sep = ",",
  bom = TRUE
)

# ============================================================
# 10. QC scenario summaries
# ============================================================

original_by_zone <- wpd[, .(
  n_original_records = .N
), by = zone]

qc_summary_by_zone <- wpd_qc_all[, .(
  n_records = .N,
  
  mean_VV = mean(VV, na.rm = TRUE),
  median_VV = median(VV, na.rm = TRUE),
  sd_VV = sd(VV, na.rm = TRUE),
  min_VV = min(VV, na.rm = TRUE),
  p95_VV = quantile(VV, 0.95, na.rm = TRUE),
  p99_VV = quantile(VV, 0.99, na.rm = TRUE),
  max_VV = max(VV, na.rm = TRUE),
  
  mean_rho_used = mean(rho_used, na.rm = TRUE),
  median_rho_used = median(rho_used, na.rm = TRUE),
  
  mean_WPD = mean(WPD, na.rm = TRUE),
  median_WPD = median(WPD, na.rm = TRUE),
  sd_WPD = sd(WPD, na.rm = TRUE),
  p25_WPD = quantile(WPD, 0.25, na.rm = TRUE),
  p75_WPD = quantile(WPD, 0.75, na.rm = TRUE),
  p95_WPD = quantile(WPD, 0.95, na.rm = TRUE),
  p99_WPD = quantile(WPD, 0.99, na.rm = TRUE),
  max_WPD = max(WPD, na.rm = TRUE),
  
  skewness_WPD = moments::skewness(WPD, na.rm = TRUE),
  kurtosis_WPD = moments::kurtosis(WPD, na.rm = TRUE),
  
  n_VV_gt_20 = sum(VV > 20, na.rm = TRUE),
  pct_VV_gt_20 = round(100 * mean(VV > 20, na.rm = TRUE), 5),
  n_VV_gt_25 = sum(VV > 25, na.rm = TRUE),
  pct_VV_gt_25 = round(100 * mean(VV > 25, na.rm = TRUE), 5),
  n_VV_gt_30 = sum(VV > 30, na.rm = TRUE),
  pct_VV_gt_30 = round(100 * mean(VV > 30, na.rm = TRUE), 5),
  
  n_WPD_gt_5000 = sum(WPD > 5000, na.rm = TRUE),
  pct_WPD_gt_5000 = round(100 * mean(WPD > 5000, na.rm = TRUE), 5)
), by = .(
  qc_scenario,
  vv_upper_bound,
  wpd_upper_bound,
  qc_interpretation,
  zone
)]

qc_summary_by_zone <- merge(
  qc_summary_by_zone,
  original_by_zone,
  by = "zone",
  all.x = TRUE
)

qc_summary_by_zone[, retention_pct := round(
  100 * n_records / n_original_records,
  5
)]

qc_summary_by_zone <- qc_summary_by_zone[
  order(qc_scenario, zone)
]

write.xlsx(
  qc_summary_by_zone,
  file.path(DIR_TABLES, "02E_qc_strategy_comparison_by_zone.xlsx"),
  overwrite = TRUE
)

original_overall_n <- nrow(wpd)

qc_summary_overall <- wpd_qc_all[, .(
  n_records = .N,
  n_zones = uniqueN(zone),
  
  mean_VV = mean(VV, na.rm = TRUE),
  median_VV = median(VV, na.rm = TRUE),
  sd_VV = sd(VV, na.rm = TRUE),
  max_VV = max(VV, na.rm = TRUE),
  
  mean_rho_used = mean(rho_used, na.rm = TRUE),
  median_rho_used = median(rho_used, na.rm = TRUE),
  
  mean_WPD = mean(WPD, na.rm = TRUE),
  median_WPD = median(WPD, na.rm = TRUE),
  sd_WPD = sd(WPD, na.rm = TRUE),
  p95_WPD = quantile(WPD, 0.95, na.rm = TRUE),
  p99_WPD = quantile(WPD, 0.99, na.rm = TRUE),
  max_WPD = max(WPD, na.rm = TRUE),
  
  n_WPD_gt_5000 = sum(WPD > 5000, na.rm = TRUE),
  pct_WPD_gt_5000 = round(100 * mean(WPD > 5000, na.rm = TRUE), 5)
), by = .(
  qc_scenario,
  vv_upper_bound,
  wpd_upper_bound,
  qc_interpretation
)]

qc_summary_overall[, original_records := original_overall_n]

qc_summary_overall[, retention_pct := round(
  100 * n_records / original_records,
  5
)]

qc_summary_overall <- qc_summary_overall[
  order(qc_scenario)
]

write.xlsx(
  qc_summary_overall,
  file.path(DIR_TABLES, "02E_qc_strategy_comparison_overall.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 11. Automatic working recommendation
# ============================================================

get_overall <- function(scenario_name) {
  qc_summary_overall[qc_scenario == scenario_name]
}

raw_overall <- get_overall("raw_daily_zone_rho")
qc20_overall <- get_overall("qc_vv_le_20")
qc25_overall <- get_overall("qc_vv_le_25")
qc30_overall <- get_overall("qc_vv_le_30")
wpd5000_overall <- get_overall("qc_wpd_le_5000")

recommended_qc_scenario <- "raw_daily_zone_rho"

recommendation_reason <- paste0(
  "Raw daily-zone-density dataset retained; extreme records should be discussed ",
  "as part of distributional asymmetry."
)

if (nrow(raw_overall) > 0 && raw_overall$pct_WPD_gt_5000 > 0.1) {
  
  if (nrow(qc20_overall) > 0 && qc20_overall$retention_pct >= 99) {
    
    recommended_qc_scenario <- "qc_vv_le_20"
    
    recommendation_reason <- paste0(
      "The raw dataset contains a non-negligible fraction of very high WPD values. ",
      "The VV <= 20 m s^-1 scenario retains at least 99% of records while reducing cubic distortion."
    )
    
  } else if (nrow(qc25_overall) > 0 && qc25_overall$retention_pct >= 99) {
    
    recommended_qc_scenario <- "qc_vv_le_25"
    
    recommendation_reason <- paste0(
      "The VV <= 25 m s^-1 scenario retains at least 99% of records and reduces ",
      "the influence of extreme cubic WPD values."
    )
    
  } else if (nrow(qc30_overall) > 0 && qc30_overall$retention_pct >= 99) {
    
    recommended_qc_scenario <- "qc_vv_le_30"
    
    recommendation_reason <- paste0(
      "The VV <= 30 m s^-1 scenario retains at least 99% of records and removes ",
      "the most extreme wind-speed values."
    )
    
  } else {
    
    recommended_qc_scenario <- "qc_wpd_le_5000"
    
    recommendation_reason <- paste0(
      "The WPD <= 5000 W m^-2 scenario is recommended as a conservative ",
      "energy-domain screening."
    )
  }
}

recommended_row <- qc_summary_overall[
  qc_scenario == recommended_qc_scenario
]

recommended_qc_decision <- data.frame(
  decision_item = c(
    "main_density_strategy",
    "recommended_working_qc_scenario",
    "recommendation_reason",
    "raw_records",
    "recommended_records",
    "recommended_retention_pct",
    "recommended_mean_WPD",
    "recommended_median_WPD",
    "recommended_max_WPD",
    "article_position"
  ),
  value = c(
    unique(wpd$density_strategy)[1],
    recommended_qc_scenario,
    recommendation_reason,
    original_overall_n,
    recommended_row$n_records,
    recommended_row$retention_pct,
    round(recommended_row$mean_WPD, 6),
    round(recommended_row$median_WPD, 6),
    round(recommended_row$max_WPD, 6),
    "Use the recommended QC-screened dataset as the main descriptive basis and report raw/QC sensitivity as methodological control."
  )
)

write.xlsx(
  recommended_qc_decision,
  file.path(DIR_TABLES, "02E_recommended_qc_decision.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 12. Save main working dataset
# ============================================================

wpd_main <- wpd_qc_all[
  qc_scenario == recommended_qc_scenario
]

wpd_main[, article_dataset_role := "main_working_dataset_after_qc"]

saveRDS(
  wpd_main,
  file.path(DIR_DATA_PROCESSED, "02E_article_main_wpd_dataset_after_qc.rds")
)

fwrite(
  wpd_main,
  file.path(DIR_DATA_PROCESSED, "02E_article_main_wpd_dataset_after_qc.csv"),
  sep = ",",
  bom = TRUE
)

wpd_main_summary_by_zone <- wpd_main[, .(
  n_records = .N,
  
  mean_VV = mean(VV, na.rm = TRUE),
  median_VV = median(VV, na.rm = TRUE),
  sd_VV = sd(VV, na.rm = TRUE),
  min_VV = min(VV, na.rm = TRUE),
  p95_VV = quantile(VV, 0.95, na.rm = TRUE),
  p99_VV = quantile(VV, 0.99, na.rm = TRUE),
  max_VV = max(VV, na.rm = TRUE),
  
  mean_rho_used = mean(rho_used, na.rm = TRUE),
  median_rho_used = median(rho_used, na.rm = TRUE),
  
  mean_WPD = mean(WPD, na.rm = TRUE),
  median_WPD = median(WPD, na.rm = TRUE),
  sd_WPD = sd(WPD, na.rm = TRUE),
  p25_WPD = quantile(WPD, 0.25, na.rm = TRUE),
  p75_WPD = quantile(WPD, 0.75, na.rm = TRUE),
  p95_WPD = quantile(WPD, 0.95, na.rm = TRUE),
  p99_WPD = quantile(WPD, 0.99, na.rm = TRUE),
  max_WPD = max(WPD, na.rm = TRUE)
), by = zone][order(zone)]

write.xlsx(
  wpd_main_summary_by_zone,
  file.path(DIR_TABLES, "02E_article_main_wpd_summary_by_zone.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 13. Monthly summaries for article figures
# ============================================================

monthly_wpd_main <- wpd_main[, .(
  n_records = .N,
  mean_VV = mean(VV, na.rm = TRUE),
  median_VV = median(VV, na.rm = TRUE),
  mean_rho_used = mean(rho_used, na.rm = TRUE),
  mean_WPD = mean(WPD, na.rm = TRUE),
  median_WPD = median(WPD, na.rm = TRUE),
  p95_WPD = quantile(WPD, 0.95, na.rm = TRUE)
), by = .(
  zone,
  year_month
)][order(zone, year_month)]

monthly_wpd_main[, date_month := as.Date(paste0(year_month, "-01"))]

write.xlsx(
  monthly_wpd_main,
  file.path(DIR_TABLES, "02E_monthly_wpd_summary_main_dataset.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 14. Article plot theme
# ============================================================

article_theme <- theme_classic(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 11),
    axis.title = element_text(face = "bold", size = 12),
    axis.text = element_text(color = "black", size = 11),
    axis.line = element_line(color = "black", linewidth = 0.4),
    axis.ticks = element_line(color = "black", linewidth = 0.4),
    panel.grid.major.y = element_line(color = "grey88", linewidth = 0.25),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold"),
    plot.margin = margin(10, 10, 10, 10),
    plot.background = element_rect(fill = "white", color = NA)
  )

save_article_plot <- function(plot_object, filename, width = 7.5, height = 5.2) {
  
  out_path <- file.path(DIR_FIGURES_DRAFT, filename)
  
  ggsave(
    filename = out_path,
    plot = plot_object,
    width = width,
    height = height,
    dpi = 520,
    units = "in",
    bg = "white",
    limitsize = FALSE
  )
  
  log_msg("Figure exported:", out_path)
}

# ============================================================
# 15. Draft article figures
# ============================================================

fig_qc_effect <- ggplot(
  qc_summary_by_zone,
  aes(
    x = factor(zone),
    y = mean_WPD,
    group = qc_scenario,
    linetype = qc_scenario,
    shape = qc_scenario
  )
) +
  geom_line(linewidth = 0.6) +
  geom_point(size = 2.4) +
  scale_y_continuous(
    trans = scales::pseudo_log_trans(base = 10, sigma = 1),
    labels = scales::label_number(accuracy = 0.1)
  ) +
  labs(
    title = "Effect of quality-control criteria on mean WPD",
    subtitle = "Daily zone-level air density strategy",
    x = "Analytical zone",
    y = expression("Mean WPD (W m"^-2*")"),
    linetype = "QC scenario",
    shape = "QC scenario"
  ) +
  article_theme

save_article_plot(
  fig_qc_effect,
  "Fig_QC_effect_of_quality_control_on_mean_WPD.png",
  width = 8.5,
  height = 5.5
)

fig_vv_distribution <- ggplot(
  wpd_main,
  aes(x = factor(zone), y = VV)
) +
  geom_violin(trim = TRUE, alpha = 0.35, linewidth = 0.3) +
  geom_boxplot(width = 0.18, outlier.alpha = 0.15, linewidth = 0.35) +
  labs(
    title = "Wind-speed distribution by analytical zone",
    subtitle = paste0("Main QC scenario: ", recommended_qc_scenario),
    x = "Analytical zone",
    y = expression("Wind speed, " * V[V] * " (m s"^-1*")")
  ) +
  article_theme

save_article_plot(
  fig_vv_distribution,
  "Fig_01_wind_speed_distribution_by_zone_main_QC.png"
)

fig_wpd_distribution <- ggplot(
  wpd_main,
  aes(x = factor(zone), y = WPD)
) +
  geom_violin(trim = TRUE, alpha = 0.35, linewidth = 0.3) +
  geom_boxplot(width = 0.18, outlier.alpha = 0.12, linewidth = 0.35) +
  scale_y_continuous(
    trans = scales::pseudo_log_trans(base = 10, sigma = 1),
    labels = scales::label_number(accuracy = 0.1)
  ) +
  labs(
    title = "Wind power density distribution by analytical zone",
    subtitle = "WPD calculated using daily zone-level air density",
    x = "Analytical zone",
    y = expression("WPD (W m"^-2*")")
  ) +
  article_theme

save_article_plot(
  fig_wpd_distribution,
  "Fig_02_WPD_distribution_by_zone_main_QC.png"
)

fig_monthly_vv <- ggplot(
  monthly_wpd_main,
  aes(x = date_month, y = mean_VV, group = factor(zone))
) +
  geom_line(linewidth = 0.45) +
  facet_wrap(~ zone, ncol = 2, scales = "free_y") +
  labs(
    title = "Monthly mean wind speed by analytical zone",
    subtitle = paste0("Main QC scenario: ", recommended_qc_scenario),
    x = "Month",
    y = expression("Monthly mean " * V[V] * " (m s"^-1*")")
  ) +
  article_theme +
  theme(legend.position = "none")

save_article_plot(
  fig_monthly_vv,
  "Fig_03_monthly_mean_wind_speed_by_zone.png",
  width = 8.5,
  height = 6.0
)

fig_monthly_wpd <- ggplot(
  monthly_wpd_main,
  aes(x = date_month, y = mean_WPD, group = factor(zone))
) +
  geom_line(linewidth = 0.45) +
  facet_wrap(~ zone, ncol = 2, scales = "free_y") +
  scale_y_continuous(
    trans = scales::pseudo_log_trans(base = 10, sigma = 1),
    labels = scales::label_number(accuracy = 0.1)
  ) +
  labs(
    title = "Monthly mean wind power density by analytical zone",
    subtitle = "Daily zone-level air density strategy",
    x = "Month",
    y = expression("Monthly mean WPD (W m"^-2*")")
  ) +
  article_theme +
  theme(legend.position = "none")

save_article_plot(
  fig_monthly_wpd,
  "Fig_04_monthly_mean_WPD_by_zone.png",
  width = 8.5,
  height = 6.0
)

# ============================================================
# 16. Draft captions
# ============================================================

captions <- data.frame(
  figure_id = c(
    "QC Figure",
    "Figure 1",
    "Figure 2",
    "Figure 3",
    "Figure 4"
  ),
  filename = c(
    "Fig_QC_effect_of_quality_control_on_mean_WPD.png",
    "Fig_01_wind_speed_distribution_by_zone_main_QC.png",
    "Fig_02_WPD_distribution_by_zone_main_QC.png",
    "Fig_03_monthly_mean_wind_speed_by_zone.png",
    "Fig_04_monthly_mean_WPD_by_zone.png"
  ),
  draft_caption = c(
    "Effect of alternative quality-control criteria on mean wind power density by analytical zone. The comparison supports the selection of the main working dataset.",
    "Distribution of observed wind speed by analytical zone after applying the main quality-control criterion.",
    "Distribution of wind power density by analytical zone. WPD was calculated using daily zone-level air density derived from pressure and temperature records.",
    "Monthly mean wind speed by analytical zone for the main quality-controlled dataset.",
    "Monthly mean wind power density by analytical zone using the daily zone-level air density strategy."
  )
)

write.xlsx(
  captions,
  file.path(DIR_TABLES, "02E_draft_figure_captions.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 17. Save compact QC object
# ============================================================

qc_object <- list(
  input_wpd = INPUT_WPD,
  input_corrected_long = INPUT_CORRECTED_LONG,
  density_strategy_summary = density_strategy_summary,
  vv_raw_station_summary = vv_raw_station_summary,
  vv_raw_zone_summary = vv_raw_zone_summary,
  top_raw_vv_records = top_raw_vv_records,
  wpd_general_summary = wpd_general_summary,
  wpd_zone_summary_raw = wpd_zone_summary_raw,
  top_wpd_records = top_wpd_records,
  qc_scenarios = qc_scenarios,
  qc_summary_by_zone = qc_summary_by_zone,
  qc_summary_overall = qc_summary_overall,
  recommended_qc_decision = recommended_qc_decision,
  wpd_main_summary_by_zone = wpd_main_summary_by_zone,
  monthly_wpd_main = monthly_wpd_main,
  captions = captions
)

saveRDS(
  qc_object,
  file.path(DIR_RESULTS, "02E_quality_control_daily_density_wpd.rds")
)

# ============================================================
# 18. Console report
# ============================================================

cat("\n============================================================\n")
cat("QUALITY CONTROL — DAILY-ZONE-DENSITY WPD DATASET\n")
cat("============================================================\n\n")

cat("Input WPD dataset:\n")
cat(INPUT_WPD, "\n\n")

cat("Input corrected long dataset:\n")
cat(ifelse(is.na(INPUT_CORRECTED_LONG), "Not found; raw VV audit skipped.", INPUT_CORRECTED_LONG), "\n\n")

cat("Density strategy summary:\n")
print(density_strategy_summary)

cat("\nRaw VV quality summary by zone:\n")
print(vv_raw_zone_summary)

cat("\nZone-hour WPD raw summary by zone:\n")
print(wpd_zone_summary_raw)

cat("\nQC strategy comparison overall:\n")
print(qc_summary_overall)

cat("\nQC strategy comparison by zone:\n")
print(qc_summary_by_zone)

cat("\nRecommended QC decision:\n")
print(recommended_qc_decision)

cat("\nMain WPD summary by zone after QC:\n")
print(wpd_main_summary_by_zone)

cat("\nDraft figures exported to:\n")
cat(DIR_FIGURES_DRAFT, "\n\n")

cat("Key exported files:\n")
cat("- 04_tables/02E_density_strategy_summary.xlsx\n")
cat("- 04_tables/02E_raw_vv_quality_summary_by_zone.xlsx\n")
cat("- 04_tables/02E_raw_vv_quality_summary_by_station.xlsx, if corrected long dataset is available\n")
cat("- 04_tables/02E_top_raw_vv_extreme_records.xlsx, if corrected long dataset is available\n")
cat("- 04_tables/02E_wpd_general_quality_summary.xlsx\n")
cat("- 04_tables/02E_wpd_raw_summary_by_zone.xlsx\n")
cat("- 04_tables/02E_top_wpd_extreme_records.xlsx\n")
cat("- 04_tables/02E_qc_strategy_comparison_by_zone.xlsx\n")
cat("- 04_tables/02E_qc_strategy_comparison_overall.xlsx\n")
cat("- 04_tables/02E_recommended_qc_decision.xlsx\n")
cat("- 04_tables/02E_article_main_wpd_summary_by_zone.xlsx\n")
cat("- 04_tables/02E_monthly_wpd_summary_main_dataset.xlsx\n")
cat("- 04_tables/02E_draft_figure_captions.xlsx\n")
cat("- 01_data_processed/02E_wpd_qc_scenarios_daily_zone_density.rds\n")
cat("- 01_data_processed/02E_article_main_wpd_dataset_after_qc.rds\n")
cat("- 03_figures/draft/Fig_QC_effect_of_quality_control_on_mean_WPD.png\n")
cat("- 03_figures/draft/Fig_01_wind_speed_distribution_by_zone_main_QC.png\n")
cat("- 03_figures/draft/Fig_02_WPD_distribution_by_zone_main_QC.png\n")
cat("- 03_figures/draft/Fig_03_monthly_mean_wind_speed_by_zone.png\n")
cat("- 03_figures/draft/Fig_04_monthly_mean_WPD_by_zone.png\n")
cat("- 02_results/02E_quality_control_daily_density_wpd.rds\n")
cat("============================================================\n")

log_msg("Quality control for daily-zone-density WPD dataset completed successfully.")

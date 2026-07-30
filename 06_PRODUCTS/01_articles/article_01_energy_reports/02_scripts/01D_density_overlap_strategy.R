# ============================================================
# 01D_rebuild_overlap_after_correct_datetime.R
# ARTICLE 1 — ENERGY REPORTS
# Rebuild VV-PA-TM overlap after corrected datetime parsing
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
  library(openxlsx)
})

# ============================================================
# 2. Paths
# ============================================================

ARTICLE_ROOT <- "E:/Academia/UNAL/DOCTORADO/Productos/Articulo 1"

INPUT_RDS <- file.path(
  ARTICLE_ROOT,
  "01_data_processed",
  "00C_article_period_2017_2022_correct_datetime.rds"
)

DIR_DATA_PROCESSED <- file.path(ARTICLE_ROOT, "01_data_processed")
DIR_RESULTS <- file.path(ARTICLE_ROOT, "02_results")
DIR_TABLES <- file.path(ARTICLE_ROOT, "04_tables")
DIR_LOGS <- file.path(ARTICLE_ROOT, "logs")

dirs <- c(DIR_DATA_PROCESSED, DIR_RESULTS, DIR_TABLES, DIR_LOGS)
invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))

if (!file.exists(INPUT_RDS)) {
  stop("Corrected datetime dataset not found: ", INPUT_RDS)
}

log_file <- file.path(DIR_LOGS, "01D_rebuild_overlap_after_correct_datetime_log.txt")

log_msg <- function(...) {
  msg <- paste0(
    format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    " | ",
    paste(..., collapse = " ")
  )
  cat(msg, "\n")
  cat(msg, "\n", file = log_file, append = TRUE)
}

log_msg("Starting overlap reconstruction after corrected datetime parsing.")

# ============================================================
# 3. Load corrected dataset
# ============================================================

dt <- readRDS(INPUT_RDS)
dt <- as.data.table(dt)

dt[, datetime := as.POSIXct(datetime, tz = "America/Bogota")]
dt[, variable_clean := stringr::str_to_upper(variable_clean)]
dt[, zone := as.character(zone)]
dt[, station := as.character(station)]
dt[, value := suppressWarnings(as.numeric(value))]

dt <- dt[!is.na(datetime) & !is.na(value)]

log_msg("Corrected dataset loaded.")
log_msg("Rows:", nrow(dt))
log_msg("Zones:", uniqueN(dt$zone))
log_msg("Stations:", uniqueN(dt$station))

# ============================================================
# 4. Study period audit
# ============================================================

study_period_audit <- data.frame(
  n_rows = nrow(dt),
  n_zones = uniqueN(dt$zone),
  n_stations = uniqueN(dt$station),
  min_datetime = min(dt$datetime, na.rm = TRUE),
  max_datetime = max(dt$datetime, na.rm = TRUE)
)

write.xlsx(
  study_period_audit,
  file.path(DIR_TABLES, "01D_study_period_audit_corrected_datetime.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 5. Variable inventory
# ============================================================

variable_inventory <- dt[, .(
  n_records = .N,
  n_zones = uniqueN(zone),
  n_stations = uniqueN(station),
  min_datetime = min(datetime, na.rm = TRUE),
  max_datetime = max(datetime, na.rm = TRUE),
  min_value = min(value, na.rm = TRUE),
  median_value = median(value, na.rm = TRUE),
  mean_value = mean(value, na.rm = TRUE),
  max_value = max(value, na.rm = TRUE)
), by = .(
  variable_raw,
  variable_clean
)][order(-n_records)]

write.xlsx(
  variable_inventory,
  file.path(DIR_TABLES, "01D_variable_inventory_corrected_datetime.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 6. Zone-hour aggregation
# ============================================================

dt[, datetime_hour := floor_date(datetime, unit = "hour")]

zone_hour_long <- dt[, .(
  value = mean(value, na.rm = TRUE),
  n_original_records = .N,
  n_stations_contributing = uniqueN(station)
), by = .(
  zone,
  datetime_hour,
  variable_clean
)]

zone_hour_wide <- dcast(
  zone_hour_long,
  zone + datetime_hour ~ variable_clean,
  value.var = "value",
  fun.aggregate = mean,
  fill = NA_real_
)

setnames(zone_hour_wide, "datetime_hour", "datetime")

log_msg("Zone-hour wide dataset created.")
log_msg("Rows:", nrow(zone_hour_wide))
log_msg("Columns:", ncol(zone_hour_wide))

# ============================================================
# 7. Detect physical variables
# ============================================================

detect_variable <- function(available, candidates) {
  candidates_clean <- candidates |>
    stringr::str_to_upper() |>
    stringr::str_replace_all("[^A-Z0-9_]", "_") |>
    stringr::str_replace_all("_+", "_") |>
    stringr::str_remove("^_") |>
    stringr::str_remove("_$")
  
  found <- intersect(candidates_clean, available)
  
  if (length(found) == 0) return(NA_character_)
  found[1]
}

available_vars <- names(zone_hour_wide)

vv_col <- detect_variable(
  available_vars,
  c("VV", "VEL_VIENTO", "VELOCIDAD_VIENTO", "VELOCIDAD_DEL_VIENTO", "WIND_SPEED")
)

pa_col <- detect_variable(
  available_vars,
  c("PA", "PRESION", "PRESION_ATMOSFERICA", "ATMOSPHERIC_PRESSURE", "PRESSURE")
)

tm_col <- detect_variable(
  available_vars,
  c("TM", "TEMPERATURA", "TEMPERATURA_MEDIA", "TEMP", "T", "AIR_TEMPERATURE")
)

tmax_col <- detect_variable(
  available_vars,
  c("TMAX", "T_MAX", "TEMPERATURA_MAXIMA", "MAX_TEMPERATURE")
)

tmin_col <- detect_variable(
  available_vars,
  c("TMIN", "T_MIN", "TEMPERATURA_MINIMA", "MIN_TEMPERATURE")
)

physical_variable_detection <- data.frame(
  physical_role = c(
    "wind_speed",
    "pressure",
    "mean_temperature",
    "maximum_temperature",
    "minimum_temperature"
  ),
  detected_column = c(vv_col, pa_col, tm_col, tmax_col, tmin_col)
)

write.xlsx(
  physical_variable_detection,
  file.path(DIR_TABLES, "01D_physical_variable_detection_corrected_datetime.xlsx"),
  overwrite = TRUE
)

if (is.na(vv_col)) stop("Wind speed variable was not detected.")
if (is.na(pa_col)) stop("Pressure variable was not detected.")

if (is.na(tm_col) && !(is.na(tmax_col) || is.na(tmin_col))) {
  zone_hour_wide[, TM_DERIVED := (get(tmax_col) + get(tmin_col)) / 2]
  tm_col <- "TM_DERIVED"
  log_msg("Mean temperature derived from maximum and minimum temperature.")
}

if (is.na(tm_col)) stop("Temperature variable was not detected.")

# ============================================================
# 8. Build physical zone-hour dataset
# ============================================================

physical_hourly <- zone_hour_wide[, .(
  zone = as.character(zone),
  datetime = datetime,
  VV = as.numeric(get(vv_col)),
  PA = as.numeric(get(pa_col)),
  TM = as.numeric(get(tm_col))
)]

physical_hourly[, date := as.Date(datetime)]
physical_hourly[, year := year(datetime)]
physical_hourly[, month := month(datetime)]
physical_hourly[, year_month := format(datetime, "%Y-%m")]

# ============================================================
# 9. Unit audit before correction
# ============================================================

unit_audit_before <- data.frame(
  variable = c("VV_raw", "PA_raw", "TM_raw"),
  n_available = c(
    sum(!is.na(physical_hourly$VV)),
    sum(!is.na(physical_hourly$PA)),
    sum(!is.na(physical_hourly$TM))
  ),
  min = c(
    min(physical_hourly$VV, na.rm = TRUE),
    min(physical_hourly$PA, na.rm = TRUE),
    min(physical_hourly$TM, na.rm = TRUE)
  ),
  p25 = c(
    quantile(physical_hourly$VV, 0.25, na.rm = TRUE),
    quantile(physical_hourly$PA, 0.25, na.rm = TRUE),
    quantile(physical_hourly$TM, 0.25, na.rm = TRUE)
  ),
  median = c(
    median(physical_hourly$VV, na.rm = TRUE),
    median(physical_hourly$PA, na.rm = TRUE),
    median(physical_hourly$TM, na.rm = TRUE)
  ),
  p75 = c(
    quantile(physical_hourly$VV, 0.75, na.rm = TRUE),
    quantile(physical_hourly$PA, 0.75, na.rm = TRUE),
    quantile(physical_hourly$TM, 0.75, na.rm = TRUE)
  ),
  max = c(
    max(physical_hourly$VV, na.rm = TRUE),
    max(physical_hourly$PA, na.rm = TRUE),
    max(physical_hourly$TM, na.rm = TRUE)
  )
)

write.xlsx(
  unit_audit_before,
  file.path(DIR_TABLES, "01D_unit_audit_before_physical_calculation.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 10. Unit conversion and physical screening
# ============================================================

physical_hourly[, VV := fifelse(VV < 0, NA_real_, VV)]

pressure_median <- median(physical_hourly$PA, na.rm = TRUE)

if (!is.na(pressure_median) && pressure_median >= 50000 && pressure_median <= 110000) {
  physical_hourly[, PA_Pa := PA]
  pressure_unit_interpretation <- "Pressure interpreted as Pa."
} else if (!is.na(pressure_median) && pressure_median >= 500 && pressure_median <= 1100) {
  physical_hourly[, PA_Pa := PA * 100]
  pressure_unit_interpretation <- "Pressure interpreted as hPa and converted to Pa."
} else if (!is.na(pressure_median) && pressure_median >= 50 && pressure_median <= 110) {
  physical_hourly[, PA_Pa := PA * 1000]
  pressure_unit_interpretation <- "Pressure interpreted as kPa and converted to Pa."
} else {
  physical_hourly[, PA_Pa := PA]
  pressure_unit_interpretation <- "Pressure unit uncertain; values preserved as provided."
}

temperature_median <- median(physical_hourly$TM, na.rm = TRUE)

if (!is.na(temperature_median) && temperature_median >= 230 && temperature_median <= 330) {
  physical_hourly[, TK := TM]
  temperature_unit_interpretation <- "Temperature interpreted as Kelvin."
} else if (!is.na(temperature_median) && temperature_median >= -30 && temperature_median <= 60) {
  physical_hourly[, TK := TM + 273.15]
  temperature_unit_interpretation <- "Temperature interpreted as Celsius and converted to Kelvin."
} else {
  physical_hourly[, TK := TM]
  temperature_unit_interpretation <- "Temperature unit uncertain; values preserved as provided."
}

# Conservative physical screening
physical_hourly[PA_Pa < 50000 | PA_Pa > 110000, PA_Pa := NA_real_]
physical_hourly[TK < 230 | TK > 330, TK := NA_real_]
physical_hourly[VV > 75, VV := NA_real_]

R_d <- 287.05

physical_hourly[, rho := PA_Pa / (R_d * TK)]
physical_hourly[rho < 0.5 | rho > 1.5, rho := NA_real_]

physical_hourly[, WPD_observed_rho := 0.5 * rho * VV^3]
physical_hourly[WPD_observed_rho < 0 | WPD_observed_rho > 5000, WPD_observed_rho := NA_real_]

physical_hourly[, has_VV := !is.na(VV)]
physical_hourly[, has_PA := !is.na(PA_Pa)]
physical_hourly[, has_TK := !is.na(TK)]
physical_hourly[, has_rho := !is.na(rho)]
physical_hourly[, has_WPD_observed_rho := !is.na(WPD_observed_rho)]

# ============================================================
# 11. Hour-level overlap
# ============================================================

hour_overlap_by_zone <- physical_hourly[, .(
  n_zone_hours = .N,
  n_VV = sum(has_VV),
  n_PA = sum(has_PA),
  n_TK = sum(has_TK),
  n_rho = sum(has_rho),
  n_WPD_observed_rho = sum(has_WPD_observed_rho),
  pct_VV_with_rho = round(100 * sum(has_VV & has_rho) / max(sum(has_VV), 1), 3),
  pct_VV_with_WPD_observed_rho = round(
    100 * sum(has_WPD_observed_rho) / max(sum(has_VV), 1),
    3
  )
), by = zone][order(zone)]

write.xlsx(
  hour_overlap_by_zone,
  file.path(DIR_TABLES, "01D_hour_level_overlap_by_zone_corrected_datetime.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 12. Density strategies
# ============================================================

vv_hourly <- physical_hourly[has_VV == TRUE, .(
  zone,
  datetime,
  date,
  year,
  month,
  year_month,
  VV
)]

# Daily density
rho_day <- physical_hourly[has_rho == TRUE, .(
  rho_day_mean = mean(rho, na.rm = TRUE),
  rho_day_median = median(rho, na.rm = TRUE),
  n_rho_day = .N
), by = .(zone, date)]

vv_day_join <- merge(
  vv_hourly,
  rho_day,
  by = c("zone", "date"),
  all.x = TRUE
)

vv_day_join[, WPD_day_rho := 0.5 * rho_day_mean * VV^3]

# Monthly density
rho_month <- physical_hourly[has_rho == TRUE, .(
  rho_month_mean = mean(rho, na.rm = TRUE),
  rho_month_median = median(rho, na.rm = TRUE),
  n_rho_month = .N
), by = .(zone, year_month)]

vv_month_join <- merge(
  vv_hourly,
  rho_month,
  by = c("zone", "year_month"),
  all.x = TRUE
)

vv_month_join[, WPD_month_rho := 0.5 * rho_month_mean * VV^3]

# Zone density
rho_zone <- physical_hourly[has_rho == TRUE, .(
  rho_zone_mean = mean(rho, na.rm = TRUE),
  rho_zone_median = median(rho, na.rm = TRUE),
  n_rho_zone = .N
), by = zone]

vv_zone_join <- merge(
  vv_hourly,
  rho_zone,
  by = "zone",
  all.x = TRUE
)

vv_zone_join[, WPD_zone_rho := 0.5 * rho_zone_mean * VV^3]

# Standard density
rho_standard <- 1.225

vv_standard <- copy(vv_hourly)
vv_standard[, rho_standard := rho_standard]
vv_standard[, WPD_standard_rho := 0.5 * rho_standard * VV^3]

# ============================================================
# 13. Strategy comparison
# ============================================================

strategy_comparison <- data.table(
  strategy = c(
    "hourly_observed_rho",
    "daily_zone_mean_rho",
    "monthly_zone_mean_rho",
    "overall_zone_mean_rho",
    "standard_air_density"
  ),
  available_wind_records = c(
    nrow(vv_hourly),
    nrow(vv_day_join),
    nrow(vv_month_join),
    nrow(vv_zone_join),
    nrow(vv_standard)
  ),
  records_with_density = c(
    sum(physical_hourly$has_VV & physical_hourly$has_rho),
    sum(!is.na(vv_day_join$rho_day_mean)),
    sum(!is.na(vv_month_join$rho_month_mean)),
    sum(!is.na(vv_zone_join$rho_zone_mean)),
    nrow(vv_standard)
  )
)

strategy_comparison[, coverage_pct := round(
  100 * records_with_density / max(available_wind_records, 1),
  3
)]

strategy_comparison[, methodological_strength := c(
  "Strongest physically because VV, PA and TM coincide at zone-hour level.",
  "Strong if daily density is available for most wind-speed records.",
  "Defensible if density varies slowly relative to wind speed.",
  "Fallback based on climatological zone-level density.",
  "Fallback estimate using standard air density with sensitivity analysis."
)]

write.xlsx(
  strategy_comparison,
  file.path(DIR_TABLES, "01D_density_strategy_comparison_corrected_datetime.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 14. Recommended strategy
# ============================================================

hourly_coverage <- strategy_comparison[
  strategy == "hourly_observed_rho",
  coverage_pct
]

daily_coverage <- strategy_comparison[
  strategy == "daily_zone_mean_rho",
  coverage_pct
]

monthly_coverage <- strategy_comparison[
  strategy == "monthly_zone_mean_rho",
  coverage_pct
]

zone_coverage <- strategy_comparison[
  strategy == "overall_zone_mean_rho",
  coverage_pct
]

recommended_strategy <- if (hourly_coverage >= 70) {
  "hourly_observed_rho"
} else if (daily_coverage >= 70) {
  "daily_zone_mean_rho"
} else if (monthly_coverage >= 70) {
  "monthly_zone_mean_rho"
} else if (zone_coverage >= 70) {
  "overall_zone_mean_rho"
} else {
  "standard_air_density_with_sensitivity"
}

recommendation <- data.frame(
  recommended_strategy = recommended_strategy,
  rationale = dplyr::case_when(
    recommended_strategy == "hourly_observed_rho" ~
      "Zone-hour observed air density provides sufficient overlap for WPD calculation.",
    recommended_strategy == "daily_zone_mean_rho" ~
      "Daily zone-level density provides sufficient coverage for wind-speed records.",
    recommended_strategy == "monthly_zone_mean_rho" ~
      "Monthly zone-level density provides sufficient coverage and is physically defensible.",
    recommended_strategy == "overall_zone_mean_rho" ~
      "Only zone-level density provides sufficient coverage; sensitivity analysis is required.",
    TRUE ~
      "Observed density overlap remains insufficient; use standard air density and density-sensitivity scenarios."
  )
)

write.xlsx(
  recommendation,
  file.path(DIR_TABLES, "01D_recommended_density_strategy_corrected_datetime.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 15. Build final WPD candidate dataset
# ============================================================

if (recommended_strategy == "hourly_observed_rho") {
  
  final_wpd <- physical_hourly[has_VV == TRUE & has_rho == TRUE, .(
    zone,
    datetime,
    date,
    year,
    month,
    year_month,
    VV,
    rho_used = rho,
    WPD = 0.5 * rho * VV^3
  )]
  
  final_wpd[, density_strategy := "hourly_observed_rho"]
  
} else if (recommended_strategy == "daily_zone_mean_rho") {
  
  final_wpd <- copy(vv_day_join)
  setnames(final_wpd, "rho_day_mean", "rho_used")
  final_wpd[, WPD := WPD_day_rho]
  final_wpd[, density_strategy := "daily_zone_mean_rho"]
  
} else if (recommended_strategy == "monthly_zone_mean_rho") {
  
  final_wpd <- copy(vv_month_join)
  setnames(final_wpd, "rho_month_mean", "rho_used")
  final_wpd[, WPD := WPD_month_rho]
  final_wpd[, density_strategy := "monthly_zone_mean_rho"]
  
} else if (recommended_strategy == "overall_zone_mean_rho") {
  
  final_wpd <- copy(vv_zone_join)
  setnames(final_wpd, "rho_zone_mean", "rho_used")
  final_wpd[, WPD := WPD_zone_rho]
  final_wpd[, density_strategy := "overall_zone_mean_rho"]
  
} else {
  
  final_wpd <- copy(vv_standard)
  setnames(final_wpd, "rho_standard", "rho_used")
  final_wpd[, WPD := WPD_standard_rho]
  final_wpd[, density_strategy := "standard_air_density_1.225_kg_m3"]
}

final_wpd <- final_wpd[
  !is.na(VV) &
    !is.na(rho_used) &
    !is.na(WPD) &
    WPD >= 0
]

# Keep raw high WPD for audit, but also flag extreme values
final_wpd[, WPD_gt_5000 := WPD > 5000]
final_wpd[, VV_gt_30 := VV > 30]
final_wpd[, VV_gt_25 := VV > 25]
final_wpd[, VV_gt_20 := VV > 20]

saveRDS(
  final_wpd,
  file.path(DIR_DATA_PROCESSED, "01D_final_wpd_candidate_dataset_corrected_datetime.rds")
)

fwrite(
  final_wpd,
  file.path(DIR_DATA_PROCESSED, "01D_final_wpd_candidate_dataset_corrected_datetime.csv"),
  sep = ",",
  bom = TRUE
)

# ============================================================
# 16. Final summaries
# ============================================================

final_wpd_summary_by_zone <- final_wpd[, .(
  n_records = .N,
  mean_VV = mean(VV, na.rm = TRUE),
  median_VV = median(VV, na.rm = TRUE),
  sd_VV = sd(VV, na.rm = TRUE),
  min_VV = min(VV, na.rm = TRUE),
  p95_VV = quantile(VV, 0.95, na.rm = TRUE),
  p99_VV = quantile(VV, 0.99, na.rm = TRUE),
  max_VV = max(VV, na.rm = TRUE),
  mean_rho_used = mean(rho_used, na.rm = TRUE),
  mean_WPD = mean(WPD, na.rm = TRUE),
  median_WPD = median(WPD, na.rm = TRUE),
  sd_WPD = sd(WPD, na.rm = TRUE),
  p25_WPD = quantile(WPD, 0.25, na.rm = TRUE),
  p75_WPD = quantile(WPD, 0.75, na.rm = TRUE),
  p95_WPD = quantile(WPD, 0.95, na.rm = TRUE),
  p99_WPD = quantile(WPD, 0.99, na.rm = TRUE),
  max_WPD = max(WPD, na.rm = TRUE),
  n_VV_gt_30 = sum(VV_gt_30, na.rm = TRUE),
  pct_VV_gt_30 = round(100 * mean(VV_gt_30, na.rm = TRUE), 4),
  n_WPD_gt_5000 = sum(WPD_gt_5000, na.rm = TRUE),
  pct_WPD_gt_5000 = round(100 * mean(WPD_gt_5000, na.rm = TRUE), 4)
), by = zone][order(zone)]

write.xlsx(
  final_wpd_summary_by_zone,
  file.path(DIR_TABLES, "01D_final_wpd_summary_by_zone_corrected_datetime.xlsx"),
  overwrite = TRUE
)

final_wpd_summary_by_year_zone <- final_wpd[, .(
  n_records = .N,
  mean_VV = mean(VV, na.rm = TRUE),
  median_VV = median(VV, na.rm = TRUE),
  mean_WPD = mean(WPD, na.rm = TRUE),
  median_WPD = median(WPD, na.rm = TRUE),
  max_WPD = max(WPD, na.rm = TRUE)
), by = .(
  year,
  zone
)][order(year, zone)]

write.xlsx(
  final_wpd_summary_by_year_zone,
  file.path(DIR_TABLES, "01D_final_wpd_summary_by_year_zone_corrected_datetime.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 17. Save audit object
# ============================================================

audit_object <- list(
  study_period_audit = study_period_audit,
  variable_inventory = variable_inventory,
  physical_variable_detection = physical_variable_detection,
  unit_audit_before = unit_audit_before,
  hour_overlap_by_zone = hour_overlap_by_zone,
  strategy_comparison = strategy_comparison,
  recommendation = recommendation,
  final_wpd_summary_by_zone = final_wpd_summary_by_zone,
  final_wpd_summary_by_year_zone = final_wpd_summary_by_year_zone,
  pressure_unit_interpretation = pressure_unit_interpretation,
  temperature_unit_interpretation = temperature_unit_interpretation
)

saveRDS(
  audit_object,
  file.path(DIR_RESULTS, "01D_rebuild_overlap_after_correct_datetime.rds")
)

# ============================================================
# 18. Console report
# ============================================================

cat("\n============================================================\n")
cat("REBUILT VV-PA-TM OVERLAP AFTER CORRECT DATETIME — ARTICLE 1\n")
cat("============================================================\n\n")

cat("Study period audit:\n")
print(study_period_audit)

cat("\nPhysical variable detection:\n")
print(physical_variable_detection)

cat("\nUnit audit before physical calculation:\n")
print(unit_audit_before)

cat("\nUnit interpretation:\n")
cat("-", pressure_unit_interpretation, "\n")
cat("-", temperature_unit_interpretation, "\n")

cat("\nHour-level overlap by zone:\n")
print(hour_overlap_by_zone)

cat("\nDensity strategy comparison:\n")
print(strategy_comparison)

cat("\nRecommended strategy:\n")
print(recommendation)

cat("\nFinal WPD summary by zone:\n")
print(final_wpd_summary_by_zone)

cat("\nExported key files:\n")
cat("- 04_tables/01D_hour_level_overlap_by_zone_corrected_datetime.xlsx\n")
cat("- 04_tables/01D_density_strategy_comparison_corrected_datetime.xlsx\n")
cat("- 04_tables/01D_recommended_density_strategy_corrected_datetime.xlsx\n")
cat("- 04_tables/01D_final_wpd_summary_by_zone_corrected_datetime.xlsx\n")
cat("- 01_data_processed/01D_final_wpd_candidate_dataset_corrected_datetime.rds\n")
cat("- 02_results/01D_rebuild_overlap_after_correct_datetime.rds\n")
cat("============================================================\n")

log_msg("Overlap reconstruction after corrected datetime completed successfully.")

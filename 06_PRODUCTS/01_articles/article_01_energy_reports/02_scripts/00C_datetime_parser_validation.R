# ============================================================
# 00C_compare_datetime_parsers.R
# ARTICLE 1 — ENERGY REPORTS
# Robust datetime parser comparison for 2017–2022 dataset
# Author: Favio Nicolás Rosero Rodríguez
# ============================================================

rm(list = ls())
gc()

# ============================================================
# 1. Packages
# ============================================================

required_packages <- c(
  "data.table",
  "lubridate",
  "stringr",
  "janitor",
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
  library(lubridate)
  library(stringr)
  library(janitor)
  library(openxlsx)
})

# ============================================================
# 2. Paths
# ============================================================

ARTICLE_ROOT <- "E:/Academia/UNAL/DOCTORADO/Productos/Articulo 1"
RAW_FILE <- file.path(ARTICLE_ROOT, "Datos.txt")

DIR_DATA_PROCESSED <- file.path(ARTICLE_ROOT, "01_data_processed")
DIR_RESULTS <- file.path(ARTICLE_ROOT, "02_results")
DIR_TABLES <- file.path(ARTICLE_ROOT, "04_tables")
DIR_LOGS <- file.path(ARTICLE_ROOT, "logs")

dirs <- c(DIR_DATA_PROCESSED, DIR_RESULTS, DIR_TABLES, DIR_LOGS)
invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))

if (!file.exists(RAW_FILE)) {
  stop("Raw file not found: ", RAW_FILE)
}

log_file <- file.path(DIR_LOGS, "00C_compare_datetime_parsers_log.txt")

log_msg <- function(...) {
  msg <- paste0(
    format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    " | ",
    paste(..., collapse = " ")
  )
  cat(msg, "\n")
  cat(msg, "\n", file = log_file, append = TRUE)
}

log_msg("Starting robust datetime parser comparison.")
log_msg("Raw file:", RAW_FILE)

# ============================================================
# 3. Read raw data
# ============================================================

dt_raw <- tryCatch(
  {
    fread(
      RAW_FILE,
      encoding = "UTF-8",
      na.strings = c("", "NA", "NaN", "NULL", "null", "-", "N/A"),
      showProgress = TRUE
    )
  },
  error = function(e1) {
    log_msg("UTF-8 failed. Trying Latin-1.")
    fread(
      RAW_FILE,
      encoding = "Latin-1",
      na.strings = c("", "NA", "NaN", "NULL", "null", "-", "N/A"),
      showProgress = TRUE
    )
  }
)

original_colnames <- names(dt_raw)

dt <- dt_raw |>
  as.data.frame() |>
  janitor::clean_names() |>
  as.data.table()

clean_colnames <- names(dt)

column_dictionary <- data.frame(
  original_name = original_colnames,
  clean_name = clean_colnames
)

write.xlsx(
  column_dictionary,
  file.path(DIR_TABLES, "00C_column_dictionary.xlsx"),
  overwrite = TRUE
)

log_msg("Raw data loaded.")
log_msg("Rows:", nrow(dt))
log_msg("Columns:", ncol(dt))

# ============================================================
# 4. Detect key columns
# ============================================================

find_col <- function(possible_names, available_names) {
  found <- intersect(possible_names, available_names)
  if (length(found) == 0) return(NA_character_)
  found[1]
}

col_station <- find_col(
  c("estacion", "station", "codigo_estacion", "cod_estacion"),
  names(dt)
)

col_datetime <- find_col(
  c("fecha_y_hora", "fechayhora", "fecha_hora", "datetime", "fecha"),
  names(dt)
)

col_value <- find_col(
  c("valor", "value"),
  names(dt)
)

col_zone <- find_col(
  c("zona", "zone"),
  names(dt)
)

col_variable <- find_col(
  c("variable", "var", "parametro"),
  names(dt)
)

detected_columns <- data.frame(
  role = c("station", "datetime", "value", "zone", "variable"),
  detected_column = c(col_station, col_datetime, col_value, col_zone, col_variable)
)

write.xlsx(
  detected_columns,
  file.path(DIR_TABLES, "00C_detected_columns.xlsx"),
  overwrite = TRUE
)

print(detected_columns)

if (any(is.na(c(col_datetime, col_value, col_zone, col_variable)))) {
  stop("Required columns were not detected correctly.")
}

if (is.na(col_station)) {
  dt[, station_temp_article1 := "unknown_station"]
  col_station <- "station_temp_article1"
}

# ============================================================
# 5. Raw datetime component audit
# ============================================================

dt[, raw_datetime_string := as.character(get(col_datetime))]
dt[, raw_datetime_string := stringr::str_squish(raw_datetime_string)]
dt[, raw_datetime_string := stringr::str_replace_all(raw_datetime_string, "T", " ")]

dt[, raw_date_part := sub("\\s+.*$", "", raw_datetime_string)]
dt[, raw_time_part := ifelse(
  grepl("\\s+", raw_datetime_string),
  sub("^\\S+\\s+", "", raw_datetime_string),
  "00:00:00"
)]

dt[, raw_date_part_standard := gsub("[-.]", "/", raw_date_part)]

date_parts <- tstrsplit(dt$raw_date_part_standard, "/", fixed = TRUE, fill = NA)

dt[, date_a := suppressWarnings(as.integer(date_parts[[1]]))]
dt[, date_b := suppressWarnings(as.integer(date_parts[[2]]))]
dt[, date_c := suppressWarnings(as.integer(date_parts[[3]]))]

component_summary <- data.frame(
  component = c("first_component", "second_component", "third_component"),
  min_value = c(
    min(dt$date_a, na.rm = TRUE),
    min(dt$date_b, na.rm = TRUE),
    min(dt$date_c, na.rm = TRUE)
  ),
  max_value = c(
    max(dt$date_a, na.rm = TRUE),
    max(dt$date_b, na.rm = TRUE),
    max(dt$date_c, na.rm = TRUE)
  ),
  pct_17_22 = c(
    round(100 * mean(dt$date_a %in% 17:22, na.rm = TRUE), 4),
    round(100 * mean(dt$date_b %in% 17:22, na.rm = TRUE), 4),
    round(100 * mean(dt$date_c %in% 17:22, na.rm = TRUE), 4)
  ),
  pct_2017_2022 = c(
    round(100 * mean(dt$date_a %in% 2017:2022, na.rm = TRUE), 4),
    round(100 * mean(dt$date_b %in% 2017:2022, na.rm = TRUE), 4),
    round(100 * mean(dt$date_c %in% 2017:2022, na.rm = TRUE), 4)
  ),
  pct_1_12 = c(
    round(100 * mean(dt$date_a %in% 1:12, na.rm = TRUE), 4),
    round(100 * mean(dt$date_b %in% 1:12, na.rm = TRUE), 4),
    round(100 * mean(dt$date_c %in% 1:12, na.rm = TRUE), 4)
  ),
  pct_1_31 = c(
    round(100 * mean(dt$date_a %in% 1:31, na.rm = TRUE), 4),
    round(100 * mean(dt$date_b %in% 1:31, na.rm = TRUE), 4),
    round(100 * mean(dt$date_c %in% 1:31, na.rm = TRUE), 4)
  )
)

write.xlsx(
  component_summary,
  file.path(DIR_TABLES, "00C_raw_date_component_summary.xlsx"),
  overwrite = TRUE
)

raw_datetime_samples <- dt[
  ,
  .N,
  by = .(raw_date_part_standard)
][order(-N)][1:min(.N, 500)]

write.xlsx(
  raw_datetime_samples,
  file.path(DIR_TABLES, "00C_raw_date_part_samples.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 6. Manual parser
# ============================================================

manual_parse_datetime <- function(x, order = "ymd", tz = "America/Bogota") {
  
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
  
  date_split <- data.table(raw_date = date_part)
  parts <- tstrsplit(date_split$raw_date, "/", fixed = TRUE, fill = NA)
  
  a <- suppressWarnings(as.integer(parts[[1]]))
  b <- suppressWarnings(as.integer(parts[[2]]))
  c <- suppressWarnings(as.integer(parts[[3]]))
  
  if (order == "ymd") {
    yy <- a
    mm <- b
    dd <- c
  } else if (order == "dmy") {
    dd <- a
    mm <- b
    yy <- c
  } else if (order == "mdy") {
    mm <- a
    dd <- b
    yy <- c
  } else {
    stop("Unsupported order.")
  }
  
  yy <- ifelse(!is.na(yy) & yy < 100, 2000 + yy, yy)
  
  time_part <- gsub("\\..*$", "", time_part)
  time_split <- data.table(raw_time = time_part)
  tparts <- tstrsplit(time_split$raw_time, ":", fixed = TRUE, fill = "0")
  
  HH <- suppressWarnings(as.integer(tparts[[1]]))
  MM <- suppressWarnings(as.integer(tparts[[2]]))
  SS <- suppressWarnings(as.integer(tparts[[3]]))
  
  HH[is.na(HH)] <- 0L
  MM[is.na(MM)] <- 0L
  SS[is.na(SS)] <- 0L
  
  valid <- !is.na(yy) &
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
  
  out <- rep(as.POSIXct(NA, tz = tz), length(x))
  
  iso_string <- sprintf(
    "%04d-%02d-%02d %02d:%02d:%02d",
    yy,
    mm,
    dd,
    HH,
    MM,
    SS
  )
  
  out[valid] <- suppressWarnings(as.POSIXct(
    iso_string[valid],
    format = "%Y-%m-%d %H:%M:%S",
    tz = tz
  ))
  
  return(out)
}

# ============================================================
# 7. Apply candidate parsers
# ============================================================

study_start <- as.POSIXct("2017-01-01 00:00:00", tz = "America/Bogota")
study_end <- as.POSIXct("2023-01-01 00:00:00", tz = "America/Bogota")

parser_orders <- c("ymd", "dmy", "mdy")

parser_results <- list()

for (ord in parser_orders) {
  log_msg("Parsing datetime with manual order:", ord)
  parser_results[[ord]] <- manual_parse_datetime(dt$raw_datetime_string, order = ord)
}

# ============================================================
# 8. Parser comparison
# ============================================================

compare_parser <- function(parsed_datetime, parser_name) {
  
  inside <- !is.na(parsed_datetime) &
    parsed_datetime >= study_start &
    parsed_datetime < study_end
  
  data.frame(
    parser = parser_name,
    n_rows = length(parsed_datetime),
    n_valid_datetime = sum(!is.na(parsed_datetime)),
    pct_valid_datetime = round(100 * mean(!is.na(parsed_datetime)), 5),
    min_datetime = as.character(min(parsed_datetime, na.rm = TRUE)),
    max_datetime = as.character(max(parsed_datetime, na.rm = TRUE)),
    n_inside_2017_2022 = sum(inside),
    pct_inside_2017_2022 = round(100 * mean(inside), 5),
    n_outside_2017_2022 = sum(!is.na(parsed_datetime) & !inside),
    pct_outside_2017_2022 = round(
      100 * mean(!is.na(parsed_datetime) & !inside),
      5
    ),
    n_before_2017 = sum(!is.na(parsed_datetime) & parsed_datetime < study_start),
    n_after_2022 = sum(!is.na(parsed_datetime) & parsed_datetime >= study_end)
  )
}

parser_comparison <- rbindlist(lapply(names(parser_results), function(ord) {
  compare_parser(parser_results[[ord]], ord)
}), fill = TRUE)

parser_comparison <- parser_comparison[order(-pct_inside_2017_2022)]

write.xlsx(
  parser_comparison,
  file.path(DIR_TABLES, "00C_parser_comparison_2017_2022.xlsx"),
  overwrite = TRUE
)

recommended_parser <- parser_comparison$parser[1]

recommendation <- data.frame(
  recommended_parser = recommended_parser,
  rationale = paste0(
    "The selected parser maximizes the percentage of records inside the expected ",
    "2017–2022 study period and minimizes out-of-period artifacts."
  )
)

write.xlsx(
  recommendation,
  file.path(DIR_TABLES, "00C_recommended_datetime_parser.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 9. Build corrected dataset with recommended parser
# ============================================================

dt[, datetime_corrected := parser_results[[recommended_parser]]]

dt_corrected <- dt[
  !is.na(datetime_corrected),
  .(
    station = as.character(get(col_station)),
    zone = as.character(get(col_zone)),
    datetime_raw = raw_datetime_string,
    datetime = datetime_corrected,
    variable_raw = as.character(get(col_variable)),
    value_raw = get(col_value)
  )
]

dt_corrected[, value := suppressWarnings(as.numeric(value_raw))]
dt_corrected[, station := str_trim(station)]
dt_corrected[, zone := str_trim(zone)]

dt_corrected[, variable_clean := variable_raw |>
               stringr::str_to_upper() |>
               stringr::str_replace_all("[^A-Z0-9_]", "_") |>
               stringr::str_replace_all("_+", "_") |>
               stringr::str_remove("^_") |>
               stringr::str_remove("_$")]

dt_corrected[, year := year(datetime)]
dt_corrected[, month := month(datetime)]
dt_corrected[, year_month := format(datetime, "%Y-%m")]

dt_article_period <- dt_corrected[
  datetime >= study_start &
    datetime < study_end &
    !is.na(value)
]

# ============================================================
# 10. Variable inventory with corrected parser
# ============================================================

variable_inventory_corrected <- dt_article_period[, .(
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
  variable_inventory_corrected,
  file.path(DIR_TABLES, "00C_variable_inventory_corrected_2017_2022.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 11. VV audit with corrected parser
# ============================================================

vv_corrected <- dt_article_period[
  variable_clean == "VV" &
    !is.na(value)
]

vv_summary_corrected <- vv_corrected[, .(
  n_records = .N,
  n_zones = uniqueN(zone),
  n_stations = uniqueN(station),
  min_datetime = min(datetime, na.rm = TRUE),
  max_datetime = max(datetime, na.rm = TRUE),
  mean_VV = mean(value, na.rm = TRUE),
  median_VV = median(value, na.rm = TRUE),
  sd_VV = sd(value, na.rm = TRUE),
  min_VV = min(value, na.rm = TRUE),
  max_VV = max(value, na.rm = TRUE)
)]

vv_by_zone_corrected <- vv_corrected[, .(
  n_records = .N,
  n_stations = uniqueN(station),
  min_datetime = min(datetime, na.rm = TRUE),
  max_datetime = max(datetime, na.rm = TRUE),
  mean_VV = mean(value, na.rm = TRUE),
  median_VV = median(value, na.rm = TRUE),
  sd_VV = sd(value, na.rm = TRUE),
  min_VV = min(value, na.rm = TRUE),
  max_VV = max(value, na.rm = TRUE)
), by = zone][order(zone)]

vv_by_year_zone_corrected <- vv_corrected[, .(
  n_records = .N,
  n_stations = uniqueN(station),
  mean_VV = mean(value, na.rm = TRUE),
  median_VV = median(value, na.rm = TRUE),
  sd_VV = sd(value, na.rm = TRUE),
  min_VV = min(value, na.rm = TRUE),
  max_VV = max(value, na.rm = TRUE)
), by = .(
  year,
  zone
)][order(year, zone)]

write.xlsx(
  vv_summary_corrected,
  file.path(DIR_TABLES, "00C_vv_summary_corrected_2017_2022.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  vv_by_zone_corrected,
  file.path(DIR_TABLES, "00C_vv_summary_by_zone_corrected_2017_2022.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  vv_by_year_zone_corrected,
  file.path(DIR_TABLES, "00C_vv_summary_by_year_zone_corrected_2017_2022.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 12. Save corrected datasets
# ============================================================

saveRDS(
  dt_corrected,
  file.path(DIR_DATA_PROCESSED, "00C_all_records_correct_datetime.rds")
)

saveRDS(
  dt_article_period,
  file.path(DIR_DATA_PROCESSED, "00C_article_period_2017_2022_correct_datetime.rds")
)

fwrite(
  dt_article_period,
  file.path(DIR_DATA_PROCESSED, "00C_article_period_2017_2022_correct_datetime.csv"),
  sep = ",",
  bom = TRUE
)

# ============================================================
# 13. Save comparison samples
# ============================================================

sample_idx <- seq_len(min(nrow(dt), 1000))

parser_sample <- data.table(
  raw_datetime = dt$raw_datetime_string[sample_idx],
  parsed_ymd = parser_results[["ymd"]][sample_idx],
  parsed_dmy = parser_results[["dmy"]][sample_idx],
  parsed_mdy = parser_results[["mdy"]][sample_idx]
)

write.xlsx(
  parser_sample,
  file.path(DIR_TABLES, "00C_parser_sample_first_1000_rows.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 14. Console report
# ============================================================

cat("\n============================================================\n")
cat("ROBUST DATETIME PARSER COMPARISON — ARTICLE 1\n")
cat("============================================================\n\n")

cat("Detected columns:\n")
print(detected_columns)

cat("\nRaw date component summary:\n")
print(component_summary)

cat("\nParser comparison:\n")
print(parser_comparison)

cat("\nRecommended parser:\n")
print(recommendation)

cat("\nVariable inventory with corrected parser:\n")
print(variable_inventory_corrected)

cat("\nVV summary with corrected parser:\n")
print(vv_summary_corrected)

cat("\nVV by zone with corrected parser:\n")
print(vv_by_zone_corrected)

cat("\nVV by year and zone with corrected parser:\n")
print(vv_by_year_zone_corrected)

cat("\nExported key files:\n")
cat("- 04_tables/00C_raw_date_component_summary.xlsx\n")
cat("- 04_tables/00C_parser_comparison_2017_2022.xlsx\n")
cat("- 04_tables/00C_recommended_datetime_parser.xlsx\n")
cat("- 04_tables/00C_variable_inventory_corrected_2017_2022.xlsx\n")
cat("- 04_tables/00C_vv_summary_corrected_2017_2022.xlsx\n")
cat("- 04_tables/00C_vv_summary_by_zone_corrected_2017_2022.xlsx\n")
cat("- 04_tables/00C_vv_summary_by_year_zone_corrected_2017_2022.xlsx\n")
cat("- 01_data_processed/00C_article_period_2017_2022_correct_datetime.rds\n")
cat("============================================================\n")

log_msg("Robust datetime parser comparison completed successfully.")

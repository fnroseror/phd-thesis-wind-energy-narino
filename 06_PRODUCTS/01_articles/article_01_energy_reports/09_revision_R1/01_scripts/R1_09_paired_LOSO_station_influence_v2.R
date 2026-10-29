# ============================================================
# ENERGY REPORTS — REVISION R1
# R1_09_paired_LOSO_station_influence_v2.R
#
# Manuscript: EGYR-D-26-02665
#
# Purpose:
# Deconfound station influence from temporal-support changes in V2.
#
# V2 construction already frozen computationally in R1-08:
#   raw VV -> station-hour mean -> QC 0 <= VV <= 20 m/s
#   -> station-hour WPD = 0.5 * rho_zone-hour * VV^3
#   -> equal-station mean WPD within each zone-hour.
#
# This script quantifies:
#   1) exact reconstruction of canonical V2;
#   2) station-level WPD after QC20;
#   3) direct contribution of each station to the zonal mean WPD;
#   4) paired-support LOSO:
#        compare baseline and LOSO only on identical timestamps;
#   5) co-observed LOSO:
#        compare only timestamps where the removed station and at
#        least one other station were simultaneously present;
#   6) sole-contributor dependence by station.
#
# This is an interpretation/sensitivity audit. It does NOT alter V2.
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

V2_FILE <- file.path(
  DIR_RESULTS,
  "R1_V2_CANONICAL_zone_hour_dataset.rds"
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
  V2_FILE
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
  "R1_09_paired_LOSO_station_influence_log.txt"
)

SUMMARY_FILE <- file.path(
  DIR_RESULTS,
  "R1_09_UPLOAD_THIS_TO_CHAT.txt"
)

SESSION_FILE <- file.path(
  DIR_RESULTS,
  "R1_09_sessionInfo.txt"
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

log_msg("Starting R1-09 paired LOSO / station influence audit.")

# ============================================================
# 4. Load candidate support, rho and canonical V2
# ============================================================

candidate <- as.data.table(readRDS(CANDIDATE_FILE))
v2 <- as.data.table(readRDS(V2_FILE))

candidate[, zone := as.character(zone)]
v2[, zone := as.character(zone)]

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
# 7. Reconstruct retained station-hour data exactly as V2
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

sh <- merge(
  station_hour_qc,
  rho_key,
  by = c("zone", "datetime"),
  all.x = TRUE
)

if (any(!is.finite(sh$rho_used))) {
  stop("Unexpected missing rho after candidate-support restriction.")
}

sh[, WPD_station_hour := 0.5 * rho_used * VV_station_hour^3]

# Count stations in each zone-hour.
sh[, n_stations_zonehour := uniqueN(station), by = .(
  zone,
  datetime
)]

# ============================================================
# 8. Exact V2 reconstruction check
# ============================================================

v2_reconstructed <- sh[, .(
  VV_reconstructed = mean(VV_station_hour),
  WPD_reconstructed = mean(WPD_station_hour),
  n_stations_reconstructed = uniqueN(station)
), by = .(
  zone,
  datetime
)]

chk <- merge(
  v2[, .(
    zone,
    datetime,
    VV_v2 = VV,
    WPD_v2 = WPD,
    n_stations_v2 = n_stations
  )],
  v2_reconstructed,
  by = c("zone", "datetime"),
  all = TRUE
)

reconstruction_check <- chk[, .(
  v2_rows = sum(is.finite(WPD_v2)),
  reconstructed_rows = sum(is.finite(WPD_reconstructed)),
  matched_rows = sum(
    is.finite(WPD_v2) &
      is.finite(WPD_reconstructed)
  ),
  max_abs_VV_difference = max(
    abs(VV_v2 - VV_reconstructed),
    na.rm = TRUE
  ),
  max_abs_WPD_difference = max(
    abs(WPD_v2 - WPD_reconstructed),
    na.rm = TRUE
  ),
  station_count_match = all(
    n_stations_v2 == n_stations_reconstructed,
    na.rm = TRUE
  )
)]

if (
  reconstruction_check$v2_rows !=
    reconstruction_check$reconstructed_rows ||
  reconstruction_check$matched_rows !=
    reconstruction_check$v2_rows ||
  reconstruction_check$max_abs_VV_difference > 1e-10 ||
  reconstruction_check$max_abs_WPD_difference > 1e-8 ||
  !reconstruction_check$station_count_match
) {
  stop("Exact canonical V2 reconstruction FAILED.")
}

log_msg("Canonical V2 reconstruction PASSED.")

# ============================================================
# 9. Station-level post-QC physical summaries
# ============================================================

station_summary <- sh[, .(
  n_station_hours = .N,
  n_days = uniqueN(as.Date(datetime)),
  pct_zone_hours_present =
    100 * .N / v2[zone == .BY$zone, .N],
  mean_VV = mean(VV_station_hour),
  median_VV = median(VV_station_hour),
  p95_VV = quantile(
    VV_station_hour,
    0.95,
    names = FALSE
  ),
  p99_VV = quantile(
    VV_station_hour,
    0.99,
    names = FALSE
  ),
  max_VV = max(VV_station_hour),
  mean_WPD = mean(WPD_station_hour),
  median_WPD = median(WPD_station_hour),
  p95_WPD = quantile(
    WPD_station_hour,
    0.95,
    names = FALSE
  ),
  p99_WPD = quantile(
    WPD_station_hour,
    0.99,
    names = FALSE
  ),
  max_WPD = max(WPD_station_hour),
  pct_hours_as_sole_contributor =
    100 * mean(n_stations_zonehour == 1L),
  n_hours_as_sole_contributor =
    sum(n_stations_zonehour == 1L),
  n_hours_coobserved =
    sum(n_stations_zonehour >= 2L)
), by = .(
  zone,
  station
)]

# ============================================================
# 10. Direct contribution shares to zonal mean WPD
#
# At each zone-hour:
#   zonal WPD = sum_i(WPD_i / n_stations)
#
# Therefore the contribution of station i to the overall zonal
# mean is:
#   sum_t[ WPD_i(t) / n_stations(t) ] / N_zone_hours
#
# Missing station-hours contribute zero, exactly matching the
# equal-station zonal mean construction.
# ============================================================

sh[, weighted_WPD_contribution :=
     WPD_station_hour / n_stations_zonehour]

station_contribution <- sh[, .(
  sum_weighted_WPD = sum(weighted_WPD_contribution),
  n_station_hours = .N
), by = .(
  zone,
  station
)]

zone_denominator <- v2[, .(
  n_zone_hours = .N,
  mean_WPD_zone = mean(WPD)
), by = zone]

station_contribution <- merge(
  station_contribution,
  zone_denominator,
  by = "zone",
  all.x = TRUE
)

station_contribution[, `:=`(
  mean_WPD_contribution =
    sum_weighted_WPD / n_zone_hours,
  pct_of_zonal_mean_WPD =
    100 *
    (sum_weighted_WPD / n_zone_hours) /
    mean_WPD_zone
)]

setorder(
  station_contribution,
  zone,
  -pct_of_zonal_mean_WPD
)

contribution_check <- station_contribution[, .(
  sum_pct_contribution =
    sum(pct_of_zonal_mean_WPD),
  reconstructed_mean_WPD =
    sum(mean_WPD_contribution),
  canonical_mean_WPD =
    unique(mean_WPD_zone),
  abs_difference =
    abs(
      sum(mean_WPD_contribution) -
        unique(mean_WPD_zone)
    )
), by = zone]

if (
  any(abs(contribution_check$sum_pct_contribution - 100) > 1e-8) ||
  any(contribution_check$abs_difference > 1e-8)
) {
  stop("Station contribution decomposition FAILED.")
}

# ============================================================
# 11. Paired-support LOSO
#
# Compare V2 baseline and reduced series only on timestamps that
# remain after station removal.
# ============================================================

stations <- unique(
  sh[, .(
    zone,
    station
  )]
)

setorder(stations, zone, station)

paired_list <- vector(
  "list",
  nrow(stations)
)

coobserved_list <- vector(
  "list",
  nrow(stations)
)

for (i in seq_len(nrow(stations))) {

  z <- stations$zone[i]
  s <- stations$station[i]

  base_z <- v2[
    zone == z,
    .(
      datetime,
      VV_base = VV,
      WPD_base = WPD,
      n_stations_base = n_stations
    )
  ]

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

  paired <- merge(
    base_z,
    reduced,
    by = "datetime",
    all = FALSE
  )

  paired_list[[i]] <- data.table(
    zone = z,
    removed_station = s,
    baseline_zone_hours = nrow(base_z),
    paired_zone_hours = nrow(paired),
    pct_baseline_hours_on_paired_support =
      100 * nrow(paired) / nrow(base_z),

    baseline_mean_VV_paired =
      mean(paired$VV_base),
    loso_mean_VV_paired =
      mean(paired$VV_loso),
    pct_change_mean_VV_paired =
      100 *
      (
        mean(paired$VV_loso) -
          mean(paired$VV_base)
      ) /
      mean(paired$VV_base),

    baseline_mean_WPD_paired =
      mean(paired$WPD_base),
    loso_mean_WPD_paired =
      mean(paired$WPD_loso),
    pct_change_mean_WPD_paired =
      100 *
      (
        mean(paired$WPD_loso) -
          mean(paired$WPD_base)
      ) /
      mean(paired$WPD_base)
  )

  # ----------------------------------------------------------
  # Co-observed support:
  # station s is present AND at least one other station is present.
  # This isolates the direct effect of removing s where a
  # within-hour alternative actually exists.
  # ----------------------------------------------------------

  co_times <- sh[
    zone == z &
      station == s &
      n_stations_zonehour >= 2L,
    unique(datetime)
  ]

  if (length(co_times) > 0L) {

    base_co <- base_z[
      datetime %in% co_times
    ]

    red_co <- reduced[
      datetime %in% co_times
    ]

    co <- merge(
      base_co,
      red_co,
      by = "datetime",
      all = FALSE
    )

    coobserved_list[[i]] <- data.table(
      zone = z,
      removed_station = s,
      n_coobserved_hours = nrow(co),
      baseline_mean_VV_coobserved =
        mean(co$VV_base),
      loso_mean_VV_coobserved =
        mean(co$VV_loso),
      pct_change_mean_VV_coobserved =
        100 *
        (
          mean(co$VV_loso) -
            mean(co$VV_base)
        ) /
        mean(co$VV_base),
      baseline_mean_WPD_coobserved =
        mean(co$WPD_base),
      loso_mean_WPD_coobserved =
        mean(co$WPD_loso),
      pct_change_mean_WPD_coobserved =
        100 *
        (
          mean(co$WPD_loso) -
            mean(co$WPD_base)
        ) /
        mean(co$WPD_base)
    )

  } else {

    coobserved_list[[i]] <- data.table(
      zone = z,
      removed_station = s,
      n_coobserved_hours = 0L,
      baseline_mean_VV_coobserved = NA_real_,
      loso_mean_VV_coobserved = NA_real_,
      pct_change_mean_VV_coobserved = NA_real_,
      baseline_mean_WPD_coobserved = NA_real_,
      loso_mean_WPD_coobserved = NA_real_,
      pct_change_mean_WPD_coobserved = NA_real_
    )
  }
}

paired_loso <- rbindlist(
  paired_list,
  fill = TRUE
)

coobserved_loso <- rbindlist(
  coobserved_list,
  fill = TRUE
)

# data.table::setorder() accepts column names, not expressions such
# as -abs(column). Create temporary absolute-value columns, order by
# them, and then remove them.
paired_loso[
  ,
  abs_pct_change_mean_WPD_paired :=
    abs(pct_change_mean_WPD_paired)
]

setorder(
  paired_loso,
  zone,
  -abs_pct_change_mean_WPD_paired
)

paired_loso[
  ,
  abs_pct_change_mean_WPD_paired := NULL
]

coobserved_loso[
  ,
  abs_pct_change_mean_WPD_coobserved :=
    abs(pct_change_mean_WPD_coobserved)
]

setorder(
  coobserved_loso,
  zone,
  -abs_pct_change_mean_WPD_coobserved
)

coobserved_loso[
  ,
  abs_pct_change_mean_WPD_coobserved := NULL
]

# ============================================================
# 12. Zone-level sensitivity summaries
# ============================================================

paired_zone_summary <- paired_loso[, .(
  n_stations_tested = .N,
  max_abs_pct_change_mean_WPD_paired =
    max(
      abs(pct_change_mean_WPD_paired),
      na.rm = TRUE
    ),
  station_max_paired_WPD_influence =
    removed_station[
      which.max(
        abs(pct_change_mean_WPD_paired)
      )
    ],
  max_abs_pct_change_mean_VV_paired =
    max(
      abs(pct_change_mean_VV_paired),
      na.rm = TRUE
    ),
  min_paired_support_pct =
    min(
      pct_baseline_hours_on_paired_support,
      na.rm = TRUE
    )
), by = zone][order(zone)]

coobserved_zone_summary <- coobserved_loso[
  is.finite(pct_change_mean_WPD_coobserved),
  .(
    n_stations_tested = .N,
    max_abs_pct_change_mean_WPD_coobserved =
      max(
        abs(pct_change_mean_WPD_coobserved),
        na.rm = TRUE
      ),
    station_max_coobserved_WPD_influence =
      removed_station[
        which.max(
          abs(pct_change_mean_WPD_coobserved)
        )
      ]
  ),
  by = zone
][order(zone)]

# ============================================================
# 13. Merge compact station influence table
# ============================================================

station_influence <- merge(
  station_summary,
  station_contribution[
    ,
    .(
      zone,
      station,
      mean_WPD_contribution,
      pct_of_zonal_mean_WPD
    )
  ],
  by = c("zone", "station"),
  all.x = TRUE
)

station_influence <- merge(
  station_influence,
  paired_loso[
    ,
    .(
      zone,
      station = removed_station,
      pct_baseline_hours_on_paired_support,
      pct_change_mean_WPD_paired
    )
  ],
  by = c("zone", "station"),
  all.x = TRUE
)

station_influence <- merge(
  station_influence,
  coobserved_loso[
    ,
    .(
      zone,
      station = removed_station,
      n_coobserved_hours,
      pct_change_mean_WPD_coobserved
    )
  ],
  by = c("zone", "station"),
  all.x = TRUE
)

setorder(
  station_influence,
  zone,
  -pct_of_zonal_mean_WPD
)

# ============================================================
# 14. Save outputs
# ============================================================

write.xlsx(
  reconstruction_check,
  file.path(
    DIR_TABLES,
    "R1_09_V2_exact_reconstruction_check.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  station_summary,
  file.path(
    DIR_TABLES,
    "R1_09_station_postQC_physical_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  station_contribution,
  file.path(
    DIR_TABLES,
    "R1_09_station_contribution_to_zonal_WPD.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  contribution_check,
  file.path(
    DIR_TABLES,
    "R1_09_contribution_decomposition_check.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  paired_loso,
  file.path(
    DIR_TABLES,
    "R1_09_paired_support_LOSO.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  coobserved_loso,
  file.path(
    DIR_TABLES,
    "R1_09_coobserved_LOSO.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  paired_zone_summary,
  file.path(
    DIR_TABLES,
    "R1_09_paired_LOSO_zone_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  coobserved_zone_summary,
  file.path(
    DIR_TABLES,
    "R1_09_coobserved_LOSO_zone_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  station_influence,
  file.path(
    DIR_TABLES,
    "R1_09_station_influence_compact.xlsx"
  ),
  overwrite = TRUE
)

saveRDS(
  list(
    reconstruction_check = reconstruction_check,
    station_summary = station_summary,
    station_contribution = station_contribution,
    contribution_check = contribution_check,
    paired_LOSO = paired_loso,
    coobserved_LOSO = coobserved_loso,
    paired_zone_summary = paired_zone_summary,
    coobserved_zone_summary = coobserved_zone_summary,
    station_influence = station_influence
  ),
  file.path(
    DIR_RESULTS,
    "R1_09_paired_LOSO_station_influence.rds"
  )
)

# ============================================================
# 15. Compact report for ChatGPT
# ============================================================

summary_lines <- capture.output({

  cat("============================================================\n")
  cat("R1-09 PAIRED LOSO / STATION INFLUENCE — SUMMARY FOR CHATGPT\n")
  cat("============================================================\n")

  cat("\n============================================================\n")
  cat("EXACT V2 RECONSTRUCTION CHECK\n")
  cat("============================================================\n")
  print(reconstruction_check)

  cat("\n============================================================\n")
  cat("DIRECT STATION CONTRIBUTION TO ZONAL MEAN WPD\n")
  cat("============================================================\n")
  print(
    station_contribution[
      ,
      .(
        zone,
        station,
        n_station_hours,
        mean_WPD_contribution,
        pct_of_zonal_mean_WPD
      )
    ]
  )

  cat("\n============================================================\n")
  cat("CONTRIBUTION DECOMPOSITION CHECK\n")
  cat("============================================================\n")
  print(contribution_check)

  cat("\n============================================================\n")
  cat("PAIRED-SUPPORT LOSO\n")
  cat("============================================================\n")
  print(paired_loso)

  cat("\n============================================================\n")
  cat("PAIRED-SUPPORT LOSO — ZONE SUMMARY\n")
  cat("============================================================\n")
  print(paired_zone_summary)

  cat("\n============================================================\n")
  cat("CO-OBSERVED LOSO\n")
  cat("============================================================\n")
  print(coobserved_loso)

  cat("\n============================================================\n")
  cat("CO-OBSERVED LOSO — ZONE SUMMARY\n")
  cat("============================================================\n")
  print(coobserved_zone_summary)

  cat("\n============================================================\n")
  cat("COMPACT STATION INFLUENCE TABLE\n")
  cat("============================================================\n")
  print(
    station_influence[
      ,
      .(
        zone,
        station,
        pct_zone_hours_present,
        mean_VV,
        mean_WPD,
        pct_hours_as_sole_contributor,
        pct_of_zonal_mean_WPD,
        pct_baseline_hours_on_paired_support,
        pct_change_mean_WPD_paired,
        n_coobserved_hours,
        pct_change_mean_WPD_coobserved
      )
    ]
  )

  cat("\n============================================================\n")
  cat("DECISION RULE\n")
  cat("============================================================\n")
  cat(
    "Use paired-support and co-observed LOSO for scientific interpretation ",
    "of station influence. The unpaired R1-08 LOSO mixes station removal ",
    "with temporal-support changes and must not be used alone to quantify ",
    "station effect. V2 itself is unchanged by this audit.\n",
    sep = ""
  )

  cat("\nR1-09 COMPLETED SUCCESSFULLY\n")
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

log_msg("R1-09 completed successfully.")
log_msg("Summary to upload:", SUMMARY_FILE)

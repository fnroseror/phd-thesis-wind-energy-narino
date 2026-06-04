# ============================================================
# 06I_temporal_dependence_acf_pacf_article1.R
# ARTICLE 1 — ENERGY REPORTS
# Temporal dependence analysis using ACF and PACF
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
  "zoo",
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
  library(zoo)
  library(openxlsx)
})

# ============================================================
# 2. Paths
# ============================================================

ARTICLE_ROOT <- "E:/Academia/UNAL/DOCTORADO/Productos/Articulo 1"

DIR_DATA_PROCESSED <- file.path(ARTICLE_ROOT, "01_data_processed")
DIR_RESULTS        <- file.path(ARTICLE_ROOT, "02_results")
DIR_FIGURES        <- file.path(ARTICLE_ROOT, "03_figures")
DIR_FIGURES_FINAL  <- file.path(DIR_FIGURES, "publication_ready_final")
DIR_TABLES         <- file.path(ARTICLE_ROOT, "04_tables")
DIR_LOGS           <- file.path(ARTICLE_ROOT, "logs")

dirs <- c(
  DIR_DATA_PROCESSED,
  DIR_RESULTS,
  DIR_FIGURES,
  DIR_FIGURES_FINAL,
  DIR_TABLES,
  DIR_LOGS
)

invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))

INPUT_MAIN_WPD <- file.path(
  DIR_DATA_PROCESSED,
  "02E_article_main_wpd_dataset_after_qc.rds"
)

if (!file.exists(INPUT_MAIN_WPD)) {
  stop("Main QC dataset not found: ", INPUT_MAIN_WPD)
}

log_file <- file.path(DIR_LOGS, "06I_temporal_dependence_acf_pacf_article1_log.txt")

log_msg <- function(...) {
  msg <- paste0(
    format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    " | ",
    paste(..., collapse = " ")
  )
  cat(msg, "\n")
  cat(msg, "\n", file = log_file, append = TRUE)
}

log_msg("Starting temporal dependence analysis using ACF and PACF.")

# ============================================================
# 3. Load and standardize dataset
# ============================================================

dt <- readRDS(INPUT_MAIN_WPD)
dt <- as.data.table(dt)

required_columns <- c("zone", "datetime", "VV", "WPD", "rho_used")

missing_columns <- setdiff(required_columns, names(dt))

if (length(missing_columns) > 0) {
  stop(
    "Main dataset is missing required columns: ",
    paste(missing_columns, collapse = ", ")
  )
}

dt[, datetime := as.POSIXct(datetime, tz = "America/Bogota")]
dt[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
dt[, VV := suppressWarnings(as.numeric(VV))]
dt[, WPD := suppressWarnings(as.numeric(WPD))]
dt[, rho_used := suppressWarnings(as.numeric(rho_used))]
dt[, date := as.Date(datetime)]
dt[, year := year(datetime)]
dt[, month := month(datetime)]
dt[, year_month := format(datetime, "%Y-%m")]

dt <- dt[
  !is.na(zone) &
    !is.na(datetime) &
    !is.na(VV) &
    !is.na(WPD) &
    is.finite(VV) &
    is.finite(WPD) &
    VV >= 0 &
    WPD >= 0
]

log_msg("Dataset loaded.")
log_msg("Rows:", nrow(dt))
log_msg("Zones:", uniqueN(dt$zone))
log_msg("Min datetime:", as.character(min(dt$datetime, na.rm = TRUE)))
log_msg("Max datetime:", as.character(max(dt$datetime, na.rm = TRUE)))

# ============================================================
# 4. Labels and palettes
# ============================================================

zone_labels <- c(
  "1" = "Zone 1",
  "2" = "Zone 2",
  "3" = "Zone 3",
  "4" = "Zone 4"
)

zone_palette <- c(
  "1" = "#0072B2",
  "2" = "#D55E00",
  "3" = "#009E73",
  "4" = "#CC79A7"
)

variable_palette <- c(
  "VV" = "#0072B2",
  "WPD" = "#D55E00"
)

# ============================================================
# 5. Theme and save helper
# ============================================================

theme_pub <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
      plot.subtitle = element_text(size = 12, hjust = 0.5),
      axis.title = element_text(face = "bold", size = 13),
      axis.text = element_text(color = "black", size = 11),
      legend.title = element_text(face = "bold", size = 12),
      legend.text = element_text(size = 10.5),
      strip.text = element_text(face = "bold", size = 12),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(color = "grey85", linewidth = 0.3),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),
      strip.background = element_rect(fill = "white", color = "black", linewidth = 0.5),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      legend.position = "bottom",
      legend.box = "horizontal",
      plot.margin = margin(8, 8, 8, 8)
    )
}

save_pub_plot <- function(plot_object, filename_base, width = 8, height = 6) {
  
  png_path  <- file.path(DIR_FIGURES_FINAL, paste0(filename_base, ".png"))
  tiff_path <- file.path(DIR_FIGURES_FINAL, paste0(filename_base, ".tiff"))
  pdf_path  <- file.path(DIR_FIGURES_FINAL, paste0(filename_base, ".pdf"))
  
  ggsave(
    filename = png_path,
    plot = plot_object,
    width = width,
    height = height,
    dpi = 600,
    units = "in",
    bg = "white",
    limitsize = FALSE
  )
  
  ggsave(
    filename = tiff_path,
    plot = plot_object,
    width = width,
    height = height,
    dpi = 600,
    units = "in",
    bg = "white",
    compression = "lzw",
    limitsize = FALSE
  )
  
  ggsave(
    filename = pdf_path,
    plot = plot_object,
    width = width,
    height = height,
    units = "in",
    bg = "white",
    limitsize = FALSE
  )
  
  log_msg("Saved:", png_path)
  log_msg("Saved:", tiff_path)
  log_msg("Saved:", pdf_path)
}

# ============================================================
# 6. Daily aggregation
# ============================================================

daily_summary <- dt[, .(
  n_records = .N,
  mean_VV = mean(VV, na.rm = TRUE),
  median_VV = median(VV, na.rm = TRUE),
  mean_WPD = mean(WPD, na.rm = TRUE),
  median_WPD = median(WPD, na.rm = TRUE),
  mean_rho_used = mean(rho_used, na.rm = TRUE)
), by = .(
  zone,
  date
)]

start_date <- min(dt$date, na.rm = TRUE)
end_date <- max(dt$date, na.rm = TRUE)

full_dates <- seq.Date(
  from = start_date,
  to = end_date,
  by = "day"
)

daily_grid <- as.data.table(
  expand.grid(
    zone = c("1", "2", "3", "4"),
    date = full_dates,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
)

daily_grid[, zone := factor(zone, levels = c("1", "2", "3", "4"))]

daily_grid <- merge(
  daily_grid,
  daily_summary,
  by = c("zone", "date"),
  all.x = TRUE
)

setorder(daily_grid, zone, date)

daily_grid[, day_index := as.integer(date - min(date)) + 1, by = zone]

# ============================================================
# 7. Short-gap interpolation for temporal diagnostics
# ============================================================

# Conservative rule:
# ACF/PACF require regular series.
# Short gaps up to 7 days are interpolated.
# Larger gaps remain missing and are not hidden in coverage tables.

daily_grid[, mean_VV_interp := zoo::na.approx(
  mean_VV,
  x = date,
  na.rm = FALSE,
  maxgap = 7
), by = zone]

daily_grid[, mean_WPD_interp := zoo::na.approx(
  mean_WPD,
  x = date,
  na.rm = FALSE,
  maxgap = 7
), by = zone]

daily_coverage <- daily_grid[, .(
  n_days = .N,
  
  n_days_with_VV = sum(!is.na(mean_VV)),
  pct_days_with_VV = round(100 * mean(!is.na(mean_VV)), 3),
  n_days_interpolated_VV = sum(is.na(mean_VV) & !is.na(mean_VV_interp)),
  n_days_remaining_missing_VV = sum(is.na(mean_VV_interp)),
  pct_remaining_missing_VV = round(100 * mean(is.na(mean_VV_interp)), 3),
  
  n_days_with_WPD = sum(!is.na(mean_WPD)),
  pct_days_with_WPD = round(100 * mean(!is.na(mean_WPD)), 3),
  n_days_interpolated_WPD = sum(is.na(mean_WPD) & !is.na(mean_WPD_interp)),
  n_days_remaining_missing_WPD = sum(is.na(mean_WPD_interp)),
  pct_remaining_missing_WPD = round(100 * mean(is.na(mean_WPD_interp)), 3)
), by = zone][order(zone)]

write.xlsx(
  daily_coverage,
  file.path(DIR_TABLES, "06I_daily_temporal_coverage_by_zone.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  daily_grid,
  file.path(DIR_TABLES, "06I_daily_regularized_series_by_zone.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 8. Monthly aggregation for descriptive temporal support
# ============================================================

monthly_summary <- dt[, .(
  n_records = .N,
  mean_VV = mean(VV, na.rm = TRUE),
  median_VV = median(VV, na.rm = TRUE),
  mean_WPD = mean(WPD, na.rm = TRUE),
  median_WPD = median(WPD, na.rm = TRUE),
  mean_rho_used = mean(rho_used, na.rm = TRUE)
), by = .(
  zone,
  year_month
)]

monthly_summary[, date_month := as.Date(paste0(year_month, "-01"))]

start_month <- as.Date(format(min(dt$date, na.rm = TRUE), "%Y-%m-01"))
end_month <- as.Date(format(max(dt$date, na.rm = TRUE), "%Y-%m-01"))

full_months <- seq.Date(
  from = start_month,
  to = end_month,
  by = "month"
)

monthly_grid <- as.data.table(
  expand.grid(
    zone = c("1", "2", "3", "4"),
    date_month = full_months,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
)

monthly_grid[, zone := factor(zone, levels = c("1", "2", "3", "4"))]
monthly_grid[, year_month := format(date_month, "%Y-%m")]

monthly_grid <- merge(
  monthly_grid,
  monthly_summary,
  by = c("zone", "year_month", "date_month"),
  all.x = TRUE
)

setorder(monthly_grid, zone, date_month)

monthly_coverage <- monthly_grid[, .(
  n_months = .N,
  n_months_with_VV = sum(!is.na(mean_VV)),
  pct_months_with_VV = round(100 * mean(!is.na(mean_VV)), 3),
  n_months_with_WPD = sum(!is.na(mean_WPD)),
  pct_months_with_WPD = round(100 * mean(!is.na(mean_WPD)), 3)
), by = zone][order(zone)]

write.xlsx(
  monthly_coverage,
  file.path(DIR_TABLES, "06I_monthly_temporal_coverage_by_zone.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  monthly_grid,
  file.path(DIR_TABLES, "06I_monthly_regular_series_by_zone.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 9. ACF/PACF helper functions
# ============================================================

prepare_series_for_correlation <- function(x) {
  x <- as.numeric(x)
  x <- x[is.finite(x)]
  
  if (length(x) < 30) {
    return(NULL)
  }
  
  if (stats::sd(x, na.rm = TRUE) == 0) {
    return(NULL)
  }
  
  return(x)
}

compute_acf_table <- function(data_grid, value_col, variable_label, max_lag = 90) {
  
  out <- lapply(levels(data_grid$zone), function(z) {
    
    x <- data_grid[zone == z][[value_col]]
    x <- prepare_series_for_correlation(x)
    
    if (is.null(x)) {
      return(NULL)
    }
    
    lag_max_use <- min(max_lag, length(x) - 2)
    
    acf_obj <- stats::acf(
      x,
      lag.max = lag_max_use,
      plot = FALSE
    )
    
    data.table(
      zone = z,
      variable = variable_label,
      lag = as.integer(acf_obj$lag[, 1, 1]),
      correlation = as.numeric(acf_obj$acf[, 1, 1]),
      n_effective = length(x),
      significance_bound = 1.96 / sqrt(length(x))
    )
  })
  
  rbindlist(out, fill = TRUE)
}

compute_pacf_table <- function(data_grid, value_col, variable_label, max_lag = 60) {
  
  out <- lapply(levels(data_grid$zone), function(z) {
    
    x <- data_grid[zone == z][[value_col]]
    x <- prepare_series_for_correlation(x)
    
    if (is.null(x)) {
      return(NULL)
    }
    
    lag_max_use <- min(max_lag, length(x) - 2)
    
    pacf_obj <- stats::pacf(
      x,
      lag.max = lag_max_use,
      plot = FALSE
    )
    
    data.table(
      zone = z,
      variable = variable_label,
      lag = as.integer(pacf_obj$lag),
      correlation = as.numeric(pacf_obj$acf),
      n_effective = length(x),
      significance_bound = 1.96 / sqrt(length(x))
    )
  })
  
  rbindlist(out, fill = TRUE)
}

# ============================================================
# 10. Compute daily ACF/PACF
# ============================================================

acf_daily_VV <- compute_acf_table(
  daily_grid,
  value_col = "mean_VV_interp",
  variable_label = "VV",
  max_lag = 90
)

acf_daily_WPD <- compute_acf_table(
  daily_grid,
  value_col = "mean_WPD_interp",
  variable_label = "WPD",
  max_lag = 90
)

pacf_daily_VV <- compute_pacf_table(
  daily_grid,
  value_col = "mean_VV_interp",
  variable_label = "VV",
  max_lag = 60
)

pacf_daily_WPD <- compute_pacf_table(
  daily_grid,
  value_col = "mean_WPD_interp",
  variable_label = "WPD",
  max_lag = 60
)

acf_daily_all <- rbindlist(
  list(acf_daily_VV, acf_daily_WPD),
  fill = TRUE
)

pacf_daily_all <- rbindlist(
  list(pacf_daily_VV, pacf_daily_WPD),
  fill = TRUE
)

write.xlsx(
  acf_daily_all,
  file.path(DIR_TABLES, "06I_daily_ACF_values_VV_WPD_by_zone.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  pacf_daily_all,
  file.path(DIR_TABLES, "06I_daily_PACF_values_VV_WPD_by_zone.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 11. Temporal dependence summary
# ============================================================

summarize_correlation_decay <- function(corr_table, threshold = 0.2) {
  
  corr_table_no0 <- corr_table[lag > 0]
  
  out <- corr_table_no0[, {
    
    abs_corr <- abs(correlation)
    
    first_below_threshold <- suppressWarnings(min(lag[abs_corr < threshold], na.rm = TRUE))
    
    if (!is.finite(first_below_threshold)) {
      first_below_threshold <- NA_integer_
    }
    
    max_abs_corr_lag1_7 <- max(abs_corr[lag >= 1 & lag <= 7], na.rm = TRUE)
    max_abs_corr_lag8_30 <- max(abs_corr[lag >= 8 & lag <= 30], na.rm = TRUE)
    max_abs_corr_lag31_90 <- max(abs_corr[lag >= 31 & lag <= 90], na.rm = TRUE)
    
    data.table(
      n_lags = .N,
      lag1_correlation = correlation[lag == 1][1],
      max_abs_corr_lag1_7 = max_abs_corr_lag1_7,
      max_abs_corr_lag8_30 = max_abs_corr_lag8_30,
      max_abs_corr_lag31_90 = max_abs_corr_lag31_90,
      first_lag_abs_corr_below_0_2 = first_below_threshold,
      significance_bound = significance_bound[1]
    )
  }, by = .(
    zone,
    variable
  )]
  
  out[!is.finite(max_abs_corr_lag1_7), max_abs_corr_lag1_7 := NA_real_]
  out[!is.finite(max_abs_corr_lag8_30), max_abs_corr_lag8_30 := NA_real_]
  out[!is.finite(max_abs_corr_lag31_90), max_abs_corr_lag31_90 := NA_real_]
  
  out[order(variable, zone)]
}

acf_decay_summary <- summarize_correlation_decay(acf_daily_all, threshold = 0.2)
pacf_decay_summary <- summarize_correlation_decay(pacf_daily_all, threshold = 0.2)

write.xlsx(
  acf_decay_summary,
  file.path(DIR_TABLES, "06I_daily_ACF_temporal_decay_summary.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  pacf_decay_summary,
  file.path(DIR_TABLES, "06I_daily_PACF_temporal_decay_summary.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 12. Save results object
# ============================================================

temporal_results <- list(
  input_main_wpd = INPUT_MAIN_WPD,
  daily_coverage = daily_coverage,
  monthly_coverage = monthly_coverage,
  daily_grid = daily_grid,
  monthly_grid = monthly_grid,
  acf_daily_all = acf_daily_all,
  pacf_daily_all = pacf_daily_all,
  acf_decay_summary = acf_decay_summary,
  pacf_decay_summary = pacf_decay_summary
)

saveRDS(
  temporal_results,
  file.path(DIR_RESULTS, "06I_temporal_dependence_acf_pacf_article1.rds")
)

# ============================================================
# 13. Plot data
# ============================================================

acf_plot_WPD <- acf_daily_all[
  variable == "WPD" &
    lag > 0 &
    lag <= 90
]

acf_plot_VV <- acf_daily_all[
  variable == "VV" &
    lag > 0 &
    lag <= 90
]

pacf_plot_WPD <- pacf_daily_all[
  variable == "WPD" &
    lag > 0 &
    lag <= 60
]

pacf_plot_VV <- pacf_daily_all[
  variable == "VV" &
    lag > 0 &
    lag <= 60
]

acf_plot_WPD[, zone := factor(zone, levels = c("1", "2", "3", "4"))]
acf_plot_VV[, zone := factor(zone, levels = c("1", "2", "3", "4"))]
pacf_plot_WPD[, zone := factor(zone, levels = c("1", "2", "3", "4"))]
pacf_plot_VV[, zone := factor(zone, levels = c("1", "2", "3", "4"))]

acf_conf_WPD <- unique(acf_plot_WPD[, .(zone, significance_bound)])
acf_conf_VV <- unique(acf_plot_VV[, .(zone, significance_bound)])
pacf_conf_WPD <- unique(pacf_plot_WPD[, .(zone, significance_bound)])
pacf_conf_VV <- unique(pacf_plot_VV[, .(zone, significance_bound)])

# ============================================================
# 14. Figure 7 — Daily WPD ACF
# ============================================================

fig_07_wpd_acf <- ggplot(
  acf_plot_WPD,
  aes(x = lag, y = correlation, color = zone)
) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.35) +
  geom_hline(
    data = acf_conf_WPD,
    aes(yintercept = significance_bound),
    inherit.aes = FALSE,
    color = "grey45",
    linetype = "dashed",
    linewidth = 0.35
  ) +
  geom_hline(
    data = acf_conf_WPD,
    aes(yintercept = -significance_bound),
    inherit.aes = FALSE,
    color = "grey45",
    linetype = "dashed",
    linewidth = 0.35
  ) +
  geom_line(linewidth = 0.75) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_y_continuous(limits = c(-1, 1), breaks = seq(-1, 1, 0.5)) +
  labs(
    title = "Daily autocorrelation of wind power density by analytical zone",
    subtitle = "ACF estimated from daily regularized WPD series",
    x = "Lag (days)",
    y = "Autocorrelation"
  ) +
  theme_pub()

save_pub_plot(
  fig_07_wpd_acf,
  "Fig_07_daily_WPD_ACF_by_zone_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 15. Figure 8 — Daily WPD PACF
# ============================================================

fig_08_wpd_pacf <- ggplot(
  pacf_plot_WPD,
  aes(x = lag, y = correlation, color = zone)
) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.35) +
  geom_hline(
    data = pacf_conf_WPD,
    aes(yintercept = significance_bound),
    inherit.aes = FALSE,
    color = "grey45",
    linetype = "dashed",
    linewidth = 0.35
  ) +
  geom_hline(
    data = pacf_conf_WPD,
    aes(yintercept = -significance_bound),
    inherit.aes = FALSE,
    color = "grey45",
    linetype = "dashed",
    linewidth = 0.35
  ) +
  geom_col(width = 0.75, alpha = 0.85) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    labeller = labeller(zone = zone_labels)
  ) +
  scale_fill_manual(values = zone_palette, guide = "none") +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_y_continuous(limits = c(-1, 1), breaks = seq(-1, 1, 0.5)) +
  labs(
    title = "Daily partial autocorrelation of wind power density by analytical zone",
    subtitle = "PACF estimated from daily regularized WPD series",
    x = "Lag (days)",
    y = "Partial autocorrelation"
  ) +
  theme_pub()

save_pub_plot(
  fig_08_wpd_pacf,
  "Fig_08_daily_WPD_PACF_by_zone_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 16. Supplementary Figure S3 — Daily VV ACF
# ============================================================

fig_S3_vv_acf <- ggplot(
  acf_plot_VV,
  aes(x = lag, y = correlation, color = zone)
) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.35) +
  geom_hline(
    data = acf_conf_VV,
    aes(yintercept = significance_bound),
    inherit.aes = FALSE,
    color = "grey45",
    linetype = "dashed",
    linewidth = 0.35
  ) +
  geom_hline(
    data = acf_conf_VV,
    aes(yintercept = -significance_bound),
    inherit.aes = FALSE,
    color = "grey45",
    linetype = "dashed",
    linewidth = 0.35
  ) +
  geom_line(linewidth = 0.75) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_y_continuous(limits = c(-1, 1), breaks = seq(-1, 1, 0.5)) +
  labs(
    title = "Daily autocorrelation of wind speed by analytical zone",
    subtitle = "ACF estimated from daily regularized wind-speed series",
    x = "Lag (days)",
    y = "Autocorrelation"
  ) +
  theme_pub()

save_pub_plot(
  fig_S3_vv_acf,
  "Fig_S3_daily_VV_ACF_by_zone_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 17. Supplementary Figure S4 — Daily VV PACF
# ============================================================

fig_S4_vv_pacf <- ggplot(
  pacf_plot_VV,
  aes(x = lag, y = correlation, color = zone)
) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.35) +
  geom_hline(
    data = pacf_conf_VV,
    aes(yintercept = significance_bound),
    inherit.aes = FALSE,
    color = "grey45",
    linetype = "dashed",
    linewidth = 0.35
  ) +
  geom_hline(
    data = pacf_conf_VV,
    aes(yintercept = -significance_bound),
    inherit.aes = FALSE,
    color = "grey45",
    linetype = "dashed",
    linewidth = 0.35
  ) +
  geom_col(width = 0.75, alpha = 0.85) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_y_continuous(limits = c(-1, 1), breaks = seq(-1, 1, 0.5)) +
  labs(
    title = "Daily partial autocorrelation of wind speed by analytical zone",
    subtitle = "PACF estimated from daily regularized wind-speed series",
    x = "Lag (days)",
    y = "Partial autocorrelation"
  ) +
  theme_pub()

save_pub_plot(
  fig_S4_vv_pacf,
  "Fig_S4_daily_VV_PACF_by_zone_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 18. Captions
# ============================================================

captions <- data.table(
  figure_id = c(
    "Figure 7",
    "Figure 8",
    "Figure S3",
    "Figure S4"
  ),
  filename_base = c(
    "Fig_07_daily_WPD_ACF_by_zone_FINAL",
    "Fig_08_daily_WPD_PACF_by_zone_FINAL",
    "Fig_S3_daily_VV_ACF_by_zone_FINAL",
    "Fig_S4_daily_VV_PACF_by_zone_FINAL"
  ),
  recommendation = c(
    "Main text",
    "Main text or supplementary if figure limit is strict",
    "Supplementary material",
    "Supplementary material"
  ),
  draft_caption = c(
    "Daily autocorrelation function of wind power density by analytical zone. Dashed lines indicate approximate 95% significance bounds.",
    "Daily partial autocorrelation function of wind power density by analytical zone. Dashed lines indicate approximate 95% significance bounds.",
    "Daily autocorrelation function of wind speed by analytical zone. Dashed lines indicate approximate 95% significance bounds.",
    "Daily partial autocorrelation function of wind speed by analytical zone. Dashed lines indicate approximate 95% significance bounds."
  )
)

write.xlsx(
  captions,
  file.path(DIR_TABLES, "06I_temporal_dependence_figure_captions.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 19. Final table for article
# ============================================================

temporal_table_for_article <- merge(
  acf_decay_summary[variable == "WPD"],
  daily_coverage,
  by = "zone",
  all.x = TRUE
)

write.xlsx(
  temporal_table_for_article,
  file.path(DIR_TABLES, "06I_temporal_dependence_summary_table_for_article.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 20. Console report
# ============================================================

cat("\n============================================================\n")
cat("TEMPORAL DEPENDENCE ANALYSIS — ACF/PACF — ARTICLE 1\n")
cat("============================================================\n\n")

cat("Input main dataset:\n")
cat(INPUT_MAIN_WPD, "\n\n")

cat("Dataset summary:\n")
print(data.table(
  n_records = nrow(dt),
  n_zones = uniqueN(dt$zone),
  min_datetime = min(dt$datetime, na.rm = TRUE),
  max_datetime = max(dt$datetime, na.rm = TRUE),
  mean_VV = mean(dt$VV, na.rm = TRUE),
  median_VV = median(dt$VV, na.rm = TRUE),
  mean_WPD = mean(dt$WPD, na.rm = TRUE),
  median_WPD = median(dt$WPD, na.rm = TRUE)
))

cat("\nDaily temporal coverage by zone:\n")
print(daily_coverage)

cat("\nMonthly temporal coverage by zone:\n")
print(monthly_coverage)

cat("\nDaily ACF temporal decay summary:\n")
print(acf_decay_summary)

cat("\nDaily PACF temporal decay summary:\n")
print(pacf_decay_summary)

cat("\nFigures exported to:\n")
cat(DIR_FIGURES_FINAL, "\n\n")

cat("Main / candidate main figures:\n")
cat("- Fig_07_daily_WPD_ACF_by_zone_FINAL\n")
cat("- Fig_08_daily_WPD_PACF_by_zone_FINAL\n\n")

cat("Supplementary figures:\n")
cat("- Fig_S3_daily_VV_ACF_by_zone_FINAL\n")
cat("- Fig_S4_daily_VV_PACF_by_zone_FINAL\n\n")

cat("Tables exported:\n")
cat("- 04_tables/06I_daily_temporal_coverage_by_zone.xlsx\n")
cat("- 04_tables/06I_monthly_temporal_coverage_by_zone.xlsx\n")
cat("- 04_tables/06I_daily_ACF_values_VV_WPD_by_zone.xlsx\n")
cat("- 04_tables/06I_daily_PACF_values_VV_WPD_by_zone.xlsx\n")
cat("- 04_tables/06I_daily_ACF_temporal_decay_summary.xlsx\n")
cat("- 04_tables/06I_daily_PACF_temporal_decay_summary.xlsx\n")
cat("- 04_tables/06I_temporal_dependence_summary_table_for_article.xlsx\n")
cat("- 02_results/06I_temporal_dependence_acf_pacf_article1.rds\n")
cat("============================================================\n")

log_msg("Temporal dependence analysis using ACF/PACF completed successfully.")

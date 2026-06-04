# ============================================================
# 07J_fft_spectral_analysis_article1.R
# ARTICLE 1 — ENERGY REPORTS
# Spectral analysis using FFT for daily VV and WPD series
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

log_file <- file.path(DIR_LOGS, "07J_fft_spectral_analysis_article1_log.txt")

log_msg <- function(...) {
  msg <- paste0(
    format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    " | ",
    paste(..., collapse = " ")
  )
  cat(msg, "\n")
  cat(msg, "\n", file = log_file, append = TRUE)
}

log_msg("Starting FFT spectral analysis.")

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
# 4. Labels, palettes and theme
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

band_palette <- c(
  "2–10 days" = "#0072B2",
  "10–30 days" = "#D55E00",
  "30–120 days" = "#009E73",
  "120–365 days" = "#CC79A7",
  ">365 days" = "#7F7F7F"
)

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
      panel.grid.major.x = element_line(color = "grey90", linewidth = 0.25),
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

save_pub_plot <- function(plot_object, filename_base, width = 9, height = 6.6) {
  
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
# 5. Daily aggregation and regular grid
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

# Short-gap interpolation only
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
  n_days_with_WPD = sum(!is.na(mean_WPD)),
  pct_days_with_WPD = round(100 * mean(!is.na(mean_WPD)), 3),
  n_days_remaining_missing_VV_after_short_interpolation = sum(is.na(mean_VV_interp)),
  pct_remaining_missing_VV_after_short_interpolation = round(100 * mean(is.na(mean_VV_interp)), 3),
  n_days_remaining_missing_WPD_after_short_interpolation = sum(is.na(mean_WPD_interp)),
  pct_remaining_missing_WPD_after_short_interpolation = round(100 * mean(is.na(mean_WPD_interp)), 3)
), by = zone][order(zone)]

write.xlsx(
  daily_coverage,
  file.path(DIR_TABLES, "07J_daily_temporal_coverage_for_FFT_by_zone.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  daily_grid,
  file.path(DIR_TABLES, "07J_daily_regularized_series_for_FFT_by_zone.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 6. Helper functions for continuous segments and FFT
# ============================================================

get_longest_continuous_segment <- function(data_zone, value_col) {
  
  temp <- copy(data_zone)
  temp[, value := get(value_col)]
  temp[, valid := !is.na(value) & is.finite(value)]
  
  if (sum(temp$valid) < 30) {
    return(data.table())
  }
  
  temp[, run_id := rleid(valid)]
  
  valid_runs <- temp[
    valid == TRUE,
    .(
      n_days = .N,
      start_date = min(date),
      end_date = max(date)
    ),
    by = run_id
  ][order(-n_days)]
  
  if (nrow(valid_runs) == 0) {
    return(data.table())
  }
  
  selected_run <- valid_runs$run_id[1]
  
  segment <- temp[
    run_id == selected_run & valid == TRUE
  ]
  
  return(segment)
}

hann_window <- function(n) {
  if (n <= 1) {
    return(rep(1, n))
  }
  
  0.5 - 0.5 * cos(2 * pi * seq(0, n - 1) / (n - 1))
}

compute_fft_spectrum <- function(segment, variable_label, value_col, min_length = 128) {
  
  if (nrow(segment) < min_length) {
    return(list(
      spectrum = data.table(),
      summary = data.table(
        variable = variable_label,
        n_segment_days = nrow(segment),
        start_date = ifelse(nrow(segment) > 0, as.character(min(segment$date)), NA_character_),
        end_date = ifelse(nrow(segment) > 0, as.character(max(segment$date)), NA_character_),
        status = "insufficient_continuous_segment"
      )
    ))
  }
  
  x <- as.numeric(segment[[value_col]])
  x <- x[is.finite(x)]
  
  n <- length(x)
  
  if (n < min_length || stats::sd(x, na.rm = TRUE) == 0) {
    return(list(
      spectrum = data.table(),
      summary = data.table(
        variable = variable_label,
        n_segment_days = n,
        start_date = as.character(min(segment$date)),
        end_date = as.character(max(segment$date)),
        status = "insufficient_variability"
      )
    ))
  }
  
  x_detrended <- residuals(lm(x ~ seq_along(x)))
  x_centered <- x_detrended - mean(x_detrended, na.rm = TRUE)
  
  win <- hann_window(n)
  x_windowed <- x_centered * win
  
  fft_values <- fft(x_windowed)
  
  # One-sided spectrum
  half_n <- floor(n / 2)
  
  frequencies <- (0:(half_n)) / n
  amplitudes <- Mod(fft_values[1:(half_n + 1)]) / n
  power <- amplitudes^2
  
  spectrum <- data.table(
    frequency_cycles_per_day = frequencies,
    amplitude = amplitudes,
    power = power
  )
  
  spectrum <- spectrum[frequency_cycles_per_day > 0]
  
  spectrum[, period_days := 1 / frequency_cycles_per_day]
  spectrum[, normalized_power := power / sum(power, na.rm = TRUE)]
  
  spectrum <- spectrum[
    is.finite(period_days) &
      is.finite(normalized_power) &
      period_days >= 2
  ]
  
  spectrum[, spectral_band := fifelse(
    period_days >= 2 & period_days < 10,
    "2–10 days",
    fifelse(
      period_days >= 10 & period_days < 30,
      "10–30 days",
      fifelse(
        period_days >= 30 & period_days < 120,
        "30–120 days",
        fifelse(
          period_days >= 120 & period_days <= 365,
          "120–365 days",
          ">365 days"
        )
      )
    )
  )]
  
  spectrum[, variable := variable_label]
  
  summary <- data.table(
    variable = variable_label,
    n_segment_days = n,
    start_date = as.character(min(segment$date)),
    end_date = as.character(max(segment$date)),
    mean_original = mean(x, na.rm = TRUE),
    sd_original = sd(x, na.rm = TRUE),
    status = "ok"
  )
  
  list(
    spectrum = spectrum,
    summary = summary
  )
}

extract_top_peaks <- function(spectrum, n_peaks = 5) {
  
  if (nrow(spectrum) == 0) {
    return(data.table())
  }
  
  # Restrict to interpretable periods for daily meteorological dynamics
  spec <- spectrum[
    period_days >= 2 &
      period_days <= 730
  ]
  
  if (nrow(spec) == 0) {
    return(data.table())
  }
  
  setorder(spec, -normalized_power)
  
  peaks <- spec[1:min(n_peaks, .N)]
  
  peaks[, rank_peak := seq_len(.N)]
  
  peaks[
    ,
    .(
      rank_peak,
      period_days,
      frequency_cycles_per_day,
      normalized_power,
      spectral_band
    )
  ]
}

compute_band_energy <- function(spectrum) {
  
  if (nrow(spectrum) == 0) {
    return(data.table())
  }
  
  band_order <- c(
    "2–10 days",
    "10–30 days",
    "30–120 days",
    "120–365 days",
    ">365 days"
  )
  
  out <- spectrum[
    ,
    .(
      band_power_share = sum(normalized_power, na.rm = TRUE)
    ),
    by = spectral_band
  ]
  
  out[, spectral_band := factor(spectral_band, levels = band_order)]
  setorder(out, spectral_band)
  
  out
}

# ============================================================
# 7. Compute FFT by zone and variable
# ============================================================

fft_results <- list()
segment_summary_list <- list()
top_peaks_list <- list()
band_energy_list <- list()

zones <- levels(daily_grid$zone)

for (z in zones) {
  
  log_msg("FFT analysis for zone:", z)
  
  data_zone <- daily_grid[zone == z]
  
  # VV
  segment_vv <- get_longest_continuous_segment(
    data_zone,
    value_col = "mean_VV_interp"
  )
  
  fft_vv <- compute_fft_spectrum(
    segment_vv,
    variable_label = "VV",
    value_col = "value",
    min_length = 128
  )
  
  if (nrow(fft_vv$spectrum) > 0) {
    fft_vv$spectrum[, zone := z]
    peaks_vv <- extract_top_peaks(fft_vv$spectrum, n_peaks = 5)
    peaks_vv[, zone := z]
    peaks_vv[, variable := "VV"]
    
    bands_vv <- compute_band_energy(fft_vv$spectrum)
    bands_vv[, zone := z]
    bands_vv[, variable := "VV"]
  } else {
    peaks_vv <- data.table()
    bands_vv <- data.table()
  }
  
  fft_vv$summary[, zone := z]
  
  # WPD
  segment_wpd <- get_longest_continuous_segment(
    data_zone,
    value_col = "mean_WPD_interp"
  )
  
  fft_wpd <- compute_fft_spectrum(
    segment_wpd,
    variable_label = "WPD",
    value_col = "value",
    min_length = 128
  )
  
  if (nrow(fft_wpd$spectrum) > 0) {
    fft_wpd$spectrum[, zone := z]
    peaks_wpd <- extract_top_peaks(fft_wpd$spectrum, n_peaks = 5)
    peaks_wpd[, zone := z]
    peaks_wpd[, variable := "WPD"]
    
    bands_wpd <- compute_band_energy(fft_wpd$spectrum)
    bands_wpd[, zone := z]
    bands_wpd[, variable := "WPD"]
  } else {
    peaks_wpd <- data.table()
    bands_wpd <- data.table()
  }
  
  fft_wpd$summary[, zone := z]
  
  fft_results[[paste0("zone_", z, "_VV")]] <- fft_vv$spectrum
  fft_results[[paste0("zone_", z, "_WPD")]] <- fft_wpd$spectrum
  
  segment_summary_list[[paste0("zone_", z, "_VV")]] <- fft_vv$summary
  segment_summary_list[[paste0("zone_", z, "_WPD")]] <- fft_wpd$summary
  
  top_peaks_list[[paste0("zone_", z, "_VV")]] <- peaks_vv
  top_peaks_list[[paste0("zone_", z, "_WPD")]] <- peaks_wpd
  
  band_energy_list[[paste0("zone_", z, "_VV")]] <- bands_vv
  band_energy_list[[paste0("zone_", z, "_WPD")]] <- bands_wpd
}

fft_spectrum_all <- rbindlist(fft_results, fill = TRUE)
fft_segment_summary <- rbindlist(segment_summary_list, fill = TRUE)
fft_top_peaks <- rbindlist(top_peaks_list, fill = TRUE)
fft_band_energy <- rbindlist(band_energy_list, fill = TRUE)

fft_spectrum_all[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
fft_segment_summary[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
fft_top_peaks[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
fft_band_energy[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]

# ============================================================
# 8. Export FFT tables
# ============================================================

write.xlsx(
  fft_segment_summary,
  file.path(DIR_TABLES, "07J_FFT_segment_summary_by_zone_variable.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  fft_top_peaks,
  file.path(DIR_TABLES, "07J_FFT_top_periods_by_zone_variable.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  fft_band_energy,
  file.path(DIR_TABLES, "07J_FFT_spectral_band_energy_by_zone_variable.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  fft_spectrum_all,
  file.path(DIR_TABLES, "07J_FFT_full_spectrum_by_zone_variable.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 9. Save result object
# ============================================================

fft_results_object <- list(
  input_main_wpd = INPUT_MAIN_WPD,
  daily_coverage = daily_coverage,
  daily_grid = daily_grid,
  fft_segment_summary = fft_segment_summary,
  fft_top_peaks = fft_top_peaks,
  fft_band_energy = fft_band_energy,
  fft_spectrum_all = fft_spectrum_all
)

saveRDS(
  fft_results_object,
  file.path(DIR_RESULTS, "07J_fft_spectral_analysis_article1.rds")
)

# ============================================================
# 10. Plot data
# ============================================================

plot_spectrum_wpd <- fft_spectrum_all[
  variable == "WPD" &
    period_days >= 2 &
    period_days <= 730
]

plot_spectrum_vv <- fft_spectrum_all[
  variable == "VV" &
    period_days >= 2 &
    period_days <= 730
]

plot_spectrum_wpd[, zone := factor(zone, levels = c("1", "2", "3", "4"))]
plot_spectrum_vv[, zone := factor(zone, levels = c("1", "2", "3", "4"))]

plot_band_wpd <- fft_band_energy[variable == "WPD"]
plot_band_vv <- fft_band_energy[variable == "VV"]

plot_band_wpd[, spectral_band := factor(
  as.character(spectral_band),
  levels = c("2–10 days", "10–30 days", "30–120 days", "120–365 days", ">365 days")
)]

plot_band_vv[, spectral_band := factor(
  as.character(spectral_band),
  levels = c("2–10 days", "10–30 days", "30–120 days", "120–365 days", ">365 days")
)]

# ============================================================
# 11. Figure 9 — WPD spectrum
# ============================================================

fig_09_wpd_fft <- ggplot(
  plot_spectrum_wpd,
  aes(
    x = period_days,
    y = normalized_power,
    color = zone
  )
) +
  geom_line(linewidth = 0.75, alpha = 0.95, na.rm = TRUE) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_continuous(
    trans = "log10",
    breaks = c(2, 5, 10, 30, 90, 180, 365, 730),
    labels = c("2", "5", "10", "30", "90", "180", "365", "730")
  ) +
  scale_y_continuous(labels = label_number(accuracy = 0.0001)) +
  labs(
    title = "Spectral power of daily wind power density by analytical zone",
    subtitle = "FFT applied to the longest continuous daily segment after short-gap interpolation",
    x = "Period (days, log scale)",
    y = "Normalized spectral power"
  ) +
  theme_pub()

save_pub_plot(
  fig_09_wpd_fft,
  "Fig_09_daily_WPD_FFT_spectrum_by_zone_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 12. Figure 10 — WPD spectral band energy
# ============================================================

fig_10_wpd_band <- ggplot(
  plot_band_wpd,
  aes(
    x = spectral_band,
    y = band_power_share,
    fill = spectral_band
  )
) +
  geom_col(color = "black", linewidth = 0.35, width = 0.72) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    labeller = labeller(zone = zone_labels)
  ) +
  scale_fill_manual(values = band_palette, guide = "none") +
  scale_y_continuous(
    labels = label_percent(accuracy = 1),
    limits = c(0, NA)
  ) +
  labs(
    title = "Spectral power distribution of daily wind power density",
    subtitle = "Relative contribution of physically interpretable period bands",
    x = "Period band",
    y = "Share of normalized spectral power"
  ) +
  theme_pub() +
  theme(
    axis.text.x = element_text(angle = 25, hjust = 1)
  )

save_pub_plot(
  fig_10_wpd_band,
  "Fig_10_daily_WPD_FFT_band_energy_by_zone_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 13. Supplementary Figure S5 — VV spectrum
# ============================================================

fig_S5_vv_fft <- ggplot(
  plot_spectrum_vv,
  aes(
    x = period_days,
    y = normalized_power,
    color = zone
  )
) +
  geom_line(linewidth = 0.75, alpha = 0.95, na.rm = TRUE) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_continuous(
    trans = "log10",
    breaks = c(2, 5, 10, 30, 90, 180, 365, 730),
    labels = c("2", "5", "10", "30", "90", "180", "365", "730")
  ) +
  scale_y_continuous(labels = label_number(accuracy = 0.0001)) +
  labs(
    title = "Spectral power of daily wind speed by analytical zone",
    subtitle = "FFT applied to the longest continuous daily segment after short-gap interpolation",
    x = "Period (days, log scale)",
    y = "Normalized spectral power"
  ) +
  theme_pub()

save_pub_plot(
  fig_S5_vv_fft,
  "Fig_S5_daily_VV_FFT_spectrum_by_zone_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 14. Supplementary Figure S6 — VV spectral band energy
# ============================================================

fig_S6_vv_band <- ggplot(
  plot_band_vv,
  aes(
    x = spectral_band,
    y = band_power_share,
    fill = spectral_band
  )
) +
  geom_col(color = "black", linewidth = 0.35, width = 0.72) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    labeller = labeller(zone = zone_labels)
  ) +
  scale_fill_manual(values = band_palette, guide = "none") +
  scale_y_continuous(
    labels = label_percent(accuracy = 1),
    limits = c(0, NA)
  ) +
  labs(
    title = "Spectral power distribution of daily wind speed",
    subtitle = "Relative contribution of physically interpretable period bands",
    x = "Period band",
    y = "Share of normalized spectral power"
  ) +
  theme_pub() +
  theme(
    axis.text.x = element_text(angle = 25, hjust = 1)
  )

save_pub_plot(
  fig_S6_vv_band,
  "Fig_S6_daily_VV_FFT_band_energy_by_zone_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 15. Captions
# ============================================================

captions <- data.table(
  figure_id = c(
    "Figure 9",
    "Figure 10",
    "Figure S5",
    "Figure S6"
  ),
  filename_base = c(
    "Fig_09_daily_WPD_FFT_spectrum_by_zone_FINAL",
    "Fig_10_daily_WPD_FFT_band_energy_by_zone_FINAL",
    "Fig_S5_daily_VV_FFT_spectrum_by_zone_FINAL",
    "Fig_S6_daily_VV_FFT_band_energy_by_zone_FINAL"
  ),
  recommendation = c(
    "Main text",
    "Main text or supplementary if figure limit is strict",
    "Supplementary material",
    "Supplementary material"
  ),
  draft_caption = c(
    "Spectral power of daily wind power density by analytical zone. FFT was applied to the longest continuous daily segment after short-gap interpolation.",
    "Relative contribution of physically interpretable period bands to the normalized spectral power of daily WPD.",
    "Spectral power of daily wind speed by analytical zone. FFT was applied to the longest continuous daily segment after short-gap interpolation.",
    "Relative contribution of physically interpretable period bands to the normalized spectral power of daily wind speed."
  )
)

write.xlsx(
  captions,
  file.path(DIR_TABLES, "07J_FFT_figure_captions.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 16. Main spectral table for article
# ============================================================

spectral_table_for_article <- merge(
  fft_top_peaks[variable == "WPD"],
  fft_segment_summary[variable == "WPD", .(
    zone,
    n_segment_days,
    start_date,
    end_date,
    status
  )],
  by = "zone",
  all.x = TRUE
)

setorder(spectral_table_for_article, zone, rank_peak)

write.xlsx(
  spectral_table_for_article,
  file.path(DIR_TABLES, "07J_WPD_top_spectral_periods_table_for_article.xlsx"),
  overwrite = TRUE
)

band_table_for_article <- fft_band_energy[variable == "WPD"]

write.xlsx(
  band_table_for_article,
  file.path(DIR_TABLES, "07J_WPD_spectral_band_energy_table_for_article.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 17. Console report
# ============================================================

cat("\n============================================================\n")
cat("FFT SPECTRAL ANALYSIS — ARTICLE 1\n")
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

cat("\nDaily temporal coverage for FFT by zone:\n")
print(daily_coverage)

cat("\nFFT segment summary:\n")
print(fft_segment_summary)

cat("\nTop spectral periods by zone and variable:\n")
print(fft_top_peaks)

cat("\nSpectral band energy by zone and variable:\n")
print(fft_band_energy)

cat("\nFigures exported to:\n")
cat(DIR_FIGURES_FINAL, "\n\n")

cat("Main / candidate main figures:\n")
cat("- Fig_09_daily_WPD_FFT_spectrum_by_zone_FINAL\n")
cat("- Fig_10_daily_WPD_FFT_band_energy_by_zone_FINAL\n\n")

cat("Supplementary figures:\n")
cat("- Fig_S5_daily_VV_FFT_spectrum_by_zone_FINAL\n")
cat("- Fig_S6_daily_VV_FFT_band_energy_by_zone_FINAL\n\n")

cat("Tables exported:\n")
cat("- 04_tables/07J_daily_temporal_coverage_for_FFT_by_zone.xlsx\n")
cat("- 04_tables/07J_FFT_segment_summary_by_zone_variable.xlsx\n")
cat("- 04_tables/07J_FFT_top_periods_by_zone_variable.xlsx\n")
cat("- 04_tables/07J_FFT_spectral_band_energy_by_zone_variable.xlsx\n")
cat("- 04_tables/07J_WPD_top_spectral_periods_table_for_article.xlsx\n")
cat("- 04_tables/07J_WPD_spectral_band_energy_table_for_article.xlsx\n")
cat("- 02_results/07J_fft_spectral_analysis_article1.rds\n")
cat("============================================================\n")

log_msg("FFT spectral analysis completed successfully.")

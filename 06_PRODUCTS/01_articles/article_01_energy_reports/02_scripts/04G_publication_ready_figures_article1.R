# ============================================================
# 04G_publication_ready_figures_article1.R
# ARTICLE 1 — ENERGY REPORTS
# Publication-ready figures for Article 1
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
  library(openxlsx)
})

# ============================================================
# 2. Paths
# ============================================================

ARTICLE_ROOT <- "E:/Academia/UNAL/DOCTORADO/Productos/Articulo 1"

DIR_DATA_PROCESSED <- file.path(ARTICLE_ROOT, "01_data_processed")
DIR_RESULTS        <- file.path(ARTICLE_ROOT, "02_results")
DIR_FIGURES        <- file.path(ARTICLE_ROOT, "03_figures")
DIR_FIGURES_PUB    <- file.path(DIR_FIGURES, "publication_ready")
DIR_TABLES         <- file.path(ARTICLE_ROOT, "04_tables")
DIR_LOGS           <- file.path(ARTICLE_ROOT, "logs")

dirs <- c(
  DIR_DATA_PROCESSED,
  DIR_RESULTS,
  DIR_FIGURES,
  DIR_FIGURES_PUB,
  DIR_TABLES,
  DIR_LOGS
)

invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))

INPUT_MAIN_WPD <- file.path(
  DIR_DATA_PROCESSED,
  "02E_article_main_wpd_dataset_after_qc.rds"
)

INPUT_QC_ALL <- file.path(
  DIR_DATA_PROCESSED,
  "02E_wpd_qc_scenarios_daily_zone_density.rds"
)

INPUT_DIST_RESULTS <- file.path(
  DIR_RESULTS,
  "03F_weibull_rayleigh_distribution_fitting.rds"
)

if (!file.exists(INPUT_MAIN_WPD)) {
  stop("Main QC dataset not found: ", INPUT_MAIN_WPD)
}

if (!file.exists(INPUT_QC_ALL)) {
  stop("QC scenarios dataset not found: ", INPUT_QC_ALL)
}

if (!file.exists(INPUT_DIST_RESULTS)) {
  stop("Distribution fitting results not found: ", INPUT_DIST_RESULTS)
}

log_file <- file.path(DIR_LOGS, "04G_publication_ready_figures_article1_log.txt")

log_msg <- function(...) {
  msg <- paste0(
    format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    " | ",
    paste(..., collapse = " ")
  )
  cat(msg, "\n")
  cat(msg, "\n", file = log_file, append = TRUE)
}

log_msg("Starting publication-ready figures generation.")

# ============================================================
# 3. Load data
# ============================================================

dt_main <- readRDS(INPUT_MAIN_WPD)
dt_main <- as.data.table(dt_main)

dt_qc_all <- readRDS(INPUT_QC_ALL)
dt_qc_all <- as.data.table(dt_qc_all)

dist_results <- readRDS(INPUT_DIST_RESULTS)

comparison_table   <- as.data.table(dist_results$comparison_table)
density_curve_data <- as.data.table(dist_results$density_curve_data)
cdf_curve_data     <- as.data.table(dist_results$cdf_curve_data)
best_distribution  <- as.data.table(dist_results$best_distribution_by_zone)

# ============================================================
# 4. Standardization
# ============================================================

dt_main[, datetime := as.POSIXct(datetime, tz = "America/Bogota")]
dt_main[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
dt_main[, year := year(datetime)]
dt_main[, month := month(datetime)]
dt_main[, year_month := format(datetime, "%Y-%m")]
dt_main[, VV := suppressWarnings(as.numeric(VV))]
dt_main[, WPD := suppressWarnings(as.numeric(WPD))]
dt_main[, rho_used := suppressWarnings(as.numeric(rho_used))]

dt_main <- dt_main[
  !is.na(datetime) &
    !is.na(zone) &
    !is.na(VV) &
    !is.na(WPD) &
    is.finite(VV) &
    is.finite(WPD)
]

dt_qc_all[, datetime := as.POSIXct(datetime, tz = "America/Bogota")]
dt_qc_all[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
dt_qc_all[, VV := suppressWarnings(as.numeric(VV))]
dt_qc_all[, WPD := suppressWarnings(as.numeric(WPD))]
dt_qc_all[, qc_scenario := as.character(qc_scenario)]

comparison_table[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
comparison_table[, distribution := as.character(distribution)]

density_curve_data[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
density_curve_data[, curve_type := as.character(curve_type)]
density_curve_data[, x := suppressWarnings(as.numeric(x))]
density_curve_data[, density := suppressWarnings(as.numeric(density))]

cdf_curve_data[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
cdf_curve_data[, curve_type := as.character(curve_type)]
cdf_curve_data[, x := suppressWarnings(as.numeric(x))]
cdf_curve_data[, CDF := suppressWarnings(as.numeric(CDF))]

best_distribution[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]

# ============================================================
# 5. Labels and palettes
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

curve_palette_density <- c(
  "Empirical density" = "#000000",
  "Weibull"           = "#0072B2",
  "Rayleigh"          = "#D55E00"
)

curve_palette_cdf <- c(
  "Empirical CDF" = "#000000",
  "Weibull"       = "#0072B2",
  "Rayleigh"      = "#D55E00"
)

curve_linetypes_density <- c(
  "Empirical density" = "solid",
  "Weibull"           = "dotted",
  "Rayleigh"          = "dashed"
)

curve_linetypes_cdf <- c(
  "Empirical CDF" = "solid",
  "Weibull"       = "dotted",
  "Rayleigh"      = "dashed"
)

qc_label_map <- c(
  "raw_daily_zone_rho"          = "Raw",
  "qc_vv_le_30"                 = "VV <= 30 m s^-1",
  "qc_vv_le_25"                 = "VV <= 25 m s^-1",
  "qc_vv_le_20"                 = "VV <= 20 m s^-1",
  "qc_wpd_le_5000"              = "WPD <= 5000 W m^-2",
  "qc_vv_le_25_and_wpd_le_5000" = "VV <= 25 and WPD <= 5000"
)

qc_palette <- c(
  "VV <= 20 m s^-1"          = "#000000",
  "VV <= 25 m s^-1"          = "#0072B2",
  "VV <= 30 m s^-1"          = "#D55E00",
  "WPD <= 5000 W m^-2"       = "#009E73",
  "VV <= 25 and WPD <= 5000" = "#CC79A7",
  "Raw"                      = "#7F7F7F"
)

# ============================================================
# 6. Theme and save helper
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
  
  png_path  <- file.path(DIR_FIGURES_PUB, paste0(filename_base, ".png"))
  tiff_path <- file.path(DIR_FIGURES_PUB, paste0(filename_base, ".tiff"))
  pdf_path  <- file.path(DIR_FIGURES_PUB, paste0(filename_base, ".pdf"))
  
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
# 7. Monthly summaries with explicit gaps
# ============================================================

monthly_main <- dt_main[, .(
  mean_VV  = mean(VV, na.rm = TRUE),
  mean_WPD = mean(WPD, na.rm = TRUE),
  median_WPD = median(WPD, na.rm = TRUE),
  n_records = .N
), by = .(zone, year_month)]

monthly_main[, date_month := as.Date(paste0(year_month, "-01"))]

start_month <- as.Date(format(min(dt_main$datetime, na.rm = TRUE), "%Y-%m-01"))
end_month   <- as.Date(format(max(dt_main$datetime, na.rm = TRUE), "%Y-%m-01"))

full_months <- seq.Date(
  from = start_month,
  to = end_month,
  by = "month"
)

full_grid <- as.data.table(
  expand.grid(
    zone = c("1", "2", "3", "4"),
    date_month = full_months,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
)

full_grid[, zone := factor(zone, levels = c("1", "2", "3", "4"))]
full_grid[, year_month := format(date_month, "%Y-%m")]

monthly_plot_data <- merge(
  full_grid,
  monthly_main,
  by = c("zone", "date_month", "year_month"),
  all.x = TRUE
)

setorder(monthly_plot_data, zone, date_month)

write.xlsx(
  monthly_plot_data,
  file.path(DIR_TABLES, "04G_monthly_plot_data_with_explicit_gaps.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 8. QC sensitivity summary
# ============================================================

qc_summary_plot <- dt_qc_all[
  !is.na(WPD) &
    is.finite(WPD),
  .(
    n_records = .N,
    mean_WPD = mean(WPD, na.rm = TRUE),
    median_WPD = median(WPD, na.rm = TRUE),
    max_WPD = max(WPD, na.rm = TRUE)
  ),
  by = .(zone, qc_scenario)
]

qc_summary_plot[, qc_label := qc_label_map[as.character(qc_scenario)]]

qc_summary_plot <- qc_summary_plot[!is.na(qc_label)]

qc_summary_plot[, qc_label := factor(
  qc_label,
  levels = c(
    "VV <= 20 m s^-1",
    "VV <= 25 m s^-1",
    "VV <= 30 m s^-1",
    "WPD <= 5000 W m^-2",
    "VV <= 25 and WPD <= 5000",
    "Raw"
  )
)]

write.xlsx(
  qc_summary_plot,
  file.path(DIR_TABLES, "04G_QC_sensitivity_summary_for_plot.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 9. Distribution curve labels — corrected without fifelse
# ============================================================

density_plot_data <- copy(density_curve_data)

density_plot_data <- density_plot_data[
  curve_type %in% c("empirical_density", "Weibull", "Rayleigh")
]

density_plot_data[, curve_label := as.character(curve_type)]
density_plot_data[curve_label == "empirical_density", curve_label := "Empirical density"]

density_plot_data[, curve_label := factor(
  curve_label,
  levels = c("Empirical density", "Weibull", "Rayleigh")
)]

density_plot_data <- density_plot_data[
  is.finite(x) &
    is.finite(density) &
    !is.na(curve_label)
]

cdf_plot_data <- copy(cdf_curve_data)

cdf_plot_data <- cdf_plot_data[
  curve_type %in% c("empirical_CDF", "Weibull", "Rayleigh")
]

cdf_plot_data[, curve_label := as.character(curve_type)]
cdf_plot_data[curve_label == "empirical_CDF", curve_label := "Empirical CDF"]

cdf_plot_data[, curve_label := factor(
  curve_label,
  levels = c("Empirical CDF", "Weibull", "Rayleigh")
)]

cdf_plot_data <- cdf_plot_data[
  is.finite(x) &
    is.finite(CDF) &
    !is.na(curve_label)
]

write.xlsx(
  density_plot_data,
  file.path(DIR_TABLES, "04G_density_plot_data_cleaned.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  cdf_plot_data,
  file.path(DIR_TABLES, "04G_cdf_plot_data_cleaned.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 10. AIC/BIC delta plot data
# ============================================================

aic_bic_plot_data <- melt(
  comparison_table[, .(zone, distribution, AIC, BIC)],
  id.vars = c("zone", "distribution"),
  variable.name = "criterion",
  value.name = "value"
)

aic_bic_plot_data[, distribution := factor(distribution, levels = c("Weibull", "Rayleigh"))]
aic_bic_plot_data[, criterion := factor(criterion, levels = c("AIC", "BIC"))]
aic_bic_plot_data[, value := as.numeric(value)]

aic_bic_plot_data <- aic_bic_plot_data[is.finite(value)]

aic_bic_plot_data[, delta_value := value - min(value, na.rm = TRUE), by = .(zone, criterion)]

write.xlsx(
  aic_bic_plot_data,
  file.path(DIR_TABLES, "04G_AIC_BIC_delta_plot_data.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 11. Figure 1 — Monthly mean wind speed
# ============================================================

fig_01_monthly_vv <- ggplot(
  monthly_plot_data,
  aes(x = date_month, y = mean_VV, color = zone, group = zone)
) +
  geom_line(linewidth = 0.85, na.rm = FALSE) +
  geom_point(size = 1.5, alpha = 0.75, na.rm = TRUE) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Monthly mean wind speed by analytical zone",
    subtitle = "Main quality-control scenario: VV <= 20 m s^-1",
    x = "Month",
    y = expression("Monthly mean " * V[V] * " (m s"^-1 * ")")
  ) +
  theme_pub()

save_pub_plot(
  fig_01_monthly_vv,
  "Fig_01_monthly_mean_wind_speed_by_zone",
  width = 9,
  height = 6.6
)

# ============================================================
# 12. Figure 2 — Monthly mean WPD
# ============================================================

fig_02_monthly_wpd <- ggplot(
  monthly_plot_data,
  aes(x = date_month, y = mean_WPD, color = zone, group = zone)
) +
  geom_line(linewidth = 0.85, na.rm = FALSE) +
  geom_point(size = 1.5, alpha = 0.75, na.rm = TRUE) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = zone_palette, guide = "none") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(labels = label_number(accuracy = 0.1, big.mark = " ")) +
  labs(
    title = "Monthly mean wind power density by analytical zone",
    subtitle = "WPD calculated using daily zone-level air density",
    x = "Month",
    y = expression("Monthly mean WPD (W m"^-2 * ")")
  ) +
  theme_pub()

save_pub_plot(
  fig_02_monthly_wpd,
  "Fig_02_monthly_mean_WPD_by_zone",
  width = 9,
  height = 6.6
)

# ============================================================
# 13. Figure 3 — Wind-speed distribution by zone
# ============================================================

fig_03_vv_distribution <- ggplot(
  dt_main,
  aes(x = zone, y = VV, fill = zone)
) +
  geom_violin(
    trim = TRUE,
    alpha = 0.42,
    color = "black",
    linewidth = 0.45
  ) +
  geom_boxplot(
    width = 0.18,
    outlier.shape = NA,
    fill = "white",
    color = "black",
    linewidth = 0.45
  ) +
  stat_summary(
    fun = mean,
    geom = "point",
    shape = 23,
    size = 2.6,
    fill = "#F0E442",
    color = "black"
  ) +
  scale_fill_manual(values = zone_palette, guide = "none") +
  scale_x_discrete(labels = zone_labels) +
  labs(
    title = "Wind-speed distribution by analytical zone",
    subtitle = "Main quality-control scenario: VV <= 20 m s^-1",
    x = "Analytical zone",
    y = expression("Wind speed, " * V[V] * " (m s"^-1 * ")")
  ) +
  theme_pub()

save_pub_plot(
  fig_03_vv_distribution,
  "Fig_03_wind_speed_distribution_by_zone",
  width = 8.2,
  height = 6
)

# ============================================================
# 14. Figure 4 — WPD distribution by zone
# ============================================================

fig_04_wpd_distribution <- ggplot(
  dt_main,
  aes(x = zone, y = WPD, fill = zone)
) +
  geom_violin(
    trim = TRUE,
    alpha = 0.42,
    color = "black",
    linewidth = 0.45
  ) +
  geom_boxplot(
    width = 0.18,
    outlier.shape = NA,
    fill = "white",
    color = "black",
    linewidth = 0.45
  ) +
  stat_summary(
    fun = mean,
    geom = "point",
    shape = 23,
    size = 2.6,
    fill = "#F0E442",
    color = "black"
  ) +
  scale_fill_manual(values = zone_palette, guide = "none") +
  scale_x_discrete(labels = zone_labels) +
  scale_y_continuous(
    trans = pseudo_log_trans(base = 10, sigma = 1),
    labels = label_number(accuracy = 0.1, big.mark = " ")
  ) +
  labs(
    title = "Wind power density distribution by analytical zone",
    subtitle = "WPD calculated using daily zone-level air density",
    x = "Analytical zone",
    y = expression("WPD (W m"^-2 * ")")
  ) +
  theme_pub()

save_pub_plot(
  fig_04_wpd_distribution,
  "Fig_04_WPD_distribution_by_zone",
  width = 8.2,
  height = 6
)

# ============================================================
# 15. Figure 5 — Density fit
# ============================================================

fig_05_density_fit <- ggplot(
  density_plot_data,
  aes(x = x, y = density, color = curve_label, linetype = curve_label)
) +
  geom_line(linewidth = 0.9, na.rm = TRUE) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = curve_palette_density) +
  scale_linetype_manual(values = curve_linetypes_density) +
  labs(
    title = "Empirical, Weibull and Rayleigh wind-speed density fits",
    subtitle = "Main quality-controlled dataset; VV > 0 used for distribution fitting",
    x = expression("Wind speed, " * V[V] * " (m s"^-1 * ")"),
    y = "Probability density",
    color = "Curve",
    linetype = "Curve"
  ) +
  theme_pub()

save_pub_plot(
  fig_05_density_fit,
  "Fig_05_weibull_rayleigh_density_fit_by_zone",
  width = 9,
  height = 6.6
)

# ============================================================
# 16. Figure 6 — CDF fit
# ============================================================

fig_06_cdf_fit <- ggplot(
  cdf_plot_data,
  aes(x = x, y = CDF, color = curve_label, linetype = curve_label)
) +
  geom_line(linewidth = 0.9, na.rm = TRUE) +
  facet_wrap(
    ~ zone,
    ncol = 2,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_color_manual(values = curve_palette_cdf) +
  scale_linetype_manual(values = curve_linetypes_cdf) +
  labs(
    title = "Empirical, Weibull and Rayleigh cumulative distribution fits",
    subtitle = "Main quality-controlled dataset; VV > 0 used for distribution fitting",
    x = expression("Wind speed, " * V[V] * " (m s"^-1 * ")"),
    y = "Cumulative probability",
    color = "Curve",
    linetype = "Curve"
  ) +
  theme_pub()

save_pub_plot(
  fig_06_cdf_fit,
  "Fig_06_weibull_rayleigh_CDF_fit_by_zone",
  width = 9,
  height = 6.6
)

# ============================================================
# 17. Figure 7 — Delta AIC/BIC comparison
# ============================================================

fig_07_aic_bic_delta <- ggplot(
  aic_bic_plot_data,
  aes(x = distribution, y = delta_value, fill = distribution)
) +
  geom_col(width = 0.62, color = "black", linewidth = 0.35) +
  facet_grid(
    criterion ~ zone,
    scales = "free_y",
    labeller = labeller(zone = zone_labels)
  ) +
  scale_fill_manual(values = c("Weibull" = "#0072B2", "Rayleigh" = "#D55E00")) +
  scale_y_continuous(labels = label_number(accuracy = 0.1, big.mark = " ")) +
  labs(
    title = "Delta AIC and BIC for Weibull and Rayleigh fits",
    subtitle = "Delta = 0 identifies the best model within each zone and criterion",
    x = "Distribution",
    y = expression(Delta * " information criterion"),
    fill = "Distribution"
  ) +
  theme_pub() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

save_pub_plot(
  fig_07_aic_bic_delta,
  "Fig_07_delta_AIC_BIC_weibull_rayleigh_comparison",
  width = 9,
  height = 6.8
)

# ============================================================
# 18. Supplementary Figure S1 — QC sensitivity
# ============================================================

fig_S1_qc <- ggplot(
  qc_summary_plot,
  aes(x = zone, y = mean_WPD, color = qc_label, group = qc_label)
) +
  geom_line(linewidth = 0.85) +
  geom_point(size = 2.4) +
  scale_color_manual(values = qc_palette) +
  scale_x_discrete(labels = zone_labels) +
  scale_y_continuous(labels = label_number(accuracy = 0.1, big.mark = " ")) +
  labs(
    title = "Effect of quality-control criteria on mean wind power density",
    subtitle = "Daily zone-level air density strategy",
    x = "Analytical zone",
    y = expression("Mean WPD (W m"^-2 * ")"),
    color = "QC scenario"
  ) +
  theme_pub() +
  guides(color = guide_legend(nrow = 2, byrow = TRUE))

save_pub_plot(
  fig_S1_qc,
  "Fig_S1_QC_sensitivity_mean_WPD",
  width = 9,
  height = 6.2
)

# ============================================================
# 19. Export captions and summary
# ============================================================

captions <- data.table(
  figure_id = c(
    "Figure 1",
    "Figure 2",
    "Figure 3",
    "Figure 4",
    "Figure 5",
    "Figure 6",
    "Figure 7",
    "Figure S1"
  ),
  filename_base = c(
    "Fig_01_monthly_mean_wind_speed_by_zone",
    "Fig_02_monthly_mean_WPD_by_zone",
    "Fig_03_wind_speed_distribution_by_zone",
    "Fig_04_WPD_distribution_by_zone",
    "Fig_05_weibull_rayleigh_density_fit_by_zone",
    "Fig_06_weibull_rayleigh_CDF_fit_by_zone",
    "Fig_07_delta_AIC_BIC_weibull_rayleigh_comparison",
    "Fig_S1_QC_sensitivity_mean_WPD"
  ),
  recommendation = c(
    "Main text",
    "Main text",
    "Main text",
    "Main text",
    "Main text",
    "Main text",
    "Main text",
    "Supplementary material"
  ),
  draft_caption = c(
    "Monthly mean wind speed by analytical zone for the main quality-controlled dataset.",
    "Monthly mean wind power density by analytical zone. WPD was calculated using daily zone-level air density.",
    "Wind-speed distribution by analytical zone for the main quality-controlled dataset. The diamond marker represents the mean.",
    "Wind power density distribution by analytical zone for the main quality-controlled dataset. The y-axis uses a pseudo-logarithmic transformation and the diamond marker represents the mean.",
    "Empirical wind-speed density and fitted Weibull and Rayleigh distributions by analytical zone.",
    "Empirical cumulative distribution function and fitted Weibull and Rayleigh cumulative distributions by analytical zone.",
    "Delta AIC and BIC comparison between Weibull and Rayleigh models by analytical zone. Delta = 0 identifies the best model within each zone and criterion.",
    "Sensitivity of mean WPD to alternative quality-control criteria."
  )
)

write.xlsx(
  captions,
  file.path(DIR_TABLES, "04G_publication_ready_figure_captions.xlsx"),
  overwrite = TRUE
)

summary_table <- best_distribution[, .(
  zone,
  distribution,
  shape,
  scale,
  sigma,
  AIC,
  BIC,
  KS_statistic,
  RMSE_CDF
)]

write.xlsx(
  summary_table,
  file.path(DIR_TABLES, "04G_best_distribution_summary_for_figures.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 20. Console report
# ============================================================

cat("\n============================================================\n")
cat("PUBLICATION-READY FIGURES — ARTICLE 1\n")
cat("============================================================\n\n")

cat("Input files:\n")
cat("- ", INPUT_MAIN_WPD, "\n", sep = "")
cat("- ", INPUT_QC_ALL, "\n", sep = "")
cat("- ", INPUT_DIST_RESULTS, "\n\n", sep = "")

cat("Figures exported to:\n")
cat(DIR_FIGURES_PUB, "\n\n")

cat("Main figure set:\n")
cat("- Fig_01_monthly_mean_wind_speed_by_zone\n")
cat("- Fig_02_monthly_mean_WPD_by_zone\n")
cat("- Fig_03_wind_speed_distribution_by_zone\n")
cat("- Fig_04_WPD_distribution_by_zone\n")
cat("- Fig_05_weibull_rayleigh_density_fit_by_zone\n")
cat("- Fig_06_weibull_rayleigh_CDF_fit_by_zone\n")
cat("- Fig_07_delta_AIC_BIC_weibull_rayleigh_comparison\n")
cat("- Fig_S1_QC_sensitivity_mean_WPD\n\n")

cat("Auxiliary tables:\n")
cat("- 04_tables/04G_publication_ready_figure_captions.xlsx\n")
cat("- 04_tables/04G_best_distribution_summary_for_figures.xlsx\n")
cat("- 04_tables/04G_monthly_plot_data_with_explicit_gaps.xlsx\n")
cat("- 04_tables/04G_QC_sensitivity_summary_for_plot.xlsx\n")
cat("- 04_tables/04G_AIC_BIC_delta_plot_data.xlsx\n")
cat("============================================================\n")

log_msg("Publication-ready figures generated successfully.")

# ============================================================
# 05H_final_distribution_and_publication_figures_article1.R
# ARTICLE 1 — ENERGY REPORTS
# Final distribution fitting and publication-ready figures
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
  "fitdistrplus",
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
  library(fitdistrplus)
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

INPUT_QC_ALL <- file.path(
  DIR_DATA_PROCESSED,
  "02E_wpd_qc_scenarios_daily_zone_density.rds"
)

if (!file.exists(INPUT_MAIN_WPD)) {
  stop("Main QC dataset not found: ", INPUT_MAIN_WPD)
}

if (!file.exists(INPUT_QC_ALL)) {
  stop("QC scenarios dataset not found: ", INPUT_QC_ALL)
}

log_file <- file.path(DIR_LOGS, "05H_final_distribution_and_publication_figures_article1_log.txt")

log_msg <- function(...) {
  msg <- paste0(
    format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    " | ",
    paste(..., collapse = " ")
  )
  cat(msg, "\n")
  cat(msg, "\n", file = log_file, append = TRUE)
}

log_msg("Starting final distribution fitting and publication-ready figures.")

# ============================================================
# 3. Load datasets
# ============================================================

dt_main <- readRDS(INPUT_MAIN_WPD)
dt_main <- as.data.table(dt_main)

dt_qc_all <- readRDS(INPUT_QC_ALL)
dt_qc_all <- as.data.table(dt_qc_all)

required_main_columns <- c("zone", "datetime", "VV", "WPD", "rho_used")

missing_main_columns <- setdiff(required_main_columns, names(dt_main))

if (length(missing_main_columns) > 0) {
  stop(
    "Main dataset is missing required columns: ",
    paste(missing_main_columns, collapse = ", ")
  )
}

# ============================================================
# 4. Standardize datasets
# ============================================================

dt_main[, datetime := as.POSIXct(datetime, tz = "America/Bogota")]
dt_main[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
dt_main[, VV := suppressWarnings(as.numeric(VV))]
dt_main[, WPD := suppressWarnings(as.numeric(WPD))]
dt_main[, rho_used := suppressWarnings(as.numeric(rho_used))]
dt_main[, year := year(datetime)]
dt_main[, month := month(datetime)]
dt_main[, year_month := format(datetime, "%Y-%m")]

dt_main <- dt_main[
  !is.na(zone) &
    !is.na(datetime) &
    !is.na(VV) &
    !is.na(WPD) &
    is.finite(VV) &
    is.finite(WPD) &
    VV >= 0 &
    WPD >= 0
]

dt_qc_all[, datetime := as.POSIXct(datetime, tz = "America/Bogota")]
dt_qc_all[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
dt_qc_all[, VV := suppressWarnings(as.numeric(VV))]
dt_qc_all[, WPD := suppressWarnings(as.numeric(WPD))]
dt_qc_all[, qc_scenario := as.character(qc_scenario)]

dt_qc_all <- dt_qc_all[
  !is.na(zone) &
    !is.na(WPD) &
    is.finite(WPD) &
    WPD >= 0
]

log_msg("Main dataset loaded.")
log_msg("Rows:", nrow(dt_main))
log_msg("Zones:", uniqueN(dt_main$zone))
log_msg("Min datetime:", as.character(min(dt_main$datetime, na.rm = TRUE)))
log_msg("Max datetime:", as.character(max(dt_main$datetime, na.rm = TRUE)))

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
  "qc_vv_le_30"                 = "VV \u2264 30 m s^-1",
  "qc_vv_le_25"                 = "VV \u2264 25 m s^-1",
  "qc_vv_le_20"                 = "VV \u2264 20 m s^-1",
  "qc_wpd_le_5000"              = "WPD \u2264 5000 W m^-2",
  "qc_vv_le_25_and_wpd_le_5000" = "VV \u2264 25 and WPD \u2264 5000"
)

qc_palette <- c(
  "VV \u2264 20 m s^-1"          = "#000000",
  "VV \u2264 25 m s^-1"          = "#0072B2",
  "VV \u2264 30 m s^-1"          = "#D55E00",
  "WPD \u2264 5000 W m^-2"       = "#009E73",
  "VV \u2264 25 and WPD \u2264 5000" = "#CC79A7",
  "Raw"                         = "#7F7F7F"
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
# 7. Rayleigh functions
# ============================================================

drayleigh <- function(x, sigma) {
  out <- rep(0, length(x))
  ok <- x >= 0 & sigma > 0 & is.finite(x)
  out[ok] <- (x[ok] / sigma^2) * exp(-(x[ok]^2) / (2 * sigma^2))
  out
}

prayleigh <- function(q, sigma) {
  out <- rep(0, length(q))
  ok <- q >= 0 & sigma > 0 & is.finite(q)
  out[ok] <- 1 - exp(-(q[ok]^2) / (2 * sigma^2))
  out
}

rayleigh_mle_sigma <- function(x) {
  sqrt(mean(x^2, na.rm = TRUE) / 2)
}

rayleigh_loglik <- function(x, sigma) {
  valid_x <- x[x > 0 & is.finite(x)]
  dens <- drayleigh(valid_x, sigma)
  dens <- dens[dens > 0 & is.finite(dens)]
  sum(log(dens))
}

safe_ks_test <- function(x, cdf_function, ...) {
  out <- tryCatch(
    {
      suppressWarnings(stats::ks.test(x, cdf_function, ...))
    },
    error = function(e) {
      NULL
    }
  )
  
  if (is.null(out)) {
    return(list(statistic = NA_real_, p_value = NA_real_))
  }
  
  list(
    statistic = as.numeric(out$statistic),
    p_value = as.numeric(out$p.value)
  )
}

# ============================================================
# 8. Robust distribution fitting by zone
# ============================================================

fit_zone_distributions <- function(data_zone) {
  
  z <- unique(as.character(data_zone$zone))
  
  x <- data_zone[
    !is.na(VV) &
      is.finite(VV) &
      VV > 0,
    VV
  ]
  
  n <- length(x)
  
  if (n < 30) {
    return(list(
      parameters = data.table(),
      metrics = data.table(),
      density_curve = data.table(),
      cdf_curve = data.table()
    ))
  }
  
  weibull_fit <- tryCatch(
    {
      fitdistrplus::fitdist(x, "weibull", method = "mle")
    },
    error = function(e) {
      NULL
    }
  )
  
  if (!is.null(weibull_fit)) {
    weibull_shape <- unname(weibull_fit$estimate["shape"])
    weibull_scale <- unname(weibull_fit$estimate["scale"])
    weibull_logLik <- as.numeric(weibull_fit$loglik)
    weibull_AIC <- as.numeric(weibull_fit$aic)
    weibull_BIC <- as.numeric(weibull_fit$bic)
  } else {
    weibull_shape <- NA_real_
    weibull_scale <- NA_real_
    weibull_logLik <- NA_real_
    weibull_AIC <- NA_real_
    weibull_BIC <- NA_real_
  }
  
  rayleigh_sigma <- rayleigh_mle_sigma(x)
  rayleigh_logLik_value <- rayleigh_loglik(x, rayleigh_sigma)
  rayleigh_AIC <- 2 * 1 - 2 * rayleigh_logLik_value
  rayleigh_BIC <- log(n) * 1 - 2 * rayleigh_logLik_value
  
  x_max <- max(x, na.rm = TRUE)
  
  x_min_density <- max(
    as.numeric(quantile(x[x > 0], probs = 0.005, na.rm = TRUE)),
    0.05
  )
  
  density_grid_x <- seq(
    from = x_min_density,
    to = x_max,
    length.out = 600
  )
  
  dens_emp <- density(
    x,
    from = x_min_density,
    to = x_max,
    n = 600,
    na.rm = TRUE
  )
  
  density_grid <- data.table(
    x = dens_emp$x,
    empirical_density = dens_emp$y
  )
  
  if (!is.na(weibull_shape) && !is.na(weibull_scale)) {
    density_grid[, Weibull := dweibull(
      x,
      shape = weibull_shape,
      scale = weibull_scale
    )]
  } else {
    density_grid[, Weibull := NA_real_]
  }
  
  density_grid[, Rayleigh := drayleigh(
    x,
    sigma = rayleigh_sigma
  )]
  
  density_grid[!is.finite(Weibull), Weibull := NA_real_]
  density_grid[!is.finite(Rayleigh), Rayleigh := NA_real_]
  
  cdf_grid_x <- seq(
    from = 0,
    to = x_max,
    length.out = 600
  )
  
  ecdf_fun <- ecdf(x)
  
  cdf_grid <- data.table(
    x = cdf_grid_x,
    empirical_CDF = ecdf_fun(cdf_grid_x)
  )
  
  if (!is.na(weibull_shape) && !is.na(weibull_scale)) {
    cdf_grid[, Weibull := pweibull(
      x,
      shape = weibull_shape,
      scale = weibull_scale
    )]
  } else {
    cdf_grid[, Weibull := NA_real_]
  }
  
  cdf_grid[, Rayleigh := prayleigh(
    x,
    sigma = rayleigh_sigma
  )]
  
  cdf_grid[!is.finite(Weibull), Weibull := NA_real_]
  cdf_grid[!is.finite(Rayleigh), Rayleigh := NA_real_]
  
  if (!is.na(weibull_shape) && !is.na(weibull_scale)) {
    ks_weibull <- safe_ks_test(
      x,
      "pweibull",
      shape = weibull_shape,
      scale = weibull_scale
    )
  } else {
    ks_weibull <- list(statistic = NA_real_, p_value = NA_real_)
  }
  
  ks_rayleigh <- safe_ks_test(
    x,
    prayleigh,
    sigma = rayleigh_sigma
  )
  
  valid_weibull_density <- is.finite(density_grid$empirical_density) &
    is.finite(density_grid$Weibull)
  
  valid_rayleigh_density <- is.finite(density_grid$empirical_density) &
    is.finite(density_grid$Rayleigh)
  
  rmse_density_weibull <- sqrt(mean(
    (density_grid$empirical_density[valid_weibull_density] -
       density_grid$Weibull[valid_weibull_density])^2,
    na.rm = TRUE
  ))
  
  mae_density_weibull <- mean(
    abs(
      density_grid$empirical_density[valid_weibull_density] -
        density_grid$Weibull[valid_weibull_density]
    ),
    na.rm = TRUE
  )
  
  rmse_density_rayleigh <- sqrt(mean(
    (density_grid$empirical_density[valid_rayleigh_density] -
       density_grid$Rayleigh[valid_rayleigh_density])^2,
    na.rm = TRUE
  ))
  
  mae_density_rayleigh <- mean(
    abs(
      density_grid$empirical_density[valid_rayleigh_density] -
        density_grid$Rayleigh[valid_rayleigh_density]
    ),
    na.rm = TRUE
  )
  
  valid_weibull_cdf <- is.finite(cdf_grid$empirical_CDF) &
    is.finite(cdf_grid$Weibull)
  
  valid_rayleigh_cdf <- is.finite(cdf_grid$empirical_CDF) &
    is.finite(cdf_grid$Rayleigh)
  
  rmse_cdf_weibull <- sqrt(mean(
    (cdf_grid$empirical_CDF[valid_weibull_cdf] -
       cdf_grid$Weibull[valid_weibull_cdf])^2,
    na.rm = TRUE
  ))
  
  mae_cdf_weibull <- mean(
    abs(
      cdf_grid$empirical_CDF[valid_weibull_cdf] -
        cdf_grid$Weibull[valid_weibull_cdf]
    ),
    na.rm = TRUE
  )
  
  rmse_cdf_rayleigh <- sqrt(mean(
    (cdf_grid$empirical_CDF[valid_rayleigh_cdf] -
       cdf_grid$Rayleigh[valid_rayleigh_cdf])^2,
    na.rm = TRUE
  ))
  
  mae_cdf_rayleigh <- mean(
    abs(
      cdf_grid$empirical_CDF[valid_rayleigh_cdf] -
        cdf_grid$Rayleigh[valid_rayleigh_cdf]
    ),
    na.rm = TRUE
  )
  
  parameters <- data.table(
    zone = z,
    distribution = c("Weibull", "Rayleigh"),
    n_fit = n,
    shape = c(weibull_shape, NA_real_),
    scale = c(weibull_scale, NA_real_),
    sigma = c(NA_real_, rayleigh_sigma),
    logLik = c(weibull_logLik, rayleigh_logLik_value),
    AIC = c(weibull_AIC, rayleigh_AIC),
    BIC = c(weibull_BIC, rayleigh_BIC)
  )
  
  metrics <- data.table(
    zone = z,
    distribution = c("Weibull", "Rayleigh"),
    n_fit = n,
    KS_statistic = c(
      ks_weibull$statistic,
      ks_rayleigh$statistic
    ),
    KS_p_value = c(
      ks_weibull$p_value,
      ks_rayleigh$p_value
    ),
    RMSE_density = c(
      rmse_density_weibull,
      rmse_density_rayleigh
    ),
    MAE_density = c(
      mae_density_weibull,
      mae_density_rayleigh
    ),
    RMSE_CDF = c(
      rmse_cdf_weibull,
      rmse_cdf_rayleigh
    ),
    MAE_CDF = c(
      mae_cdf_weibull,
      mae_cdf_rayleigh
    )
  )
  
  density_curve <- melt(
    density_grid,
    id.vars = "x",
    variable.name = "curve_type",
    value.name = "density"
  )
  
  density_curve[, zone := z]
  
  cdf_curve <- melt(
    cdf_grid,
    id.vars = "x",
    variable.name = "curve_type",
    value.name = "CDF"
  )
  
  cdf_curve[, zone := z]
  
  list(
    parameters = parameters,
    metrics = metrics,
    density_curve = density_curve,
    cdf_curve = cdf_curve
  )
}

# ============================================================
# 9. Run distribution fitting
# ============================================================

zones <- sort(unique(as.character(dt_main$zone)))

fit_results <- lapply(zones, function(z) {
  log_msg("Fitting distributions for zone:", z)
  fit_zone_distributions(dt_main[as.character(zone) == z])
})

parameters_by_zone <- rbindlist(
  lapply(fit_results, `[[`, "parameters"),
  fill = TRUE
)

metrics_by_zone <- rbindlist(
  lapply(fit_results, `[[`, "metrics"),
  fill = TRUE
)

density_curve_data <- rbindlist(
  lapply(fit_results, `[[`, "density_curve"),
  fill = TRUE
)

cdf_curve_data <- rbindlist(
  lapply(fit_results, `[[`, "cdf_curve"),
  fill = TRUE
)

# ============================================================
# 10. Model comparison
# ============================================================

comparison_table <- merge(
  parameters_by_zone,
  metrics_by_zone,
  by = c("zone", "distribution", "n_fit"),
  all = TRUE
)

comparison_table[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
comparison_table[, distribution := factor(as.character(distribution), levels = c("Weibull", "Rayleigh"))]

comparison_table[, delta_AIC := AIC - min(AIC, na.rm = TRUE), by = zone]
comparison_table[, delta_BIC := BIC - min(BIC, na.rm = TRUE), by = zone]

comparison_table[, rank_AIC := frank(AIC, ties.method = "min"), by = zone]
comparison_table[, rank_BIC := frank(BIC, ties.method = "min"), by = zone]
comparison_table[, rank_KS := frank(KS_statistic, ties.method = "min"), by = zone]
comparison_table[, rank_RMSE_density := frank(RMSE_density, ties.method = "min"), by = zone]
comparison_table[, rank_RMSE_CDF := frank(RMSE_CDF, ties.method = "min"), by = zone]

comparison_table[, global_fit_score := rowSums(
  .SD,
  na.rm = TRUE
), .SDcols = c(
  "rank_AIC",
  "rank_BIC",
  "rank_KS",
  "rank_RMSE_density",
  "rank_RMSE_CDF"
)]

comparison_table[, global_rank := frank(global_fit_score, ties.method = "min"), by = zone]

best_distribution_by_zone <- comparison_table[
  order(zone, global_rank)
][
  ,
  .SD[1],
  by = zone
]

best_distribution_by_zone[, interpretation := paste0(
  as.character(distribution),
  " provides the best overall fit according to the combined ranking of AIC, BIC, KS statistic, density RMSE and CDF RMSE."
)]

# ============================================================
# 11. Export distribution tables
# ============================================================

write.xlsx(
  parameters_by_zone,
  file.path(DIR_TABLES, "05H_weibull_rayleigh_parameters_by_zone_final.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  metrics_by_zone,
  file.path(DIR_TABLES, "05H_weibull_rayleigh_fit_metrics_by_zone_final.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  comparison_table,
  file.path(DIR_TABLES, "05H_weibull_rayleigh_model_comparison_by_zone_final.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  best_distribution_by_zone,
  file.path(DIR_TABLES, "05H_best_distribution_by_zone_final.xlsx"),
  overwrite = TRUE
)

distribution_results_object <- list(
  input_main_wpd = INPUT_MAIN_WPD,
  input_qc_all = INPUT_QC_ALL,
  parameters_by_zone = parameters_by_zone,
  metrics_by_zone = metrics_by_zone,
  comparison_table = comparison_table,
  best_distribution_by_zone = best_distribution_by_zone,
  density_curve_data = density_curve_data,
  cdf_curve_data = cdf_curve_data
)

saveRDS(
  distribution_results_object,
  file.path(DIR_RESULTS, "05H_final_distribution_results_article1.rds")
)

# ============================================================
# 12. Monthly summaries with explicit temporal gaps
# ============================================================

monthly_main <- dt_main[, .(
  mean_VV = mean(VV, na.rm = TRUE),
  mean_WPD = mean(WPD, na.rm = TRUE),
  median_WPD = median(WPD, na.rm = TRUE),
  n_records = .N
), by = .(
  zone,
  year_month
)]

monthly_main[, date_month := as.Date(paste0(year_month, "-01"))]

start_month <- as.Date(format(min(dt_main$datetime, na.rm = TRUE), "%Y-%m-01"))
end_month <- as.Date(format(max(dt_main$datetime, na.rm = TRUE), "%Y-%m-01"))

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
  file.path(DIR_TABLES, "05H_monthly_plot_data_with_explicit_gaps_final.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 13. QC sensitivity summary
# ============================================================

qc_summary_plot <- dt_qc_all[
  ,
  .(
    n_records = .N,
    mean_WPD = mean(WPD, na.rm = TRUE),
    median_WPD = median(WPD, na.rm = TRUE),
    max_WPD = max(WPD, na.rm = TRUE)
  ),
  by = .(
    zone,
    qc_scenario
  )
]

qc_summary_plot[, qc_label := qc_label_map[as.character(qc_scenario)]]
qc_summary_plot <- qc_summary_plot[!is.na(qc_label)]

qc_summary_plot[, qc_label := factor(
  qc_label,
  levels = c(
    "VV \u2264 20 m s^-1",
    "VV \u2264 25 m s^-1",
    "VV \u2264 30 m s^-1",
    "WPD \u2264 5000 W m^-2",
    "VV \u2264 25 and WPD \u2264 5000",
    "Raw"
  )
)]

write.xlsx(
  qc_summary_plot,
  file.path(DIR_TABLES, "05H_QC_sensitivity_summary_for_plot_final.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 14. Clean distribution curve data for plotting
# ============================================================

density_curve_data[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
density_curve_data[, curve_type := as.character(curve_type)]
density_curve_data[, x := as.numeric(x)]
density_curve_data[, density := as.numeric(density)]

density_plot_data <- density_curve_data[
  curve_type %in% c("empirical_density", "Weibull", "Rayleigh")
]

density_plot_data[, curve_label := curve_type]
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

cdf_curve_data[, zone := factor(as.character(zone), levels = c("1", "2", "3", "4"))]
cdf_curve_data[, curve_type := as.character(curve_type)]
cdf_curve_data[, x := as.numeric(x)]
cdf_curve_data[, CDF := as.numeric(CDF)]

cdf_plot_data <- cdf_curve_data[
  curve_type %in% c("empirical_CDF", "Weibull", "Rayleigh")
]

cdf_plot_data[, curve_label := curve_type]
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
  file.path(DIR_TABLES, "05H_density_plot_data_cleaned_final.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  cdf_plot_data,
  file.path(DIR_TABLES, "05H_cdf_plot_data_cleaned_final.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 15. Delta AIC/BIC plot data
# ============================================================

aic_bic_plot_data <- melt(
  comparison_table[, .(
    zone,
    distribution,
    delta_AIC,
    delta_BIC
  )],
  id.vars = c("zone", "distribution"),
  variable.name = "criterion",
  value.name = "delta_value"
)

aic_bic_plot_data[, criterion := fifelse(
  criterion == "delta_AIC",
  "Delta AIC",
  "Delta BIC"
)]

aic_bic_plot_data[, criterion := factor(
  criterion,
  levels = c("Delta AIC", "Delta BIC")
)]

aic_bic_plot_data[, distribution := factor(
  as.character(distribution),
  levels = c("Weibull", "Rayleigh")
)]

aic_bic_plot_data[, delta_value := as.numeric(delta_value)]
aic_bic_plot_data <- aic_bic_plot_data[is.finite(delta_value)]

write.xlsx(
  aic_bic_plot_data,
  file.path(DIR_TABLES, "05H_AIC_BIC_delta_plot_data_final.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 16. Figure 1 — Monthly mean wind speed
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
    subtitle = "Main quality-control scenario: VV \u2264 20 m s^-1",
    x = "Month",
    y = expression("Monthly mean " * V[V] * " (m s"^-1 * ")")
  ) +
  theme_pub()

save_pub_plot(
  fig_01_monthly_vv,
  "Fig_01_monthly_mean_wind_speed_by_zone_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 17. Figure 2 — Monthly mean WPD
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
  "Fig_02_monthly_mean_WPD_by_zone_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 18. Figure 3 — Wind-speed distribution
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
    subtitle = "Main quality-control scenario: VV \u2264 20 m s^-1",
    x = "Analytical zone",
    y = expression("Wind speed, " * V[V] * " (m s"^-1 * ")")
  ) +
  theme_pub()

save_pub_plot(
  fig_03_vv_distribution,
  "Fig_03_wind_speed_distribution_by_zone_FINAL",
  width = 8.2,
  height = 6
)

# ============================================================
# 19. Figure 4 — WPD distribution
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
    y = expression("WPD (W m"^-2 * ", pseudo-log scale)")
  ) +
  theme_pub()

save_pub_plot(
  fig_04_wpd_distribution,
  "Fig_04_WPD_distribution_by_zone_FINAL",
  width = 8.2,
  height = 6
)

# ============================================================
# 20. Figure 5 — Density fits
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
  "Fig_05_weibull_rayleigh_density_fit_by_zone_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 21. Figure 6 — CDF fits
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
  "Fig_06_weibull_rayleigh_CDF_fit_by_zone_FINAL",
  width = 9,
  height = 6.6
)

# ============================================================
# 22. Supplementary Figure S1 — QC sensitivity
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
  "Fig_S1_QC_sensitivity_mean_WPD_FINAL",
  width = 9,
  height = 6.2
)

# ============================================================
# 23. Supplementary Figure S2 — Delta AIC/BIC
# ============================================================

fig_S2_aic_bic_delta <- ggplot(
  aic_bic_plot_data,
  aes(x = distribution, y = delta_value + 1, fill = distribution)
) +
  geom_col(width = 0.62, color = "black", linewidth = 0.35) +
  facet_grid(
    criterion ~ zone,
    labeller = labeller(zone = zone_labels)
  ) +
  scale_fill_manual(values = c("Weibull" = "#0072B2", "Rayleigh" = "#D55E00")) +
  scale_y_continuous(
    trans = "log10",
    labels = label_number(accuracy = 0.1, big.mark = " ")
  ) +
  labs(
    title = "Delta AIC and BIC for Weibull and Rayleigh fits",
    subtitle = "Values shown as log10(Delta + 1); Delta = 0 identifies the best model",
    x = "Distribution",
    y = expression(log[10] * "(" * Delta * " information criterion + 1)"),
    fill = "Distribution"
  ) +
  theme_pub() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

save_pub_plot(
  fig_S2_aic_bic_delta,
  "Fig_S2_delta_AIC_BIC_weibull_rayleigh_comparison_FINAL",
  width = 9,
  height = 6.8
)

# ============================================================
# 24. Captions and final figure selection
# ============================================================

captions <- data.table(
  figure_id = c(
    "Figure 1",
    "Figure 2",
    "Figure 3",
    "Figure 4",
    "Figure 5",
    "Figure 6",
    "Figure S1",
    "Figure S2"
  ),
  filename_base = c(
    "Fig_01_monthly_mean_wind_speed_by_zone_FINAL",
    "Fig_02_monthly_mean_WPD_by_zone_FINAL",
    "Fig_03_wind_speed_distribution_by_zone_FINAL",
    "Fig_04_WPD_distribution_by_zone_FINAL",
    "Fig_05_weibull_rayleigh_density_fit_by_zone_FINAL",
    "Fig_06_weibull_rayleigh_CDF_fit_by_zone_FINAL",
    "Fig_S1_QC_sensitivity_mean_WPD_FINAL",
    "Fig_S2_delta_AIC_BIC_weibull_rayleigh_comparison_FINAL"
  ),
  recommendation = c(
    "Main text",
    "Main text",
    "Main text",
    "Main text",
    "Main text",
    "Main text",
    "Supplementary material",
    "Supplementary material or table replacement"
  ),
  draft_caption = c(
    "Monthly mean wind speed by analytical zone for the main quality-controlled dataset.",
    "Monthly mean wind power density by analytical zone. WPD was calculated using daily zone-level air density.",
    "Wind-speed distribution by analytical zone for the main quality-controlled dataset. The diamond marker represents the mean.",
    "Wind power density distribution by analytical zone for the main quality-controlled dataset. The y-axis uses a pseudo-logarithmic transformation and the diamond marker represents the mean.",
    "Empirical wind-speed density and fitted Weibull and Rayleigh distributions by analytical zone.",
    "Empirical cumulative distribution function and fitted Weibull and Rayleigh cumulative distributions by analytical zone.",
    "Sensitivity of mean WPD to alternative quality-control criteria.",
    "Delta AIC and BIC comparison between Weibull and Rayleigh models by analytical zone. Values are shown as log10(Delta + 1)."
  )
)

write.xlsx(
  captions,
  file.path(DIR_TABLES, "05H_publication_ready_figure_captions_final.xlsx"),
  overwrite = TRUE
)

table_distribution_summary <- comparison_table[
  ,
  .(
    zone,
    distribution,
    n_fit,
    shape,
    scale,
    sigma,
    AIC,
    BIC,
    delta_AIC,
    delta_BIC,
    KS_statistic,
    RMSE_density,
    RMSE_CDF,
    global_fit_score,
    global_rank
  )
][order(zone, global_rank)]

write.xlsx(
  table_distribution_summary,
  file.path(DIR_TABLES, "05H_distribution_model_comparison_table_for_article_final.xlsx"),
  overwrite = TRUE
)

table_best_distribution <- best_distribution_by_zone[
  ,
  .(
    zone,
    selected_distribution = distribution,
    n_fit,
    shape,
    scale,
    sigma,
    AIC,
    BIC,
    KS_statistic,
    RMSE_density,
    RMSE_CDF,
    interpretation
  )
][order(zone)]

write.xlsx(
  table_best_distribution,
  file.path(DIR_TABLES, "05H_best_distribution_table_for_article_final.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 25. Console report
# ============================================================

cat("\n============================================================\n")
cat("FINAL DISTRIBUTION FITTING AND PUBLICATION FIGURES — ARTICLE 1\n")
cat("============================================================\n\n")

cat("Input main dataset:\n")
cat(INPUT_MAIN_WPD, "\n\n")

cat("Dataset summary:\n")
print(data.table(
  n_records = nrow(dt_main),
  n_zones = uniqueN(dt_main$zone),
  min_datetime = min(dt_main$datetime, na.rm = TRUE),
  max_datetime = max(dt_main$datetime, na.rm = TRUE),
  mean_VV = mean(dt_main$VV, na.rm = TRUE),
  median_VV = median(dt_main$VV, na.rm = TRUE),
  max_VV = max(dt_main$VV, na.rm = TRUE),
  mean_WPD = mean(dt_main$WPD, na.rm = TRUE),
  median_WPD = median(dt_main$WPD, na.rm = TRUE),
  max_WPD = max(dt_main$WPD, na.rm = TRUE)
))

cat("\nDistribution parameters by zone:\n")
print(parameters_by_zone)

cat("\nGoodness-of-fit metrics by zone:\n")
print(metrics_by_zone)

cat("\nModel comparison by zone:\n")
print(comparison_table)

cat("\nBest distribution by zone:\n")
print(best_distribution_by_zone)

cat("\nFigures exported to:\n")
cat(DIR_FIGURES_FINAL, "\n\n")

cat("Main text figures:\n")
cat("- Fig_01_monthly_mean_wind_speed_by_zone_FINAL\n")
cat("- Fig_02_monthly_mean_WPD_by_zone_FINAL\n")
cat("- Fig_03_wind_speed_distribution_by_zone_FINAL\n")
cat("- Fig_04_WPD_distribution_by_zone_FINAL\n")
cat("- Fig_05_weibull_rayleigh_density_fit_by_zone_FINAL\n")
cat("- Fig_06_weibull_rayleigh_CDF_fit_by_zone_FINAL\n\n")

cat("Supplementary figures:\n")
cat("- Fig_S1_QC_sensitivity_mean_WPD_FINAL\n")
cat("- Fig_S2_delta_AIC_BIC_weibull_rayleigh_comparison_FINAL\n\n")

cat("Tables exported:\n")
cat("- 04_tables/05H_weibull_rayleigh_parameters_by_zone_final.xlsx\n")
cat("- 04_tables/05H_weibull_rayleigh_fit_metrics_by_zone_final.xlsx\n")
cat("- 04_tables/05H_weibull_rayleigh_model_comparison_by_zone_final.xlsx\n")
cat("- 04_tables/05H_best_distribution_by_zone_final.xlsx\n")
cat("- 04_tables/05H_distribution_model_comparison_table_for_article_final.xlsx\n")
cat("- 04_tables/05H_best_distribution_table_for_article_final.xlsx\n")
cat("- 04_tables/05H_publication_ready_figure_captions_final.xlsx\n")
cat("============================================================\n")

log_msg("Final distribution fitting and publication-ready figures completed successfully.")

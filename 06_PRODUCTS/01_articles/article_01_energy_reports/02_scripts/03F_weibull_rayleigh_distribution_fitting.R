# ============================================================
# 03F_weibull_rayleigh_distribution_fitting.R
# ARTICLE 1 — ENERGY REPORTS
# Weibull and Rayleigh fitting for wind-speed distribution
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

INPUT_MAIN_WPD <- file.path(
  DIR_DATA_PROCESSED,
  "02E_article_main_wpd_dataset_after_qc.rds"
)

if (!file.exists(INPUT_MAIN_WPD)) {
  stop(
    "Main QC WPD dataset not found. Run script 02E first: ",
    INPUT_MAIN_WPD
  )
}

log_file <- file.path(DIR_LOGS, "03F_weibull_rayleigh_distribution_fitting_log.txt")

log_msg <- function(...) {
  msg <- paste0(
    format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    " | ",
    paste(..., collapse = " ")
  )
  cat(msg, "\n")
  cat(msg, "\n", file = log_file, append = TRUE)
}

log_msg("Starting Weibull and Rayleigh distribution fitting.")

# ============================================================
# 3. Load main article dataset
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
dt[, zone := as.character(zone)]
dt[, VV := suppressWarnings(as.numeric(VV))]
dt[, WPD := suppressWarnings(as.numeric(WPD))]
dt[, rho_used := suppressWarnings(as.numeric(rho_used))]
dt[, year := lubridate::year(datetime)]
dt[, month := lubridate::month(datetime)]
dt[, year_month := format(datetime, "%Y-%m")]

dt <- dt[
  !is.na(zone) &
    !is.na(datetime) &
    !is.na(VV) &
    VV >= 0
]

log_msg("Main dataset loaded.")
log_msg("Rows:", nrow(dt))
log_msg("Zones:", uniqueN(dt$zone))
log_msg("Min datetime:", as.character(min(dt$datetime, na.rm = TRUE)))
log_msg("Max datetime:", as.character(max(dt$datetime, na.rm = TRUE)))

# ============================================================
# 4. Distribution functions
# ============================================================

drayleigh <- function(x, sigma) {
  ifelse(
    x >= 0 & sigma > 0,
    (x / sigma^2) * exp(-(x^2) / (2 * sigma^2)),
    0
  )
}

prayleigh <- function(q, sigma) {
  ifelse(
    q >= 0 & sigma > 0,
    1 - exp(-(q^2) / (2 * sigma^2)),
    0
  )
}

qrayleigh <- function(p, sigma) {
  sigma * sqrt(-2 * log(1 - p))
}

rayleigh_mle_sigma <- function(x) {
  sqrt(mean(x^2, na.rm = TRUE) / 2)
}

rayleigh_loglik <- function(x, sigma) {
  valid_x <- x[x > 0 & is.finite(x)]
  sum(log(drayleigh(valid_x, sigma)))
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
# 5. Fit function by zone
# ============================================================

fit_zone_distributions <- function(data_zone) {
  
  z <- unique(data_zone$zone)
  
  # Distribution fitting requires positive values.
  x <- data_zone[
    !is.na(VV) &
      is.finite(VV) &
      VV > 0,
    VV
  ]
  
  n <- length(x)
  
  if (n < 30) {
    return(list(
      parameters = data.table(
        zone = z,
        distribution = c("Weibull", "Rayleigh"),
        n_fit = n,
        shape = NA_real_,
        scale = NA_real_,
        sigma = NA_real_,
        logLik = NA_real_,
        AIC = NA_real_,
        BIC = NA_real_
      ),
      metrics = data.table(
        zone = z,
        distribution = c("Weibull", "Rayleigh"),
        n_fit = n,
        KS_statistic = NA_real_,
        KS_p_value = NA_real_,
        RMSE_density = NA_real_,
        MAE_density = NA_real_,
        RMSE_CDF = NA_real_,
        MAE_CDF = NA_real_
      ),
      density_curve = data.table(),
      cdf_curve = data.table()
    ))
  }
  
  # ----------------------------
  # Weibull fit
  # ----------------------------
  
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
  
  # ----------------------------
  # Rayleigh fit
  # ----------------------------
  
  rayleigh_sigma <- rayleigh_mle_sigma(x)
  rayleigh_logLik_value <- rayleigh_loglik(x, rayleigh_sigma)
  rayleigh_k <- 1
  rayleigh_AIC <- 2 * rayleigh_k - 2 * rayleigh_logLik_value
  rayleigh_BIC <- log(n) * rayleigh_k - 2 * rayleigh_logLik_value
  
  # ----------------------------
  # Empirical density grid
  # ----------------------------
  
  x_max <- max(x, na.rm = TRUE)
  
  grid <- seq(
    from = 0,
    to = x_max,
    length.out = 500
  )
  
  dens_emp <- density(
    x,
    from = 0,
    to = x_max,
    n = 512,
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
  
  # ----------------------------
  # CDF grid
  # ----------------------------
  
  ecdf_fun <- ecdf(x)
  
  cdf_grid <- data.table(
    x = grid,
    empirical_CDF = ecdf_fun(grid)
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
  
  # ----------------------------
  # Goodness-of-fit metrics
  # ----------------------------
  
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
  
  rmse_density_weibull <- sqrt(mean(
    (density_grid$empirical_density - density_grid$Weibull)^2,
    na.rm = TRUE
  ))
  
  mae_density_weibull <- mean(
    abs(density_grid$empirical_density - density_grid$Weibull),
    na.rm = TRUE
  )
  
  rmse_density_rayleigh <- sqrt(mean(
    (density_grid$empirical_density - density_grid$Rayleigh)^2,
    na.rm = TRUE
  ))
  
  mae_density_rayleigh <- mean(
    abs(density_grid$empirical_density - density_grid$Rayleigh),
    na.rm = TRUE
  )
  
  rmse_cdf_weibull <- sqrt(mean(
    (cdf_grid$empirical_CDF - cdf_grid$Weibull)^2,
    na.rm = TRUE
  ))
  
  mae_cdf_weibull <- mean(
    abs(cdf_grid$empirical_CDF - cdf_grid$Weibull),
    na.rm = TRUE
  )
  
  rmse_cdf_rayleigh <- sqrt(mean(
    (cdf_grid$empirical_CDF - cdf_grid$Rayleigh)^2,
    na.rm = TRUE
  ))
  
  mae_cdf_rayleigh <- mean(
    abs(cdf_grid$empirical_CDF - cdf_grid$Rayleigh),
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
  
  return(list(
    parameters = parameters,
    metrics = metrics,
    density_curve = density_curve,
    cdf_curve = cdf_curve
  ))
}

# ============================================================
# 6. Run fitting by zone
# ============================================================

zones <- sort(unique(dt$zone))

fit_results <- lapply(zones, function(z) {
  log_msg("Fitting distributions for zone:", z)
  fit_zone_distributions(dt[zone == z])
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
# 7. Distribution comparison
# ============================================================

comparison_table <- merge(
  parameters_by_zone,
  metrics_by_zone,
  by = c("zone", "distribution", "n_fit"),
  all = TRUE
)

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

comparison_table[, global_rank := frank(
  global_fit_score,
  ties.method = "min"
), by = zone]

best_distribution_by_zone <- comparison_table[
  global_rank == 1
][order(zone)]

best_distribution_by_zone[, interpretation := paste0(
  distribution,
  " provides the best overall fit according to the combined ranking of AIC, BIC, KS statistic, density RMSE and CDF RMSE."
)]

# ============================================================
# 8. Export tables
# ============================================================

write.xlsx(
  parameters_by_zone,
  file.path(DIR_TABLES, "03F_weibull_rayleigh_parameters_by_zone.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  metrics_by_zone,
  file.path(DIR_TABLES, "03F_weibull_rayleigh_fit_metrics_by_zone.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  comparison_table,
  file.path(DIR_TABLES, "03F_weibull_rayleigh_model_comparison_by_zone.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  best_distribution_by_zone,
  file.path(DIR_TABLES, "03F_best_distribution_by_zone.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  density_curve_data,
  file.path(DIR_TABLES, "03F_density_curve_data_by_zone.xlsx"),
  overwrite = TRUE
)

write.xlsx(
  cdf_curve_data,
  file.path(DIR_TABLES, "03F_cdf_curve_data_by_zone.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 9. Save results object
# ============================================================

results_object <- list(
  input_dataset = INPUT_MAIN_WPD,
  parameters_by_zone = parameters_by_zone,
  metrics_by_zone = metrics_by_zone,
  comparison_table = comparison_table,
  best_distribution_by_zone = best_distribution_by_zone,
  density_curve_data = density_curve_data,
  cdf_curve_data = cdf_curve_data
)

saveRDS(
  results_object,
  file.path(DIR_RESULTS, "03F_weibull_rayleigh_distribution_fitting.rds")
)

# ============================================================
# 10. Article figures
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

save_article_plot <- function(plot_object, filename, width = 8.5, height = 6.0) {
  
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

# ----------------------------
# Figure 5 — Density fit
# ----------------------------

density_plot_data <- density_curve_data[
  curve_type %in% c("empirical_density", "Weibull", "Rayleigh")
]

density_plot_data[, curve_type := factor(
  curve_type,
  levels = c("empirical_density", "Weibull", "Rayleigh"),
  labels = c("Empirical density", "Weibull", "Rayleigh")
)]

fig_density_fit <- ggplot(
  density_plot_data,
  aes(
    x = x,
    y = density,
    linetype = curve_type,
    linewidth = curve_type
  )
) +
  geom_line(na.rm = TRUE) +
  facet_wrap(~ zone, ncol = 2, scales = "free_y") +
  scale_linewidth_manual(
    values = c(
      "Empirical density" = 0.8,
      "Weibull" = 0.55,
      "Rayleigh" = 0.55
    )
  ) +
  labs(
    title = "Empirical, Weibull and Rayleigh wind-speed density fits",
    subtitle = "Main quality-controlled dataset; VV > 0 used for distribution fitting",
    x = expression("Wind speed, " * V[V] * " (m s"^-1*")"),
    y = "Probability density",
    linetype = "Curve",
    linewidth = "Curve"
  ) +
  article_theme

save_article_plot(
  fig_density_fit,
  "Fig_05_weibull_rayleigh_density_fit_by_zone.png",
  width = 8.8,
  height = 6.2
)

# ----------------------------
# Figure 6 — CDF fit
# ----------------------------

cdf_plot_data <- cdf_curve_data[
  curve_type %in% c("empirical_CDF", "Weibull", "Rayleigh")
]

cdf_plot_data[, curve_type := factor(
  curve_type,
  levels = c("empirical_CDF", "Weibull", "Rayleigh"),
  labels = c("Empirical CDF", "Weibull", "Rayleigh")
)]

fig_cdf_fit <- ggplot(
  cdf_plot_data,
  aes(
    x = x,
    y = CDF,
    linetype = curve_type,
    linewidth = curve_type
  )
) +
  geom_line(na.rm = TRUE) +
  facet_wrap(~ zone, ncol = 2) +
  scale_linewidth_manual(
    values = c(
      "Empirical CDF" = 0.8,
      "Weibull" = 0.55,
      "Rayleigh" = 0.55
    )
  ) +
  labs(
    title = "Empirical, Weibull and Rayleigh cumulative distribution fits",
    subtitle = "Main quality-controlled dataset; VV > 0 used for distribution fitting",
    x = expression("Wind speed, " * V[V] * " (m s"^-1*")"),
    y = "Cumulative probability",
    linetype = "Curve",
    linewidth = "Curve"
  ) +
  article_theme

save_article_plot(
  fig_cdf_fit,
  "Fig_06_weibull_rayleigh_CDF_fit_by_zone.png",
  width = 8.8,
  height = 6.2
)

# ----------------------------
# Figure 7 — AIC/BIC comparison
# ----------------------------

aic_bic_plot_data <- melt(
  comparison_table[, .(
    zone,
    distribution,
    AIC,
    BIC
  )],
  id.vars = c("zone", "distribution"),
  variable.name = "criterion",
  value.name = "value"
)

fig_aic_bic <- ggplot(
  aic_bic_plot_data,
  aes(
    x = distribution,
    y = value,
    shape = distribution
  )
) +
  geom_point(size = 2.7) +
  facet_grid(criterion ~ zone, scales = "free_y") +
  labs(
    title = "AIC and BIC comparison for Weibull and Rayleigh fits",
    subtitle = "Lower values indicate better information-criterion performance",
    x = "Distribution",
    y = "Information criterion value",
    shape = "Distribution"
  ) +
  article_theme +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1)
  )

save_article_plot(
  fig_aic_bic,
  "Fig_07_AIC_BIC_weibull_rayleigh_comparison.png",
  width = 8.8,
  height = 6.2
)

# ============================================================
# 11. Draft captions
# ============================================================

captions <- data.frame(
  figure_id = c(
    "Figure 5",
    "Figure 6",
    "Figure 7"
  ),
  filename = c(
    "Fig_05_weibull_rayleigh_density_fit_by_zone.png",
    "Fig_06_weibull_rayleigh_CDF_fit_by_zone.png",
    "Fig_07_AIC_BIC_weibull_rayleigh_comparison.png"
  ),
  draft_caption = c(
    "Empirical wind-speed density and fitted Weibull and Rayleigh distributions by analytical zone. Distribution fitting was performed using positive wind-speed values from the main quality-controlled dataset.",
    "Empirical cumulative distribution function and fitted Weibull and Rayleigh cumulative distributions by analytical zone.",
    "AIC and BIC comparison between Weibull and Rayleigh models by analytical zone. Lower values indicate better information-criterion performance."
  )
)

write.xlsx(
  captions,
  file.path(DIR_TABLES, "03F_draft_distribution_figure_captions.xlsx"),
  overwrite = TRUE
)

# ============================================================
# 12. Console report
# ============================================================

cat("\n============================================================\n")
cat("WEIBULL AND RAYLEIGH DISTRIBUTION FITTING — ARTICLE 1\n")
cat("============================================================\n\n")

cat("Input dataset:\n")
cat(INPUT_MAIN_WPD, "\n\n")

cat("Dataset summary:\n")
print(data.table(
  n_records = nrow(dt),
  n_zones = uniqueN(dt$zone),
  min_datetime = min(dt$datetime, na.rm = TRUE),
  max_datetime = max(dt$datetime, na.rm = TRUE),
  mean_VV = mean(dt$VV, na.rm = TRUE),
  median_VV = median(dt$VV, na.rm = TRUE),
  max_VV = max(dt$VV, na.rm = TRUE)
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
cat(DIR_FIGURES_DRAFT, "\n\n")

cat("Key exported files:\n")
cat("- 04_tables/03F_weibull_rayleigh_parameters_by_zone.xlsx\n")
cat("- 04_tables/03F_weibull_rayleigh_fit_metrics_by_zone.xlsx\n")
cat("- 04_tables/03F_weibull_rayleigh_model_comparison_by_zone.xlsx\n")
cat("- 04_tables/03F_best_distribution_by_zone.xlsx\n")
cat("- 04_tables/03F_density_curve_data_by_zone.xlsx\n")
cat("- 04_tables/03F_cdf_curve_data_by_zone.xlsx\n")
cat("- 04_tables/03F_draft_distribution_figure_captions.xlsx\n")
cat("- 03_figures/draft/Fig_05_weibull_rayleigh_density_fit_by_zone.png\n")
cat("- 03_figures/draft/Fig_06_weibull_rayleigh_CDF_fit_by_zone.png\n")
cat("- 03_figures/draft/Fig_07_AIC_BIC_weibull_rayleigh_comparison.png\n")
cat("- 02_results/03F_weibull_rayleigh_distribution_fitting.rds\n")
cat("============================================================\n")

log_msg("Weibull and Rayleigh distribution fitting completed successfully.")

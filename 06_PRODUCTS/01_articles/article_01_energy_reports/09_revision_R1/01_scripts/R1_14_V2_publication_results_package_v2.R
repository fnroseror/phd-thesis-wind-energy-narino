# ============================================================
# ENERGY REPORTS — REVISION R1
# R1_14_V2_PUBLICATION_RESULTS_PACKAGE_v2.R
#
# Manuscript: EGYR-D-26-02665
#
# Purpose:
# Freeze the publication-ready V2 results package:
#   MAIN TABLES
#     Table 2 — Descriptive statistics + dependence-aware WPD CI
#     Table 3 — Weibull/Rayleigh fit metrics + Weibull k CI
#     Table 4 — Kruskal-Wallis global tests
#     Table 5 — Temporal coverage, interpolation sensitivity and FFT summary
#
#   MAIN FIGURES
#     Monthly wind speed / WPD
#     Empirical CDF + Weibull/Rayleigh fits
#     Station contribution to zonal mean WPD
#     ACF sensitivity: observed vs short-gap interpolation
#     FFT spectral-band fractions
#
#   SUPPLEMENT
#     Full Dunn-Holm pairwise tests
#     Station contribution + paired/co-observed LOSO
#     Bootstrap sensitivity at 7/30/90 d
#     Full FFT band-energy table
#
# IMPORTANT:
# - Reads frozen V2 and previously audited R1 outputs.
# - Does NOT alter the canonical dataset.
# ============================================================

rm(list = ls())
gc()

# ------------------------------------------------------------
# 1. Packages
# ------------------------------------------------------------

required_packages <- c("data.table", "openxlsx")

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}

invisible(lapply(required_packages, install_if_missing))

suppressPackageStartupMessages({
  library(data.table)
  library(openxlsx)
})

# ------------------------------------------------------------
# 2. Paths
# ------------------------------------------------------------

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
DIR_FIGURES <- file.path(R1_ROOT, "03_figures")
DIR_RESULTS <- file.path(R1_ROOT, "04_results")
DIR_LOGS <- file.path(R1_ROOT, "06_logs")

invisible(lapply(
  c(DIR_TABLES, DIR_FIGURES, DIR_RESULTS, DIR_LOGS),
  dir.create,
  recursive = TRUE,
  showWarnings = FALSE
))

V2_FILE <- file.path(
  DIR_RESULTS,
  "R1_V2_CANONICAL_zone_hour_dataset.rds"
)

R1_10_FILE <- file.path(
  DIR_RESULTS,
  "R1_10_V2_statistical_core.rds"
)

R1_11_FILE <- file.path(
  DIR_RESULTS,
  "R1_11_V2_temporal_spectral_core.rds"
)

R1_13_FILE <- file.path(
  DIR_RESULTS,
  "R1_13_run_stratified_circular_block_bootstrap.rds"
)

required_files <- c(
  V2_FILE,
  R1_10_FILE,
  R1_11_FILE,
  R1_13_FILE
)

missing_files <- required_files[!file.exists(required_files)]

if (length(missing_files) > 0L) {
  stop(
    "Missing required file(s):\n",
    paste(missing_files, collapse = "\n")
  )
}

# ------------------------------------------------------------
# 3. Load frozen objects
# ------------------------------------------------------------

v2 <- as.data.table(readRDS(V2_FILE))
r10 <- readRDS(R1_10_FILE)
r11 <- readRDS(R1_11_FILE)
r13 <- readRDS(R1_13_FILE)

v2[, zone := as.character(zone)]
v2[, date := as.Date(date)]

stopifnot(nrow(v2) == 137811L)

# ------------------------------------------------------------
# 4. Recursive helper to retrieve audited tables
# ------------------------------------------------------------

find_table <- function(x, required_cols) {

  if (is.data.frame(x) || data.table::is.data.table(x)) {
    nms <- names(x)
    if (all(required_cols %in% nms)) {
      return(as.data.table(copy(x)))
    }
  }

  if (is.list(x)) {
    for (i in seq_along(x)) {
      ans <- find_table(x[[i]], required_cols)
      if (!is.null(ans)) return(ans)
    }
  }

  NULL
}

desc <- find_table(
  r10,
  c(
    "zone", "n", "n_days",
    "mean_VV", "median_VV",
    "mean_WPD", "median_WPD",
    "p95_WPD", "p99_WPD", "max_WPD"
  )
)

fits <- find_table(
  r10,
  c(
    "zone", "model", "shape_k",
    "scale_or_sigma", "AIC", "BIC",
    "CDF_RMSE", "CDF_MAE", "KS_D"
  )
)

kw <- find_table(
  r10,
  c(
    "scale", "variable", "N",
    "groups", "H", "df",
    "p_value", "epsilon_squared"
  )
)

dunn <- find_table(
  r10,
  c(
    "scale", "variable",
    "group1", "group2",
    "z", "p_raw", "p_holm",
    "significant_0_05"
  )
)

if (any(vapply(
  list(desc, fits, kw, dunn),
  is.null,
  logical(1)
))) {
  stop("Could not recover one or more required R1-10 tables.")
}

desc[, zone := as.character(zone)]
fits[, zone := as.character(zone)]

# ------------------------------------------------------------
# 5. R1-13 primary uncertainty selections
# ------------------------------------------------------------

boot <- as.data.table(r13$summary)
boot[, zone := as.character(zone)]

primary_blocks <- data.table(
  zone = c("1", "2", "3", "4"),
  primary_block_days = c(90L, 90L, 30L, 7L)
)

boot_primary <- merge(
  boot,
  primary_blocks,
  by = "zone"
)[
  requested_block_days == primary_block_days
]

boot_wpd <- boot_primary[
  parameter == "Mean_WPD",
  .(
    zone,
    WPD_CI95_lower = percentile_CI95_lower,
    WPD_CI95_upper = percentile_CI95_upper,
    WPD_bootstrap_SE = bootstrap_SE,
    primary_block_days
  )
]

boot_k <- boot_primary[
  parameter == "Weibull_k",
  .(
    zone,
    k_CI95_lower = percentile_CI95_lower,
    k_CI95_upper = percentile_CI95_upper,
    k_bootstrap_SE = bootstrap_SE,
    primary_block_days
  )
]

# ------------------------------------------------------------
# 6. MAIN TABLE 2 — descriptive + WPD uncertainty
# ------------------------------------------------------------

table2 <- merge(
  desc,
  boot_wpd,
  by = "zone",
  all.x = TRUE
)

table2 <- table2[
  ,
  .(
    Zone = paste("Zone", zone),
    `Zone-hour observations` = n,
    `Observed days` = n_days,
    `Mean VV (m/s)` = round(mean_VV, 2),
    `Median VV (m/s)` = round(median_VV, 2),
    `Mean WPD (W/m2)` = round(mean_WPD, 2),
    `WPD 95% CI lower` = round(WPD_CI95_lower, 2),
    `WPD 95% CI upper` = round(WPD_CI95_upper, 2),
    `Median WPD (W/m2)` = round(median_WPD, 2),
    `WPD P95 (W/m2)` = round(p95_WPD, 2),
    `WPD P99 (W/m2)` = round(p99_WPD, 2),
    `Max WPD (W/m2)` = round(max_WPD, 2),
    `Bootstrap block (d)` = primary_block_days
  )
]

# ------------------------------------------------------------
# 7. MAIN TABLE 3 — distributional fits + k uncertainty
# ------------------------------------------------------------

table3 <- merge(
  fits,
  boot_k,
  by = "zone",
  all.x = TRUE
)

table3[
  model != "Weibull",
  `:=`(
    k_CI95_lower = NA_real_,
    k_CI95_upper = NA_real_,
    k_bootstrap_SE = NA_real_,
    primary_block_days = NA_integer_
  )
]

table3 <- table3[
  ,
  .(
    Zone = paste("Zone", zone),
    Model = model,
    `Weibull k` = round(shape_k, 3),
    `k 95% CI lower` = round(k_CI95_lower, 3),
    `k 95% CI upper` = round(k_CI95_upper, 3),
    `Scale / sigma` = round(scale_or_sigma, 3),
    AIC = round(AIC, 2),
    BIC = round(BIC, 2),
    `CDF RMSE` = round(CDF_RMSE, 4),
    `CDF MAE` = round(CDF_MAE, 4),
    `KS distance` = round(KS_D, 4)
  )
]

# ------------------------------------------------------------
# 8. MAIN TABLE 4 — global inferential tests
# ------------------------------------------------------------

table4 <- kw[
  ,
  .(
    Scale = scale,
    Variable = variable,
    N = N,
    Groups = groups,
    H = round(H, 2),
    df = df,
    `p-value` = format(
      p_value,
      scientific = TRUE,
      digits = 3
    ),
    `Epsilon-squared` = round(epsilon_squared, 3)
  )
]

# ------------------------------------------------------------
# 9. MAIN TABLE 5 — temporal / interpolation / spectral summary
# ------------------------------------------------------------

gap <- as.data.table(r11$gap_summary)
interp <- as.data.table(r11$interpolation_summary)
temporal <- as.data.table(r11$reviewer_temporal_table)
fft_summary <- as.data.table(r11$FFT_summary)
fft_bands <- as.data.table(r11$FFT_bands)

gap[, zone := as.character(zone)]
interp[, zone := as.character(zone)]
temporal[, zone := as.character(zone)]
fft_summary[, zone := as.character(zone)]
fft_bands[, zone := as.character(zone)]

# Preflight checks for R1-11 components used below.
required_gap_cols <- c(
  "zone",
  "pct_observed_days",
  "max_missing_gap_days",
  "max_internal_gap_days"
)

required_interp_cols <- c(
  "zone",
  "pct_interpolated_total_calendar"
)

required_fft_summary_cols <- c(
  "zone",
  "variable",
  "dominant_period_days"
)

required_fft_band_cols <- c(
  "zone",
  "variable",
  "band",
  "energy_fraction"
)

check_required_cols <- function(x, required, object_name) {
  miss <- setdiff(required, names(x))
  if (length(miss) > 0L) {
    stop(
      object_name,
      " is missing required column(s): ",
      paste(miss, collapse = ", ")
    )
  }
}

check_required_cols(gap, required_gap_cols, "R1-11 gap_summary")
check_required_cols(
  interp,
  required_interp_cols,
  "R1-11 interpolation_summary"
)
check_required_cols(
  fft_summary,
  required_fft_summary_cols,
  "R1-11 FFT_summary"
)
check_required_cols(
  fft_bands,
  required_fft_band_cols,
  "R1-11 FFT_bands"
)

# reviewer_temporal_table in R1-11 is already WPD-specific in the
# frozen output. Keep compatibility in case a later object includes
# an explicit variable column.
temporal_required <- c(
  "zone",
  "scenario",
  "lag1_correlation",
  "first_abs_corr_below_0_2",
  "segment_length_days",
  "pct_interpolated_days_in_segment"
)

missing_temporal_cols <- setdiff(
  temporal_required,
  names(temporal)
)

if (length(missing_temporal_cols) > 0L) {
  stop(
    "R1-11 reviewer_temporal_table is missing required column(s): ",
    paste(missing_temporal_cols, collapse = ", ")
  )
}

if ("variable" %in% names(temporal)) {

  temporal_wpd <- temporal[
    variable == "WPD",
    .(
      zone,
      scenario,
      lag1_correlation,
      first_abs_corr_below_0_2,
      segment_length_days,
      pct_interpolated_days_in_segment
    )
  ]

} else {

  temporal_wpd <- temporal[
    ,
    .(
      zone,
      scenario,
      lag1_correlation,
      first_abs_corr_below_0_2,
      segment_length_days,
      pct_interpolated_days_in_segment
    )
  ]
}

temporal_wide <- dcast(
  temporal_wpd,
  zone + segment_length_days +
    pct_interpolated_days_in_segment ~ scenario,
  value.var = c(
    "lag1_correlation",
    "first_abs_corr_below_0_2"
  )
)

fft_wpd <- fft_summary[
  variable == "WPD",
  .(
    zone,
    dominant_period_days
  )
]

dominant_band <- fft_bands[
  variable == "WPD",
  .SD[which.max(energy_fraction)],
  by = zone
][
  ,
  .(
    zone,
    dominant_band = band,
    dominant_band_fraction = energy_fraction
  )
]

table5_raw <- Reduce(
  function(x, y) merge(x, y, by = "zone", all = TRUE),
  list(
    gap,
    interp,
    temporal_wide,
    fft_wpd,
    dominant_band
  )
)

table5 <- table5_raw[
  ,
  .(
    Zone = paste("Zone", zone),
    `Observed calendar (%)` = round(pct_observed_days, 2),
    `Interpolated calendar (%)` =
      round(pct_interpolated_total_calendar, 2),
    `Maximum missing gap (d)` = max_missing_gap_days,
    `Maximum internal gap (d)` = max_internal_gap_days,
    `Lag-1 WPD observed` =
      round(
        lag1_correlation_Observed_calendar_pairs,
        3
      ),
    `Lag-1 WPD interpolated` =
      round(
        lag1_correlation_Short_gap_interp_max7_calendar_pairs,
        3
      ),
    `First |r| < 0.2 observed (d)` =
      first_abs_corr_below_0_2_Observed_calendar_pairs,
    `Continuous FFT segment (d)` = segment_length_days,
    `Dominant FFT period (d)` =
      round(dominant_period_days, 1),
    `Largest spectral band` = dominant_band,
    `Largest band fraction` =
      round(dominant_band_fraction, 3)
  )
]

# ------------------------------------------------------------
# 10. Frozen R1-09 station influence table
#
# Values are copied from the audited R1-09 compact output and
# retained here as a fallback-independent publication table.
# ------------------------------------------------------------

station_influence <- data.table(
  zone = c(
    rep("1", 5),
    rep("2", 4),
    rep("3", 5),
    rep("4", 2)
  ),
  station = c(
    "51025060", "51025080", "51035020",
    "51025090", "5102500128",
    "52055160", "52055220", "52055170", "52055230",
    "52055150", "5205500123", "47015100",
    "52055210", "52045080",
    "52040050", "52035040"
  ),
  pct_of_zonal_mean_WPD = c(
    94.0813633, 3.7503149, 1.4838142,
    0.5579184, 0.1265892,
    62.5090488, 16.5518021, 11.7769147, 9.1622345,
    78.2369035, 9.6924356, 5.7378836,
    4.2275553, 2.1052220,
    79.3092890, 20.6907110
  ),
  pct_change_mean_WPD_paired = c(
    -93.177585, 42.710988, 21.827241,
    24.673998, 3.752255,
    -60.845621, 21.582992, 20.139420, 20.353298,
    -74.570644, -3.376143, 3.626747,
    47.099258, 27.036965,
    35.555522, -10.700653
  ),
  pct_change_mean_WPD_coobserved = c(
    -97.46398, 46.08220, 38.73390,
    46.90526, 28.45392,
    -91.13980, 22.94611, 24.95538, 30.48539,
    -86.27630, -15.83003, 14.89349,
    52.64664, 41.67334,
    36.77532, -36.77532
  )
)

check_contribution <- station_influence[
  ,
  .(sum_pct = sum(pct_of_zonal_mean_WPD)),
  by = zone
]

if (any(abs(check_contribution$sum_pct - 100) > 1e-4)) {
  stop("Station contribution percentages do not sum to 100%.")
}

# ------------------------------------------------------------
# 11. Main and supplementary workbooks
# ------------------------------------------------------------

MAIN_XLSX <- file.path(
  DIR_TABLES,
  "R1_V2_MAIN_PUBLICATION_TABLES.xlsx"
)

SUPP_XLSX <- file.path(
  DIR_TABLES,
  "R1_V2_SUPPLEMENTARY_TABLES.xlsx"
)

write.xlsx(
  list(
    Table2_Descriptive = table2,
    Table3_DistributionFits = table3,
    Table4_KruskalWallis = table4,
    Table5_TemporalSpectral = table5
  ),
  MAIN_XLSX,
  overwrite = TRUE
)

write.xlsx(
  list(
    S1_DunnHolm = dunn,
    S2_StationInfluence = station_influence,
    S3_BootstrapSensitivity = boot,
    S4_FFTBands = fft_bands
  ),
  SUPP_XLSX,
  overwrite = TRUE
)

# CSV copies for transparent reuse
fwrite(
  table2,
  file.path(DIR_TABLES, "R1_Table2_V2_descriptive_uncertainty.csv")
)

fwrite(
  table3,
  file.path(DIR_TABLES, "R1_Table3_V2_distribution_fits.csv")
)

fwrite(
  table4,
  file.path(DIR_TABLES, "R1_Table4_V2_Kruskal_Wallis.csv")
)

fwrite(
  table5,
  file.path(DIR_TABLES, "R1_Table5_V2_temporal_spectral.csv")
)

# ------------------------------------------------------------
# 12. Figure style
# ------------------------------------------------------------

zone_cols <- c(
  "1" = "#1F4E79",
  "2" = "#2E75B6",
  "3" = "#70AD47",
  "4" = "#C55A11"
)

zone_lty <- c(
  "1" = 1,
  "2" = 2,
  "3" = 3,
  "4" = 4
)

export_three_formats <- function(
    basename,
    width,
    height,
    draw_fun
) {

  pdf(
    file.path(DIR_FIGURES, paste0(basename, ".pdf")),
    width = width,
    height = height,
    useDingbats = FALSE
  )
  draw_fun()
  dev.off()

  tiff(
    file.path(DIR_FIGURES, paste0(basename, ".tiff")),
    width = width,
    height = height,
    units = "in",
    res = 600,
    compression = "lzw"
  )
  draw_fun()
  dev.off()

  png(
    file.path(DIR_FIGURES, paste0(basename, ".png")),
    width = width,
    height = height,
    units = "in",
    res = 300
  )
  draw_fun()
  dev.off()
}

# ------------------------------------------------------------
# 13. FIGURE — monthly mean VV and WPD
# ------------------------------------------------------------

v2[, month := as.Date(format(date, "%Y-%m-01"))]

monthly <- v2[
  ,
  .(
    mean_VV = mean(VV, na.rm = TRUE),
    mean_WPD = mean(WPD, na.rm = TRUE)
  ),
  by = .(zone, month)
]

draw_monthly <- function() {

  op <- par(no.readonly = TRUE)
  on.exit(par(op), add = TRUE)

  par(
    mfrow = c(2, 1),
    mar = c(3.5, 4.5, 2.2, 1.2),
    oma = c(0.5, 0.5, 0.3, 0.3),
    family = "sans"
  )

  # Wind speed
  plot(
    range(monthly$month),
    range(monthly$mean_VV, na.rm = TRUE),
    type = "n",
    xlab = "",
    ylab = expression("Monthly mean wind speed (m s"^{-1}*")"),
    main = "(a) Wind speed",
    xaxt = "n"
  )

  for (z in names(zone_cols)) {
    dz <- monthly[zone == z][order(month)]
    lines(
      dz$month,
      dz$mean_VV,
      col = zone_cols[z],
      lty = zone_lty[z],
      lwd = 1.7
    )
  }

  axis.Date(
    1,
    at = seq(
      as.Date("2017-01-01"),
      as.Date("2022-01-01"),
      by = "1 year"
    ),
    format = "%Y"
  )

  grid(nx = NA, ny = NULL, lty = 3)

  legend(
    "topright",
    legend = paste("Zone", names(zone_cols)),
    col = zone_cols,
    lty = zone_lty,
    lwd = 1.7,
    bty = "n",
    cex = 0.8
  )

  # WPD
  plot(
    range(monthly$month),
    range(monthly$mean_WPD, na.rm = TRUE),
    type = "n",
    xlab = "Year",
    ylab = expression("Monthly mean WPD (W m"^{-2}*")"),
    main = "(b) Wind power density",
    xaxt = "n"
  )

  for (z in names(zone_cols)) {
    dz <- monthly[zone == z][order(month)]
    lines(
      dz$month,
      dz$mean_WPD,
      col = zone_cols[z],
      lty = zone_lty[z],
      lwd = 1.7
    )
  }

  axis.Date(
    1,
    at = seq(
      as.Date("2017-01-01"),
      as.Date("2022-01-01"),
      by = "1 year"
    ),
    format = "%Y"
  )

  grid(nx = NA, ny = NULL, lty = 3)
}

export_three_formats(
  "R1_Figure_V2_monthly_VV_WPD",
  8.5,
  7,
  draw_monthly
)

# ------------------------------------------------------------
# 14. FIGURE — empirical CDF vs Weibull / Rayleigh
# ------------------------------------------------------------

draw_cdf <- function() {

  op <- par(no.readonly = TRUE)
  on.exit(par(op), add = TRUE)

  par(
    mfrow = c(2, 2),
    mar = c(4.0, 4.2, 2.3, 1.0),
    oma = c(0.4, 0.4, 0.4, 0.4),
    family = "sans"
  )

  for (z in c("1", "2", "3", "4")) {

    vv <- sort(
      v2[
        zone == z &
          is.finite(VV) &
          VV > 0,
        VV
      ]
    )

    n <- length(vv)

    idx <- unique(
      round(
        seq(
          1,
          n,
          length.out = min(n, 2500L)
        )
      )
    )

    x_emp <- vv[idx]
    y_emp <- idx / n

    fit_w <- fits[
      zone == z &
        model == "Weibull"
    ]

    fit_r <- fits[
      zone == z &
        model == "Rayleigh"
    ]

    xmax <- as.numeric(
      quantile(
        vv,
        0.995,
        names = FALSE
      )
    )

    xgrid <- seq(0, xmax, length.out = 500)

    cdf_w <- pweibull(
      xgrid,
      shape = fit_w$shape_k[1],
      scale = fit_w$scale_or_sigma[1]
    )

    sigma_r <- fit_r$scale_or_sigma[1]

    cdf_r <- 1 - exp(
      -(xgrid^2) /
        (2 * sigma_r^2)
    )

    plot(
      x_emp,
      y_emp,
      type = "l",
      lwd = 2,
      xlim = c(0, xmax),
      ylim = c(0, 1),
      xlab = expression("Wind speed (m s"^{-1}*")"),
      ylab = "Cumulative probability",
      main = paste("Zone", z)
    )

    lines(
      xgrid,
      cdf_w,
      lwd = 1.8,
      lty = 2
    )

    lines(
      xgrid,
      cdf_r,
      lwd = 1.8,
      lty = 3
    )

    grid(nx = NA, ny = NULL, lty = 3)

    if (z == "1") {
      legend(
        "bottomright",
        legend = c(
          "Empirical",
          "Weibull",
          "Rayleigh"
        ),
        lty = c(1, 2, 3),
        lwd = c(2, 1.8, 1.8),
        bty = "n",
        cex = 0.78
      )
    }
  }
}

export_three_formats(
  "R1_Figure_V2_CDF_Weibull_Rayleigh",
  8.5,
  7.2,
  draw_cdf
)

# ------------------------------------------------------------
# 15. FIGURE — station contribution
# ------------------------------------------------------------

draw_station_contribution <- function() {

  op <- par(no.readonly = TRUE)
  on.exit(par(op), add = TRUE)

  par(
    mfrow = c(2, 2),
    mar = c(4.2, 6.5, 2.5, 1.0),
    oma = c(0.5, 0.4, 0.4, 0.4),
    family = "sans"
  )

  for (z in c("1", "2", "3", "4")) {

    dz <- station_influence[
      zone == z
    ][
      order(pct_of_zonal_mean_WPD)
    ]

    bp <- barplot(
      dz$pct_of_zonal_mean_WPD,
      names.arg = dz$station,
      horiz = TRUE,
      las = 1,
      xlim = c(0, 105),
      col = adjustcolor(
        zone_cols[z],
        alpha.f = 0.78
      ),
      border = NA,
      xlab = "Contribution to zonal mean WPD (%)",
      main = paste("Zone", z),
      cex.names = 0.72
    )

    text(
      dz$pct_of_zonal_mean_WPD + 1.4,
      bp,
      labels = sprintf(
        "%.1f",
        dz$pct_of_zonal_mean_WPD
      ),
      adj = c(0, 0.5),
      cex = 0.72
    )

    abline(
      v = 50,
      lty = 3
    )
  }
}

export_three_formats(
  "R1_Figure_V2_station_WPD_contribution",
  9,
  7.5,
  draw_station_contribution
)

# ------------------------------------------------------------
# 16. FIGURE — ACF sensitivity observed vs interpolation
# ------------------------------------------------------------

acf_calendar <- as.data.table(
  r11$calendar_lag_correlations
)

acf_calendar[, zone := as.character(zone)]

acf_wpd <- acf_calendar[
  variable == "WPD"
]

draw_acf_sensitivity <- function() {

  op <- par(no.readonly = TRUE)
  on.exit(par(op), add = TRUE)

  par(
    mfrow = c(2, 2),
    mar = c(4.0, 4.2, 2.4, 1.0),
    oma = c(0.4, 0.4, 0.4, 0.4),
    family = "sans"
  )

  for (z in c("1", "2", "3", "4")) {

    obs <- acf_wpd[
      zone == z &
        scenario == "Observed_calendar_pairs"
    ][order(lag)]

    int <- acf_wpd[
      zone == z &
        scenario ==
          "Short_gap_interp_max7_calendar_pairs"
    ][order(lag)]

    ylim_use <- range(
      c(
        obs$correlation,
        int$correlation,
        -0.2,
        0.2
      ),
      na.rm = TRUE
    )

    plot(
      obs$lag,
      obs$correlation,
      type = "l",
      lwd = 2,
      xlim = c(0, 90),
      ylim = ylim_use,
      xlab = "Lag (days)",
      ylab = "Calendar-preserving correlation",
      main = paste("Zone", z)
    )

    lines(
      int$lag,
      int$correlation,
      lwd = 1.8,
      lty = 2
    )

    abline(
      h = c(-0.2, 0, 0.2),
      lty = c(3, 1, 3),
      lwd = c(1, 0.8, 1)
    )

    grid(nx = NA, ny = NULL, lty = 3)

    if (z == "1") {
      legend(
        "topright",
        legend = c(
          "Observed calendar pairs",
          "Short-gap interpolation <= 7 d"
        ),
        lty = c(1, 2),
        lwd = c(2, 1.8),
        bty = "n",
        cex = 0.72
      )
    }
  }
}

export_three_formats(
  "R1_Figure_V2_ACF_interpolation_sensitivity",
  8.5,
  7.2,
  draw_acf_sensitivity
)

# ------------------------------------------------------------
# 17. FIGURE — WPD spectral-band fractions
# ------------------------------------------------------------

band_order <- c(
  "2-10 d",
  "10-30 d",
  "30-120 d",
  "120-365 d",
  ">365 d"
)

spectral_wide <- dcast(
  fft_bands[
    variable == "WPD"
  ],
  zone ~ band,
  value.var = "energy_fraction",
  fill = 0
)

spectral_wide[, zone := as.character(zone)]

for (b in band_order) {
  if (!b %in% names(spectral_wide)) {
    spectral_wide[, (b) := 0]
  }
}

spectral_matrix <- t(
  as.matrix(
    spectral_wide[
      ,
      ..band_order
    ]
  )
)

colnames(spectral_matrix) <- paste(
  "Zone",
  spectral_wide$zone
)

band_cols <- c(
  "#D9EAF7",
  "#A9CFE5",
  "#78B2D1",
  "#4D8EB8",
  "#285F8F"
)

draw_spectral <- function() {

  op <- par(no.readonly = TRUE)
  on.exit(par(op), add = TRUE)

  par(
    mar = c(4.5, 4.8, 2.0, 1.0),
    family = "sans"
  )

  barplot(
    spectral_matrix * 100,
    beside = FALSE,
    col = band_cols,
    border = NA,
    ylim = c(0, 100),
    ylab = "Fraction of one-sided spectral power (%)",
    xlab = "Analytical zone",
    legend.text = band_order,
    args.legend = list(
      x = "topright",
      bty = "n",
      cex = 0.75
    )
  )

  grid(nx = NA, ny = NULL, lty = 3)
}

export_three_formats(
  "R1_Figure_V2_WPD_spectral_bands",
  7.5,
  5.6,
  draw_spectral
)

# ------------------------------------------------------------
# 18. Captions
# ------------------------------------------------------------

captions <- c(
  Monthly_VV_WPD = paste(
    "Figure X. Monthly mean wind speed and wind power density",
    "for the four analytical zones using the canonical V2 dataset.",
    "The two variables are shown separately because WPD is computed",
    "from local station-hour energetic states before zonal aggregation."
  ),
  CDF = paste(
    "Figure X. Empirical cumulative wind-speed distributions and",
    "fitted Weibull and Rayleigh models by analytical zone.",
    "The comparison illustrates the clear Weibull advantage in Zone 1",
    "and the metric-dependent similarity between models in Zones 2–4."
  ),
  Station = paste(
    "Figure X. Direct contribution of individual stations to the",
    "long-term zonal mean wind power density. Percentages sum to 100%",
    "within each analytical zone and quantify the concentration of the",
    "energetic signal in the observed station network."
  ),
  ACF = paste(
    "Figure X. Sensitivity of calendar-preserving WPD lag correlations",
    "to short-gap interpolation. Solid lines use observed calendar pairs;",
    "dashed lines use linear interpolation only for internal gaps of",
    "seven days or less. The close agreement indicates that the observed",
    "short-lag persistence is not generated by interpolation."
  ),
  FFT = paste(
    "Figure X. Fraction of one-sided WPD spectral power by period band",
    "for the longest continuous daily segment available in each zone",
    "after interpolation of internal gaps of seven days or less.",
    "Spectral fractions are interpreted as descriptors of temporal",
    "variability rather than deterministic atmospheric cycles."
  )
)

writeLines(
  paste(
    names(captions),
    captions,
    sep = "\n"
  ),
  file.path(
    DIR_FIGURES,
    "R1_V2_RESULTS_FIGURE_CAPTIONS.txt"
  )
)

# ------------------------------------------------------------
# 19. Publication-package decision note
# ------------------------------------------------------------

decision_note <- c(
  "R1-14 V2 PUBLICATION RESULTS PACKAGE",
  "",
  "MAIN MANUSCRIPT TABLES:",
  "Table 2 — Descriptive statistics and dependence-aware WPD uncertainty.",
  "Table 3 — Weibull/Rayleigh fit metrics and Weibull k uncertainty.",
  "Table 4 — Kruskal-Wallis global comparisons and effect sizes.",
  "Table 5 — Temporal coverage, interpolation sensitivity and spectral summary.",
  "",
  "MAIN MANUSCRIPT FIGURES:",
  "Monthly VV/WPD time series.",
  "Empirical CDF with Weibull/Rayleigh fits.",
  "Station contribution to zonal mean WPD.",
  "ACF interpolation-sensitivity comparison.",
  "WPD spectral-band composition.",
  "",
  "SUPPLEMENTARY:",
  "Full Dunn-Holm pairwise results.",
  "Detailed station contribution and LOSO sensitivity.",
  "Bootstrap sensitivity at 7, 30 and 90 days.",
  "Full FFT band-energy fractions.",
  "",
  "Interpretation remains conditional on the observed station network.",
  "No output in this package is an area-weighted continuous wind-resource estimate."
)

SUMMARY_FILE <- file.path(
  DIR_RESULTS,
  "R1_14_PUBLICATION_PACKAGE_SUMMARY_v2.txt"
)

writeLines(
  decision_note,
  SUMMARY_FILE
)

cat(
  paste(decision_note, collapse = "\n"),
  "\n"
)

cat("\nMain workbook:\n", MAIN_XLSX, "\n", sep = "")
cat("Supplement workbook:\n", SUPP_XLSX, "\n", sep = "")
cat("Summary:\n", SUMMARY_FILE, "\n", sep = "")

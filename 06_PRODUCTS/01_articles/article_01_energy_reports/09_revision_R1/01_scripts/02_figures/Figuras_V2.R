# ============================================================
# ENERGY REPORTS — REVISION V2
# R1_15_V2_FINAL_MANUSCRIPT_FIGURES.R
#
# Manuscript: EGYR-D-26-02665
#
# PURPOSE
# Build the FINAL main-manuscript figure package from the
# frozen V2 analytical objects. This script DOES NOT modify
# the canonical V2 dataset and DOES NOT reuse analytical
# figures from V1.
#
# FINAL FIGURE PLAN
#   Figure 1  Wind capacity: World / South America / Colombia
#             (already generated in the revision workflow)
#   Figure 2  Study area + IDEAM network + analytical units
#             (map can be retained if station grouping is unchanged;
#              caption must be revised)
#   Figure 3  Methodological framework V2
#             (already generated and frozen)
#   Figure 4  Monthly wind speed and WPD — canonical V2
#   Figure 5  Empirical CDF + Weibull / Rayleigh — canonical V2
#   Figure 6  Station contribution to zonal mean WPD — R1-09
#   Figure 7  ACF interpolation sensitivity — R1-11
#   Figure 8  WPD spectral-band fractions — R1-11
#
# IMPORTANT
# - All result figures are generated from frozen V2/R1 outputs.
# - Figure numbering is final-provisional and can be adjusted
#   after manuscript integration without changing the analysis.
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

FINAL_DIR <- file.path(
  DIR_FIGURES,
  "final_manuscript_v2"
)

dir.create(
  FINAL_DIR,
  recursive = TRUE,
  showWarnings = FALSE
)

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

SUPP_XLSX <- file.path(
  DIR_TABLES,
  "R1_V2_SUPPLEMENTARY_TABLES.xlsx"
)

required_files <- c(
  V2_FILE,
  R1_10_FILE,
  R1_11_FILE,
  SUPP_XLSX
)

missing_files <- required_files[!file.exists(required_files)]

if (length(missing_files) > 0L) {
  stop(
    paste0(
      "Missing required V2 file(s):\n",
      paste(missing_files, collapse = "\n")
    )
  )
}

# ------------------------------------------------------------
# 3. Load frozen analytical objects
# ------------------------------------------------------------

v2 <- as.data.table(readRDS(V2_FILE))
r10 <- readRDS(R1_10_FILE)
r11 <- readRDS(R1_11_FILE)

v2[, zone := as.character(zone)]
v2[, date := as.Date(date)]

if (nrow(v2) != 137811L) {
  stop(
    "Canonical V2 row count mismatch. Expected 137811; found ",
    nrow(v2),
    "."
  )
}

required_v2_cols <- c("zone", "date", "VV", "WPD")
missing_v2_cols <- setdiff(required_v2_cols, names(v2))

if (length(missing_v2_cols) > 0L) {
  stop(
    "Canonical V2 dataset is missing: ",
    paste(missing_v2_cols, collapse = ", ")
  )
}

# ------------------------------------------------------------
# 4. Helper: recursively retrieve audited R1-10 tables
# ------------------------------------------------------------

find_table <- function(x, required_cols) {

  if (is.data.frame(x) || data.table::is.data.table(x)) {
    if (all(required_cols %in% names(x))) {
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

fits <- find_table(
  r10,
  c(
    "zone",
    "model",
    "shape_k",
    "scale_or_sigma",
    "AIC",
    "BIC",
    "CDF_RMSE",
    "CDF_MAE",
    "KS_D"
  )
)

if (is.null(fits)) {
  stop("Could not locate Weibull/Rayleigh fit table in R1-10.")
}

fits[, zone := as.character(zone)]

# Exact model names required for the publication figure.
if (!all(c("Weibull", "Rayleigh") %in% unique(fits$model))) {
  stop(
    "Unexpected model labels in R1-10: ",
    paste(unique(fits$model), collapse = ", ")
  )
}

# ------------------------------------------------------------
# 5. Station contribution from frozen R1-14 supplement
# ------------------------------------------------------------

station_influence <- as.data.table(
  read.xlsx(
    SUPP_XLSX,
    sheet = "S2_StationInfluence"
  )
)

required_station_cols <- c(
  "zone",
  "station",
  "pct_of_zonal_mean_WPD"
)

missing_station_cols <- setdiff(
  required_station_cols,
  names(station_influence)
)

if (length(missing_station_cols) > 0L) {
  stop(
    "Station influence sheet is missing: ",
    paste(missing_station_cols, collapse = ", ")
  )
}

station_influence[, zone := as.character(zone)]
station_influence[, station := as.character(station)]

station_check <- station_influence[
  ,
  .(sum_pct = sum(pct_of_zonal_mean_WPD)),
  by = zone
]

if (any(abs(station_check$sum_pct - 100) > 1e-3)) {
  stop("Station contribution percentages do not sum to 100% by zone.")
}

# ------------------------------------------------------------
# 6. R1-11 temporal / spectral components
# ------------------------------------------------------------

if (is.null(r11$calendar_lag_correlations)) {
  stop("R1-11 object does not contain calendar_lag_correlations.")
}

acf_calendar <- as.data.table(
  r11$calendar_lag_correlations
)

required_acf_cols <- c(
  "zone",
  "variable",
  "scenario",
  "lag",
  "correlation"
)

missing_acf_cols <- setdiff(
  required_acf_cols,
  names(acf_calendar)
)

if (length(missing_acf_cols) > 0L) {
  stop(
    "R1-11 calendar_lag_correlations missing: ",
    paste(missing_acf_cols, collapse = ", ")
  )
}

acf_calendar[, zone := as.character(zone)]

# Retrieve the FFT band table robustly from the R1-11 object.
find_fft_bands <- function(x) {

  if (is.data.frame(x) || data.table::is.data.table(x)) {
    need <- c(
      "zone",
      "variable",
      "band",
      "energy_fraction"
    )

    if (all(need %in% names(x))) {
      return(as.data.table(copy(x)))
    }
  }

  if (is.list(x)) {
    for (i in seq_along(x)) {
      ans <- find_fft_bands(x[[i]])
      if (!is.null(ans)) return(ans)
    }
  }

  NULL
}

fft_bands <- find_fft_bands(r11)

if (is.null(fft_bands)) {
  stop("Could not locate FFT band-energy table in R1-11.")
}

fft_bands[, zone := as.character(zone)]

# ------------------------------------------------------------
# 7. Publication style
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
    file.path(FINAL_DIR, paste0(basename, ".pdf")),
    width = width,
    height = height,
    useDingbats = FALSE
  )
  draw_fun()
  dev.off()

  tiff(
    file.path(FINAL_DIR, paste0(basename, ".tiff")),
    width = width,
    height = height,
    units = "in",
    res = 600,
    compression = "lzw"
  )
  draw_fun()
  dev.off()

  png(
    file.path(FINAL_DIR, paste0(basename, ".png")),
    width = width,
    height = height,
    units = "in",
    res = 300
  )
  draw_fun()
  dev.off()
}

safe_grid <- function() {
  grid(lty = 3)
}

# ------------------------------------------------------------
# 8. Figure 4 — Monthly mean VV and WPD
# ------------------------------------------------------------

v2[, month := as.Date(format(date, "%Y-%m-01"))]

monthly <- v2[
  ,
  .(
    mean_VV = mean(VV, na.rm = TRUE),
    mean_WPD = mean(WPD, na.rm = TRUE)
  ),
  by = .(zone, month)
][order(zone, month)]

draw_figure4 <- function() {

  op <- par(no.readonly = TRUE)
  on.exit(par(op), add = TRUE)

  par(
    mfrow = c(2, 1),
    mar = c(3.6, 4.8, 2.0, 1.0),
    oma = c(0.4, 0.4, 0.2, 0.2),
    family = "sans"
  )

  # Panel a
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
    dz <- monthly[zone == z]
    lines(
      dz$month,
      dz$mean_VV,
      col = zone_cols[z],
      lty = zone_lty[z],
      lwd = 1.8
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

  safe_grid()

  legend(
    "topright",
    legend = paste("Zone", names(zone_cols)),
    col = zone_cols,
    lty = zone_lty,
    lwd = 1.8,
    bty = "n",
    cex = 0.80
  )

  # Panel b
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
    dz <- monthly[zone == z]
    lines(
      dz$month,
      dz$mean_WPD,
      col = zone_cols[z],
      lty = zone_lty[z],
      lwd = 1.8
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

  safe_grid()
}

export_three_formats(
  "Figure_04_V2_Monthly_VV_WPD",
  8.5,
  7.0,
  draw_figure4
)

# ------------------------------------------------------------
# 9. Figure 5 — Empirical CDF vs Weibull / Rayleigh
# ------------------------------------------------------------

draw_figure5 <- function() {

  op <- par(no.readonly = TRUE)
  on.exit(par(op), add = TRUE)

  par(
    mfrow = c(2, 2),
    mar = c(4.0, 4.2, 2.2, 0.8),
    oma = c(0.3, 0.3, 0.3, 0.3),
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

    if (n < 10L) {
      stop("Too few positive VV observations in Zone ", z)
    }

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

    if (nrow(fit_w) != 1L || nrow(fit_r) != 1L) {
      stop("Expected one Weibull and one Rayleigh fit in Zone ", z)
    }

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
      lwd = 2.1,
      xlim = c(0, xmax),
      ylim = c(0, 1),
      xlab = expression("Wind speed (m s"^{-1}*")"),
      ylab = "Cumulative probability",
      main = paste("Zone", z)
    )

    lines(
      xgrid,
      cdf_w,
      lwd = 1.9,
      lty = 2
    )

    lines(
      xgrid,
      cdf_r,
      lwd = 1.9,
      lty = 3
    )

    safe_grid()

    if (z == "1") {
      legend(
        "bottomright",
        legend = c(
          "Empirical",
          "Weibull",
          "Rayleigh"
        ),
        lty = c(1, 2, 3),
        lwd = c(2.1, 1.9, 1.9),
        bty = "n",
        cex = 0.78
      )
    }
  }
}

export_three_formats(
  "Figure_05_V2_CDF_Weibull_Rayleigh",
  8.5,
  7.2,
  draw_figure5
)

# ------------------------------------------------------------
# Supplementary Figure S1 — empirical density vs fitted models
#
# This figure is retained specifically to address Reviewer 2's
# observation that relative Weibull superiority in Zone 1 does
# not imply a perfect absolute fit near zero.
# ------------------------------------------------------------

draw_figureS1 <- function() {

  op <- par(no.readonly = TRUE)
  on.exit(par(op), add = TRUE)

  par(
    mfrow = c(2, 2),
    mar = c(4.0, 4.2, 2.2, 0.8),
    oma = c(0.3, 0.3, 0.3, 0.3),
    family = "sans"
  )

  for (z in c("1", "2", "3", "4")) {

    vv <- v2[
      zone == z &
        is.finite(VV) &
        VV > 0,
      VV
    ]

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

    den <- density(
      vv,
      from = 0,
      to = xmax,
      n = 512,
      na.rm = TRUE
    )

    xgrid <- seq(0, xmax, length.out = 500)

    pdf_w <- dweibull(
      xgrid,
      shape = fit_w$shape_k[1],
      scale = fit_w$scale_or_sigma[1]
    )

    sigma_r <- fit_r$scale_or_sigma[1]

    pdf_r <- (
      xgrid / sigma_r^2
    ) * exp(
      -(xgrid^2) /
        (2 * sigma_r^2)
    )

    ylim_use <- range(
      c(
        den$y,
        pdf_w,
        pdf_r
      ),
      na.rm = TRUE
    )

    plot(
      den$x,
      den$y,
      type = "l",
      lwd = 2.1,
      xlim = c(0, xmax),
      ylim = ylim_use,
      xlab = expression("Wind speed (m s"^{-1}*")"),
      ylab = "Probability density",
      main = paste("Zone", z)
    )

    lines(
      xgrid,
      pdf_w,
      lwd = 1.9,
      lty = 2
    )

    lines(
      xgrid,
      pdf_r,
      lwd = 1.9,
      lty = 3
    )

    safe_grid()

    if (z == "1") {
      legend(
        "topright",
        legend = c(
          "Empirical density",
          "Weibull",
          "Rayleigh"
        ),
        lty = c(1, 2, 3),
        lwd = c(2.1, 1.9, 1.9),
        bty = "n",
        cex = 0.76
      )
    }
  }
}

export_three_formats(
  "Figure_S1_V2_Density_Weibull_Rayleigh",
  8.5,
  7.2,
  draw_figureS1
)

# ------------------------------------------------------------
# 10. Figure 6 — Station contribution to zonal mean WPD
# ------------------------------------------------------------

draw_figure6 <- function() {

  op <- par(no.readonly = TRUE)
  on.exit(par(op), add = TRUE)

  par(
    mfrow = c(2, 2),
    mar = c(4.2, 6.8, 2.3, 1.0),
    oma = c(0.4, 0.3, 0.2, 0.2),
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
      dz$pct_of_zonal_mean_WPD + 1.2,
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
      lty = 3,
      lwd = 1
    )
  }
}

export_three_formats(
  "Figure_06_V2_Station_WPD_Contribution",
  9.0,
  7.5,
  draw_figure6
)

# ------------------------------------------------------------
# 11. Figure 7 — ACF interpolation sensitivity
# ------------------------------------------------------------

acf_wpd <- acf_calendar[
  variable == "WPD"
]

expected_scenarios <- c(
  "Observed_calendar_pairs",
  "Short_gap_interp_max7_calendar_pairs"
)

if (!all(expected_scenarios %in% unique(acf_wpd$scenario))) {
  stop(
    "R1-11 does not contain both expected ACF scenarios."
  )
}

draw_figure7 <- function() {

  op <- par(no.readonly = TRUE)
  on.exit(par(op), add = TRUE)

  par(
    mfrow = c(2, 2),
    mar = c(4.0, 4.4, 2.2, 0.8),
    oma = c(0.3, 0.3, 0.3, 0.3),
    family = "sans"
  )

  for (z in c("1", "2", "3", "4")) {

    obs <- acf_wpd[
      zone == z &
        scenario == "Observed_calendar_pairs"
    ][order(lag)]

    int <- acf_wpd[
      zone == z &
        scenario == "Short_gap_interp_max7_calendar_pairs"
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
      lwd = 2.1,
      xlim = c(0, 90),
      ylim = ylim_use,
      xlab = "Lag (days)",
      ylab = "Calendar-preserving correlation",
      main = paste("Zone", z)
    )

    lines(
      int$lag,
      int$correlation,
      lwd = 1.9,
      lty = 2
    )

    abline(
      h = c(-0.2, 0, 0.2),
      lty = c(3, 1, 3),
      lwd = c(1, 0.8, 1)
    )

    safe_grid()

    if (z == "1") {
      legend(
        "topright",
        legend = c(
          "Observed calendar pairs",
          "Short-gap interpolation <= 7 d"
        ),
        lty = c(1, 2),
        lwd = c(2.1, 1.9),
        bty = "n",
        cex = 0.70
      )
    }
  }
}

export_three_formats(
  "Figure_07_V2_ACF_Interpolation_Sensitivity",
  8.5,
  7.2,
  draw_figure7
)

# ------------------------------------------------------------
# 12. Figure 8 — WPD spectral-band fractions
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

spectral_wide <- spectral_wide[
  match(c("1", "2", "3", "4"), zone)
]

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

draw_figure8 <- function() {

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

  safe_grid()
}

export_three_formats(
  "Figure_08_V2_WPD_Spectral_Bands",
  7.5,
  5.6,
  draw_figure8
)

# ------------------------------------------------------------
# 13. Copy already-frozen revision figures 1 and 3
# ------------------------------------------------------------

copy_if_exists <- function(src_base, dst_base) {

  copied <- character()

  for (ext in c("pdf", "tiff", "png")) {

    src <- file.path(
      DIR_FIGURES,
      paste0(src_base, ".", ext)
    )

    dst <- file.path(
      FINAL_DIR,
      paste0(dst_base, ".", ext)
    )

    if (file.exists(src)) {
      ok <- file.copy(
        src,
        dst,
        overwrite = TRUE
      )

      if (ok) copied <- c(copied, dst)
    }
  }

  copied
}

fig1_copied <- copy_if_exists(
  "R1_Figure_wind_capacity_global_SouthAmerica_Colombia_2016_2025_v2",
  "Figure_01_V2_Wind_Capacity_2016_2025"
)

fig3_copied <- copy_if_exists(
  "R1_Figure_methodological_framework_V2",
  "Figure_03_V2_Methodological_Framework"
)

# ------------------------------------------------------------
# 14. Captions — final-provisional numbering
# ------------------------------------------------------------

captions <- c(
  Figure_01 = paste(
    "Figure 1. Evolution of installed wind-power capacity at global,",
    "South American, and Colombian scales from 2016 to 2025.",
    "Panels use independent vertical scales to preserve readability.",
    "Capacity corresponds to maximum net generating capacity installed",
    "and connected at the end of each calendar year. Source: IRENA (2026),",
    "Renewable Capacity Statistics 2026."
  ),

  Figure_02 = paste(
    "Figure 2. Physiographic setting, IDEAM meteorological stations,",
    "and analytical aggregation units in Nariño, Colombia.",
    "The four analytical units organize the observed monitoring network",
    "for comparative analysis and should not be interpreted as homogeneous",
    "wind-resource regions or continuous spatial resource estimates."
  ),

  Figure_03 = paste(
    "Figure 3. Revised methodological framework for the physical-statistical",
    "characterization of wind power density. Quality control and nonlinear",
    "energetic transformation are applied at station-hour scale before",
    "equal-station zonal aggregation. Subsequent analyses quantify",
    "distributional structure, station-composition sensitivity, temporal",
    "dependence, spectral organization, and uncertainty."
  ),

  Figure_04 = paste(
    "Figure 4. Monthly mean wind speed and wind power density for the four",
    "analytical units using the canonical V2 dataset. Wind speed and WPD are",
    "shown separately because local station-hour WPD is calculated before",
    "equal-station zonal aggregation."
  ),

  Figure_05 = paste(
    "Figure 5. Empirical cumulative wind-speed distributions with fitted",
    "Weibull and Rayleigh models by analytical unit. Weibull provides a",
    "clear relative improvement over Rayleigh in Zone 1, whereas model",
    "performance in Zones 2–4 depends on the selected goodness-of-fit metric."
  ),

  Figure_06 = paste(
    "Figure 6. Direct contribution of individual IDEAM stations to the",
    "long-term zonal mean WPD. Contributions sum to 100% within each",
    "analytical unit and quantify the dependence of the aggregated energetic",
    "signal on the composition of the observed station network."
  ),

  Figure_07 = paste(
    "Figure 7. Sensitivity of calendar-preserving WPD lag correlations to",
    "short-gap interpolation. Solid lines use observed calendar pairs;",
    "dashed lines use linear interpolation only for internal gaps of seven",
    "days or less. Their close agreement indicates that short-lag persistence",
    "is not generated by the interpolation procedure."
  ),

  Figure_08 = paste(
    "Figure 8. Fraction of one-sided WPD spectral power by period band for",
    "the longest continuous daily segment available in each analytical unit",
    "after interpolation of internal gaps of seven days or less. Spectral",
    "fractions are interpreted as descriptors of temporal variability rather",
    "than as evidence of deterministic atmospheric cycles."
  ),

  Figure_S1 = paste(
    "Figure S1. Empirical wind-speed density with fitted Weibull and Rayleigh",
    "models by analytical unit. The figure is retained to distinguish relative",
    "model performance from absolute goodness of fit, particularly in Zone 1,",
    "where Weibull improves substantially on Rayleigh but does not reproduce",
    "the empirical density perfectly near the lowest wind-speed states."
  )
)

writeLines(
  paste(
    names(captions),
    captions,
    sep = "\n"
  ),
  file.path(
    FINAL_DIR,
    "V2_FINAL_FIGURE_CAPTIONS.txt"
  )
)

# ------------------------------------------------------------
# 15. Figure manifest / audit
# ------------------------------------------------------------

expected_result_png <- c(
  "Figure_04_V2_Monthly_VV_WPD.png",
  "Figure_05_V2_CDF_Weibull_Rayleigh.png",
  "Figure_06_V2_Station_WPD_Contribution.png",
  "Figure_07_V2_ACF_Interpolation_Sensitivity.png",
  "Figure_08_V2_WPD_Spectral_Bands.png"
)

result_check <- data.table(
  file = expected_result_png,
  exists = file.exists(
    file.path(FINAL_DIR, expected_result_png)
  )
)

manifest <- c(
  "ENERGY REPORTS — V2 FINAL MANUSCRIPT FIGURE PACKAGE",
  "",
  paste0("Generated: ", format(Sys.time())),
  paste0("Canonical V2 rows: ", nrow(v2)),
  "",
  "FIGURE PLAN",
  "Figure 1 — Wind capacity (revision figure already frozen).",
  "Figure 2 — Study area / IDEAM network / analytical units.",
  "             Retain map only if station grouping and station locations are unchanged.",
  "             Caption MUST use 'analytical aggregation units' framing.",
  "Figure 3 — Methodological framework V2 (frozen).",
  "Figure 4 — Monthly VV and WPD from canonical V2.",
  "Figure 5 — Empirical CDF + Weibull/Rayleigh from canonical V2/R1-10.",
  "Figure 6 — Station contribution from frozen R1-09 output.",
  "Figure 7 — ACF sensitivity from R1-11.",
  "Figure 8 — WPD spectral bands from R1-11.",
  "Figure S1 — Empirical density + Weibull/Rayleigh, retained as",
  "            direct evidence for Reviewer 2 comment 7.",
  "",
  "V1 ANALYTICAL FIGURES MUST NOT BE USED IN THE REVISED MANUSCRIPT.",
  "",
  "RESULT FIGURE CHECK",
  paste(
    result_check$file,
    result_check$exists,
    sep = " : "
  ),
  "",
  paste0(
    "Figure 1 frozen files copied: ",
    length(fig1_copied)
  ),
  paste0(
    "Figure 3 frozen files copied: ",
    length(fig3_copied)
  ),
  "",
  "Figure 2 is intentionally not regenerated here because it is a",
  "study-area/network map rather than a V1 analytical result. It should",
  "be retained only after visual/content verification against the same",
  "16-station grouping used in V2."
)

writeLines(
  manifest,
  file.path(
    FINAL_DIR,
    "R1_15_V2_FINAL_FIGURE_MANIFEST.txt"
  )
)

# ------------------------------------------------------------
# 16. Console summary
# ------------------------------------------------------------

cat("\n")
cat("============================================================\n")
cat("R1-15 FINAL MANUSCRIPT FIGURES COMPLETED\n")
cat("============================================================\n")
cat("Output folder:\n")
cat(FINAL_DIR, "\n\n")

print(result_check)

cat("\n")
cat("Review these files first:\n")
cat(
  file.path(
    FINAL_DIR,
    "R1_15_V2_FINAL_FIGURE_MANIFEST.txt"
  ),
  "\n"
)
cat(
  file.path(
    FINAL_DIR,
    "V2_FINAL_FIGURE_CAPTIONS.txt"
  ),
  "\n"
)
cat("\n")
cat("Then visually inspect Figures 4–8 PNG files.\n")
cat("============================================================\n")

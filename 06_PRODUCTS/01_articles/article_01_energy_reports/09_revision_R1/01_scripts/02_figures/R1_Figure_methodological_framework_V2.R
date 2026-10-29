# ============================================================
# ENERGY REPORTS — REVISION R1
# FIGURE: METHODOLOGICAL FRAMEWORK / FLOWCHART
#
# Manuscript: EGYR-D-26-02665
#
# Purpose:
# Create a publication-ready methodological flowchart addressing
# Reviewer 2, Comment 3.
#
# Exports:
#   - PDF
#   - TIFF 600 dpi
#   - PNG 300 dpi
#
# The diagram represents the revised V2 workflow:
# observational data -> station-hour construction -> density ->
# station-level QC -> local WPD -> zonal aggregation ->
# station sensitivity -> statistics -> temporal/spectral ->
# uncertainty -> reproducible outputs.
# ============================================================

rm(list = ls())
gc()

# ------------------------------------------------------------
# 1. Paths
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

DIR_FIGURES <- file.path(R1_ROOT, "03_figures")

dir.create(
  DIR_FIGURES,
  recursive = TRUE,
  showWarnings = FALSE
)

# ------------------------------------------------------------
# 2. Drawing helpers
# ------------------------------------------------------------

draw_box <- function(
    xleft, ybottom, xright, ytop,
    title,
    body = NULL,
    title_cex = 0.92,
    body_cex = 0.72,
    border_lwd = 1.2
) {

  rect(
    xleft, ybottom, xright, ytop,
    border = "black",
    lwd = border_lwd
  )

  text(
    x = (xleft + xright) / 2,
    y = ytop - 0.045 * (ytop - ybottom),
    labels = title,
    font = 2,
    cex = title_cex,
    adj = c(0.5, 1)
  )

  if (!is.null(body)) {
    text(
      x = (xleft + xright) / 2,
      y = (ybottom + ytop) / 2 - 0.02,
      labels = body,
      cex = body_cex,
      adj = c(0.5, 0.5)
    )
  }
}

draw_arrow <- function(
    x0, y0, x1, y1,
    lwd = 1.4
) {
  arrows(
    x0, y0, x1, y1,
    length = 0.08,
    angle = 25,
    lwd = lwd
  )
}

# ------------------------------------------------------------
# 3. Figure
# ------------------------------------------------------------

draw_method_flowchart <- function() {

  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par), add = TRUE)

  par(
    mar = c(0.4, 0.4, 0.4, 0.4),
    family = "sans",
    xpd = NA
  )

  plot(
    0, 0,
    type = "n",
    xlim = c(0, 1),
    ylim = c(0, 1),
    axes = FALSE,
    xlab = "",
    ylab = "",
    asp = NA
  )

  # ----------------------------------------------------------
  # Row 1
  # ----------------------------------------------------------

  draw_box(
    0.02, 0.72, 0.22, 0.96,
    "1. Observational data",
    paste(
      "IDEAM meteorological stations (n = 16)",
      "Study period: 2017–2022",
      "Wind speed, pressure and temperature",
      "Datetime validation",
      sep = "\n"
    )
  )

  draw_box(
    0.27, 0.72, 0.47, 0.96,
    "2. Station-hour construction",
    paste(
      "Sub-hourly observations",
      "aggregated within each station-hour",
      "",
      "v(s,t) = mean of valid observations",
      "within station s and hour t",
      sep = "\n"
    )
  )

  draw_box(
    0.52, 0.72, 0.72, 0.96,
    "3. Air-density estimation",
    paste(
      "Pressure + temperature",
      "Ideal-gas relationship",
      "Daily zone-level density",
      "assigned to valid station-hours",
      sep = "\n"
    )
  )

  draw_box(
    0.77, 0.72, 0.98, 0.96,
    "4. Station-level quality control",
    paste(
      "QC applied before aggregation",
      "",
      "Retain station-hour wind speed",
      "v(s,t) <= 20 m s^-1",
      sep = "\n"
    )
  )

  draw_arrow(0.22, 0.84, 0.27, 0.84)
  draw_arrow(0.47, 0.84, 0.52, 0.84)
  draw_arrow(0.72, 0.84, 0.77, 0.84)

  # ----------------------------------------------------------
  # Row 2
  # ----------------------------------------------------------

  draw_box(
    0.08, 0.42, 0.34, 0.65,
    "5. Local energetic transformation",
    paste(
      "WPD calculated at station-hour scale",
      "",
      "WPD(s,t) = 0.5 * rho(z,d) * v(s,t)^3",
      "",
      "Cubic transformation precedes",
      "zonal aggregation",
      sep = "\n"
    )
  )

  draw_box(
    0.38, 0.42, 0.64, 0.65,
    "6. Zone-hour aggregation",
    paste(
      "Equal weight among stations",
      "available at each zone-hour",
      "",
      "Mean wind speed and mean local WPD",
      "computed separately",
      "",
      "Not an area-weighted spatial mean",
      sep = "\n"
    )
  )

  draw_box(
    0.68, 0.42, 0.94, 0.65,
    "7. Station-composition sensitivity",
    paste(
      "Direct station contribution to WPD",
      "Paired-support leave-one-station-out",
      "Co-observed sensitivity",
      "",
      "Quantifies network dependence",
      sep = "\n"
    )
  )

  draw_arrow(0.875, 0.72, 0.875, 0.68)
  draw_arrow(0.875, 0.68, 0.21, 0.68)
  draw_arrow(0.21, 0.68, 0.21, 0.65)

  draw_arrow(0.34, 0.535, 0.38, 0.535)
  draw_arrow(0.64, 0.535, 0.68, 0.535)

  # Nonlinearity note
  rect(
    0.38, 0.33, 0.64, 0.39,
    border = "black",
    lty = 2,
    lwd = 1
  )

  text(
    0.51, 0.36,
    labels = expression(
      frac(1, n) * sum(v[s]^3) !=
        (frac(1, n) * sum(v[s]))^3
    ),
    cex = 0.86
  )

  # ----------------------------------------------------------
  # Row 3
  # ----------------------------------------------------------

  draw_box(
    0.02, 0.08, 0.27, 0.28,
    "8. Physical–statistical analysis",
    paste(
      "Descriptive statistics",
      "Weibull and Rayleigh fitting",
      "AIC, BIC, KS and CDF errors",
      "Kruskal–Wallis + Dunn–Holm",
      "Effect-size assessment",
      sep = "\n"
    )
  )

  draw_box(
    0.30, 0.08, 0.55, 0.28,
    "9. Temporal and spectral analysis",
    paste(
      "Calendar-preserving daily series",
      "Internal linear interpolation ≤ 7 days",
      "ACF/PACF on continuous segments",
      "Detrend + Hann window + FFT",
      "Spectral-band interpretation",
      sep = "\n"
    )
  )

  draw_box(
    0.58, 0.08, 0.80, 0.28,
    "10. Uncertainty quantification",
    paste(
      "Run-stratified circular",
      "moving-block bootstrap",
      "Mean WPD and Weibull k",
      "Zone-specific block lengths",
      "95% confidence intervals",
      sep = "\n"
    )
  )

  draw_box(
    0.83, 0.08, 0.98, 0.28,
    "11. Outputs",
    paste(
      "Canonical V2 dataset",
      "137,811 zone-hours",
      "Tables and figures",
      "Versioned R scripts",
      "Reproducibility records",
      sep = "\n"
    ),
    body_cex = 0.67
  )

  draw_arrow(0.81, 0.42, 0.81, 0.315)
  draw_arrow(0.81, 0.315, 0.145, 0.315)
  draw_arrow(0.145, 0.315, 0.145, 0.28)

  draw_arrow(0.27, 0.18, 0.30, 0.18)
  draw_arrow(0.55, 0.18, 0.58, 0.18)
  draw_arrow(0.80, 0.18, 0.83, 0.18)

  # Footer
  text(
    0.5, 0.025,
    labels = paste(
      "Interpretation is conditional on the observed station network;",
      "analytical zones are comparative aggregation units, not homogeneous wind-resource regions."
    ),
    cex = 0.67
  )
}

# ------------------------------------------------------------
# 4. Export
# ------------------------------------------------------------

PDF_FILE <- file.path(
  DIR_FIGURES,
  "R1_Figure_methodological_framework_V2.pdf"
)

TIFF_FILE <- file.path(
  DIR_FIGURES,
  "R1_Figure_methodological_framework_V2.tiff"
)

PNG_FILE <- file.path(
  DIR_FIGURES,
  "R1_Figure_methodological_framework_V2.png"
)

pdf(
  PDF_FILE,
  width = 12,
  height = 8,
  useDingbats = FALSE
)
draw_method_flowchart()
dev.off()

tiff(
  TIFF_FILE,
  width = 12,
  height = 8,
  units = "in",
  res = 600,
  compression = "lzw"
)
draw_method_flowchart()
dev.off()

png(
  PNG_FILE,
  width = 12,
  height = 8,
  units = "in",
  res = 300
)
draw_method_flowchart()
dev.off()

# ------------------------------------------------------------
# 5. Caption
# ------------------------------------------------------------

caption <- paste(
  "Figure X. Revised methodological framework for the physical–statistical",
  "characterization of wind power density in Nariño. Wind observations are",
  "first constructed at station-hour scale, quality controlled before the",
  "nonlinear energetic transformation, and converted to local station-hour",
  "WPD using daily zone-level air density. Local energetic states are then",
  "aggregated with equal weight among contributing stations at each zone-hour.",
  "Station-composition sensitivity, inter-zonal statistics, temporal and",
  "spectral diagnostics, and block-bootstrap uncertainty analysis are applied",
  "to delimit the interpretation of the resulting observational-network summaries."
)

writeLines(
  caption,
  file.path(
    DIR_FIGURES,
    "R1_Figure_methodological_framework_V2_caption.txt"
  )
)

cat("\nMethodological flowchart generated successfully.\n")
cat("PDF : ", PDF_FILE, "\n", sep = "")
cat("TIFF: ", TIFF_FILE, "\n", sep = "")
cat("PNG : ", PNG_FILE, "\n", sep = "")

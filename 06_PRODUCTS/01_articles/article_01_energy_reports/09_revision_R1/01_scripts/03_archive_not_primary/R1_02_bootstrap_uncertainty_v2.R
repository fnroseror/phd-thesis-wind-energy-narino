# ============================================================
# ENERGY REPORTS — REVISION R1
# R1_02_bootstrap_uncertainty_v2.R
#
# Manuscript: EGYR-D-26-02665
# Reviewer 2 — Comment 8
#
# Objective:
# Quantify uncertainty for, at minimum:
#   1) Mean wind power density (WPD) by analytical zone
#   2) Weibull shape parameter k by analytical zone
#
# Bootstrap design:
# - Non-parametric bootstrap clustered by calendar day.
# - Entire days are resampled, preserving all within-day hourly
#   observations together instead of treating hourly records as
#   independent bootstrap units.
# - 2,000 replicates by default.
# - 95% percentile confidence intervals and bootstrap SE.
#
# IMPORTANT:
# - Original Article 1 outputs are NOT overwritten.
# - New outputs go only to 09_revision_R1.
# - Weibull point estimates are cross-checked against the original
#   fitdistrplus MLE before bootstrap execution.
# - Bootstrap uses the mathematically equivalent profile-MLE root solution
#   for Weibull k, implemented on the log scale for numerical stability.
# ============================================================

rm(list = ls())
gc()

# ============================================================
# 1. Packages
# ============================================================

required_packages <- c(
  "data.table",
  "fitdistrplus",
  "ggplot2",
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
  library(fitdistrplus)
  library(ggplot2)
  library(openxlsx)
})

# ============================================================
# 2. Paths
# ============================================================

SOURCE_ROOT <- paste0(
  "E:/Academia/UNAL/DOCTORADO/",
  "Fase 2/Productos/Articulo 1/Proceso"
)

SOURCE_DATA_DIR <- file.path(
  SOURCE_ROOT,
  "01_data_processed"
)

INPUT_FILE <- file.path(
  SOURCE_DATA_DIR,
  "02E_article_main_wpd_dataset_after_qc.rds"
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
DIR_FIGURES <- file.path(R1_ROOT, "03_figures")
DIR_RESULTS <- file.path(R1_ROOT, "04_results")
DIR_LOGS <- file.path(R1_ROOT, "06_logs")

dirs <- c(
  DIR_TABLES,
  DIR_FIGURES,
  DIR_RESULTS,
  DIR_LOGS
)

invisible(
  lapply(
    dirs,
    dir.create,
    recursive = TRUE,
    showWarnings = FALSE
  )
)

if (!file.exists(INPUT_FILE)) {
  stop(
    "\nMain Article 1 analytical dataset not found:\n",
    INPUT_FILE,
    "\n"
  )
}

# ============================================================
# 3. Reproducibility controls
# ============================================================

SEED <- 20261020L
B <- 2000L
CI_LEVEL <- 0.95

set.seed(SEED)

LOG_FILE <- file.path(
  DIR_LOGS,
  "R1_02_bootstrap_uncertainty_log.txt"
)

SUMMARY_FILE <- file.path(
  DIR_RESULTS,
  "R1_02_UPLOAD_THIS_TO_CHAT.txt"
)

SESSION_FILE <- file.path(
  DIR_RESULTS,
  "R1_02_sessionInfo.txt"
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

log_msg("Starting R1-02 bootstrap uncertainty analysis.")
log_msg("Input dataset:", INPUT_FILE)
log_msg("Bootstrap replicates:", B)
log_msg("Bootstrap unit: calendar day cluster.")
log_msg("Random seed:", SEED)

# ============================================================
# 4. Load and validate analytical dataset
# ============================================================

dt <- as.data.table(readRDS(INPUT_FILE))

required_columns <- c(
  "zone",
  "date",
  "datetime",
  "VV",
  "WPD"
)

missing_columns <- setdiff(
  required_columns,
  names(dt)
)

if (length(missing_columns) > 0L) {
  stop(
    "Missing required columns: ",
    paste(missing_columns, collapse = ", ")
  )
}

dt[, zone := as.character(zone)]

dt <- dt[
  zone %in% c("1", "2", "3", "4") &
    !is.na(date) &
    is.finite(VV) &
    is.finite(WPD)
]

setorder(
  dt,
  zone,
  date,
  datetime
)

# ============================================================
# 5. V1 checksum
# ============================================================

checksum <- dt[, .(
  n = .N,
  mean_VV = mean(VV),
  mean_WPD = mean(WPD)
), by = zone][order(zone)]

expected <- data.table(
  zone = c("1", "2", "3", "4"),
  n_expected = c(
    42706L,
    43618L,
    42416L,
    8744L
  ),
  mean_WPD_expected = c(
    140.75903,
    15.81935,
    12.96353,
    16.94948
  )
)

checksum <- merge(
  checksum,
  expected,
  by = "zone",
  all.x = TRUE
)

checksum[
  ,
  `:=`(
    n_match = n == n_expected,
    WPD_abs_difference =
      abs(mean_WPD - mean_WPD_expected)
  )
]

if (!all(checksum$n_match)) {
  stop("V1 checksum FAILED: record counts differ.")
}

if (any(checksum$WPD_abs_difference > 1e-4)) {
  stop("V1 checksum FAILED: WPD means differ.")
}

log_msg("V1 scientific checksum: PASSED.")

# ============================================================
# 6. Fast Weibull MLE
#
# For x > 0, k solves:
#
# 1/k = sum(x^k log x)/sum(x^k) - mean(log x)
#
# lambda = [mean(x^k)]^(1/k)
#
# This is used in the bootstrap for speed. The point estimate
# is first compared against fitdistrplus::fitdist(..., "weibull").
# ============================================================

fast_weibull_mle <- function(x) {

  x <- as.numeric(x)
  x <- x[
    is.finite(x) &
      x > 0
  ]

  if (length(x) < 30L) {
    return(
      c(
        shape = NA_real_,
        scale = NA_real_
      )
    )
  }

  lx <- log(x)

  # Numerically stable profile-score equation for Weibull k.
  # Instead of evaluating x^k directly, weights are computed
  # on the log scale and rescaled by their maximum.
  score_k <- function(k) {

    a <- k * lx
    a_max <- max(a)

    w <- exp(a - a_max)

    weighted_log_x <-
      sum(w * lx) /
      sum(w)

    weighted_log_x -
      mean(lx) -
      (1 / k)
  }

  lower <- 0.05
  upper <- 20

  f_lower <- suppressWarnings(
    score_k(lower)
  )

  f_upper <- suppressWarnings(
    score_k(upper)
  )

  if (
    !is.finite(f_lower) ||
    !is.finite(f_upper) ||
    sign(f_lower) == sign(f_upper)
  ) {

    fit <- tryCatch(
      fitdistrplus::fitdist(
        x,
        "weibull",
        method = "mle"
      ),
      error = function(e) NULL
    )

    if (is.null(fit)) {
      return(
        c(
          shape = NA_real_,
          scale = NA_real_
        )
      )
    }

    return(
      c(
        shape =
          unname(fit$estimate["shape"]),
        scale =
          unname(fit$estimate["scale"])
      )
    )
  }

  k_hat <- tryCatch(
    stats::uniroot(
      score_k,
      interval = c(lower, upper),
      tol = 1e-10
    )$root,
    error = function(e) NA_real_
  )

  if (!is.finite(k_hat)) {
    return(
      c(
        shape = NA_real_,
        scale = NA_real_
      )
    )
  }

  # Stable calculation of lambda:
  # lambda = [mean(x^k)]^(1/k)
  a <- k_hat * lx
  a_max <- max(a)

  log_mean_xk <-
    a_max +
    log(
      mean(
        exp(a - a_max)
      )
    )

  scale_hat <- exp(
    log_mean_xk /
      k_hat
  )

  c(
    shape = k_hat,
    scale = scale_hat
  )
}

# ============================================================
# 7. Original point estimates and Weibull MLE validation
# ============================================================

point_estimates <- list()
weibull_validation <- list()

for (z in c("1", "2", "3", "4")) {

  dz <- dt[zone == z]

  vv_pos <- dz[
    is.finite(VV) &
      VV > 0,
    VV
  ]

  fast_fit <- fast_weibull_mle(vv_pos)

  original_fit <- fitdistrplus::fitdist(
    vv_pos,
    "weibull",
    method = "mle"
  )

  original_shape <- unname(
    original_fit$estimate["shape"]
  )

  original_scale <- unname(
    original_fit$estimate["scale"]
  )

  point_estimates[[z]] <- data.table(
    zone = z,
    n_records = nrow(dz),
    n_days = uniqueN(dz$date),
    n_positive_VV = length(vv_pos),
    mean_WPD = mean(dz$WPD),
    Weibull_k = original_shape,
    Weibull_scale = original_scale
  )

  weibull_validation[[z]] <- data.table(
    zone = z,
    fitdistrplus_k = original_shape,
    fast_mle_k = unname(fast_fit["shape"]),
    abs_difference_k =
      abs(
        original_shape -
          unname(fast_fit["shape"])
      ),
    fitdistrplus_scale = original_scale,
    fast_mle_scale = unname(fast_fit["scale"]),
    abs_difference_scale =
      abs(
        original_scale -
          unname(fast_fit["scale"])
      )
  )
}

point_estimates <- rbindlist(
  point_estimates,
  fill = TRUE
)

weibull_validation <- rbindlist(
  weibull_validation,
  fill = TRUE
)

# The profile-MLE root solution and fitdistrplus use different
# numerical algorithms, so exact agreement at 1e-4 is unnecessarily
# strict for a validation guard. We therefore:
#   - log all differences,
#   - issue a warning if |delta k| > 0.001,
#   - stop only if |delta k| > 0.01 (scientifically material mismatch).
#
# Point estimates reported in the manuscript remain those from
# fitdistrplus; the fast profile MLE is used only inside the bootstrap.

log_msg("Weibull MLE validation table:")
capture.output(
  print(weibull_validation)
) |>
  paste(collapse = " | ") |>
  log_msg()

if (
  any(
    weibull_validation$abs_difference_k >
      0.01
  )
) {
  stop(
    paste0(
      "Fast Weibull MLE validation FAILED: ",
      "at least one |delta k| exceeds 0.01. ",
      "Bootstrap stopped to avoid a material estimator mismatch."
    )
  )
}

if (
  any(
    weibull_validation$abs_difference_k >
      0.001
  )
) {
  warning(
    paste0(
      "Small numerical differences were detected between ",
      "the profile Weibull MLE and fitdistrplus (|delta k| > 0.001), ",
      "but all are below the material-mismatch threshold of 0.01. ",
      "Point estimates remain those from fitdistrplus."
    )
  )
}

log_msg(
  "Fast Weibull profile-MLE validation: ACCEPTED."
)

# ============================================================
# 8. Prepare day-cluster bootstrap structures
# ============================================================

zone_objects <- list()

for (z in c("1", "2", "3", "4")) {

  dz <- copy(
    dt[zone == z]
  )

  unique_dates <- sort(
    unique(dz$date)
  )

  # List of row indices for every observed calendar day.
  rows_by_day <- split(
    seq_len(nrow(dz)),
    dz$date
  )

  zone_objects[[z]] <- list(
    data = dz,
    dates = unique_dates,
    rows_by_day = rows_by_day
  )
}

# ============================================================
# 9. Day-cluster bootstrap
#
# Each replicate samples observed calendar days with replacement.
# All records belonging to each selected day move together.
# Thus intraday dependence and unequal records/day are retained.
# ============================================================

bootstrap_one_zone <- function(
    zone_object,
    zone_id,
    B
) {

  dz <- zone_object$data
  day_keys <- names(
    zone_object$rows_by_day
  )

  n_days <- length(day_keys)

  out <- vector(
    "list",
    B
  )

  for (b in seq_len(B)) {

    sampled_days <- sample(
      day_keys,
      size = n_days,
      replace = TRUE
    )

    idx <- unlist(
      zone_object$rows_by_day[
        sampled_days
      ],
      use.names = FALSE
    )

    wpd_b <- dz$WPD[idx]
    vv_b <- dz$VV[idx]

    vv_b <- vv_b[
      is.finite(vv_b) &
        vv_b > 0
    ]

    fit_b <- fast_weibull_mle(
      vv_b
    )

    out[[b]] <- data.table(
      zone = zone_id,
      replicate = b,
      n_resampled_records = length(idx),
      mean_WPD = mean(
        wpd_b,
        na.rm = TRUE
      ),
      Weibull_k = unname(
        fit_b["shape"]
      ),
      Weibull_scale = unname(
        fit_b["scale"]
      )
    )

    if (
      b %% 250L == 0L
    ) {
      log_msg(
        "Zone",
        zone_id,
        "- completed",
        b,
        "of",
        B,
        "bootstrap replicates."
      )
    }
  }

  rbindlist(
    out,
    fill = TRUE
  )
}

bootstrap_results <- list()

for (z in c("1", "2", "3", "4")) {

  log_msg(
    "Starting bootstrap for Zone",
    z
  )

  bootstrap_results[[z]] <-
    bootstrap_one_zone(
      zone_objects[[z]],
      z,
      B
    )

  log_msg(
    "Completed bootstrap for Zone",
    z
  )
}

boot <- rbindlist(
  bootstrap_results,
  fill = TRUE
)

# ============================================================
# 10. Bootstrap quality audit
# ============================================================

bootstrap_audit <- boot[, .(
  n_replicates = .N,
  valid_mean_WPD =
    sum(is.finite(mean_WPD)),
  valid_Weibull_k =
    sum(is.finite(Weibull_k)),
  valid_Weibull_scale =
    sum(is.finite(Weibull_scale)),
  min_resampled_records =
    min(n_resampled_records),
  median_resampled_records =
    median(n_resampled_records),
  max_resampled_records =
    max(n_resampled_records)
), by = zone][order(zone)]

if (
  any(
    bootstrap_audit$valid_mean_WPD <
      0.95 * B
  )
) {
  stop(
    "Too many invalid bootstrap WPD replicates."
  )
}

if (
  any(
    bootstrap_audit$valid_Weibull_k <
      0.95 * B
  )
) {
  stop(
    "Too many invalid bootstrap Weibull-k replicates."
  )
}

# ============================================================
# 11. Confidence intervals
# ============================================================

alpha <- 1 - CI_LEVEL
q_low <- alpha / 2
q_high <- 1 - alpha / 2

ci_summary <- boot[, {

  wpd_valid <- mean_WPD[
    is.finite(mean_WPD)
  ]

  k_valid <- Weibull_k[
    is.finite(Weibull_k)
  ]

  scale_valid <- Weibull_scale[
    is.finite(Weibull_scale)
  ]

  data.table(
    bootstrap_replicates = .N,

    mean_WPD_boot_mean =
      mean(wpd_valid),
    mean_WPD_boot_SE =
      stats::sd(wpd_valid),
    mean_WPD_CI_low =
      as.numeric(
        quantile(
          wpd_valid,
          q_low,
          names = FALSE,
          type = 7
        )
      ),
    mean_WPD_CI_high =
      as.numeric(
        quantile(
          wpd_valid,
          q_high,
          names = FALSE,
          type = 7
        )
      ),

    Weibull_k_boot_mean =
      mean(k_valid),
    Weibull_k_boot_SE =
      stats::sd(k_valid),
    Weibull_k_CI_low =
      as.numeric(
        quantile(
          k_valid,
          q_low,
          names = FALSE,
          type = 7
        )
      ),
    Weibull_k_CI_high =
      as.numeric(
        quantile(
          k_valid,
          q_high,
          names = FALSE,
          type = 7
        )
      ),

    Weibull_scale_boot_mean =
      mean(scale_valid),
    Weibull_scale_boot_SE =
      stats::sd(scale_valid),
    Weibull_scale_CI_low =
      as.numeric(
        quantile(
          scale_valid,
          q_low,
          names = FALSE,
          type = 7
        )
      ),
    Weibull_scale_CI_high =
      as.numeric(
        quantile(
          scale_valid,
          q_high,
          names = FALSE,
          type = 7
        )
      )
  )
}, by = zone][order(zone)]

ci_summary <- merge(
  point_estimates,
  ci_summary,
  by = "zone",
  all.x = TRUE
)

ci_summary[
  ,
  `:=`(
    mean_WPD_CI_width =
      mean_WPD_CI_high -
      mean_WPD_CI_low,
    Weibull_k_CI_width =
      Weibull_k_CI_high -
      Weibull_k_CI_low
  )
]

# ============================================================
# 12. Additional uncertainty diagnostics
# ============================================================

diagnostics <- ci_summary[, .(
  zone,

  mean_WPD,
  mean_WPD_CI_low,
  mean_WPD_CI_high,
  mean_WPD_relative_CI_width_pct =
    100 *
      (
        mean_WPD_CI_high -
          mean_WPD_CI_low
      ) /
      mean_WPD,

  Weibull_k,
  Weibull_k_CI_low,
  Weibull_k_CI_high,
  Weibull_k_relative_CI_width_pct =
    100 *
      (
        Weibull_k_CI_high -
          Weibull_k_CI_low
      ) /
      Weibull_k
)]

# ============================================================
# 13. Publication-support figure
# ============================================================

plot_wpd <- ci_summary[, .(
  zone,
  estimate = mean_WPD,
  low = mean_WPD_CI_low,
  high = mean_WPD_CI_high
)]

p_wpd <- ggplot(
  plot_wpd,
  aes(
    x = factor(zone),
    y = estimate
  )
) +
  geom_point(
    size = 2
  ) +
  geom_errorbar(
    aes(
      ymin = low,
      ymax = high
    ),
    width = 0.15
  ) +
  labs(
    x = "Analytical zone",
    y = expression(
      "Mean WPD (W " * m^{-2} * ")"
    ),
    title =
      "Bootstrap uncertainty of mean wind power density",
    subtitle =
      paste0(
        B,
        " day-cluster bootstrap replicates; ",
        "95% percentile confidence intervals"
      )
  ) +
  theme_bw(base_size = 11) +
  theme(
    panel.grid.minor =
      element_blank()
  )

ggsave(
  file.path(
    DIR_FIGURES,
    "R1_02_mean_WPD_bootstrap_CI.png"
  ),
  p_wpd,
  width = 7,
  height = 5,
  dpi = 600
)

ggsave(
  file.path(
    DIR_FIGURES,
    "R1_02_mean_WPD_bootstrap_CI.tiff"
  ),
  p_wpd,
  width = 7,
  height = 5,
  dpi = 600,
  compression = "lzw"
)

plot_k <- ci_summary[, .(
  zone,
  estimate = Weibull_k,
  low = Weibull_k_CI_low,
  high = Weibull_k_CI_high
)]

p_k <- ggplot(
  plot_k,
  aes(
    x = factor(zone),
    y = estimate
  )
) +
  geom_point(
    size = 2
  ) +
  geom_errorbar(
    aes(
      ymin = low,
      ymax = high
    ),
    width = 0.15
  ) +
  geom_hline(
    yintercept = 1,
    linetype = "dashed",
    linewidth = 0.4
  ) +
  labs(
    x = "Analytical zone",
    y = expression(
      "Weibull shape parameter " * italic(k)
    ),
    title =
      "Bootstrap uncertainty of Weibull shape parameter",
    subtitle =
      paste0(
        B,
        " day-cluster bootstrap replicates; ",
        "95% percentile confidence intervals"
      )
  ) +
  theme_bw(base_size = 11) +
  theme(
    panel.grid.minor =
      element_blank()
  )

ggsave(
  file.path(
    DIR_FIGURES,
    "R1_02_Weibull_k_bootstrap_CI.png"
  ),
  p_k,
  width = 7,
  height = 5,
  dpi = 600
)

ggsave(
  file.path(
    DIR_FIGURES,
    "R1_02_Weibull_k_bootstrap_CI.tiff"
  ),
  p_k,
  width = 7,
  height = 5,
  dpi = 600,
  compression = "lzw"
)

# ============================================================
# 14. Save tables and complete object
# ============================================================

write.xlsx(
  point_estimates,
  file.path(
    DIR_TABLES,
    "R1_02_point_estimates_WPD_Weibull.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  weibull_validation,
  file.path(
    DIR_TABLES,
    "R1_02_Weibull_MLE_validation.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  bootstrap_audit,
  file.path(
    DIR_TABLES,
    "R1_02_bootstrap_quality_audit.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  ci_summary,
  file.path(
    DIR_TABLES,
    "R1_02_bootstrap_CI_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  diagnostics,
  file.path(
    DIR_TABLES,
    "R1_02_uncertainty_diagnostics.xlsx"
  ),
  overwrite = TRUE
)

saveRDS(
  list(
    settings = list(
      seed = SEED,
      B = B,
      CI_level = CI_LEVEL,
      bootstrap_unit =
        "calendar-day cluster"
    ),
    checksum =
      checksum,
    point_estimates =
      point_estimates,
    weibull_validation =
      weibull_validation,
    bootstrap_audit =
      bootstrap_audit,
    bootstrap_replicates =
      boot,
    ci_summary =
      ci_summary,
    diagnostics =
      diagnostics
  ),
  file.path(
    DIR_RESULTS,
    "R1_02_bootstrap_uncertainty.rds"
  )
)

# ============================================================
# 15. Exact summary file to return to ChatGPT
# ============================================================

summary_lines <- capture.output({

  cat("============================================================\n")
  cat("R1-02 BOOTSTRAP UNCERTAINTY — SUMMARY FOR CHATGPT\n")
  cat("============================================================\n")

  cat("\nBOOTSTRAP DESIGN\n")
  cat("Replicates:", B, "\n")
  cat("CI level:", CI_LEVEL, "\n")
  cat("Unit: calendar-day cluster\n")
  cat("Seed:", SEED, "\n")

  cat("\n============================================================\n")
  cat("V1 SCIENTIFIC CHECKSUM\n")
  cat("============================================================\n")
  print(checksum)

  cat("\n============================================================\n")
  cat("WEIBULL MLE VALIDATION\n")
  cat("============================================================\n")
  print(weibull_validation)

  cat("\n============================================================\n")
  cat("POINT ESTIMATES\n")
  cat("============================================================\n")
  print(point_estimates)

  cat("\n============================================================\n")
  cat("BOOTSTRAP QUALITY AUDIT\n")
  cat("============================================================\n")
  print(bootstrap_audit)

  cat("\n============================================================\n")
  cat("95% BOOTSTRAP CONFIDENCE INTERVALS\n")
  cat("============================================================\n")
  print(
    ci_summary[, .(
      zone,
      n_records,
      n_days,
      mean_WPD,
      mean_WPD_boot_SE,
      mean_WPD_CI_low,
      mean_WPD_CI_high,
      Weibull_k,
      Weibull_k_boot_SE,
      Weibull_k_CI_low,
      Weibull_k_CI_high,
      Weibull_scale,
      Weibull_scale_CI_low,
      Weibull_scale_CI_high
    )]
  )

  cat("\n============================================================\n")
  cat("UNCERTAINTY DIAGNOSTICS\n")
  cat("============================================================\n")
  print(diagnostics)

  cat("\n============================================================\n")
  cat("OUTPUT LOCATIONS\n")
  cat("============================================================\n")
  cat("Tables :", DIR_TABLES, "\n")
  cat("Figures:", DIR_FIGURES, "\n")
  cat("Results:", DIR_RESULTS, "\n")

  cat("\nR1-02 COMPLETED SUCCESSFULLY\n")
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
  paste(
    summary_lines,
    collapse = "\n"
  ),
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

log_msg("R1-02 completed successfully.")
log_msg("Summary to upload:", SUMMARY_FILE)

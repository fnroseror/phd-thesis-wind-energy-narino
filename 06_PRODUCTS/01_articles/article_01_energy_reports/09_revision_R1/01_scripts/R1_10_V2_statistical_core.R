# ============================================================
# ENERGY REPORTS — REVISION R1
# R1_10_V2_statistical_core.R
#
# Manuscript: EGYR-D-26-02665
#
# Purpose:
# Recompute the core distributional/statistical reviewer analyses
# using the frozen V2 canonical zone-hour dataset.
#
# Includes:
#   1) V2 checksum and descriptive statistics
#   2) Weibull vs Rayleigh comparison using positive VV values
#      (likelihood/AIC/BIC + ECDF-CDF error + KS distance)
#   3) Calendar-day cluster bootstrap (2000 replicates) for:
#        - mean WPD
#        - Weibull shape k
#   4) Kruskal-Wallis tests for VV and WPD:
#        - zone-hour observations
#        - daily-zone means
#   5) Dunn-Holm pairwise comparisons implemented directly
#
# Interpretation rule:
# Inferential intervals/tests are conditional on the observed
# station network. They do NOT quantify spatial representativeness
# uncertainty, which is documented separately in R1-09.
# ============================================================

rm(list = ls())
gc()

# ============================================================
# 1. Packages
# ============================================================

required_packages <- c(
  "data.table",
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
  library(openxlsx)
})

# ============================================================
# 2. Paths
# ============================================================

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

if (!file.exists(V2_FILE)) {
  stop("Canonical V2 file not found: ", V2_FILE)
}

LOG_FILE <- file.path(
  DIR_LOGS,
  "R1_10_V2_statistical_core_log.txt"
)

SUMMARY_FILE <- file.path(
  DIR_RESULTS,
  "R1_10_UPLOAD_THIS_TO_CHAT.txt"
)

SESSION_FILE <- file.path(
  DIR_RESULTS,
  "R1_10_sessionInfo.txt"
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

log_msg("Starting R1-10 V2 statistical core.")

# ============================================================
# 3. Load and validate V2
# ============================================================

v2 <- as.data.table(readRDS(V2_FILE))
v2[, zone := as.character(zone)]

required_cols <- c(
  "zone",
  "datetime",
  "date",
  "VV",
  "WPD",
  "rho_used",
  "n_stations"
)

miss <- setdiff(required_cols, names(v2))

if (length(miss) > 0L) {
  stop(
    "Missing V2 columns: ",
    paste(miss, collapse = ", ")
  )
}

if (nrow(v2) != 137811L) {
  stop(
    "Unexpected V2 row count: ",
    nrow(v2),
    " (expected 137811)"
  )
}

if (
  any(!is.finite(v2$VV)) ||
  any(!is.finite(v2$WPD)) ||
  any(v2$VV < 0)
) {
  stop("V2 contains invalid VV/WPD values.")
}

# ============================================================
# 4. Descriptive checksum
# ============================================================

descriptive <- v2[, .(
  n = .N,
  n_days = uniqueN(date),
  mean_VV = mean(VV),
  median_VV = median(VV),
  sd_VV = sd(VV),
  p05_VV = quantile(VV, 0.05, names = FALSE),
  p25_VV = quantile(VV, 0.25, names = FALSE),
  p75_VV = quantile(VV, 0.75, names = FALSE),
  p95_VV = quantile(VV, 0.95, names = FALSE),
  p99_VV = quantile(VV, 0.99, names = FALSE),
  max_VV = max(VV),
  mean_WPD = mean(WPD),
  median_WPD = median(WPD),
  sd_WPD = sd(WPD),
  p05_WPD = quantile(WPD, 0.05, names = FALSE),
  p25_WPD = quantile(WPD, 0.25, names = FALSE),
  p75_WPD = quantile(WPD, 0.75, names = FALSE),
  p95_WPD = quantile(WPD, 0.95, names = FALSE),
  p99_WPD = quantile(WPD, 0.99, names = FALSE),
  max_WPD = max(WPD),
  pct_zero_VV = 100 * mean(VV == 0)
), by = zone][order(zone)]

expected_means <- data.table(
  zone = c("1", "2", "3", "4"),
  expected_mean_WPD = c(
    31.959144,
    30.439745,
    26.297862,
    18.682928
  )
)

checksum <- merge(
  descriptive[, .(
    zone,
    n,
    mean_VV,
    mean_WPD
  )],
  expected_means,
  by = "zone",
  all.x = TRUE
)

checksum[, abs_difference :=
           abs(mean_WPD - expected_mean_WPD)]

if (any(checksum$abs_difference > 1e-4)) {
  stop("V2 mean-WPD checksum FAILED.")
}

log_msg("V2 checksum PASSED.")

# ============================================================
# 5. Fast Weibull MLE for positive data
# ============================================================

fit_weibull_fast <- function(x) {

  x <- x[
    is.finite(x) &
      x > 0
  ]

  n <- length(x)

  if (n < 10L) {
    return(
      list(
        shape = NA_real_,
        scale = NA_real_,
        logLik = NA_real_
      )
    )
  }

  lx <- log(x)

  score <- function(k) {

    xk <- x^k

    (1 / k) +
      mean(lx) -
      sum(xk * lx) / sum(xk)
  }

  lower <- 0.05
  upper <- 20

  f_low <- score(lower)
  f_up <- score(upper)

  if (
    !is.finite(f_low) ||
    !is.finite(f_up) ||
    f_low * f_up > 0
  ) {
    lower <- 0.02
    upper <- 50
    f_low <- score(lower)
    f_up <- score(upper)
  }

  if (
    !is.finite(f_low) ||
    !is.finite(f_up) ||
    f_low * f_up > 0
  ) {
    return(
      list(
        shape = NA_real_,
        scale = NA_real_,
        logLik = NA_real_
      )
    )
  }

  k <- uniroot(
    score,
    interval = c(lower, upper),
    tol = 1e-10
  )$root

  lambda <- (
    mean(x^k)
  )^(1 / k)

  ll <- sum(
    dweibull(
      x,
      shape = k,
      scale = lambda,
      log = TRUE
    )
  )

  list(
    shape = k,
    scale = lambda,
    logLik = ll
  )
}

fit_rayleigh <- function(x) {

  x <- x[
    is.finite(x) &
      x > 0
  ]

  n <- length(x)

  if (n < 10L) {
    return(
      list(
        sigma = NA_real_,
        logLik = NA_real_
      )
    )
  }

  sigma <- sqrt(
    mean(x^2) / 2
  )

  ll <- sum(
    log(x) -
      2 * log(sigma) -
      (x^2) / (2 * sigma^2)
  )

  list(
    sigma = sigma,
    logLik = ll
  )
}

rayleigh_cdf <- function(x, sigma) {
  1 - exp(
    -(x^2) / (2 * sigma^2)
  )
}

# ============================================================
# 6. Weibull vs Rayleigh comparison
#
# Avoid density-at-zero metrics. Comparison uses:
#   - logLik / AIC / BIC
#   - empirical-CDF vs fitted-CDF RMSE/MAE
#   - KS distance D
# ============================================================

fit_rows <- list()

for (z in sort(unique(v2$zone))) {

  x_all <- v2[
    zone == z,
    VV
  ]

  n_total <- length(x_all)
  n_zero <- sum(x_all == 0)

  x <- x_all[
    is.finite(x_all) &
      x_all > 0
  ]

  n_pos <- length(x)

  wb <- fit_weibull_fast(x)
  ry <- fit_rayleigh(x)

  xs <- sort(x)
  F_emp <- seq_len(n_pos) / n_pos

  F_wb <- pweibull(
    xs,
    shape = wb$shape,
    scale = wb$scale
  )

  F_ry <- rayleigh_cdf(
    xs,
    sigma = ry$sigma
  )

  wb_ks <- max(abs(F_emp - F_wb))
  ry_ks <- max(abs(F_emp - F_ry))

  wb_rmse <- sqrt(
    mean(
      (F_emp - F_wb)^2
    )
  )

  ry_rmse <- sqrt(
    mean(
      (F_emp - F_ry)^2
    )
  )

  wb_mae <- mean(
    abs(F_emp - F_wb)
  )

  ry_mae <- mean(
    abs(F_emp - F_ry)
  )

  wb_aic <- 2 * 2 - 2 * wb$logLik
  ry_aic <- 2 * 1 - 2 * ry$logLik

  wb_bic <- log(n_pos) * 2 - 2 * wb$logLik
  ry_bic <- log(n_pos) * 1 - 2 * ry$logLik

  fit_rows[[length(fit_rows) + 1L]] <- data.table(
    zone = z,
    model = "Weibull",
    n_total = n_total,
    n_positive = n_pos,
    n_zero = n_zero,
    pct_zero = 100 * n_zero / n_total,
    shape_k = wb$shape,
    scale_or_sigma = wb$scale,
    logLik = wb$logLik,
    AIC = wb_aic,
    BIC = wb_bic,
    CDF_RMSE = wb_rmse,
    CDF_MAE = wb_mae,
    KS_D = wb_ks
  )

  fit_rows[[length(fit_rows) + 1L]] <- data.table(
    zone = z,
    model = "Rayleigh",
    n_total = n_total,
    n_positive = n_pos,
    n_zero = n_zero,
    pct_zero = 100 * n_zero / n_total,
    shape_k = NA_real_,
    scale_or_sigma = ry$sigma,
    logLik = ry$logLik,
    AIC = ry_aic,
    BIC = ry_bic,
    CDF_RMSE = ry_rmse,
    CDF_MAE = ry_mae,
    KS_D = ry_ks
  )
}

fit_comparison <- rbindlist(fit_rows)
setorder(fit_comparison, zone, model)

metric_winner <- function(w, r) {
  ifelse(
    abs(w - r) < .Machine$double.eps^0.5,
    "Tie",
    ifelse(w < r, "Weibull", "Rayleigh")
  )
}

fit_wide <- dcast(
  fit_comparison,
  zone ~ model,
  value.var = c(
    "AIC",
    "BIC",
    "CDF_RMSE",
    "CDF_MAE",
    "KS_D"
  )
)

fit_wide[, `:=`(
  winner_AIC = metric_winner(
    AIC_Weibull,
    AIC_Rayleigh
  ),
  winner_BIC = metric_winner(
    BIC_Weibull,
    BIC_Rayleigh
  ),
  winner_CDF_RMSE = metric_winner(
    CDF_RMSE_Weibull,
    CDF_RMSE_Rayleigh
  ),
  winner_CDF_MAE = metric_winner(
    CDF_MAE_Weibull,
    CDF_MAE_Rayleigh
  ),
  winner_KS = metric_winner(
    KS_D_Weibull,
    KS_D_Rayleigh
  )
)]

# ============================================================
# 7. Calendar-day cluster bootstrap
#
# Resample observed calendar days WITH replacement within zone.
# All zone-hour records of a sampled day are retained together.
#
# This captures intraday clustering but is conditional on the
# observed station network and does not fully correct long-range
# interday serial dependence.
# ============================================================

set.seed(20261020L)

B <- 2000L

bootstrap_rows <- list()
bootstrap_draws <- list()

for (z in sort(unique(v2$zone))) {

  dz <- v2[
    zone == z,
    .(
      date,
      VV,
      WPD
    )
  ]

  days <- sort(unique(dz$date))

  vv_by_day <- split(
    dz$VV,
    dz$date
  )

  wpd_by_day <- split(
    dz$WPD,
    dz$date
  )

  day_names <- names(vv_by_day)

  boot_mean_wpd <- rep(
    NA_real_,
    B
  )

  boot_k <- rep(
    NA_real_,
    B
  )

  for (b in seq_len(B)) {

    sampled_idx <- sample.int(
      length(day_names),
      size = length(day_names),
      replace = TRUE
    )

    vv_b <- unlist(
      vv_by_day[sampled_idx],
      use.names = FALSE
    )

    wpd_b <- unlist(
      wpd_by_day[sampled_idx],
      use.names = FALSE
    )

    boot_mean_wpd[b] <- mean(wpd_b)

    fit_b <- fit_weibull_fast(vv_b)

    boot_k[b] <- fit_b$shape

    if (b %% 250L == 0L) {
      log_msg(
        "Bootstrap zone",
        z,
        ":",
        b,
        "/",
        B
      )
    }
  }

  observed_mean_wpd <- mean(dz$WPD)
  observed_k <- fit_weibull_fast(dz$VV)$shape

  valid_wpd <- boot_mean_wpd[
    is.finite(boot_mean_wpd)
  ]

  valid_k <- boot_k[
    is.finite(boot_k)
  ]

  bootstrap_rows[[length(bootstrap_rows) + 1L]] <- data.table(
    zone = z,
    parameter = "Mean_WPD",
    estimate = observed_mean_wpd,
    bootstrap_replicates = length(valid_wpd),
    bootstrap_SE = sd(valid_wpd),
    CI95_lower = quantile(
      valid_wpd,
      0.025,
      names = FALSE
    ),
    CI95_upper = quantile(
      valid_wpd,
      0.975,
      names = FALSE
    )
  )

  bootstrap_rows[[length(bootstrap_rows) + 1L]] <- data.table(
    zone = z,
    parameter = "Weibull_k",
    estimate = observed_k,
    bootstrap_replicates = length(valid_k),
    bootstrap_SE = sd(valid_k),
    CI95_lower = quantile(
      valid_k,
      0.025,
      names = FALSE
    ),
    CI95_upper = quantile(
      valid_k,
      0.975,
      names = FALSE
    )
  )

  bootstrap_draws[[z]] <- data.table(
    replicate = seq_len(B),
    mean_WPD = boot_mean_wpd,
    Weibull_k = boot_k
  )
}

bootstrap_summary <- rbindlist(
  bootstrap_rows
)

# ============================================================
# 8. Kruskal-Wallis effect size
# ============================================================

kw_with_epsilon <- function(x, g) {

  ok <- is.finite(x) & !is.na(g)

  x <- x[ok]
  g <- factor(g[ok])

  kt <- kruskal.test(
    x ~ g
  )

  H <- as.numeric(kt$statistic)
  k <- nlevels(g)
  N <- length(x)

  epsilon2 <- max(
    0,
    (H - k + 1) /
      (N - k)
  )

  data.table(
    N = N,
    groups = k,
    H = H,
    df = as.numeric(kt$parameter),
    p_value = kt$p.value,
    epsilon_squared = epsilon2
  )
}

# ============================================================
# 9. Dunn-Holm posthoc implemented directly
# ============================================================

dunn_holm <- function(x, g) {

  ok <- is.finite(x) & !is.na(g)

  x <- x[ok]
  g <- factor(g[ok])

  N <- length(x)
  r <- rank(
    x,
    ties.method = "average"
  )

  lev <- levels(g)
  k <- length(lev)

  n_i <- as.numeric(
    table(g)[lev]
  )

  mean_rank <- sapply(
    lev,
    function(L) {
      mean(
        r[g == L]
      )
    }
  )

  ties <- table(x)
  tie_term <- sum(
    ties^3 - ties
  )

  tie_correction <- if (N > 1L) {
    1 -
      tie_term /
      (N^3 - N)
  } else {
    1
  }

  pairs <- combn(
    seq_len(k),
    2L
  )

  out <- vector(
    "list",
    ncol(pairs)
  )

  base_var <- (
    N * (N + 1) / 12
  ) * tie_correction

  for (j in seq_len(ncol(pairs))) {

    i1 <- pairs[1L, j]
    i2 <- pairs[2L, j]

    se <- sqrt(
      base_var *
        (
          1 / n_i[i1] +
          1 / n_i[i2]
        )
    )

    z_stat <- (
      mean_rank[i1] -
        mean_rank[i2]
    ) / se

    p_raw <- 2 * pnorm(
      -abs(z_stat)
    )

    out[[j]] <- data.table(
      group1 = lev[i1],
      group2 = lev[i2],
      n1 = n_i[i1],
      n2 = n_i[i2],
      mean_rank1 = mean_rank[i1],
      mean_rank2 = mean_rank[i2],
      z = z_stat,
      p_raw = p_raw
    )
  }

  ans <- rbindlist(out)

  ans[, p_holm := p.adjust(
    p_raw,
    method = "holm"
  )]

  ans[, significant_0_05 :=
        p_holm < 0.05]

  ans[]
}

# ============================================================
# 10. Zone-hour tests
# ============================================================

kw_hourly_vv <- kw_with_epsilon(
  v2$VV,
  v2$zone
)

kw_hourly_vv[, variable := "VV"]
kw_hourly_vv[, scale := "Zone-hour"]

kw_hourly_wpd <- kw_with_epsilon(
  v2$WPD,
  v2$zone
)

kw_hourly_wpd[, variable := "WPD"]
kw_hourly_wpd[, scale := "Zone-hour"]

dunn_hourly_vv <- dunn_holm(
  v2$VV,
  v2$zone
)

dunn_hourly_vv[, variable := "VV"]
dunn_hourly_vv[, scale := "Zone-hour"]

dunn_hourly_wpd <- dunn_holm(
  v2$WPD,
  v2$zone
)

dunn_hourly_wpd[, variable := "WPD"]
dunn_hourly_wpd[, scale := "Zone-hour"]

# ============================================================
# 11. Daily-zone mean tests
# ============================================================

daily <- v2[, .(
  VV = mean(VV),
  WPD = mean(WPD),
  n_hours = .N
), by = .(
  zone,
  date
)]

kw_daily_vv <- kw_with_epsilon(
  daily$VV,
  daily$zone
)

kw_daily_vv[, variable := "VV"]
kw_daily_vv[, scale := "Daily-zone mean"]

kw_daily_wpd <- kw_with_epsilon(
  daily$WPD,
  daily$zone
)

kw_daily_wpd[, variable := "WPD"]
kw_daily_wpd[, scale := "Daily-zone mean"]

dunn_daily_vv <- dunn_holm(
  daily$VV,
  daily$zone
)

dunn_daily_vv[, variable := "VV"]
dunn_daily_vv[, scale := "Daily-zone mean"]

dunn_daily_wpd <- dunn_holm(
  daily$WPD,
  daily$zone
)

dunn_daily_wpd[, variable := "WPD"]
dunn_daily_wpd[, scale := "Daily-zone mean"]

kw_summary <- rbindlist(
  list(
    kw_hourly_vv,
    kw_hourly_wpd,
    kw_daily_vv,
    kw_daily_wpd
  ),
  fill = TRUE
)

setcolorder(
  kw_summary,
  c(
    "scale",
    "variable",
    "N",
    "groups",
    "H",
    "df",
    "p_value",
    "epsilon_squared"
  )
)

dunn_summary <- rbindlist(
  list(
    dunn_hourly_vv,
    dunn_hourly_wpd,
    dunn_daily_vv,
    dunn_daily_wpd
  ),
  fill = TRUE
)

setcolorder(
  dunn_summary,
  c(
    "scale",
    "variable",
    "group1",
    "group2",
    "n1",
    "n2",
    "mean_rank1",
    "mean_rank2",
    "z",
    "p_raw",
    "p_holm",
    "significant_0_05"
  )
)

# ============================================================
# 12. Save outputs
# ============================================================

write.xlsx(
  checksum,
  file.path(
    DIR_TABLES,
    "R1_10_V2_checksum.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  descriptive,
  file.path(
    DIR_TABLES,
    "R1_10_V2_descriptive_statistics.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  fit_comparison,
  file.path(
    DIR_TABLES,
    "R1_10_V2_Weibull_Rayleigh_metrics.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  fit_wide,
  file.path(
    DIR_TABLES,
    "R1_10_V2_Weibull_Rayleigh_winners.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  bootstrap_summary,
  file.path(
    DIR_TABLES,
    "R1_10_V2_bootstrap_CI.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  kw_summary,
  file.path(
    DIR_TABLES,
    "R1_10_V2_Kruskal_Wallis.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  dunn_summary,
  file.path(
    DIR_TABLES,
    "R1_10_V2_Dunn_Holm_pairwise.xlsx"
  ),
  overwrite = TRUE
)

saveRDS(
  bootstrap_draws,
  file.path(
    DIR_RESULTS,
    "R1_10_V2_bootstrap_draws.rds"
  )
)

saveRDS(
  list(
    checksum = checksum,
    descriptive = descriptive,
    fit_comparison = fit_comparison,
    fit_winners = fit_wide,
    bootstrap_summary = bootstrap_summary,
    KW = kw_summary,
    Dunn_Holm = dunn_summary
  ),
  file.path(
    DIR_RESULTS,
    "R1_10_V2_statistical_core.rds"
  )
)

# ============================================================
# 13. Compact report
# ============================================================

summary_lines <- capture.output({

  cat("============================================================\n")
  cat("R1-10 V2 STATISTICAL CORE — SUMMARY FOR CHATGPT\n")
  cat("============================================================\n")

  cat("\n============================================================\n")
  cat("V2 CHECKSUM\n")
  cat("============================================================\n")
  print(checksum)

  cat("\n============================================================\n")
  cat("V2 DESCRIPTIVE STATISTICS\n")
  cat("============================================================\n")
  print(descriptive)

  cat("\n============================================================\n")
  cat("WEIBULL / RAYLEIGH FIT METRICS\n")
  cat("============================================================\n")
  print(fit_comparison)

  cat("\n============================================================\n")
  cat("WEIBULL / RAYLEIGH METRIC WINNERS\n")
  cat("============================================================\n")
  print(fit_wide)

  cat("\n============================================================\n")
  cat("BOOTSTRAP 95% CI — DAY-CLUSTER, B=2000\n")
  cat("============================================================\n")
  print(bootstrap_summary)

  cat("\n============================================================\n")
  cat("KRUSKAL-WALLIS\n")
  cat("============================================================\n")
  print(kw_summary)

  cat("\n============================================================\n")
  cat("DUNN-HOLM PAIRWISE\n")
  cat("============================================================\n")
  print(dunn_summary)

  cat("\n============================================================\n")
  cat("INTERPRETATION RULE\n")
  cat("============================================================\n")
  cat(
    "All V2 inferential results are conditional on the observed ",
    "station network. They quantify statistical uncertainty and zonal ",
    "differences in the analytical dataset, but do not quantify spatial ",
    "representativeness uncertainty. Station-composition sensitivity ",
    "must be reported using R1-09.\n",
    sep = ""
  )

  cat("\nR1-10 COMPLETED SUCCESSFULLY\n")
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

log_msg("R1-10 completed successfully.")
log_msg("Summary to upload:", SUMMARY_FILE)

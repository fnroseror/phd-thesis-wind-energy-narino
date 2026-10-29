# ============================================================
# ENERGY REPORTS — REVISION R1
# R1_13_run_stratified_circular_block_bootstrap.R
#
# Manuscript: EGYR-D-26-02665
#
# Purpose:
# Correct the temporal-composition bias detected in R1-12.
#
# Method:
#   - Work on the frozen canonical V2 dataset.
#   - Identify ACTUALLY CONSECUTIVE observed-day runs separately
#     for each zone.
#   - Preserve every observed run and its original number of days.
#   - Within each run, resample circular moving blocks.
#   - Blocks never cross a real calendar gap.
#   - For a run shorter than the requested block length L, use
#     L_eff = run length.
#   - Reconstruct all zone-hour observations belonging to the
#     selected days.
#
# Block lengths:
#   7, 30, 90 days
#
# Parameters:
#   - mean WPD
#   - Weibull shape k
#
# Outputs:
#   - percentile and basic 95% CIs
#   - bootstrap bias and bias/SE ratio
#   - comparison with R1-10 day-cluster bootstrap
#   - comparison with R1-12 unrestricted MBB
#
# IMPORTANT:
#   V2 is not modified.
# ============================================================

rm(list = ls())
gc()

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

# ============================================================
# Paths
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

R1_10_FILE <- file.path(
  DIR_RESULTS,
  "R1_10_V2_statistical_core.rds"
)

R1_12_FILE <- file.path(
  DIR_RESULTS,
  "R1_12_V2_moving_block_bootstrap_sensitivity.rds"
)

invisible(lapply(
  c(DIR_TABLES, DIR_RESULTS, DIR_LOGS),
  dir.create,
  recursive = TRUE,
  showWarnings = FALSE
))

required_files <- c(V2_FILE, R1_10_FILE, R1_12_FILE)
missing_files <- required_files[!file.exists(required_files)]

if (length(missing_files) > 0L) {
  stop(
    "Missing required file(s):\n",
    paste(missing_files, collapse = "\n")
  )
}

LOG_FILE <- file.path(
  DIR_LOGS,
  "R1_13_run_stratified_circular_block_bootstrap_log.txt"
)

SUMMARY_FILE <- file.path(
  DIR_RESULTS,
  "R1_13_UPLOAD_THIS_TO_CHAT.txt"
)

SESSION_FILE <- file.path(
  DIR_RESULTS,
  "R1_13_sessionInfo.txt"
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

log_msg("Starting R1-13 run-stratified circular block bootstrap.")

# ============================================================
# Load data and references
# ============================================================

v2 <- as.data.table(readRDS(V2_FILE))
v2[, zone := as.character(zone)]
v2[, date := as.Date(date)]

if (nrow(v2) != 137811L) {
  stop("Unexpected V2 row count: ", nrow(v2))
}

r1_10 <- readRDS(R1_10_FILE)
r1_12 <- readRDS(R1_12_FILE)

day_cluster_reference <- as.data.table(
  r1_10$bootstrap_summary
)
day_cluster_reference[, zone := as.character(zone)]

mbb_unrestricted_reference <- as.data.table(
  r1_12$MBB_summary
)
mbb_unrestricted_reference[, zone := as.character(zone)]

# ============================================================
# Fast Weibull MLE
# ============================================================

fit_weibull_fast <- function(x) {

  x <- x[is.finite(x) & x > 0]

  if (length(x) < 10L) {
    return(list(shape = NA_real_, scale = NA_real_))
  }

  lx <- log(x)

  score <- function(k) {
    xk <- x^k
    (1 / k) + mean(lx) - sum(xk * lx) / sum(xk)
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
    return(list(shape = NA_real_, scale = NA_real_))
  }

  k <- uniroot(
    score,
    interval = c(lower, upper),
    tol = 1e-10
  )$root

  lambda <- (mean(x^k))^(1 / k)

  list(
    shape = k,
    scale = lambda
  )
}

# ============================================================
# Observed contiguous runs
# ============================================================

make_day_runs <- function(dates) {

  dates <- sort(unique(as.Date(dates)))

  if (length(dates) == 0L) {
    return(data.table())
  }

  new_run <- c(
    TRUE,
    diff(as.integer(dates)) != 1L
  )

  run_id <- cumsum(new_run)

  out <- data.table(
    date = dates,
    run_id = run_id
  )

  out[
    ,
    `:=`(
      run_position = seq_len(.N),
      run_length = .N
    ),
    by = run_id
  ]

  out[]
}

# ============================================================
# Circular block sample within one observed run
# ============================================================

sample_one_run <- function(run_dates, block_length) {

  run_dates <- as.Date(run_dates)
  m <- length(run_dates)

  if (m == 0L) {
    return(as.Date(character()))
  }

  L_eff <- min(as.integer(block_length), m)

  if (m == 1L) {
    return(run_dates)
  }

  n_blocks <- ceiling(m / L_eff)

  starts <- sample.int(
    m,
    size = n_blocks,
    replace = TRUE
  )

  sampled_idx <- integer(0)

  for (s in starts) {

    idx <- (
      (s - 1L + 0:(L_eff - 1L)) %% m
    ) + 1L

    sampled_idx <- c(
      sampled_idx,
      idx
    )
  }

  sampled_idx <- sampled_idx[
    seq_len(m)
  ]

  run_dates[sampled_idx]
}

# ============================================================
# Audit effective block support
# ============================================================

block_lengths <- c(7L, 30L, 90L)
support_rows <- list()

for (z in sort(unique(v2$zone))) {

  dates_z <- sort(unique(v2[zone == z, date]))
  runs_z <- make_day_runs(dates_z)

  run_lengths <- unique(
    runs_z[, .(run_id, run_length)]
  )$run_length

  for (L in block_lengths) {

    effective <- pmin(
      run_lengths,
      L
    )

    days_in_runs_ge_L <- sum(
      run_lengths[run_lengths >= L]
    )

    support_rows[[length(support_rows) + 1L]] <- data.table(
      zone = z,
      requested_block_days = L,
      n_observed_days = length(dates_z),
      n_runs = length(run_lengths),
      min_run_days = min(run_lengths),
      median_run_days = as.numeric(median(run_lengths)),
      max_run_days = max(run_lengths),
      min_effective_block_days = min(effective),
      median_effective_block_days = as.numeric(median(effective)),
      max_effective_block_days = max(effective),
      pct_observed_days_in_runs_at_least_requested_L =
        100 * days_in_runs_ge_L / sum(run_lengths)
    )
  }
}

block_support <- rbindlist(support_rows)

# ============================================================
# Run-stratified circular moving-block bootstrap
# ============================================================

B <- 1000L
set.seed(20261021L)

summary_rows <- list()
draws <- list()

for (z in sort(unique(v2$zone))) {

  dz <- v2[
    zone == z,
    .(
      date,
      VV,
      WPD
    )
  ]

  observed_dates <- sort(unique(dz$date))
  run_map <- make_day_runs(observed_dates)

  run_ids <- sort(unique(run_map$run_id))

  clusters <- split(
    dz[, .(VV, WPD)],
    as.character(dz$date)
  )

  theta_wpd <- mean(dz$WPD)
  theta_k <- fit_weibull_fast(dz$VV)$shape

  for (L in block_lengths) {

    log_msg(
      "Zone",
      z,
      "requested block",
      L
    )

    boot_wpd <- rep(NA_real_, B)
    boot_k <- rep(NA_real_, B)

    for (b in seq_len(B)) {

      sampled_dates_all <- as.Date(character())

      for (rid in run_ids) {

        rd <- run_map[
          run_id == rid,
          date
        ]

        sampled_rd <- sample_one_run(
          rd,
          block_length = L
        )

        sampled_dates_all <- c(
          sampled_dates_all,
          sampled_rd
        )
      }

      sampled_names <- as.character(
        sampled_dates_all
      )

      sampled_data <- rbindlist(
        clusters[sampled_names],
        use.names = TRUE,
        fill = TRUE
      )

      boot_wpd[b] <- mean(
        sampled_data$WPD
      )

      boot_k[b] <- fit_weibull_fast(
        sampled_data$VV
      )$shape

      if (b %% 250L == 0L) {
        log_msg(
          "Zone",
          z,
          "L=",
          L,
          "bootstrap",
          b,
          "/",
          B
        )
      }
    }

    draws[[paste(z, L, sep = "_")]] <- data.table(
      zone = z,
      requested_block_days = L,
      replicate = seq_len(B),
      mean_WPD = boot_wpd,
      Weibull_k = boot_k
    )

    for (parameter_name in c("Mean_WPD", "Weibull_k")) {

      if (parameter_name == "Mean_WPD") {
        theta <- theta_wpd
        vals <- boot_wpd
      } else {
        theta <- theta_k
        vals <- boot_k
      }

      vals <- vals[is.finite(vals)]

      q025 <- quantile(
        vals,
        0.025,
        names = FALSE
      )

      q975 <- quantile(
        vals,
        0.975,
        names = FALSE
      )

      boot_mean <- mean(vals)
      boot_bias <- boot_mean - theta
      boot_se <- sd(vals)

      summary_rows[[length(summary_rows) + 1L]] <- data.table(
        zone = z,
        requested_block_days = L,
        parameter = parameter_name,
        estimate = theta,
        bootstrap_replicates = length(vals),
        bootstrap_mean = boot_mean,
        bootstrap_bias = boot_bias,
        bootstrap_SE = boot_se,
        abs_bias_over_SE =
          abs(boot_bias) / boot_se,
        percentile_CI95_lower = q025,
        percentile_CI95_upper = q975,
        basic_CI95_lower =
          2 * theta - q975,
        basic_CI95_upper =
          2 * theta - q025
      )
    }
  }
}

rs_cmbb_summary <- rbindlist(
  summary_rows
)

setorder(
  rs_cmbb_summary,
  zone,
  parameter,
  requested_block_days
)

# ============================================================
# Compare with R1-10 and R1-12
# ============================================================

ref_day <- day_cluster_reference[
  ,
  .(
    zone,
    parameter,
    day_cluster_SE = bootstrap_SE,
    day_cluster_CI95_lower = CI95_lower,
    day_cluster_CI95_upper = CI95_upper
  )
]

ref_mbb <- mbb_unrestricted_reference[
  ,
  .(
    zone,
    requested_block_days = block_length_days,
    parameter,
    unrestricted_MBB_bias = bootstrap_bias,
    unrestricted_MBB_SE = bootstrap_SE,
    unrestricted_MBB_CI95_lower = CI95_lower,
    unrestricted_MBB_CI95_upper = CI95_upper
  )
]

comparison <- merge(
  rs_cmbb_summary,
  ref_day,
  by = c("zone", "parameter"),
  all.x = TRUE
)

comparison <- merge(
  comparison,
  ref_mbb,
  by = c(
    "zone",
    "requested_block_days",
    "parameter"
  ),
  all.x = TRUE
)

comparison[
  ,
  `:=`(
    SE_inflation_vs_day_cluster =
      bootstrap_SE / day_cluster_SE,
    percentile_width =
      percentile_CI95_upper -
      percentile_CI95_lower,
    day_cluster_width =
      day_cluster_CI95_upper -
      day_cluster_CI95_lower,
    width_inflation_vs_day_cluster =
      (
        percentile_CI95_upper -
        percentile_CI95_lower
      ) /
      (
        day_cluster_CI95_upper -
        day_cluster_CI95_lower
      )
  )
]

setorder(
  comparison,
  zone,
  parameter,
  requested_block_days
)

# ============================================================
# Candidate interval recommendation diagnostic
#
# Not an automatic manuscript decision. We flag scenarios with
# relatively small bootstrap location bias.
# ============================================================

comparison[
  ,
  low_location_bias :=
    abs_bias_over_SE <= 0.25
]

# ============================================================
# Save outputs
# ============================================================

write.xlsx(
  block_support,
  file.path(
    DIR_TABLES,
    "R1_13_block_support_by_run.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  rs_cmbb_summary,
  file.path(
    DIR_TABLES,
    "R1_13_run_stratified_circular_MBB_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  comparison,
  file.path(
    DIR_TABLES,
    "R1_13_bootstrap_method_comparison.xlsx"
  ),
  overwrite = TRUE
)

saveRDS(
  draws,
  file.path(
    DIR_RESULTS,
    "R1_13_run_stratified_circular_MBB_draws.rds"
  )
)

saveRDS(
  list(
    block_support = block_support,
    summary = rs_cmbb_summary,
    comparison = comparison
  ),
  file.path(
    DIR_RESULTS,
    "R1_13_run_stratified_circular_block_bootstrap.rds"
  )
)

# ============================================================
# Compact report
# ============================================================

summary_lines <- capture.output({

  cat("============================================================\n")
  cat("R1-13 RUN-STRATIFIED CIRCULAR BLOCK BOOTSTRAP\n")
  cat("SUMMARY FOR CHATGPT\n")
  cat("============================================================\n")

  cat("\n============================================================\n")
  cat("BLOCK SUPPORT BY OBSERVED CONTIGUOUS RUN\n")
  cat("============================================================\n")
  print(block_support)

  cat("\n============================================================\n")
  cat("RUN-STRATIFIED CIRCULAR MBB SUMMARY\n")
  cat("============================================================\n")
  print(rs_cmbb_summary)

  cat("\n============================================================\n")
  cat("COMPARISON WITH R1-10 AND R1-12\n")
  cat("============================================================\n")
  print(
    comparison[
      ,
      .(
        zone,
        parameter,
        requested_block_days,
        estimate,
        bootstrap_mean,
        bootstrap_bias,
        bootstrap_SE,
        abs_bias_over_SE,
        percentile_CI95_lower,
        percentile_CI95_upper,
        basic_CI95_lower,
        basic_CI95_upper,
        day_cluster_SE,
        day_cluster_CI95_lower,
        day_cluster_CI95_upper,
        SE_inflation_vs_day_cluster,
        width_inflation_vs_day_cluster,
        unrestricted_MBB_bias,
        unrestricted_MBB_SE,
        low_location_bias
      )
    ]
  )

  cat("\n============================================================\n")
  cat("INTERPRETATION RULE\n")
  cat("============================================================\n")
  cat(
    "R1-13 preserves the exact observed run composition and prevents ",
    "long contiguous runs from being overrepresented simply because ",
    "they offer more valid block starts. Prefer R1-13 over the unrestricted ",
    "R1-12 MBB for serial-dependence sensitivity if bootstrap location ",
    "bias is substantially reduced. Do not select an interval only because ",
    "it is wider or narrower. All intervals remain conditional on the ",
    "observed station network.\n",
    sep = ""
  )

  cat("\nR1-13 COMPLETED SUCCESSFULLY\n")
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

log_msg("R1-13 completed successfully.")
log_msg("Summary to upload:", SUMMARY_FILE)

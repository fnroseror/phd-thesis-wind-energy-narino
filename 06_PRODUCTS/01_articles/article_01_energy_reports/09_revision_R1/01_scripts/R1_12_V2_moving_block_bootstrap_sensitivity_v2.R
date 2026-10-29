# ============================================================
# ENERGY REPORTS — REVISION R1
# R1_12_V2_moving_block_bootstrap_sensitivity_v2.R
#
# Manuscript: EGYR-D-26-02665
#
# Purpose:
# Sensitivity analysis for the bootstrap confidence intervals
# reported in R1-10, accounting for interday serial dependence.
#
# Primary R1-10 bootstrap:
#   resampled calendar days independently with replacement while
#   retaining all zone-hour observations within each selected day.
#
# R1-12 sensitivity:
#   moving-block bootstrap over ACTUALLY CONSECUTIVE OBSERVED
#   calendar days, without interpolating missing days.
#
# Block lengths:
#   7, 30, and 90 days.
#
# Parameters:
#   - mean WPD of the zone-hour analytical series
#   - Weibull shape parameter k fitted to positive VV
#
# IMPORTANT:
# - This script does NOT alter canonical V2.
# - Blocks never cross a calendar gap.
# - Missing days are not interpolated for bootstrap inference.
# - Results remain conditional on the observed station network.
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

R1_10_FILE <- file.path(
  DIR_RESULTS,
  "R1_10_V2_statistical_core.rds"
)

invisible(lapply(
  c(DIR_TABLES, DIR_RESULTS, DIR_LOGS),
  dir.create,
  recursive = TRUE,
  showWarnings = FALSE
))

required_files <- c(
  V2_FILE,
  R1_10_FILE
)

missing_files <- required_files[!file.exists(required_files)]

if (length(missing_files) > 0L) {
  stop(
    "Missing required file(s):\n",
    paste(missing_files, collapse = "\n")
  )
}

LOG_FILE <- file.path(
  DIR_LOGS,
  "R1_12_V2_moving_block_bootstrap_sensitivity_log.txt"
)

SUMMARY_FILE <- file.path(
  DIR_RESULTS,
  "R1_12_UPLOAD_THIS_TO_CHAT.txt"
)

SESSION_FILE <- file.path(
  DIR_RESULTS,
  "R1_12_sessionInfo.txt"
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

log_msg("Starting R1-12 moving-block bootstrap sensitivity.")

# ============================================================
# 3. Load canonical V2 and R1-10 reference
# ============================================================

v2 <- as.data.table(readRDS(V2_FILE))
v2[, zone := as.character(zone)]

r1_10 <- readRDS(R1_10_FILE)

if (is.null(r1_10$bootstrap_summary)) {
  stop("R1-10 bootstrap_summary not found.")
}

day_cluster_reference <- as.data.table(
  r1_10$bootstrap_summary
)

day_cluster_reference[, zone := as.character(zone)]

required_cols <- c(
  "zone",
  "date",
  "VV",
  "WPD"
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
    nrow(v2)
  )
}

# ============================================================
# 4. Fast Weibull MLE
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

# ============================================================
# 5. Build contiguous observed-day runs
# ============================================================

make_day_runs <- function(dates) {

  dates <- sort(unique(as.Date(dates)))

  if (length(dates) == 0L) {
    return(data.table())
  }

  break_flag <- c(
    TRUE,
    diff(as.integer(dates)) != 1L
  )

  run_id <- cumsum(break_flag)

  data.table(
    date = dates,
    run_id = run_id
  )[
    ,
    `:=`(
      run_position = seq_len(.N),
      run_length = .N
    ),
    by = run_id
  ]
}

enumerate_valid_blocks <- function(
    dates,
    block_length
) {

  runs <- make_day_runs(dates)

  if (nrow(runs) == 0L) {
    return(list())
  }

  valid_run_ids <- unique(
    runs[
      run_length >= block_length,
      run_id
    ]
  )

  if (length(valid_run_ids) == 0L) {
    return(list())
  }

  blocks <- list()
  counter <- 0L

  for (rid in valid_run_ids) {

    rd <- runs[
      run_id == rid,
      date
    ]

    n_start <- length(rd) - block_length + 1L

    for (s in seq_len(n_start)) {

      counter <- counter + 1L

      blocks[[counter]] <- rd[
        s:(s + block_length - 1L)
      ]
    }
  }

  blocks
}

# ============================================================
# 6. Audit available block starts
# ============================================================

block_lengths <- c(
  7L,
  30L,
  90L
)

block_availability_list <- list()

for (z in sort(unique(v2$zone))) {

  days <- sort(
    unique(
      as.Date(
        v2[
          zone == z,
          date
        ]
      )
    )
  )

  runs <- make_day_runs(days)

  max_run <- if (nrow(runs) > 0L) {
    max(runs$run_length)
  } else {
    0L
  }

  n_runs <- if (nrow(runs) > 0L) {
    uniqueN(runs$run_id)
  } else {
    0L
  }

  for (L in block_lengths) {

    blocks <- enumerate_valid_blocks(
      days,
      L
    )

    block_availability_list[[
      length(block_availability_list) + 1L
    ]] <- data.table(
      zone = z,
      block_length_days = L,
      n_observed_days = length(days),
      n_contiguous_runs = n_runs,
      max_contiguous_observed_run_days = max_run,
      n_valid_block_starts = length(blocks),
      block_available = length(blocks) > 0L
    )
  }
}

block_availability <- rbindlist(
  block_availability_list
)

# ============================================================
# 7. Moving-block bootstrap
# ============================================================

B <- 1000L

set.seed(20261020L)

mbb_summary_list <- list()
mbb_draws_list <- list()

for (z in sort(unique(v2$zone))) {

  dz <- v2[
    zone == z,
    .(
      date = as.Date(date),
      VV,
      WPD
    )
  ]

  observed_days <- sort(
    unique(dz$date)
  )

  target_n_days <- length(observed_days)

  # Preserve all zone-hour observations within each selected day.
  clusters <- split(
    dz[
      ,
      .(
        VV,
        WPD
      )
    ],
    as.character(dz$date)
  )

  observed_mean_wpd <- mean(dz$WPD)
  observed_k <- fit_weibull_fast(dz$VV)$shape

  for (L in block_lengths) {

    log_msg(
      "Preparing zone",
      z,
      "block length",
      L
    )

    blocks <- enumerate_valid_blocks(
      observed_days,
      L
    )

    if (length(blocks) == 0L) {

      mbb_summary_list[[
        length(mbb_summary_list) + 1L
      ]] <- data.table(
        zone = z,
        block_length_days = L,
        parameter = c(
          "Mean_WPD",
          "Weibull_k"
        ),
        estimate = c(
          observed_mean_wpd,
          observed_k
        ),
        bootstrap_replicates = 0L,
        bootstrap_mean = NA_real_,
        bootstrap_bias = NA_real_,
        bootstrap_SE = NA_real_,
        CI95_lower = NA_real_,
        CI95_upper = NA_real_,
        available = FALSE
      )

      next
    }

    n_blocks_needed <- ceiling(
      target_n_days / L
    )

    boot_mean_wpd <- rep(
      NA_real_,
      B
    )

    boot_k <- rep(
      NA_real_,
      B
    )

    for (b in seq_len(B)) {

      sampled_block_ids <- sample.int(
        length(blocks),
        size = n_blocks_needed,
        replace = TRUE
      )

      sampled_days <- unlist(
        blocks[sampled_block_ids],
        use.names = FALSE
      )

      sampled_days <- as.Date(
        sampled_days,
        origin = "1970-01-01"
      )

      if (length(sampled_days) > target_n_days) {
        sampled_days <- sampled_days[
          seq_len(target_n_days)
        ]
      }

      sampled_names <- as.character(
        sampled_days
      )

      sampled_data <- rbindlist(
        clusters[sampled_names],
        use.names = TRUE,
        fill = TRUE
      )

      boot_mean_wpd[b] <- mean(
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

    valid_wpd <- boot_mean_wpd[
      is.finite(boot_mean_wpd)
    ]

    valid_k <- boot_k[
      is.finite(boot_k)
    ]

    mbb_summary_list[[
      length(mbb_summary_list) + 1L
    ]] <- data.table(
      zone = z,
      block_length_days = L,
      parameter = "Mean_WPD",
      estimate = observed_mean_wpd,
      bootstrap_replicates = length(valid_wpd),
      bootstrap_mean = mean(valid_wpd),
      bootstrap_bias =
        mean(valid_wpd) - observed_mean_wpd,
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
      ),
      available = TRUE
    )

    mbb_summary_list[[
      length(mbb_summary_list) + 1L
    ]] <- data.table(
      zone = z,
      block_length_days = L,
      parameter = "Weibull_k",
      estimate = observed_k,
      bootstrap_replicates = length(valid_k),
      bootstrap_mean = mean(valid_k),
      bootstrap_bias =
        mean(valid_k) - observed_k,
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
      ),
      available = TRUE
    )

    mbb_draws_list[[
      paste(z, L, sep = "_")
    ]] <- data.table(
      zone = z,
      block_length_days = L,
      replicate = seq_len(B),
      mean_WPD = boot_mean_wpd,
      Weibull_k = boot_k
    )
  }
}

mbb_summary <- rbindlist(
  mbb_summary_list,
  fill = TRUE
)

setorder(
  mbb_summary,
  zone,
  parameter,
  block_length_days
)

# ============================================================
# 8. Compare against independent-day cluster bootstrap
# ============================================================

reference <- day_cluster_reference[
  ,
  .(
    zone,
    parameter,
    reference_estimate = estimate,
    day_cluster_SE = bootstrap_SE,
    day_cluster_CI95_lower = CI95_lower,
    day_cluster_CI95_upper = CI95_upper,
    day_cluster_CI_width =
      CI95_upper - CI95_lower
  )
]

comparison <- merge(
  mbb_summary,
  reference,
  by = c(
    "zone",
    "parameter"
  ),
  all.x = TRUE
)

comparison[, `:=`(
  MBB_CI_width =
    CI95_upper - CI95_lower,
  SE_inflation_vs_day_cluster =
    bootstrap_SE / day_cluster_SE,
  CI_width_inflation_vs_day_cluster =
    (CI95_upper - CI95_lower) /
    day_cluster_CI_width
)]

setorder(
  comparison,
  zone,
  parameter,
  block_length_days
)

# ============================================================
# 9. Compact worst-case sensitivity by zone/parameter
# ============================================================

available_comparison <- comparison[
  available == TRUE &
    is.finite(bootstrap_SE)
]

worst_case <- available_comparison[
  ,
  {
    idx <- which.max(
      CI_width_inflation_vs_day_cluster
    )

    .(
      block_length_days =
        block_length_days[idx],
      estimate =
        estimate[idx],
      day_cluster_SE =
        day_cluster_SE[idx],
      MBB_SE =
        bootstrap_SE[idx],
      SE_inflation_vs_day_cluster =
        SE_inflation_vs_day_cluster[idx],
      day_cluster_CI95_lower =
        day_cluster_CI95_lower[idx],
      day_cluster_CI95_upper =
        day_cluster_CI95_upper[idx],
      MBB_CI95_lower =
        CI95_lower[idx],
      MBB_CI95_upper =
        CI95_upper[idx],
      CI_width_inflation_vs_day_cluster =
        CI_width_inflation_vs_day_cluster[idx]
    )
  },
  by = .(
    zone,
    parameter
  )
]

setorder(
  worst_case,
  zone,
  parameter
)

# ============================================================
# 10. Save outputs
# ============================================================

write.xlsx(
  block_availability,
  file.path(
    DIR_TABLES,
    "R1_12_block_availability.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  mbb_summary,
  file.path(
    DIR_TABLES,
    "R1_12_moving_block_bootstrap_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  comparison,
  file.path(
    DIR_TABLES,
    "R1_12_MBB_vs_day_cluster_comparison.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  worst_case,
  file.path(
    DIR_TABLES,
    "R1_12_worst_case_interval_sensitivity.xlsx"
  ),
  overwrite = TRUE
)

saveRDS(
  mbb_draws_list,
  file.path(
    DIR_RESULTS,
    "R1_12_moving_block_bootstrap_draws.rds"
  )
)

saveRDS(
  list(
    block_availability = block_availability,
    MBB_summary = mbb_summary,
    comparison = comparison,
    worst_case = worst_case
  ),
  file.path(
    DIR_RESULTS,
    "R1_12_V2_moving_block_bootstrap_sensitivity.rds"
  )
)

# ============================================================
# 11. Compact report for ChatGPT
# ============================================================

summary_lines <- capture.output({

  cat("============================================================\n")
  cat("R1-12 V2 MOVING-BLOCK BOOTSTRAP — SUMMARY FOR CHATGPT\n")
  cat("============================================================\n")

  cat("\n============================================================\n")
  cat("BLOCK AVAILABILITY\n")
  cat("============================================================\n")
  print(block_availability)

  cat("\n============================================================\n")
  cat("MOVING-BLOCK BOOTSTRAP SUMMARY\n")
  cat("============================================================\n")
  print(mbb_summary)

  cat("\n============================================================\n")
  cat("COMPARISON WITH R1-10 INDEPENDENT-DAY CLUSTER BOOTSTRAP\n")
  cat("============================================================\n")
  print(
    comparison[
      ,
      .(
        zone,
        parameter,
        block_length_days,
        estimate,
        bootstrap_SE,
        CI95_lower,
        CI95_upper,
        day_cluster_SE,
        day_cluster_CI95_lower,
        day_cluster_CI95_upper,
        SE_inflation_vs_day_cluster,
        CI_width_inflation_vs_day_cluster,
        bootstrap_bias,
        available
      )
    ]
  )

  cat("\n============================================================\n")
  cat("WORST-CASE INTERVAL SENSITIVITY\n")
  cat("============================================================\n")
  print(worst_case)

  cat("\n============================================================\n")
  cat("INTERPRETATION RULE\n")
  cat("============================================================\n")
  cat(
    "R1-10 satisfies the reviewer request for bootstrap confidence ",
    "intervals using calendar-day clusters. R1-12 is a serial-dependence ",
    "sensitivity analysis. If moving-block intervals are materially wider, ",
    "the revised manuscript should either report the block-bootstrap ",
    "intervals as the more conservative uncertainty estimate or report ",
    "both and state that day-cluster intervals understate uncertainty ",
    "when interday persistence is ignored. All intervals remain conditional ",
    "on the observed station network and do not quantify spatial ",
    "representativeness uncertainty.\n",
    sep = ""
  )

  cat("\nR1-12 COMPLETED SUCCESSFULLY\n")
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

log_msg("R1-12 completed successfully.")
log_msg("Summary to upload:", SUMMARY_FILE)

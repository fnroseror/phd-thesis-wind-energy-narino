# ============================================================
# ENERGY REPORTS — REVISION R1
# R1_11_V2_temporal_spectral_core_v3.R
#
# Manuscript: EGYR-D-26-02665
#
# Purpose:
# Recompute the temporal-dependence and FFT/spectral core using
# the frozen V2 canonical zone-hour dataset.
#
# This script explicitly addresses Reviewer 2 by:
#   1) preserving the daily calendar;
#   2) quantifying observed coverage and maximum missing gaps;
#   3) comparing calendar-preserving lag correlations before and
#      after short-gap interpolation (maxgap = 7 days);
#   4) reporting pair counts at each lag;
#   5) computing standard ACF/PACF only on the longest continuous
#      segment after short-gap interpolation;
#   6) repeating the original FFT logic on that longest segment:
#      linear detrend -> center -> Hann window -> one-sided FFT;
#   7) reporting segment dates, length, interpolation fraction,
#      dominant period, and spectral-energy fractions by period band.
#
# IMPORTANT:
# - "calendar-preserving lag correlation" is NOT mislabeled as
#   base R acf(); it is Pearson correlation between y_t and
#   y_{t-lag} using only calendar-aligned finite pairs.
# - V2 itself is not modified.
# - Short-gap interpolation is used only for temporal diagnostics,
#   not to create new zone-hour WPD observations.
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
  "R1_11_V2_temporal_spectral_core_log.txt"
)

SUMMARY_FILE <- file.path(
  DIR_RESULTS,
  "R1_11_UPLOAD_THIS_TO_CHAT.txt"
)

SESSION_FILE <- file.path(
  DIR_RESULTS,
  "R1_11_sessionInfo.txt"
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

log_msg("Starting R1-11 V2 temporal/spectral core.")

# ============================================================
# 3. Load and validate canonical V2
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

checksum <- v2[, .(
  n = .N,
  mean_VV = mean(VV),
  mean_WPD = mean(WPD)
), by = zone][order(zone)]

expected <- data.table(
  zone = c("1", "2", "3", "4"),
  n_expected = c(43033L, 43618L, 42416L, 8744L),
  mean_WPD_expected = c(
    31.959144,
    30.439745,
    26.297862,
    18.682928
  )
)

checksum <- merge(
  checksum,
  expected,
  by = "zone",
  all.x = TRUE
)

checksum[, `:=`(
  n_match = n == n_expected,
  mean_WPD_abs_difference =
    abs(mean_WPD - mean_WPD_expected)
)]

if (
  !all(checksum$n_match) ||
  any(checksum$mean_WPD_abs_difference > 1e-4)
) {
  stop("V2 checksum FAILED.")
}

log_msg("V2 checksum PASSED.")

# ============================================================
# 4. Build daily observed series
# ============================================================

daily <- v2[, .(
  VV = mean(VV),
  WPD = mean(WPD),
  n_zone_hours = .N,
  mean_n_stations = mean(n_stations)
), by = .(
  zone,
  date
)]

calendar_start <- as.Date("2017-01-01")
calendar_end <- as.Date("2022-06-30")

all_dates <- seq(
  calendar_start,
  calendar_end,
  by = "day"
)

full_calendar <- data.table::CJ(
  zone = c("1", "2", "3", "4"),
  date = all_dates,
  unique = TRUE
)

daily_full <- merge(
  full_calendar,
  daily,
  by = c("zone", "date"),
  all.x = TRUE
)

setorder(daily_full, zone, date)

# ============================================================
# 5. Helpers: missing runs and short-gap interpolation
# ============================================================

missing_run_table <- function(
    dates,
    observed
) {

  x <- data.table(
    date = dates,
    missing = !observed
  )

  if (!any(x$missing)) {
    return(
      data.table(
        run_id = integer(),
        start_date = as.Date(character()),
        end_date = as.Date(character()),
        length_days = integer(),
        run_type = character()
      )
    )
  }

  x[, run_id := rleid(missing)]

  runs <- x[
    missing == TRUE,
    .(
      start_date = min(date),
      end_date = max(date),
      length_days = .N
    ),
    by = run_id
  ]

  if (all(x$missing)) {
    runs[, run_type := "all_missing"]
    return(runs[])
  }

  first_obs <- min(
    x$date[!x$missing],
    na.rm = TRUE
  )

  last_obs <- max(
    x$date[!x$missing],
    na.rm = TRUE
  )

  runs[, run_type := fifelse(
    end_date < first_obs,
    "leading",
    fifelse(
      start_date > last_obs,
      "trailing",
      "internal"
    )
  )]

  runs[]
}

interpolate_short_gaps <- function(
    x,
    maxgap = 7L
) {

  out <- as.numeric(x)
  n <- length(out)

  if (n <= 2L) return(out)

  miss <- is.na(out)

  if (!any(miss)) return(out)

  rr <- rle(miss)
  ends <- cumsum(rr$lengths)
  starts <- ends - rr$lengths + 1L

  for (j in seq_along(rr$values)) {

    if (!rr$values[j]) next

    len <- rr$lengths[j]
    st <- starts[j]
    en <- ends[j]

    if (
      len <= maxgap &&
      st > 1L &&
      en < n &&
      is.finite(out[st - 1L]) &&
      is.finite(out[en + 1L])
    ) {
      out[st:en] <- approx(
        x = c(st - 1L, en + 1L),
        y = c(out[st - 1L], out[en + 1L]),
        xout = st:en
      )$y
    }
  }

  out
}

# ============================================================
# 6. Coverage and gap summary
# ============================================================

gap_summary_list <- list()
gap_runs_list <- list()

for (z in c("1", "2", "3", "4")) {

  dz <- daily_full[zone == z]
  observed <- is.finite(dz$WPD)

  runs <- missing_run_table(
    dz$date,
    observed
  )

  if (nrow(runs) > 0L) {
    runs[, zone := z]
    setcolorder(
      runs,
      c(
        "zone",
        "run_id",
        "start_date",
        "end_date",
        "length_days",
        "run_type"
      )
    )
  }

  gap_runs_list[[z]] <- runs

  internal <- runs[run_type == "internal"]
  leading <- runs[run_type == "leading"]
  trailing <- runs[run_type == "trailing"]

  gap_summary_list[[z]] <- data.table(
    zone = z,
    total_calendar_days = nrow(dz),
    observed_days = sum(observed),
    missing_days = sum(!observed),
    pct_observed_days = 100 * mean(observed),
    n_missing_runs = nrow(runs),
    max_missing_gap_days =
      if (nrow(runs) == 0L) 0L else max(runs$length_days),
    median_missing_gap_days =
      if (nrow(runs) == 0L) 0 else as.numeric(median(runs$length_days)),
    n_internal_gaps = nrow(internal),
    max_internal_gap_days =
      if (nrow(internal) == 0L) 0L else max(internal$length_days),
    n_internal_gaps_le_7 =
      sum(internal$length_days <= 7),
    n_internal_gaps_gt_7 =
      sum(internal$length_days > 7),
    leading_gap_days =
      if (nrow(leading) == 0L) 0L else max(leading$length_days),
    trailing_gap_days =
      if (nrow(trailing) == 0L) 0L else max(trailing$length_days)
  )
}

gap_summary <- rbindlist(
  gap_summary_list,
  fill = TRUE
)

gap_runs <- rbindlist(
  gap_runs_list,
  fill = TRUE
)

# ============================================================
# 7. Add interpolated series and interpolation audit
# ============================================================

daily_full[, `:=`(
  VV_interp = interpolate_short_gaps(VV, maxgap = 7L),
  WPD_interp = interpolate_short_gaps(WPD, maxgap = 7L)
), by = zone]

daily_full[, `:=`(
  VV_was_interpolated =
    !is.finite(VV) & is.finite(VV_interp),
  WPD_was_interpolated =
    !is.finite(WPD) & is.finite(WPD_interp)
)]

interp_summary <- daily_full[
  ,
  {
    remaining_runs <- missing_run_table(
      date,
      is.finite(WPD_interp)
    )

    .(
      total_calendar_days = .N,
      original_observed_days =
        sum(is.finite(WPD)),
      newly_interpolated_days =
        sum(WPD_was_interpolated),
      pct_interpolated_total_calendar =
        100 * mean(WPD_was_interpolated),
      remaining_missing_days =
        sum(!is.finite(WPD_interp)),
      pct_remaining_missing =
        100 * mean(!is.finite(WPD_interp)),
      max_remaining_gap_days =
        if (nrow(remaining_runs) == 0L) {
          0L
        } else {
          max(remaining_runs$length_days)
        }
    )
  },
  by = zone
][order(zone)]

# ============================================================
# 8. Calendar-preserving lag correlation
# ============================================================

calendar_lag_cor <- function(
    x,
    max_lag = 90L
) {

  x <- as.numeric(x)
  n <- length(x)

  out <- vector(
    "list",
    max_lag + 1L
  )

  for (lag in 0:max_lag) {

    if (lag == 0L) {

      ok <- is.finite(x)

      corr <- if (sum(ok) >= 3L) {
        1
      } else {
        NA_real_
      }

      out[[lag + 1L]] <- data.table(
        lag = lag,
        n_pairs = sum(ok),
        correlation = corr
      )

    } else {

      x1 <- x[(lag + 1L):n]
      x0 <- x[1L:(n - lag)]

      ok <- is.finite(x1) & is.finite(x0)

      corr <- if (sum(ok) >= 3L) {
        cor(
          x1[ok],
          x0[ok]
        )
      } else {
        NA_real_
      }

      out[[lag + 1L]] <- data.table(
        lag = lag,
        n_pairs = sum(ok),
        correlation = corr
      )
    }
  }

  rbindlist(out)
}

acf_calendar_list <- list()

for (z in c("1", "2", "3", "4")) {

  dz <- daily_full[zone == z]

  for (variable in c("VV", "WPD")) {

    x_obs <- dz[[variable]]

    x_interp <- dz[[paste0(variable, "_interp")]]

    a_obs <- calendar_lag_cor(
      x_obs,
      max_lag = 90L
    )

    a_obs[, `:=`(
      zone = z,
      variable = variable,
      scenario = "Observed_calendar_pairs"
    )]

    a_int <- calendar_lag_cor(
      x_interp,
      max_lag = 90L
    )

    a_int[, `:=`(
      zone = z,
      variable = variable,
      scenario = "Short_gap_interp_max7_calendar_pairs"
    )]

    acf_calendar_list[[length(acf_calendar_list) + 1L]] <- a_obs
    acf_calendar_list[[length(acf_calendar_list) + 1L]] <- a_int
  }
}

acf_calendar <- rbindlist(
  acf_calendar_list
)

setcolorder(
  acf_calendar,
  c(
    "zone",
    "variable",
    "scenario",
    "lag",
    "n_pairs",
    "correlation"
  )
)

# ============================================================
# 9. ACF summary and interpolation sensitivity
# ============================================================

first_below_threshold <- function(
    lag,
    corr,
    threshold = 0.2
) {

  ok <- lag > 0 &
    is.finite(corr) &
    abs(corr) < threshold

  if (!any(ok)) return(NA_integer_)

  min(lag[ok])
}

acf_summary <- acf_calendar[
  ,
  .(
    lag1_correlation =
      correlation[lag == 1L][1L],
    lag1_n_pairs =
      n_pairs[lag == 1L][1L],
    first_abs_corr_below_0_2 =
      first_below_threshold(
        lag,
        correlation,
        threshold = 0.2
      ),
    max_abs_corr_lag1_90 =
      max(
        abs(correlation[lag >= 1L]),
        na.rm = TRUE
      )
  ),
  by = .(
    zone,
    variable,
    scenario
  )
][order(zone, variable, scenario)]

acf_sensitivity <- dcast(
  acf_summary,
  zone + variable ~ scenario,
  value.var = c(
    "lag1_correlation",
    "lag1_n_pairs",
    "first_abs_corr_below_0_2"
  )
)

acf_sensitivity[, delta_lag1_interp_minus_observed :=
  lag1_correlation_Short_gap_interp_max7_calendar_pairs -
  lag1_correlation_Observed_calendar_pairs
]

# ============================================================
# 10. Longest continuous segment helper
# ============================================================

longest_finite_segment <- function(
    dates,
    x,
    was_interpolated = NULL
) {

  finite <- is.finite(x)

  if (!any(finite)) {
    return(
      list(
        start_idx = NA_integer_,
        end_idx = NA_integer_,
        length = 0L,
        start_date = as.Date(NA),
        end_date = as.Date(NA),
        x = numeric(),
        dates = as.Date(character()),
        n_interpolated = 0L,
        pct_interpolated = NA_real_
      )
    )
  }

  run_id <- rleid(finite)

  runs <- data.table(
    idx = seq_along(x),
    finite = finite,
    run_id = run_id
  )[
    finite == TRUE,
    .(
      start_idx = min(idx),
      end_idx = max(idx),
      length = .N
    ),
    by = run_id
  ]

  best <- runs[
    which.max(length)
  ]

  idx <- best$start_idx:best$end_idx

  if (is.null(was_interpolated)) {
    n_interp <- 0L
  } else {
    n_interp <- sum(
      was_interpolated[idx],
      na.rm = TRUE
    )
  }

  list(
    start_idx = best$start_idx,
    end_idx = best$end_idx,
    length = best$length,
    start_date = dates[best$start_idx],
    end_date = dates[best$end_idx],
    x = x[idx],
    dates = dates[idx],
    n_interpolated = n_interp,
    pct_interpolated =
      100 * n_interp / best$length
  )
}

segment_rows <- list()
segments <- list()

for (z in c("1", "2", "3", "4")) {

  dz <- daily_full[zone == z]

  for (variable in c("VV", "WPD")) {

    x <- dz[[paste0(variable, "_interp")]]

    was_int <- dz[[paste0(variable, "_was_interpolated")]]

    seg <- longest_finite_segment(
      dates = dz$date,
      x = x,
      was_interpolated = was_int
    )

    key <- paste(
      z,
      variable,
      sep = "_"
    )

    segments[[key]] <- seg

    segment_rows[[length(segment_rows) + 1L]] <- data.table(
      zone = z,
      variable = variable,
      start_date = seg$start_date,
      end_date = seg$end_date,
      segment_length_days = seg$length,
      n_interpolated_days_in_segment =
        seg$n_interpolated,
      pct_interpolated_days_in_segment =
        seg$pct_interpolated
    )
  }
}

segment_summary <- rbindlist(
  segment_rows
)

setorder(
  segment_summary,
  zone,
  variable
)

# ============================================================
# 11. Standard ACF/PACF on longest continuous segment
# ============================================================

standard_acf_list <- list()
standard_pacf_list <- list()
standard_acf_summary_list <- list()

for (z in c("1", "2", "3", "4")) {

  for (variable in c("VV", "WPD")) {

    key <- paste(
      z,
      variable,
      sep = "_"
    )

    seg <- segments[[key]]

    if (seg$length < 10L) next

    lag_max <- min(
      90L,
      seg$length - 1L
    )

    ac <- acf(
      seg$x,
      lag.max = lag_max,
      plot = FALSE,
      na.action = na.pass
    )

    ac_dt <- data.table(
      zone = z,
      variable = variable,
      segment_start = seg$start_date,
      segment_end = seg$end_date,
      segment_length_days = seg$length,
      lag = as.integer(round(as.numeric(ac$lag))),
      acf = as.numeric(ac$acf)
    )

    standard_acf_list[[length(standard_acf_list) + 1L]] <- ac_dt

    pc <- pacf(
      seg$x,
      lag.max = lag_max,
      plot = FALSE,
      na.action = na.pass
    )

    pc_dt <- data.table(
      zone = z,
      variable = variable,
      segment_start = seg$start_date,
      segment_end = seg$end_date,
      segment_length_days = seg$length,
      lag = seq_along(as.numeric(pc$acf)),
      pacf = as.numeric(pc$acf)
    )

    standard_pacf_list[[length(standard_pacf_list) + 1L]] <- pc_dt

    lag1 <- ac_dt[
      lag == 1L,
      acf
    ][1L]

    first_below <- first_below_threshold(
      ac_dt$lag,
      ac_dt$acf,
      threshold = 0.2
    )

    sig_bound <- 1.96 / sqrt(seg$length)

    standard_acf_summary_list[[
      length(standard_acf_summary_list) + 1L
    ]] <- data.table(
      zone = z,
      variable = variable,
      segment_start = seg$start_date,
      segment_end = seg$end_date,
      segment_length_days = seg$length,
      pct_interpolated_days_in_segment =
        seg$pct_interpolated,
      lag1_acf = lag1,
      first_abs_acf_below_0_2 = first_below,
      approximate_95pct_white_noise_bound =
        sig_bound
    )
  }
}

standard_acf <- rbindlist(
  standard_acf_list,
  fill = TRUE
)

standard_pacf <- rbindlist(
  standard_pacf_list,
  fill = TRUE
)

standard_acf_summary <- rbindlist(
  standard_acf_summary_list,
  fill = TRUE
)

# ============================================================
# 12. FFT helper
# ============================================================

hann_window <- function(n) {
  if (n <= 1L) return(rep(1, n))
  0.5 * (
    1 - cos(
      2 * pi * (0:(n - 1L)) / (n - 1L)
    )
  )
}

fft_one_sided <- function(
    x,
    sampling_interval_days = 1
) {

  x <- as.numeric(x)
  n <- length(x)

  if (n < 128L) {
    return(
      list(
        spectrum = data.table(),
        n = n,
        eligible = FALSE
      )
    )
  }

  t <- seq_len(n)

  # Linear detrend.
  fit <- lm(x ~ t)
  xd <- residuals(fit)

  # Explicit centering after detrending.
  xd <- xd - mean(xd)

  w <- hann_window(n)
  xw <- xd * w

  F <- fft(xw)

  k_max <- floor(n / 2L)

  # Positive frequencies only; exclude DC (k = 0).
  k <- 1:k_max

  freq <- k / (
    n * sampling_interval_days
  )

  power <- (
    Mod(F[k + 1L])^2
  )

  # Double non-Nyquist positive-frequency power to obtain a
  # conventional one-sided representation. Fractions are
  # unaffected by a common scale factor.
  if (n %% 2L == 0L && length(power) >= 1L) {
    if (length(power) > 1L) {
      power[1:(length(power) - 1L)] <-
        2 * power[1:(length(power) - 1L)]
    }
  } else {
    power <- 2 * power
  }

  period_days <- 1 / freq

  sp <- data.table(
    frequency_per_day = freq,
    period_days = period_days,
    power = power
  )

  list(
    spectrum = sp,
    n = n,
    eligible = TRUE
  )
}

period_band <- function(period_days) {
  fifelse(
    period_days >= 2 &
      period_days < 10,
    "2-10 d",
    fifelse(
      period_days >= 10 &
        period_days < 30,
      "10-30 d",
      fifelse(
        period_days >= 30 &
          period_days < 120,
        "30-120 d",
        fifelse(
          period_days >= 120 &
            period_days <= 365,
          "120-365 d",
          fifelse(
            period_days > 365,
            ">365 d",
            "<2 d"
          )
        )
      )
    )
  )
}

band_levels <- c(
  "2-10 d",
  "10-30 d",
  "30-120 d",
  "120-365 d",
  ">365 d"
)

fft_spectrum_list <- list()
fft_summary_list <- list()
fft_band_list <- list()

for (z in c("1", "2", "3", "4")) {

  for (variable in c("VV", "WPD")) {

    key <- paste(
      z,
      variable,
      sep = "_"
    )

    seg <- segments[[key]]

    ff <- fft_one_sided(
      seg$x,
      sampling_interval_days = 1
    )

    if (!ff$eligible) {

      fft_summary_list[[
        length(fft_summary_list) + 1L
      ]] <- data.table(
        zone = z,
        variable = variable,
        eligible_fft = FALSE,
        segment_start = seg$start_date,
        segment_end = seg$end_date,
        segment_length_days = seg$length,
        pct_interpolated_days_in_segment =
          seg$pct_interpolated,
        dominant_period_days = NA_real_,
        dominant_frequency_per_day = NA_real_,
        total_one_sided_power = NA_real_
      )

      next
    }

    sp <- ff$spectrum

    sp[, band := period_band(period_days)]

    total_power <- sum(
      sp$power[
        sp$band %in% band_levels
      ],
      na.rm = TRUE
    )

    dominant_idx <- which.max(
      sp$power
    )

    fft_summary_list[[
      length(fft_summary_list) + 1L
    ]] <- data.table(
      zone = z,
      variable = variable,
      eligible_fft = TRUE,
      segment_start = seg$start_date,
      segment_end = seg$end_date,
      segment_length_days = seg$length,
      pct_interpolated_days_in_segment =
        seg$pct_interpolated,
      dominant_period_days =
        sp$period_days[dominant_idx],
      dominant_frequency_per_day =
        sp$frequency_per_day[dominant_idx],
      total_one_sided_power =
        total_power
    )

    band_dt <- sp[
      band %in% band_levels,
      .(
        band_power = sum(power),
        n_frequency_bins = .N
      ),
      by = band
    ]

    all_band_dt <- data.table(
      band = band_levels
    )

    band_dt <- merge(
      all_band_dt,
      band_dt,
      by = "band",
      all.x = TRUE
    )

    band_dt[
      is.na(band_power),
      `:=`(
        band_power = 0,
        n_frequency_bins = 0L
      )
    ]

    band_dt[, `:=`(
      zone = z,
      variable = variable,
      segment_length_days = seg$length,
      energy_fraction =
        if (total_power > 0) {
          band_power / total_power
        } else {
          NA_real_
        }
    )]

    fft_band_list[[
      length(fft_band_list) + 1L
    ]] <- band_dt

    sp[, `:=`(
      zone = z,
      variable = variable
    )]

    fft_spectrum_list[[
      length(fft_spectrum_list) + 1L
    ]] <- sp
  }
}

fft_summary <- rbindlist(
  fft_summary_list,
  fill = TRUE
)

fft_bands <- rbindlist(
  fft_band_list,
  fill = TRUE
)

fft_spectrum <- rbindlist(
  fft_spectrum_list,
  fill = TRUE
)

if (nrow(fft_bands) > 0L) {
  setcolorder(
    fft_bands,
    c(
      "zone",
      "variable",
      "segment_length_days",
      "band",
      "n_frequency_bins",
      "band_power",
      "energy_fraction"
    )
  )
}

# ============================================================
# 13. Compact WPD-only reviewer table
# ============================================================

reviewer_temporal_table <- merge(
  acf_summary[
    variable == "WPD",
    .(
      zone,
      scenario,
      lag1_correlation,
      lag1_n_pairs,
      first_abs_corr_below_0_2
    )
  ],
  segment_summary[
    variable == "WPD",
    .(
      zone,
      segment_start = start_date,
      segment_end = end_date,
      segment_length_days,
      n_interpolated_days_in_segment,
      pct_interpolated_days_in_segment
    )
  ],
  by = "zone",
  all.x = TRUE
)

reviewer_temporal_table <- merge(
  reviewer_temporal_table,
  gap_summary[
    ,
    .(
      zone,
      pct_observed_days,
      max_missing_gap_days,
      max_internal_gap_days,
      n_internal_gaps_le_7,
      n_internal_gaps_gt_7
    )
  ],
  by = "zone",
  all.x = TRUE
)

setorder(
  reviewer_temporal_table,
  zone,
  scenario
)

# ============================================================
# 14. Save outputs
# ============================================================

write.xlsx(
  checksum,
  file.path(
    DIR_TABLES,
    "R1_11_V2_checksum.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  gap_summary,
  file.path(
    DIR_TABLES,
    "R1_11_V2_daily_gap_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  gap_runs,
  file.path(
    DIR_TABLES,
    "R1_11_V2_all_missing_runs.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  interp_summary,
  file.path(
    DIR_TABLES,
    "R1_11_V2_interpolation_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  acf_calendar,
  file.path(
    DIR_TABLES,
    "R1_11_V2_calendar_lag_correlations.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  acf_summary,
  file.path(
    DIR_TABLES,
    "R1_11_V2_calendar_lag_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  acf_sensitivity,
  file.path(
    DIR_TABLES,
    "R1_11_V2_interpolation_ACF_sensitivity.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  segment_summary,
  file.path(
    DIR_TABLES,
    "R1_11_V2_longest_continuous_segments.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  standard_acf,
  file.path(
    DIR_TABLES,
    "R1_11_V2_standard_ACF_longest_segment.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  standard_pacf,
  file.path(
    DIR_TABLES,
    "R1_11_V2_standard_PACF_longest_segment.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  standard_acf_summary,
  file.path(
    DIR_TABLES,
    "R1_11_V2_standard_ACF_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  fft_summary,
  file.path(
    DIR_TABLES,
    "R1_11_V2_FFT_summary.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  fft_bands,
  file.path(
    DIR_TABLES,
    "R1_11_V2_FFT_band_energy.xlsx"
  ),
  overwrite = TRUE
)

write.xlsx(
  reviewer_temporal_table,
  file.path(
    DIR_TABLES,
    "R1_11_V2_reviewer_temporal_table.xlsx"
  ),
  overwrite = TRUE
)

saveRDS(
  fft_spectrum,
  file.path(
    DIR_RESULTS,
    "R1_11_V2_FFT_spectrum.rds"
  )
)

saveRDS(
  list(
    checksum = checksum,
    gap_summary = gap_summary,
    interpolation_summary = interp_summary,
    calendar_lag_correlations = acf_calendar,
    calendar_lag_summary = acf_summary,
    interpolation_sensitivity = acf_sensitivity,
    segment_summary = segment_summary,
    standard_ACF_summary = standard_acf_summary,
    FFT_summary = fft_summary,
    FFT_bands = fft_bands,
    reviewer_temporal_table = reviewer_temporal_table
  ),
  file.path(
    DIR_RESULTS,
    "R1_11_V2_temporal_spectral_core.rds"
  )
)

# ============================================================
# 15. Compact report for ChatGPT
# ============================================================

summary_lines <- capture.output({

  cat("============================================================\n")
  cat("R1-11 V2 TEMPORAL / SPECTRAL CORE — SUMMARY FOR CHATGPT\n")
  cat("============================================================\n")

  cat("\n============================================================\n")
  cat("V2 CHECKSUM\n")
  cat("============================================================\n")
  print(checksum)

  cat("\n============================================================\n")
  cat("DAILY GAP SUMMARY\n")
  cat("============================================================\n")
  print(gap_summary)

  cat("\n============================================================\n")
  cat("SHORT-GAP INTERPOLATION SUMMARY\n")
  cat("============================================================\n")
  print(interp_summary)

  cat("\n============================================================\n")
  cat("CALENDAR-PRESERVING LAG CORRELATION SUMMARY\n")
  cat("============================================================\n")
  print(acf_summary)

  cat("\n============================================================\n")
  cat("INTERPOLATION SENSITIVITY — LAG 1\n")
  cat("============================================================\n")
  print(
    acf_sensitivity[
      ,
      .(
        zone,
        variable,
        lag1_correlation_Observed_calendar_pairs,
        lag1_correlation_Short_gap_interp_max7_calendar_pairs,
        delta_lag1_interp_minus_observed,
        first_abs_corr_below_0_2_Observed_calendar_pairs,
        first_abs_corr_below_0_2_Short_gap_interp_max7_calendar_pairs
      )
    ]
  )

  cat("\n============================================================\n")
  cat("LONGEST CONTINUOUS SEGMENTS AFTER MAXGAP7\n")
  cat("============================================================\n")
  print(segment_summary)

  cat("\n============================================================\n")
  cat("STANDARD ACF ON LONGEST CONTINUOUS SEGMENT\n")
  cat("============================================================\n")
  print(standard_acf_summary)

  cat("\n============================================================\n")
  cat("FFT SUMMARY\n")
  cat("============================================================\n")
  print(fft_summary)

  cat("\n============================================================\n")
  cat("FFT BAND ENERGY FRACTIONS\n")
  cat("============================================================\n")
  print(fft_bands)

  cat("\n============================================================\n")
  cat("WPD REVIEWER TEMPORAL TABLE\n")
  cat("============================================================\n")
  print(reviewer_temporal_table)

  cat("\n============================================================\n")
  cat("INTERPRETATION RULE\n")
  cat("============================================================\n")
  cat(
    "Use calendar-preserving lag correlations to discuss the effect ",
    "of interpolation because they preserve actual calendar spacing. ",
    "Use standard ACF/PACF and FFT only on explicitly reported longest ",
    "continuous segments after interpolation of internal gaps <=7 days. ",
    "Zone 4 must be strongly qualified if its long missing intervals ",
    "remain large relative to the analyzed calendar.\n",
    sep = ""
  )

  cat("\nR1-11 COMPLETED SUCCESSFULLY\n")
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

log_msg("R1-11 completed successfully.")
log_msg("Summary to upload:", SUMMARY_FILE)

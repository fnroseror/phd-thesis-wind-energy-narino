# 03_metrics_helpers.R
# Shared performance metrics

rmse_fun <- function(obs, pred) {
  sqrt(mean((obs - pred)^2, na.rm = TRUE))
}

mae_fun <- function(obs, pred) {
  mean(abs(obs - pred), na.rm = TRUE)
}

r2_fun <- function(obs, pred) {
  keep <- is.finite(obs) & is.finite(pred)
  obs <- obs[keep]
  pred <- pred[keep]

  if (length(obs) < 2) return(NA_real_)

  ss_res <- sum((obs - pred)^2)
  ss_tot <- sum((obs - mean(obs))^2)

  if (ss_tot == 0) return(NA_real_)
  1 - ss_res / ss_tot
}

mape_fun <- function(obs, pred) {
  keep <- is.finite(obs) & is.finite(pred) & obs != 0
  if (!any(keep)) return(NA_real_)
  mean(abs((obs[keep] - pred[keep]) / obs[keep])) * 100
}

skill_score_fun <- function(model_error, baseline_error) {
  if (!is.finite(model_error) || !is.finite(baseline_error) || baseline_error == 0) {
    return(NA_real_)
  }
  1 - (model_error / baseline_error)
}

pi_coverage_fun <- function(obs, lower, upper) {
  keep <- is.finite(obs) & is.finite(lower) & is.finite(upper)
  if (!any(keep)) return(NA_real_)
  mean(obs[keep] >= lower[keep] & obs[keep] <= upper[keep])
}

pi_width_fun <- function(lower, upper) {
  keep <- is.finite(lower) & is.finite(upper)
  if (!any(keep)) return(NA_real_)
  mean(upper[keep] - lower[keep])
}

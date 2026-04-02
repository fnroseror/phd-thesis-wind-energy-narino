rmse_fun <- function(obs, pred) {
  sqrt(mean((obs - pred)^2, na.rm = TRUE))
}

mae_fun <- function(obs, pred) {
  mean(abs(obs - pred), na.rm = TRUE)
}

r2_fun <- function(obs, pred) {
  ss_res <- sum((obs - pred)^2, na.rm = TRUE)
  ss_tot <- sum((obs - mean(obs, na.rm = TRUE))^2, na.rm = TRUE)
  1 - ss_res / ss_tot
}

skill_score_fun <- function(model_error, baseline_error) {
  1 - (model_error / baseline_error)
}

pi_coverage_fun <- function(obs, lower, upper) {
  mean(obs >= lower & obs <= upper, na.rm = TRUE)
}

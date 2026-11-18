# ============================================================
# ARTICLE 2 — CROSS-ARTICLE WPD TARGET AUDIT
# STEP 02 / P0-B: density-definition sensitivity
# ============================================================

library(data.table)

ROOT <- "C:/Users/UMARIANA/Documents/GitHub/phd-thesis-wind-energy-narino"

A2_FILE <- file.path(
  ROOT,
  "local_work/02_article02_dataset/article02_analytical_dataset_v1_0.rds"
)

A1_FILE <- file.path(
  ROOT,
  "06_PRODUCTS/01_articles/article_01_energy_reports",
  "09_revision_R1/04_results",
  "R1_V2_CANONICAL_zone_hour_dataset.rds"
)

OUT_DIR <- file.path(
  ROOT,
  "local_work/12_manuscript/audit"
)

dir.create(
  OUT_DIR,
  recursive = TRUE,
  showWarnings = FALSE
)

stopifnot(file.exists(A2_FILE))
stopifnot(file.exists(A1_FILE))

cat("\n============================================================\n")
cat("ARTICLE 2 — DENSITY-DEFINITION SENSITIVITY AUDIT\n")
cat("============================================================\n\n")

# ------------------------------------------------------------
# 1. Load datasets
# ------------------------------------------------------------

D <- as.data.table(readRDS(A2_FILE))
A1 <- as.data.table(readRDS(A1_FILE))

D[, Estacion := as.character(Estacion)]

cat("ARTICLE 2 DATASET\n")
cat("Rows:", nrow(D), "\n")
cat("Stations:", uniqueN(D$Estacion), "\n")
cat("Zones:", uniqueN(D$Zona), "\n\n")

cat("ARTICLE 1 R1 CANONICAL DATASET\n")
cat("Rows:", nrow(A1), "\n")
cat("Columns:\n")
print(names(A1))

# ------------------------------------------------------------
# 2. Validate expected Article-1 structure
# ------------------------------------------------------------

required_A1 <- c("zone", "datetime", "rho_used")

if (!all(required_A1 %in% names(A1))) {
  stop(
    "Missing expected Article-1 columns: ",
    paste(setdiff(required_A1, names(A1)), collapse = ", ")
  )
}

A1[, zone := as.integer(zone)]

# ------------------------------------------------------------
# 3. Create common local-hour key
# ------------------------------------------------------------

A1[, local_hour := format(
  datetime,
  tz = "America/Bogota",
  format = "%Y-%m-%d %H:00:00"
)]

D[, local_hour := format(
  Hora,
  tz = "America/Bogota",
  format = "%Y-%m-%d %H:00:00"
)]

RHO_A1 <- unique(
  A1[, .(
    Zona = zone,
    local_hour,
    rho_A1 = rho_used
  )]
)

DUP <- RHO_A1[, .N, by = .(Zona, local_hour)][N > 1]

cat("\nDuplicate Article-1 rho keys:", nrow(DUP), "\n")

if (nrow(DUP) > 0) {
  print(DUP)
  stop("Article-1 rho key is not unique.")
}

# ------------------------------------------------------------
# 4. Join Article-1 density to Article-2 observations
# ------------------------------------------------------------

J <- merge(
  D,
  RHO_A1,
  by = c("Zona", "local_hour"),
  all.x = TRUE
)

cat("\n============================================================\n")
cat("OVERLAP AUDIT\n")
cat("============================================================\n\n")

N_TOTAL <- nrow(J)
N_MATCH <- J[is.finite(rho_A1), .N]
N_MISS  <- J[!is.finite(rho_A1), .N]

cat("Article-2 rows:", N_TOTAL, "\n")
cat("Rows with Article-1 rho:", N_MATCH, "\n")
cat("Rows without Article-1 rho:", N_MISS, "\n")
cat("Overlap (%):", round(100 * N_MATCH / N_TOTAL, 4), "\n")

# ------------------------------------------------------------
# 5. Recompute WPD using Article-1 rho
# ------------------------------------------------------------

K <- J[
  is.finite(rho_A1) &
  is.finite(rho) &
  is.finite(VV) &
  is.finite(WPD)
]

K[, WPD_using_A1_rho := 0.5 * rho_A1 * VV^3]

K[, rho_diff := rho - rho_A1]
K[, rho_abs_diff := abs(rho_diff)]

K[, rho_rel_diff_pct :=
  fifelse(
    abs(rho_A1) > 1e-12,
    100 * rho_diff / rho_A1,
    NA_real_
  )
]

K[, WPD_diff := WPD - WPD_using_A1_rho]
K[, WPD_abs_diff := abs(WPD_diff)]

K[, WPD_rel_diff_pct :=
  fifelse(
    abs(WPD_using_A1_rho) > 1e-12,
    100 * WPD_diff / WPD_using_A1_rho,
    NA_real_
  )
]

# ------------------------------------------------------------
# 6. Global summary
# ------------------------------------------------------------

GLOBAL <- K[, .(
  N = .N,

  rho_A2_mean = mean(rho),
  rho_A1_mean = mean(rho_A1),

  rho_abs_diff_median = median(rho_abs_diff),
  rho_abs_diff_p95 = quantile(
    rho_abs_diff,
    0.95,
    names = FALSE
  ),

  rho_rel_diff_median_pct = median(
    rho_rel_diff_pct,
    na.rm = TRUE
  ),

  rho_rel_diff_p05_pct = quantile(
    rho_rel_diff_pct,
    0.05,
    na.rm = TRUE,
    names = FALSE
  ),

  rho_rel_diff_p95_pct = quantile(
    rho_rel_diff_pct,
    0.95,
    na.rm = TRUE,
    names = FALSE
  ),

  WPD_A2_mean = mean(WPD),
  WPD_A1rho_mean = mean(WPD_using_A1_rho),

  WPD_abs_diff_median = median(WPD_abs_diff),
  WPD_abs_diff_p95 = quantile(
    WPD_abs_diff,
    0.95,
    names = FALSE
  ),

  WPD_rel_diff_median_pct = median(
    WPD_rel_diff_pct,
    na.rm = TRUE
  ),

  WPD_rel_diff_p05_pct = quantile(
    WPD_rel_diff_pct,
    0.05,
    na.rm = TRUE,
    names = FALSE
  ),

  WPD_rel_diff_p95_pct = quantile(
    WPD_rel_diff_pct,
    0.95,
    na.rm = TRUE,
    names = FALSE
  ),

  correlation_WPD = cor(
    WPD,
    WPD_using_A1_rho,
    use = "complete.obs"
  ),

  spearman_WPD = cor(
    WPD,
    WPD_using_A1_rho,
    method = "spearman",
    use = "complete.obs"
  )
)]

cat("\n============================================================\n")
cat("GLOBAL DENSITY / WPD SENSITIVITY\n")
cat("============================================================\n\n")

print(GLOBAL)

# ------------------------------------------------------------
# 7. By zone
# ------------------------------------------------------------

BY_ZONE <- K[, .(
  N = .N,

  rho_A2_mean = mean(rho),
  rho_A1_mean = mean(rho_A1),

  rho_rel_diff_median_pct = median(
    rho_rel_diff_pct,
    na.rm = TRUE
  ),

  rho_rel_diff_p95_abs_pct = quantile(
    abs(rho_rel_diff_pct),
    0.95,
    na.rm = TRUE,
    names = FALSE
  ),

  WPD_A2_mean = mean(WPD),
  WPD_A1rho_mean = mean(WPD_using_A1_rho),

  WPD_rel_diff_median_pct = median(
    WPD_rel_diff_pct,
    na.rm = TRUE
  ),

  WPD_rel_diff_p95_abs_pct = quantile(
    abs(WPD_rel_diff_pct),
    0.95,
    na.rm = TRUE,
    names = FALSE
  ),

  correlation_WPD = cor(
    WPD,
    WPD_using_A1_rho,
    use = "complete.obs"
  )
), by = Zona][order(Zona)]

cat("\n============================================================\n")
cat("SENSITIVITY BY ZONE\n")
cat("============================================================\n\n")

print(BY_ZONE)

# ------------------------------------------------------------
# 8. By Article-2 rho provenance
# ------------------------------------------------------------

if ("rho_source" %in% names(K)) {

  BY_SOURCE <- K[, .(
    N = .N,

    median_abs_rho_diff = median(rho_abs_diff),

    p95_abs_rho_diff = quantile(
      rho_abs_diff,
      0.95,
      names = FALSE
    ),

    median_abs_WPD_rel_diff_pct = median(
      abs(WPD_rel_diff_pct),
      na.rm = TRUE
    ),

    p95_abs_WPD_rel_diff_pct = quantile(
      abs(WPD_rel_diff_pct),
      0.95,
      na.rm = TRUE,
      names = FALSE
    )
  ), by = rho_source][order(-N)]

  cat("\n============================================================\n")
  cat("SENSITIVITY BY ARTICLE-2 RHO SOURCE\n")
  cat("============================================================\n\n")

  print(BY_SOURCE)

} else {

  BY_SOURCE <- NULL
}

# ------------------------------------------------------------
# 9. Exact numerical equality
# ------------------------------------------------------------

EQ <- data.table(
  Check = c(
    "rho identical within 1e-12",
    "WPD identical within 1e-10"
  ),

  N_equal = c(
    K[abs(rho - rho_A1) <= 1e-12, .N],
    K[abs(WPD - WPD_using_A1_rho) <= 1e-10, .N]
  ),

  N_total = nrow(K)
)

EQ[, pct_equal := 100 * N_equal / N_total]

cat("\n============================================================\n")
cat("EXACT-EQUALITY DIAGNOSTICS\n")
cat("============================================================\n\n")

print(EQ)

# ------------------------------------------------------------
# 10. Rank preservation
# ------------------------------------------------------------

RANK_AUDIT <- K[, .(
  N = .N,

  spearman = cor(
    WPD,
    WPD_using_A1_rho,
    method = "spearman",
    use = "complete.obs"
  ),

  pearson = cor(
    WPD,
    WPD_using_A1_rho,
    use = "complete.obs"
  )
), by = Zona][order(Zona)]

cat("\n============================================================\n")
cat("RANK / STRUCTURE PRESERVATION\n")
cat("============================================================\n\n")

print(RANK_AUDIT)

# ------------------------------------------------------------
# 11. Save permanent local audit evidence
# ------------------------------------------------------------

fwrite(
  GLOBAL,
  file.path(
    OUT_DIR,
    "cross_article_density_sensitivity_global_v1_0.csv"
  )
)

fwrite(
  BY_ZONE,
  file.path(
    OUT_DIR,
    "cross_article_density_sensitivity_by_zone_v1_0.csv"
  )
)

fwrite(
  EQ,
  file.path(
    OUT_DIR,
    "cross_article_density_exact_equality_v1_0.csv"
  )
)

fwrite(
  RANK_AUDIT,
  file.path(
    OUT_DIR,
    "cross_article_density_rank_preservation_v1_0.csv"
  )
)

if (!is.null(BY_SOURCE)) {

  fwrite(
    BY_SOURCE,
    file.path(
      OUT_DIR,
      "cross_article_density_sensitivity_by_source_v1_0.csv"
    )
  )
}

# ------------------------------------------------------------
# 12. Final audit message
# ------------------------------------------------------------

cat("\n============================================================\n")
cat("P0-B COMPLETE\n")
cat("============================================================\n")

cat("\nEvidence saved in:\n")
cat(normalizePath(OUT_DIR, winslash = "/"), "\n")

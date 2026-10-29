# ============================================================
# ENERGY REPORTS — REVISION R1
# FIGURE: GLOBAL / SOUTH AMERICA / COLOMBIA WIND CAPACITY
# Revised layout v2 — annotation overlap corrected
#
# Source:
# IRENA (2026). Renewable Capacity Statistics 2026.
# Wind energy capacity tables, 2016–2025.
# ============================================================

rm(list = ls())
gc()

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
DIR_TABLES <- file.path(R1_ROOT, "02_tables")

dir.create(DIR_FIGURES, recursive = TRUE, showWarnings = FALSE)
dir.create(DIR_TABLES, recursive = TRUE, showWarnings = FALSE)

years <- 2016:2025

world_mw <- c(
  467316, 514972, 563516, 623076, 733274,
  824193, 903089, 1018224, 1132690, 1291368
)

south_america_mw <- c(
  13121, 15853, 18963, 21074, 24179,
  29581, 33622, 40178, 44795, 48396
)

colombia_mw <- c(
  18, 18, 18, 18, 18,
  18, 34, 34, 34, 34
)

capacity_data <- data.frame(
  year = years,
  world_MW = world_mw,
  south_america_MW = south_america_mw,
  colombia_MW = colombia_mw
)

write.csv(
  capacity_data,
  file.path(
    DIR_TABLES,
    "R1_IRENA_2026_wind_capacity_2016_2025.csv"
  ),
  row.names = FALSE
)

stopifnot(
  capacity_data$world_MW[10] == 1291368,
  capacity_data$south_america_MW[10] == 48396,
  capacity_data$colombia_MW[10] == 34
)

draw_figure <- function() {

  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par), add = TRUE)

  par(
    mfrow = c(1, 3),
    mar = c(4.4, 4.6, 2.8, 1.3),
    oma = c(0.3, 0.3, 0.3, 0.3),
    mgp = c(2.7, 0.8, 0),
    tcl = -0.25,
    las = 1,
    family = "sans"
  )

  x_limits <- c(2015.7, 2025.65)
  x_ticks <- c(2016, 2018, 2020, 2022, 2024, 2025)

  # Panel A — World
  world_gw <- capacity_data$world_MW / 1000

  plot(
    capacity_data$year,
    world_gw,
    type = "o",
    pch = 16,
    lwd = 1.8,
    cex = 0.72,
    xlab = "Year",
    ylab = "Installed wind capacity (GW)",
    main = "(a) World",
    xaxt = "n",
    xlim = x_limits,
    ylim = c(0, 1450)
  )

  axis(
    1,
    at = x_ticks,
    labels = x_ticks,
    las = 2,
    cex.axis = 0.8
  )

  grid(nx = NA, ny = NULL, lty = 3)

  text(
    x = 2024.78,
    y = world_gw[10] + 55,
    labels = sprintf("%.1f GW", world_gw[10]),
    adj = c(1, 0),
    cex = 0.78
  )

  # Panel B — South America
  south_america_gw <- capacity_data$south_america_MW / 1000

  plot(
    capacity_data$year,
    south_america_gw,
    type = "o",
    pch = 16,
    lwd = 1.8,
    cex = 0.72,
    xlab = "Year",
    ylab = "Installed wind capacity (GW)",
    main = "(b) South America",
    xaxt = "n",
    xlim = x_limits,
    ylim = c(0, 55.5)
  )

  axis(
    1,
    at = x_ticks,
    labels = x_ticks,
    las = 2,
    cex.axis = 0.8
  )

  grid(nx = NA, ny = NULL, lty = 3)

  text(
    x = 2024.78,
    y = south_america_gw[10] + 2.1,
    labels = sprintf("%.1f GW", south_america_gw[10]),
    adj = c(1, 0),
    cex = 0.78
  )

  # Panel C — Colombia
  plot(
    capacity_data$year,
    capacity_data$colombia_MW,
    type = "o",
    pch = 16,
    lwd = 1.8,
    cex = 0.72,
    xlab = "Year",
    ylab = "Installed wind capacity (MW)",
    main = "(c) Colombia",
    xaxt = "n",
    xlim = x_limits,
    ylim = c(0, 42)
  )

  axis(
    1,
    at = x_ticks,
    labels = x_ticks,
    las = 2,
    cex.axis = 0.8
  )

  grid(nx = NA, ny = NULL, lty = 3)

  text(
    x = 2024.78,
    y = 36.1,
    labels = "34 MW",
    adj = c(1, 0),
    cex = 0.78
  )
}

pdf(
  file.path(
    DIR_FIGURES,
    "R1_Figure_wind_capacity_global_SouthAmerica_Colombia_2016_2025_v2.pdf"
  ),
  width = 10.5,
  height = 3.8,
  useDingbats = FALSE
)
draw_figure()
dev.off()

tiff(
  file.path(
    DIR_FIGURES,
    "R1_Figure_wind_capacity_global_SouthAmerica_Colombia_2016_2025_v2.tiff"
  ),
  width = 10.5,
  height = 3.8,
  units = "in",
  res = 600,
  compression = "lzw"
)
draw_figure()
dev.off()

png(
  file.path(
    DIR_FIGURES,
    "R1_Figure_wind_capacity_global_SouthAmerica_Colombia_2016_2025_v2.png"
  ),
  width = 10.5,
  height = 3.8,
  units = "in",
  res = 300
)
draw_figure()
dev.off()

caption <- paste(
  "Figure X. Evolution of installed wind-power capacity at global,",
  "South American, and Colombian scales from 2016 to 2025.",
  "Panels use independent vertical scales to preserve readability.",
  "Capacity corresponds to maximum net generating capacity installed",
  "and connected at the end of each calendar year.",
  "Source: IRENA (2026), Renewable Capacity Statistics 2026."
)

writeLines(
  caption,
  file.path(
    DIR_FIGURES,
    "R1_Figure_wind_capacity_caption_v2.txt"
  )
)

cat("\nRevised figure created successfully.\n")
cat("Output folder:\n", DIR_FIGURES, "\n")

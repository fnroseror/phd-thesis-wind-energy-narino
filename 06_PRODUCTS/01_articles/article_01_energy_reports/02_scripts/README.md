# Scripts — Article 01 Energy Reports

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  
**Author:** Favio Nicolás Rosero Rodríguez

---

## Purpose

This folder contains the R scripts used to support the reproducible analytical workflow for Article 01.

The workflow supports:

1. datetime validation;
2. air-density strategy selection;
3. wind power density calculation;
4. quality control;
5. Weibull/Rayleigh distribution fitting;
6. publication-ready figure generation;
7. ACF/PACF temporal-dependence analysis;
8. FFT-based spectral analysis;
9. final physiographic map generation.

---

## Execution order

The recommended execution order is:

```text
00C_datetime_parser_validation.R
01D_density_overlap_strategy.R
02E_quality_control_daily_density_wpd.R
03F_weibull_rayleigh_distribution_fitting.R
04G_publication_ready_figures_article1.R
05H_distribution_and_publication_figures.R
06I_acf_pacf_temporal_dependence.R
07J_fft_spectral_analysis.R
FIGURE 1 — FINAL ARTICLE-READY MAP
```

> Note: the final map script is currently stored as `FIGURE 1 — FINAL ARTICLE-READY MAP`.  
> For full naming consistency, it may later be renamed as `13_final_map_article_ready.R`.

---

## Script descriptions

### 00C_datetime_parser_validation.R

Validates the datetime parser and confirms the temporal structure of the meteorological dataset.

Main role:

```text
Raw meteorological records
→ parser comparison
→ corrected 2017–2022 article-period dataset
```

Main outputs:

```text
01_data_processed/00C_article_period_2017_2022_correct_datetime.rds
01_data_processed/00C_article_period_2017_2022_correct_datetime.csv
04_tables/00C_parser_comparison_2017_2022.xlsx
04_tables/00C_recommended_datetime_parser.xlsx
04_tables/00C_variable_inventory_corrected_2017_2022.xlsx
```

---

### 01D_density_overlap_strategy.R

Evaluates alternative air-density estimation strategies under variable-overlap limitations.

Strategies evaluated:

```text
hourly observed density
daily zone-level density
monthly zone-level density
overall zone-level density
standard air density
```

Final selected strategy:

```text
daily zone-level air density
```

Main outputs:

```text
01_data_processed/01D_final_wpd_candidate_dataset_corrected_datetime.rds
01_data_processed/01D_final_wpd_candidate_dataset_corrected_datetime.csv
04_tables/01D_density_strategy_comparison_corrected_datetime.xlsx
04_tables/01D_recommended_density_strategy_corrected_datetime.xlsx
```

---

### 02E_quality_control_daily_density_wpd.R

Computes WPD using wind speed and daily zone-level air density.

Main quality-control criterion:

```text
VV <= 20 m s^-1
```

Main outputs:

```text
01_data_processed/02E_article_main_wpd_dataset_after_qc.rds
01_data_processed/02E_article_main_wpd_dataset_after_qc.csv
04_tables/02E_recommended_qc_decision.xlsx
04_tables/02E_article_main_wpd_summary_by_zone.xlsx
04_tables/02E_qc_strategy_comparison_overall.xlsx
```

---

### 03F_weibull_rayleigh_distribution_fitting.R

Performs Weibull and Rayleigh distribution fitting for wind-speed data by analytical zone.

Main role:

```text
Main QC WPD dataset
→ positive wind-speed values
→ Weibull/Rayleigh fitting
→ goodness-of-fit metrics
```

Main outputs:

```text
04_tables/03F_weibull_rayleigh_parameters_by_zone.xlsx
04_tables/03F_weibull_rayleigh_fit_metrics_by_zone.xlsx
04_tables/03F_weibull_rayleigh_model_comparison_by_zone.xlsx
04_tables/03F_best_distribution_by_zone.xlsx
02_results/03F_weibull_rayleigh_distribution_fitting.rds
```

---

### 04G_publication_ready_figures_article1.R

Generates an intermediate publication-ready figure set.

Main role:

```text
Main QC dataset + distribution results
→ monthly figures
→ distribution figures
→ QC sensitivity figure
```

Main outputs:

```text
03_figures/publication_ready/
04_tables/04G_publication_ready_figure_captions.xlsx
04_tables/04G_best_distribution_summary_for_figures.xlsx
```

---

### 05H_distribution_and_publication_figures.R

Final consolidated script for descriptive, distributional and publication-ready figures.

This is the main final script for the descriptive and distributional figure set used in the article.

It supports:

```text
monthly mean wind speed
monthly mean WPD
wind-speed distribution
WPD distribution
Weibull/Rayleigh density fits
Weibull/Rayleigh CDF fits
QC sensitivity analysis
Delta AIC/BIC comparison
```

Main outputs:

```text
03_figures/publication_ready_final/
04_tables/05H_weibull_rayleigh_parameters_by_zone_final.xlsx
04_tables/05H_weibull_rayleigh_fit_metrics_by_zone_final.xlsx
04_tables/05H_weibull_rayleigh_model_comparison_by_zone_final.xlsx
04_tables/05H_best_distribution_by_zone_final.xlsx
04_tables/05H_distribution_model_comparison_table_for_article_final.xlsx
04_tables/05H_best_distribution_table_for_article_final.xlsx
04_tables/05H_publication_ready_figure_captions_final.xlsx
02_results/05H_final_distribution_results_article1.rds
```

---

### 06I_acf_pacf_temporal_dependence.R

Computes temporal-dependence diagnostics for daily WPD and wind-speed series.

It supports:

```text
daily WPD ACF
daily WPD PACF
daily VV ACF
daily VV PACF
temporal decay summaries
coverage summaries
```

Main outputs:

```text
04_tables/06I_daily_ACF_values_VV_WPD_by_zone.xlsx
04_tables/06I_daily_PACF_values_VV_WPD_by_zone.xlsx
04_tables/06I_daily_ACF_temporal_decay_summary.xlsx
04_tables/06I_daily_PACF_temporal_decay_summary.xlsx
04_tables/06I_daily_temporal_coverage_by_zone.xlsx
02_results/06I_temporal_dependence_acf_pacf_article1.rds
```

---

### 07J_fft_spectral_analysis.R

Performs FFT-based spectral analysis using the longest continuous daily segment by analytical zone.

It supports:

```text
WPD FFT spectrum
WPD spectral-band energy
VV FFT spectrum
VV spectral-band energy
top spectral periods
segment summaries
```

Main outputs:

```text
04_tables/07J_FFT_spectral_band_energy_by_zone_variable.xlsx
04_tables/07J_FFT_segment_summary_by_zone_variable.xlsx
04_tables/07J_WPD_top_spectral_periods_table_for_article.xlsx
02_results/07J_fft_spectral_analysis_article1.rds
```

---

### FIGURE 1 — FINAL ARTICLE-READY MAP

Generates the final physiographic study-area map for Article 01.

The map includes:

```text
Nariño, Colombia
topographic relief
municipal boundaries
Pacific context
IDEAM meteorological stations
analytical zones
station labels S01–S16
```

Main outputs:

```text
03_figures/publication_ready_final/Fig_01_final_article_ready_map_narino.tiff
03_figures/publication_ready_final/Fig_01_final_article_ready_map_narino.png
03_figures/publication_ready_final/Fig_01_station_key_for_map.csv
03_figures/publication_ready_final/Fig_01_zone_station_summary.csv
```

Final caption:

```text
Figure 1. Physiographic setting, topographic relief, municipal boundaries,
IDEAM meteorological stations and analytical zoning used for wind power
density assessment in Nariño, Colombia. Station labels S01–S16 correspond
to the station key reported in the supplementary material. Transparent
colored envelopes represent analytical station groupings and should not be
interpreted as administrative or official territorial boundaries.
```

---

## Main methodological chain

```text
Raw meteorological records
        ↓
Datetime validation
        ↓
Air-density strategy selection
        ↓
WPD calculation
        ↓
Quality control
        ↓
Distributional analysis
        ↓
Publication-ready figures
        ↓
Temporal-dependence analysis
        ↓
Spectral analysis
        ↓
Physiographic study-area map
        ↓
Tables, figures and manuscript results
```

---

## Main article-level results supported

The scripts support the following results:

```text
1. WPD estimation using daily zone-level air density.
2. Quality-controlled article dataset with 137,484 records.
3. Final QC criterion: VV <= 20 m s^-1.
4. Weibull distribution outperforming Rayleigh in all analytical zones.
5. Zone 1 as the strongest and most intermittent WPD regime.
6. Daily WPD temporal persistence across analytical zones.
7. FFT-based spectral-energy regimes by zone.
8. Physiographic interpretation of Nariño as a Pacific–Andean wind system.
```

---

## Final intended figure order

```text
Figure 1  — Physiographic setting and analytical zoning in Nariño
Figure 2  — Monthly mean wind speed by analytical zone
Figure 3  — Monthly mean WPD by analytical zone
Figure 4  — Wind-speed distribution by analytical zone
Figure 5  — WPD distribution by analytical zone
Figure 6  — Weibull/Rayleigh density fits
Figure 7  — Weibull/Rayleigh CDF fits
Figure 8  — Daily WPD ACF by analytical zone
Figure 9  — FFT spectral-band energy of daily WPD by analytical zone
```

---

## Main tables supported

```text
Table 1 — Descriptive WPD summary by analytical zone
Table 2 — Weibull/Rayleigh best distribution by analytical zone
Table 3 — Temporal-dependence summary by analytical zone
Table 4 — Spectral-band energy summary by analytical zone
```

---

## Required R packages

The main R packages used across the workflow are:

```text
data.table
dplyr
lubridate
stringr
ggplot2
scales
zoo
fitdistrplus
moments
openxlsx
sf
terra
geodata
ggrepel
ggspatial
patchwork
ggnewscale
stats
utils
```

Additional package details should be documented in:

```text
08_reproducibility/software_versions.md
08_reproducibility/session_info.txt
```

---

## Reproducibility note

Before submission, the workflow should be executable from the first script to the final script.

After execution, generate final session information using:

```r
sink("06_PRODUCTS/01_articles/article_01_energy_reports/08_reproducibility/session_info.txt")
sessionInfo()
sink()
```

---

## TDQ control rule

No figure, table or manuscript claim should be used unless it can be traced to:

```text
Script → Output → Figure/Table → Result summary → Manuscript section
```

---

## Current status

```text
Scripts folder: created
Core analytical scripts: uploaded
Intermediate reproducibility scripts: uploaded
Final map script: uploaded
Execution order: documented
Final sessionInfo: pending
```

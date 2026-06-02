# Scripts — Article 01 Energy Reports

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  

---

## Purpose

This folder contains the R scripts used to generate the analytical workflow for Article 01.

The scripts support:

```text
1. datetime validation;
2. air-density strategy selection;
3. wind power density calculation;
4. quality control;
5. publication figures;
6. Weibull/Rayleigh distributional fitting;
7. ACF/PACF temporal-dependence analysis;
8. FFT spectral analysis;
9. article submission framework outputs.
```

---

## Execution order

The recommended execution order is:

```text
00C_datetime_parser_validation.R
01D_density_overlap_strategy.R
02E_quality_control_daily_density_wpd.R
05H_distribution_and_publication_figures.R
06I_acf_pacf_temporal_dependence.R
07J_fft_spectral_analysis.R
08K_energy_reports_submission_framework.R
```

---

## Script descriptions

### 00C_datetime_parser_validation.R

Validates the correct date parser and confirms the temporal structure of the meteorological dataset.

Main output:

```text
Correct date structure: DMY
Corrected study period: 2017–2022
```

---

### 01D_density_overlap_strategy.R

Evaluates alternative air-density estimation strategies under variable-overlap limitations.

Main strategies evaluated:

```text
Hourly observed density
Daily zone-level density
Monthly zone-level density
Overall zone-level density
Standard air density
```

Final selected strategy:

```text
Daily zone-level air density
```

---

### 02E_quality_control_daily_density_wpd.R

Computes wind power density using wind speed and daily zone-level air density.

Applies the main quality-control criterion:

```text
VV <= 20 m s^-1
```

Main article-level output:

```text
02E_article_main_wpd_dataset_after_qc.rds
```

---

### 05H_distribution_and_publication_figures.R

Generates the main descriptive and distributional figures for the article.

Supports:

```text
Monthly mean wind speed
Monthly mean WPD
Wind-speed distribution
WPD distribution
Weibull/Rayleigh density fits
Weibull/Rayleigh CDF fits
AIC/BIC comparison
QC sensitivity
```

---

### 06I_acf_pacf_temporal_dependence.R

Computes temporal-dependence diagnostics for daily WPD and wind-speed series.

Supports:

```text
Daily WPD ACF
Daily WPD PACF
Daily VV ACF
Daily VV PACF
Temporal decay summaries
Coverage summaries
```

---

### 07J_fft_spectral_analysis.R

Performs FFT-based spectral analysis using the longest continuous daily segment by analytical zone.

Supports:

```text
WPD FFT spectrum
WPD spectral-band energy
VV FFT spectrum
VV spectral-band energy
Top spectral periods
Segment summary
```

---

### 08K_energy_reports_submission_framework.R

Organizes article-level outputs for Energy Reports submission.

Supports:

```text
Final figure organization
Final table organization
Submission package structure
Reproducibility outputs
```

---

## Main scientific outputs

The scripts support the following scientific results:

```text
1. WPD estimation with daily zone-level air density.
2. Quality-controlled article dataset with 137,484 records.
3. Weibull distribution outperforming Rayleigh in all zones.
4. Zone 1 as the strongest and most intermittent WPD regime.
5. Daily WPD temporal persistence across zones.
6. FFT-based temporal-energy regimes by zone.
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
Temporal-dependence analysis
        ↓
Spectral analysis
        ↓
Figures and tables
        ↓
Manuscript results
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
openxlsx
stats
utils
```

Additional package details are documented in:

```text
08_reproducibility/software_versions.md
```

---

## Reproducibility note

Before submission, the full workflow should be executed from the first script to the final script.

After execution, generate the final session information using:

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
Main scripts: loaded or pending verification
Execution order: documented
Reproducibility link: documented
Final sessionInfo: pending
```

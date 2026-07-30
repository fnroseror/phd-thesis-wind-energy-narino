# Execution Order — Article 01 Energy Reports

## Purpose

This file defines the execution order required to reproduce the analytical workflow of Article 01.

The workflow starts from corrected meteorological records and produces the final article-level datasets, tables and publication-ready figures.

---

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  
**Current phase:** Manuscript construction and repository consolidation  

---

## General workflow

```text
Datetime validation
        ↓
Density strategy selection
        ↓
Wind power density calculation
        ↓
Quality control
        ↓
Distributional analysis and publication figures
        ↓
Temporal dependence analysis
        ↓
Spectral analysis
        ↓
Editorial and submission framework
```

---

## Script execution order

### 1. Datetime parser validation

```text
00C_datetime_parser_validation.R
```

**Purpose**

- Validate the correct date parser.
- Confirm the real study period.
- Avoid temporal misinterpretation.
- Generate corrected datetime structure.

**Expected output**

```text
Corrected article-period dataset with valid datetime structure.
```

**Manuscript use**

```text
Study area and meteorological data
Datetime validation and preprocessing
```

---

### 2. Density overlap and WPD strategy

```text
01D_density_overlap_strategy.R
```

**Purpose**

- Evaluate pressure and temperature overlap.
- Compare air-density strategies.
- Select the most appropriate air-density strategy.
- Calculate candidate Wind Power Density.

**Expected outputs**

```text
Daily zone-level air-density strategy
Candidate WPD dataset
Density strategy comparison table
```

**Manuscript use**

```text
Methodology
Air density and WPD formulation
Daily zone-level density strategy
```

---

### 3. Quality control

```text
02E_quality_control_daily_density_wpd.R
```

**Purpose**

- Evaluate WPD sensitivity to extreme wind-speed values.
- Compare quality-control scenarios.
- Select the main QC criterion.
- Generate the final article-level WPD dataset.

**Main QC decision**

```text
VV <= 20 m s^-1
```

**Expected output**

```text
02E_article_main_wpd_dataset_after_qc.rds
```

**Manuscript use**

```text
Methodology
Quality-control criterion
Supplementary material
```

---

### 4. Distributional analysis and publication figures

```text
05H_distribution_and_publication_figures.R
```

**Purpose**

- Generate descriptive statistics.
- Fit Weibull and Rayleigh distributions.
- Compare goodness-of-fit metrics.
- Export publication-ready figures.
- Export editable result tables.

**Expected main figures**

```text
Figure 1 — Monthly mean wind speed by analytical zone
Figure 2 — Monthly mean WPD by analytical zone
Figure 3 — Wind-speed distribution by analytical zone
Figure 4 — WPD distribution by analytical zone
Figure 5 — Weibull/Rayleigh density fits
Figure 6 — Weibull/Rayleigh CDF fits
```

**Expected supplementary figures**

```text
Figure S1 — QC sensitivity of mean WPD
Figure S2 — Delta AIC/BIC Weibull vs Rayleigh
```

**Manuscript use**

```text
Results 4.1 — Wind speed and WPD variability
Results 4.2 — Zonal contrast in wind-energy potential
Results 4.3 — Weibull and Rayleigh fitting
```

---

### 5. Temporal dependence analysis

```text
06I_acf_pacf_temporal_dependence.R
```

**Purpose**

- Aggregate daily WPD and wind speed by zone.
- Regularize daily series.
- Apply short-gap interpolation.
- Compute ACF and PACF.
- Summarize temporal persistence.

**Expected main figure**

```text
Figure 7 — Daily WPD ACF by analytical zone
```

**Expected supplementary figures**

```text
Figure S3 — Daily WPD PACF by analytical zone
Figure S4 — Daily VV ACF/PACF support
```

**Expected tables**

```text
Daily temporal coverage by zone
Daily ACF temporal decay summary
Daily PACF temporal decay summary
```

**Manuscript use**

```text
Results 4.4 — Temporal persistence of WPD
Supplementary material
```

---

### 6. FFT spectral analysis

```text
07J_fft_spectral_analysis.R
```

**Purpose**

- Identify the longest continuous daily segment by zone.
- Compute FFT spectra for WPD and wind speed.
- Identify dominant temporal periods.
- Aggregate spectral power by physical period bands.

**Expected main figure**

```text
Figure 8 — WPD spectral band energy by analytical zone
```

**Expected supplementary figures**

```text
Figure S5 — Raw FFT spectrum support
```

**Expected tables**

```text
FFT segment summary by zone and variable
FFT top spectral periods by zone and variable
FFT spectral band energy by zone and variable
```

**Manuscript use**

```text
Results 4.5 — Spectral structure of WPD
Discussion
Supplementary material
```

---

### 7. Editorial submission framework

```text
08K_energy_reports_submission_framework.R
```

**Purpose**

- Create editorial structure.
- Create compliance matrix.
- Create submission checklist.
- Create declaration templates.
- Organize manuscript and submission package.

**Expected outputs**

```text
Energy Reports compliance matrix
Repository traceability map
Submission readiness checklist
Data availability statement
Declaration files
Cover letter draft
```

**Manuscript use**

```text
Submission package
Editorial compliance
Repository documentation
```

---

## Final analytical dataset

The final analytical dataset used for manuscript figures and tables is:

```text
02E_article_main_wpd_dataset_after_qc.rds
```

This dataset corresponds to the quality-controlled WPD database generated using:

```text
Daily zone-level air density
VV <= 20 m s^-1
```

---

## Main derived outputs

The workflow generates:

```text
1. Corrected datetime dataset
2. Density strategy comparison
3. Final WPD dataset after QC
4. Descriptive statistics by zone
5. Weibull/Rayleigh fitting outputs
6. ACF/PACF temporal-dependence outputs
7. FFT spectral-analysis outputs
8. Publication-ready figures
9. Editable tables
10. Editorial compliance files
```

---

## Figure generation logic

Main manuscript figures are generated from scripts and copied into:

```text
03_figures/main_text/
```

Supplementary figures are generated from scripts and copied into:

```text
03_figures/supplementary/
```

Figures must remain traceable to their source scripts.

---

## Table generation logic

Main manuscript tables are generated from scripts and copied into:

```text
04_tables/main_text/
```

Supplementary tables are generated from scripts and copied into:

```text
04_tables/supplementary/
```

Tables must remain editable and should not be submitted as images.

---

## Software environment

The main software environment is:

```text
R / RStudio
```

The main R packages include:

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
```

Additional package details should be documented in:

```text
software_versions.md
session_info.txt
```

---

## Reproducibility notes

The scripts must be executed in the order defined above because each script depends on outputs generated by previous steps.

The repository does not necessarily redistribute raw IDEAM data. Reproducibility depends on access to the original meteorological records or to the derived article-level datasets when redistribution is permitted.

---

## TDQ reproducibility rule

Every figure, table and manuscript claim must be traceable to:

```text
Script → Output file → Repository folder → Manuscript section
```

If an output cannot be regenerated from the documented workflow, it should not be used in the submitted manuscript.

---

## Current reproducibility status

```text
Execution order: defined
Core scripts: generated
Final dataset: generated
Figures: generated
Tables: generated
Software versions: pending
Session info: pending
Data access notes: pending
```

# Tables — Article 01 Energy Reports

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  

---

## Purpose

This folder contains the final tables prepared for Article 01 submission.

The tables are organized into:

```text
main_text/
supplementary/
```

---

## Folder structure

```text
04_tables/
├── README.md
├── main_text/
└── supplementary/
```

---

# 1. Main-text tables

The folder:

```text
04_tables/main_text/
```

must contain the editable tables used directly in the main manuscript.

Recommended final table list:

```text
Table_01_dataset_zones_temporal_coverage.xlsx
Table_02_descriptive_statistics_VV_WPD_by_zone.xlsx
Table_03_weibull_rayleigh_parameters_fit_metrics.xlsx
Table_04_temporal_spectral_summary_WPD_by_zone.xlsx
```

---

# 2. Supplementary tables

The folder:

```text
04_tables/supplementary/
```

must contain detailed tables used as supplementary evidence.

Recommended supplementary table list:

```text
Table_S1_QC_scenario_comparison.xlsx
Table_S2_full_weibull_rayleigh_fit_metrics.xlsx
Table_S3_daily_ACF_PACF_values_by_zone.xlsx
Table_S4_FFT_top_spectral_periods_by_zone_variable.xlsx
Table_S5_FFT_spectral_band_energy_by_zone_variable.xlsx
Table_S6_temporal_coverage_by_zone.xlsx
```

---

# 3. Main table descriptions

## Table 1

**Dataset, analytical zones and temporal coverage.**

Purpose:

```text
Summarizes the meteorological dataset, analytical zoning, study period and temporal coverage used in the article.
```

---

## Table 2

**Descriptive statistics of wind speed and wind power density by analytical zone.**

Purpose:

```text
Reports the main descriptive statistics of VV and WPD after quality control.
```

Recommended contents:

```text
Zone
Variable
n
Mean
Median
Standard deviation
Minimum
Percentile 25
Percentile 75
Percentile 90
Percentile 95
Maximum
```

---

## Table 3

**Weibull and Rayleigh distribution parameters and goodness-of-fit metrics by analytical zone.**

Purpose:

```text
Supports the selection of Weibull as the preferred distributional model.
```

Recommended contents:

```text
Zone
Distribution
Shape parameter
Scale parameter
AIC
BIC
Delta AIC
Delta BIC
Preferred model
```

---

## Table 4

**Temporal and spectral summary of wind power density by analytical zone.**

Purpose:

```text
Integrates ACF, PACF and FFT results into one compact table for the main manuscript.
```

Recommended contents:

```text
Zone
ACF lag 1
First lag |ACF| < 0.2
PACF lag 1
First lag |PACF| < 0.2
Dominant spectral band
Main spectral contribution
Interpretation
Coverage note
```

---

# 4. Supplementary table descriptions

## Table S1

**Quality-control scenario comparison.**

Purpose:

```text
Documents how alternative wind-speed thresholds affect WPD statistics and record retention.
```

---

## Table S2

**Full Weibull/Rayleigh fitting metrics.**

Purpose:

```text
Provides complete distributional fitting evidence for all analytical zones.
```

---

## Table S3

**Daily ACF and PACF values by lag and analytical zone.**

Purpose:

```text
Provides detailed temporal-dependence values supporting the ACF/PACF figures.
```

---

## Table S4

**FFT top spectral periods by analytical zone and variable.**

Purpose:

```text
Reports the dominant spectral periods detected by FFT analysis.
```

---

## Table S5

**FFT spectral-band energy by analytical zone and variable.**

Purpose:

```text
Reports the relative contribution of each period band to normalized spectral power.
```

---

## Table S6

**Temporal coverage by analytical zone.**

Purpose:

```text
Documents the temporal coverage and continuous-segment length used for temporal and spectral diagnostics.
```

---

# 5. Technical requirements

Before submission, verify that all tables are:

```text
Editable
Clearly numbered
Consistent with manuscript captions
Consistent with figure results
Stored in Excel or Word-compatible format
Not inserted as images
Cited in the manuscript
Traceable to R scripts
```

---

# 6. Recommended formats

Preferred formats:

```text
.xlsx
.docx
.csv
```

For GitHub documentation and reproducibility:

```text
.xlsx and .csv are recommended.
```

For manuscript integration:

```text
Tables should remain editable in DOCX.
```

Avoid:

```text
tables as screenshots
tables embedded only in images
unclear temporary filenames
manual values without script traceability
```

---

# 7. Table traceability rule

Each table must be traceable to:

```text
R script → output file → table folder → manuscript caption → manuscript citation
```

Example:

```text
06I_acf_pacf_temporal_dependence.R
        ↓
06I_daily_ACF_temporal_decay_summary.xlsx
        ↓
04_tables/supplementary/Table_S3_daily_ACF_PACF_values_by_zone.xlsx
        ↓
Table S3 caption
        ↓
Supplementary material
```

---

# 8. Naming convention

Use clear and stable filenames.

Recommended pattern:

```text
Table_XX_short_description.xlsx
Table_SX_short_description.xlsx
```

Avoid filenames with:

```text
spaces
accents
temporary words
draft labels
unclear versions
```

Do not use:

```text
tabla nueva.xlsx
final final.xlsx
table1.xlsx
datos.xlsx
```

---

# 9. TDQ control note

A table enters the manuscript only if it satisfies:

```text
1. It supports a specific result.
2. It contains necessary numerical evidence.
3. It is readable.
4. It is editable.
5. It is traceable to a script.
6. It is cited in the manuscript.
7. It does not duplicate unnecessary information.
```

---

# 10. Current status

```text
Tables folder: created
Main-text table folder: pending population
Supplementary table folder: pending population
Table captions: drafted
Manuscript integration: pending
```

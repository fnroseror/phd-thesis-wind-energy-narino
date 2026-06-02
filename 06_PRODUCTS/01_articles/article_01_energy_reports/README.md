# Article 01 — Energy Reports Submission Workspace

## Provisional title

**Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia**

---

## Target journal

**Journal:** Energy Reports  
**Publisher:** Elsevier  
**Article type:** Research Article  
**Current status:** Submission-package construction  
**Repository status:** Active working folder for manuscript, figures, tables, reproducibility and submission files  

---

## Purpose of this folder

This folder contains the complete working package for Article 01, prepared for submission to *Energy Reports*.

The article is derived from the doctoral research framework on wind-energy characterization in Nariño, Colombia, and focuses on the physical–statistical analysis of wind power density using observed meteorological data.

The purpose of this repository section is to provide:

```text
1. manuscript draft;
2. journal-format control;
3. scripts used for analysis;
4. final figures;
5. final tables;
6. result summaries;
7. supplementary material;
8. submission declarations;
9. reproducibility documentation;
10. traceability from scripts to manuscript claims.
```

---

## Scientific scope

The article focuses on:

```text
Wind power density
Complex Andean terrain
Nariño, Colombia
Multi-station meteorological data
Air-density-supported WPD estimation
Weibull/Rayleigh distributional analysis
ACF/PACF temporal-dependence analysis
FFT spectral analysis
Reproducible physical–statistical workflow
```

The article does not focus on:

```text
Turbine-level production
Wind-farm micrositing
CFD simulation
Economic feasibility
Grid integration
Operational forecasting
TDQ as a theoretical article
```

---

## Main research question

How does wind power density vary across analytical zones in complex Andean terrain, and what distributional, temporal and spectral structures characterize its behavior?

---

## Core physical formulation

Wind power density is computed as:

```text
WPD = 0.5 * rho * v^3
```

where:

```text
WPD = wind power density
rho = air density
v = wind speed
```

Air density is estimated using:

```text
rho = p / (R * T)
```

where:

```text
p = atmospheric pressure
R = specific gas constant for dry air
T = absolute temperature
```

---

## Repository structure

```text
article_01_energy_reports/
├── README.md
├── 00_editorial_strategy/
├── 01_manuscript/
├── 02_scripts/
├── 03_figures/
│   ├── main_text/
│   └── supplementary/
├── 04_tables/
│   ├── main_text/
│   └── supplementary/
├── 05_results_summary/
├── 06_supplementary_material/
├── 07_submission_package/
└── 08_reproducibility/
```

---

## Folder description

### 00_editorial_strategy

Contains journal-alignment and editorial-control files.

Main files:

```text
energy_reports_compliance_matrix.md
repository_traceability_map.md
submission_readiness_checklist.md
article_scope_tdq.md
energy_reports_format_lock.md
```

Purpose:

```text
Locks the article scope, submission strategy, journal requirements and traceability logic.
```

---

### 01_manuscript

Contains the manuscript working files.

Main files:

```text
title_highlights_abstract_keywords.md
figure_captions.md
manuscript_energy_reports_master.md
references_pending.md
```

Purpose:

```text
Develops the article text, abstract, highlights, keywords, captions and references.
```

---

### 02_scripts

Contains the R scripts used to generate the article results.

Main scripts:

```text
00C_datetime_parser_validation.R
01D_density_overlap_strategy.R
02E_quality_control_daily_density_wpd.R
05H_distribution_and_publication_figures.R
06I_acf_pacf_temporal_dependence.R
07J_fft_spectral_analysis.R
```

Purpose:

```text
Provides the computational basis for WPD estimation, quality control, distributional analysis, temporal analysis and spectral analysis.
```

---

### 03_figures

Contains final article figures.

Structure:

```text
03_figures/main_text/
03_figures/supplementary/
```

Purpose:

```text
Stores publication-ready figures used in the main manuscript and supplementary material.
```

---

### 04_tables

Contains final article tables.

Structure:

```text
04_tables/main_text/
04_tables/supplementary/
```

Purpose:

```text
Stores editable tables used in the main manuscript and supplementary material.
```

---

### 05_results_summary

Contains concise result summaries used to support manuscript writing.

Main files:

```text
main_results_summary.md
distribution_results_summary.md
temporal_results_summary.md
spectral_results_summary.md
```

Purpose:

```text
Documents the main scientific results and protects consistency between figures, tables and manuscript claims.
```

---

### 06_supplementary_material

Contains supplementary files prepared for journal submission.

Purpose:

```text
Supports the manuscript with additional figures, tables, methods or reproducibility notes.
```

---

### 07_submission_package

Contains journal submission declarations and cover-letter material.

Main files:

```text
data_availability_statement.md
competing_interest_statement.md
funding_statement.md
credit_author_statement.md
generative_ai_declaration.md
cover_letter_draft.md
```

Purpose:

```text
Prepares the formal editorial files required for submission.
```

---

### 08_reproducibility

Contains reproducibility documentation.

Main files:

```text
execution_order.md
data_access_notes.md
software_versions.md
session_info_placeholder.txt
```

Purpose:

```text
Documents execution order, data access, software versions and computational environment.
```

---

## Current article status

```text
Article type: Research Article
Target journal: Energy Reports
Manuscript base: drafted
Abstract: drafted and within word limit
Highlights: drafted
Keywords: drafted
Figures folder: created
Tables folder: created
Scripts: uploaded and documented
Results summaries: drafted
Submission declarations: drafted
Reproducibility files: drafted
References: pending verification
Final DOCX: pending
Online submission account: pending
```

---

## Main scientific outputs

The article currently supports the following results:

```text
1. WPD was estimated using wind speed and daily zone-level air density.
2. The corrected study period corresponds to 2017–2022.
3. The final quality-control criterion was VV <= 20 m s^-1.
4. The final article-level dataset retained 137,484 records.
5. Zone 1 showed the highest and most intermittent WPD regime.
6. Weibull outperformed Rayleigh in all analytical zones.
7. Daily WPD showed relevant temporal persistence.
8. FFT analysis revealed distinct temporal-energy regimes across zones.
```

---

## Main figure plan

Main-text figures:

```text
Fig_01_monthly_mean_wind_speed_by_zone_FINAL.png
Fig_02_monthly_mean_WPD_by_zone_FINAL.png
Fig_03_wind_speed_distribution_by_zone_FINAL.png
Fig_04_WPD_distribution_by_zone_FINAL.png
Fig_05_weibull_rayleigh_density_fit_by_zone_FINAL.png
Fig_06_weibull_rayleigh_CDF_fit_by_zone_FINAL.png
Fig_07_daily_WPD_ACF_by_zone_FINAL.png
Fig_08_daily_WPD_FFT_band_energy_by_zone_FINAL.png
```

Supplementary figures:

```text
Fig_S1_QC_sensitivity_mean_WPD_FINAL.png
Fig_S2_delta_AIC_BIC_weibull_rayleigh_comparison_FINAL.png
Fig_S3_daily_WPD_PACF_by_zone_FINAL.png
Fig_S4_daily_VV_ACF_by_zone_FINAL.png
Fig_S5_daily_VV_PACF_by_zone_FINAL.png
Fig_S6_daily_WPD_FFT_spectrum_by_zone_FINAL.png
Fig_S7_daily_VV_FFT_spectrum_by_zone_FINAL.png
Fig_S8_daily_VV_FFT_band_energy_by_zone_FINAL.png
```

---

## Main table plan

Main-text tables:

```text
Table_01_dataset_zones_temporal_coverage.xlsx
Table_02_descriptive_statistics_VV_WPD_by_zone.xlsx
Table_03_weibull_rayleigh_parameters_fit_metrics.xlsx
Table_04_temporal_spectral_summary_WPD_by_zone.xlsx
```

Supplementary tables:

```text
Table_S1_QC_scenario_comparison.xlsx
Table_S2_full_weibull_rayleigh_fit_metrics.xlsx
Table_S3_daily_ACF_PACF_values_by_zone.xlsx
Table_S4_FFT_top_spectral_periods_by_zone_variable.xlsx
Table_S5_FFT_spectral_band_energy_by_zone_variable.xlsx
Table_S6_temporal_coverage_by_zone.xlsx
```

---

## Journal-format control

The article must comply with the following submission requirements:

```text
Research Article
Target length: 5,000–7,000 words
Abstract: maximum 250 words
Keywords: 1–7
Highlights: 3–5 bullet points, maximum 85 characters each
References: author-year style
Figures: separate high-resolution files
Tables: editable, not images
Equations: editable text
Data availability statement: required
Generative AI declaration: required if AI-assisted tools were used
Main manuscript: DOCX or other editable source file
```

Detailed requirements are documented in:

```text
00_editorial_strategy/energy_reports_format_lock.md
```

---

## Data availability strategy

Raw IDEAM observational records are not redistributed in this repository due to source-data redistribution considerations.

This repository provides:

```text
R scripts
derived outputs where permitted
summary tables
publication-ready figures
reproducibility documentation
editorial traceability files
```

Access to original raw meteorological records should be requested or downloaded from the official IDEAM data platform.

---

## Generative AI declaration control

AI-assisted tools were used for:

```text
manuscript organization
editorial planning
language refinement
code-review discussion
repository structuring
```

AI-assisted tools were not used for:

```text
raw data generation
fabrication of results
alteration of scientific figures
generation of R plots as artificial images
replacement of author verification
```

All scientific analyses, figures and tables must remain traceable to the author-controlled R workflow.

---

## Traceability principle

Every manuscript claim must be supported by the following chain:

```text
R script
        ↓
Output table or figure
        ↓
Result summary
        ↓
Manuscript section
        ↓
Submission package
```

No unsupported claim should be included in the final article.

---

## Current readiness estimate

```text
Editorial structure:        90–95 %
Scripts:                    85 %
Results summaries:          90 %
Submission declarations:    85 %
Reproducibility package:    85 %
Manuscript base:            60–65 %
Figures in final folders:   pending
Tables in final folders:    pending
References:                 pending
DOCX submission file:       pending

Overall submission readiness: 72–75 %
```

---

## Immediate next actions

```text
1. Copy final main figures into 03_figures/main_text/.
2. Copy final supplementary figures into 03_figures/supplementary/.
3. Copy final main tables into 04_tables/main_text/.
4. Copy final supplementary tables into 04_tables/supplementary/.
5. Replace references_pending.md with verified author-year references.
6. Refine manuscript_energy_reports_master.md with exact numerical values.
7. Create final highlights editable file.
8. Convert manuscript to DOCX.
9. Create or access Elsevier Editorial Manager account.
10. Submit and obtain manuscript number or confirmation email.
```

---

## TDQ control rule

This article must remain:

```text
focused
reproducible
physically grounded
editorially compliant
scientifically defensible
```

Avoid:

```text
overclaiming
mixing thesis theory beyond article scope
adding unsupported discussion
using non-verified references
submitting figures without traceability
submitting tables as images
```

---

## Final objective

The immediate objective of this workspace is:

```text
Submit Article 01 to Energy Reports and obtain formal submission confirmation.
```

The longer-term objective is:

```text
Achieve peer-reviewed publication through a rigorous, traceable and reproducible wind-energy characterization article.
```

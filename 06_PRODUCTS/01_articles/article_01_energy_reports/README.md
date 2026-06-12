# Article 01 — Energy Reports Submission Package

## Article title

**Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia**

## Target journal

- **Journal:** Energy Reports
- **Publisher:** Elsevier
- **Article type:** Research Article
- **Current status:** Submission-ready manuscript and editorial package; online submission pending
- **Last repository update:** 2026-06-12

---

## Purpose of this workspace

This folder contains the complete scientific, computational and editorial package for Article 01, derived from the doctoral research on wind-energy characterization in Nariño, Colombia.

The repository section supports:

1. manuscript traceability;
2. reproducible R-based analysis;
3. publication-ready figures and tables;
4. supplementary material;
5. editorial declarations and submission files;
6. consistency between scripts, outputs and manuscript claims.

---

## Scientific scope

The article focuses on:

- wind power density (WPD);
- complex Andean terrain;
- multi-station meteorological observations in Nariño, Colombia;
- daily zone-level air-density estimation;
- conservative wind-speed quality control;
- Weibull and Rayleigh distributional comparison;
- ACF/PACF temporal-dependence diagnostics;
- FFT-based spectral analysis;
- reproducible physical–statistical characterization.

The article does **not** claim:

- turbine-level energy production;
- commercial wind-farm feasibility;
- micrositing;
- CFD simulation;
- economic feasibility;
- grid-integration assessment;
- operational forecasting capability.

---

## Research question

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
v   = wind speed
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

## Main scientific results

The current manuscript supports the following results:

1. The corrected observational period is 2017–2022.
2. WPD was estimated using wind speed and daily zone-level air density.
3. The final quality-control criterion was `VV <= 20 m s^-1`.
4. The final article-level dataset retained 137,484 records, corresponding to 99.7562% of the selected WPD dataset.
5. Zone 1 showed the highest mean WPD, approximately 140.76 W m^-2.
6. The energetic dominance of Zone 1 was associated with intermittency and a long high-speed tail rather than uniformly high wind speed.
7. Weibull outperformed Rayleigh in all four analytical zones.
8. Daily WPD showed zone-dependent temporal memory.
9. FFT analysis identified distinct spectral-energy regimes, including low-frequency dominance in Zone 1.
10. The results provide regional physical–statistical evidence but do not establish turbine-level feasibility or commercial viability.

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

## Final manuscript

The submission-ready manuscript is:

```text
01_manuscript/
└── Energy_Reports_Article01_Main_Manuscript_Submission_READY.docx
```

This file contains:

- title, authors and affiliations;
- highlights;
- abstract and keywords;
- main manuscript text;
- Tables 1–4;
- Figures 1–9;
- data availability statement;
- CRediT author statement;
- competing-interest declaration;
- funding statement;
- generative-AI declaration;
- final reference list.

Earlier manuscript files remain as working-history records. The file above is the official submission source.

---

## Main figures

Publication-ready TIFF files are stored in:

```text
03_figures/main_text/
```

Final figure set:

```text
Fig_01_physiographic_setting_zoning_narino_FINAL.tiff
Fig_02_monthly_mean_wind_speed_by_zone_FINAL.tiff
Fig_03_monthly_mean_WPD_by_zone_FINAL.tiff
Fig_04_wind_speed_distribution_by_zone_FINAL.tiff
Fig_05_WPD_distribution_by_zone_FINAL.tiff
Fig_06_weibull_rayleigh_density_fit_by_zone_FINAL.tiff
Fig_07_weibull_rayleigh_CDF_fit_by_zone_FINAL.tiff
Fig_08_daily_WPD_ACF_by_zone_FINAL.tiff
Fig_09_daily_WPD_FFT_band_energy_by_zone_FINAL.tiff
```

---

## Supplementary figures

Publication-ready TIFF files are stored in:

```text
03_figures/supplementary/
```

Final supplementary figure set:

```text
Fig_S1_QC_sensitivity_mean_WPD_FINAL.tiff
Fig_S2_delta_AIC_BIC_weibull_rayleigh_comparison_FINAL.tiff
Fig_S3_daily_WPD_PACF_by_zone_FINAL.tiff
Fig_S4_daily_VV_ACF_by_zone_FINAL.tiff
Fig_S5_daily_VV_PACF_by_zone_FINAL.tiff
Fig_S6_daily_WPD_FFT_spectrum_by_zone_FINAL.tiff
Fig_S7_daily_VV_FFT_spectrum_by_zone_FINAL.tiff
Fig_S8_daily_VV_FFT_band_energy_by_zone_FINAL.tiff
```

PACF is used as a supplementary diagnostic. The main manuscript cites Fig. S3 for WPD and Fig. S5 for wind speed.

---

## Main tables

Editable final tables are stored in:

```text
04_tables/main_text/
```

Final table set:

```text
Table_01_IDEAM_meteorological_stations_and_analytical_zoning.csv
Table_02_descriptive_statistics_VV_WPD_by_zone.xlsx
Table_03_selected_wind_speed_distribution_fit_metrics_by_zone.xlsx
Table_04_temporal_spectral_summary_WPD_by_zone.xlsx
```

Table 4 integrates the temporal-dependence and spectral summaries used in the manuscript.

---

## Supplementary material

The journal-ready supplementary document is stored in:

```text
06_supplementary_material/
└── Energy_Reports_Article01_Supplementary_Material_Figures_S1_S8.docx
```

The same folder contains:

- Figures S1–S8 in TIFF format;
- `Supplementary_Figure_Captions.txt`.

---

## Submission package

Final editorial files are stored in:

```text
07_submission_package/
```

Current files:

```text
Energy_Reports_Article01_Cover_Letter.docx
Energy_Reports_Article01_Submission_Checklist.md
Energy_Reports_Article01_Submission_File_Manifest.csv
```

The checklist and manifest use the definitive manuscript and supplementary-material filenames.

---

## Computational workflow

The R scripts used to generate the article results are stored in:

```text
02_scripts/
```

Core scripts include:

```text
00C_datetime_parser_validation.R
01D_density_overlap_strategy.R
02E_quality_control_daily_density_wpd.R
05H_distribution_and_publication_figures.R
06I_acf_pacf_temporal_dependence.R
07J_fft_spectral_analysis.R
```

Additional scripts support map generation, auditing, table production and final figure preparation.

---

## Reproducibility

Reproducibility documentation is stored in:

```text
08_reproducibility/
```

Current files include:

```text
data_access_notes.md
execution_order.md
software_versions.md
session_info_placeholder.txt
```

Before final archival release, `session_info_placeholder.txt` should be replaced with an actual R session-information file, preferably:

```text
session_info_R.txt
```

generated in R with:

```r
sessionInfo()
```

This is a repository-completeness action and does not change the scientific content of the manuscript.

---

## Data availability

Raw IDEAM meteorological observations are not redistributed in this repository because of source-data redistribution considerations.

The repository provides, where permitted:

- R scripts;
- derived summaries;
- editable tables;
- publication-ready figures;
- supplementary material;
- reproducibility documentation;
- editorial traceability files.

Access to original meteorological records should be requested or obtained through the official IDEAM data platform.

---

## Generative-AI disclosure

AI-assisted tools were used to support:

- manuscript organization;
- editorial planning;
- language refinement;
- code-review discussion;
- repository structuring.

AI-assisted tools were not used to:

- generate raw meteorological data;
- fabricate scientific results;
- alter analytical outputs;
- replace author verification;
- create artificial substitutes for the R-generated scientific figures.

All analyses, calculations, figures and tables remain traceable to the author-controlled computational workflow.

---

## Traceability principle

Every scientific claim should follow this chain:

```text
R script
↓
Derived output, table or figure
↓
Result summary
↓
Manuscript section
↓
Submission package
```

No unsupported scientific claim should be included in the submitted article.

---

## Current readiness

```text
Scientific manuscript: complete
Main tables: complete
Main figures: complete
Supplementary figures: complete
Supplementary document: complete
Cover letter: complete
Submission checklist: complete
Submission manifest: complete
Repository synchronization: near-complete
Online journal submission: pending
```

Estimated submission-package readiness:

```text
95–97%
```

The remaining repository task is to replace the R session-information placeholder and perform one final cross-folder verification before submission.

---

## Immediate next actions

1. Replace `session_info_placeholder.txt` with actual R `sessionInfo()` output.
2. Perform final repository cross-check.
3. Verify author metadata in the journal submission system.
4. Upload the manuscript, cover letter and supplementary material.
5. Review the PDF generated by the submission system.
6. Submit and record the manuscript number or confirmation email.

---

## Final objective

The immediate objective is to submit Article 01 to *Energy Reports* and obtain formal submission confirmation.

The longer-term objective is to achieve peer-reviewed publication through a rigorous, traceable and reproducible physical–statistical characterization of wind power density in complex Andean terrain.

# Repository Traceability Map — Article 01 Energy Reports

## Purpose

This file documents the traceability chain of Article 01, from data processing to manuscript preparation.

The objective is to ensure that every scientific claim, figure, table and editorial component can be traced to a reproducible script, output file or repository evidence.

---

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  
**Current phase:** Manuscript construction and repository consolidation  

---

## General traceability logic

```text
Raw meteorological records
        ↓
Datetime validation
        ↓
Density strategy selection
        ↓
Wind power density calculation
        ↓
Quality control
        ↓
Distributional analysis
        ↓
Temporal dependence analysis
        ↓
Spectral analysis
        ↓
Figures and tables
        ↓
Manuscript sections
        ↓
Submission package
```

---

## 1. Data processing traceability

| Step | Description | Script | Output | Manuscript section |
|---|---|---|---|---|
| Datetime validation | Validation of the correct DMY date parser and real study period | `02_scripts/00C_datetime_parser_validation.R` | Corrected temporal structure | Study area and data / preprocessing |
| Density overlap analysis | Comparison of hourly, daily, monthly and standard density strategies | `02_scripts/01D_density_overlap_strategy.R` | Daily zone-level density selected | Methodology |
| WPD calculation | Calculation of wind power density using air density and wind speed | `02_scripts/01D_density_overlap_strategy.R` | Candidate WPD dataset | Methodology |
| Quality control | Selection of the main QC scenario using VV <= 20 m s^-1 | `02_scripts/02E_quality_control_daily_density_wpd.R` | Final WPD dataset after QC | Methodology / Results |
| Final dataset | Final article-level dataset for WPD analysis | `01_data_processed/` | `02E_article_main_wpd_dataset_after_qc.rds` | Results |

---

## 2. Statistical and physical analysis traceability

| Analysis block | Scientific purpose | Script | Output | Manuscript use |
|---|---|---|---|---|
| Descriptive analysis | Characterize wind speed and WPD by analytical zone | `02_scripts/05H_distribution_and_publication_figures.R` | Descriptive figures and tables | Results 4.1 / 4.2 |
| Weibull/Rayleigh fitting | Assess wind-speed distributional behavior by zone | `02_scripts/05H_distribution_and_publication_figures.R` | Parameters, AIC/BIC, CDF and density fits | Results 4.3 |
| ACF/PACF | Evaluate temporal persistence of WPD and wind speed | `02_scripts/06I_acf_pacf_temporal_dependence.R` | ACF/PACF figures and summaries | Results 4.4 |
| FFT spectral analysis | Identify dominant temporal-energy regimes | `02_scripts/07J_fft_spectral_analysis.R` | Spectral bands and FFT summaries | Results 4.5 / Discussion |

---

## 3. Main figure traceability

| Figure | Description | Source script | Repository destination | Manuscript section |
|---|---|---|---|---|
| Figure 1 | Monthly mean wind speed by analytical zone | `02_scripts/05H_distribution_and_publication_figures.R` | `03_figures/main_text/` | Results 4.1 |
| Figure 2 | Monthly mean WPD by analytical zone | `02_scripts/05H_distribution_and_publication_figures.R` | `03_figures/main_text/` | Results 4.2 |
| Figure 3 | Wind-speed distribution by analytical zone | `02_scripts/05H_distribution_and_publication_figures.R` | `03_figures/main_text/` | Results 4.1 |
| Figure 4 | WPD distribution by analytical zone | `02_scripts/05H_distribution_and_publication_figures.R` | `03_figures/main_text/` | Results 4.2 |
| Figure 5 | Weibull and Rayleigh density fits | `02_scripts/05H_distribution_and_publication_figures.R` | `03_figures/main_text/` | Results 4.3 |
| Figure 6 | Weibull and Rayleigh CDF fits | `02_scripts/05H_distribution_and_publication_figures.R` | `03_figures/main_text/` | Results 4.3 |
| Figure 7 | Daily WPD autocorrelation by analytical zone | `02_scripts/06I_acf_pacf_temporal_dependence.R` | `03_figures/main_text/` | Results 4.4 |
| Figure 8 | WPD spectral band energy by analytical zone | `02_scripts/07J_fft_spectral_analysis.R` | `03_figures/main_text/` | Results 4.5 |

---

## 4. Supplementary figure traceability

| Supplementary figure | Description | Source script | Repository destination | Role |
|---|---|---|---|---|
| Figure S1 | QC sensitivity of mean WPD | `02_scripts/02E_quality_control_daily_density_wpd.R` | `03_figures/supplementary/` | Supports QC decision |
| Figure S2 | Delta AIC/BIC comparison between Weibull and Rayleigh | `02_scripts/05H_distribution_and_publication_figures.R` | `03_figures/supplementary/` | Supports distribution selection |
| Figure S3 | Daily WPD PACF by analytical zone | `02_scripts/06I_acf_pacf_temporal_dependence.R` | `03_figures/supplementary/` | Supports autoregressive interpretation |
| Figure S4 | Daily VV ACF/PACF support | `02_scripts/06I_acf_pacf_temporal_dependence.R` | `03_figures/supplementary/` | Supports wind-speed temporal structure |
| Figure S5 | Raw FFT spectrum of WPD/VV | `02_scripts/07J_fft_spectral_analysis.R` | `03_figures/supplementary/` | Supports spectral-band interpretation |

---

## 5. Main table traceability

| Table | Description | Source | Repository destination | Manuscript section |
|---|---|---|---|---|
| Table 1 | Dataset, stations, zones and temporal coverage | Processing outputs | `04_tables/main_text/` | Study area and data |
| Table 2 | Descriptive statistics of VV and WPD by zone | Distribution/publication script | `04_tables/main_text/` | Results |
| Table 3 | Weibull/Rayleigh parameters and goodness-of-fit metrics | Distribution fitting script | `04_tables/main_text/` | Results |
| Table 4 | Temporal and spectral summary by zone | ACF/PACF and FFT scripts | `04_tables/main_text/` | Results / Discussion |

---

## 6. Manuscript traceability

| Manuscript component | Evidence source | Repository location | Status |
|---|---|---|---|
| Title | Article scope and target journal | `01_manuscript/title_highlights_abstract_keywords.md` | Pending |
| Highlights | Main findings | `01_manuscript/title_highlights_abstract_keywords.md` | Pending |
| Abstract | Full results synthesis | `01_manuscript/title_highlights_abstract_keywords.md` | Pending |
| Introduction | Literature and research gap | `01_manuscript/manuscript_energy_reports_master.md` | Pending |
| Methods | Scripts and processing outputs | `02_scripts/` | Pending |
| Results | Figures and tables | `03_figures/`, `04_tables/` | Pending |
| Discussion | Physical interpretation of results | `05_results_summary/` | Pending |
| Conclusions | Main findings and implications | `01_manuscript/manuscript_energy_reports_master.md` | Pending |

---

## 7. Submission package traceability

| Submission component | Repository file | Status |
|---|---|---|
| Cover letter | `07_submission_package/cover_letter_draft.md` | Pending |
| Data availability statement | `07_submission_package/data_availability_statement.md` | Pending |
| Funding statement | `07_submission_package/funding_statement.md` | Pending |
| Competing interest statement | `07_submission_package/competing_interest_statement.md` | Pending |
| CRediT author statement | `07_submission_package/credit_author_statement.md` | Pending |
| Generative AI declaration | `07_submission_package/generative_ai_declaration.md` | Pending |
| Submission checklist | `00_editorial_strategy/submission_readiness_checklist.md` | Pending |

---

## 8. Reproducibility traceability

| Component | File | Purpose |
|---|---|---|
| Execution order | `08_reproducibility/execution_order.md` | Defines the script-running sequence |
| Software versions | `08_reproducibility/software_versions.md` | Documents R, RStudio and package versions |
| Data access notes | `08_reproducibility/data_access_notes.md` | Explains raw IDEAM data access |
| Session information | `08_reproducibility/session_info.txt` | Stores computational environment details |

---

## 9. TDQ control rule

No result should enter the manuscript unless it satisfies the following chain:

```text
Claim → Evidence file → Script/table/figure → Manuscript section → Editorial requirement
```

If a result cannot be traced, it should not be included in the submitted manuscript.

---

## 10. Current repository status

```text
Scientific core: completed
Figures: generated
Tables: generated
Repository structure: created
Compliance matrix: created
Traceability map: created
Manuscript: pending
Submission package: pending
```

---

## 11. Immediate next actions

1. Copy final R scripts into `02_scripts/`.
2. Copy final main figures into `03_figures/main_text/`.
3. Copy final supplementary figures into `03_figures/supplementary/`.
4. Copy final main tables into `04_tables/main_text/`.
5. Copy final supplementary tables into `04_tables/supplementary/`.
6. Create `submission_readiness_checklist.md`.
7. Create `article_scope_tdq.md`.
8. Create `execution_order.md`.
9. Create `data_access_notes.md`.
10. Start `title_highlights_abstract_keywords.md`.

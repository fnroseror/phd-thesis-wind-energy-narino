# Energy Reports Compliance Matrix — Article 01

## Article information

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  
**Current status:** Manuscript in preparation  
**Repository status:** Evidence consolidation in progress  

## TDQ principle

This matrix connects each journal requirement with:

1. the available evidence;
2. the repository location;
3. the manuscript section;
4. the current status;
5. the pending action.

The objective is to avoid blind manuscript writing and increase submission readiness through editorial traceability.

---

## 1. Journal compliance matrix

| Requirement | Energy Reports condition | Current evidence | Repository location | Manuscript location | Status | Pending action |
|---|---|---|---|---|---|---|
| Article type | Research Article, typically 5,000–7,000 words | Scientific core completed | `01_manuscript/` | Full manuscript | In progress | Draft full manuscript |
| Title | Clear and informative | Provisional title defined | `01_manuscript/title_highlights_abstract_keywords.md` | Title page | Draft | Refine final title |
| Abstract | Concise abstract | Results already available | `01_manuscript/title_highlights_abstract_keywords.md` | Abstract | Pending | Draft <=250 words |
| Keywords | 1–7 keywords | Candidate keywords defined | `01_manuscript/title_highlights_abstract_keywords.md` | Keywords | Pending | Select final 5–7 keywords |
| Highlights | 3–5 highlights, separate editable file | Main findings identified | `01_manuscript/title_highlights_abstract_keywords.md` | Separate file | Pending | Draft 3–5 highlights |
| Graphical abstract | Recommended, separate file | Concept pending | `01_manuscript/graphical_abstract/` | Submission file | Optional | Design non-AI graphical abstract |
| SI units | Use SI units consistently | VV, WPD and rho already expressed in SI | Manuscript and figures | Methods/results | In progress | Review all units |
| Equations | Editable equations | WPD equation defined | `01_manuscript/` | Methods | Pending | Insert WPD and air-density equations |
| Tables | Editable tables, not images | XLSX outputs generated | `04_tables/main_text/` and `04_tables/supplementary/` | Tables 1–4 | In progress | Select final tables |
| Figures | Separate figure files | Publication-ready figures generated in R | `03_figures/main_text/` and `03_figures/supplementary/` | Figures 1–8 | In progress | Move final figures |
| Captions | Captions required for all figures | Draft captions available | `01_manuscript/figure_captions.md` | Figure captions | Pending | Finalize captions |
| Supplementary material | Must be relevant and cited | QC, PACF, delta AIC/BIC, FFT support | `06_supplementary_material/` | Supplementary section | In progress | Build supplementary index |
| Data availability | Data statement required | Raw IDEAM data + derived outputs | `07_submission_package/data_availability_statement.md` | Data availability statement | Pending | Define raw-data sharing limits |
| Competing interests | Declaration required | Draft statement pending | `07_submission_package/competing_interest_statement.md` | Declarations | Pending | Confirm with authors |
| Funding | Funding statement required | Draft statement pending | `07_submission_package/funding_statement.md` | Declarations | Pending | Confirm funding status |
| Generative AI declaration | Required if AI-assisted writing was used | Draft declaration needed | `07_submission_package/generative_ai_declaration.md` | Before references | Pending | Declare editorial assistance only |
| CRediT statement | Author roles should be defined | Roles pending | `07_submission_package/credit_author_statement.md` | Declarations | Pending | Confirm author list and roles |
| Cover letter | Required/recommended for submission | Draft pending | `07_submission_package/cover_letter_draft.md` | Submission package | Pending | Draft after manuscript |
| References | Complete and consistent | Reference list pending | `01_manuscript/references_pending.md` | References | Pending | Build verified reference list |

---

## 2. Scientific evidence already generated

| Evidence block | Core result | Repository destination | Manuscript use | Status |
|---|---|---|---|---|
| Datetime validation | Correct DMY parser; real period 2017–2022 | `02_scripts/00C_datetime_parser_validation.R` | Study area / preprocessing | Completed |
| Density strategy | Daily zone-level air density selected | `02_scripts/01D_density_overlap_strategy.R` | Methods | Completed |
| Quality control | Main scenario: VV <= 20 m s^-1 | `02_scripts/02E_quality_control_daily_density_wpd.R` | Methods / Supplementary | Completed |
| Final WPD dataset | QC dataset generated | `01_data_processed/` | Results | Completed |
| Descriptive analysis | Zonal VV and WPD statistics | `04_tables/main_text/` | Results | Completed |
| Distribution fitting | Weibull vs Rayleigh by zone | `02_scripts/05H_distribution_and_publication_figures.R` | Results | Completed |
| Temporal dependence | ACF/PACF by zone | `02_scripts/06I_acf_pacf_temporal_dependence.R` | Results / Supplementary | Completed |
| Spectral analysis | FFT spectral bands by zone | `02_scripts/07J_fft_spectral_analysis.R` | Results / Discussion | Completed |
| Publication-ready figures | Main and supplementary figures | `03_figures/` | Results | In progress |
| Editable tables | Main and supplementary tables | `04_tables/` | Results / Supplementary | In progress |

---

## 3. Proposed main manuscript figures

| Figure | Description | Destination | Status |
|---|---|---|---|
| Figure 1 | Monthly mean wind speed by zone | Main text | Generated |
| Figure 2 | Monthly mean WPD by zone | Main text | Generated |
| Figure 3 | Wind-speed distribution by zone | Main text | Generated |
| Figure 4 | WPD distribution by zone | Main text | Generated |
| Figure 5 | Weibull/Rayleigh density fits | Main text | Generated |
| Figure 6 | Weibull/Rayleigh CDF fits | Main text | Generated |
| Figure 7 | Daily WPD ACF by zone | Main text | Generated |
| Figure 8 | WPD FFT spectral band energy | Main text | Generated |

---

## 4. Proposed supplementary figures

| Figure | Description | Destination | Status |
|---|---|---|---|
| Figure S1 | QC sensitivity of mean WPD | Supplementary | Generated |
| Figure S2 | Delta AIC/BIC Weibull vs Rayleigh | Supplementary | Generated |
| Figure S3 | Daily WPD PACF by zone | Supplementary | Generated |
| Figure S4 | Daily VV ACF/PACF support | Supplementary | Generated |
| Figure S5 | Raw FFT spectrum of WPD/VV | Supplementary | Generated |

---

## 5. Proposed main tables

| Table | Description | Destination | Status |
|---|---|---|---|
| Table 1 | Dataset, stations, zones and temporal coverage | Main text | Pending consolidation |
| Table 2 | Descriptive statistics of VV and WPD by zone | Main text | Pending consolidation |
| Table 3 | Weibull/Rayleigh parameters and goodness-of-fit metrics | Main text | Generated |
| Table 4 | Temporal and spectral summary by zone | Main text | Pending consolidation |

---

## 6. TDQ editorial decision

No additional analyses should be added unless a clear reviewer-relevant gap is identified.

The priority is now:

1. consolidate repository evidence;
2. organize figures and tables;
3. write the manuscript;
4. prepare the submission package.

---

## 7. Immediate pending actions

- [ ] Update `README.md` from concept note to manuscript-preparation status.
- [ ] Add `.gitkeep` files to empty `03_figures/` and `04_tables/` folders.
- [ ] Move final figures into `03_figures/main_text/` and `03_figures/supplementary/`.
- [ ] Move final tables into `04_tables/main_text/` and `04_tables/supplementary/`.
- [ ] Create `title_highlights_abstract_keywords.md`.
- [ ] Create `figure_captions.md`.
- [ ] Create `data_availability_statement.md`.
- [ ] Create declaration files.
- [ ] Start manuscript master file.

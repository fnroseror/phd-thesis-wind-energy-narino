# Submission Readiness Checklist — Article 01 Energy Reports

## Purpose

This checklist controls the editorial, scientific and reproducibility readiness of Article 01 before submission to Energy Reports.

The objective is to ensure that the manuscript is not submitted until the scientific evidence, repository organization and editorial files are complete.

---

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  
**Current phase:** Manuscript construction and repository consolidation  

---

## 1. Scientific readiness

- [x] Corrected datetime parser validated.
- [x] Real study period identified.
- [x] Meteorological variables standardized.
- [x] Analytical zones defined.
- [x] Daily zone-level air density strategy selected.
- [x] Wind power density calculated.
- [x] Quality-control scenario selected.
- [x] Final WPD dataset generated.
- [x] Weibull/Rayleigh distribution fitting completed.
- [x] ACF/PACF temporal dependence analysis completed.
- [x] FFT spectral analysis completed.
- [ ] Main scientific results summarized in text.
- [ ] Discussion structured around physical interpretation.
- [ ] Limitations clearly stated.
- [ ] Conclusions aligned with results.

---

## 2. Repository readiness

- [x] Article-specific folder created.
- [x] Editorial strategy folder created.
- [x] Manuscript folder created.
- [x] Scripts folder created.
- [ ] Main figure folder visible in GitHub.
- [ ] Supplementary figure folder visible in GitHub.
- [ ] Main table folder visible in GitHub.
- [ ] Supplementary table folder visible in GitHub.
- [x] Results summary folder created.
- [x] Supplementary material folder created.
- [x] Submission package folder created.
- [x] Reproducibility folder created.
- [x] Compliance matrix created.
- [x] Traceability map created.
- [ ] Execution order file created.
- [ ] Data access notes created.
- [ ] Software versions file created.
- [ ] Session information file added.
- [ ] Final scripts copied into `02_scripts/`.
- [ ] Final figures copied into `03_figures/`.
- [ ] Final tables copied into `04_tables/`.

---

## 3. Manuscript readiness

- [ ] Final title selected.
- [ ] Highlights drafted.
- [ ] Abstract drafted.
- [ ] Keywords selected.
- [ ] Introduction drafted.
- [ ] Study area and data section drafted.
- [ ] Methodology section drafted.
- [ ] Results section drafted.
- [ ] Discussion section drafted.
- [ ] Conclusions drafted.
- [ ] Figure captions drafted.
- [ ] Table captions drafted.
- [ ] References added.
- [ ] All in-text citations checked.
- [ ] All references cross-checked.
- [ ] Grammar and language reviewed.
- [ ] Word count checked.

---

## 4. Energy Reports editorial readiness

- [ ] Manuscript prepared as editable file.
- [ ] Abstract below 250 words.
- [ ] 1–7 keywords included.
- [ ] 3–5 highlights included.
- [ ] Each highlight below 85 characters.
- [ ] Figure files prepared separately.
- [ ] Tables prepared as editable text or Excel/Word tables.
- [ ] Figure captions included.
- [ ] Table titles and footnotes included.
- [ ] Supplementary material prepared.
- [ ] Data availability statement prepared.
- [ ] Competing interest statement prepared.
- [ ] Funding statement prepared.
- [ ] CRediT author statement prepared.
- [ ] Generative AI declaration prepared.
- [ ] Cover letter prepared.
- [ ] Corresponding author information ready.
- [ ] All author affiliations verified.

---

## 5. Figure readiness

### Main figures

- [ ] Figure 1 — Monthly mean wind speed by zone.
- [ ] Figure 2 — Monthly mean WPD by zone.
- [ ] Figure 3 — Wind-speed distribution by zone.
- [ ] Figure 4 — WPD distribution by zone.
- [ ] Figure 5 — Weibull/Rayleigh density fits.
- [ ] Figure 6 — Weibull/Rayleigh CDF fits.
- [ ] Figure 7 — Daily WPD ACF by zone.
- [ ] Figure 8 — WPD spectral band energy by zone.

### Supplementary figures

- [ ] Figure S1 — QC sensitivity.
- [ ] Figure S2 — Delta AIC/BIC Weibull vs Rayleigh.
- [ ] Figure S3 — Daily WPD PACF by zone.
- [ ] Figure S4 — Daily VV ACF/PACF support.
- [ ] Figure S5 — Raw FFT spectrum support.

---

## 6. Table readiness

### Main tables

- [ ] Table 1 — Dataset, stations, zones and temporal coverage.
- [ ] Table 2 — Descriptive statistics of VV and WPD by zone.
- [ ] Table 3 — Weibull/Rayleigh parameters and goodness-of-fit metrics.
- [ ] Table 4 — Temporal and spectral summary by zone.

### Supplementary tables

- [ ] Supplementary table for quality-control scenarios.
- [ ] Supplementary table for full Weibull/Rayleigh metrics.
- [ ] Supplementary table for ACF/PACF values.
- [ ] Supplementary table for FFT top periods.
- [ ] Supplementary table for FFT spectral band energy.

---

## 7. Data and reproducibility readiness

- [ ] Raw data source clearly identified.
- [ ] Raw data redistribution decision documented.
- [ ] Data availability statement finalized.
- [ ] Derived datasets documented.
- [ ] Scripts executable in defined order.
- [ ] Required R packages listed.
- [ ] Session information saved.
- [ ] Figures reproducible from scripts.
- [ ] Tables reproducible from scripts.
- [ ] Repository structure understandable to an external reviewer.

---

## 8. Ethical and editorial declarations

- [ ] Authorship confirmed.
- [ ] CRediT roles confirmed.
- [ ] Funding statement confirmed.
- [ ] Competing interest statement confirmed.
- [ ] Generative AI declaration confirmed.
- [ ] No generative-AI figure/artwork used.
- [ ] Raw data rights and redistribution conditions reviewed.
- [ ] No copyrighted third-party figures used without permission.

---

## 9. Final TDQ submission rule

The article can be considered ready for submission only when the following five blocks are complete:

```text
1. Scientific evidence complete
2. Repository traceability complete
3. Manuscript complete
4. Supplementary material complete
5. Submission package complete
```

---

## 10. Current readiness estimate

```text
Scientific core:        90 %
Figures:                85–90 %
Tables:                 80–85 %
Repository:             45–55 %
Manuscript:             25–30 %
Submission package:     20–25 %
Overall submission:     60–65 %
```

---

## 11. Immediate next actions

1. Add `.gitkeep` or README files to empty figure and table folders.
2. Copy final R scripts into `02_scripts/`.
3. Copy final main figures into `03_figures/main_text/`.
4. Copy final supplementary figures into `03_figures/supplementary/`.
5. Copy final main tables into `04_tables/main_text/`.
6. Copy final supplementary tables into `04_tables/supplementary/`.
7. Create `title_highlights_abstract_keywords.md`.
8. Start the manuscript master file.

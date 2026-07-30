# Main Results Summary — Article 01 Energy Reports

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  
**Current phase:** Manuscript construction and repository consolidation  

---

## Purpose

This file summarizes the main scientific results of Article 01.

The objective is to provide a concise evidence-based synthesis that supports the manuscript Results, Discussion, Abstract, Highlights and Conclusions.

---

## 1. Corrected dataset and temporal validation

The datetime validation process confirmed that the correct date structure of the meteorological records follows the DMY format.

The corrected study period corresponds to:

```text
2017–2022
```

The corrected temporal structure avoids misinterpretation of seasonal, autocorrelation and spectral analyses.

---

## 2. Final WPD estimation strategy

Wind Power Density was estimated using wind speed and air density:

```text
WPD = 0.5 * rho * v^3
```

Because exact hourly overlap among wind speed, pressure and temperature records was limited, different air-density strategies were evaluated.

The selected strategy was:

```text
Daily zone-level air density
```

This strategy was selected because it preserves physical dependence on local air-density variation while retaining a substantially larger proportion of usable wind-speed records than exact hourly matching.

---

## 3. Quality-control decision

The main quality-control criterion selected for the article was:

```text
VV <= 20 m s^-1
```

This threshold was selected to reduce the effect of extreme wind-speed values that can disproportionately inflate WPD due to the cubic dependence on wind speed.

The final article-level dataset after quality control contained:

```text
137,484 records
```

The quality-control strategy retained approximately:

```text
99.7562 % of the candidate WPD dataset
```

This indicates that the QC process removed only a small fraction of extreme values while preserving the dominant data structure.

---

## 4. Main zonal WPD result

The main energetic contrast was observed across analytical zones.

Zone 1 showed the highest mean WPD:

```text
Zone 1 mean WPD: approximately 140.76 W m^-2
```

The remaining zones showed lower mean WPD values:

```text
Zone 2 mean WPD: approximately 15.82 W m^-2
Zone 3 mean WPD: approximately 12.96 W m^-2
Zone 4 mean WPD: approximately 16.95 W m^-2
```

This result indicates that the wind-energy signal is spatially heterogeneous and that regional averages would hide important zonal differences.

---

## 5. Physical interpretation of Zone 1

Zone 1 does not simply represent a uniformly stronger wind regime.

Instead, it shows a more intermittent energetic behavior, where relatively infrequent high-wind events generate a strong contribution to mean WPD because of the cubic relationship:

```text
WPD ∝ v^3
```

Therefore, Zone 1 is characterized by:

```text
High energetic contribution
Strong asymmetry
Intermittent wind-energy behavior
Relevant high-WPD events
```

This makes Zone 1 the most important analytical zone for interpreting regional wind-energy potential.

---

## 6. Weibull/Rayleigh distributional result

Weibull and Rayleigh distributions were fitted to wind-speed data by analytical zone.

The main result was:

```text
Weibull outperformed Rayleigh in all analytical zones.
```

This indicates that the additional flexibility of the Weibull distribution is required to represent the observed wind-speed regimes.

The Weibull shape parameters supported the physical interpretation:

```text
Zone 1: k < 1
Zones 2–4: k close to 2
```

Interpretation:

```text
Zone 1: highly asymmetric and intermittent wind-speed regime.
Zones 2–4: more regular regimes, closer to Rayleigh-like behavior, but still better represented by Weibull.
```

---

## 7. Temporal dependence result

The ACF analysis revealed that daily WPD is not purely random or independent.

The main ACF lag-1 values were approximately:

```text
Zone 1: 0.884
Zone 2: 0.862
Zone 3: 0.757
Zone 4: 0.575
```

This shows relevant short-term temporal persistence across zones.

The first lag where absolute ACF dropped below 0.2 showed different memory structures:

```text
Zone 1: did not fall below 0.2 within the 90-day lag window
Zone 2: approximately lag 54
Zone 3: approximately lag 22
Zone 4: approximately lag 13
```

This suggests that Zone 1 has the strongest and longest temporal memory in WPD.

---

## 8. PACF result

The PACF analysis showed that most direct temporal dependence was concentrated at the first lag.

Approximate PACF lag-1 values were:

```text
Zone 1: 0.884
Zone 2: 0.862
Zone 3: 0.757
Zone 4: 0.575
```

After the first lag, partial autocorrelation decreased quickly.

Interpretation:

```text
Daily WPD has a strong immediate autoregressive component.
Longer persistence observed in the ACF is partly mediated through short-lag dependence.
```

This supports the use of temporal models in future forecasting-oriented research.

---

## 9. FFT spectral result

FFT-based spectral analysis revealed distinct temporal-energy regimes across analytical zones.

The strongest result was observed in Zone 1:

```text
Zone 1: dominant low-frequency WPD variability
```

A large proportion of Zone 1 WPD spectral power was concentrated in periods longer than 365 days.

Interpretation:

```text
Zone 1 is not dominated only by short-term noise.
It presents a structured low-frequency energetic regime.
```

Other zones showed more distributed spectral behavior:

```text
Zone 2: seasonal and low-frequency structure.
Zone 3: more balanced contribution across short-term, intra-monthly and seasonal bands.
Zone 4: stronger short-period contribution, but interpretation requires caution due to lower temporal coverage.
```

---

## 10. Main methodological contribution

The methodological contribution of the article is the integration of:

```text
1. corrected datetime validation;
2. daily zone-level air-density-supported WPD estimation;
3. quality-controlled wind-speed and WPD analysis;
4. Weibull/Rayleigh distributional modeling;
5. ACF/PACF temporal-dependence analysis;
6. FFT spectral-band interpretation;
7. reproducible computational documentation.
```

This combination allows WPD to be interpreted not only as a statistical variable but as a physically meaningful energy descriptor.

---

## 11. Main scientific message

The central scientific message of the article is:

```text
Wind-energy assessment in complex Andean terrain should not rely only on average wind speed. Wind power density, supported by air-density estimation, distributional modeling, temporal persistence and spectral structure, provides a stronger physical-statistical basis for characterizing regional wind-energy potential.
```

---

## 12. Results for Abstract

The abstract should protect the following results:

```text
1. WPD was estimated using wind speed and daily zone-level air density.
2. The final QC dataset retained 137,484 records.
3. Zone 1 showed the highest and most intermittent WPD regime.
4. Weibull outperformed Rayleigh in all zones.
5. ACF/PACF revealed temporal persistence in daily WPD.
6. FFT identified distinct temporal-energy regimes across zones.
7. WPD provides a stronger physical descriptor than wind speed alone.
```

---

## 13. Results for Discussion

The Discussion should emphasize:

```text
1. Zone 1 dominance is caused by energetic intermittency, not only high average wind speed.
2. WPD reveals stronger regional contrast than wind-speed-only analysis.
3. Daily zone-level air density is a practical solution under limited hourly variable overlap.
4. Weibull flexibility is necessary in complex terrain.
5. ACF/PACF and FFT show that WPD has temporal structure.
6. The article is a characterization study, not a turbine-level feasibility study.
7. The framework can support future forecasting, micrositing or energy-planning studies.
```

---

## 14. Results for Conclusions

The Conclusions should include:

```text
1. WPD is a physically stronger descriptor of wind-energy potential than wind speed alone.
2. Daily zone-level air density provides a defensible WPD estimation strategy.
3. The QC criterion preserves the dataset while controlling extreme cubic amplification.
4. Zone 1 is the dominant wind-energy zone.
5. Weibull is the preferred distributional model.
6. Daily WPD has relevant temporal persistence.
7. FFT reveals distinct temporal-energy regimes.
8. The workflow is reproducible and suitable for complex-terrain wind-energy assessment.
```

---

## 15. Limitations to acknowledge

The following limitations must be stated clearly:

```text
1. The study characterizes regional WPD, not turbine-level production.
2. It does not perform micrositing, CFD simulation or wind-farm design.
3. Daily zone-level air density is a practical approximation under limited exact hourly overlap.
4. Zone 4 temporal and spectral results require caution due to lower coverage.
5. Forecasting models are not part of Article 01 and should be developed separately.
```

---

## 16. TDQ interpretation

The article should remain focused on:

```text
Physical-statistical WPD characterization
Complex Andean terrain
Observed meteorological data
Distributional analysis
Temporal persistence
Spectral structure
Reproducibility
```

The article should not expand toward:

```text
TDQ theory
Turbine production
Economic feasibility
Wind-farm design
Forecasting models
Policy prescription beyond evidence
```

---

## 17. Current result status

```text
Datetime validation: completed
Density strategy: completed
Quality control: completed
Final WPD dataset: completed
Descriptive results: completed
Weibull/Rayleigh fitting: completed
ACF/PACF analysis: completed
FFT analysis: completed
Main result synthesis: drafted
Manuscript integration: in progress
```

---

## 18. Immediate next actions

1. Create `distribution_results_summary.md`.
2. Create `temporal_results_summary.md`.
3. Create `spectral_results_summary.md`.
4. Copy final figures into `03_figures/main_text/` and `03_figures/supplementary/`.
5. Copy final tables into `04_tables/main_text/` and `04_tables/supplementary/`.
6. Refine manuscript Results section with exact numerical values.
7. Add verified references.

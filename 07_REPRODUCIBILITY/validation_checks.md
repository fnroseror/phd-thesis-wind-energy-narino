# Validation Checks

## Purpose

This document defines the minimum validation checks required to support the computational reproducibility of the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The purpose of this file is to document the checks that should be performed before, during, and after the computational workflow to verify that the data, code outputs, physical variables, predictive results, uncertainty intervals, FNRR values, energy estimates, figures, and tables remain coherent with the thesis.

This file supports the reproducibility layer of the repository:

```text
07_REPRODUCIBILITY/
```

and should be read together with:

```text
07_REPRODUCIBILITY/data_contract.md
07_REPRODUCIBILITY/execution_pipeline.md
07_REPRODUCIBILITY/software_versions.md
07_REPRODUCIBILITY/sessionInfo.txt
05_APPENDICES_SUPPORT/Anexo_H_Reproducibilidad_Computacional.md
```

---

## 1. Validation philosophy

Validation is not only a technical step.

In this repository, validation means verifying that the computational workflow preserves scientific, physical, statistical, and documentary coherence.

The validation principle is:

```text
A result is reproducible only if its data structure, physical meaning,
computational origin, numerical behavior, output location, and thesis interpretation
remain coherent.
```

The checks in this file are intended to reduce silent errors and protect the repository from inconsistencies.

---

## 2. Validation levels

Validation should be performed at multiple levels:

```text
data structure
metadata consistency
physical admissibility
derived-variable construction
model-output coherence
uncertainty-output coherence
FNRR coherence
energy-output coherence
figure/table consistency
repository-location consistency
documentation consistency
```

Each level supports a different part of the doctoral workflow.

---

## 3. Data-structure validation

The input dataset should contain the minimum required columns defined in:

```text
07_REPRODUCIBILITY/data_contract.md
```

Minimum required columns:

```text
Estación
FechaYHora
Valor
Zona
Variable
```

Validation checks:

```text
[ ] Column Estación exists.
[ ] Column FechaYHora exists.
[ ] Column Valor exists.
[ ] Column Zona exists.
[ ] Column Variable exists.
[ ] No required column is completely empty.
[ ] Column names are consistent with the expected structure.
```

If the dataset does not satisfy these checks, the computational workflow should not proceed without correction or documentation.

---

## 4. Date-time validation

The field:

```text
FechaYHora
```

must be parsable as a date-time variable.

Validation checks:

```text
[ ] FechaYHora is successfully parsed as date-time.
[ ] No invalid date strings remain after parsing.
[ ] Temporal order can be reconstructed.
[ ] Records fall within the intended doctoral study period.
[ ] Duplicated date-time records are identified and interpreted.
[ ] Temporal resolution is documented.
```

Recommended interpretation:

```text
Temporal errors affect time-series analysis, forecasting, spectral analysis,
uncertainty estimation, and energy projection.
```

---

## 5. Variable-code validation

The variable codes should match the official variable dictionary documented in:

```text
02_DATA_METADATA/02_variable_dictionary.md
```

Expected variable codes include:

```text
VV
DV
Tmin
Tmax
PA
HR
EV
NU
PR
FA
```

Validation checks:

```text
[ ] All variable codes are recognized.
[ ] No undocumented variable aliases remain.
[ ] Temperature labels are normalized when necessary.
[ ] Historical aliases such as TM or Tm are documented before use.
[ ] Variable names match the metadata file.
```

If alternative labels appear, they should be mapped explicitly before analysis.

---

## 6. Station validation

Station names or identifiers must remain consistent across the dataset.

Validation checks:

```text
[ ] Each observation has a station identifier.
[ ] Station names are not duplicated due to spelling variations.
[ ] Station names match the metadata record.
[ ] Station labels are stable across the analysis.
[ ] Station information can be linked to an analytical zone.
```

Station and zone documentation:

```text
02_DATA_METADATA/03_station_zone_mapping.md
```

---

## 7. Zone validation

Each observation should be assigned to one analytical zone.

Expected zones:

```text
1
2
3
4
```

or equivalent labels:

```text
Z1
Z2
Z3
Z4
```

Validation checks:

```text
[ ] Each station has an assigned zone.
[ ] No observation has a missing zone.
[ ] No observation belongs to an undocumented zone.
[ ] The station-zone mapping is stable.
[ ] All four analytical zones are represented when required by the analysis.
```

---

## 8. Numeric-value validation

The field:

```text
Valor
```

must be numeric for quantitative variables.

Validation checks:

```text
[ ] Valor can be parsed as numeric.
[ ] Non-numeric text values are identified.
[ ] Missing values are counted.
[ ] NaN values are identified.
[ ] Infinite values are identified.
[ ] Extreme values are flagged for review.
[ ] Non-physical values are documented before treatment.
```

Diagnostic categories:

```text
NA
NaN
Inf
-Inf
non-numeric text
outliers
non-physical values
```

These categories should not be deleted silently.

---

## 9. Physical-admissibility validation

The dataset should satisfy basic physical-admissibility conditions.

Minimum expectations:

| Variable | Expected condition |
|---|---|
| `VV` | Wind speed should be nonnegative. |
| `PA` | Atmospheric pressure should be positive. |
| `Tmin`, `Tmax` | Temperature should be physically plausible. |
| `HR` | Relative humidity should remain within interpretable limits. |
| `PR` | Precipitation should be nonnegative. |
| `EV` | Evaporation should be nonnegative when applicable. |

Validation checks:

```text
[ ] Negative wind-speed values are identified.
[ ] Invalid pressure values are identified.
[ ] Implausible temperature values are identified.
[ ] Invalid precipitation values are identified.
[ ] Invalid evaporation values are identified.
[ ] Treatment of non-physical values is documented.
```

---

## 10. Missing-data validation

Missing data should be quantified and documented.

Validation checks:

```text
[ ] Missing values are counted by variable.
[ ] Missing values are counted by station.
[ ] Missing values are counted by zone.
[ ] Missing values are counted by period.
[ ] Missing-value treatment is documented.
[ ] No imputation or filtering is applied without traceability.
```

Related documentation:

```text
02_DATA_METADATA/04_data_processing_notes.md
05_APPENDICES_SUPPORT/Anexo_B_Preprocesamiento_y_Trazabilidad.md
```

---

## 11. Zero-value validation

Zero values must be interpreted according to the variable.

Validation checks:

```text
[ ] Zero wind speed is interpreted as possible calm wind.
[ ] Zero precipitation is interpreted as possible no-rain condition.
[ ] Zero evaporation is interpreted according to the variable context.
[ ] Zero values are not automatically treated as missing.
[ ] Variable-specific interpretation is documented.
```

---

## 12. Unit validation

Units must be coherent before physical calculations.

Validation checks:

```text
[ ] Wind speed is expressed in m/s or converted before WPD calculation.
[ ] Atmospheric pressure is expressed in Pa or converted when used for air density.
[ ] Temperature is expressed in °C or K with conversion documented.
[ ] Temperature conversion to Kelvin is correct when required.
[ ] WPD output is expressed in W/m².
[ ] Energy-related units are documented.
```

The WPD calculation requires:

```text
v in m/s
ρ in kg/m³
WPD in W/m²
```

---

## 13. Air-density validation

If air density is computed, the implementation should be physically coherent.

Expected relation:

```text
ρ = p / (R_d · T_K)
```

Validation checks:

```text
[ ] Pressure input is available.
[ ] Temperature input is available.
[ ] Temperature is converted to Kelvin when required.
[ ] Air density is positive under valid inputs.
[ ] Implausible air-density values are reviewed.
[ ] Air-density assumptions are documented.
```

---

## 14. WPD validation

Wind Power Density is defined as:

```text
WPD = 0.5 · ρ · v³
```

Validation checks:

```text
[ ] Wind speed is available.
[ ] Air density is available or computable.
[ ] Wind speed is nonnegative.
[ ] Air density is positive.
[ ] WPD is nonnegative.
[ ] WPD units are documented.
[ ] WPD values are linked to station, zone, and time.
```

Expected condition:

```text
WPD ≥ 0
```

when inputs are physically valid.

---

## 15. Physical-characterization validation

Physical-characterization outputs should be aligned with Chapter 2.

Expected output folder:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
```

Expected figure folder:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
```

Expected table folder:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
```

Validation checks:

```text
[ ] Descriptive statistics outputs exist.
[ ] Weibull parameter outputs exist when reported.
[ ] Weibull versus Rayleigh comparison outputs exist when reported.
[ ] ACF/PACF figures or outputs exist when reported.
[ ] FFT figures or outputs exist when reported.
[ ] Wavelet figures or outputs exist when reported.
[ ] Outputs are consistent with Chapter 2 interpretation.
```

---

## 16. Model-output validation

Model outputs should preserve model, target, zone, and horizon information.

Expected output folders:

```text
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
```

Validation checks:

```text
[ ] Model name is documented.
[ ] Target variable is documented.
[ ] Zone is documented.
[ ] Horizon is documented.
[ ] Observed values are included where required.
[ ] Predicted values are included where required.
[ ] Error metrics are included where required.
[ ] Persistence benchmark is included when Skill Score is reported.
```

---

## 17. Metric validation

The main metrics may include:

```text
RMSE
MAE
R²
Skill Score
```

Validation checks:

```text
[ ] RMSE values are nonnegative.
[ ] MAE values are nonnegative.
[ ] R² values are interpreted cautiously.
[ ] Skill Score is computed against the correct persistence benchmark.
[ ] Metric definitions are consistent across model families.
[ ] Metrics are not mixed across incompatible targets or horizons.
```

Recommended interpretation:

```text
Model performance should be interpreted through metrics, horizon,
zone, target variable, and persistence comparison.
```

---

## 18. Persistence-benchmark validation

Persistence is used as a key benchmark.

Conceptual form:

```text
Ŷ_persistence(t+h) = Y(t)
```

Validation checks:

```text
[ ] Persistence benchmark is defined.
[ ] Persistence benchmark uses the correct target variable.
[ ] Persistence benchmark uses the correct horizon.
[ ] Skill Score is computed against persistence.
[ ] Model improvement over persistence is not assumed without metric evidence.
```

---

## 19. PI90 validation

PI90 uncertainty outputs should contain lower and upper interval bounds.

Expected output folder:

```text
04_RESULTS_COMPLETE/03_pi90_uncertainty/
```

Validation checks:

```text
[ ] Lower interval bound exists.
[ ] Upper interval bound exists.
[ ] Lower bound is less than or equal to upper bound.
[ ] Observed value is available when coverage is computed.
[ ] Predicted value is available when required.
[ ] Coverage indicator is computed when reported.
[ ] Empirical coverage is interpreted correctly.
```

Expected condition:

```text
lower_PI90 ≤ upper_PI90
```

Coverage interpretation:

```text
Coverage_PI90 ≈ 0.90
```

when calibrated.

---

## 20. FNRR validation

FNRR is defined as:

```text
FNRR_z(T) = [Q_75,z(T) − Q_25,z(T)] / [Q_75,z(T) + Q_25,z(T) + ε_z]
```

Expected output folder:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
```

Validation checks:

```text
[ ] WPD input is available.
[ ] Zone is defined.
[ ] Temporal window is defined.
[ ] Q25 is computed.
[ ] Q75 is computed.
[ ] IQR is computed as Q75 − Q25.
[ ] ε_z is positive.
[ ] ε_z has the same physical unit as WPD.
[ ] FNRR is dimensionless.
[ ] FNRR is within the expected bounds.
```

Expected condition:

```text
0 ≤ FNRR_z(T) < 1
```

under the assumptions documented in Appendix G.

---

## 21. Energy-output validation

Energy outputs should preserve the relationship between free energy and usable energy.

Expected output folder:

```text
04_RESULTS_COMPLETE/05_energy_projection/
```

Core relation:

```text
E_usable = (1 − FNRR) · E_free
```

Validation checks:

```text
[ ] E_free is nonnegative.
[ ] FNRR is within expected bounds.
[ ] E_usable is nonnegative.
[ ] E_usable does not exceed E_free.
[ ] Energy-output units are documented.
[ ] Projection period is documented.
[ ] Projection outputs are interpreted as model-based scenarios.
```

Expected condition:

```text
0 ≤ E_usable ≤ E_free
```

---

## 22. Figure validation

Figures should be stored in:

```text
04_RESULTS_COMPLETE/07_FIGURES/
```

Expected structure:

```text
chapter_2/
chapter_3/
chapter_4/
```

Validation checks:

```text
[ ] Chapter 2 figures are stored in chapter_2.
[ ] Chapter 3 figures are stored in chapter_3.
[ ] Chapter 4 figures are stored in chapter_4.
[ ] Figure names are descriptive.
[ ] Figure content matches its file name.
[ ] Figures referenced in the thesis or appendices exist.
[ ] Figures are not duplicated unnecessarily.
```

---

## 23. Table validation

Tables should be stored in:

```text
04_RESULTS_COMPLETE/08_TABLES/
```

Expected structure:

```text
chapter_2/
chapter_3/
chapter_4/
```

Validation checks:

```text
[ ] Chapter 2 tables are stored in chapter_2.
[ ] Chapter 3 tables are stored in chapter_3.
[ ] Chapter 4 tables are stored in chapter_4.
[ ] Table names are descriptive.
[ ] Tables contain expected columns.
[ ] Tables referenced in the thesis or appendices exist.
[ ] Tables are not duplicated unnecessarily.
```

---

## 24. Appendix consistency validation

Appendix files should remain consistent with repository evidence.

Key appendix folder:

```text
05_APPENDICES_SUPPORT/
```

Validation checks:

```text
[ ] Appendix A matches data and station-zone documentation.
[ ] Appendix B matches preprocessing and traceability decisions.
[ ] Appendix C matches experimental configuration.
[ ] Appendix D matches Chapter 2 extended results.
[ ] Appendix E matches Chapter 3 extended results.
[ ] Appendix F matches Chapter 4 extended results.
[ ] Appendix G matches the final physical and mathematical formulation.
[ ] Appendix H matches the final reproducibility structure.
```

---

## 25. Product-folder validation

Product folders are located in:

```text
06_PRODUCTS/
```

Validation checks:

```text
[ ] Article concept notes are clearly labeled as concept notes.
[ ] Patent material is labeled as preliminary and non-confidential.
[ ] Book material is labeled as outline or conceptual development.
[ ] Dashboard scope is documented honestly.
[ ] Presentation certificates are organized.
[ ] Directed-thesis evidence is uploaded and documented.
[ ] Professorial-project evidence is uploaded and documented.
```

Products should not be confused with the core evidence required to reproduce thesis results.

---

## 26. Documentation validation

The repository documentation should be internally consistent.

Validation checks:

```text
[ ] README.md reflects the final repository structure.
[ ] Folder names match documentation.
[ ] Old folder names are removed or explained.
[ ] Internal labels are interpreted cautiously.
[ ] Data availability limitations are documented.
[ ] Reproducibility limitations are documented.
[ ] No unsupported claims are introduced.
```

---

## 27. Internal-label validation

Some repository files may contain internal labels such as:

```text
TDQ
PIESS
BAYES
ML
DL
WPD
Eh
FNRR
PI90
ELSEVIER
NATURE
ANEXO
```

Validation checks:

```text
[ ] Internal labels are not overinterpreted.
[ ] TDQ is not presented as the central proof of the thesis.
[ ] PIESS is interpreted only where documented.
[ ] BAYES is linked to optimization only where applicable.
[ ] ELSEVIER or NATURE labels are not interpreted as submission claims.
[ ] Formal thesis language is prioritized.
```

Recommended formal language:

```text
physical characterization
Wind Power Density
predictive modeling
uncertainty quantification
FNRR
free energy
usable energy
regional energy projection
```

---

## 28. Repository-structure validation

The final repository structure should be:

```text
01_THESIS/
02_DATA_METADATA/
03_CODE/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/
06_PRODUCTS/
07_REPRODUCIBILITY/
README.md
```

Validation checks:

```text
[ ] Main README reflects this structure.
[ ] Results are stored in 04_RESULTS_COMPLETE.
[ ] Figures are inside 04_RESULTS_COMPLETE/07_FIGURES.
[ ] Tables are inside 04_RESULTS_COMPLETE/08_TABLES.
[ ] Appendices are inside 05_APPENDICES_SUPPORT.
[ ] Products are inside 06_PRODUCTS.
[ ] Reproducibility files are inside 07_REPRODUCIBILITY.
```

---

## 29. Minimum final validation checklist

Before considering the repository closed, confirm:

```text
[ ] Main README updated.
[ ] 01_THESIS documented.
[ ] 02_DATA_METADATA documented.
[ ] 03_CODE structure coherent.
[ ] 04_RESULTS_COMPLETE organized.
[ ] 05_APPENDICES_SUPPORT complete.
[ ] 06_PRODUCTS documented with evidence.
[ ] 07_REPRODUCIBILITY complete.
[ ] Appendix G mathematically consistent.
[ ] Appendix H aligned with final structure.
[ ] Dashboard scope documented correctly.
[ ] Product evidence uploaded where available.
[ ] Reproducibility limitations documented.
```

---

## 30. Final statement

Validation protects the scientific coherence of the repository.

Its central principle is:

```text
A doctoral repository is defensible when its data, code, outputs,
figures, tables, appendices, products, and reproducibility files
remain consistent with the thesis narrative and mathematical formulation.
```

This file provides the minimum validation structure required to support that coherence.

# Execution Pipeline

## Purpose

This document describes the recommended execution pipeline for the computational workflow associated with the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The purpose of this file is to provide a structured execution sequence connecting metadata, preprocessing, physical characterization, predictive modeling, uncertainty quantification, FNRR computation, energy projection, figures, tables, appendices, and reproducibility validation.

This file supports the reproducibility layer of the repository:

```text
07_REPRODUCIBILITY/
```

and should be read together with:

```text
07_REPRODUCIBILITY/data_contract.md
07_REPRODUCIBILITY/software_versions.md
07_REPRODUCIBILITY/sessionInfo.txt
07_REPRODUCIBILITY/validation_checks.md
05_APPENDICES_SUPPORT/Anexo_H_Reproducibilidad_Computacional.md
```

---

## 1. Execution philosophy

The repository is not presented as a fully automated one-click production system.

Instead, the execution pipeline documents the scientific and computational sequence required to understand, reproduce, verify, or progressively re-run the doctoral workflow.

The central principle is:

```text
metadata
→ data contract
→ preprocessing
→ physical characterization
→ modeling
→ uncertainty
→ FNRR
→ energy projection
→ figures and tables
→ validation
→ thesis interpretation
```

The pipeline should be interpreted as a structured research workflow, not as a single monolithic script.

---

## 2. General workflow overview

The general execution sequence is:

```text
1. Review repository structure
2. Review metadata and data availability
3. Confirm data contract
4. Prepare computational environment
5. Run preprocessing
6. Generate physical characterization outputs
7. Run classical forecasting models
8. Run machine learning models
9. Run deep learning models
10. Run hybrid physical–statistical integration
11. Generate PI90 uncertainty outputs
12. Compute FNRR outputs
13. Generate energy-projection outputs
14. Export figures
15. Export tables
16. Run validation checks
17. Review appendices and reproducibility documentation
```

This sequence follows the scientific architecture of the thesis.

---

## 3. Repository-level dependencies

The execution pipeline depends on the following repository folders:

```text
02_DATA_METADATA/
03_CODE/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/
07_REPRODUCIBILITY/
```

Product folders in:

```text
06_PRODUCTS/
```

are derivative outputs and should not be treated as required computational inputs for reproducing the thesis results.

---

## 4. Step 1 — Review metadata

Before running code, the reviewer or user should inspect:

```text
02_DATA_METADATA/01_dataset_overview.md
02_DATA_METADATA/02_variable_dictionary.md
02_DATA_METADATA/03_station_zone_mapping.md
02_DATA_METADATA/04_data_processing_notes.md
02_DATA_METADATA/05_data_availability.md
```

Purpose:

```text
understand the observational system before executing computational scripts
```

This step clarifies:

- what data were used;
- which variables were analyzed;
- which stations were included;
- how stations were grouped by zone;
- what processing assumptions were applied;
- and what data-availability limits exist.

---

## 5. Step 2 — Confirm data contract

The expected data contract is documented in:

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

Before execution, confirm that the input dataset satisfies:

- valid station identifiers;
- parseable date-time values;
- numeric observed values;
- valid zone labels;
- valid meteorological variable codes;
- and physically interpretable units.

If the dataset does not satisfy the contract, preprocessing should not proceed without correction or documentation.

---

## 6. Step 3 — Prepare computational environment

The software context is documented in:

```text
07_REPRODUCIBILITY/software_versions.md
07_REPRODUCIBILITY/sessionInfo.txt
```

Recommended preparation steps:

```text
1. Open R or RStudio.
2. Confirm R version.
3. Install or load required packages.
4. Confirm working directory or project root.
5. Confirm access to input data.
6. Confirm output folders exist.
7. Set random seeds when applicable.
```

The environment may require packages for:

- data manipulation;
- date-time parsing;
- statistical modeling;
- machine learning;
- deep learning;
- plotting;
- table export;
- and document/report generation.

---

## 7. Step 4 — Preprocessing

Code location:

```text
03_CODE/01_preprocessing/
```

Expected role:

```text
raw or organized meteorological data
→ cleaned and structured analytical dataset
```

Preprocessing may include:

- reading input files;
- harmonizing column names;
- parsing `FechaYHora`;
- filtering variables;
- assigning stations to zones;
- checking missing values;
- checking non-physical values;
- harmonizing units;
- preparing long-format data;
- preparing wide-format modeling tables when required;
- and exporting preprocessing outputs.

Expected outputs may support:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
05_APPENDICES_SUPPORT/Anexo_B_Preprocesamiento_y_Trazabilidad.md
```

Minimum checks:

```text
required columns exist
dates parse correctly
values are numeric
stations map to zones
variables match the dictionary
```

---

## 8. Step 5 — Physical characterization

Code location:

```text
03_CODE/02_physical_characterization/
```

Expected role:

```text
processed meteorological data
→ physical and statistical characterization outputs
```

This stage supports Chapter 2 of the thesis.

Expected analyses include:

- descriptive statistics;
- zonal comparison;
- wind-speed characterization;
- Weibull parameter estimation;
- Weibull versus Rayleigh comparison;
- ACF;
- PACF;
- FFT;
- Wavelet analysis;
- and exploratory physical interpretation.

Expected result location:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
```

Expected figures:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
```

Expected tables:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
```

Appendix support:

```text
05_APPENDICES_SUPPORT/Anexo_D_Resultados_Extendidos_Cap2.md
```

---

## 9. Step 6 — WPD construction

Wind Power Density is the central derived physical variable:

```text
WPD = 0.5 · ρ · v³
```

This construction may be implemented during physical characterization, modeling preparation, or energy-projection stages, depending on the script organization.

Required inputs:

```text
wind speed
air density or variables required to estimate air density
date-time index
zone
station information
```

Physical requirements:

```text
v ≥ 0
ρ ≥ 0
WPD ≥ 0
```

Formal support:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

---

## 10. Step 7 — Classical forecasting models

Code location:

```text
03_CODE/03_classical_models/
```

Expected role:

```text
WPD or energy-related time series
→ classical forecasting outputs
```

Possible model families:

- ARIMA;
- ARIMAX;
- persistence-related baselines;
- or related classical time-series structures.

Expected result support:

```text
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

Purpose:

```text
establish classical forecasting performance and compare against other model families
```

---

## 11. Step 8 — Machine learning models

Code location:

```text
03_CODE/04_machine_learning/
```

Expected role:

```text
feature-engineered meteorological or energetic datasets
→ machine learning prediction outputs
```

Possible model families:

- Random Forest;
- XGBoost;
- base machine learning models;
- optimized or Bayesian-supported machine learning models.

Expected result support:

```text
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

Purpose:

```text
evaluate nonlinear predictive capacity for wind-energy-related targets
```

---

## 12. Step 9 — Deep learning models

Code location:

```text
03_CODE/05_deep_learning/
```

Expected role:

```text
sequential or lagged datasets
→ deep learning prediction outputs
```

Main model family:

```text
LSTM or related sequential architectures
```

Expected result support:

```text
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
```

Important reproducibility note:

Deep learning outputs may be sensitive to:

- random initialization;
- backend configuration;
- TensorFlow/Keras version;
- CPU/GPU differences;
- train-test split;
- hyperparameter tuning;
- and random seeds.

Exact bit-level reproduction is not guaranteed across systems.

Scientific reproducibility is supported through documented workflow, metrics, outputs, and session information.

---

## 13. Step 10 — Hybrid physical–statistical integration

Code location:

```text
03_CODE/06_hybrid_tdq/
```

Repository interpretation:

```text
This folder preserves the current repository naming for the hybrid integration workflow.
For doctoral evaluation, it should be interpreted as the hybrid physical–statistical integration stage.
```

Expected role:

```text
model outputs
→ integrated predictive interpretation
→ uncertainty support
→ energy and FNRR-related outputs
```

This stage may connect:

- WPD predictions;
- model comparison;
- PI90 intervals;
- FNRR outputs;
- free energy;
- usable energy;
- and projection logic.

Internal labels such as `TDQ` or `PIESS` should be interpreted cautiously as workflow labels unless formally defined in the corresponding appendix or product document.

---

## 14. Step 11 — PI90 uncertainty outputs

Expected result location:

```text
04_RESULTS_COMPLETE/03_pi90_uncertainty/
```

PI90 outputs should include or support:

- lower prediction interval;
- upper prediction interval;
- observed value;
- predicted value;
- empirical coverage;
- calibration logic when applicable;
- and uncertainty-aware interpretation.

General expression:

```text
PI90 = [lower bound, upper bound]
```

Validation condition:

```text
lower bound ≤ upper bound
```

Empirical coverage:

```text
Coverage_PI90 = mean(observed value inside interval)
```

The target interpretation is:

```text
Coverage_PI90 ≈ 0.90
```

when calibrated.

---

## 15. Step 12 — FNRR computation

Expected result location:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
```

Formal definition:

```text
FNRR_z(T) = [Q_75,z(T) − Q_25,z(T)] / [Q_75,z(T) + Q_25,z(T) + ε_z]
```

Required inputs:

- WPD series;
- zone;
- temporal window;
- quantile definition;
- numerical-stability term `ε_z`.

Expected condition:

```text
0 ≤ FNRR_z(T) < 1
```

Formal support:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

Purpose:

```text
quantify regional non-regularity in WPD behavior
```

---

## 16. Step 13 — Energy projection

Code location:

```text
03_CODE/07_energy_projection/
```

Expected result location:

```text
04_RESULTS_COMPLETE/05_energy_projection/
```

Energy quantities:

```text
E_free
E_usable
```

Core relation:

```text
E_usable = (1 − FNRR) · E_free
```

Expected checks:

```text
E_free ≥ 0
0 ≤ FNRR < 1
0 ≤ E_usable ≤ E_free
```

Purpose:

```text
convert WPD behavior and projections into interpretable energetic quantities
```

Projection outputs should be interpreted as model-based scenarios, not direct observations of future values.

---

## 17. Step 14 — Export figures

Figure location:

```text
04_RESULTS_COMPLETE/07_FIGURES/
```

Expected structure:

```text
04_RESULTS_COMPLETE/07_FIGURES/
├── chapter_2/
├── chapter_3/
└── chapter_4/
```

Figure roles:

| Folder | Role |
|---|---|
| `chapter_2/` | Physical characterization figures. |
| `chapter_3/` | Predictive modeling, uncertainty, and residual figures. |
| `chapter_4/` | FNRR, energy, and projection figures. |

Figures should be named consistently and should remain aligned with thesis interpretation.

---

## 18. Step 15 — Export tables

Table location:

```text
04_RESULTS_COMPLETE/08_TABLES/
```

Expected structure:

```text
04_RESULTS_COMPLETE/08_TABLES/
├── chapter_2/
├── chapter_3/
└── chapter_4/
```

Table roles:

| Folder | Role |
|---|---|
| `chapter_2/` | Data, descriptive, Weibull, Rayleigh, and characterization tables. |
| `chapter_3/` | Model comparison, ML, DL, prediction, and uncertainty tables. |
| `chapter_4/` | FNRR, free energy, usable energy, and projection tables. |

Tables should preserve enough information to support traceability between code, results, and thesis narrative.

---

## 19. Step 16 — Extended results

Extended result location:

```text
04_RESULTS_COMPLETE/06_extended_results/
```

This folder may contain:

- supplementary outputs;
- residual support;
- additional scenarios;
- robustness checks;
- intermediate model outputs;
- training logs;
- or technical evidence not included in the main thesis body.

Extended results should support traceability without overloading the main thesis.

---

## 20. Step 17 — Validation checks

Validation file:

```text
07_REPRODUCIBILITY/validation_checks.md
```

Minimum validation categories:

```text
data structure
date-time parsing
station-zone mapping
variable dictionary
physical admissibility
WPD nonnegativity
FNRR bounds
usable energy bounds
PI90 interval validity
output location consistency
figure/table alignment
```

Validation should be performed after major execution stages.

---

## 21. Step 18 — Appendices and documentation

Appendix support is stored in:

```text
05_APPENDICES_SUPPORT/
```

Key appendices:

```text
Anexo_A_Base_Datos_y_Zonificacion.md
Anexo_B_Preprocesamiento_y_Trazabilidad.md
Anexo_C_Configuracion_Experimental.md
Anexo_D_Resultados_Extendidos_Cap2.md
Anexo_E_Resultados_Extendidos_Cap3.md
Anexo_F_Resultados_Extendidos_Cap4.md
Anexo_G_Physical_Mathematical_Model_FNRR.md
Anexo_H_Reproducibilidad_Computacional.md
```

Appendices should be reviewed after computational outputs are generated to ensure consistency between:

```text
code
results
figures
tables
mathematical formulation
thesis interpretation
```

---

## 22. Recommended execution order by folder

A practical execution order is:

```text
02_DATA_METADATA/
07_REPRODUCIBILITY/data_contract.md
03_CODE/01_preprocessing/
03_CODE/02_physical_characterization/
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/
07_REPRODUCIBILITY/validation_checks.md
```

---

## 23. Recommended output review order

After execution, review outputs in this order:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/07_FIGURES/
04_RESULTS_COMPLETE/08_TABLES/
05_APPENDICES_SUPPORT/
07_REPRODUCIBILITY/
```

This order follows the thesis logic.

---

## 24. Execution assumptions

The pipeline assumes:

1. input data follow the data contract;
2. station-zone mapping is available;
3. variable dictionary is stable;
4. required packages are installed;
5. local paths are configured when necessary;
6. output folders exist or are created by scripts;
7. random seeds are set when stochastic models are used;
8. model outputs are exported consistently;
9. and results are reviewed before being interpreted.

---

## 25. Local path caution

Some historical scripts may include local development paths.

These paths may need to be replaced with project-relative paths before rerunning the workflow on another machine.

Recommended pattern:

```text
project_root <- "path/to/phd-thesis-wind-energy-narino"
```

Then define inputs and outputs relative to:

```text
project_root
```

This improves portability.

---

## 26. Randomness and reproducibility

Some workflows may include stochastic behavior, especially:

- train-test splitting;
- machine learning models;
- deep learning models;
- Bayesian optimization;
- neural-network initialization;
- and hyperparameter tuning.

Recommended practice:

```text
set.seed(...)
```

or equivalent seed-setting mechanisms should be used when exact rerun comparability is required.

However, exact numerical identity is not guaranteed across different systems, especially for deep learning workflows.

---

## 27. What this pipeline does not guarantee

This execution pipeline does not guarantee that:

- all raw data are publicly included;
- all scripts execute without local configuration;
- deep learning results reproduce bit-by-bit on all machines;
- historical exploratory scripts are part of the final workflow;
- or the repository functions as a one-click production pipeline.

Instead, it documents the scientific sequence required for understanding and progressive reproducibility.

---

## 28. Minimum successful execution evidence

A successful execution or review should be able to confirm:

1. processed data follow the expected structure;
2. physical characterization outputs exist;
3. model-comparison outputs exist;
4. PI90 uncertainty outputs exist;
5. FNRR outputs exist;
6. energy-projection outputs exist;
7. figures are organized by chapter;
8. tables are organized by chapter;
9. appendices explain the results;
10. and reproducibility files document environment and validation logic.

---

## 29. Relationship with thesis chapters

The execution pipeline supports thesis chapters as follows:

| Thesis component | Repository execution support |
|---|---|
| Chapter 2 | Preprocessing and physical characterization. |
| Chapter 3 | Predictive modeling, model comparison, and uncertainty support. |
| Chapter 4 | FNRR, free energy, usable energy, and energy projection. |
| Appendices | Extended documentation, mathematical formulation, and reproducibility. |

---

## 30. Final statement

The execution pipeline defines the operational logic of the doctoral repository.

Its central principle is:

```text
The workflow must preserve the connection between meteorological data,
physical variables, predictive outputs, uncertainty, regional irregularity,
energy interpretation, figures, tables, appendices, and reproducibility checks.
```

This pipeline supports scientific traceability, doctoral review, and future technical refinement.

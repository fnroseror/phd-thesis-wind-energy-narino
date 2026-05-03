# PhD Thesis Repository — Wind Energy Forecasting and Usable Energy Assessment in Nariño

## Overview

This repository contains the computational, methodological, documentary, result, appendix, product, and reproducibility support material associated with the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

Author:

**Favio Nicolás Rosero Rodríguez**

Doctoral program:

**Doctorado en Ciencias — Física**  
**Universidad Nacional de Colombia, Sede Manizales**

This repository is designed to support:

- scientific traceability,
- methodological transparency,
- computational reproducibility,
- external academic evaluation,
- thesis defense support,
- and derivative academic, technological, pedagogical, and institutional products.

The repository is not a generic storage space. It is the structured scientific support environment of the doctoral thesis.

---

## 1. Scientific scope

The thesis develops a physical–statistical and computational framework for the characterization, prediction, uncertainty quantification, and energetic interpretation of wind power potential in Nariño, Colombia.

The central scientific chain is:

```text
meteorological observations
→ preprocessing and traceability
→ physical characterization
→ Wind Power Density
→ predictive modeling
→ uncertainty quantification
→ FNRR
→ free energy
→ usable energy
→ regional energy projection
```

The central physical target variable is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

The thesis also introduces the **Factor de No Regularidad Regional (FNRR)** as a bounded, dimensionless, robust descriptor of regional irregularity in WPD behavior.

FNRR supports the distinction between:

```text
physically available energy
```

and

```text
structurally usable energy
```

through the relationship:

```text
E_usable = (1 − FNRR) · E_free
```

---

## 2. Repository purpose

This repository has four main purposes.

### 2.1 Scientific support

To preserve the evidence, methods, outputs, figures, tables, and mathematical support associated with the doctoral thesis.

### 2.2 Reproducibility support

To document the computational workflow, software context, data contract, execution logic, and validation assumptions required to understand and progressively reproduce the results.

### 2.3 Academic review support

To allow jurors, reviewers, advisors, and academic evaluators to inspect the structure of the work without depending exclusively on verbal explanation.

### 2.4 Product projection

To organize derivative products emerging from the doctoral work, including scientific articles, patent-oriented material, book development, dashboards, presentations, directed theses, and professorial projects.

---

## 3. Repository structure

The final repository structure is:

```text
phd-thesis-wind-energy-narino/
├── 01_THESIS/
├── 02_DATA_METADATA/
├── 03_CODE/
├── 04_RESULTS_COMPLETE/
├── 05_APPENDICES_SUPPORT/
├── 06_PRODUCTS/
├── 07_REPRODUCIBILITY/
└── README.md
```

Each folder has a defined role in the scientific architecture of the repository.

---

## 4. Core repository folders

## `01_THESIS/`

This folder contains the thesis-level documentation and repository orientation material.

It supports:

- thesis context,
- repository scope,
- contribution summary,
- repository map,
- citation guidance,
- and connection between the dissertation and the repository evidence.

This folder should be interpreted as the formal thesis-entry layer of the repository.

---

## `02_DATA_METADATA/`

This folder documents the observational and metadata foundation of the thesis.

It includes information about:

- dataset overview,
- variable dictionary,
- station-to-zone mapping,
- data-processing notes,
- data availability,
- observational scope,
- and methodological interpretation of the meteorological database.

The dataset is associated with meteorological records from Nariño, Colombia, organized into analytical zones for physical characterization, predictive modeling, uncertainty analysis, FNRR computation, and energy projection.

This folder should be read before inspecting code or results.

---

## `03_CODE/`

This folder preserves the computational workflow used to generate the thesis results.

The expected code structure is:

```text
03_CODE/
├── 01_preprocessing/
├── 02_physical_characterization/
├── 03_classical_models/
├── 04_machine_learning/
├── 05_deep_learning/
├── 06_hybrid_tdq/
├── 07_energy_projection/
└── 08_utils/
```

Scientific interpretation of code stages:

| Code folder | Scientific role |
|---|---|
| `01_preprocessing/` | Prepares meteorological records for analysis while preserving physical traceability. |
| `02_physical_characterization/` | Generates descriptive, distributional, temporal, spectral, and wavelet-based characterization outputs. |
| `03_classical_models/` | Implements classical forecasting models such as ARIMA and ARIMAX. |
| `04_machine_learning/` | Implements machine learning models such as Random Forest and XGBoost. |
| `05_deep_learning/` | Implements deep learning models such as LSTM. |
| `06_hybrid_tdq/` | Preserves the current repository naming for the hybrid integration workflow. Scientifically, it should be interpreted as a hybrid physical–statistical integration stage. |
| `07_energy_projection/` | Supports energy integration, FNRR outputs, and regional projection. |
| `08_utils/` | Contains auxiliary functions and support utilities. |

Internal workflow labels such as `TDQ`, `PIESS`, or `BAYES` should be interpreted as development or traceability labels unless formally defined in the corresponding methodological appendix.

---

## `04_RESULTS_COMPLETE/`

This folder contains the complete result evidence of the doctoral work.

Its final structure is:

```text
04_RESULTS_COMPLETE/
├── 01_physical_characterization/
├── 02_model_comparison/
├── 03_pi90_uncertainty/
├── 04_fnrr_outputs/
├── 05_energy_projection/
├── 06_extended_results/
├── 07_FIGURES/
└── 08_TABLES/
```

This folder is the central evidence layer of the repository.

It contains:

- physical characterization outputs,
- model-comparison outputs,
- uncertainty outputs,
- FNRR outputs,
- energy-projection outputs,
- extended technical results,
- figures by chapter,
- and tables by chapter.

Figures and tables are intentionally integrated inside `04_RESULTS_COMPLETE/` to preserve the connection between numerical results and visual evidence.

---

### `04_RESULTS_COMPLETE/01_physical_characterization/`

Contains structured outputs associated with Chapter 2 physical–statistical characterization.

It supports:

- descriptive statistics,
- Weibull parameter estimation,
- Weibull versus Rayleigh comparison,
- ACF,
- PACF,
- FFT,
- Wavelet analysis,
- and wind-speed signal interpretation.

---

### `04_RESULTS_COMPLETE/02_model_comparison/`

Contains outputs associated with predictive model comparison.

It supports:

- classical forecasting models,
- machine learning models,
- deep learning models,
- persistence benchmarking,
- RMSE,
- MAE,
- R²,
- Skill Score,
- model rankings,
- zone-based comparison,
- and horizon-based comparison.

---

### `04_RESULTS_COMPLETE/03_pi90_uncertainty/`

Contains uncertainty-related outputs.

It supports:

- PI90 prediction intervals,
- empirical coverage,
- calibration logic,
- uncertainty-aware prediction,
- and probabilistic interpretation of model outputs.

---

### `04_RESULTS_COMPLETE/04_fnrr_outputs/`

Contains the FNRR result layer.

It supports:

- regional irregularity interpretation,
- robust WPD-based structural analysis,
- FNRR summaries,
- free-energy and usable-energy interpretation,
- and the transition from prediction to structural energy assessment.

---

### `04_RESULTS_COMPLETE/05_energy_projection/`

Contains the energy-projection result layer.

It supports:

- projected WPD,
- free energy,
- usable energy,
- PI90-supported energy interpretation,
- regional projection toward 2028,
- and annual or quarterly energetic synthesis.

---

### `04_RESULTS_COMPLETE/06_extended_results/`

Contains supplementary or extended outputs that support technical traceability.

It may include:

- additional metric matrices,
- residual-support outputs,
- robustness checks,
- extended validation files,
- training-support files,
- supplementary scenarios,
- and technical evidence not included directly in the main thesis body.

---

### `04_RESULTS_COMPLETE/07_FIGURES/`

Contains the graphical evidence of the thesis.

It is organized by chapter:

```text
04_RESULTS_COMPLETE/07_FIGURES/
├── chapter_2/
├── chapter_3/
└── chapter_4/
```

Chapter-level interpretation:

| Folder | Role |
|---|---|
| `chapter_2/` | Figures for physical characterization, Weibull/Rayleigh analysis, ACF/PACF, FFT, and Wavelet. |
| `chapter_3/` | Figures for model comparison, WPD prediction, Eh prediction, Skill Score, PI90, and residual analysis. |
| `chapter_4/` | Figures for FNRR, free energy, usable energy, PI90-supported projection, and energy projection toward 2028. |

Figures are not decorative. They are part of the scientific evidence layer.

---

### `04_RESULTS_COMPLETE/08_TABLES/`

Contains the numerical evidence of the thesis.

It is organized by chapter:

```text
04_RESULTS_COMPLETE/08_TABLES/
├── chapter_2/
├── chapter_3/
└── chapter_4/
```

Chapter-level interpretation:

| Folder | Role |
|---|---|
| `chapter_2/` | Tables for data traceability, quality control, physical characterization, Weibull fitting, and Rayleigh comparison. |
| `chapter_3/` | Tables for predictive modeling, model comparison, ML/DL outputs, PI90 support, and final prediction outputs. |
| `chapter_4/` | Tables for FNRR, free energy, usable energy, WPD projection, PI90, and annual/quarterly energy summaries. |

Tables provide numerical verification for the thesis results.

---

## `05_APPENDICES_SUPPORT/`

This folder contains technical, methodological, mathematical, and reproducibility appendices.

Its purpose is to provide extended support for aspects that are essential for evaluation but should not overload the main thesis document.

Current appendix structure:

```text
05_APPENDICES_SUPPORT/
├── Anexo_A_Base_Datos_y_Zonificacion.md
├── Anexo_B_Preprocesamiento_y_Trazabilidad.md
├── Anexo_C_Configuracion_Experimental.md
├── Anexo_D_Resultados_Extendidos_Cap2.md
├── Anexo_E_Resultados_Extendidos_Cap3.md
├── Anexo_F_Resultados_Extendidos_Cap4.md
├── Anexo_G_Physical_Mathematical_Model_FNRR.md
├── Anexo_G_Physical_Mathematical_Model_FNRR.docx
└── Anexo_H_Reproducibilidad_Computacional.md
```

Appendix roles:

| Appendix | Role |
|---|---|
| Appendix A | Database and zonal structure. |
| Appendix B | Preprocessing and traceability. |
| Appendix C | Experimental configuration. |
| Appendix D | Extended Chapter 2 results. |
| Appendix E | Extended Chapter 3 results. |
| Appendix F | Extended Chapter 4 results. |
| Appendix G | Physical and mathematical formulation of the model and FNRR. |
| Appendix H | Computational reproducibility. |

Appendix G is especially important because it formalizes:

- Wind Power Density,
- PI90 uncertainty,
- FNRR,
- free energy,
- usable energy,
- and regional energy projection.

---

## `06_PRODUCTS/`

This folder contains academic, technological, pedagogical, and applied products derived from the doctoral thesis.

Its structure is:

```text
06_PRODUCTS/
├── 01_articles/
├── 02_patent/
├── 03_book/
├── 04_dashboard/
├── 05_presentations/
├── 06_directed_theses/
├── 07_professorial_project/
└── README.md
```

This folder should be interpreted as the projection layer of the repository.

It is not part of the core evidentiary structure of the thesis.

Product categories:

| Folder | Role |
|---|---|
| `01_articles/` | Scientific article concept notes and manuscript-development support. |
| `02_patent/` | Preliminary patent-oriented technical documentation. |
| `03_book/` | Book outline and pedagogical/scientific projection. |
| `04_dashboard/` | Dashboard and visualization product support. |
| `05_presentations/` | Presentations, events, certificates, and dissemination material. |
| `06_directed_theses/` | Directed theses and academic supervision products. |
| `07_professorial_project/` | Professorial, institutional, or research-line project material. |

The products are derived from the thesis, but they should not be confused with the thesis itself.

---

## `07_REPRODUCIBILITY/`

This folder contains reproducibility support material.

It should include or document:

```text
07_REPRODUCIBILITY/
├── data_contract.md
├── execution_pipeline.md
├── software_versions.md
├── sessionInfo.txt
├── validation_checks.md
└── repository_version_support.md
```

This folder supports:

- execution logic,
- software environment documentation,
- package/session information,
- validation checks,
- data contract,
- repository version support,
- and reproducibility assumptions.

The repository is not presented as a fully containerized one-click production system. It is a doctoral scientific repository designed for traceability, reviewability, and progressive reproducibility.

---

## 5. Methodological architecture

The methodological architecture of the thesis follows this sequence:

```text
data metadata
→ preprocessing
→ physical characterization
→ classical forecasting
→ machine learning
→ deep learning
→ hybrid physical–statistical integration
→ uncertainty quantification
→ FNRR computation
→ energy projection
→ figures and tables
→ appendices
→ reproducibility support
```

This sequence reflects the dependency structure between scientific stages.

Each stage supports the next.

---

## 6. Thesis–repository relationship

The thesis and repository should be read together.

The thesis provides the formal academic argument.

The repository preserves the evidence, code, outputs, figures, tables, appendices, and reproducibility support.

The relationship is:

```text
doctoral thesis
→ scientific argument

repository
→ evidence, traceability, reproducibility, and derivative products
```

The repository supports the thesis, but it does not replace the dissertation document.

---

## 7. Data availability and reproducibility policy

Raw institutional research data are not fully included in this repository.

This is due to possible constraints related to:

- file size,
- source-format complexity,
- repository clarity,
- local processing structure,
- and responsible data-management practices.

The repository instead preserves:

- metadata,
- variable definitions,
- station-zone mapping,
- processing notes,
- code structure,
- result outputs,
- figures,
- tables,
- appendices,
- and reproducibility documentation.

The data-availability statement is documented in:

```text
02_DATA_METADATA/05_data_availability.md
```

Reproducibility support is documented in:

```text
07_REPRODUCIBILITY/
05_APPENDICES_SUPPORT/Anexo_H_Reproducibilidad_Computacional.md
```

---

## 8. Mathematical and physical support

The main mathematical and physical formulation is documented in:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.docx
```

This appendix formalizes:

```text
WPD = 0.5 · ρ · v³
```

```text
FNRR_z(T) = [Q_75,z(T) − Q_25,z(T)] / [Q_75,z(T) + Q_25,z(T) + ε_z]
```

```text
E_usable = (1 − FNRR) · E_free
```

The formulation supports the final doctoral contribution:

```text
a physical–statistical framework for forecasting and interpreting
regional wind-energy potential under uncertainty and structural irregularity
```

---

## 9. Interpretation of internal workflow labels

Some files may contain labels such as:

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

These labels should be interpreted carefully.

For doctoral evaluation, the core scientific language is:

- physical characterization,
- Wind Power Density,
- predictive modeling,
- persistence benchmarking,
- uncertainty quantification,
- PI90,
- FNRR,
- free energy,
- usable energy,
- and regional energy projection.

Internal workflow labels should not be overinterpreted as independent theoretical claims, publication claims, or formal patent claims unless explicitly defined in the corresponding appendix or product document.

---

## 10. Recommended reading order

For reviewers, jurors, or external readers, the recommended reading order is:

```text
1. README.md
2. 01_THESIS/
3. 02_DATA_METADATA/
4. 05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
5. 05_APPENDICES_SUPPORT/Anexo_B_Preprocesamiento_y_Trazabilidad.md
6. 05_APPENDICES_SUPPORT/Anexo_C_Configuracion_Experimental.md
7. 04_RESULTS_COMPLETE/
8. 04_RESULTS_COMPLETE/07_FIGURES/
9. 04_RESULTS_COMPLETE/08_TABLES/
10. 05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
11. 07_REPRODUCIBILITY/
12. 06_PRODUCTS/
```

For mathematical review, prioritize:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

For data review, prioritize:

```text
02_DATA_METADATA/
05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
05_APPENDICES_SUPPORT/Anexo_B_Preprocesamiento_y_Trazabilidad.md
```

For model review, prioritize:

```text
03_CODE/
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
05_APPENDICES_SUPPORT/Anexo_C_Configuracion_Experimental.md
05_APPENDICES_SUPPORT/Anexo_E_Resultados_Extendidos_Cap3.md
```

For energy and FNRR review, prioritize:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
05_APPENDICES_SUPPORT/Anexo_F_Resultados_Extendidos_Cap4.md
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

---

## 11. Repository status

```text
Status: Final scientific closure and reproducibility alignment
Repository role: Doctoral thesis support environment
Core evidence: Organized
Appendices: Structured
Products: In progressive documentation
Reproducibility: Under final alignment
```

This repository is under final organization to support doctoral evaluation, thesis defense, future publications, technological projection, and academic continuity.

---

## 12. Citation

If this repository is cited, it should be cited together with the corresponding doctoral thesis and institutional affiliation.

Suggested citation format:

```text
Rosero-Rodríguez, F. N. (2026). PhD thesis repository:
Wind energy forecasting and usable energy assessment in Nariño.
Doctorado en Ciencias — Física, Universidad Nacional de Colombia, Sede Manizales.
GitHub repository: phd-thesis-wind-energy-narino.
```

---

## 13. Final statement

This repository preserves the scientific support system of a doctoral thesis focused on wind-energy prediction and interpretation in Nariño, Colombia.

Its central principle is:

```text
The thesis establishes the scientific contribution;
the repository preserves the evidence, traceability,
mathematical support, reproducibility structure,
and derivative academic products.
```

The repository should be read as a coherent scientific architecture connecting:

```text
data
→ physics
→ modeling
→ uncertainty
→ FNRR
→ usable energy
→ reproducibility
→ academic projection
```

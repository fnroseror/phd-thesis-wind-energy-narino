# 07_REPRODUCIBILITY

## Purpose

This folder contains the computational reproducibility support for the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The purpose of this folder is to document the data contract, execution logic, software environment, validation checks, and repository-version support required to understand and progressively reproduce the computational workflow of the doctoral research.

This folder is part of the final doctoral repository structure:

```text
phd-thesis-wind-energy-narino/
├── 01_THESIS/
├── 02_DATA_METADATA/
├── 03_CODE/
├── 04_RESULTS_COMPLETE/
├── 05_APPENDICES_SUPPORT/
├── 06_PRODUCTS/
└── 07_REPRODUCIBILITY/
```

This folder should be interpreted as the reproducibility and technical-traceability layer of the repository.

---

## 1. Reproducibility scope

The repository is designed to support scientific traceability and progressive computational reproducibility.

It is not presented as a fully containerized one-click execution system.

Instead, it documents:

- expected data structure;
- input-variable conventions;
- processing logic;
- execution sequence;
- software environment;
- package/session information;
- validation checks;
- known reproducibility limits;
- and repository state for doctoral review.

The reproducibility principle is:

```text
A doctoral computational repository is reproducible when its data structure,
code logic, result evidence, software context, validation criteria,
and limitations are sufficiently documented for scientific evaluation.
```

---

## 2. Scientific workflow supported

The reproducibility structure supports the following scientific chain:

```text
meteorological observations
→ preprocessing and traceability
→ physical characterization
→ Wind Power Density
→ predictive modeling
→ PI90 uncertainty
→ FNRR
→ free energy
→ usable energy
→ regional projection
```

The computational workflow is connected to:

```text
02_DATA_METADATA/
03_CODE/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/
```

---

## 3. Main files

The expected files in this folder are:

```text
07_REPRODUCIBILITY/
├── README.md
├── data_contract.md
├── execution_pipeline.md
├── software_versions.md
├── sessionInfo.txt
├── validation_checks.md
└── repository_version_support.md
```

Each file has a specific role.

| File | Role |
|---|---|
| `README.md` | Explains the purpose and scope of reproducibility support. |
| `data_contract.md` | Defines the expected input data structure and required fields. |
| `execution_pipeline.md` | Documents the recommended execution sequence of the workflow. |
| `software_versions.md` | Summarizes the software and package environment. |
| `sessionInfo.txt` | Preserves R session information from the computational environment. |
| `validation_checks.md` | Defines minimum checks required to verify output coherence. |
| `repository_version_support.md` | Documents the repository state used for doctoral review. |

---

## 4. Relationship with metadata

The reproducibility layer depends on the metadata documented in:

```text
02_DATA_METADATA/
```

That folder defines:

- dataset overview;
- variable dictionary;
- station-to-zone mapping;
- processing notes;
- data availability;
- and observational interpretation.

The metadata layer answers:

```text
What data were used?
What variables were analyzed?
Which stations were included?
How were stations organized by zone?
What limitations apply to data access and interpretation?
```

---

## 5. Relationship with code

The computational workflow is stored in:

```text
03_CODE/
```

Expected structure:

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

Repository interpretation:

| Code folder | Reproducibility role |
|---|---|
| `01_preprocessing/` | Prepares and organizes meteorological data. |
| `02_physical_characterization/` | Generates physical and statistical characterization outputs. |
| `03_classical_models/` | Supports classical forecasting workflows. |
| `04_machine_learning/` | Supports machine learning workflows. |
| `05_deep_learning/` | Supports deep learning workflows. |
| `06_hybrid_tdq/` | Preserves the current repository naming for the hybrid physical–statistical integration stage. |
| `07_energy_projection/` | Supports energy projection, FNRR, free energy, and usable energy outputs. |
| `08_utils/` | Contains auxiliary functions and utilities. |

Internal labels such as `TDQ`, `PIESS`, or `BAYES` should be interpreted cautiously as workflow labels unless formally defined in the corresponding methodological appendix.

---

## 6. Relationship with complete results

The complete results are stored in:

```text
04_RESULTS_COMPLETE/
```

Expected structure:

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

The reproducibility relationship is:

```text
metadata + code → complete results
```

The result layer includes:

- physical characterization outputs;
- model-comparison outputs;
- PI90 uncertainty outputs;
- FNRR outputs;
- energy-projection outputs;
- extended results;
- figures;
- and tables.

---

## 7. Relationship with appendices

The reproducibility layer is supported by:

```text
05_APPENDICES_SUPPORT/
```

Especially:

```text
Anexo_A_Base_Datos_y_Zonificacion.md
Anexo_B_Preprocesamiento_y_Trazabilidad.md
Anexo_C_Configuracion_Experimental.md
Anexo_G_Physical_Mathematical_Model_FNRR.md
Anexo_H_Reproducibilidad_Computacional.md
```

Appendix H provides the extended explanation of computational reproducibility.

Appendix G provides the physical and mathematical formulation of:

```text
WPD = 0.5 · ρ · v³
```

```text
FNRR_z(T) = [Q_75,z(T) − Q_25,z(T)] / [Q_75,z(T) + Q_25,z(T) + ε_z]
```

```text
E_usable = (1 − FNRR) · E_free
```

---

## 8. Data reproducibility

The complete raw data are not necessarily included in this public repository.

Reproducibility is supported through:

- metadata;
- data contract;
- variable dictionary;
- station-zone mapping;
- processing notes;
- code structure;
- result outputs;
- figures;
- tables;
- appendices;
- and software environment documentation.

The data-availability statement is located in:

```text
02_DATA_METADATA/05_data_availability.md
```

This is a realistic reproducibility strategy for a large environmental observational dataset.

---

## 9. Execution reproducibility

The execution sequence is documented in:

```text
execution_pipeline.md
```

The general workflow is:

```text
1. Review metadata
2. Confirm data structure
3. Run preprocessing
4. Generate physical characterization
5. Run classical models
6. Run machine learning models
7. Run deep learning models
8. Generate uncertainty outputs
9. Compute FNRR
10. Estimate free and usable energy
11. Export figures and tables
12. Review validation checks
```

The execution pipeline should be interpreted as a structured scientific workflow, not as a guarantee that every script can be executed without local configuration.

---

## 10. Software reproducibility

Software context is documented in:

```text
software_versions.md
sessionInfo.txt
```

These files support interpretation of:

- R version;
- package versions;
- TensorFlow or deep learning backend when applicable;
- operating system context;
- dependency assumptions;
- and computational environment notes.

Exact bit-level reproducibility is not guaranteed across machines, especially for stochastic models or deep learning workflows.

The objective is scientific and computational traceability.

---

## 11. Validation checks

Validation logic is documented in:

```text
validation_checks.md
```

Validation checks should verify, at minimum:

- expected columns exist;
- variables are correctly labeled;
- dates are correctly parsed;
- station-zone mapping is coherent;
- WPD is nonnegative under valid physical inputs;
- FNRR remains within expected bounds;
- usable energy does not exceed free energy;
- PI90 intervals contain lower and upper limits;
- result folders contain expected outputs;
- and figures/tables are aligned with thesis chapters.

---

## 12. Repository version support

Repository state is documented in:

```text
repository_version_support.md
```

This file should describe:

- repository status;
- final structure;
- known limitations;
- public-data constraints;
- reproducibility assumptions;
- and doctoral-review readiness.

This is important because repositories evolve over time.

The version-support file helps reviewers understand the structure corresponding to the doctoral evaluation stage.

---

## 13. Reproducibility limitations

This repository may include:

- historical local path references;
- scripts developed during different phases of the doctoral process;
- stochastic modeling components;
- software-version sensitivity;
- large-data constraints;
- and outputs generated across multiple execution stages.

These limitations are expected in a complex doctoral computational workflow.

They should be documented honestly rather than hidden.

---

## 14. What this folder does not claim

This folder does not claim that:

- the repository is a fully automated production pipeline;
- all raw data are publicly included;
- every script runs without local configuration;
- deep learning outputs reproduce bit-by-bit on every machine;
- or historical exploratory files are part of the final workflow.

Instead, this folder documents:

```text
data structure
→ execution logic
→ software context
→ validation checks
→ repository state
→ reproducibility limits
```

---

## 15. Recommended reviewer route

A reviewer interested in reproducibility should inspect:

```text
1. 07_REPRODUCIBILITY/README.md
2. 07_REPRODUCIBILITY/data_contract.md
3. 07_REPRODUCIBILITY/execution_pipeline.md
4. 07_REPRODUCIBILITY/software_versions.md
5. 07_REPRODUCIBILITY/sessionInfo.txt
6. 07_REPRODUCIBILITY/validation_checks.md
7. 07_REPRODUCIBILITY/repository_version_support.md
```

Then connect this information with:

```text
02_DATA_METADATA/
03_CODE/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/
```

---

## 16. Closure criterion

This folder is considered complete when:

1. the data contract is explicit;
2. the execution pipeline is documented;
3. the software environment is described;
4. session information is preserved;
5. validation checks are listed;
6. repository-version support is documented;
7. reproducibility limitations are acknowledged;
8. and the repository can be reviewed without requiring verbal explanation from the author.

---

## 17. Final note

This folder provides the final technical support layer of the doctoral repository.

Its central principle is:

```text
Scientific reproducibility is not only rerunning code;
it is preserving the relationship between data, code, results,
figures, tables, mathematical formulation, software context,
validation checks, and documented limitations.
```

For that reason, `07_REPRODUCIBILITY/` should be treated as the computational traceability and reproducibility layer of the doctoral thesis repository.

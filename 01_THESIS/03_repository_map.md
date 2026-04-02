# Repository Map

## Purpose of this map

This document explains how the internal structure of the repository is connected to the scientific structure of the doctoral thesis.

The thesis is organized into five main chapters, followed by annexes and associated products. This repository functions as the computational, methodological, documentary, and reproducibility support environment of that structure.

Its purpose is not only to store files, but to preserve the traceability between:

- the written scientific argument,
- the computational pipeline,
- the generated evidence,
- the extended technical material,
- the reproducibility environment,
- and the derivative products associated with the doctoral work.

---

## Thesis-to-repository correspondence

### Chapter 1 — Scientific foundation of the problem

**Thesis focus**

- context and scientific framework,
- problem statement,
- objectives,
- scope,
- contribution,
- justification,
- general document structure.

**Repository support**

- `01_THESIS/`
- `02_DATA_METADATA/`

**Role in the repository**

This chapter is primarily conceptual and structural. Its repository support is concentrated in the thesis-context material and in the metadata documentation that defines the observational basis of the research.

Relevant materials include:

- thesis PDF,
- repository scope,
- contributions summary,
- repository map,
- data metadata and variable structure.

---

### Chapter 2 — Physical–statistical characterization of wind in Nariño

**Thesis focus**

- theoretical and conceptual review,
- meteorological data structure,
- preprocessing,
- descriptive analysis,
- Weibull and Rayleigh comparison,
- ACF/PACF,
- FFT,
- Wavelet,
- physical synthesis of wind behavior.

**Repository support**

- `03_CODE/01_preprocessing/`
- `03_CODE/02_physical_characterization/`
- `04_RESULTS/01_physical_characterization/`
- `05_FIGURES/chapter_2/`
- `06_TABLES/chapter_2/`
- `07_APPENDICES_SUPPORT/`

**Role in the repository**

This chapter is supported by all code and outputs related to physical characterization of wind dynamics. It includes preprocessing logic, distributional analysis, temporal dependence, spectral analysis, and time–frequency decomposition.

Representative contents:

- cleaning and quality-control scripts,
- generation of descriptive statistics,
- Weibull/Rayleigh fitting outputs,
- ACF and PACF outputs,
- FFT outputs,
- Wavelet outputs,
- supplementary physical analysis not fully included in the thesis PDF.

---

### Chapter 3 — Predictive modeling of Wind Power Density (WPD)

**Thesis focus**

- comparative predictive design,
- temporal partition strategy,
- deterministic metrics,
- Skill Score against persistence,
- probabilistic evaluation,
- PI90 calibration logic,
- introduction of FNRR,
- comparison of predictive families.

**Repository support**

- `03_CODE/03_classical_models/`
- `03_CODE/04_machine_learning/`
- `03_CODE/05_deep_learning/`
- `03_CODE/06_hybrid_tdq/`
- `04_RESULTS/02_model_comparison/`
- `04_RESULTS/03_pi90_uncertainty/`
- `04_RESULTS/04_fnrr_outputs/`
- `05_FIGURES/chapter_3/`
- `06_TABLES/chapter_3/`
- `07_APPENDICES_SUPPORT/`
- `09_REPRODUCIBILITY/`

**Role in the repository**

This chapter is supported by the predictive core of the repository. It includes the implementation and evaluation of classical, machine learning, deep learning, and hybrid physical–statistical approaches under a unified time-series validation framework.

Representative contents:

- ARIMA and ARIMAX scripts,
- Random Forest and XGBoost scripts,
- LSTM-based scripts,
- Bayesian tuning outputs when applicable,
- model comparison tables,
- persistence benchmark comparison,
- PI90 calibration results,
- FNRR calculation support,
- training curves and extended validation outputs.

---

### Chapter 4 — Energy integration and regional projection (2017–2028)

**Thesis focus**

- physical basis of usable wind energy,
- temporal evolution of WPD,
- free energy versus usable energy,
- uncertainty propagation,
- formal definition of FNRR,
- structural interpretation by zone,
- projection up to 2028.

**Repository support**

- `03_CODE/06_hybrid_tdq/`
- `03_CODE/07_energy_projection/`
- `04_RESULTS/05_energy_projection/`
- `04_RESULTS/04_fnrr_outputs/`
- `04_RESULTS/03_pi90_uncertainty/`
- `05_FIGURES/chapter_4/`
- `06_TABLES/chapter_4/`
- `07_APPENDICES_SUPPORT/`
- `09_REPRODUCIBILITY/`

**Role in the repository**

This chapter is supported by the code and outputs that transform physical wind behavior into energetic interpretation. It includes the generation of WPD-based yearly metrics, PI90 uncertainty intervals, FNRR-based structural penalization, and regional projection scenarios.

Representative contents:

- WPD and Eh construction support,
- energy aggregation outputs,
- FNRR formal implementation,
- free-energy and usable-energy calculations,
- annual projection results,
- uncertainty bands,
- extended scenario outputs.

---

### Chapter 5 — Scientific discussion and doctoral contribution

**Thesis focus**

- physical contribution,
- statistical contribution,
- methodological contribution,
- comparison with international literature,
- limitations,
- future lines of work.

**Repository support**

- `01_THESIS/`
- `07_APPENDICES_SUPPORT/`
- `08_PRODUCTS/`
- `09_REPRODUCIBILITY/`

**Role in the repository**

This chapter is primarily interpretive and synthetic, but its support in the repository is important because the discussion depends on traceable evidence.

The repository therefore supports Chapter 5 through:

- structured summaries of contributions,
- reproducibility evidence,
- extended methodological support,
- and derivative products that emerge from the doctoral work.

---

## Annexes — Repository-backed technical support

**Thesis focus**

The annexes are explicitly presented in the thesis as the space where reproducible codes, complete tables, additional figures, experimental configurations, and extended results are organized.

**Repository support**

- `07_APPENDICES_SUPPORT/`
- `05_FIGURES/supplementary/`
- `06_TABLES/supplementary/`
- `09_REPRODUCIBILITY/`

**Role in the repository**

This is the main digital extension of the annex section. It stores materials that support the thesis scientifically but are not fully embedded in the main PDF due to space, readability, or documentary scope.

Representative contents:

- supplementary tables,
- supplementary figures,
- calibration notes,
- training curves,
- methodological extensions,
- reproducibility records,
- additional validation artifacts.

---

## Associated products — Post-thesis and derivative outputs

**Thesis focus**

The thesis explicitly lists associated products such as articles, patent-oriented developments, dashboard work, book material, conference outputs, directed thesis projects, and a professorial project.

**Repository support**

- `08_PRODUCTS/`

**Role in the repository**

This section of the repository preserves the organization of all derivative outputs formally associated with the doctoral work.

Representative contents:

- article drafts and support files,
- patent-oriented technical material,
- dashboard support material,
- book development material,
- conference-paper support,
- directed-project support files,
- professorial project support files.

---

## Folder-by-folder functional interpretation

### `01_THESIS/`
Contains the formal thesis context:

- final PDF,
- repository scope,
- contributions summary,
- repository map,
- citation material.

### `02_DATA_METADATA/`
Contains documentation of the observational basis of the work:

- variable dictionary,
- station-to-zone structure,
- data descriptions,
- metadata notes.

### `03_CODE/`
Contains the executable scientific workflow:

- preprocessing,
- physical characterization,
- classical forecasting,
- machine learning,
- deep learning,
- hybrid TDQ logic,
- energy projection,
- utilities.

### `04_RESULTS/`
Contains structured outputs generated by the workflow:

- physical characterization results,
- model comparison outputs,
- PI90 uncertainty outputs,
- FNRR outputs,
- projected energy outputs,
- extended results.

### `05_FIGURES/`
Contains organized visual material by chapter:

- chapter 2 figures,
- chapter 3 figures,
- chapter 4 figures,
- supplementary figures.

### `06_TABLES/`
Contains organized tabular material by chapter:

- chapter 2 tables,
- chapter 3 tables,
- chapter 4 tables,
- supplementary tables.

### `07_APPENDICES_SUPPORT/`
Contains technical material not fully included in the main thesis document but required for scientific support and methodological traceability.

### `08_PRODUCTS/`
Contains materials related to associated products formally declared by the thesis.

### `09_REPRODUCIBILITY/`
Contains the reproducibility environment:

- session information,
- execution order,
- validation checks,
- environment notes,
- repository version support.

---

## Reading order for external users

A reader or evaluator should interpret the repository in the following order:

1. `01_THESIS/`
2. `02_DATA_METADATA/`
3. `03_CODE/`
4. `04_RESULTS/`
5. `05_FIGURES/` and `06_TABLES/`
6. `07_APPENDICES_SUPPORT/`
7. `09_REPRODUCIBILITY/`
8. `08_PRODUCTS/`

This sequence mirrors the scientific logic of the thesis: from context and data foundation, to method, to results, to support material, and finally to derivative outputs.

---

## Final interpretation

This repository is not organized as a generic storage space.

It is structured as a **scientific map of the doctoral thesis**.

Each major folder corresponds to a specific function within the research system:

- theoretical grounding,
- data support,
- executable method,
- generated evidence,
- annex extension,
- reproducibility,
- and associated products.

The repository should therefore be read as the digital extension of the thesis architecture, preserving coherence between document, method, evidence, and scientific projection.

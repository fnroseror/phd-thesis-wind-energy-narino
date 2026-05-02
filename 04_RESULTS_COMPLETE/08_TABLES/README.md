# 08_TABLES

## Purpose

This folder contains the complete tabular evidence associated with the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

It is part of:

```text
04_RESULTS_COMPLETE/
```

and functions as the numerical evidence layer of the doctoral repository.

The purpose of this folder is to preserve the tables generated during the physical characterization, predictive modeling, uncertainty analysis, FNRR interpretation, and energy-projection stages of the thesis.

---

## 1. Scientific role of this folder

Tables are not auxiliary files in this repository.

They provide the numerical support required to verify, interpret, and reproduce the results reported in the thesis.

In this doctoral work, tables are used to document:

- data availability,
- quality-control diagnostics,
- temporal-resolution structure,
- physical characterization outputs,
- distributional fitting,
- Weibull and Rayleigh comparison,
- model-comparison results,
- machine learning outputs,
- deep learning outputs,
- prediction outputs,
- uncertainty intervals,
- FNRR summaries,
- energy projection,
- and annual or quarterly synthesis results.

For that reason, this folder should be interpreted as part of the scientific result layer, not as a secondary storage space.

---

## 2. Folder structure

The current structure is:

```text
08_TABLES/
├── chapter_2/
├── chapter_3/
├── chapter_4/
└── README.md
```

Each chapter folder contains tabular evidence associated with the corresponding analytical stage of the thesis.

---

## 3. Chapter 2 tables

Folder:

```text
08_TABLES/chapter_2/
```

This folder contains tables associated with the physical and statistical characterization stage of the thesis.

The current tabular evidence includes files related to:

- record counts by variable,
- quality-control diagnostics,
- temporal-resolution analysis,
- processing parameters,
- descriptive statistics of wind speed by zone,
- cleaning traceability,
- master zonal tables,
- signal variance by zone,
- Weibull maximum-likelihood estimation,
- and Weibull versus Rayleigh comparison.

Scientific role:

These tables support the empirical and physical basis of Chapter 2. They document how the observational system was structured, cleaned, characterized, and interpreted before predictive modeling.

They support the transition from:

```text
observational data
→ quality control
→ zonal organization
→ physical characterization
→ distributional interpretation
→ predictive modeling basis
```

---

## 4. Chapter 3 tables

Folder:

```text
08_TABLES/chapter_3/
```

This folder contains tables associated with predictive modeling, model comparison, deterministic metrics, probabilistic outputs, and energy-related predictive structures.

The current tabular evidence includes files related to:

- classical forecasting models,
- machine learning models,
- Bayesian or optimized machine learning variants,
- deep learning outputs,
- deep learning hyperparameter summaries,
- WPD prediction results,
- Eh prediction results,
- diagnostic records by zone,
- FNRR summaries,
- final prediction outputs by zone and horizon,
- PI90 interval outputs,
- and global model-comparison tables.

Scientific role:

These tables support the predictive modeling stage of the thesis. They provide numerical evidence for evaluating how different model families behave across zones, targets, and prediction horizons.

They also support the comparison between deterministic performance and uncertainty-aware interpretation.

The central evaluation logic is:

```text
models
→ metrics
→ comparison against persistence
→ uncertainty support
→ predictive interpretation
```

---

## 5. Chapter 4 tables

Folder:

```text
08_TABLES/chapter_4/
```

This folder contains tables associated with the integrated physical–statistical interpretation, FNRR, PI90-supported uncertainty, and regional energy projection toward 2028.

The current tabular evidence includes files related to:

- annual FNRR and coherence from 2017 to 2028,
- annual WPD, free energy, usable energy, and PI90,
- daily WPD projection,
- annual WPD and FNRR summaries,
- quarterly WPD and energy summaries,
- annual integrated outputs,
- hourly WPD, Eh, and PI90 structures,
- quarterly integrated outputs,
- quarterly FNRR and coherence,
- and quarterly WPD, free energy, usable energy, and PI90 from 2017 to 2028.

Scientific role:

These tables support the energetic closure of the thesis.

They document how the doctoral workflow moves from prediction to energy interpretation by integrating:

```text
WPD
→ uncertainty
→ FNRR
→ free energy
→ usable energy
→ projection toward 2028
```

This chapter-level tabular evidence is central for supporting the original contribution of the thesis and its regional energy-potential interpretation.

---

## 6. Relationship with figures

The tables contained in this folder should be interpreted together with the graphical evidence contained in:

```text
04_RESULTS_COMPLETE/07_FIGURES/
```

Figures provide visual interpretation.

Tables provide numerical support.

Together, they form the evidence structure required to support the doctoral results.

---

## 7. Relationship with result folders

This folder is directly connected to the result folders:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/06_extended_results/
```

The tables should not be interpreted as isolated files. Each table belongs to a scientific stage of the thesis workflow.

---

## 8. Relationship with code

The tables contained in this folder should be reproducible from the computational workflow contained in:

```text
03_CODE/
```

Depending on the table, the corresponding scripts may be associated with:

```text
03_CODE/01_preprocessing/
03_CODE/02_physical_characterization/
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
03_CODE/08_utils/
```

The folder `03_CODE/06_hybrid_tdq/` reflects the current repository naming. In the scientific interpretation of this tables folder, it should be understood as the hybrid physical–statistical integration stage of the doctoral workflow.

---

## 9. Interpretation of file names

Some table names preserve internal computational labels from the development workflow, including labels such as:

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
```

These labels should be interpreted as traceability labels associated with the computational pipeline.

For doctoral evaluation, the tables should be read according to their scientific function:

- physical characterization,
- predictive modeling,
- model comparison,
- uncertainty quantification,
- FNRR interpretation,
- energy projection,
- and reproducibility support.

---

## 10. Methodological caution

Tables should not be interpreted in isolation.

Each table must be read in relation to:

- the thesis chapter where it is used,
- the variable represented,
- the zone or horizon analyzed,
- the corresponding figure,
- the code that generated it,
- and the methodological purpose of the analysis.

This prevents numerical outputs from being overinterpreted without physical, statistical, or computational context.

---

## 11. Closure criterion

This folder is considered properly organized when:

1. tables are grouped by thesis chapter,
2. file names are sufficiently descriptive,
3. each table can be traced to a result stage,
4. each table can be connected to code, figures, or thesis interpretation,
5. obsolete or duplicate tables are avoided unless they have a clear support function,
6. and the folder can be reviewed without requiring verbal explanation from the author.

---

## 12. Final note

This folder preserves the numerical evidence of the doctoral thesis.

Its role is to support the transition from computational outputs to scientific interpretation.

In the repository structure, `08_TABLES/` provides the tabular layer of the complete evidence system:

```text
data
→ code
→ results
→ figures
→ tables
→ appendices
→ reproducibility
```

For that reason, this folder is essential for external academic review and for the numerical verification of the thesis results.

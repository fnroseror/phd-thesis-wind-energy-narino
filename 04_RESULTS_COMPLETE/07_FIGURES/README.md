# 07_FIGURES

## Purpose

This folder contains the complete visual evidence associated with the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

It is part of:

```text
04_RESULTS_COMPLETE/
```

and functions as the graphical evidence layer of the doctoral repository.

The purpose of this folder is to preserve the figures generated during the physical characterization, predictive modeling, uncertainty analysis, FNRR interpretation, and energy-projection stages of the thesis.

---

## 1. Scientific role of this folder

Figures are not decorative elements in this repository.

They are visual evidence that supports the interpretation of the doctoral results.

In this thesis, figures are used to represent:

- physical behavior of wind speed,
- distributional structure,
- temporal dependence,
- spectral behavior,
- time-frequency behavior,
- predictive model performance,
- uncertainty calibration,
- FNRR behavior,
- free and usable energy,
- and projected regional wind-energy potential.

For that reason, this folder must be interpreted as part of the scientific result layer, not as an auxiliary image archive.

---

## 2. Folder structure

The current structure is:

```text
07_FIGURES/
├── chapter_2/
├── chapter_3/
├── chapter_4/
└── README.md
```

Each chapter folder contains figures associated with the corresponding analytical stage of the thesis.

---

## 3. Chapter 2 figures

Folder:

```text
07_FIGURES/chapter_2/
```

This folder contains figures associated with the physical and statistical characterization of wind behavior.

The current visual evidence includes figures related to:

- ACF analysis,
- PACF analysis,
- FFT spectral analysis,
- Wavelet time-frequency analysis,
- Weibull distribution parameters,
- Weibull versus Rayleigh comparison,
- CDF and PDF comparisons,
- and boxplot-based zonal comparison of wind speed.

Scientific role:

These figures support the physical characterization stage of the thesis. They help demonstrate that wind speed in Nariño should be interpreted as a structured physical-statistical signal rather than as a simple random or Gaussian variable.

They provide visual evidence for:

```text
wind speed observation
→ distributional structure
→ temporal dependence
→ spectral behavior
→ multiscale interpretation
→ physical basis for forecasting
```

---

## 4. Chapter 3 figures

Folder:

```text
07_FIGURES/chapter_3/
```

This folder contains figures associated with predictive modeling, model comparison, deterministic evaluation, uncertainty behavior, and supporting visual outputs for WPD and Eh.

The current visual evidence includes figures related to:

- Skill Score versus persistence,
- R²,
- RMSE,
- PI90 coverage before and after calibration,
- FNRR density by zone,
- examples for short and medium prediction horizons,
- WPD prediction curves,
- Eh prediction curves,
- residual analysis,
- zone-specific results,
- horizon-specific results,
- and model-specific visual outputs.

Scientific role:

These figures support the predictive modeling stage of the thesis.

They allow reviewers to inspect visually whether the forecasting framework provides meaningful improvement, how models behave across zones and horizons, and how predictive results connect with uncertainty and energetic interpretation.

The central interpretation criterion is:

```text
A model is not only evaluated by fitting the data;
it must demonstrate predictive value relative to persistence
and must remain interpretable under uncertainty.
```

---

## 5. Chapter 4 figures

Folder:

```text
07_FIGURES/chapter_4/
```

This folder contains figures associated with the integrated physical-statistical interpretation, FNRR, uncertainty-aware energetic analysis, and regional projection toward 2028.

The current visual evidence includes figures related to:

- annual free energy,
- annual usable energy,
- PI90-supported energy interpretation,
- annual FNRR behavior,
- projected FNRR from 2017 to 2028,
- projected free energy,
- projected usable energy,
- and quarterly WPD projection.

Scientific role:

These figures support the energetic closure of the thesis.

They show how the doctoral workflow moves from physical characterization and prediction toward regional energetic interpretation.

The main visual logic is:

```text
predicted WPD
→ uncertainty
→ FNRR structural interpretation
→ free energy
→ usable energy
→ projection toward 2028
```

---

## 6. Relationship with results

This folder is directly connected to the result folders:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/06_extended_results/
```

The figures should always be interpreted together with the corresponding numerical outputs, tables, and methodological descriptions.

---

## 7. Relationship with tables

The graphical evidence in this folder should be read together with:

```text
04_RESULTS_COMPLETE/08_TABLES/
```

Figures provide visual interpretation.

Tables provide numerical support.

Together, they form the evidence structure required to support the thesis results.

---

## 8. Relationship with code

The figures contained in this folder should be reproducible from the computational workflow contained in:

```text
03_CODE/
```

Depending on the figure, the corresponding scripts may be associated with:

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

The folder `03_CODE/06_hybrid_tdq/` reflects the current repository naming. In the scientific interpretation of the repository, this stage should be understood as part of the hybrid physical-statistical integration layer of the doctoral workflow.

---

## 9. Naming interpretation

Some figure names preserve the original computational workflow labels used during development.

These names should be interpreted as traceability labels, not as independent theoretical claims.

For doctoral evaluation, the figures should be read according to their scientific function:

- physical characterization,
- deterministic model comparison,
- probabilistic uncertainty,
- FNRR structural interpretation,
- and energy projection.

This distinction helps preserve technical traceability while maintaining a clear academic interpretation.

---

## 10. Methodological caution

Figures should not be interpreted in isolation.

Each figure must be read in relation to:

- the thesis chapter where it is discussed,
- the corresponding numerical table,
- the code that generated it,
- the variable being analyzed,
- the zone and prediction horizon represented,
- and the methodological purpose of the analysis.

This prevents visual evidence from being overinterpreted without numerical, physical, or methodological support.

---

## 11. Closure criterion

This folder is considered properly organized when:

1. figures are grouped by thesis chapter,
2. file names are sufficiently descriptive,
3. each figure can be traced to a result stage,
4. each figure can be connected to code, tables, or thesis interpretation,
5. obsolete or duplicate figures are avoided unless they have a clear support function,
6. and the folder can be reviewed without requiring verbal explanation from the author.

---

## 12. Final note

This folder preserves the visual evidence of the doctoral thesis.

Its role is to support the transition from numerical results to scientific interpretation.

In the repository structure, `07_FIGURES/` provides the graphical layer of the complete evidence system:

```text
data
→ code
→ results
→ figures
→ tables
→ appendices
→ reproducibility
```

For that reason, this folder is essential for external academic review and for the visual verification of the thesis results.

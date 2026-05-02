# 02_model_comparison

## Purpose

This folder contains the structured documentation and outputs associated with deterministic model comparison for the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

It corresponds to the comparative predictive result layer of the thesis and supports the evaluation of forecasting models applied to **Wind Power Density (WPD)** and related wind-energy variables.

This folder is part of:

```text
04_RESULTS_COMPLETE/
```

and must be interpreted as a component of the complete scientific evidence layer of the repository.

---

## 1. Scientific role of this folder

The doctoral thesis does not evaluate predictive performance only through isolated goodness-of-fit indicators.

Instead, model comparison is interpreted through a physically meaningful forecasting framework in which each model must be evaluated against a baseline that represents the natural persistence of the atmospheric signal.

For that reason, the main comparison logic is based on:

- deterministic error metrics,
- explanatory capacity,
- horizon-based evaluation,
- zonal behavior,
- and improvement over persistence.

The central decision criterion is the **Skill Score versus persistence**, complemented by RMSE, MAE, and R².

---

## 2. Physical meaning of model comparison

The target variable of the thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

Because WPD depends cubically on wind speed, predictive errors in wind behavior may propagate nonlinearly into the energetic interpretation.

Therefore, model comparison is not only a statistical exercise. It is a physical evaluation of how well each modeling approach captures the temporal evolution of an energetic atmospheric quantity.

---

## 3. Modeling families considered in the thesis

The comparative framework of the thesis includes the following modeling families:

### 3.1 Classical time-series models

These models provide a statistical baseline for temporal forecasting and allow the thesis to evaluate the behavior of linear or semi-linear temporal structures.

Examples include:

- ARIMA,
- ARIMAX,
- and related classical forecasting structures.

### 3.2 Machine learning models

These models allow nonlinear relationships between predictors and the target variable to be explored.

Examples include:

- Random Forest,
- XGBoost,
- and related supervised learning models.

### 3.3 Deep learning models

These models are used to evaluate whether recurrent or sequential architectures improve forecasting performance in the presence of temporal dependence.

Examples include:

- LSTM-based architectures,
- optimized deep learning configurations,
- and horizon-based deep learning forecasts.

### 3.4 Hybrid physical–statistical integration

The thesis also considers an integrated modeling stage in which physical interpretation, statistical behavior, predictive performance, uncertainty, and energy interpretation are connected into a unified framework.

This stage should be interpreted as a hybrid physical–statistical integration layer, not as an isolated algorithmic comparison.

---

## 4. Evaluation metrics

The main deterministic evaluation metrics associated with this folder are:

| Metric | Meaning | Role in the thesis |
|---|---|---|
| **RMSE** | Root Mean Squared Error | Quantifies error magnitude with stronger penalization of large deviations. |
| **MAE** | Mean Absolute Error | Quantifies average absolute predictive error. |
| **R²** | Coefficient of determination | Measures explanatory or predictive capacity relative to variance. |
| **Skill Score** | Improvement relative to persistence | Principal criterion for deciding whether a model provides real predictive gain. |

---

## 5. Persistence baseline

Persistence is used as a reference benchmark because it represents a physically and operationally meaningful baseline in time-series forecasting.

A model is not considered scientifically strong only because it presents a high R² or low error in isolation. It must also demonstrate improvement over a simple persistence-based prediction.

This criterion is especially important in wind-energy forecasting because atmospheric variables often contain temporal autocorrelation. A model that does not improve over persistence may not add meaningful predictive value, even if some conventional metrics appear acceptable.

---

## 6. Skill Score interpretation

The Skill Score compares the error of a forecasting model against the error of a persistence benchmark.

Conceptually:

```text
Skill > 0  → the model improves over persistence
Skill = 0  → the model performs similarly to persistence
Skill < 0  → the model performs worse than persistence
```

Within the thesis, the Skill Score is interpreted as the principal deterministic criterion because it answers the central predictive question:

```text
Does the model add value beyond the natural persistence of the wind-energy signal?
```

---

## 7. Expected result outputs

This folder may contain or document outputs such as:

- winning models by zone and horizon,
- full deterministic metrics for WPD,
- RMSE by model, zone, and horizon,
- MAE by model, zone, and horizon,
- R² by model, zone, and horizon,
- Skill Score versus persistence,
- persistence baseline metrics,
- best-model selection logs,
- and deterministic model-comparison summaries.

If the corresponding tabular outputs are stored in `04_RESULTS_COMPLETE/08_TABLES/`, this folder should be interpreted as the conceptual and methodological result layer that explains how those tables must be read.

---

## 8. Current repository interpretation

At this stage of repository organization, this folder functions as the documentation node for deterministic model comparison.

If numerical CSV or Excel outputs are later added here, their naming should remain consistent with the following logic:

```text
target_metric_scope.csv
```

Examples:

```text
wpd_full_metrics_by_model_zone_horizon.csv
wpd_skill_vs_persistence_by_model.csv
wpd_winning_models_by_zone_horizon.csv
persistence_baseline_metrics.csv
deterministic_model_comparison_summary.csv
```

This naming criterion helps preserve interpretability, traceability, and consistency with the doctoral workflow.

---

## 9. Thesis linkage

This folder is aligned primarily with the predictive modeling stage of the thesis and supports the comparative results associated with Chapter 3.

It connects to:

- deterministic forecasting results for WPD,
- model comparison by zone,
- model comparison by prediction horizon,
- evaluation against persistence,
- and the selection of winning models using Skill Score as the main criterion.

The outputs and documentation in this folder should be interpreted together with the corresponding figures and tables organized in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

---

## 10. Relationship with code

The deterministic model-comparison results should be reproducible from the corresponding code folders:

```text
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
```

The last folder name reflects the current repository structure. Conceptually, in this results layer, it should be interpreted as the hybrid physical–statistical integration stage of the doctoral workflow.

The logical relationship is:

```text
processed zonal data
→ classical models
→ machine learning models
→ deep learning models
→ hybrid physical–statistical integration
→ deterministic metrics
→ comparison against persistence
→ selection of winning models
```

---

## 11. Relationship with the complete results folder

This folder is part of the broader result structure:

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

Within this structure, `02_model_comparison/` provides the deterministic predictive-evaluation layer.

It builds upon the physical characterization of wind behavior and prepares the transition toward uncertainty quantification, FNRR interpretation, and energy projection.

---

## 12. Methodological caution

This folder should not be interpreted as a simple ranking of algorithms.

In the thesis, model comparison is meaningful only when read under the following conditions:

- the same temporal-validation logic is respected,
- the same target variable is used,
- the same zonal structure is preserved,
- the same prediction horizons are compared,
- persistence is used as a benchmark,
- and deterministic results are later complemented by uncertainty analysis.

This prevents model selection from being reduced to isolated numerical performance.

---

## 13. Interpretation role

This folder supports one of the central doctoral claims:

Predictive modeling in wind-energy systems must be evaluated not only through conventional accuracy metrics, but through comparative gain against a physically meaningful baseline.

Therefore, the scientific function of this folder is to preserve the evidence required to justify why a model is useful, for which zone, under which horizon, and with what level of improvement over persistence.

---

## 14. Final note

This folder documents the deterministic model-comparison layer of the doctoral thesis.

Its role is to connect:

- physical characterization,
- forecasting models,
- deterministic metrics,
- persistence benchmarking,
- horizon-based evaluation,
- zonal interpretation,
- and later uncertainty and energetic analysis.

It is a central component of the repository because it supports the transition from physical understanding to predictive decision-making.

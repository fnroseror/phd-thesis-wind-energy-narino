# Chapter 3 Tables — Predictive Modeling, Model Comparison, and Uncertainty Support

## Purpose

This folder contains the tabular evidence associated with Chapter 3 of the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The tables in this folder support the predictive modeling stage of the thesis, including classical forecasting models, machine learning models, deep learning models, model comparison, WPD prediction, horizon-integrated energy prediction, uncertainty intervals, and hybrid physical–statistical integration outputs.

This folder is part of:

```text
04_RESULTS_COMPLETE/08_TABLES/
```

and should be interpreted as the numerical evidence layer for the predictive modeling and model-evaluation stage of the doctoral workflow.

---

## 1. Scientific role of these tables

Chapter 3 represents the transition from physical characterization to predictive modeling.

The tables contained in this folder document the numerical evidence required to evaluate how different model families behave when forecasting wind-energy-related variables under the zonal structure of Nariño.

The tabular evidence supports the following scientific sequence:

```text
physical characterization
→ predictive modeling
→ model comparison
→ deterministic metrics
→ uncertainty intervals
→ WPD prediction
→ horizon-integrated energy interpretation
→ hybrid physical–statistical synthesis
```

The central target variable of the thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

Because WPD depends cubically on wind speed, predictive errors may propagate nonlinearly into the energetic interpretation. For that reason, the tables in this folder are not only statistical outputs; they are numerical support for the physical and energetic interpretation of the forecasting problem.

---

## 2. Main table families

The current tables in this folder can be interpreted under the following families:

| Table family | Main role |
|---|---|
| Classical forecasting tables | Store outputs from classical time-series models for WPD and Eh. |
| Machine learning tables | Store base and optimized ML model outputs. |
| Deep learning tables | Store DL model results, complete outputs, and hyperparameter summaries. |
| Diagnostic tables | Document data availability and row structure by zone. |
| Prediction tables | Store final predictions by zone and horizon. |
| PIESS / interval tables | Store prediction intervals and probabilistic-support outputs. |
| FNRR tables | Support the structural interpretation of regional irregularity. |
| Global synthesis tables | Summarize final predictive behavior across zones, horizons, and regimes. |

---

## 3. Current tables in this folder

The current contents of this folder include the following files:

| File | Scientific function |
|---|---|
| `CLASICOS_DEFINITIVA_Eh.csv` | Stores final classical-model results for horizon-integrated energy. |
| `CLASICOS_DEFINITIVA_WPD.csv` | Stores final classical-model results for Wind Power Density. |
| `DIAGNOSTICO_FILAS_POR_ZONA.csv` | Documents row availability and diagnostic structure by zone. |
| `DL_HP_GLOBAL_TDQ.csv` | Stores global deep-learning hyperparameter information from the development workflow. |
| `DL_TABLA_COMBINADA_DEFINITIVA.csv` | Provides a combined deep-learning result table. |
| `DL_TABLA_Eh_COMPLETA.csv` | Stores complete deep-learning outputs for horizon-integrated energy. |
| `DL_TABLA_WPD_COMPLETA.csv` | Stores complete deep-learning outputs for Wind Power Density. |
| `DL_TUNING_WPD_Corto_h1.csv` | Documents tuning results for short-horizon WPD prediction. |
| `DL_TUNING_WPD_Medio_h12.csv` | Documents tuning results for medium-horizon WPD prediction. |
| `FNRR_RESUMEN_ZONA.csv` | Summarizes FNRR-related information by zone. |
| `ML_BASE_DEFINITIVA_Eh.csv` | Stores base machine-learning outputs for horizon-integrated energy. |
| `ML_BASE_DEFINITIVA_WPD.csv` | Stores base machine-learning outputs for Wind Power Density. |
| `ML_BAYES_DEFINITIVA_Eh.csv` | Stores optimized or Bayesian-supported ML outputs for horizon-integrated energy. |
| `ML_BAYES_DEFINITIVA_WPD.csv` | Stores optimized or Bayesian-supported ML outputs for Wind Power Density. |
| `TDQ_FINAL_PREDS_GLOBAL.csv` | Stores global final prediction outputs from the integrated workflow. |
| `TDQ_FINAL_TABLA_GLOBAL.csv` | Stores the global final synthesis table from the integrated workflow. |
| `TDQ_PIESS_INTERVALOS_PREDS.csv` | Stores interval-based prediction outputs associated with PIESS uncertainty support. |
| `TDQ_PIESS_PREDS_GLOBAL.csv` | Stores global PIESS prediction outputs. |
| `TDQ_PIESS_TABLA_GLOBAL.csv` | Stores global PIESS synthesis outputs. |
| `TDQ_PIESS_TABLA_GLOBAL_MEJORADA.csv` | Stores an improved global PIESS synthesis table. |
| `TDQ_PIESS_TABLA_POR_REGIMEN.csv` | Stores PIESS results organized by regime. |

In addition, this folder contains several prediction tables organized by zone and horizon for both the final integrated outputs and PIESS outputs.

---

## 4. Classical forecasting tables

### `CLASICOS_DEFINITIVA_WPD.csv`

This table stores final classical-model results for Wind Power Density.

Scientific interpretation:

It supports the comparison between classical time-series approaches and later machine learning or deep learning approaches.

Classical models are important because they provide a reference point for evaluating whether more complex models add predictive value.

---

### `CLASICOS_DEFINITIVA_Eh.csv`

This table stores final classical-model results for horizon-integrated energy.

Scientific interpretation:

It supports the evaluation of classical forecasting methods when the target is not only instantaneous WPD but also accumulated energetic behavior.

This distinction is important because energy interpretation often requires integration over a prediction horizon rather than only pointwise prediction.

---

## 5. Diagnostic table

### `DIAGNOSTICO_FILAS_POR_ZONA.csv`

This table documents row availability and diagnostic structure by zone.

Scientific interpretation:

It provides support for evaluating whether model results are based on comparable or heterogeneous data availability across the four analytical zones.

This is important because differences in available records can affect model training, validation, and interpretation.

---

## 6. Machine learning tables

### `ML_BASE_DEFINITIVA_WPD.csv`

This table stores base machine-learning outputs for Wind Power Density.

Scientific interpretation:

It supports evaluation of nonlinear supervised models before optimization or Bayesian-supported refinement.

---

### `ML_BASE_DEFINITIVA_Eh.csv`

This table stores base machine-learning outputs for horizon-integrated energy.

Scientific interpretation:

It supports evaluation of machine learning models when the prediction target is interpreted as accumulated energetic behavior.

---

### `ML_BAYES_DEFINITIVA_WPD.csv`

This table stores optimized or Bayesian-supported machine-learning outputs for WPD.

Scientific interpretation:

It supports evaluation of whether model refinement improves predictive performance for the central physical target variable.

---

### `ML_BAYES_DEFINITIVA_Eh.csv`

This table stores optimized or Bayesian-supported machine-learning outputs for Eh.

Scientific interpretation:

It supports evaluation of optimized ML behavior for horizon-integrated energetic prediction.

---

## 7. Deep learning tables

### `DL_TABLA_WPD_COMPLETA.csv`

This table stores complete deep-learning outputs for Wind Power Density.

Scientific interpretation:

It supports evaluation of sequential or deep learning architectures applied to WPD prediction.

Because wind-energy time series may contain temporal dependence, deep learning models are relevant for evaluating whether sequential patterns improve forecasting performance.

---

### `DL_TABLA_Eh_COMPLETA.csv`

This table stores complete deep-learning outputs for horizon-integrated energy.

Scientific interpretation:

It supports evaluation of deep learning architectures in accumulated energetic prediction.

---

### `DL_TABLA_COMBINADA_DEFINITIVA.csv`

This table provides a combined deep-learning result structure.

Scientific interpretation:

It allows integrated reading of deep learning outputs across targets, zones, or horizons, depending on the internal structure of the file.

---

### `DL_HP_GLOBAL_TDQ.csv`

This table stores global deep-learning hyperparameter information from the development workflow.

Scientific interpretation:

The label `TDQ` is preserved as a computational traceability label from the workflow. In the doctoral interpretation of this folder, the table should be read as part of the deep learning and hybrid physical–statistical modeling support.

---

### `DL_TUNING_WPD_Corto_h1.csv`

This table documents tuning results for short-horizon WPD prediction.

Scientific interpretation:

It supports the evaluation of hyperparameter behavior for near-term WPD forecasting.

---

### `DL_TUNING_WPD_Medio_h12.csv`

This table documents tuning results for medium-horizon WPD prediction.

Scientific interpretation:

It supports the evaluation of hyperparameter behavior when the prediction horizon increases.

---

## 8. Final prediction tables by zone and horizon

This folder contains final prediction tables organized by zone and horizon.

Examples include:

```text
TDQ_FINAL_PREDS_Z1_Corto_h1.csv
TDQ_FINAL_PREDS_Z1_Medio_h12.csv
TDQ_FINAL_PREDS_Z1_Largo_h72.csv

TDQ_FINAL_PREDS_Z2_Corto_h1.csv
TDQ_FINAL_PREDS_Z2_Medio_h12.csv
TDQ_FINAL_PREDS_Z2_Largo_h72.csv

TDQ_FINAL_PREDS_Z3_Corto_h1.csv
TDQ_FINAL_PREDS_Z3_Medio_h12.csv
TDQ_FINAL_PREDS_Z3_Largo_h72.csv

TDQ_FINAL_PREDS_Z4_Corto_h1.csv
TDQ_FINAL_PREDS_Z4_Medio_h12.csv
TDQ_FINAL_PREDS_Z4_Largo_h72.csv
```

Scientific interpretation:

These tables support the zone-specific and horizon-specific interpretation of model predictions.

The labels indicate:

| Label | Interpretation |
|---|---|
| `Z1`, `Z2`, `Z3`, `Z4` | Analytical zones defined in the dataset. |
| `Corto_h1` | Short prediction horizon. |
| `Medio_h12` | Medium prediction horizon. |
| `Largo_h72` | Long prediction horizon. |

The label `TDQ` is preserved for traceability to the development workflow. For doctoral evaluation, these files should be interpreted as final integrated prediction outputs within the hybrid physical–statistical stage of the thesis.

---

## 9. PIESS prediction and interval tables

This folder contains PIESS-related outputs, including:

```text
TDQ_PIESS_INTERVALOS_PREDS.csv
TDQ_PIESS_PREDS_GLOBAL.csv
TDQ_PIESS_TABLA_GLOBAL.csv
TDQ_PIESS_TABLA_GLOBAL_MEJORADA.csv
TDQ_PIESS_TABLA_POR_REGIMEN.csv
```

and zone/horizon-specific prediction files such as:

```text
TDQ_PIESS_PREDS_Z1_Corto_h1.csv
TDQ_PIESS_PREDS_Z1_Medio_h12.csv
TDQ_PIESS_PREDS_Z1_Largo_h72.csv

TDQ_PIESS_PREDS_Z2_Corto_h1.csv
TDQ_PIESS_PREDS_Z2_Medio_h12.csv
TDQ_PIESS_PREDS_Z2_Largo_h72.csv

TDQ_PIESS_PREDS_Z3_Corto_h1.csv
TDQ_PIESS_PREDS_Z3_Medio_h12.csv
TDQ_PIESS_PREDS_Z3_Largo_h72.csv

TDQ_PIESS_PREDS_Z4_Corto_h1.csv
TDQ_PIESS_PREDS_Z4_Medio_h12.csv
TDQ_PIESS_PREDS_Z4_Largo_h72.csv
```

Scientific interpretation:

These tables support the uncertainty-aware and integrated interpretation of predictive outputs.

The term `PIESS` is preserved as a computational workflow label. In the thesis interpretation, these outputs are related to interval-supported predictive synthesis, uncertainty-aware modeling, and regime-based interpretation.

---

## 10. FNRR support table

### `FNRR_RESUMEN_ZONA.csv`

This table summarizes FNRR-related information by zone.

Scientific interpretation:

It supports the connection between predictive modeling and structural regional irregularity.

This table helps transition from Chapter 3 predictive outputs toward Chapter 4 energetic interpretation, where FNRR is used to distinguish between free energy and structurally usable energy.

---

## 11. Global synthesis tables

### `TDQ_FINAL_PREDS_GLOBAL.csv`

This table stores global final prediction outputs from the integrated workflow.

Scientific interpretation:

It provides a broad synthesis of final predictions across zones, horizons, or target structures.

---

### `TDQ_FINAL_TABLA_GLOBAL.csv`

This table stores the global final synthesis table from the integrated workflow.

Scientific interpretation:

It supports the global interpretation of predictive performance and final model outputs.

---

### `TDQ_PIESS_TABLA_GLOBAL.csv`

This table stores global PIESS synthesis outputs.

Scientific interpretation:

It supports global uncertainty-aware interpretation of the integrated predictive workflow.

---

### `TDQ_PIESS_TABLA_GLOBAL_MEJORADA.csv`

This table stores an improved global PIESS synthesis table.

Scientific interpretation:

It may represent a refined version of the global PIESS table and should be interpreted as an enhanced synthesis output.

---

### `TDQ_PIESS_TABLA_POR_REGIMEN.csv`

This table stores PIESS results organized by regime.

Scientific interpretation:

It supports interpretation by predictive or energetic regime, allowing the thesis to distinguish model behavior under different structural conditions.

---

## 12. Relationship with Chapter 3 figures

These tables should be interpreted together with the visual evidence contained in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
```

The tables provide numerical evidence.

The figures provide visual interpretation.

Together, they support the predictive modeling and model-evaluation results of Chapter 3.

---

## 13. Relationship with model-comparison results

These tables are directly connected to:

```text
04_RESULTS_COMPLETE/02_model_comparison/
```

They provide numerical evidence for:

- classical models,
- machine learning models,
- deep learning models,
- prediction outputs,
- model comparison,
- and integrated predictive synthesis.

---

## 14. Relationship with PI90 uncertainty

The interval-related outputs in this folder should be interpreted together with:

```text
04_RESULTS_COMPLETE/03_pi90_uncertainty/
```

They support the probabilistic interpretation of model predictions and provide numerical evidence for uncertainty-aware forecasting.

---

## 15. Relationship with FNRR and energy projection

The FNRR-related outputs in this folder should be interpreted together with:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
```

These tables help connect predictive outputs with regional irregularity and later energetic interpretation.

---

## 16. Relationship with code

The tables in this folder should be reproducible from the predictive modeling workflow contained in:

```text
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
03_CODE/08_utils/
```

The folder `03_CODE/06_hybrid_tdq/` reflects the current repository naming. In the scientific interpretation of this tables folder, it should be understood as part of the hybrid physical–statistical integration stage of the doctoral workflow.

The logical relationship is:

```text
processed zonal data
→ classical models
→ machine learning models
→ deep learning models
→ model comparison
→ final predictions
→ uncertainty-aware synthesis
→ Chapter 3 tables
```

---

## 17. Interpretation of internal labels

Some file names include labels such as:

```text
TDQ
PIESS
BAYES
ML
DL
WPD
Eh
FNRR
```

These labels should be interpreted as internal workflow and traceability labels.

For doctoral evaluation, the tables should be read according to their scientific function:

- predictive modeling,
- deterministic model comparison,
- uncertainty-aware prediction,
- target-variable interpretation,
- zonal comparison,
- horizon comparison,
- FNRR support,
- and energy-related forecasting.

This distinction prevents internal development labels from being overinterpreted as separate theoretical claims.

---

## 18. Methodological caution

The tables in this folder should not be interpreted in isolation.

Each table must be read according to:

- the target variable,
- the modeling family,
- the zone analyzed,
- the prediction horizon,
- the corresponding figure,
- the metric or output represented,
- and the methodological purpose of Chapter 3.

This prevents numerical outputs from being interpreted without predictive, statistical, physical, or energetic context.

---

## 19. Interpretation role

The tabular evidence in this folder supports the following thesis position:

```text
Wind-energy prediction must be evaluated through model comparison,
zonal behavior, horizon dependence, deterministic metrics,
uncertainty-aware outputs, and energetic interpretation.
```

These tables provide the numerical foundation for evaluating whether the predictive framework contributes meaningful value beyond baseline or isolated model fitting.

---

## 20. Final note

This folder preserves the Chapter 3 numerical evidence of the doctoral thesis.

Its role is to support the predictive modeling stage and to connect model outputs with uncertainty, FNRR, WPD, Eh, and later energy-projection interpretation.

Together with the Chapter 3 figures, this folder provides the numerical evidence required to evaluate predictive behavior, model comparison, uncertainty-aware forecasting, and the transition toward the integrated energetic framework of the thesis.

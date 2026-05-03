# Appendix E — Extended Results for Chapter 3

## Purpose

This appendix documents the extended results associated with Chapter 3 of the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

Its purpose is to provide technical support for the predictive modeling stage of the thesis, including classical forecasting models, machine learning models, deep learning models, deterministic model comparison, uncertainty-aware outputs, residual analysis, and energy-related prediction results.

This appendix complements the Chapter 3 materials contained in:

```text
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

---

## E.1 Role of Chapter 3 in the thesis

Chapter 3 represents the transition from physical characterization to predictive modeling.

After Chapter 2 establishes the physical and statistical structure of wind behavior in Nariño, Chapter 3 evaluates whether that atmospheric signal can be forecasted using classical, machine learning, deep learning, and integrated physical–statistical modeling approaches.

The general logic of Chapter 3 is:

```text
physical characterization
→ target-variable construction
→ model training
→ model validation
→ deterministic evaluation
→ comparison against persistence
→ uncertainty-aware prediction
→ residual analysis
→ energy-related interpretation
```

This chapter is essential because the thesis is not limited to describing wind behavior. It evaluates whether wind-energy-related quantities can be predicted with meaningful improvement over a physically relevant baseline.

---

## E.2 Central target variable

The central target variable of the doctoral thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

WPD is central because it connects atmospheric motion with energetic potential.

The cubic dependence on wind speed means that prediction errors may propagate nonlinearly into the energetic interpretation. For that reason, Chapter 3 evaluates predictive behavior not only as a statistical problem, but as a physical–energetic modeling problem.

---

## E.3 Secondary energetic quantity: Eh

Chapter 3 also includes **Eh**, interpreted as horizon-integrated energy.

Conceptually:

```text
Eh = accumulated or integrated energetic quantity over a prediction horizon
```

Eh allows the thesis to move from pointwise power-density prediction toward accumulated energetic interpretation.

This is relevant because energy systems are not evaluated only through instantaneous values, but also through energy accumulated over operational horizons.

---

## E.4 Prediction horizons

The predictive modeling stage evaluates different horizons.

The main horizon labels used in the repository are:

| Horizon label | Interpretation |
|---|---|
| `Corto_h1` or `h001` | Short-horizon prediction. |
| `Medio_h12` or `h012` | Medium-horizon prediction. |
| `Largo_h72` or `h072` | Long-horizon prediction. |

The horizon structure is important because prediction difficulty generally increases as the forecasting horizon grows.

For this reason, model performance must be interpreted by:

- target variable,
- zone,
- prediction horizon,
- model family,
- deterministic metric,
- uncertainty behavior,
- and residual structure.

---

## E.5 Zonal structure

All predictive results must be interpreted according to the four analytical zones defined in the thesis:

```text
Z1, Z2, Z3, Z4
```

The station-to-zone structure is documented in:

```text
02_DATA_METADATA/03_station_zone_mapping.md
05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
```

The zonal structure is important because wind behavior is regionally heterogeneous. A model may perform well in one zone and not necessarily in another.

Therefore, Chapter 3 results should not be interpreted only as global metrics. They must also be interpreted as zone-dependent predictive behavior.

---

## E.6 Model families evaluated

Chapter 3 includes several model families.

Each family plays a different methodological role in the thesis.

---

### E.6.1 Classical forecasting models

Classical models provide a statistical reference for time-series forecasting.

They include models such as:

- ARIMA,
- ARIMAX,
- and related time-series forecasting structures.

Associated repository locations:

```text
03_CODE/03_classical_models/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

Relevant table files include:

```text
CLASICOS_DEFINITIVA_WPD.csv
CLASICOS_DEFINITIVA_Eh.csv
```

Scientific role:

Classical models help evaluate whether conventional temporal structures can capture part of the behavior of WPD and Eh.

They also provide an intermediate reference between persistence and more complex machine learning or deep learning models.

---

### E.6.2 Machine learning models

Machine learning models are used to evaluate nonlinear predictive behavior.

The repository includes outputs associated with:

- Random Forest,
- XGBoost,
- base ML configurations,
- and optimized or Bayesian-supported ML configurations.

Associated repository locations:

```text
03_CODE/04_machine_learning/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
```

Relevant table files include:

```text
ML_BASE_DEFINITIVA_WPD.csv
ML_BASE_DEFINITIVA_Eh.csv
ML_BAYES_DEFINITIVA_WPD.csv
ML_BAYES_DEFINITIVA_Eh.csv
```

Scientific role:

Machine learning models allow the thesis to evaluate whether nonlinear relationships between meteorological variables and energetic targets improve predictive performance.

This is especially relevant for WPD because its physical formulation is nonlinear.

---

### E.6.3 Deep learning models

Deep learning models are used to evaluate whether sequential architectures improve prediction in the presence of temporal dependence.

The main deep learning architecture represented in the repository is LSTM-based modeling.

Associated repository locations:

```text
03_CODE/05_deep_learning/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
```

Relevant table files include:

```text
DL_TABLA_WPD_COMPLETA.csv
DL_TABLA_Eh_COMPLETA.csv
DL_TABLA_COMBINADA_DEFINITIVA.csv
DL_HP_GLOBAL_TDQ.csv
DL_TUNING_WPD_Corto_h1.csv
DL_TUNING_WPD_Medio_h12.csv
```

Scientific role:

Deep learning models support the evaluation of temporal learning capacity across zones and horizons.

Because wind-energy series may contain persistence, intermittency, and nonlinear temporal behavior, sequential models provide an important comparison layer.

---

### E.6.4 Hybrid physical–statistical integration

The repository contains an internal development folder named:

```text
03_CODE/06_hybrid_tdq/
```

For doctoral evaluation, this stage should be interpreted as the hybrid physical–statistical integration layer of the thesis.

Scientific role:

This stage integrates:

- physical target construction,
- deterministic prediction,
- uncertainty-aware interpretation,
- FNRR support,
- and energy-related outputs.

The internal label `TDQ` may appear in file names as a workflow traceability label. In this appendix, those files are interpreted according to their scientific function within the predictive and energetic modeling workflow.

---

## E.7 Deterministic evaluation metrics

The main deterministic metrics used in Chapter 3 are:

| Metric | Meaning | Role in the thesis |
|---|---|---|
| **RMSE** | Root Mean Squared Error | Quantifies predictive error with stronger penalization of large deviations. |
| **MAE** | Mean Absolute Error | Quantifies average absolute predictive error. |
| **R²** | Coefficient of determination | Provides complementary information about explained variance. |
| **Skill Score** | Improvement relative to persistence | Principal criterion for evaluating predictive gain. |

---

## E.8 Persistence baseline

Persistence is the main benchmark used in the thesis.

Persistence is important because atmospheric time series often contain temporal dependence. A model may appear useful through conventional metrics but fail to improve over a simple persistence-based prediction.

The central predictive question is:

```text
Does the model add value beyond the natural persistence of the wind-energy signal?
```

This is why the Skill Score versus persistence is treated as a principal deterministic criterion.

Conceptually:

```text
Skill > 0  → model improves over persistence
Skill = 0  → model behaves similarly to persistence
Skill < 0  → model performs worse than persistence
```

---

## E.9 Global model-performance figures

The Chapter 3 visual evidence is located in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
```

Key global performance figures include:

```text
01_Skill_vs_Persist.png
02_R2.png
03_RMSE.png
04_Coverage_PI90_before_after.png
05_FNRR_density_by_zone.png
```

### Scientific interpretation

These figures provide a visual synthesis of model performance.

They support interpretation of:

- predictive improvement over persistence,
- explanatory capacity,
- prediction error magnitude,
- uncertainty calibration,
- and the transition toward regional irregularity interpretation.

The figures should be interpreted together with the Chapter 3 tables in:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

---

## E.10 Skill Score visual evidence

The figure:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/01_Skill_vs_Persist.png
```

supports the evaluation of model improvement relative to persistence.

Scientific interpretation:

This figure is central because it visually addresses whether the predictive framework provides meaningful improvement beyond a simple temporal baseline.

In a wind-energy context, outperforming persistence is important because wind-related variables may contain autocorrelation. A model that does not outperform persistence may not provide practical predictive value.

---

## E.11 R² visual evidence

The figure:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/02_R2.png
```

supports the interpretation of explained variance.

Scientific interpretation:

R² provides useful complementary evidence, but it should not be interpreted in isolation.

In the thesis, R² must be read together with:

- RMSE,
- MAE,
- Skill Score,
- horizon behavior,
- residual structure,
- and uncertainty calibration.

---

## E.12 RMSE visual evidence

The figure:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/03_RMSE.png
```

supports the interpretation of prediction error magnitude.

Scientific interpretation:

RMSE is relevant because large errors are penalized more strongly.

In the context of WPD, this matters because large errors may have amplified energetic consequences due to the cubic dependence on wind speed.

---

## E.13 PI90 coverage visual evidence

The figure:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/04_Coverage_PI90_before_after.png
```

supports the probabilistic uncertainty component of Chapter 3.

Scientific interpretation:

This figure compares empirical coverage before and after calibration.

It shows that the thesis does not interpret forecasting only through point predictions. It also evaluates whether the associated uncertainty intervals are probabilistically meaningful.

---

## E.14 FNRR density support figure

The figure:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/05_FNRR_density_by_zone.png
```

acts as a bridge between Chapter 3 and Chapter 4.

Scientific interpretation:

This figure provides visual support for regional irregularity behavior and prepares the transition toward FNRR-based energetic interpretation.

It should be read as an intermediate support figure connecting predictive results with structural energy interpretation.

---

## E.15 Representative horizon figures

The folder contains representative prediction examples such as:

```text
06_Example_Corto_h1.png
07_Example_Medio_h12.png
```

Scientific interpretation:

These figures help reviewers inspect model behavior at specific horizons.

Short-horizon examples support evaluation of near-term predictive tracking.

Medium-horizon examples support evaluation of model stability as the prediction horizon increases.

Together, these figures provide visual evidence of horizon-dependent predictive behavior.

---

## E.16 WPD prediction curves

The Chapter 3 figure folder contains WPD prediction curves organized by zone and horizon.

Examples include:

```text
CURVA_WPD_Z1_Corto_h1_LSTM_TDQ_BAYES.png
CURVA_WPD_Z1_Medio_h12_LSTM_TDQ_BAYES.png
CURVA_WPD_Z1_Largo_h72_LSTM_TDQ_BAYES.png

CURVA_WPD_Z2_Corto_h1_LSTM_TDQ_BAYES.png
CURVA_WPD_Z2_Medio_h12_LSTM_TDQ_BAYES.png
CURVA_WPD_Z2_Largo_h72_LSTM_TDQ_BAYES.png

CURVA_WPD_Z3_Corto_h1_LSTM_TDQ_BAYES.png
CURVA_WPD_Z3_Medio_h12_LSTM_TDQ_BAYES.png
CURVA_WPD_Z3_Largo_h72_LSTM_TDQ_BAYES.png

CURVA_WPD_Z4_Corto_h1_LSTM_TDQ_BAYES.png
CURVA_WPD_Z4_Medio_h12_LSTM_TDQ_BAYES.png
CURVA_WPD_Z4_Largo_h72_LSTM_TDQ_BAYES.png
```

Scientific interpretation:

These figures allow the reviewer to inspect predicted WPD behavior by zone and horizon.

They support evaluation of:

- local model tracking,
- horizon-dependent degradation,
- zone-specific behavior,
- deviations between observed and predicted structures,
- and the energetic consequences of model performance.

The label `TDQ_BAYES` appears as an internal workflow and optimization label. For the doctoral interpretation, these figures should be read as part of the hybrid physical–statistical predictive stage.

---

## E.17 Publication-oriented WPD figures

The folder contains publication-oriented WPD figures with names such as:

```text
ELSEVIER_WPD_Z1_Corto_h1_XGB_Bayes.png
ELSEVIER_WPD_Z1_Medio_h12_XGB_Bayes.png
ELSEVIER_WPD_Z1_Largo_h72_XGB_Bayes.png

ELSEVIER_WPD_Z2_Corto_h1_XGB.png
ELSEVIER_WPD_Z2_Medio_h12_XGB.png
ELSEVIER_WPD_Z2_Largo_h72_XGB.png

ELSEVIER_WPD_Z3_Corto_h1_XGB.png
ELSEVIER_WPD_Z3_Medio_h12_XGB.png
ELSEVIER_WPD_Z3_Largo_h72_XGB.png

ELSEVIER_WPD_Z4_Corto_h1_RF.png
ELSEVIER_WPD_Z4_Medio_h12_RF.png
ELSEVIER_WPD_Z4_Largo_h72_RF.png
```

Scientific interpretation:

These figures provide refined visual summaries of WPD prediction behavior.

The `ELSEVIER` label should be interpreted as a formatting or product-orientation label, not as a publication-status claim.

---

## E.18 Integrated WPD panel

The figure:

```text
FIGURA_3_4_PANEL_WPD.png
```

provides an integrated visual synthesis of WPD prediction behavior.

Scientific interpretation:

This figure is useful because it condenses several predictive conditions into a single panel.

It supports comparative interpretation across zones, horizons, or model outputs depending on the internal organization of the figure.

This type of figure is valuable for thesis defense because it allows complex predictive evidence to be communicated visually.

---

## E.19 Eh prediction figures

The Chapter 3 figure folder also contains Eh-related figures, including files such as:

```text
ANEXO_Eh_Z1_Corto_ML_BAYES_XGB_Bayes.png
ANEXO_Eh_Z1_Medio_ML_BAYES_XGB_Bayes.png
ANEXO_Eh_Z1_Largo_ML_BAYES_XGB_Bayes.png

ANEXO_Eh_Z2_Corto_ML_BAYES_XGB.png
ANEXO_Eh_Z2_Medio_ML_BAYES_XGB.png
ANEXO_Eh_Z2_Largo_ML_BAYES_XGB.png

ANEXO_Eh_Z3_Corto_ML_BAYES_XGB.png
ANEXO_Eh_Z3_Medio_ML_BAYES_XGB.png
ANEXO_Eh_Z3_Largo_ML_BAYES_XGB.png

ANEXO_Eh_Z4_Corto_ML_BAYES_RF.png
ANEXO_Eh_Z4_Medio_ML_BAYES_RF.png
ANEXO_Eh_Z4_Largo_ML_BAYES_RF.png
```

Scientific interpretation:

These figures support the transition from pointwise WPD prediction to horizon-integrated energy interpretation.

Eh figures are relevant because energy forecasting is not only about instantaneous power density, but also about accumulated energetic behavior over a prediction horizon.

---

## E.20 Nature-style WPD and Eh figures

The folder contains additional publication-oriented visualizations named with the `NATURE_` prefix.

Examples include:

```text
NATURE_WPD_Z1_Corto_h001.png
NATURE_WPD_Z1_Medio_h012.png
NATURE_WPD_Z1_Largo_h072.png

NATURE_Eh_Z1_Corto_h001.png
NATURE_Eh_Z1_Medio_h012.png
NATURE_Eh_Z1_Largo_h072.png
```

and equivalent figures for the other zones.

Scientific interpretation:

These figures should be interpreted as refined graphical outputs for scientific communication.

The `NATURE` prefix should be interpreted as a formatting or product-orientation label, not as a publication-status claim.

---

## E.21 Residual analysis

The Chapter 3 figure folder contains residual figures for WPD and Eh.

Examples include:

```text
RESID_WPD_Z1_Corto_h1_LSTM_TDQ_BAYES.png
RESID_WPD_Z1_Medio_h12_LSTM_TDQ_BAYES.png
RESID_WPD_Z1_Largo_h72_LSTM_TDQ_BAYES.png

RESID_Eh_Z1_Corto_h1_LSTM_TDQ_BAYES.png
RESID_Eh_Z1_Medio_h12_LSTM_TDQ_BAYES.png
RESID_Eh_Z1_Largo_h72_LSTM_TDQ_BAYES.png
```

and equivalent figures for the other zones.

Scientific interpretation:

Residual analysis supports diagnostic evaluation of prediction errors.

Residual figures help determine whether errors:

- are randomly distributed,
- show systematic structure,
- increase with horizon,
- differ by zone,
- or suggest model limitations.

This is important because good global metrics may hide structured error behavior.

---

## E.22 Chapter 3 table families

The Chapter 3 numerical evidence is located in:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

The main table families include:

- classical model tables,
- machine learning tables,
- deep learning tables,
- hyperparameter tuning tables,
- final prediction tables,
- PIESS and interval-support tables,
- FNRR-support tables,
- and global synthesis tables.

These tables provide the numerical basis for interpreting the figures and predictive results.

---

## E.23 Classical model tables

Relevant files include:

```text
CLASICOS_DEFINITIVA_WPD.csv
CLASICOS_DEFINITIVA_Eh.csv
```

Scientific interpretation:

These files support evaluation of classical time-series models for WPD and Eh.

They help establish whether conventional temporal methods provide useful predictive performance before comparing them with ML and DL approaches.

---

## E.24 Machine learning tables

Relevant files include:

```text
ML_BASE_DEFINITIVA_WPD.csv
ML_BASE_DEFINITIVA_Eh.csv
ML_BAYES_DEFINITIVA_WPD.csv
ML_BAYES_DEFINITIVA_Eh.csv
```

Scientific interpretation:

These tables support the comparison between base and optimized machine learning models.

They provide numerical evidence for assessing whether model refinement improves WPD or Eh prediction.

---

## E.25 Deep learning tables

Relevant files include:

```text
DL_TABLA_WPD_COMPLETA.csv
DL_TABLA_Eh_COMPLETA.csv
DL_TABLA_COMBINADA_DEFINITIVA.csv
DL_HP_GLOBAL_TDQ.csv
DL_TUNING_WPD_Corto_h1.csv
DL_TUNING_WPD_Medio_h12.csv
```

Scientific interpretation:

These tables provide deep learning outputs and hyperparameter-support information.

The label `TDQ` is preserved as an internal workflow label. For doctoral evaluation, these files should be interpreted as deep learning and hybrid physical–statistical support outputs.

---

## E.26 Final prediction tables

The folder includes final prediction outputs by zone and horizon, such as:

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

These files support zone-specific and horizon-specific predictive interpretation.

They should be read as final integrated prediction outputs within the hybrid physical–statistical modeling stage.

---

## E.27 PIESS and interval-support tables

Relevant files include:

```text
TDQ_PIESS_INTERVALOS_PREDS.csv
TDQ_PIESS_PREDS_GLOBAL.csv
TDQ_PIESS_TABLA_GLOBAL.csv
TDQ_PIESS_TABLA_GLOBAL_MEJORADA.csv
TDQ_PIESS_TABLA_POR_REGIMEN.csv
```

and zone/horizon-specific prediction files.

Scientific interpretation:

These files support uncertainty-aware predictive synthesis.

The term `PIESS` is preserved as a computational workflow label. In the thesis interpretation, these outputs are related to interval-supported prediction, regime-based synthesis, and uncertainty-aware modeling.

---

## E.28 FNRR support table

Relevant file:

```text
FNRR_RESUMEN_ZONA.csv
```

Scientific interpretation:

This file supports the connection between predictive modeling and regional irregularity interpretation.

It prepares the transition from Chapter 3 toward Chapter 4, where FNRR is used to distinguish between free energy and structurally usable energy.

---

## E.29 Global synthesis tables

Relevant files include:

```text
TDQ_FINAL_PREDS_GLOBAL.csv
TDQ_FINAL_TABLA_GLOBAL.csv
TDQ_PIESS_TABLA_GLOBAL.csv
TDQ_PIESS_TABLA_GLOBAL_MEJORADA.csv
TDQ_PIESS_TABLA_POR_REGIMEN.csv
```

Scientific interpretation:

These files provide synthesis outputs across zones, horizons, regimes, and predictive structures.

They support the general interpretation of Chapter 3 results and help connect model outputs with uncertainty-aware and energy-related analysis.

---

## E.30 Relationship with PI90 uncertainty

The probabilistic uncertainty layer is documented in:

```text
04_RESULTS_COMPLETE/03_pi90_uncertainty/
```

and supported by figures and tables in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

PI90 outputs are important because they allow the thesis to move from deterministic point predictions to probabilistic forecast interpretation.

The central probabilistic idea is:

```text
A useful forecast should not only estimate a central value,
but also quantify the uncertainty around that estimate.
```

---

## E.31 Relationship with Chapter 2

Chapter 3 depends on the physical characterization developed in Chapter 2.

The transition is:

```text
Chapter 2 physical characterization
→ temporal and distributional understanding
→ predictive modeling design
→ Chapter 3 model evaluation
```

Chapter 2 provides evidence that wind behavior is structured, heterogeneous, and temporally organized. Chapter 3 tests whether that structure can be used for prediction.

---

## E.32 Relationship with Chapter 4

Chapter 3 provides the predictive basis for Chapter 4.

The transition is:

```text
Chapter 3 predictions
→ uncertainty-aware outputs
→ FNRR structural interpretation
→ free energy
→ usable energy
→ energy projection
```

Therefore, Chapter 3 is the bridge between physical characterization and regional energy projection.

---

## E.33 Relationship with code

The Chapter 3 extended results should be reproducible from:

```text
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
03_CODE/08_utils/
```

The folder `03_CODE/06_hybrid_tdq/` reflects the current repository naming. In this appendix, it should be interpreted as part of the hybrid physical–statistical integration stage.

The computational relationship is:

```text
processed zonal data
→ target-variable construction
→ classical models
→ machine learning models
→ deep learning models
→ integrated prediction outputs
→ uncertainty support
→ Chapter 3 extended results
```

---

## E.34 Repository locations associated with Chapter 3

The main repository locations associated with Chapter 3 are:

```text
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
```

Each location has a specific role:

| Repository location | Role |
|---|---|
| `04_RESULTS_COMPLETE/02_model_comparison/` | Documents deterministic model comparison. |
| `04_RESULTS_COMPLETE/03_pi90_uncertainty/` | Documents probabilistic uncertainty support. |
| `04_RESULTS_COMPLETE/07_FIGURES/chapter_3/` | Stores visual evidence for Chapter 3. |
| `04_RESULTS_COMPLETE/08_TABLES/chapter_3/` | Stores numerical evidence for Chapter 3. |
| `03_CODE/03_classical_models/` | Contains classical forecasting logic. |
| `03_CODE/04_machine_learning/` | Contains machine learning logic. |
| `03_CODE/05_deep_learning/` | Contains deep learning logic. |
| `03_CODE/06_hybrid_tdq/` | Contains the integrated physical–statistical workflow under the current repository naming. |

---

## E.35 Interpretation of internal workflow labels

Some files include labels such as:

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

These labels should be interpreted as internal workflow, modeling, optimization, formatting, or product-orientation labels.

For doctoral evaluation, the relevant scientific functions are:

- predictive modeling,
- deterministic model comparison,
- uncertainty-aware prediction,
- WPD prediction,
- Eh interpretation,
- FNRR support,
- residual analysis,
- and transition toward energy projection.

This distinction prevents internal development labels from being overinterpreted as separate theoretical or publication claims.

---

## E.36 Methodological caution

The extended results of Chapter 3 should not be interpreted as a simple competition between algorithms.

Model interpretation must consider:

- target variable,
- zone,
- prediction horizon,
- validation logic,
- persistence benchmark,
- deterministic metrics,
- uncertainty calibration,
- residual behavior,
- and energetic meaning.

A model that performs well under one condition should not automatically be generalized to all zones, horizons, or target variables.

---

## E.37 What this appendix does not claim

This appendix does not claim that a single model universally dominates every condition.

It does not claim that high R² alone is sufficient to validate a model.

It does not claim that deterministic accuracy eliminates uncertainty.

It does not claim that projected or predicted values are direct observations.

Instead, it documents extended evidence supporting model comparison, uncertainty-aware prediction, and the transition from predictive modeling to energetic interpretation.

---

## E.38 Closure criterion

The extended results of Chapter 3 are considered sufficiently documented when:

1. model families are identified,
2. target variables are distinguished,
3. prediction horizons are defined,
4. deterministic metrics are interpreted,
5. persistence is included as a benchmark,
6. PI90 uncertainty is included,
7. WPD and Eh outputs are documented,
8. residual analysis is acknowledged,
9. figures are connected to tables,
10. tables are connected to code,
11. internal labels are interpreted with caution,
12. and Chapter 3 is clearly linked to Chapters 2 and 4.

---

## E.39 Final statement

The extended results of Chapter 3 provide the predictive evidence layer of the doctoral thesis.

Their central message is:

```text
Forecasting wind-energy potential requires more than fitting models;
it requires physical target construction, comparison against persistence,
uncertainty-aware evaluation, horizon-based interpretation,
zonal analysis, and energetic meaning.
```

For that reason, Appendix E supports the scientific transition from physical characterization to uncertainty-aware predictive modeling and regional energy projection.

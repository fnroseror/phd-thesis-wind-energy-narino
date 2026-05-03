# Appendix C — Experimental Configuration

## Purpose

This appendix documents the experimental configuration used in the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

Its purpose is to define the modeling structure, target variables, spatial organization, prediction horizons, model families, evaluation metrics, uncertainty criteria, and reproducibility logic used in the computational workflow of the thesis.

This appendix complements:

```text
03_CODE/
04_RESULTS_COMPLETE/
07_REPRODUCIBILITY/
```

and should be interpreted as the experimental-design support document of the doctoral repository.

---

## C.1 Role of the experimental configuration

The experimental configuration defines how the thesis moves from processed meteorological data to predictive and energetic results.

The general experimental logic is:

```text
processed zonal data
→ derived physical variables
→ target-variable construction
→ model training
→ model validation
→ deterministic evaluation
→ comparison against persistence
→ PI90 uncertainty assessment
→ FNRR structural interpretation
→ energy projection
```

This appendix is important because it documents the rules under which the computational results should be interpreted.

Without a clear experimental configuration, model comparison could become a disconnected ranking of algorithms. In this thesis, model comparison is interpreted under a physical, statistical, temporal, zonal, and energetic framework.

---

## C.2 General experimental system

The experimental system is based on the following components:

| Component | Description |
|---|---|
| Observational basis | Meteorological records from the Nariño station network. |
| Spatial unit | Four analytical zones defined in the doctoral dataset. |
| Main observed variable | Wind speed (`VV`). |
| Main derived target | Wind Power Density (`WPD`). |
| Derived energetic quantity | Horizon-integrated energy (`Eh`). |
| Structural descriptor | Factor de No Regularidad Regional (`FNRR`). |
| Uncertainty representation | 90% prediction intervals (`PI90`). |
| Main benchmark | Persistence model. |
| Main deterministic criterion | Skill Score versus persistence. |
| Complementary metrics | RMSE, MAE, and R². |

The experimental configuration is therefore not only statistical. It is designed to preserve physical interpretability and regional energetic meaning.

---

## C.3 Spatial configuration

The thesis uses four analytical zones as the operational spatial structure.

The zones are defined in:

```text
02_DATA_METADATA/03_station_zone_mapping.md
05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
```

The zonal structure supports:

- physical characterization by region,
- comparison of wind regimes,
- model training and evaluation by zone,
- uncertainty interpretation by zone,
- FNRR computation by zone,
- and energy projection by zone.

The zone is therefore the basic spatial unit for experimental analysis.

The general spatial notation is:

```text
Z1, Z2, Z3, Z4
```

Each model output, metric, figure, and table should be interpreted in relation to its corresponding zone whenever applicable.

---

## C.4 Temporal configuration

The observational period used in the thesis corresponds to:

```text
2017–2022
```

The energy-projection stage extends the interpretation toward:

```text
2028
```

The historical period provides the empirical basis for model development, while the projected period represents a model-based energetic scenario.

The temporal organization is essential for:

- time-series modeling,
- temporal validation,
- horizon-based forecasting,
- uncertainty evaluation,
- and energy integration.

The experimental configuration should preserve temporal ordering and avoid random mixing of observations when time dependence is relevant.

---

## C.5 Prediction horizons

The thesis evaluates predictive behavior across different horizons.

The main horizon labels used in the repository are:

| Label | Horizon interpretation | Repository notation |
|---|---|---|
| Short horizon | Near-term prediction | `Corto_h1` or `h001` |
| Medium horizon | Intermediate prediction | `Medio_h12` or `h012` |
| Long horizon | Extended prediction | `Largo_h72` or `h072` |

The horizon structure is important because forecasting difficulty generally increases as the prediction horizon grows.

The experimental interpretation must therefore consider not only which model performs best, but also:

- in which zone,
- for which target variable,
- under which horizon,
- and with what uncertainty behavior.

---

## C.6 Target variables

The experimental configuration distinguishes between observed, derived, and energetic target variables.

### C.6.1 Observed basis

The primary observed variable is:

```text
VV — wind speed
```

Wind speed is the fundamental observed atmospheric quantity used to construct the energetic target of the thesis.

---

### C.6.2 Air density

Air density is represented as:

```text
ρ
```

It is derived from atmospheric variables such as pressure and temperature under the physical approximation used in the thesis.

Air density is required for constructing Wind Power Density.

---

### C.6.3 Wind Power Density

The central target variable of the thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

This variable is central because it connects atmospheric motion with energetic potential.

The cubic dependence on wind speed makes WPD highly sensitive to changes in wind behavior. For that reason, model errors in wind-related prediction may propagate nonlinearly into the energetic interpretation.

---

### C.6.4 Horizon-integrated energy

The thesis also uses **Eh**, interpreted as horizon-integrated energy.

Conceptually:

```text
Eh = accumulated or integrated energetic quantity over a prediction horizon
```

Eh supports the interpretation of energy not only as an instantaneous quantity, but as accumulated behavior over forecasting horizons.

This is important because energy systems are often evaluated through integrated production potential rather than isolated pointwise values.

---

### C.6.5 Free and usable energy

The thesis distinguishes between:

```text
E_free
```

and

```text
E_usable
```

where:

- `E_free` represents physically available energetic potential before structural irregularity adjustment.
- `E_usable` represents the energetic component after adjustment through FNRR.

The conceptual relationship is:

```text
E_usable = (1 − FNRR) · E_free
```

This relationship allows the thesis to avoid treating all physically available energy as fully usable energy.

---

## C.7 Model families

The experimental configuration includes several model families.

Each family has a different scientific role in the thesis.

---

### C.7.1 Classical time-series models

Classical models provide a statistical reference for temporal forecasting.

They include models such as:

- ARIMA,
- ARIMAX,
- and related time-series configurations.

Scientific role:

Classical models allow the thesis to evaluate whether conventional statistical forecasting structures can capture the temporal behavior of WPD or energetic variables.

They also provide an intermediate baseline between persistence and more complex machine learning or deep learning methods.

Associated repository location:

```text
03_CODE/03_classical_models/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

---

### C.7.2 Machine learning models

Machine learning models are used to evaluate nonlinear predictive behavior.

The main ML models used in the repository include:

- Random Forest,
- XGBoost,
- and optimized or Bayesian-supported variants.

Scientific role:

Machine learning models allow the thesis to evaluate whether nonlinear relationships improve predictive performance compared with classical methods.

They are especially relevant when the target variable is WPD, because the relationship between atmospheric variables and energetic output may be nonlinear.

Associated repository location:

```text
03_CODE/04_machine_learning/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
```

---

### C.7.3 Deep learning models

Deep learning models are used to evaluate whether sequential architectures can improve prediction under temporal dependence.

The main deep learning family represented in the repository is:

- LSTM-based modeling.

Scientific role:

LSTM models are relevant because wind-energy time series may contain temporal dependencies that are not fully captured by static supervised learning models.

Deep learning outputs support the evaluation of temporal learning capacity across zones and horizons.

Associated repository location:

```text
03_CODE/05_deep_learning/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
```

---

### C.7.4 Hybrid physical–statistical integration

The repository contains a folder named:

```text
03_CODE/06_hybrid_tdq/
```

This name reflects the internal development workflow.

For doctoral evaluation, this stage should be interpreted as the hybrid physical–statistical integration layer of the thesis.

Scientific role:

This stage integrates:

- physical target construction,
- predictive modeling,
- uncertainty interpretation,
- FNRR computation,
- and energy projection.

The goal is not only to select an algorithm, but to connect model outputs with physically meaningful energy interpretation.

Associated repository location:

```text
03_CODE/06_hybrid_tdq/
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

---

## C.8 Benchmark model: persistence

Persistence is the main benchmark used in the thesis.

Conceptually, persistence assumes that the future value is equal or closely related to the most recent observed value.

Persistence is important because atmospheric time series often contain temporal autocorrelation. A model that does not outperform persistence may not provide meaningful predictive gain.

The thesis therefore evaluates model performance not only through absolute metrics, but through improvement relative to persistence.

The key question is:

```text
Does the model add predictive value beyond the natural persistence of the atmospheric signal?
```

---

## C.9 Deterministic evaluation metrics

The main deterministic metrics used in the experimental configuration are:

| Metric | Meaning | Role in the thesis |
|---|---|---|
| RMSE | Root Mean Squared Error | Measures error magnitude with stronger penalization of large deviations. |
| MAE | Mean Absolute Error | Measures average absolute prediction error. |
| R² | Coefficient of determination | Measures explanatory or predictive capacity. |
| Skill Score | Improvement relative to persistence | Principal deterministic criterion for model selection. |

---

### C.9.1 RMSE

RMSE is used to evaluate the magnitude of prediction error.

It is especially relevant when large errors should be penalized more strongly.

In the context of WPD, large errors are important because energetic interpretation may be sensitive to extreme deviations.

---

### C.9.2 MAE

MAE provides a complementary measure of average absolute error.

It is less sensitive to extreme deviations than RMSE and supports a more robust interpretation of average predictive error.

---

### C.9.3 R²

R² provides information about the proportion of variance explained by the model.

In this thesis, R² is interpreted as a complementary metric.

It should not be used alone to decide the best model.

---

### C.9.4 Skill Score versus persistence

Skill Score is the principal deterministic criterion of the thesis.

Conceptually:

```text
Skill > 0  → model improves over persistence
Skill = 0  → model behaves similarly to persistence
Skill < 0  → model performs worse than persistence
```

This metric is central because it evaluates whether the model contributes real predictive value beyond a simple physically meaningful baseline.

---

## C.10 Probabilistic evaluation: PI90

The thesis includes a probabilistic uncertainty layer through 90% prediction intervals.

A PI90 interval is designed to contain approximately 90% of future observed values under the validation and calibration conditions used in the thesis.

Conceptually:

```text
PI90 = [lower bound, upper bound]
```

A calibrated PI90 should satisfy:

```text
empirical coverage ≈ 0.90
```

The PI90 layer allows the thesis to evaluate not only point predictions, but also the reliability of uncertainty estimates.

Associated repository location:

```text
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

---

## C.11 Calibration logic

The uncertainty-calibration logic compares:

1. nominal coverage,
2. empirical coverage before calibration,
3. calibration factor,
4. empirical coverage after calibration.

This supports evaluation of whether prediction intervals are:

- too narrow,
- too wide,
- undercalibrated,
- overcalibrated,
- or appropriately calibrated.

The calibration stage is essential because a model with good deterministic performance may still provide poor uncertainty representation.

---

## C.12 FNRR experimental role

The **Factor de No Regularidad Regional (FNRR)** is introduced as a structural descriptor of regional irregularity.

Its experimental role is to support the distinction between:

```text
free energy
```

and

```text
usable energy
```

through the conceptual relationship:

```text
E_usable = (1 − FNRR) · E_free
```

FNRR is not a conventional forecasting metric.

It is a structural regional descriptor associated with the internal behavior of WPD and its energetic interpretation.

Associated repository location:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.docx
```

If a Markdown version of Anexo G is added, it should also be referenced as:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

---

## C.13 Energy projection configuration

The energy-projection stage extends the interpretation from historical characterization and prediction toward projected energetic scenarios.

The projection horizon reaches:

```text
2028
```

The projection should be interpreted as a model-based scenario, not as an observed measurement.

The energy projection integrates:

```text
WPD prediction
→ uncertainty
→ FNRR adjustment
→ free energy
→ usable energy
→ projected energy scenario
```

Associated repository location:

```text
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
```

---

## C.14 Experimental outputs

The experimental workflow generates several categories of outputs.

| Output category | Examples |
|---|---|
| Physical characterization outputs | Descriptive statistics, Weibull parameters, Rayleigh comparison. |
| Model-comparison outputs | RMSE, MAE, R², Skill Score, model rankings. |
| Prediction outputs | Predictions by zone, target, model, and horizon. |
| Uncertainty outputs | PI90 intervals, empirical coverage, calibration factors. |
| FNRR outputs | FNRR values, structural summaries, irregularity interpretation. |
| Energy outputs | Free energy, usable energy, WPD projections, annual and quarterly summaries. |
| Visual outputs | Figures by chapter and analytical stage. |
| Tabular outputs | Tables by chapter and result type. |
| Reproducibility outputs | Logs, session information, software versions, execution notes. |

The complete evidence layer is organized in:

```text
04_RESULTS_COMPLETE/
```

---

## C.15 Relationship with Chapter 2

Chapter 2 provides the physical characterization required before model training.

It includes:

- descriptive statistics,
- Weibull fitting,
- Rayleigh comparison,
- ACF,
- PACF,
- FFT,
- Wavelet analysis,
- and zonal interpretation.

Experimental relationship:

```text
Chapter 2
→ defines physical behavior of wind
→ informs forecasting difficulty
→ supports WPD interpretation
→ prepares the predictive modeling stage
```

Associated repository locations:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
```

---

## C.16 Relationship with Chapter 3

Chapter 3 corresponds to predictive modeling and model evaluation.

It includes:

- classical models,
- machine learning models,
- deep learning models,
- model comparison,
- persistence benchmarking,
- deterministic metrics,
- and uncertainty-support outputs.

Experimental relationship:

```text
Chapter 3
→ evaluates predictive performance
→ compares model families
→ validates improvement over persistence
→ supports uncertainty-aware prediction
```

Associated repository locations:

```text
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

---

## C.17 Relationship with Chapter 4

Chapter 4 corresponds to integrated energetic interpretation.

It includes:

- WPD projection,
- PI90 uncertainty,
- FNRR,
- free energy,
- usable energy,
- annual and quarterly projection,
- and regional energy interpretation toward 2028.

Experimental relationship:

```text
Chapter 4
→ integrates prediction, uncertainty, and FNRR
→ distinguishes free energy from usable energy
→ provides regional energy projection
```

Associated repository locations:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

---

## C.18 Relationship with code

The experimental configuration is implemented across the following code folders:

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

Each code folder corresponds to one stage of the doctoral workflow.

The logical sequence is:

```text
preprocessing
→ physical characterization
→ classical modeling
→ machine learning
→ deep learning
→ hybrid physical–statistical integration
→ energy projection
→ utilities and support
```

---

## C.19 Relationship with results

The results generated from the experimental configuration are organized in:

```text
04_RESULTS_COMPLETE/
```

with the following structure:

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

This structure connects experimental design with evidence.

---

## C.20 Relationship with reproducibility

The experimental configuration should be interpreted together with:

```text
07_REPRODUCIBILITY/
```

That folder should contain or document:

- execution pipeline,
- software versions,
- session information,
- data contract,
- and reproducibility assumptions.

The relationship is:

```text
experimental configuration
→ executable scripts
→ generated outputs
→ reproducibility documentation
```

---

## C.21 Interpretation of internal workflow labels

Some files in the repository contain internal labels such as:

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

These labels should be interpreted as workflow or traceability labels.

For doctoral evaluation, the core interpretation remains:

- physical characterization,
- statistical modeling,
- machine learning and deep learning comparison,
- uncertainty quantification,
- FNRR as regional irregularity descriptor,
- and energy projection.

Internal labels should not be overinterpreted as separate theoretical claims unless they are formally defined in the corresponding appendix.

---

## C.22 Experimental caution

The experimental configuration does not imply that all models perform equally well.

It defines a controlled framework under which models can be compared.

Model interpretation must consider:

- target variable,
- zone,
- prediction horizon,
- metric,
- persistence baseline,
- uncertainty calibration,
- and energetic meaning.

A model with strong performance in one zone or horizon should not automatically be generalized to all zones or horizons without evidence.

---

## C.23 What this appendix does not claim

This appendix does not claim that the experimental system eliminates all uncertainty.

It does not claim that a single model universally dominates under every condition.

It does not claim that projected values are observed values.

Instead, it defines a structured experimental framework for comparing models, quantifying uncertainty, interpreting irregularity, and projecting energy under the methodological assumptions of the thesis.

---

## C.24 Closure criterion

The experimental configuration is considered sufficiently documented when:

1. target variables are clearly defined,
2. zones are identified as experimental units,
3. horizons are explicitly described,
4. model families are documented,
5. metrics are defined,
6. persistence is included as benchmark,
7. PI90 uncertainty is included,
8. FNRR is connected to energy interpretation,
9. outputs are linked to result folders,
10. code folders are connected to the workflow,
11. reproducibility files are aligned with the final repository structure,
12. and internal labels are interpreted with academic caution.

---

## C.25 Final statement

The experimental configuration of the thesis is designed to connect physical understanding, predictive modeling, uncertainty quantification, regional irregularity, and energy projection.

Its central principle is:

```text
A model is scientifically useful only if it improves prediction,
preserves physical meaning, quantifies uncertainty,
and supports interpretable energy projection.
```

For that reason, this appendix defines the experimental structure required to understand and evaluate the computational results of the doctoral thesis.

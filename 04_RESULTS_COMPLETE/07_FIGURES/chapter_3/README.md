# Chapter 3 Figures — Predictive Modeling and Model Evaluation

## Purpose

This folder contains the visual evidence associated with Chapter 3 of the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The figures in this folder support the predictive modeling stage of the thesis, including deterministic model comparison, probabilistic uncertainty evaluation, horizon-based forecasting, WPD prediction, integrated-energy interpretation, and residual analysis.

This folder is part of:

```text
04_RESULTS_COMPLETE/07_FIGURES/
```

and should be interpreted as the graphical evidence layer for the predictive and uncertainty-evaluation stage of the doctoral workflow.

---

## 1. Scientific role of these figures

Chapter 3 represents the transition from physical characterization to predictive modeling.

The figures contained in this folder provide visual support for evaluating whether the proposed forecasting framework captures the temporal and energetic behavior of the wind system with sufficient accuracy and interpretability.

The visual evidence supports the following scientific sequence:

```text
physical characterization
→ predictive modeling
→ deterministic evaluation
→ persistence comparison
→ probabilistic uncertainty
→ WPD prediction
→ horizon-integrated energy interpretation
→ residual verification
```

The central target variable of the thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

Because WPD depends cubically on wind speed, predictive errors may propagate nonlinearly into the energetic interpretation. For that reason, visual evaluation is essential for understanding model behavior beyond numerical metrics alone.

---

## 2. Main figure families

The figures in this folder can be interpreted under the following families:

| Figure family | Main role |
|---|---|
| Global performance figures | Summarize model performance through Skill Score, R², RMSE, and PI90 coverage. |
| Example-horizon figures | Show representative predictions for short and medium horizons. |
| WPD forecast curves | Present model-based WPD prediction behavior by zone and horizon. |
| Eh forecast curves | Present horizon-integrated energy behavior by zone and horizon. |
| Article-style figures | Provide publication-oriented visual summaries. |
| Residual figures | Support visual diagnosis of model error structure. |
| FNRR-support figures | Connect predictive results with structural irregularity interpretation. |

---

## 3. Global model-performance figures

The following figures provide global visual summaries of predictive performance:

```text
01_Skill_vs_Persist.png
02_R2.png
03_RMSE.png
04_Coverage_PI90_before_after.png
05_FNRR_density_by_zone.png
```

### `01_Skill_vs_Persist.png`

This figure summarizes model improvement relative to the persistence benchmark.

Scientific interpretation:

The Skill Score is central in the thesis because it evaluates whether a model provides predictive value beyond the natural persistence of the wind-energy signal.

A model is not considered strong only because it fits the data. It must improve over persistence.

---

### `02_R2.png`

This figure summarizes the coefficient of determination associated with the predictive models.

Scientific interpretation:

R² provides complementary information about explanatory or predictive capacity. However, in the thesis it should not be interpreted alone. It must be read together with RMSE, Skill Score, and uncertainty behavior.

---

### `03_RMSE.png`

This figure summarizes Root Mean Squared Error behavior.

Scientific interpretation:

RMSE is important because it penalizes large prediction errors. In the context of WPD, large deviations are especially relevant because energetic interpretation is sensitive to wind-speed variability.

---

### `04_Coverage_PI90_before_after.png`

This figure compares PI90 coverage before and after calibration.

Scientific interpretation:

This figure supports the probabilistic uncertainty component of the thesis. It shows whether the prediction intervals approach the expected empirical coverage after calibration.

The figure should be interpreted as evidence that the thesis does not only evaluate point forecasts, but also the reliability of predictive uncertainty.

---

### `05_FNRR_density_by_zone.png`

This figure represents the density behavior associated with FNRR by zone.

Scientific interpretation:

The figure supports the structural interpretation of regional irregularity. It connects the predictive stage with the later energetic interpretation developed through FNRR.

---

## 4. Representative horizon examples

The following figures provide representative prediction examples:

```text
06_Example_Corto_h1.png
07_Example_Medio_h12.png
```

### `06_Example_Corto_h1.png`

This figure represents a short-horizon prediction example.

Scientific interpretation:

Short-horizon prediction is useful for evaluating how well the model captures near-term temporal evolution. It is commonly expected to perform better than longer horizons because uncertainty has less time to accumulate.

---

### `07_Example_Medio_h12.png`

This figure represents a medium-horizon prediction example.

Scientific interpretation:

Medium-horizon prediction provides evidence of model stability beyond immediate persistence. It is useful for evaluating whether the model preserves predictive structure as the forecasting horizon increases.

---

## 5. WPD forecast-curve figures

This folder contains several WPD forecast figures organized by zone and horizon.

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

These figures show the temporal behavior of predicted WPD by zone and horizon.

They allow reviewers to evaluate:

- how predictions follow observed energetic dynamics,
- how performance changes by zone,
- how uncertainty or deviation increases with horizon,
- and how the model behaves under different regional regimes.

The label `TDQ_BAYES` appears in file names as a computational traceability label from the development workflow. For the doctoral interpretation of this folder, these figures should be read as part of the hybrid physical–statistical predictive stage.

---

## 6. Article-style WPD figures

This folder also contains publication-oriented WPD figures, including files such as:

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

These figures provide polished visual summaries of WPD prediction behavior, potentially useful for derivative articles or publication-oriented outputs.

They should be interpreted as visual support for the model-comparison and forecasting results, not as independent results separate from the thesis workflow.

---

## 7. Integrated WPD panel figure

The folder includes:

```text
FIGURA_3_4_PANEL_WPD.png
```

Scientific interpretation:

This panel figure is important because it visually synthesizes WPD behavior across multiple conditions.

Its role is to provide an integrated view that supports comparison between zones, horizons, or model outputs, depending on the internal structure of the figure.

This type of figure is especially useful for thesis defense because it condenses several predictive results into one visual object.

---

## 8. Eh forecast and horizon-integrated energy figures

This folder contains several figures related to **Eh**, interpreted as horizon-integrated energy.

Examples include:

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

These figures support the transition from instantaneous or pointwise WPD prediction toward accumulated energetic interpretation.

Eh figures are relevant because energy systems are not evaluated only through instantaneous power density, but through accumulated energetic behavior over prediction horizons.

---

## 9. Nature-style WPD and Eh figures

This folder contains additional publication-style visualizations named with the `NATURE_` prefix.

Examples include:

```text
NATURE_WPD_Z1_Corto_h001.png
NATURE_WPD_Z1_Medio_h012.png
NATURE_WPD_Z1_Largo_h072.png

NATURE_Eh_Z1_Corto_h001.png
NATURE_Eh_Z1_Medio_h012.png
NATURE_Eh_Z1_Largo_h072.png
```

and equivalent figures for zones Z2, Z3, and Z4.

Scientific interpretation:

These figures are publication-oriented visual outputs intended to present WPD and Eh behavior in a refined graphical format.

They support scientific communication, article preparation, and visual synthesis of model performance.

The prefixes used in the file names should be interpreted as formatting or product-orientation labels, not as claims of publication status.

---

## 10. Residual-analysis figures

The folder contains residual figures for WPD and Eh by zone and horizon.

Examples include:

```text
RESID_WPD_Z1_Corto_h1_LSTM_TDQ_BAYES.png
RESID_WPD_Z1_Medio_h12_LSTM_TDQ_BAYES.png
RESID_WPD_Z1_Largo_h72_LSTM_TDQ_BAYES.png

RESID_Eh_Z1_Corto_h1_LSTM_TDQ_BAYES.png
RESID_Eh_Z1_Medio_h12_LSTM_TDQ_BAYES.png
RESID_Eh_Z1_Largo_h72_LSTM_TDQ_BAYES.png
```

and equivalent figures for zones Z2, Z3, and Z4.

Scientific interpretation:

Residual figures support diagnostic evaluation of prediction errors.

They help assess:

- whether errors show systematic structure,
- whether deviations change with horizon,
- whether residual behavior differs by zone,
- and whether model predictions remain stable under different forecasting conditions.

Residual analysis is essential because good average metrics may hide systematic error behavior.

---

## 11. Time-series figures

The folder also contains time-series figures such as:

```text
SERIE_EH_Z1_Corto_h1_XGB_Bayes.png
SERIE_EH_Z2_Medio_h12_XGB.png
SERIE_EH_Z3_Medio_h12_XGB.png
SERIE_EH_Z4_Medio_h12_ARIMAX.png
```

and additional `SERIE_Eh_*` figures associated with the hybrid predictive workflow.

Scientific interpretation:

These figures provide direct visual comparison between observed and predicted energy-related behavior over time.

They are useful for inspecting local prediction behavior that may not be fully captured by global metrics.

---

## 12. Interpretation of horizons

The figures use three main forecasting horizons:

| Horizon label | Interpretation |
|---|---|
| `Corto_h1` or `h001` | Short horizon, associated with near-term prediction. |
| `Medio_h12` or `h012` | Medium horizon, associated with intermediate temporal prediction. |
| `Largo_h72` or `h072` | Long horizon, associated with extended prediction. |

Scientific interpretation:

As the prediction horizon increases, uncertainty and error propagation generally become more relevant.

For that reason, figures should be interpreted not only by model type, but also by horizon.

---

## 13. Interpretation of zones

The figures use four analytical zones:

```text
Z1, Z2, Z3, Z4
```

These zones correspond to the regional structure defined in:

```text
02_DATA_METADATA/03_station_zone_mapping.md
```

Scientific interpretation:

Model behavior should be interpreted by zone because the wind-energy system is regionally heterogeneous.

A model may behave differently across zones due to differences in atmospheric dynamics, variability, data availability, and energetic structure.

---

## 14. Relationship with model-comparison results

These figures should be interpreted together with:

```text
04_RESULTS_COMPLETE/02_model_comparison/
```

and the corresponding tables in:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

The figures provide visual evidence, while the tables provide numerical support.

Together, they support the predictive modeling results of Chapter 3.

---

## 15. Relationship with PI90 uncertainty

The uncertainty-related figures should be interpreted together with:

```text
04_RESULTS_COMPLETE/03_pi90_uncertainty/
```

especially the PI90 coverage figure:

```text
04_Coverage_PI90_before_after.png
```

This figure helps support the probabilistic interpretation of the predictive workflow.

---

## 16. Relationship with FNRR and energy interpretation

The FNRR-related figure:

```text
05_FNRR_density_by_zone.png
```

should be interpreted as a bridge between the predictive modeling stage and the structural energetic interpretation developed later in the thesis.

It connects Chapter 3 with the Chapter 4 logic of:

```text
prediction
→ uncertainty
→ regional irregularity
→ usable energy
```

---

## 17. Relationship with code

The figures contained in this folder should be reproducible from the predictive modeling and evaluation workflow contained in:

```text
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
03_CODE/08_utils/
```

The folder `03_CODE/06_hybrid_tdq/` reflects the current repository naming. In the scientific interpretation of this figures folder, it should be understood as the hybrid physical–statistical integration stage of the doctoral workflow.

---

## 18. Naming interpretation

Some file names include labels such as:

```text
TDQ
BAYES
ELSEVIER
NATURE
ANEXO
```

These labels should be interpreted as internal workflow, optimization, formatting, or product-orientation labels.

They should not be read as independent theoretical claims or publication-status claims.

For doctoral evaluation, the figures should be interpreted according to their scientific function:

- WPD prediction,
- Eh prediction,
- model comparison,
- uncertainty evaluation,
- residual analysis,
- and energy-related interpretation.

---

## 19. Methodological caution

The figures in this folder should not be interpreted in isolation.

Each figure must be read in relation to:

- the target variable,
- the zone,
- the prediction horizon,
- the model family,
- the corresponding numerical metrics,
- the uncertainty structure,
- and the thesis chapter where the result is discussed.

This prevents visual outputs from being overinterpreted without numerical or methodological support.

---

## 20. Interpretation role

The visual evidence in this folder supports the following thesis position:

```text
Predictive modeling of wind-energy potential must be evaluated through
deterministic performance, persistence comparison, uncertainty behavior,
residual structure, zonal interpretation, and energetic meaning.
```

This folder therefore provides the graphical foundation for the predictive modeling stage of the doctoral workflow.

---

## 21. Final note

This folder preserves the Chapter 3 visual evidence of the doctoral thesis.

Its role is to support the transition from physical characterization to predictive modeling and from deterministic forecasting to uncertainty-aware energetic interpretation.

Together with the Chapter 3 tables, this folder provides the visual evidence required to evaluate model behavior, predictive value, uncertainty, and the energetic relevance of the forecasting framework.

# Article 02 — Concept Note

## Tentative title

**Hybrid physical–statistical forecasting of wind power density in Nariño, Colombia: comparison of classical, machine learning, and deep learning approaches**

---

## Current status

```text
Status: Concept note
Maturity level: Pre-manuscript
Repository role: Publication planning and scientific traceability
```

This file does not represent a submitted, accepted, or published manuscript.

It defines the scientific scope, evidence base, methodological orientation, and development path for the second derivative article projected from the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

---

## 1. Article role within the publication portfolio

This article is intended to be the second scientific publication derived from the doctoral thesis.

Its role is to present the predictive modeling core of the doctoral work, including the comparison of classical forecasting models, machine learning models, deep learning models, persistence benchmarking, deterministic metrics, uncertainty-aware evaluation, and horizon-based interpretation.

The article corresponds mainly to the scientific development associated with Chapter 3 of the thesis.

The publication sequence is:

```text
Article 01
Physical–statistical characterization of wind and WPD

Article 02
Predictive modeling and model comparison

Article 03
FNRR, uncertainty, free energy, and usable energy
```

Article 02 should function as the predictive core of the publication portfolio.

---

## 2. Scientific problem

Forecasting wind-energy-related variables in complex regional systems cannot be treated as a purely algorithmic task.

The predictive problem is conditioned by:

- atmospheric variability,
- nonlinear physical relationships,
- temporal dependence,
- regional heterogeneity,
- multi-scale structure,
- uncertainty,
- and the energetic amplification produced by wind speed.

The central physical target variable of the thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

Because WPD depends cubically on wind speed, small errors in wind behavior may propagate into larger energetic deviations.

Therefore, wind-energy forecasting must be evaluated not only through conventional model accuracy, but also through physical meaning, comparison against persistence, horizon dependence, zonal behavior, uncertainty support, and residual structure.

The scientific problem can be stated as follows:

```text
How do classical, machine learning, and deep learning models compare in forecasting Wind Power Density in Nariño, Colombia, when evaluated under a physical–statistical framework using persistence benchmarking, deterministic metrics, and uncertainty-aware support?
```

---

## 3. Main objective

To compare classical, machine learning, and deep learning models for forecasting Wind Power Density in Nariño, Colombia, under a hybrid physical–statistical framework that incorporates zonal structure, prediction horizons, persistence benchmarking, deterministic metrics, uncertainty-aware evaluation, and energetic interpretation.

---

## 4. Specific objectives

1. To define Wind Power Density as the central physical target variable for wind-energy forecasting.

2. To evaluate forecasting performance across the four analytical zones defined in the doctoral dataset.

3. To compare classical time-series models, machine learning models, and deep learning models under a consistent predictive framework.

4. To evaluate model performance across short, medium, and long prediction horizons.

5. To compare model results against a persistence benchmark.

6. To analyze deterministic performance through RMSE, MAE, R², and Skill Score.

7. To include uncertainty-aware support through PI90-related outputs.

8. To inspect representative prediction curves and residual behavior.

9. To establish the predictive basis required for later FNRR and energy-projection interpretation.

---

## 5. Expected contribution

This article is expected to contribute:

- a comparative evaluation of forecasting model families for WPD in a regional wind-energy system;
- evidence on the predictive value of classical, machine learning, and deep learning approaches;
- a physically meaningful interpretation of model performance using WPD as the target variable;
- an evaluation framework based on persistence benchmarking and Skill Score;
- horizon-based and zone-based interpretation of predictive performance;
- uncertainty-aware support through PI90-related outputs;
- residual-based diagnostic support for model interpretation;
- and a methodological bridge between physical characterization and regional energy projection.

The article should not claim that a single model universally dominates under all conditions.

Its contribution is to present a structured, physically interpretable, and evidence-based comparison of forecasting families under the doctoral dataset and workflow.

---

## 6. Proposed article type

```text
Original research article
```

Possible journal areas:

- renewable energy forecasting,
- wind-energy systems,
- applied physics,
- energy informatics,
- environmental modeling,
- physical–statistical modeling,
- machine learning for energy systems,
- uncertainty-aware prediction.

This concept note does not define a final target journal.

Target-journal selection should be performed after the manuscript scope, figure selection, table selection, novelty statement, and manuscript length are consolidated.

---

## 7. Proposed abstract draft

Forecasting wind-energy potential requires models that can capture temporal structure, nonlinear behavior, regional heterogeneity, and uncertainty. This study compares classical forecasting models, machine learning models, and deep learning models for Wind Power Density prediction in Nariño, Colombia, using a multi-zone meteorological dataset derived from the doctoral thesis. Wind Power Density is used as the central physical target variable because it links atmospheric motion with energetic potential through its cubic dependence on wind speed. The predictive framework evaluates short, medium, and long horizons across four analytical zones. Model performance is assessed using RMSE, MAE, R², and Skill Score against persistence, complemented by uncertainty-aware support through PI90-related outputs and residual analysis. The results are intended to identify which modeling families provide meaningful predictive gain beyond persistence and how predictive behavior changes across zones and horizons. The study contributes a physical–statistical forecasting framework for regional wind-energy prediction and provides the predictive basis for later uncertainty, FNRR, and usable-energy interpretation.

---

## 8. Keywords

Suggested keywords:

```text
Wind Power Density
Wind-energy forecasting
Machine learning
Deep learning
LSTM
Random Forest
XGBoost
ARIMA
ARIMAX
Persistence benchmark
Skill Score
Prediction intervals
Uncertainty quantification
Physical–statistical modeling
Renewable energy
Nariño
```

---

## 9. Study area and data basis

The article is based on the doctoral dataset associated with Nariño, Colombia.

The observational basis includes:

- multi-station meteorological records,
- 16 IDEAM meteorological stations,
- four analytical zones,
- hourly records from 2017–2022,
- wind speed as the primary observed variable,
- atmospheric variables required or useful for physical interpretation,
- and derived energetic variables such as WPD and Eh.

The database and zonal structure are documented in:

```text
02_DATA_METADATA/
05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
```

The article should describe the dataset as a regional observational system, not as a generic numerical matrix.

The four zones should be interpreted as analytical units used to preserve regional structure in the modeling workflow.

---

## 10. Central physical target variable

The central target variable is **Wind Power Density**:

```text
WPD = 0.5 · ρ · v³
```

This variable is used because it connects wind behavior with energetic potential.

The cubic dependence on wind speed makes WPD more physically informative than wind speed alone for energy-related forecasting.

However, this same cubic dependence increases the importance of careful modeling, because predictive errors may be energetically amplified.

For this reason, Article 02 should frame prediction as a physical–statistical problem, not only as an algorithmic exercise.

---

## 11. Secondary energetic quantity: Eh

The article may also include **Eh**, interpreted as horizon-integrated energy.

Conceptually:

```text
Eh = accumulated or integrated energetic quantity over a prediction horizon
```

Eh supports the transition from pointwise WPD forecasting to accumulated energetic interpretation.

This is relevant because energy systems are not evaluated only through instantaneous power density, but also through energetic behavior accumulated over operational horizons.

---

## 12. Prediction horizons

The article should evaluate predictive behavior across three main horizons:

| Horizon label | Interpretation |
|---|---|
| `Corto_h1` or `h001` | Short-horizon prediction. |
| `Medio_h12` or `h012` | Medium-horizon prediction. |
| `Largo_h72` or `h072` | Long-horizon prediction. |

The horizon structure is important because forecasting difficulty generally increases with the prediction horizon.

The article should interpret model performance according to:

- target variable,
- analytical zone,
- prediction horizon,
- model family,
- deterministic metrics,
- uncertainty behavior,
- and residual structure.

---

## 13. Zonal structure

The predictive results should be interpreted across the four analytical zones:

```text
Z1, Z2, Z3, Z4
```

The station-to-zone mapping is documented in:

```text
02_DATA_METADATA/03_station_zone_mapping.md
05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
```

Zonal interpretation is essential because regional wind-energy behavior is not necessarily homogeneous.

A model may perform well in one zone and less effectively in another.

Therefore, Article 02 should avoid presenting only global metrics. It should preserve zone-level interpretation.

---

## 14. Proposed methodological structure

The methodology of the article should follow this structure:

```text
1. Study area and observational data
2. Zonal organization
3. Physical construction of WPD
4. Prediction targets and horizons
5. Classical forecasting models
6. Machine learning models
7. Deep learning models
8. Persistence benchmark
9. Deterministic evaluation metrics
10. PI90 uncertainty support
11. Residual analysis
12. Model comparison and selection criteria
```

This structure keeps the article aligned with the thesis and repository evidence.

---

## 15. Model families

The article should compare the following model families.

### 15.1 Classical forecasting models

Classical models provide a statistical time-series reference.

Examples include:

- ARIMA,
- ARIMAX,
- and related time-series forecasting structures.

Repository support:

```text
03_CODE/03_classical_models/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/CLASICOS_DEFINITIVA_WPD.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_3/CLASICOS_DEFINITIVA_Eh.csv
```

Scientific role:

Classical models help evaluate whether conventional temporal structures can capture part of the behavior of WPD and Eh.

They provide an important baseline between persistence and more complex ML or DL models.

---

### 15.2 Machine learning models

Machine learning models evaluate nonlinear predictive behavior.

The repository includes outputs associated with:

- Random Forest,
- XGBoost,
- base ML configurations,
- optimized or Bayesian-supported ML configurations.

Repository support:

```text
03_CODE/04_machine_learning/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/ML_BASE_DEFINITIVA_WPD.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_3/ML_BASE_DEFINITIVA_Eh.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_3/ML_BAYES_DEFINITIVA_WPD.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_3/ML_BAYES_DEFINITIVA_Eh.csv
```

Scientific role:

Machine learning models allow the thesis to evaluate whether nonlinear relationships between meteorological variables and energy-related targets improve predictive performance.

---

### 15.3 Deep learning models

Deep learning models evaluate whether sequential architectures improve prediction under temporal dependence.

The main deep learning architecture represented in the repository is LSTM-based modeling.

Repository support:

```text
03_CODE/05_deep_learning/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/DL_TABLA_WPD_COMPLETA.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_3/DL_TABLA_Eh_COMPLETA.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_3/DL_TABLA_COMBINADA_DEFINITIVA.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_3/DL_HP_GLOBAL_TDQ.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_3/DL_TUNING_WPD_Corto_h1.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_3/DL_TUNING_WPD_Medio_h12.csv
```

Scientific role:

Deep learning models support the evaluation of temporal learning capacity across zones and horizons.

Because wind-energy signals may contain persistence, intermittency, and temporal dependence, sequential models provide a necessary comparison layer.

---

### 15.4 Hybrid physical–statistical integration

The repository contains an internal workflow folder named:

```text
03_CODE/06_hybrid_tdq/
```

For article development, this stage should be described carefully as a **hybrid physical–statistical integration layer**.

Scientific role:

This stage integrates:

- physical construction of WPD,
- deterministic prediction,
- uncertainty-aware support,
- FNRR-related outputs,
- and energy-related interpretation.

Internal labels such as `TDQ` should be treated as workflow traceability labels unless formally defined in the article.

---

## 16. Persistence benchmark

Persistence is the main benchmark for predictive evaluation.

Conceptually:

```text
Ŷ_persistence(t+h) = Y(t)
```

Persistence is important because atmospheric variables often contain temporal autocorrelation.

A model may obtain acceptable numerical metrics but still fail to improve meaningfully over persistence.

Therefore, the central predictive question is:

```text
Does the model add predictive value beyond the natural persistence of the wind-energy signal?
```

This makes Skill Score against persistence a principal criterion of Article 02.

---

## 17. Deterministic evaluation metrics

The main deterministic metrics are:

| Metric | Meaning | Role in the article |
|---|---|---|
| RMSE | Root Mean Squared Error | Measures error magnitude and penalizes large deviations. |
| MAE | Mean Absolute Error | Measures average absolute error. |
| R² | Coefficient of determination | Provides complementary explanatory or predictive capacity. |
| Skill Score | Improvement relative to persistence | Main criterion for predictive value beyond baseline. |

The article should not select models based on R² alone.

Model interpretation should integrate:

```text
RMSE + MAE + R² + Skill Score + horizon + zone + uncertainty + residual behavior
```

---

## 18. Skill Score interpretation

Using RMSE as loss measure, the Skill Score may be interpreted as:

```text
Skill = 1 − (RMSE_model / RMSE_persistence)
```

Interpretation:

```text
Skill > 0  → model improves over persistence
Skill = 0  → model behaves similarly to persistence
Skill < 0  → model performs worse than persistence
```

A stronger result is obtained when the model shows substantial positive Skill across zones and horizons.

The article should treat Skill Score as the main criterion for identifying real predictive gain.

---

## 19. PI90 uncertainty support

The article should include uncertainty-aware support through PI90-related outputs.

A 90% prediction interval is conceptually:

```text
PI90 = [lower bound, upper bound]
```

A calibrated PI90 should satisfy:

```text
empirical coverage ≈ 0.90
```

Repository support:

```text
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/04_Coverage_PI90_before_after.png
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

Scientific role:

PI90 support shows that the predictive framework is not limited to point forecasts.

It evaluates whether the uncertainty surrounding predictions is empirically meaningful.

---

## 20. Residual analysis

Residual analysis should be included as a diagnostic layer.

Residuals can be represented as:

```text
e_i = Y_i − Ŷ_i
```

Residual figures help evaluate whether model errors:

- are random or structured,
- change with horizon,
- differ by zone,
- show systematic bias,
- or reveal model limitations.

Repository support:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/RESID_WPD_*.png
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/RESID_Eh_*.png
```

Scientific role:

Residual analysis prevents the article from relying only on global metrics.

A model with good average metrics may still show systematic residual behavior.

---

## 21. Suggested figures for the article

A preliminary figure set could include:

| Figure | Source | Purpose |
|---|---|---|
| Workflow diagram | To be created | Shows data → WPD → models → metrics → uncertainty. |
| Skill vs persistence | `01_Skill_vs_Persist.png` | Shows predictive gain over persistence. |
| R² comparison | `02_R2.png` | Shows explanatory/predictive capacity. |
| RMSE comparison | `03_RMSE.png` | Shows error magnitude. |
| PI90 coverage | `04_Coverage_PI90_before_after.png` | Shows uncertainty calibration support. |
| Representative WPD forecast | `CURVA_WPD_*` | Shows prediction tracking by zone/horizon. |
| Residual figure | `RESID_WPD_*` | Shows diagnostic error behavior. |

The final article should avoid using too many figures.

A focused article may use 5–7 main figures and place additional figures in supplementary material.

---

## 22. Suggested tables for the article

A preliminary table set could include:

| Table | Source | Purpose |
|---|---|---|
| Experimental configuration | Appendix C | Defines targets, horizons, models, and metrics. |
| Classical model results | `CLASICOS_DEFINITIVA_WPD.csv` | Supports baseline statistical forecasting. |
| ML model results | `ML_BASE_DEFINITIVA_WPD.csv`, `ML_BAYES_DEFINITIVA_WPD.csv` | Supports nonlinear model comparison. |
| DL model results | `DL_TABLA_WPD_COMPLETA.csv` | Supports sequential model comparison. |
| Global final predictions | `TDQ_FINAL_TABLA_GLOBAL.csv` | Supports integrated predictive synthesis. |
| PI90 outputs | `TDQ_PIESS_INTERVALOS_PREDS.csv` or related outputs | Supports uncertainty-aware interpretation. |

The article should include only the tables required for a clear scientific narrative.

Additional tables may be placed as supplementary material.

---

## 23. Expected results narrative

The results section should be organized around five interpretive blocks.

### 23.1 Model-family performance

Compare classical, ML, and DL model families.

Purpose:

```text
identify which modeling families provide stronger predictive performance
```

### 23.2 Persistence comparison

Evaluate Skill Score against persistence.

Purpose:

```text
verify whether models provide real predictive gain
```

### 23.3 Horizon-based behavior

Compare short, medium, and long prediction horizons.

Purpose:

```text
evaluate how predictive performance changes as horizon increases
```

### 23.4 Zonal behavior

Interpret model performance across Z1, Z2, Z3, and Z4.

Purpose:

```text
identify regional differences in forecastability
```

### 23.5 Uncertainty and residual support

Discuss PI90 coverage and residual behavior.

Purpose:

```text
evaluate whether predictions are reliable beyond point metrics
```

---

## 24. Discussion focus

The discussion should emphasize:

- why WPD forecasting is physically more meaningful than wind-speed-only forecasting;
- how model performance changes across zones and horizons;
- why persistence benchmarking is necessary in wind-energy forecasting;
- whether complex models justify their complexity;
- how uncertainty support changes the interpretation of prediction;
- how residual behavior reveals model limitations;
- and how predictive outputs prepare the transition toward FNRR and energy projection.

The discussion should avoid overstating any single model as universally superior unless the evidence supports that claim across zones, horizons, and metrics.

---

## 25. Main novelty statement

A possible novelty statement is:

```text
This study compares classical, machine learning, and deep learning models for Wind Power Density forecasting in Nariño, Colombia, under a physical–statistical framework that integrates zonal structure, prediction horizons, persistence benchmarking, deterministic metrics, uncertainty support, and residual interpretation.
```

A stronger version for the manuscript introduction:

```text
The novelty of this study lies in evaluating wind-energy forecasting not only as an algorithmic task, but as a physical–statistical problem centered on Wind Power Density, where model value is assessed through improvement over persistence, horizon-dependent behavior, zonal variability, and uncertainty-aware interpretation.
```

---

## 26. Repository evidence supporting the article

Primary support:

```text
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
05_APPENDICES_SUPPORT/Anexo_C_Configuracion_Experimental.md
05_APPENDICES_SUPPORT/Anexo_E_Resultados_Extendidos_Cap3.md
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

Secondary support:

```text
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
07_REPRODUCIBILITY/
```

---

## 27. Relationship with Article 01

Article 02 depends on Article 01 because predictive modeling requires prior physical characterization.

The relationship is:

```text
Article 01
characterizes the wind-energy signal

Article 02
tests whether that signal can be forecasted with meaningful predictive gain
```

Article 01 provides the physical and statistical basis.

Article 02 provides the predictive evaluation.

---

## 28. Relationship with Article 03

Article 02 supports Article 03 because FNRR and usable-energy interpretation depend on predictive and uncertainty-aware outputs.

The relationship is:

```text
Article 02
produces forecasts and uncertainty-aware support

Article 03
uses prediction, uncertainty, and WPD structure to formalize FNRR and usable energy
```

Therefore, Article 02 functions as the bridge between physical characterization and structural energetic interpretation.

---

## 29. Possible manuscript structure

A recommended manuscript structure is:

```text
1. Introduction
2. Study area and dataset
3. Physical formulation of Wind Power Density
4. Prediction targets and horizons
5. Modeling framework
   5.1 Classical models
   5.2 Machine learning models
   5.3 Deep learning models
   5.4 Hybrid physical–statistical integration
6. Evaluation metrics
   6.1 RMSE
   6.2 MAE
   6.3 R²
   6.4 Skill Score versus persistence
   6.5 PI90 uncertainty support
7. Results
8. Discussion
9. Limitations
10. Conclusions
11. Data and code availability
12. References
```

---

## 30. Limitations to declare

The article should declare limitations honestly.

Possible limitations include:

- heterogeneous variable availability across the observational system;
- unequal station representation across zones;
- possible sensitivity to preprocessing and unit harmonization;
- dependence on the selected validation strategy;
- possible variability of ML/DL outputs due to stochastic training processes;
- limited generalization beyond the dataset without external validation;
- projection and uncertainty outputs should be interpreted as model-based scenarios;
- and internal workflow labels should not be overinterpreted as independent theoretical claims.

These limitations strengthen the article because they show methodological caution.

---

## 31. Ethical and authorship note

This concept note does not define final authorship.

Authorship should be determined according to actual scientific contribution, thesis supervision, data work, methodological support, writing, review, and institutional guidelines.

The article should clearly distinguish between:

- thesis-validated results,
- additional article-specific analysis,
- future work,
- and broader interpretations.

---

## 32. Internal label caution

Some repository outputs may contain internal labels such as:

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

For article development, these labels should be treated carefully.

The article narrative should prioritize formally defensible scientific language:

- physical–statistical forecasting,
- Wind Power Density,
- model comparison,
- persistence benchmark,
- Skill Score,
- uncertainty support,
- PI90,
- residual analysis,
- horizon-based evaluation,
- and zonal interpretation.

Internal labels should not be overinterpreted as publication claims, journal claims, or independent theoretical claims unless formally defined in the manuscript.

---

## 33. Development tasks

Next tasks for converting this concept note into a manuscript:

1. Select the final target journal category.
2. Define final article length and figure/table limits.
3. Select final Chapter 3 figures.
4. Select final Chapter 3 tables.
5. Confirm final model families and metrics to report.
6. Define the final persistence benchmark statement.
7. Write the introduction with international literature.
8. Condense the methodology into article format.
9. Convert thesis results into article-style results.
10. Write the discussion around predictive value and physical meaning.
11. Prepare data/code availability statement.
12. Prepare references in the target journal format.

---

## 34. Current development status

```text
Current status: Concept note expanded
Next stage: Draft manuscript
Priority: High
Dependency: Final verification of Chapter 3 figures, tables, metrics, and repository evidence
```

---

## 35. Final note

This article should function as the predictive core of the publication portfolio derived from the doctoral thesis.

Its central message should be:

```text
A wind-energy forecast is scientifically useful only when it improves over persistence,
preserves physical meaning, remains interpretable across zones and horizons,
and is supported by uncertainty-aware evaluation.
```

Article 02 therefore establishes the predictive bridge between physical characterization and FNRR-based usable-energy interpretation.

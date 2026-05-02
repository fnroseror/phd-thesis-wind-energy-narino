# 03_pi90_uncertainty

## Purpose

This folder contains the structured documentation and outputs associated with probabilistic uncertainty quantification through 90% prediction intervals (**PI90**) for the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

It corresponds to the probabilistic result layer of the thesis and supports the evaluation of uncertainty in the forecasting framework applied to **Wind Power Density (WPD)** and related energetic quantities.

This folder is part of:

```text
04_RESULTS_COMPLETE/
```

and must be interpreted as a component of the complete scientific evidence layer of the repository.

---

## 1. Scientific role of this folder

The thesis does not evaluate forecasting performance only through deterministic metrics such as RMSE, MAE, R², or Skill Score.

Because wind-energy prediction is affected by atmospheric variability, nonlinear energetic amplification, temporal dependence, and regional heterogeneity, the thesis also requires a probabilistic uncertainty layer.

This folder documents that uncertainty layer through calibrated 90% prediction intervals.

The central scientific question addressed by this folder is:

```text
Do the prediction intervals provide a reliable probabilistic representation of future WPD behavior?
```

---

## 2. Physical meaning of PI90 uncertainty

The central target variable of the thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

Because WPD depends cubically on wind speed, small errors in wind prediction may propagate into larger energetic deviations.

For that reason, uncertainty quantification is not an accessory component of the thesis. It is required to interpret predicted energy potential with scientific caution.

The PI90 framework allows the thesis to move from deterministic prediction to probabilistic interpretation.

---

## 3. Definition of PI90

A 90% prediction interval is designed to contain the future observed value with approximately 90% empirical coverage, under the assumptions and calibration procedure used in the modeling workflow.

Conceptually:

```text
PI90 = [lower bound, upper bound]
```

A calibrated PI90 should satisfy:

```text
empirical coverage ≈ 0.90
```

This means that approximately 90% of observed values should fall inside the predicted interval.

---

## 4. Probabilistic evaluation logic

The uncertainty-evaluation workflow is based on the comparison between:

1. **Nominal coverage**  
   The theoretical target confidence level, in this case 90%.

2. **Empirical coverage before calibration**  
   The observed proportion of values contained within the initial prediction intervals.

3. **Calibration factor**  
   A correction factor used to adjust interval width when empirical coverage differs from the nominal target.

4. **Empirical coverage after calibration**  
   The final observed proportion of values contained within the calibrated prediction intervals.

This structure allows the thesis to evaluate whether uncertainty intervals are narrow, wide, underconfident, overconfident, or properly calibrated.

---

## 5. Main probabilistic quantities

The main quantities associated with this folder are:

| Quantity | Meaning | Role in the thesis |
|---|---|---|
| **PI90** | 90% prediction interval | Represents probabilistic uncertainty around model predictions. |
| **Coverage before calibration** | Empirical proportion inside the initial interval | Diagnoses initial interval reliability. |
| **Coverage after calibration** | Empirical proportion inside the calibrated interval | Evaluates final probabilistic consistency. |
| **c_PI90** | Calibration factor | Adjusts prediction interval width to improve empirical coverage. |
| **Interval width** | Difference between upper and lower bounds | Indicates the magnitude of predictive uncertainty. |

---

## 6. Expected result outputs

This folder may contain or document outputs such as:

- empirical coverage before calibration,
- empirical coverage after calibration,
- calibration factors by zone and horizon,
- PI90 interval-width summaries,
- probabilistic validation logs,
- uncertainty summaries by model,
- uncertainty summaries by zone,
- uncertainty summaries by prediction horizon,
- and final probabilistic synthesis outputs.

If the corresponding numerical files are stored in `04_RESULTS_COMPLETE/08_TABLES/`, this folder should be interpreted as the conceptual and methodological result layer that explains how those tables must be read.

---

## 7. Suggested naming logic for future files

If numerical outputs are added directly to this folder, the naming should remain explicit and traceable.

Recommended naming examples:

```text
coverage_pi90_before_calibration.csv
coverage_pi90_after_calibration.csv
c_pi90_by_zone_horizon.csv
pi90_interval_width_by_model.csv
pi90_uncertainty_summary.csv
probabilistic_validation_log.csv
```

This naming logic helps preserve clarity between uncertainty diagnosis, calibration, and final probabilistic interpretation.

---

## 8. Relationship with deterministic model comparison

This folder should be read after:

```text
04_RESULTS_COMPLETE/02_model_comparison/
```

The deterministic model-comparison layer evaluates point prediction performance using metrics such as RMSE, MAE, R², and Skill Score.

The PI90 uncertainty layer complements that evaluation by asking a different question:

```text
How reliable is the uncertainty associated with the prediction?
```

A model may present strong deterministic metrics but still provide poorly calibrated uncertainty intervals.

For that reason, deterministic accuracy and probabilistic calibration must be interpreted together.

---

## 9. Relationship with FNRR and energy projection

This folder also supports later interpretation in:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
```

Uncertainty affects the interpretation of regional energy potential because projected energy should not be read only as a single deterministic value.

The PI90 layer provides probabilistic context for the energetic outputs, allowing the thesis to distinguish between:

- predicted value,
- uncertainty around prediction,
- regional irregularity,
- free energy,
- usable energy,
- and projected energy scenarios.

---

## 10. Thesis linkage

This folder is aligned with the probabilistic uncertainty component of the thesis.

It supports results associated with:

- uncertainty quantification for WPD,
- empirical PI90 coverage,
- calibration of prediction intervals,
- comparison between nominal and empirical coverage,
- probabilistic interpretation by zone and horizon,
- and uncertainty-aware energetic projection.

The outputs and documentation in this folder should be interpreted together with the corresponding figures and tables organized in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

---

## 11. Relationship with code

The PI90 uncertainty results should be reproducible from the corresponding modeling and uncertainty workflow contained in:

```text
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
```

The folder `03_CODE/06_hybrid_tdq/` reflects the current repository naming. In this results layer, its role should be interpreted as part of the hybrid physical–statistical integration stage of the doctoral workflow.

The logical relationship is:

```text
processed zonal data
→ deterministic forecasts
→ residual or error structure
→ PI90 interval construction
→ empirical coverage evaluation
→ calibration
→ final probabilistic interpretation
→ energy-projection support
```

---

## 12. Relationship with the complete results folder

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

Within this structure, `03_pi90_uncertainty/` provides the probabilistic evaluation layer.

It connects deterministic model comparison with uncertainty-aware energy interpretation.

---

## 13. Methodological caution

This folder should not be interpreted as a guarantee that every prediction is correct within its interval.

A prediction interval expresses probabilistic uncertainty, not certainty.

The correct interpretation is empirical and statistical:

```text
approximately 90% of future observations should fall inside the calibrated PI90 interval,
under the validation conditions used in the thesis.
```

For this reason, PI90 must be interpreted in relation to:

- validation strategy,
- empirical coverage,
- calibration procedure,
- model behavior,
- prediction horizon,
- and zonal structure.

---

## 14. Interpretation role

The outputs associated with this folder support one of the most important methodological positions of the thesis:

A forecasting framework for wind-energy systems should not only predict, but also quantify the uncertainty of its predictions.

This is especially important in regional wind-energy analysis because the decision value of a forecast depends not only on its central estimate, but also on the reliability of the uncertainty range around that estimate.

---

## 15. Final note

This folder documents the probabilistic uncertainty layer of the doctoral thesis.

Its role is to connect:

- deterministic forecasting,
- PI90 interval construction,
- empirical coverage,
- calibration,
- regional uncertainty interpretation,
- and energy-projection support.

It is a central component of the repository because it demonstrates that the doctoral workflow does not only generate forecasts, but also evaluates the reliability and uncertainty of those forecasts.

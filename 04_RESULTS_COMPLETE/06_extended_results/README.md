# 06_extended_results

## Purpose

This folder contains the structured documentation and optional extended outputs associated with the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

It corresponds to the extended technical-support layer of the result structure.

This folder is part of:

```text
04_RESULTS_COMPLETE/
```

and must be interpreted as a complementary evidence environment for scientific traceability, reproducibility, and external academic review.

---

## 1. Scientific role of this folder

The thesis document presents the central results required to support the doctoral argument.

However, a complete reproducible repository may require additional outputs that do not necessarily appear in the main body of the thesis but are still relevant for:

- technical verification,
- methodological transparency,
- model-audit support,
- supplementary interpretation,
- and reproducibility.

This folder preserves that extended result layer.

Its function is not to overload the main thesis narrative, but to prevent the loss of technical evidence that may be useful during review, defense, or future research development.

---

## 2. Why extended results are necessary

In a doctoral workflow involving physical characterization, forecasting models, uncertainty calibration, FNRR computation, and energy projection, not every generated object can be included in the thesis manuscript.

Some results may be:

- too detailed for the main document,
- repetitive but useful for verification,
- auxiliary to figures or tables,
- related to model diagnostics,
- necessary for reproducibility,
- or useful for future articles and derivative products.

For that reason, this folder acts as a controlled repository space for supplementary evidence.

---

## 3. Expected types of extended outputs

This folder may contain or document outputs such as:

- complete metric matrices,
- extended horizon comparisons,
- residual-analysis outputs,
- additional validation outputs,
- training-support objects,
- model diagnostic outputs,
- auxiliary objects linked to figures and tables,
- intermediate summaries,
- robustness checks,
- supplementary scenario results,
- and technical files not included directly in the thesis body.

If these outputs are stored elsewhere in the repository, this folder should be interpreted as the documentation node that explains their role within the complete results architecture.

---

## 4. Suggested internal organization

If additional extended result files are added, the following internal structure is recommended:

```text
06_extended_results/
├── full_metrics/
├── residual_support/
├── additional_horizons/
├── training_support/
├── robustness_checks/
├── supplementary_scenarios/
└── README.md
```

These subfolders should only be created if they contain real files or documented outputs.

Empty folders should be avoided unless they include a `.gitkeep` file and a clear purpose.

---

## 5. Suggested naming logic

If files are added directly to this folder, file names should remain explicit, traceable, and connected to the doctoral workflow.

Recommended naming examples:

```text
full_metrics_by_model_zone_horizon.csv
residual_diagnostics_by_model.csv
additional_horizon_comparison.csv
training_history_lstm_by_zone.csv
robustness_check_summary.csv
supplementary_energy_scenarios.csv
extended_validation_log.csv
```

This naming logic helps reviewers understand the purpose of each file without requiring verbal explanation.

---

## 6. Relationship with physical characterization

Extended physical-characterization outputs may include additional support related to:

- descriptive statistics,
- distributional fitting,
- Weibull and Rayleigh comparison,
- temporal-dependence diagnostics,
- spectral analysis,
- wavelet analysis,
- and auxiliary zone-level summaries.

These outputs should remain coherent with:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
```

---

## 7. Relationship with model comparison

Extended model-comparison outputs may include detailed matrices or logs related to:

- RMSE,
- MAE,
- R²,
- Skill Score versus persistence,
- model rankings,
- horizon comparisons,
- zone comparisons,
- and winning-model selection.

These outputs should remain coherent with:

```text
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

---

## 8. Relationship with uncertainty

Extended uncertainty outputs may include:

- PI90 coverage diagnostics,
- interval-width summaries,
- calibration factors,
- pre-calibration results,
- post-calibration results,
- and probabilistic validation logs.

These outputs should remain coherent with:

```text
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

---

## 9. Relationship with FNRR and energy projection

Extended outputs may also support:

- FNRR computation,
- robust quantile-based summaries,
- free-energy estimation,
- usable-energy estimation,
- projection toward 2028,
- and additional energetic scenarios.

These outputs should remain coherent with:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

---

## 10. Relationship with appendices and reproducibility

This folder should be read together with:

```text
05_APPENDICES_SUPPORT/
07_REPRODUCIBILITY/
```

The appendices provide formal, methodological, mathematical, or technical explanations.

The reproducibility folder provides execution logic, software environment information, and verification support.

The extended results folder complements both by preserving additional output evidence.

---

## 11. Relationship with code

Extended outputs should be reproducible from one or more scripts contained in:

```text
03_CODE/
```

Depending on the result type, the relevant code may come from:

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

The folder `03_CODE/06_hybrid_tdq/` reflects the current repository naming. In this results layer, it should be interpreted as part of the hybrid physical–statistical integration stage of the doctoral workflow.

---

## 12. Methodological caution

This folder should not be interpreted as a place for uncurated exploratory material.

Only outputs that contribute to scientific traceability, reproducibility, review, defense, or derivative academic products should be included.

Files should be excluded from this folder if they are:

- temporary,
- redundant,
- undocumented,
- disconnected from the thesis workflow,
- exploratory without validation,
- or impossible to interpret from their file name and documentation.

This criterion protects the repository from becoming a disorganized archive.

---

## 13. Interpretation role

The main role of this folder is to preserve evidence that is scientifically relevant but not necessarily central enough to appear in the main thesis document.

It supports the following repository principle:

```text
The thesis presents the central narrative; the repository preserves the auditable evidence.
```

For that reason, this folder strengthens the reviewability of the doctoral work.

---

## 14. Closure criterion

This folder is considered properly organized when:

1. all extended files have clear names,
2. files can be traced to a code stage,
3. outputs are connected to the corresponding thesis chapter or appendix,
4. no uncurated drafts are included,
5. no unexplained temporary files remain,
6. and the folder supports external review without requiring verbal clarification.

---

## 15. Final note

This folder documents the extended-results layer of the doctoral repository.

Its role is to connect:

- technical outputs,
- supplementary evidence,
- model diagnostics,
- uncertainty support,
- FNRR and energy-projection support,
- appendices,
- and reproducibility material.

It exists to preserve transparency without overloading the main thesis document.

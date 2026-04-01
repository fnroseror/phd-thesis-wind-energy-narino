# Contributions Summary

## Overview

This doctoral thesis develops a hybrid physical–statistical framework for the characterization, prediction, and energetic interpretation of wind dynamics in the department of Nariño, Colombia. Its contribution is not limited to predictive performance alone; it integrates physical interpretation, comparative modeling, explicit uncertainty quantification, and a structurally interpretable regional metric to support more coherent wind-energy assessment.

---

## Main doctoral contributions

### 1. Regional physical–statistical characterization of wind in Nariño

The thesis establishes a structured physical characterization of wind dynamics in Nariño using approximately 8 million hourly meteorological records from 2017–2022, organized into four representative zones.

This characterization is not restricted to descriptive statistics. It integrates:

- distributional analysis,
- temporal dependence structure,
- spectral behavior,
- and multiscale non-stationary dynamics.

The resulting analysis demonstrates that wind in Nariño cannot be treated as a Gaussian stationary process, but rather as a nonlinear, multiscale atmospheric system with structural irregularity, persistence, and physically relevant intermittency.

---

### 2. Formulation of a hybrid physical–statistical forecasting methodology

A central contribution of the thesis is the construction of a coherent forecasting methodology that links physics, statistics, and predictive modeling under uncertainty.

The proposed methodology integrates:

- physical variable construction,
- structured preprocessing,
- temporal validation,
- deterministic evaluation,
- probabilistic calibration,
- and regional energetic interpretation.

This contribution is methodological in nature: the thesis does not present an isolated model, but a reproducible workflow that connects physical interpretation with predictive evaluation and energetic usability.

---

### 3. Comparative predictive evaluation under a unified experimental design

The thesis implements and evaluates multiple predictive families under a homogeneous framework, including:

- ARIMA and ARIMAX,
- Random Forest,
- XGBoost,
- Bayesian-tuned variants,
- LSTM-based architectures,
- and the TDQ–PIESS hybrid formulation.

A key contribution here is the use of a consistent time-series validation strategy and a unified evaluation logic for all models, allowing a fair comparison between classical, machine learning, deep learning, and hybrid approaches.

This provides not only performance comparison, but a structural interpretation of which types of models better align with the physical regimes observed in different zones of Nariño.

---

### 4. Prioritization of Skill Score against persistence as the main predictive criterion

The thesis makes an explicit epistemic and methodological decision: predictive value is not judged only by goodness-of-fit metrics such as R², but by real improvement over a physically meaningful baseline.

For this reason, the **Skill Score against persistence** is used as the principal criterion for model selection, while RMSE, MAE, and R² are treated as complementary metrics.

This contribution is important because it aligns model evaluation with operational relevance in atmospheric and energy forecasting, avoiding misleading overinterpretation of isolated statistical fit.

---

### 5. Explicit probabilistic uncertainty modeling through calibrated PI90 intervals

Another major contribution is the incorporation of predictive uncertainty as a core part of the doctoral framework.

Rather than presenting only point forecasts, the thesis includes:

- interval prediction at the 90% level (PI90),
- empirical coverage analysis,
- calibration procedures,
- and interpretation of uncertainty stability across zones and horizons.

This allows the framework to move from simple prediction toward **honest probabilistic forecasting**, where uncertainty is not treated as an accessory output but as a scientifically necessary property of the model.

---

### 6. Introduction and formalization of the FNRR index

One of the original contributions of the thesis is the introduction of the **Factor de No Regularidad Regional (FNRR)**.

FNRR is proposed as an adimensional index derived from robust quantiles of WPD to describe structural irregularity in the regional energetic regime. It is designed to be:

- bounded,
- robust,
- scale-invariant,
- and energetically interpretable.

Its role is not merely descriptive. FNRR acts as a bridge between physical variability, predictive difficulty, and energetic interpretation, providing a structural descriptor of regional irregularity that goes beyond traditional variance-based measures.

---

### 7. Distinction between free energy and structurally usable energy

The thesis introduces a physically and operationally meaningful distinction between:

- **free energy**,
- and **usable energy**.

This distinction is formalized through the relation:

**E_usable = (1 − FNRR) E_free**

This is a key doctoral contribution because it shows that physically available wind energy is not automatically equivalent to structurally usable energy. In this framework, irregularity is translated into an explicit energetic penalty, allowing the regime itself to modulate interpretation.

This contribution gives the thesis a stronger physical and decision-oriented dimension, extending the analysis beyond raw potential estimation.

---

### 8. Regional energy projection up to 2028 under uncertainty control

The thesis extends the validated framework into an annual regional projection up to 2028.

This is not presented as a naive extrapolation, but as the extension of a calibrated physical–statistical model that integrates:

- WPD as central variable,
- uncertainty propagation,
- FNRR-based modulation,
- and scenario-based interpretation.

The result is a regional energetic outlook that preserves methodological consistency and explicitly distinguishes between central tendency, uncertainty, and structural firmness.

---

### 9. Reproducible scientific architecture

A major methodological contribution of the thesis is its reproducible design.

The doctoral work is organized not only as a scientific argument in written form, but as a reproducible architecture composed of:

- data structuring,
- preprocessing logic,
- physical variable generation,
- predictive pipelines,
- calibration procedures,
- extended outputs,
- and supporting annex material.

This makes the work transferable to other regions with comparable meteorological information and strengthens the scientific traceability of the results.

---

### 10. Integration of TDQ as a unifying scientific framework within the thesis scope

Within the scope of this doctoral work, TDQ is presented as a hybrid physical–statistical framework that unifies:

- physical characterization,
- comparative forecasting,
- uncertainty quantification,
- and energetic interpretation.

Its contribution in the thesis is not philosophical or speculative, but methodological and scientific: TDQ organizes the system under a coherent structure in which physical information, predictive logic, and regional irregularity are interpreted jointly.

In this sense, the thesis establishes TDQ not merely as a label, but as an operational framework with explicit computational and energetic meaning.

---

## Scientific significance

Taken together, these contributions position the thesis as more than a conventional wind forecasting study.

Its scientific significance lies in the integration of:

- atmospheric physics,
- statistical modeling,
- benchmark-based predictive validation,
- uncertainty calibration,
- and regional energetic interpretation

within a single coherent framework.

The work therefore contributes simultaneously at four levels:

- **physical**, by interpreting wind as a structured atmospheric system;
- **statistical**, by introducing robust comparative and probabilistic evaluation;
- **methodological**, by proposing a reproducible hybrid pipeline;
- **applied**, by translating physical variability into usable energy assessment and regional projection.

---

## Final statement

The central contribution of this thesis is the demonstration that regional wind-energy forecasting in Nariño must be treated as a **physical–statistical problem under uncertainty**, not merely as a numerical regression task.

By combining physical characterization, hybrid predictive modeling, calibrated uncertainty, and the formalization of FNRR, the thesis establishes a structured doctoral contribution that is reproducible, transferable, and scientifically defensible.

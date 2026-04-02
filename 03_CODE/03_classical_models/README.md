# Classical Models

## Purpose

This folder contains the classical forecasting stage of the doctoral repository associated with the thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

Its purpose is to provide the baseline time-series forecasting framework used in Chapter 3 for comparative prediction of wind-energy-related variables derived from the zonal hourly system.

This folder corresponds specifically to the **classical-model component** of the comparative predictive design.

---

## Scientific role within the thesis

The doctoral work does not evaluate advanced models in isolation. Instead, it compares several predictive families under a unified validation framework.

Within that comparison, the classical stage plays two scientific roles:

1. it provides interpretable benchmark models grounded in standard time-series forecasting;
2. it establishes the baseline against which more flexible machine-learning, deep-learning, and hybrid methods can be judged.

For that reason, this folder should be understood as the first predictive layer of Chapter 3.

---

## Main predictive models represented in this folder

The classical models used in the doctoral workflow are:

- **Persistence**
- **ARIMA**
- **ARIMAX**

These models operate over the zonal hourly system derived from preprocessing and use the same horizon structure adopted in the thesis:

- **Short horizon**: 1 step
- **Medium horizon**: 12 steps
- **Long horizon**: 72 steps

---

## Target structure in the workflow

Within the final computational design, the classical pipeline works with the hourly zonal cache built from preprocessing and evaluates predictive performance for variables later interpreted in energetic terms.

In the final script structure used during thesis closure:

- the hourly cache is read from `WPD_hourly_por_zona.csv`,
- persistence is used as the baseline comparator,
- ARIMA is fitted on zonal WPD time series,
- ARIMAX incorporates exogenous physical variables,
- and aligned prediction vectors are exported for later hybrid integration.

---

## Main computational tasks represented in this folder

The scripts documented in this folder are responsible for the following tasks:

### 1. Reading the zonal hourly cache
- loading `WPD_hourly_por_zona.csv`,
- validating required columns,
- ordering the zonal time series,
- and preparing train/test partitions.

### 2. Baseline persistence forecasting
- building the persistence predictor,
- using it as the main reference for Skill evaluation,
- and exporting aligned persistence outputs.

### 3. ARIMA modeling
- fitting seasonal ARIMA models by zone,
- generating forecasts for each horizon,
- and evaluating deterministic performance.

### 4. ARIMAX modeling
- incorporating exogenous regressors such as `VV` and `rho`,
- generating exogenous forecasts where valid,
- and evaluating predictive performance against the same benchmark logic.

### 5. Horizon-based evaluation
- evaluating Short, Medium, and Long horizons,
- computing deterministic metrics,
- and translating aligned predictions into energetic comparison structures.

### 6. Prediction-cache export
- saving aligned prediction vectors for later use in the hybrid TDQ/FNRR stage,
- preserving compatibility with the broader modeling pipeline.

---

## Expected script in this folder

### `01_cap3_classical_models.R`

This is the main script expected in this folder.

Its role is to isolate and preserve the **classical sub-block** of the final Chapter 3 pipeline, including:

- persistence,
- ARIMA,
- ARIMAX,
- horizon-based evaluation,
- comparison against persistence,
- and export of aligned prediction vectors.

This script should be read as the reproducible classical baseline of the comparative predictive framework.

---

## Main outputs expected from this folder

The outputs associated with this folder include:

- model-performance tables for classical methods,
- horizon-wise evaluation summaries,
- persistence-based benchmark comparison,
- aligned prediction-cache files,
- and supporting figures or summaries used in Chapter 3.

These outputs are later reflected in:

- `04_RESULTS/model_comparison/`
- `06_TABLES/chapter_3/`
- `05_FIGURES/chapter_3/`
- and hybrid inputs consumed in `06_hybrid_tdq/`

---

## Relationship with previous stages

This folder depends directly on:

- `03_CODE/01_preprocessing/`

because it requires the zonal hourly cache and the physically constructed variables.

It also depends conceptually on:

- `03_CODE/02_physical_characterization/`

because the interpretation of persistence, regularity, and signal structure helps justify the use and limits of classical forecasting models.

---

## Relationship with later stages

This folder feeds the later comparative and hybrid stages of the repository.

### Feeds `04_machine_learning`
The classical models serve as an interpretable reference against which ML performance can be assessed.

### Feeds `05_deep_learning`
The DL stage is not interpreted in isolation; it is evaluated relative to simpler baselines established here.

### Feeds `06_hybrid_tdq`
Aligned prediction caches exported here are reused later for hybrid integration without forcing unnecessary retraining.

---

## Reproducibility note

This folder should be interpreted as the reproducible classical-model layer of Chapter 3.

Its purpose is not only to run ARIMA-like models, but to preserve a coherent predictive baseline under the same zonal, temporal, and evaluative logic used throughout the thesis.

For that reason, the scripts placed here should satisfy four conditions:

1. preserve zonal hourly forecasting logic,
2. keep the horizon structure explicit,
3. evaluate performance against persistence,
4. and export aligned outputs usable by later stages.

---

## Final interpretation

This folder represents the classical predictive baseline of the doctoral workflow.

If preprocessing creates the structured input and physical characterization provides scientific grounding, this folder establishes the first formal predictive reference of the thesis.

Without this stage, the later comparison with machine learning, deep learning, and TDQ–PIESS would lose methodological balance, because the advanced models would not be anchored to a transparent baseline.

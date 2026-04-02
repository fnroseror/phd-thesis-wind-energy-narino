# Machine Learning

## Purpose

This folder contains the machine-learning stage of the doctoral repository associated with the thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

Its purpose is to implement the non-linear predictive models used in Chapter 3 under the same zonal, temporal, and evaluative framework applied to the rest of the thesis.

This folder corresponds specifically to the **machine-learning component** of the comparative predictive design.

---

## Scientific role within the thesis

The doctoral work compares multiple predictive families under a unified methodological structure.

Within that comparison, the machine-learning stage plays three scientific roles:

1. it captures nonlinear relationships not fully represented by classical models;
2. it evaluates whether lagged physical structure improves predictive performance;
3. it provides an intermediate level between interpretable classical methods and more flexible deep-learning or hybrid approaches.

For that reason, this folder should be read as the second predictive layer of Chapter 3.

---

## Main predictive models represented in this folder

The machine-learning models used in the doctoral workflow are:

- **Random Forest**
- **XGBoost**
- **Bayesian-optimized variants of the ML models**

These models operate over the zonal hourly cache derived from preprocessing and use the same horizon structure adopted in the thesis:

- **Short horizon**: 1 step
- **Medium horizon**: 12 steps
- **Long horizon**: 72 steps

---

## Target structure in the workflow

Within the final computational design, the ML pipeline works with the hourly zonal cache built from preprocessing and evaluates predictive performance for variables later interpreted in energetic terms.

In the final script logic used during thesis closure:

- the hourly cache is read from `WPD_hourly_por_zona.csv`,
- lagged features are constructed from WPD and physically related variables,
- Random Forest and XGBoost are trained by zone,
- Bayesian optimization is used to refine model hyperparameters,
- and aligned prediction vectors are exported for later hybrid integration.

---

## Main computational tasks represented in this folder

The scripts documented in this folder are responsible for the following tasks:

### 1. Reading the zonal hourly cache
- loading `WPD_hourly_por_zona.csv`,
- validating required columns,
- ordering the zonal time series,
- and preparing train/test partitions.

### 2. Feature engineering
- creating lagged predictors,
- building rolling summaries,
- adding temporal covariates such as hour, weekday, and month,
- and preserving causality by using backward-looking information only.

### 3. Random Forest modeling
- training zone-specific Random Forest models,
- generating horizon-based predictions,
- and evaluating deterministic performance.

### 4. XGBoost modeling
- training zone-specific XGBoost models,
- generating horizon-based predictions,
- and comparing nonlinear boosting performance against the same benchmark logic.

### 5. Bayesian optimization
- tuning model hyperparameters under a time-series validation scheme,
- selecting competitive parameter combinations,
- and preserving comparability with the rest of the predictive framework.

### 6. Horizon-based evaluation
- evaluating Short, Medium, and Long horizons,
- computing deterministic metrics for WPD,
- deriving energetic evaluation through `Eh`,
- and comparing all results against persistence.

### 7. Prediction-cache export
- saving aligned prediction vectors for later use in the hybrid TDQ/FNRR stage,
- preserving compatibility with downstream integration without retraining.

---

## Expected script in this folder

### `01_cap3_ml_models.R`

This is the main script expected in this folder.

Its role is to isolate and preserve the **machine-learning sub-block** of the final Chapter 3 pipeline, including:

- lagged-feature construction,
- Random Forest,
- XGBoost,
- Bayesian optimization,
- horizon-based evaluation,
- comparison against persistence,
- and export of aligned prediction vectors.

This script should be interpreted as the reproducible ML layer of the comparative predictive framework.

---

## Main outputs expected from this folder

The outputs associated with this folder include:

- model-performance tables for ML methods,
- horizon-wise evaluation summaries,
- Bayesian-tuning summaries,
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
- `03_CODE/03_classical_models/`

because the physical structure of the signal and the baseline behavior of classical models help contextualize ML performance.

---

## Relationship with later stages

This folder feeds the later comparative and hybrid stages of the repository.

### Feeds `05_deep_learning`
The DL stage is compared against the nonlinear performance already established by ML.

### Feeds `06_hybrid_tdq`
Aligned prediction caches exported here are reused later for hybrid integration without unnecessary retraining.

### Feeds Chapter 4 interpretation
The energetic interpretation of predictive quality becomes stronger once ML results are available alongside classical and hybrid outputs.

---

## Reproducibility note

This folder should be interpreted as the reproducible machine-learning layer of Chapter 3.

Its purpose is not only to train flexible predictive models, but to preserve a coherent nonlinear modeling stage under the same zonal, temporal, and evaluative logic used throughout the thesis.

For that reason, the scripts placed here should satisfy four conditions:

1. preserve causal feature construction,
2. keep the horizon structure explicit,
3. evaluate performance against persistence,
4. and export aligned outputs usable by later stages.

---

## Final interpretation

This folder represents the nonlinear machine-learning layer of the doctoral workflow.

If classical models establish the initial predictive baseline, this folder explores whether structured nonlinear learning improves performance while remaining methodologically comparable.

Without this stage, the comparison among predictive families would be incomplete, and the later transition toward deep learning and TDQ–PIESS would lose an important intermediate reference.

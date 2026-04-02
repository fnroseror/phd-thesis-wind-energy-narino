# Deep Learning

## Purpose

This folder contains the deep-learning stage of the doctoral repository associated with the thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

Its purpose is to implement the LSTM-based predictive layer used in Chapter 3 under the same zonal, temporal, and evaluative framework adopted in the rest of the thesis.

This folder corresponds specifically to the **deep-learning component** of the comparative predictive design.

---

## Scientific role within the thesis

The doctoral work compares multiple predictive families under a unified methodological structure.

Within that comparison, the deep-learning stage plays three scientific roles:

1. it evaluates whether sequence-based models improve predictive performance over classical and machine-learning methods;
2. it captures temporal dependencies through learned internal representations rather than manually defined lag structures alone;
3. it provides the predictive layer closest to the later hybrid TDQ integration.

For that reason, this folder should be interpreted as the sequence-modeling layer of Chapter 3.

---

## Main predictive models represented in this folder

The deep-learning models used in the doctoral workflow are:

- **LSTM_ONLY**
- **LSTM_TDQ_BAYES**

These models operate over the zonal hourly cache derived from preprocessing and use the same horizon structure adopted in the thesis:

- **Short horizon**: 1 step
- **Medium horizon**: 12 steps
- **Long horizon**: 72 steps

---

## Target structure in the workflow

Within the final computational design, the DL pipeline works with the hourly zonal cache built from preprocessing and evaluates predictive performance for variables later interpreted in energetic terms.

In the final script logic used during thesis closure:

- the hourly cache is read from `WPD_hourly_por_zona.csv`,
- sliding windows are constructed by horizon,
- LSTM models are trained by zone,
- `Eh` is derived exactly from aligned WPD predictions,
- and prediction vectors are exported for later hybrid integration without retraining.

---

## Main computational tasks represented in this folder

The scripts documented in this folder are responsible for the following tasks:

### 1. Reading the zonal hourly cache
- loading `WPD_hourly_por_zona.csv`,
- validating required columns,
- ordering the zonal time series,
- and preparing horizon-specific windows.

### 2. Window construction
- building lookback windows by horizon,
- controlling stride by forecasting scale,
- preserving causal temporal ordering,
- and limiting computational cost through bounded sampling and validation/test caps.

### 3. LSTM modeling
- training LSTM-based models on zonal WPD sequences,
- generating horizon-based predictions,
- and evaluating deterministic performance.

### 4. Global hyperparameter tuning
- tuning shared hyperparameters by horizon,
- using a TDQ-oriented strategy centered on Zone 2,
- optionally transferring the best candidates to Zone 3,
- and reusing the selected configuration across zones.

### 5. Energetic derivation
- transforming aligned WPD predictions into `Eh`,
- preserving the same horizon-integrated logic used in the rest of the thesis,
- and maintaining comparability with the classical and ML stages.

### 6. Horizon-based evaluation
- evaluating Short, Medium, and Long horizons,
- computing deterministic metrics for WPD and Eh,
- and comparing all results against persistence.

### 7. Prediction and model export
- exporting aligned prediction files,
- saving trained `.keras` models,
- saving training curves,
- and generating publication-ready and annex figures.

---

## Expected script in this folder

### `01_cap3_dl_pipeline.R`

This is the main script expected in this folder.

Its role is to preserve the final deep-learning sub-block of the Chapter 3 workflow, including:

- sliding-window construction,
- LSTM training,
- DL-only and TDQ-Bayes variants,
- horizon-based evaluation,
- derivation of Eh from predicted WPD,
- export of aligned prediction vectors,
- and saving trained models and training curves.

This script should be interpreted as the reproducible DL layer of the comparative predictive framework.

---

## Main outputs expected from this folder

The outputs associated with this folder include:

- performance tables for DL methods,
- horizon-wise evaluation summaries,
- global hyperparameter tables,
- aligned prediction files,
- trained `.keras` models,
- training curves,
- and publication-ready and annex figures.

These outputs are later reflected in:

- `04_RESULTS/model_comparison/`
- `06_TABLES/chapter_3/`
- `05_FIGURES/chapter_3/`
- and hybrid inputs consumed in `06_hybrid_tdq/`

---

## Relationship with previous stages

This folder depends directly on:

- `03_CODE/01_preprocessing/`

because it requires the zonal hourly cache and the structured WPD series.

It also depends conceptually on:

- `03_CODE/02_physical_characterization/`
- `03_CODE/03_classical_models/`
- `03_CODE/04_machine_learning/`

because the DL results are interpreted within the broader comparative framework of the thesis.

---

## Relationship with later stages

This folder feeds the later hybrid and interpretive stages of the repository.

### Feeds `06_hybrid_tdq`
Aligned prediction exports from this stage can be reused in the hybrid TDQ/FNRR integration without forcing retraining.

### Feeds Chapter 4 interpretation
The energetic interpretation of predictive quality becomes stronger once DL outputs are available alongside classical, ML, and hybrid results.

---

## Reproducibility note

This folder should be interpreted as the reproducible deep-learning layer of Chapter 3.

Its purpose is not only to train LSTM models, but to preserve a coherent sequence-modeling stage under the same zonal, temporal, and evaluative logic used throughout the thesis.

For that reason, the scripts placed here should satisfy four conditions:

1. preserve causal window construction,
2. keep the horizon structure explicit,
3. evaluate WPD and Eh under the same benchmark logic,
4. and export aligned outputs usable by later stages.

---

## Final interpretation

This folder represents the sequence-based deep-learning layer of the doctoral workflow.

If machine learning explores structured nonlinear relationships through engineered predictors, this folder explores whether the temporal sequence itself contains predictive information that can be learned directly through recurrent architectures.

Without this stage, the comparative predictive architecture of the thesis would remain incomplete, especially in relation to the later hybrid TDQ integration.

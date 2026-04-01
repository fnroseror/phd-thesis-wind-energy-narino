# Data Processing Notes

## Purpose

This document summarizes the main preprocessing principles and data-treatment decisions used in the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

Its purpose is to preserve methodological traceability between the original observational records and the processed data structures used for physical characterization, predictive modeling, uncertainty quantification, and energetic interpretation.

---

## Observational basis

The doctoral research was developed from approximately **8 million hourly meteorological records** corresponding to the period **2017–2022**, obtained from **16 meteorological stations** and grouped into **four representative geographic zones** in the department of **Nariño, Colombia**.

The observational variables considered in the thesis include:

- wind speed,
- wind direction,
- temperature,
- atmospheric pressure,
- relative humidity,
- evaporation,
- cloudiness,
- precipitation,
- and atmospheric phenomenon.

This multivariable observational basis supports both the physical interpretation of the atmospheric system and the construction of the predictive framework developed in the thesis.

---

## General processing principle

The preprocessing stage was designed under a physically consistent criterion.

A central principle explicitly adopted in the thesis is that the signal must be treated while **respecting its physical nature**, avoiding transformations that could distort the original energetic structure of the atmospheric system.

This principle is especially important because the thesis is built around the physical interpretation of wind behavior and around the construction of derived energetic variables such as **WPD** and **Eh**, whose meaning depends directly on the integrity of the original signal.

---

## Main preprocessing operations

According to the methodological description of the thesis, the data treatment stage included the following operations:

### 1. Elimination of non-physical negative values

Negative values that were not physically admissible were removed during preprocessing.

This operation was necessary to prevent invalid atmospheric and energetic interpretations and to preserve physical consistency before any statistical or predictive analysis.

### 2. Quality control

A quality-control stage was applied to the observational records.

Its role was to identify and manage inconsistencies in the data before entering the characterization and modeling stages, ensuring that the analytical results rest on a curated observational basis.

### 3. Recording of zero proportions

The preprocessing workflow included the registration of the proportion of zero values.

This is methodologically relevant because zero concentration may affect the interpretation of variable structure, data completeness, and later model behavior, especially in multivariable environmental systems.

### 4. Temporal-resolution analysis

The thesis states that the preprocessing stage included analysis of temporal resolution.

Given that the observational basis is structured as hourly data, temporal-resolution verification is necessary to maintain consistency between the original records and the subsequent analytical pipeline.

### 5. Cleaning traceability

The preprocessing stage preserved **traceability of cleaning operations**.

This means that the doctoral workflow was not designed as an opaque filtering process, but as a reproducible and methodologically accountable transformation from raw observational input to analysis-ready data.

---

## Zonal organization after preprocessing

After preprocessing, the observational system was organized into **four representative geographic zones**.

This zonal grouping is not merely administrative. It is part of the methodological structure of the thesis and supports:

- regional physical characterization,
- comparison of differentiated wind regimes,
- predictive evaluation by zone,
- and regional energetic projection.

For this reason, preprocessing must be interpreted not only at the station level, but also as a preparation step for zonal scientific analysis.

---

## Relationship with the physical analysis stage

The processed data were used to support the physical–statistical characterization of wind behavior, including:

- descriptive statistics,
- Weibull fitting,
- Rayleigh comparison,
- ACF/PACF analysis,
- FFT spectral analysis,
- and Wavelet-based time–frequency interpretation.

This means that preprocessing was not an isolated technical step. It directly conditions the validity of the physical interpretation developed in Chapter 2 of the thesis.

---

## Relationship with the predictive modeling stage

The cleaned and structured data also support the predictive stage of the thesis, which includes:

- ARIMA and ARIMAX models,
- Random Forest,
- XGBoost,
- LSTM-based architectures,
- and the hybrid TDQ–PIESS framework.

Because the thesis evaluates both deterministic and probabilistic performance, the quality and consistency of preprocessing are essential for ensuring reliable model comparison, valid uncertainty calibration, and coherent energetic interpretation.

---

## Relationship with derived physical variables

A key objective of preprocessing is to ensure that the observed variables remain suitable for the construction of derived quantities used throughout the thesis, especially:

- **air density (ρ)**,
- **Wind Power Density (WPD)**,
- **Eh**,
- and the later energetic interpretation involving **FNRR**.

Since **WPD** depends cubically on wind speed, any distortion introduced during preprocessing could propagate nonlinearly into the energetic outputs of the thesis. This is one of the reasons why the thesis explicitly emphasizes physically respectful signal treatment.

---

## Methodological interpretation

Within the logic of the doctoral work, preprocessing should be understood as a **scientific preparation stage**, not merely as a technical cleaning routine.

Its role is to guarantee that:

- the observational basis remains physically interpretable,
- the zonal structure remains analytically coherent,
- the predictive framework operates on consistent input,
- and the energetic quantities derived later preserve scientific meaning.

---

## Repository interpretation

Within this repository, preprocessing notes serve as a bridge between:

- the observational metadata,
- the station-to-zone structure,
- the executable preprocessing scripts,
- and the physical and predictive outputs reported in the thesis.

This document should therefore be read together with:

- `01_dataset_overview.md`,
- `02_variable_dictionary.md`,
- `03_station_zone_mapping.md`,
- and the code files contained in the preprocessing section of the repository.

---

## Final note

The doctoral thesis does not frame preprocessing as a purely statistical filtering stage. Instead, it treats it as a **physically informed preparation process** required to preserve the structural meaning of the atmospheric system before characterization, modeling, uncertainty quantification, and energetic projection.

For this reason, preprocessing is one of the foundational components of the reproducible architecture of the thesis.

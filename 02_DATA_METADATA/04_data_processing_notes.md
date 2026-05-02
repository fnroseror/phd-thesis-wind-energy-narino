# Data Processing Notes

## Purpose

This document summarizes the main preprocessing principles and data-treatment decisions used in the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

Its purpose is to preserve methodological traceability between the original observational records and the processed data structures used for physical characterization, predictive modeling, uncertainty quantification, and energetic interpretation.

This document should be read as a scientific traceability note, not as a generic data-cleaning description.

---

## 1. Observational basis

The doctoral research was developed from approximately **8 million hourly meteorological records** corresponding to the period **2017–2022**, obtained from **16 IDEAM meteorological stations** and grouped into **four analytical zones** in the department of **Nariño, Colombia**.

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

## 2. General processing principle

The preprocessing stage was designed under a physically consistent criterion.

A central principle adopted in the thesis is that the signal must be treated while **respecting its physical nature**, avoiding transformations that could distort the original energetic structure of the atmospheric system.

This principle is especially important because the thesis is built around the physical interpretation of wind behavior and around the construction of derived energetic variables such as **air density (ρ)**, **Wind Power Density (WPD)**, **horizon-integrated energy (Eh)**, and the regional irregularity descriptor **FNRR**.

Since **WPD** depends cubically on wind speed, any artificial distortion introduced during preprocessing may propagate nonlinearly into the energetic interpretation. For this reason, preprocessing is treated as a scientific preparation stage rather than as a purely mechanical filtering procedure.

---

## 3. Main preprocessing operations

According to the methodological structure of the thesis, the data-treatment stage included the following operations.

### 3.1 Elimination of non-physical negative values

Negative values that were not physically admissible were removed during preprocessing.

This operation was necessary to prevent invalid atmospheric and energetic interpretations and to preserve physical consistency before any statistical, predictive, or energetic analysis.

The criterion is especially relevant for variables whose physical interpretation does not admit negative magnitudes under the conditions used in the thesis workflow.

---

### 3.2 Quality control

A quality-control stage was applied to the observational records.

Its role was to identify and manage inconsistencies before entering the characterization and modeling stages, ensuring that the analytical results rest on a curated observational basis.

This quality-control process supports the reliability of:

- descriptive statistics,
- distributional fitting,
- spectral analysis,
- predictive modeling,
- uncertainty estimation,
- and energetic projection.

---

### 3.3 Recording of zero proportions

The preprocessing workflow included the registration of the proportion of zero values.

This is methodologically relevant because zero concentration may affect the interpretation of variable structure, data completeness, intermittency, and later model behavior, especially in multivariable environmental systems.

In the context of wind-energy analysis, zero or near-zero values are not merely numerical events. They may represent physically meaningful calm conditions, sensor behavior, missing-data effects, or low-energy regimes depending on the variable and context.

For that reason, zero proportions were treated as part of the diagnostic traceability of the dataset.

---

### 3.4 Temporal-resolution analysis

The thesis uses hourly observational records. Therefore, temporal-resolution verification is necessary to maintain consistency between the original records and the subsequent analytical pipeline.

Temporal consistency is important because several analyses depend directly on the ordering and spacing of the observations, including:

- autocorrelation analysis,
- partial autocorrelation analysis,
- spectral analysis,
- wavelet-based time-frequency interpretation,
- time-series forecasting,
- and horizon-based energy integration.

---

### 3.5 Unit harmonization for physical calculations

Observed variables may originate from source-specific units or formats. For physical calculations, the relevant variables must be harmonized into units compatible with the equations used in the thesis.

This is especially important for:

- wind speed,
- temperature,
- atmospheric pressure,
- air density estimation,
- and Wind Power Density construction.

The physical calculations associated with **ρ** and **WPD** require unit consistency. Without this step, the derived energetic variables would not preserve physical meaning.

---

### 3.6 Cleaning traceability

The preprocessing stage preserved traceability of cleaning operations.

This means that the doctoral workflow was not designed as an opaque filtering process, but as a reproducible and methodologically accountable transformation from raw observational input to analysis-ready data.

Traceability is essential because it allows the relationship between source data, processed data, code outputs, tables, figures, and thesis results to remain verifiable.

---

## 4. Zonal organization after preprocessing

After preprocessing, the observational system was organized into **four analytical zones**.

This zonal grouping is part of the methodological structure of the thesis and supports:

- regional physical characterization,
- comparison of differentiated wind regimes,
- predictive evaluation by zone,
- uncertainty interpretation by zone,
- and regional energetic projection.

For this reason, preprocessing must be interpreted not only at the station level, but also as a preparation step for zonal scientific analysis.

The zone is the operational spatial unit used to connect the observational system with the physical-statistical modeling framework.

---

## 5. Relationship with the physical analysis stage

The processed data were used to support the physical–statistical characterization of wind behavior, including:

- descriptive statistics,
- Weibull fitting,
- Rayleigh comparison,
- ACF/PACF analysis,
- FFT spectral analysis,
- and Wavelet-based time-frequency interpretation.

This means that preprocessing was not an isolated technical step. It directly conditions the validity of the physical interpretation developed in the thesis.

The physical characterization stage depends on preserving the structural behavior of the atmospheric signal, including its variability, intermittency, temporal dependence, and spectral content.

---

## 6. Relationship with the predictive modeling stage

The cleaned and structured data support the predictive stage of the thesis, which includes:

- classical time-series models,
- machine learning models,
- deep learning architectures,
- and hybrid physical–statistical integration.

Because the thesis evaluates both deterministic and probabilistic performance, the quality and consistency of preprocessing are essential for ensuring:

- reliable model comparison,
- valid uncertainty calibration,
- meaningful Skill Score evaluation against persistence,
- coherent PI90 interpretation,
- and physically interpretable energetic outputs.

---

## 7. Relationship with derived physical variables

A key objective of preprocessing is to ensure that the observed variables remain suitable for the construction of derived quantities used throughout the thesis, especially:

- **air density (ρ)**,
- **Wind Power Density (WPD)**,
- **horizon-integrated energy (Eh)**,
- **free energy**,
- **usable energy**,
- and **FNRR**.

The construction of WPD requires preserving the physical relationship between air density and wind speed:

```text
WPD = 0.5 · ρ · v³
```

This cubic dependence makes WPD highly sensitive to variations in wind speed. Therefore, preprocessing decisions must avoid artificial modifications that could amplify or suppress the energetic structure of the signal.

---

## 8. Methodological interpretation

Within the logic of the doctoral work, preprocessing should be understood as a **scientific preparation stage**, not merely as a technical cleaning routine.

Its role is to guarantee that:

- the observational basis remains physically interpretable,
- the zonal structure remains analytically coherent,
- the predictive framework operates on consistent input,
- uncertainty analysis remains meaningful,
- and the energetic quantities derived later preserve scientific validity.

This interpretation is central to the thesis because the dataset is not treated as an abstract numerical table, but as an observational representation of a regional atmospheric system.

---

## 9. Repository interpretation

Within this repository, preprocessing notes serve as a bridge between:

- the observational metadata,
- the station-to-zone structure,
- the executable preprocessing scripts,
- the physical characterization outputs,
- the predictive modeling outputs,
- and the energetic results reported in the thesis.

This document should therefore be read together with:

- `01_dataset_overview.md`,
- `02_variable_dictionary.md`,
- `03_station_zone_mapping.md`,
- the preprocessing scripts in `03_CODE/`,
- and the generated evidence contained in `04_RESULTS_COMPLETE/`.

---

## 10. Methodological caution

This document summarizes the processing principles used in the doctoral workflow. It does not replace the executable scripts, the thesis methodology, or the reproducibility files.

Any exact implementation detail must be verified in the corresponding code and reproducibility documentation.

The purpose of this file is to preserve the scientific rationale behind preprocessing decisions and to make explicit why data treatment is necessary for the physical, predictive, probabilistic, and energetic stages of the thesis.

---

## 11. Final note

The doctoral thesis does not frame preprocessing as a purely statistical filtering stage. Instead, it treats preprocessing as a **physically informed preparation process** required to preserve the structural meaning of the atmospheric system before characterization, modeling, uncertainty quantification, and energetic projection.

For that reason, preprocessing is one of the foundational components of the reproducible architecture of the thesis.

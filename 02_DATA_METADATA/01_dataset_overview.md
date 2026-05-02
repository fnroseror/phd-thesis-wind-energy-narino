# Dataset Overview

## General description

This repository is associated with the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

The empirical basis of the research consists of an approximately **8-million-record hourly meteorological dataset** corresponding to the period **2017–2022**, built from **16 IDEAM meteorological stations** and organized into **four representative geographic zones** in the department of **Nariño, Colombia**.

This observational dataset constitutes the physical and statistical foundation of the doctoral work. It supports the characterization of wind dynamics, the construction of derived physical variables, the comparative predictive modeling framework, and the regional energetic interpretation developed throughout the thesis.

---

## Temporal coverage

The historical observational period used in the research spans from **2017 to 2022**.

Based on this information, the thesis develops and validates a forecasting framework whose energetic projection extends to **2028**. For this reason, the observational window serves as the empirical basis for model construction, validation, and historical interpretation, while the projected horizon represents the prospective stage of the doctoral framework.

---

## Spatial coverage

The dataset corresponds to the department of **Nariño**, a region treated in the thesis as a scientifically relevant case due to its meteorological complexity, topographic heterogeneity, and wind-energy potential.

To ensure spatial representativeness and variable completeness, the 16 stations were grouped into **four geographic zones**. This zonal organization is a structural component of the thesis, since the physical characterization, predictive comparison, uncertainty interpretation, and energetic projection are all performed at the regional zonal level.

---

## Observed variables

According to the methodological design of the thesis, the observational dataset includes the following meteorological variables:

- **VV** — Wind speed
- **DV** — Wind direction
- **Tmin** — Minimum temperature
- **Tmax** — Maximum temperature
- **PA** — Atmospheric pressure
- **HR** — Relative humidity
- **EV** — Evaporation
- **NU** — Cloudiness
- **PR** — Precipitation
- **FA** — Atmospheric phenomenon

These variables provide the meteorological basis required both for the physical analysis of wind behavior and for the subsequent predictive and energetic modeling stages.

---

## Derived variables within the thesis

The thesis is not limited to the use of raw observed variables. It also constructs derived physical and energetic variables required by the doctoral framework.

The most relevant derived variables are:

- **ρ (air density)**, estimated through the ideal gas approximation.
- **WPD (Wind Power Density)**, defined as the **central variable of analysis** in the thesis.
- **Eh**, interpreted as **horizon-integrated energy** for accumulated energetic analysis.
- **FNRR**, introduced as a structural descriptor of regional irregularity.

Within the scope of the thesis, **WPD** is treated as the central physical target variable, while **Eh** is used as a derived energetic quantity for operational interpretation.

---

## Scientific role of the dataset

The dataset fulfills three major scientific functions within the doctoral research.

### 1. Physical characterization of wind

It supports the multiscale physical–statistical characterization of wind dynamics, including:

- descriptive statistics,
- Weibull fitting,
- Rayleigh comparison,
- temporal dependence analysis through ACF and PACF,
- spectral analysis through FFT,
- and time–frequency analysis through Wavelet decomposition.

This stage provides the structural physical interpretation of wind behavior in Nariño.

### 2. Predictive modeling

It provides the empirical basis for the comparative forecasting framework, including:

- classical models such as ARIMA and ARIMAX,
- machine learning models such as Random Forest and XGBoost,
- deep learning architectures based on LSTM,
- and a hybrid physical–statistical integration approach.

The dataset therefore supports both deterministic and probabilistic evaluation of predictive performance.

### 3. Energetic interpretation and projection

It enables the construction and interpretation of:

- Wind Power Density (WPD),
- free energy,
- usable energy,
- calibrated PI90 intervals,
- and projected regional energetic scenarios up to 2028.

This makes the dataset essential not only for forecasting, but also for translating atmospheric variability into physically interpretable energetic outcomes.

---

## Data treatment principles

The thesis establishes that the observational data were preprocessed under a physically consistent strategy. The main procedures include:

- elimination of non-physical negative values,
- quality control,
- recording of zero proportions,
- temporal-resolution analysis,
- and cleaning traceability.

A key principle of the work is that the signal was processed while respecting its **physical nature**, avoiding transformations that could distort its original energetic structure.

---

## Interpretation within the repository

Within this repository, the dataset should not be understood as a simple collection of meteorological observations. It should be interpreted as the **observational foundation of a reproducible physical–statistical system**.

All subsequent repository sections related to code, results, figures, tables, appendices, and reproducibility are conceptually anchored in this dataset and in its zonal organization.

For that reason, this overview functions as the entry point to the empirical base of the thesis.

---

## Repository note

As stated in the annex section of the thesis, the broader repository is intended to consolidate the zonal data structure, preprocessing scripts, physical-variable generation, classical/ML/DL pipelines, TDQ–PIESS implementation, FNRR computation, PI90 calibration, prospective projection, and the materials necessary to guarantee the computational reproducibility of the reported results.

This dataset overview is therefore the starting point for understanding the observational basis of that reproducible doctoral system.

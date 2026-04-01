# Dataset Overview

## General description

This repository is associated with the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

The observational basis of the research consists of an approximately **8-million-record hourly meteorological dataset** corresponding to the period **2017–2022**, built from **16 meteorological stations of IDEAM** and organized into **four representative geographic zones** in the department of **Nariño, Colombia**. This dataset provides the empirical foundation for the physical characterization of wind, the construction of derived energetic variables, and the comparative predictive modeling framework developed throughout the thesis. :contentReference[oaicite:1]{index=1}

---

## Temporal coverage

The observational period used in the doctoral research spans from **2017 to 2022**. Based on this historical information, the thesis develops and validates a forecasting methodology whose energetic projection extends up to the year **2028**. The historical period is therefore the empirical training and validation basis of the scientific workflow, while the projected horizon corresponds to the prospective stage of the thesis. :contentReference[oaicite:2]{index=2}

---

## Spatial coverage

The data correspond to the department of **Nariño**, a region characterized in the thesis as meteorologically complex and scientifically relevant due to its topography, atmospheric variability, and wind-energy potential. The 16 stations were grouped into **four geographic zones** in order to ensure spatial representativeness and variable completeness for regional analysis. This zonal organization is central to the physical interpretation, predictive modeling, and energetic comparison performed in the thesis. :contentReference[oaicite:3]{index=3}

---

## Variables included

According to the thesis methodology, the observational dataset includes the following meteorological variables:

- Wind speed (**VV**)
- Wind direction (**DV**)
- Temperature (**Tmin**, **Tmax**)
- Atmospheric pressure (**PA**)
- Relative humidity (**HR**)
- Evaporation (**EV**)
- Cloudiness (**NU**)
- Precipitation (**PR**)
- Atmospheric phenomenon (**FA**) :contentReference[oaicite:4]{index=4}

These variables were used both for physical characterization of wind behavior and for the construction of derived variables required by the predictive and energetic framework of the thesis. :contentReference[oaicite:5]{index=5}

---

## Derived variables used in the thesis

The doctoral work does not stop at the raw meteorological variables. It constructs a set of physically meaningful derived variables, among which the most important are:

- **Air density (ρ)**, estimated through the ideal gas approximation.
- **Wind Power Density (WPD)**, defined as the central target variable of the thesis.
- **Eh**, interpreted as horizon-integrated energy for accumulated energetic analysis.
- **FNRR**, introduced later in the thesis as a structural regional irregularity index. :contentReference[oaicite:6]{index=6}

The thesis explicitly states that **WPD** is the central variable of analysis, derived from wind speed and air density, while **Eh** is treated as a derived variable for accumulated energetic interpretation. :contentReference[oaicite:7]{index=7}

---

## Scientific role of the dataset

This dataset fulfills three scientific functions within the doctoral research:

### 1. Physical characterization
It supports the multiscale physical–statistical characterization of wind dynamics, including:

- descriptive statistics,
- Weibull distribution fitting,
- ACF/PACF temporal dependence analysis,
- FFT spectral analysis,
- and Wavelet-based time–frequency analysis. :contentReference[oaicite:8]{index=8}

### 2. Predictive modeling
It provides the empirical basis for the comparative forecasting pipeline integrating:

- ARIMA and ARIMAX,
- Random Forest,
- XGBoost,
- Bayesian-optimized LSTM architectures,
- and the hybrid TDQ–PIESS formulation. :contentReference[oaicite:9]{index=9}

### 3. Energetic interpretation
It enables the calculation of:

- WPD,
- free energy,
- usable energy,
- calibrated PI90 intervals,
- and regional projections up to 2028 under explicit uncertainty control. :contentReference[oaicite:10]{index=10}

---

## Data treatment within the thesis

The thesis states that preprocessing was performed through:

- elimination of non-physical negative values,
- quality control,
- recording of zero proportions,
- temporal resolution analysis,
- and cleaning traceability.

A key methodological principle of the work is that the signal was treated while respecting its physical nature, avoiding transformations that would alter its original energetic structure. :contentReference[oaicite:11]{index=11}

---

## Interpretation within the repository

Within this repository, the dataset should be understood not merely as a collection of meteorological observations, but as the **empirical physical basis** of the doctoral framework. It supports:

- regional wind characterization,
- physical variable construction,
- benchmark-based predictive validation,
- explicit uncertainty quantification,
- and the translation from observed wind behavior to energetic interpretation. :contentReference[oaicite:12]{index=12}

For this reason, all subsequent repository sections related to preprocessing, physical characterization, predictive models, energetic results, and reproducibility are conceptually anchored in this observational dataset. :contentReference[oaicite:13]{index=13}

---

## Repository note

As stated in the thesis annex section, the broader repository is intended to consolidate the zonal data structure, preprocessing scripts, physical-variable generation, classical/ML/DL pipelines, TDQ–PIESS implementation, FNRR computation, PI90 calibration, prospective projection, and the materials necessary to guarantee the computational reproducibility of the reported results. This dataset overview is therefore the entry point to the observational foundation of that reproducible system. :contentReference[oaicite:14]{index=14}

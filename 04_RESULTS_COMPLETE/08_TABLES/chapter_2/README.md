# Chapter 2 Tables — Physical Characterization and Data Traceability

## Purpose

This folder contains the tabular evidence associated with Chapter 2 of the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The tables in this folder support the physical and statistical characterization of the meteorological system before predictive modeling.

This folder is part of:

```text
04_RESULTS_COMPLETE/08_TABLES/
```

and should be interpreted as the numerical evidence layer for the physical characterization stage of the thesis.

---

## 1. Scientific role of these tables

Chapter 2 establishes the empirical and physical basis of the doctoral work.

The tables contained in this folder document:

- observational record availability,
- data-quality diagnostics,
- temporal-resolution structure,
- processing parameters,
- wind-speed descriptive statistics,
- cleaning traceability,
- zonal organization,
- signal variability,
- Weibull parameter estimation,
- and Weibull versus Rayleigh comparison.

This tabular layer supports the transition from:

```text
observational data
→ quality control
→ preprocessing traceability
→ zonal organization
→ physical characterization
→ distributional analysis
→ forecasting basis
```

The purpose of these tables is not only to report numbers, but to preserve the numerical traceability of the physical characterization stage.

---

## 2. Current tables in this folder

The current contents of this folder are:

| File | Scientific function |
|---|---|
| `A1_Conteo_Registros_por_Variable.csv` | Documents the number of available records by meteorological variable. |
| `A2_QC_NA_y_Negativos_por_Variable.csv` | Summarizes missing values and negative-value diagnostics by variable. |
| `A3_Resolucion_Temporal_por_Zona_Estacion.csv` | Documents temporal-resolution structure by zone and station. |
| `CFG_Cap2_parametros_usados.csv` | Stores configuration parameters used in the Chapter 2 analysis. |
| `VV_Descriptivos_por_Zona.csv` | Provides descriptive statistics of wind speed by zone. |
| `VV_Log_Parametros_Procesamiento.csv` | Records processing parameters applied to the wind-speed workflow. |
| `VV_Tabla_Maestra_Zonas.csv` | Preserves the master zonal structure used for wind-speed analysis. |
| `VV_Trazabilidad_Limpieza.csv` | Documents cleaning traceability for wind-speed data. |
| `VV_Varianza_SenalZonal_por_Zona.csv` | Summarizes zonal signal variance for wind speed. |
| `VV_Weibull_MLE_por_Zona.csv` | Stores Weibull parameter estimation by maximum likelihood for each zone. |
| `VV_Weibull_vs_Rayleigh_por_Zona.csv` | Compares Weibull and Rayleigh distributional behavior by zone. |

---

## 3. Data availability and quality-control tables

### `A1_Conteo_Registros_por_Variable.csv`

This table documents the number of available observational records by meteorological variable.

Scientific interpretation:

It supports the empirical description of the dataset and allows reviewers to identify the relative availability of each variable in the observational system.

This is important because the meteorological database is heterogeneous: not all variables have the same number of records, temporal density, or spatial availability.

---

### `A2_QC_NA_y_Negativos_por_Variable.csv`

This table summarizes missing-value diagnostics and negative-value diagnostics by variable.

Scientific interpretation:

It supports the quality-control stage of the thesis.

The table helps identify which variables required particular attention before physical characterization and predictive modeling.

This is essential because physically inconsistent or missing values may affect:

- descriptive statistics,
- distributional fitting,
- model training,
- uncertainty estimation,
- and derived energetic variables.

---

### `A3_Resolucion_Temporal_por_Zona_Estacion.csv`

This table documents temporal-resolution characteristics by zone and station.

Scientific interpretation:

It supports the verification of temporal consistency in the observational system.

Temporal resolution is particularly important because the thesis uses time-series, spectral, wavelet, and forecasting approaches.

A physically meaningful temporal analysis requires that the time structure of the data be explicitly documented.

---

## 4. Processing-configuration tables

### `CFG_Cap2_parametros_usados.csv`

This table stores the configuration parameters used during the Chapter 2 analysis.

Scientific interpretation:

It supports reproducibility by documenting the computational parameters applied in the physical characterization stage.

This file acts as a configuration record, allowing the analysis to be reviewed, repeated, or audited with greater clarity.

---

### `VV_Log_Parametros_Procesamiento.csv`

This table records the parameters used during the wind-speed processing workflow.

Scientific interpretation:

It supports methodological traceability.

The file helps connect raw or processed wind-speed observations with the final descriptive and distributional outputs reported in Chapter 2.

---

### `VV_Trazabilidad_Limpieza.csv`

This table documents the traceability of cleaning operations applied to wind-speed data.

Scientific interpretation:

It shows that preprocessing was not an opaque filtering stage.

Instead, it preserves a record of how the wind-speed signal was treated before characterization.

This is important because the thesis interprets the wind signal physically; therefore, data treatment must avoid artificial distortion of the signal structure.

---

## 5. Zonal organization table

### `VV_Tabla_Maestra_Zonas.csv`

This table preserves the master zonal structure used for the wind-speed analysis.

Scientific interpretation:

It connects the station-level observational system with the four analytical zones used throughout the thesis.

The zonal structure is essential because the thesis interprets Nariño as a heterogeneous regional atmospheric system rather than as a single homogeneous domain.

This table should be read together with:

```text
02_DATA_METADATA/03_station_zone_mapping.md
```

---

## 6. Descriptive statistics table

### `VV_Descriptivos_por_Zona.csv`

This table contains descriptive statistics of wind speed by zone.

Scientific interpretation:

It supports the first quantitative characterization of the wind-speed signal.

The table provides information about:

- sample size,
- central tendency,
- dispersion,
- empirical range,
- percentiles,
- asymmetry,
- and distributional concentration.

These quantities are necessary to understand the regional structure of the wind signal before applying forecasting models.

---

## 7. Signal-variance table

### `VV_Varianza_SenalZonal_por_Zona.csv`

This table summarizes the variance of the zonal wind-speed signal.

Scientific interpretation:

It supports the interpretation of variability by zone.

Variance is important because zones with greater variability may show stronger intermittency, higher forecasting difficulty, or greater energetic fluctuation.

In the context of wind-energy modeling, variability is not merely a statistical property; it affects the stability and interpretation of the energetic signal.

---

## 8. Weibull parameter table

### `VV_Weibull_MLE_por_Zona.csv`

This table contains Weibull parameter estimation by maximum likelihood.

Scientific interpretation:

The Weibull distribution is used to characterize wind-speed regimes because it provides a flexible representation of distributional shape and scale.

The table supports the estimation of:

- Weibull shape parameter `k`,
- Weibull scale parameter `c`,
- zero-value proportion,
- standard errors,
- information criteria,
- goodness-of-fit indicators,
- and energetic moments.

The shape parameter `k` supports interpretation of distributional regularity, while the scale parameter `c` supports interpretation of characteristic wind-speed magnitude.

---

## 9. Weibull versus Rayleigh comparison table

### `VV_Weibull_vs_Rayleigh_por_Zona.csv`

This table compares Weibull and Rayleigh distributional behavior by zone.

Scientific interpretation:

Rayleigh can be interpreted as a more restricted distributional case, while Weibull provides additional flexibility through the shape parameter.

This comparison is important because it supports the decision to characterize the wind-speed signal using a distributional model capable of representing regional asymmetry and variability.

The table provides numerical support for the distributional interpretation presented in Chapter 2.

---

## 10. Relationship with Chapter 2 figures

These tables should be interpreted together with the visual evidence contained in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
```

The tables provide numerical evidence.

The figures provide visual interpretation.

Together, they support the physical characterization of wind speed in Nariño.

---

## 11. Relationship with physical characterization outputs

These tables are directly connected to:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
```

In particular, the following files appear both as central characterization outputs and as Chapter 2 tabular evidence:

```text
VV_Descriptivos_por_Zona.csv
VV_Weibull_MLE_por_Zona.csv
VV_Weibull_vs_Rayleigh_por_Zona.csv
```

This duplication should be interpreted as intentional evidence alignment: the files support both the results folder and the chapter-level table organization.

---

## 12. Relationship with code

The tables in this folder should be reproducible from the preprocessing and physical-characterization workflow contained in:

```text
03_CODE/01_preprocessing/
03_CODE/02_physical_characterization/
```

The logical relationship is:

```text
observational records
→ quality control
→ preprocessing
→ zonal organization
→ descriptive statistics
→ variance analysis
→ Weibull fitting
→ Weibull-Rayleigh comparison
→ Chapter 2 tables
```

---

## 13. Methodological caution

The tables in this folder should not be interpreted in isolation.

Each table must be read according to:

- the variable analyzed,
- the preprocessing stage,
- the zone or station represented,
- the statistical method used,
- the corresponding figure,
- and the physical interpretation developed in Chapter 2.

This prevents numerical values from being interpreted without methodological context.

---

## 14. Interpretation role

The tabular evidence in this folder supports the following thesis position:

```text
Wind speed in Nariño must be characterized physically and statistically
before being used as the basis for predictive modeling and energy estimation.
```

The tables provide evidence that the wind signal is:

- heterogeneous across zones,
- affected by variable-level availability differences,
- dependent on careful preprocessing,
- distributionally structured,
- and physically relevant for later WPD construction.

---

## 15. Final note

This folder preserves the Chapter 2 numerical evidence of the doctoral thesis.

Its role is to support the empirical, preprocessing, physical-characterization, and distributional-analysis foundations of the doctoral workflow.

Together with the Chapter 2 figures and the physical-characterization result folder, these tables provide the numerical basis for moving from observational meteorological records to predictive and energetic modeling.

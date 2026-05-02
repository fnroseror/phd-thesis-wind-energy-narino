# 01_physical_characterization

## Purpose

This folder contains the structured outputs associated with the physical–statistical characterization of wind speed behavior in Nariño.

It corresponds to the result layer of the physical characterization stage of the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

This folder supports the interpretation of wind behavior before predictive modeling. Its role is to preserve the numerical evidence used to describe the regional structure of wind speed and its distributional behavior across the analytical zones defined in the thesis.

---

## 1. Scientific role of this folder

The doctoral thesis treats wind not only as a numerical time series, but as a physical signal associated with atmospheric motion, regional variability, intermittency, and energetic potential.

For that reason, the first analytical stage of the thesis characterizes the observed wind-speed variable (**VV**) before constructing derived energetic variables such as **Wind Power Density (WPD)**.

This folder contains the main tabular outputs associated with that stage.

The results preserved here support the transition from:

```text
observed wind speed
→ statistical characterization
→ distributional interpretation
→ physical understanding of wind variability
→ predictive and energetic modeling
```

---

## 2. Current files in this folder

The current contents of this folder are:

| File | Type | Scientific role |
|---|---|---|
| `VV_Descriptivos_por_Zona.csv` | Descriptive statistics | Summarizes wind-speed behavior by zone using central tendency, dispersion, quantiles, skewness, and kurtosis. |
| `VV_Weibull_MLE_por_Zona.csv` | Weibull estimation | Stores Weibull parameters estimated by maximum likelihood for each zone. |
| `VV_Weibull_vs_Rayleigh_por_Zona.csv` | Distributional comparison | Compares Weibull and Rayleigh distributional performance by zone using information criteria, goodness-of-fit indicators, and energetic moments. |

These files provide the numerical support for the physical–statistical interpretation of the wind-speed signal.

---

## 3. File description

### `VV_Descriptivos_por_Zona.csv`

This file contains descriptive statistics of wind speed by analytical zone.

It includes:

- zone identifier,
- sample size,
- mean,
- standard deviation,
- minimum value,
- empirical percentiles,
- median,
- maximum value,
- skewness,
- and kurtosis.

Scientific interpretation:

This file allows the wind-speed signal to be evaluated in terms of magnitude, dispersion, asymmetry, extreme behavior, and distributional concentration.

The descriptive results are relevant because wind speed is the primary observed variable from which the energetic interpretation of the thesis is derived.

---

### `VV_Weibull_MLE_por_Zona.csv`

This file contains Weibull parameter estimation by zone using maximum likelihood estimation.

It includes:

- zone identifier,
- proportion of zero values,
- Weibull shape parameter `k`,
- Weibull scale parameter `c`,
- standard errors,
- information criteria,
- Kolmogorov–Smirnov statistic,
- associated p-value,
- and the third-order energetic moment.

Scientific interpretation:

The Weibull distribution is widely used in wind-energy studies because it provides a compact statistical representation of wind-speed regimes.

In the thesis, the Weibull parameters are used to interpret the distributional structure of wind speed by zone.

The shape parameter `k` provides information about the regularity and concentration of the wind regime, while the scale parameter `c` is associated with the characteristic magnitude of wind speed.

---

### `VV_Weibull_vs_Rayleigh_por_Zona.csv`

This file compares Weibull and Rayleigh distributional behavior by zone.

It includes:

- Weibull parameters,
- Rayleigh scale parameter,
- AIC and BIC for Weibull,
- AIC and BIC for Rayleigh,
- Kolmogorov–Smirnov statistics,
- associated p-values,
- and third-order energetic moments for both distributions.

Scientific interpretation:

This comparison is important because Rayleigh can be understood as a restricted distributional case, while Weibull offers greater flexibility through its shape parameter.

The comparison supports the decision to characterize the wind-speed regime using a distributional model that can better represent regional variability and asymmetry.

---

## 4. Physical interpretation

The outputs in this folder show that the wind-speed signal must be treated as a structured physical–statistical process rather than as a simple Gaussian variable.

The descriptive and distributional evidence supports the following interpretation:

- wind speed presents different statistical behavior by zone,
- the signal contains dispersion and asymmetry,
- regional regimes are not equivalent,
- distributional characterization is required before forecasting,
- and energetic interpretation must account for the nonlinear relationship between wind speed and power density.

This is especially important because Wind Power Density depends on the cube of wind speed:

```text
WPD = 0.5 · ρ · v³
```

Therefore, changes in the distributional behavior of wind speed may produce amplified changes in the energetic interpretation.

---

## 5. Thesis linkage

This folder is aligned with the physical characterization stage of the thesis and supports the results associated with Chapter 2.

It provides numerical evidence related to:

- descriptive statistics of wind speed by zone,
- Weibull parameter estimation,
- Weibull versus Rayleigh comparison,
- regional distributional behavior,
- and physical interpretation of wind variability before predictive modeling.

The outputs in this folder should be interpreted together with the corresponding figures and tables organized in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
```

---

## 6. Relationship with code

The files in this folder should be reproducible from the physical characterization and preprocessing workflow contained in:

```text
03_CODE/01_preprocessing/
03_CODE/02_physical_characterization/
```

The logical relationship is:

```text
metadata and observational records
→ preprocessing
→ zonal organization
→ descriptive statistics
→ distributional fitting
→ physical interpretation
→ thesis results
```

---

## 7. Relationship with the complete results folder

This folder is part of the broader result structure:

```text
04_RESULTS_COMPLETE/
├── 01_physical_characterization/
├── 02_model_comparison/
├── 03_pi90_uncertainty/
├── 04_fnrr_outputs/
├── 05_energy_projection/
├── 06_extended_results/
├── 07_FIGURES/
└── 08_TABLES/
```

Within this structure, `01_physical_characterization/` provides the first layer of evidence: the physical and distributional understanding of the wind-speed signal.

The later folders build upon this foundation by evaluating predictive performance, uncertainty, FNRR, and energy projection.

---

## 8. Methodological caution

This folder currently documents the tabular outputs associated with descriptive and distributional wind-speed characterization.

Temporal-dependence analyses such as ACF and PACF, spectral analyses such as FFT, and time–frequency analyses such as Wavelet decomposition should be verified in the corresponding figure, table, code, or extended-result folders when available.

This distinction is important to avoid overstating the contents of this specific folder.

The present folder should therefore be interpreted as the tabular physical-characterization support for wind-speed distributional analysis by zone.

---

## 9. Interpretation role

The outputs in this folder define the physical basis of the forecasting problem.

They support the interpretation that wind behavior in Nariño is:

- regionally heterogeneous,
- statistically asymmetric,
- distributionally structured,
- physically relevant for energetic modeling,
- and necessary to characterize before applying forecasting models.

This result layer is not auxiliary. It is the structural foundation that justifies the predictive and energetic stages of the doctoral workflow.

---

## 10. Final note

This folder preserves the numerical evidence required to support the physical–statistical characterization of wind speed in the thesis.

Its main function is to connect the observed meteorological system with the distributional and energetic reasoning that supports the later construction of WPD, uncertainty analysis, FNRR interpretation, and regional energy projection.

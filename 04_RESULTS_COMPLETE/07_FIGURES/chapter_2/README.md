# Chapter 2 Figures — Physical Characterization

## Purpose

This folder contains the visual evidence associated with Chapter 2 of the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The figures in this folder support the physical and statistical characterization of wind speed in Nariño before the predictive modeling stage.

This folder is part of:

```text
04_RESULTS_COMPLETE/07_FIGURES/
```

and should be interpreted as the graphical evidence layer for the physical characterization stage of the thesis.

---

## 1. Scientific role of these figures

Chapter 2 establishes the physical basis of the forecasting problem.

The figures contained in this folder provide visual support for the interpretation of wind speed as a structured physical–statistical signal characterized by:

- regional variability,
- distributional asymmetry,
- temporal dependence,
- spectral structure,
- multiscale behavior,
- and energetic relevance.

This visual layer supports the transition from:

```text
observed wind speed
→ physical characterization
→ distributional analysis
→ temporal and spectral interpretation
→ basis for predictive modeling
```

---

## 2. Current figures in this folder

The current contents of this folder are:

| File | Figure type | Scientific role |
|---|---|---|
| `ACF_ZonaRepresentativa_Z1.png` | Autocorrelation function | Evaluates temporal persistence in a representative wind-speed series. |
| `PACF_ZonaRepresentativa_Z1.png` | Partial autocorrelation function | Supports the interpretation of direct temporal dependence structure. |
| `FFT_ZonaRepresentativa_Z1.png` | Frequency-domain analysis | Identifies dominant spectral components in the wind-speed signal. |
| `Wavelet_ZonaRepresentativa_Z1.png` | Time-frequency analysis | Represents the multiscale temporal evolution of spectral energy. |
| `Wavelet_ZonaRepresentativa_Z1_Basic.png` | Basic wavelet representation | Provides an additional simplified time-frequency visualization. |
| `CDF_Weibull_vs_Rayleigh_ZonaRep_Z1.png` | Cumulative distribution comparison | Compares Weibull and Rayleigh cumulative behavior for a representative zone. |
| `PDF_Weibull_vs_Rayleigh_ZonaRep_Z1.png` | Probability density comparison | Compares Weibull and Rayleigh density behavior for a representative zone. |
| `VV_Boxplot_por_Zona.png` | Zonal boxplot | Compares wind-speed dispersion, central tendency, and outlier behavior by zone. |
| `Weibull_k_por_Zona.png` | Weibull shape parameter | Visualizes the Weibull shape parameter `k` by zone. |
| `Weibull_c_por_Zona.png` | Weibull scale parameter | Visualizes the Weibull scale parameter `c` by zone. |
| `Weibull_k_c_por_Zona.png` | Weibull parameter relationship | Presents the joint interpretation of Weibull parameters `k` and `c` by zone. |

---

## 3. Temporal-dependence figures

### `ACF_ZonaRepresentativa_Z1.png`

This figure represents the autocorrelation structure of the wind-speed signal for a representative zone.

Scientific interpretation:

The ACF allows the thesis to evaluate whether the wind-speed signal contains temporal persistence. This is important because persistence affects both physical interpretation and forecasting difficulty.

A wind-speed signal with temporal dependence cannot be treated as a sequence of independent observations.

---

### `PACF_ZonaRepresentativa_Z1.png`

This figure represents the partial autocorrelation structure of the wind-speed signal.

Scientific interpretation:

The PACF helps identify direct lag relationships after controlling for intermediate lags. It supports the interpretation of short-range temporal structure and informs the need for time-series models or sequential architectures.

Together, ACF and PACF provide evidence that the wind signal has temporal organization.

---

## 4. Spectral and multiscale figures

### `FFT_ZonaRepresentativa_Z1.png`

This figure represents the frequency-domain behavior of the wind-speed signal using Fourier analysis.

Scientific interpretation:

The FFT allows the thesis to identify dominant periodicities or spectral components in the wind-speed signal.

This supports the interpretation of wind as a physical signal with frequency structure rather than as purely random noise.

---

### `Wavelet_ZonaRepresentativa_Z1.png`

This figure represents the time-frequency structure of the wind-speed signal.

Scientific interpretation:

Wavelet analysis allows the thesis to evaluate how spectral behavior changes over time.

This is important because atmospheric systems are generally nonstationary. A frequency component may not remain constant across the entire observational period.

---

### `Wavelet_ZonaRepresentativa_Z1_Basic.png`

This figure provides an additional basic wavelet representation.

Scientific interpretation:

It supports the same multiscale interpretation as the main wavelet figure, but in a simplified visual form.

Its role is complementary and should be interpreted as supporting evidence for the time-frequency behavior of the wind-speed signal.

---

## 5. Distributional-comparison figures

### `PDF_Weibull_vs_Rayleigh_ZonaRep_Z1.png`

This figure compares the probability density behavior of Weibull and Rayleigh distributions for a representative zone.

Scientific interpretation:

The PDF comparison helps evaluate how well each distribution represents the observed wind-speed density.

This is relevant because Weibull is commonly used in wind-energy studies due to its flexibility, while Rayleigh can be interpreted as a more restricted case.

---

### `CDF_Weibull_vs_Rayleigh_ZonaRep_Z1.png`

This figure compares the cumulative distribution behavior of Weibull and Rayleigh distributions for a representative zone.

Scientific interpretation:

The CDF comparison supports the evaluation of distributional fit across the accumulated probability structure of the wind-speed signal.

Together, PDF and CDF comparisons provide visual evidence for the distributional modeling decision.

---

## 6. Zonal comparison figures

### `VV_Boxplot_por_Zona.png`

This figure compares wind-speed behavior across the analytical zones.

Scientific interpretation:

The boxplot provides visual evidence of differences in central tendency, dispersion, asymmetry, and extreme values across zones.

This supports the thesis decision to interpret Nariño through zonal atmospheric regimes rather than as a single homogeneous wind system.

---

## 7. Weibull parameter figures

### `Weibull_k_por_Zona.png`

This figure presents the Weibull shape parameter `k` by zone.

Scientific interpretation:

The parameter `k` is associated with the shape, regularity, and concentration of the wind-speed distribution.

Differences in `k` between zones support the interpretation of regional distributional heterogeneity.

---

### `Weibull_c_por_Zona.png`

This figure presents the Weibull scale parameter `c` by zone.

Scientific interpretation:

The parameter `c` is associated with the characteristic wind-speed magnitude of the distribution.

Differences in `c` between zones help interpret regional differences in wind-speed intensity.

---

### `Weibull_k_c_por_Zona.png`

This figure jointly represents Weibull parameters `k` and `c`.

Scientific interpretation:

The joint interpretation of `k` and `c` supports a more complete distributional reading of wind behavior, combining information about regularity and magnitude.

This figure helps compare zones not only by average wind speed, but by distributional structure.

---

## 8. Relationship with physical characterization results

These figures should be interpreted together with the tabular outputs contained in:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
```

especially:

```text
VV_Descriptivos_por_Zona.csv
VV_Weibull_MLE_por_Zona.csv
VV_Weibull_vs_Rayleigh_por_Zona.csv
```

The figures provide visual interpretation, while the CSV files provide numerical support.

---

## 9. Relationship with tables

These figures should also be interpreted together with the tables contained in:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
```

The combined reading of figures and tables supports the Chapter 2 evidence structure.

---

## 10. Relationship with code

These figures should be reproducible from the physical characterization workflow contained in:

```text
03_CODE/01_preprocessing/
03_CODE/02_physical_characterization/
```

The logical relationship is:

```text
observational data
→ preprocessing
→ zonal organization
→ wind-speed characterization
→ distributional fitting
→ temporal analysis
→ spectral analysis
→ chapter 2 figures
```

---

## 11. Methodological caution

The figures in this folder should not be interpreted independently from the thesis text, tables, or computational workflow.

Each figure must be read according to:

- the variable analyzed,
- the zone represented,
- the method used,
- the corresponding numerical support,
- and the physical interpretation developed in Chapter 2.

This prevents visual evidence from being overinterpreted without statistical or methodological support.

---

## 12. Interpretation role

The visual evidence in this folder supports the following thesis position:

```text
Wind speed in Nariño behaves as a structured physical–statistical signal,
with regional, temporal, spectral, and distributional characteristics
that must be understood before predictive modeling.
```

This folder therefore provides the graphical foundation for the predictive and energetic stages of the doctoral workflow.

---

## 13. Final note

This folder preserves the Chapter 2 visual evidence of the doctoral thesis.

Its role is to support the physical characterization of wind speed and to connect the observed atmospheric system with the later construction of Wind Power Density, predictive modeling, uncertainty analysis, FNRR interpretation, and energy projection.

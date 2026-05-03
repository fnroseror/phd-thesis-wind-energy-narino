# Appendix D — Extended Results for Chapter 2

## Purpose

This appendix documents the extended results associated with Chapter 2 of the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

Its purpose is to provide technical support for the physical and statistical characterization of wind behavior in Nariño before predictive modeling, uncertainty quantification, FNRR computation, and energy projection.

This appendix complements the Chapter 2 result materials contained in:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
```

---

## D.1 Role of Chapter 2 in the thesis

Chapter 2 establishes the physical and statistical basis of the doctoral work.

Before applying forecasting models, the thesis first characterizes the wind-speed signal in order to understand its:

- magnitude,
- dispersion,
- distributional structure,
- regional heterogeneity,
- temporal dependence,
- spectral content,
- and multiscale behavior.

The general logic of Chapter 2 is:

```text
observational data
→ preprocessing
→ zonal organization
→ physical characterization
→ distributional fitting
→ temporal analysis
→ spectral analysis
→ basis for predictive modeling
```

This stage is essential because the thesis does not treat wind speed as an abstract numerical variable. It is interpreted as a physical signal associated with atmospheric motion and regional energy potential.

---

## D.2 Central variable of Chapter 2

The central observed variable analyzed in Chapter 2 is:

```text
VV — wind speed
```

Wind speed is the primary observed atmospheric variable from which the energetic interpretation of the thesis is later constructed.

The central derived energetic variable of the thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

Because WPD depends cubically on wind speed, the physical and statistical characterization of `VV` is not optional. It is necessary to understand how variability in wind speed may propagate into energetic interpretation.

---

## D.3 Data traceability outputs

The extended results of Chapter 2 include traceability tables that document the observational basis before physical characterization.

These outputs are located in:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
```

Relevant files include:

```text
A1_Conteo_Registros_por_Variable.csv
A2_QC_NA_y_Negativos_por_Variable.csv
A3_Resolucion_Temporal_por_Zona_Estacion.csv
CFG_Cap2_parametros_usados.csv
VV_Log_Parametros_Procesamiento.csv
VV_Trazabilidad_Limpieza.csv
VV_Tabla_Maestra_Zonas.csv
```

These tables support the methodological transparency of the thesis by documenting:

- record availability by variable,
- missing-value diagnostics,
- negative-value diagnostics,
- temporal-resolution structure,
- processing parameters,
- cleaning traceability,
- and zonal organization.

This evidence is important because the reliability of the physical characterization depends on the integrity of the observational basis.

---

## D.4 Descriptive statistics by zone

The descriptive statistics of wind speed by zone are stored in:

```text
04_RESULTS_COMPLETE/01_physical_characterization/VV_Descriptivos_por_Zona.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_2/VV_Descriptivos_por_Zona.csv
```

This table provides numerical support for the first quantitative characterization of wind speed.

It includes indicators such as:

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

These indicators allow the wind-speed signal to be evaluated in terms of magnitude, variability, asymmetry, and concentration.

The descriptive results support the interpretation that wind behavior in Nariño must be analyzed by zone rather than as a single homogeneous regional signal.

---

## D.5 Zonal variability and signal structure

The signal-variance output is located in:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_2/VV_Varianza_SenalZonal_por_Zona.csv
```

This table supports the interpretation of variability by analytical zone.

Scientific interpretation:

Zonal variance is important because wind-energy prediction is affected by the stability or instability of the signal.

A zone with higher variability may present:

- stronger intermittency,
- larger prediction difficulty,
- higher uncertainty,
- and stronger energetic fluctuation.

In the thesis, variability is not interpreted only as a statistical property. It is part of the physical behavior of the regional atmospheric system.

---

## D.6 Weibull parameter estimation

The Weibull parameter estimation output is stored in:

```text
04_RESULTS_COMPLETE/01_physical_characterization/VV_Weibull_MLE_por_Zona.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_2/VV_Weibull_MLE_por_Zona.csv
```

This file contains Weibull maximum-likelihood estimation by zone.

The main parameters are:

| Parameter | Meaning |
|---|---|
| `k` | Weibull shape parameter |
| `c` | Weibull scale parameter |

Scientific interpretation:

The Weibull distribution is relevant in wind-energy analysis because it provides a flexible representation of wind-speed behavior.

The shape parameter `k` supports interpretation of the regularity, concentration, and distributional form of the wind regime.

The scale parameter `c` supports interpretation of the characteristic magnitude of wind speed.

Together, `k` and `c` help describe the regional structure of the wind-speed distribution.

---

## D.7 Weibull versus Rayleigh comparison

The Weibull–Rayleigh comparison output is stored in:

```text
04_RESULTS_COMPLETE/01_physical_characterization/VV_Weibull_vs_Rayleigh_por_Zona.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_2/VV_Weibull_vs_Rayleigh_por_Zona.csv
```

This table compares the behavior of Weibull and Rayleigh distributions by zone.

Scientific interpretation:

Rayleigh can be interpreted as a restricted distributional case, while Weibull provides greater flexibility through its shape parameter.

The comparison is important because the wind-speed signal may present asymmetry, dispersion, and regional heterogeneity that require a more flexible model.

This extended result supports the decision to use distributional characterization as part of the physical interpretation of wind behavior.

---

## D.8 Distributional figures

The distributional visual evidence is located in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
```

Relevant files include:

```text
PDF_Weibull_vs_Rayleigh_ZonaRep_Z1.png
CDF_Weibull_vs_Rayleigh_ZonaRep_Z1.png
Weibull_k_por_Zona.png
Weibull_c_por_Zona.png
Weibull_k_c_por_Zona.png
```

Scientific interpretation:

These figures provide visual support for the distributional analysis of wind speed.

They allow reviewers to inspect:

- density behavior,
- cumulative probability behavior,
- zonal differences in Weibull parameters,
- relationship between `k` and `c`,
- and the distributional distinction between Weibull and Rayleigh.

The distributional evidence is central because the wind-energy potential depends on the structure of the wind-speed distribution, not only on its average value.

---

## D.9 Zonal comparison figure

The zonal boxplot figure is located in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/VV_Boxplot_por_Zona.png
```

Scientific interpretation:

This figure provides visual evidence of differences in wind-speed behavior across zones.

It supports the interpretation of:

- central tendency,
- dispersion,
- outlier behavior,
- asymmetry,
- and regional heterogeneity.

The boxplot supports the thesis decision to analyze Nariño through analytical zones rather than as a single homogeneous atmospheric domain.

---

## D.10 Temporal dependence: ACF and PACF

Temporal-dependence figures are located in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/ACF_ZonaRepresentativa_Z1.png
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/PACF_ZonaRepresentativa_Z1.png
```

### ACF interpretation

The autocorrelation function supports the evaluation of temporal persistence in the wind-speed signal.

Scientific interpretation:

If the signal presents autocorrelation, then observations cannot be interpreted as completely independent.

This has direct consequences for forecasting because temporal structure may provide predictive information.

### PACF interpretation

The partial autocorrelation function supports the evaluation of direct lag relationships after controlling for intermediate lags.

Scientific interpretation:

PACF helps identify short-range temporal structure and supports the need for time-series or sequential modeling approaches.

Together, ACF and PACF support the interpretation that wind speed behaves as a temporally structured signal.

---

## D.11 Spectral analysis: FFT

The spectral figure is located in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/FFT_ZonaRepresentativa_Z1.png
```

Scientific interpretation:

The FFT analysis allows the wind-speed signal to be interpreted in the frequency domain.

This is important because physical signals often contain periodic or quasi-periodic components that are not fully visible in the time domain.

In the thesis, FFT supports the interpretation of wind as a signal with spectral structure rather than as pure random noise.

The spectral analysis contributes to the physical understanding of the atmospheric system and supports the later predictive modeling stage.

---

## D.12 Time–frequency analysis: Wavelet

Wavelet figures are located in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/Wavelet_ZonaRepresentativa_Z1.png
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/Wavelet_ZonaRepresentativa_Z1_Basic.png
```

Scientific interpretation:

Wavelet analysis allows the thesis to evaluate how frequency behavior changes over time.

This is important because atmospheric systems are generally nonstationary.

A frequency component may appear, intensify, weaken, or disappear over different temporal periods.

The wavelet evidence supports the interpretation of the wind-speed signal as a multiscale and time-varying physical process.

---

## D.13 Physical interpretation of Chapter 2 extended results

The extended results of Chapter 2 support the following interpretation:

```text
Wind speed in Nariño behaves as a structured physical–statistical signal.
```

This structure appears through:

- regional differences between zones,
- descriptive variability,
- asymmetry and distributional behavior,
- Weibull parameter differences,
- temporal persistence,
- spectral components,
- and multiscale behavior.

Therefore, the wind signal should not be treated as a simple independent Gaussian sequence.

It should be characterized physically and statistically before being used in predictive modeling.

---

## D.14 Relationship with preprocessing

The results documented in this appendix depend on preprocessing and traceability.

Relevant documentation is contained in:

```text
02_DATA_METADATA/04_data_processing_notes.md
05_APPENDICES_SUPPORT/Anexo_B_Preprocesamiento_y_Trazabilidad.md
```

Relevant preprocessing and traceability tables are contained in:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
```

The logical relationship is:

```text
preprocessing
→ cleaning traceability
→ zonal organization
→ wind-speed characterization
→ Chapter 2 extended results
```

---

## D.15 Relationship with code

The Chapter 2 extended results should be reproducible from the code contained in:

```text
03_CODE/01_preprocessing/
03_CODE/02_physical_characterization/
```

The computational relationship is:

```text
observational records
→ preprocessing scripts
→ physical-characterization scripts
→ CSV outputs
→ figures
→ tables
→ thesis interpretation
```

This traceability is essential for repository review.

---

## D.16 Relationship with Chapter 3

Chapter 2 results provide the physical basis for Chapter 3 predictive modeling.

The transition is:

```text
physical characterization
→ forecasting problem definition
→ model selection
→ deterministic evaluation
→ uncertainty assessment
```

The distributional, temporal, and spectral evidence from Chapter 2 helps justify why predictive modeling is necessary and why model behavior should be interpreted under zonal and temporal structure.

---

## D.17 Relationship with Chapter 4

Chapter 2 also supports Chapter 4 because Wind Power Density and energy projection depend on the behavior of wind speed.

The transition is:

```text
wind-speed characterization
→ WPD construction
→ uncertainty-aware prediction
→ FNRR interpretation
→ energy projection
```

The physical characterization of wind speed is therefore the first layer of evidence supporting the final energetic interpretation of the thesis.

---

## D.18 Repository locations associated with Chapter 2

The main repository locations associated with Chapter 2 are:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
03_CODE/01_preprocessing/
03_CODE/02_physical_characterization/
02_DATA_METADATA/
```

Each location has a specific role:

| Repository location | Role |
|---|---|
| `02_DATA_METADATA/` | Defines dataset, variables, stations, zones, processing notes, and availability. |
| `03_CODE/01_preprocessing/` | Contains preprocessing logic. |
| `03_CODE/02_physical_characterization/` | Contains physical-characterization logic. |
| `04_RESULTS_COMPLETE/01_physical_characterization/` | Stores core Chapter 2 characterization outputs. |
| `04_RESULTS_COMPLETE/07_FIGURES/chapter_2/` | Stores visual Chapter 2 evidence. |
| `04_RESULTS_COMPLETE/08_TABLES/chapter_2/` | Stores numerical Chapter 2 evidence. |

---

## D.19 Methodological caution

The figures and tables associated with Chapter 2 should not be interpreted in isolation.

They must be read according to:

- the variable analyzed,
- the zone represented,
- the preprocessing criteria,
- the statistical method applied,
- the physical interpretation of the wind signal,
- and the role of Chapter 2 in the full doctoral workflow.

This prevents overinterpretation of isolated numerical or graphical outputs.

---

## D.20 What this appendix does not claim

This appendix does not claim that the wind system is fully deterministic.

It does not claim that all zones behave identically.

It does not claim that one distributional model explains all atmospheric behavior perfectly.

It does not claim that spectral or wavelet analysis eliminates uncertainty.

Instead, it documents extended evidence showing that the wind-speed signal has enough physical, statistical, temporal, and spectral structure to justify a rigorous predictive and energetic modeling framework.

---

## D.21 Closure criterion

The extended results of Chapter 2 are considered sufficiently documented when:

1. preprocessing and traceability outputs are identified,
2. descriptive statistics are documented,
3. zonal variability is interpreted,
4. Weibull parameters are connected to wind-regime structure,
5. Weibull and Rayleigh comparison is documented,
6. ACF and PACF are interpreted as temporal-dependence evidence,
7. FFT is interpreted as spectral evidence,
8. Wavelet is interpreted as time-frequency evidence,
9. figures are connected to tables,
10. tables are connected to code,
11. and Chapter 2 is clearly linked to Chapters 3 and 4.

---

## D.22 Final statement

The extended results of Chapter 2 provide the physical and statistical foundation of the doctoral thesis.

Their central message is:

```text
Before forecasting wind-energy potential, the wind-speed signal must be
physically characterized, statistically described, distributionally evaluated,
temporally examined, and spectrally interpreted.
```

For that reason, Appendix D supports the scientific transition from observational meteorological data to predictive modeling and regional energy interpretation.

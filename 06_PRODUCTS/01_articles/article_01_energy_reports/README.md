# Article 01 — Concept Note

## Tentative title

**Physical–statistical characterization of wind power density in Nariño, Colombia, using multi-station meteorological records**

---

## Current status

```text
Status: Concept note
Maturity level: Pre-manuscript
Repository role: Publication planning and scientific traceability
```

This file does not represent a submitted, accepted, or published manuscript.

It defines the scientific scope, evidence base, methodological orientation, and development path for the first derivative article projected from the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

---

## 1. Article role within the publication portfolio

This article is intended to be the first scientific publication derived from the doctoral thesis.

Its role is to present the physical and statistical characterization of the wind-energy system in Nariño, Colombia, before predictive modeling, uncertainty quantification, FNRR computation, and energy projection.

The article corresponds mainly to the scientific foundation developed in Chapter 2 of the thesis.

The publication sequence is:

```text
Article 01
Physical–statistical characterization of wind and WPD

Article 02
Predictive modeling and model comparison

Article 03
FNRR, uncertainty, free energy, and usable energy
```

Article 01 should establish the physical basis required for the later predictive and energetic articles.

---

## 2. Scientific problem

Wind-resource assessment is frequently reduced to the description of wind speed alone.

However, wind speed by itself does not fully represent the energetic behavior of the atmospheric system.

From a physical perspective, the energetic relevance of wind is better represented through **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

Because WPD depends cubically on wind speed, small variations in wind behavior may produce amplified energetic consequences.

In a region such as Nariño, Colombia, where atmospheric behavior may vary across zones, a physical–statistical characterization is required before any predictive or energy-projection stage.

The scientific problem can be stated as follows:

```text
How can the wind-energy behavior of Nariño be physically and statistically characterized using multi-station meteorological records, and why is WPD a more informative energetic variable than wind speed alone?
```

---

## 3. Main objective

To develop a physical–statistical characterization of wind-energy behavior in Nariño, Colombia, using multi-station meteorological records, with emphasis on wind speed, Wind Power Density, zonal variability, distributional structure, temporal dependence, and spectral behavior.

---

## 4. Specific objectives

1. To describe the observational meteorological database used for wind-energy characterization in Nariño.

2. To document the station network and zonal structure used in the analysis.

3. To characterize wind-speed behavior using descriptive statistics by zone.

4. To estimate and interpret Weibull parameters for zonal wind-speed regimes.

5. To compare Weibull and Rayleigh distributional behavior.

6. To examine temporal dependence through ACF and PACF.

7. To analyze spectral and time–frequency behavior through FFT and Wavelet evidence.

8. To justify the transition from wind-speed characterization to WPD-based energetic interpretation.

---

## 5. Expected contribution

This article is expected to contribute:

- a regional physical–statistical characterization of wind behavior in Nariño;
- a structured description of the multi-station meteorological basis used in the thesis;
- evidence supporting the interpretation of wind speed as a physical signal with zonal, temporal, distributional, and spectral structure;
- a physically grounded argument for using WPD as a central energetic variable;
- numerical and visual support for Weibull-based wind-speed characterization;
- and a scientific foundation for later predictive modeling and energy-projection studies.

The article should not claim that Nariño is fully characterized by a single distribution, model, or zone.

Its contribution is to establish a rigorous physical–statistical entry point for regional wind-energy analysis.

---

## 6. Proposed article type

```text
Original research article
```

Possible journal areas:

- renewable energy,
- wind-energy assessment,
- applied physics,
- environmental modeling,
- atmospheric data analysis,
- physical–statistical modeling.

This concept note does not define a final target journal.

Target-journal selection should be performed after the manuscript scope, length, results, figures, and novelty statement are fully consolidated.

---

## 7. Proposed abstract draft

Wind-energy assessment requires more than the description of wind speed, especially in regions with heterogeneous atmospheric and territorial conditions. This study presents a physical–statistical characterization of wind-energy behavior in Nariño, Colombia, using multi-station meteorological records organized into analytical zones. The analysis focuses on wind speed as the primary observed variable and Wind Power Density as the central derived energetic quantity. Descriptive statistics, Weibull parameter estimation, Weibull–Rayleigh comparison, autocorrelation analysis, partial autocorrelation analysis, Fourier-based spectral analysis, and Wavelet-based time–frequency interpretation are used to characterize the structure of the wind signal. The results provide evidence that wind behavior in Nariño should be interpreted as a regional physical–statistical process rather than as a homogeneous random sequence. The study establishes the empirical and physical basis for subsequent predictive modeling, uncertainty quantification, and regional energy-potential projection.

---

## 8. Keywords

Suggested keywords:

```text
Wind Power Density
Wind speed characterization
Weibull distribution
Wind-energy assessment
Physical–statistical modeling
Meteorological records
Nariño
Renewable energy
Spectral analysis
Wavelet analysis
```

---

## 9. Study area and data basis

The article is based on the doctoral dataset associated with Nariño, Colombia.

The observational basis includes:

- multi-station meteorological records,
- 16 IDEAM meteorological stations,
- four analytical zones,
- hourly records from 2017–2022,
- wind speed as the central observed variable,
- and supporting atmospheric variables such as pressure and temperature.

The database and zonal structure are documented in:

```text
02_DATA_METADATA/
05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
```

The article should describe the study area and data basis without overclaiming geographic or climatological classification beyond what is documented in the repository.

The zonal structure should be described as an analytical and methodological structure used in the thesis, not as an official territorial classification.

---

## 10. Central physical variable

The central energetic variable is **Wind Power Density**:

```text
WPD = 0.5 · ρ · v³
```

This expression derives from the kinetic energy flux of moving air.

The physical relevance of WPD is that it transforms wind speed into an energetic quantity.

Because of the cubic dependence on wind speed, WPD is highly sensitive to wind variability.

This physical relationship justifies why wind-energy characterization should not be limited to average wind speed alone.

---

## 11. Proposed methodological structure

The methodology of the article should follow this structure:

```text
1. Study area and observational database
2. Station network and zonal organization
3. Data preprocessing and traceability
4. Wind-speed descriptive characterization
5. Weibull parameter estimation
6. Weibull versus Rayleigh comparison
7. Temporal-dependence analysis through ACF and PACF
8. Frequency-domain analysis through FFT
9. Time–frequency analysis through Wavelet transform
10. Physical interpretation and transition toward WPD-based modeling
```

This structure aligns with the thesis and the repository evidence.

---

## 12. Data preprocessing and traceability

The article should briefly describe preprocessing as a physically informed preparation stage.

The preprocessing discussion should include:

- quality-control diagnosis,
- treatment of non-physical negative values,
- missing-value and zero-value interpretation,
- temporal-resolution verification,
- unit harmonization for physical calculations,
- and station-to-zone organization.

The detailed support is located in:

```text
02_DATA_METADATA/04_data_processing_notes.md
05_APPENDICES_SUPPORT/Anexo_B_Preprocesamiento_y_Trazabilidad.md
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
```

The article should not overload the methods section with every preprocessing detail. Instead, it should summarize the logic and refer to supplementary/repository material.

---

## 13. Descriptive analysis

The descriptive analysis should characterize wind speed by zone.

Relevant indicators include:

- sample size,
- mean,
- standard deviation,
- minimum,
- percentiles,
- median,
- maximum,
- skewness,
- and kurtosis.

Main supporting files:

```text
04_RESULTS_COMPLETE/01_physical_characterization/VV_Descriptivos_por_Zona.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_2/VV_Descriptivos_por_Zona.csv
```

Scientific interpretation:

The descriptive analysis should show that wind behavior differs across zones and that the signal must be interpreted through regional heterogeneity.

---

## 14. Distributional analysis

The article should include Weibull parameter estimation and Weibull–Rayleigh comparison.

Main supporting files:

```text
04_RESULTS_COMPLETE/01_physical_characterization/VV_Weibull_MLE_por_Zona.csv
04_RESULTS_COMPLETE/01_physical_characterization/VV_Weibull_vs_Rayleigh_por_Zona.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_2/VV_Weibull_MLE_por_Zona.csv
04_RESULTS_COMPLETE/08_TABLES/chapter_2/VV_Weibull_vs_Rayleigh_por_Zona.csv
```

Relevant figures:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/PDF_Weibull_vs_Rayleigh_ZonaRep_Z1.png
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/CDF_Weibull_vs_Rayleigh_ZonaRep_Z1.png
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/Weibull_k_por_Zona.png
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/Weibull_c_por_Zona.png
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/Weibull_k_c_por_Zona.png
```

Scientific interpretation:

Weibull analysis should be framed as a distributional characterization tool for wind-speed regimes.

Rayleigh comparison should be presented as a restricted reference case.

The article should avoid claiming that Weibull perfectly explains all wind behavior. It should state that Weibull provides a useful and physically interpretable distributional framework.

---

## 15. Temporal-dependence analysis

Temporal dependence should be supported by ACF and PACF evidence.

Relevant figures:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/ACF_ZonaRepresentativa_Z1.png
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/PACF_ZonaRepresentativa_Z1.png
```

Scientific interpretation:

The ACF and PACF support the idea that wind-speed observations are not necessarily independent.

This is important because temporal dependence justifies the later use of time-series and sequential predictive models.

---

## 16. Spectral and time–frequency analysis

The article should include evidence from FFT and Wavelet analysis.

Relevant figures:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/FFT_ZonaRepresentativa_Z1.png
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/Wavelet_ZonaRepresentativa_Z1.png
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/Wavelet_ZonaRepresentativa_Z1_Basic.png
```

Scientific interpretation:

FFT supports frequency-domain interpretation.

Wavelet analysis supports time–frequency interpretation.

Together, these methods help interpret wind speed as a multiscale physical signal rather than as pure random noise.

The article should present this as evidence of physical signal structure, not as a complete deterministic explanation of atmospheric behavior.

---

## 17. Suggested figures for the article

A preliminary figure set could include:

| Figure | Source | Purpose |
|---|---|---|
| Study workflow diagram | To be created | Shows data → preprocessing → characterization → WPD interpretation. |
| Zonal wind-speed boxplot | `VV_Boxplot_por_Zona.png` | Shows zonal variability. |
| Weibull parameters by zone | `Weibull_k_c_por_Zona.png` | Shows distributional structure. |
| Weibull vs Rayleigh PDF/CDF | Chapter 2 figures | Shows distributional comparison. |
| ACF/PACF figure | Chapter 2 figures | Shows temporal dependence. |
| FFT/Wavelet figure | Chapter 2 figures | Shows spectral and multiscale behavior. |

The final article should use a controlled number of figures to avoid visual overload.

---

## 18. Suggested tables for the article

A preliminary table set could include:

| Table | Source | Purpose |
|---|---|---|
| Station and zonal structure | Appendix A / metadata | Describes observational basis. |
| Record availability by variable | `A1_Conteo_Registros_por_Variable.csv` | Documents data heterogeneity. |
| Descriptive statistics by zone | `VV_Descriptivos_por_Zona.csv` | Supports zonal characterization. |
| Weibull parameters by zone | `VV_Weibull_MLE_por_Zona.csv` | Supports distributional analysis. |
| Weibull vs Rayleigh comparison | `VV_Weibull_vs_Rayleigh_por_Zona.csv` | Supports model comparison. |

The article should include only the tables required for a clear scientific narrative.

Additional tables may be referenced as supplementary material.

---

## 19. Expected results narrative

The results section should be organized around four interpretive blocks:

### 19.1 Observational and zonal structure

This block should describe the dataset, stations, variables, and four analytical zones.

Purpose:

```text
establish empirical and spatial traceability
```

### 19.2 Descriptive and zonal behavior

This block should describe wind-speed magnitude, dispersion, asymmetry, and variability by zone.

Purpose:

```text
demonstrate regional heterogeneity
```

### 19.3 Distributional behavior

This block should discuss Weibull parameters and Weibull–Rayleigh comparison.

Purpose:

```text
show distributional structure of wind-speed regimes
```

### 19.4 Temporal and spectral structure

This block should interpret ACF, PACF, FFT, and Wavelet evidence.

Purpose:

```text
show temporal persistence, spectral components, and multiscale behavior
```

The discussion should then connect these results to WPD and later predictive modeling.

---

## 20. Discussion focus

The discussion should emphasize:

- why WPD is physically more informative than wind speed alone;
- how zonal behavior affects regional wind-energy interpretation;
- why distributional characterization matters for energy assessment;
- why temporal and spectral structure justify predictive modeling;
- how the article prepares the scientific basis for uncertainty-aware forecasting;
- and how this characterization supports future regional renewable-energy planning.

The discussion should avoid speculative claims not directly supported by the thesis outputs.

---

## 21. Main novelty statement

A possible novelty statement is:

```text
This study provides a physical–statistical characterization of wind-energy behavior in Nariño, Colombia, integrating multi-station meteorological records, zonal organization, Weibull-based distributional analysis, temporal and spectral characterization, and Wind Power Density as the central energetic variable.
```

A stronger version for the manuscript introduction:

```text
The novelty of this study lies in moving from a wind-speed-centered description toward a WPD-centered physical–statistical characterization of regional wind-energy behavior, supported by zonal analysis, distributional fitting, temporal dependence, and spectral evidence.
```

---

## 22. Repository evidence supporting the article

Primary support:

```text
02_DATA_METADATA/
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
05_APPENDICES_SUPPORT/Anexo_B_Preprocesamiento_y_Trazabilidad.md
05_APPENDICES_SUPPORT/Anexo_D_Resultados_Extendidos_Cap2.md
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

Secondary support:

```text
03_CODE/01_preprocessing/
03_CODE/02_physical_characterization/
07_REPRODUCIBILITY/
```

---

## 23. Relationship with later articles

This article supports Article 02 because predictive modeling requires prior physical characterization.

The relationship is:

```text
Article 01
defines the physical and statistical structure of the wind-energy signal

Article 02
uses that structure to justify predictive modeling and model comparison

Article 03
uses prediction and uncertainty to formalize FNRR and usable energy
```

Therefore, Article 01 should be written as the empirical and physical foundation of the publication sequence.

---

## 24. Possible manuscript structure

A recommended manuscript structure is:

```text
1. Introduction
2. Study area and meteorological database
3. Physical formulation of Wind Power Density
4. Preprocessing and zonal organization
5. Physical–statistical characterization methods
   5.1 Descriptive statistics
   5.2 Weibull and Rayleigh distributions
   5.3 ACF and PACF
   5.4 FFT spectral analysis
   5.5 Wavelet time–frequency analysis
6. Results
7. Discussion
8. Limitations
9. Conclusions
10. Data and code availability
11. References
```

---

## 25. Limitations to declare

The article should declare limitations honestly.

Possible limitations include:

- heterogeneous availability of meteorological variables;
- unequal number of stations per zone;
- potential differences in station instrumentation and operational continuity;
- dependence on preprocessing and unit harmonization;
- use of analytical zones as methodological units rather than official climatic regions;
- and limited generalization beyond the documented dataset without further validation.

These limitations strengthen the article because they show methodological caution.

---

## 26. Ethical and authorship note

This concept note does not define final authorship.

Authorship should be determined according to actual scientific contribution, thesis supervision, data work, methodological support, writing, review, and institutional guidelines.

The article should clearly distinguish between:

- thesis-validated results,
- additional article-specific analysis,
- future work,
- and broader interpretations.

---

## 27. Development tasks

Next tasks for converting this concept note into a manuscript:

1. Select the final target journal category.
2. Define final article length and figure/table limits.
3. Select the final figures from Chapter 2.
4. Select the final tables from Chapter 2.
5. Draft the introduction with international literature.
6. Write the methodology section from repository evidence.
7. Convert thesis results into article-style results.
8. Write discussion focused on WPD and regional characterization.
9. Prepare a data/code availability statement.
10. Prepare references in the target journal format.

---

## 28. Current development status

```text
Current status: Concept note expanded
Next stage: Draft manuscript
Priority: Medium-high
Dependency: Final verification of Chapter 2 figures, tables, and repository metadata
```

---

## 29. Final note

This article should function as the physical and statistical entry point of the publication portfolio derived from the doctoral thesis.

Its central message should be:

```text
A rigorous regional wind-energy study must first characterize the wind signal physically and statistically before attempting prediction, uncertainty quantification, or energy projection.
```

Article 01 therefore establishes the empirical and physical foundation for the complete publication strategy.

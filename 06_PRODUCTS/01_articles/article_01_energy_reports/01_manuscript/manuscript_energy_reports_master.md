# Manuscript Master — Article 01 Energy Reports

## Provisional title

Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

---

## Highlights

- Daily air density supported wind power density estimation.
- Weibull outperformed Rayleigh in all analytical zones.
- Zone 1 showed the strongest and most intermittent WPD regime.
- Daily WPD showed clear temporal persistence across zones.
- FFT revealed distinct temporal-energy regimes in complex terrain.

---

## Abstract

Wind-energy assessment in complex terrain requires physical descriptors that account for atmospheric variability and the nonlinear dependence of available power on wind speed. This study presents a physical–statistical characterization of wind power density (WPD) in Nariño, Colombia, a complex Andean region with heterogeneous topographic and meteorological conditions. Multi-station meteorological records from 2017 to 2022 were grouped into analytical zones and used to estimate WPD from wind speed and daily zone-level air density. A quality-control criterion of wind speed <=20 m s^-1 was applied to reduce cubic amplification by extreme values while preserving 137,484 records. The analysis combined descriptive statistics, Weibull and Rayleigh distribution fitting, autocorrelation and partial autocorrelation functions, and FFT-based spectral analysis. Results showed strong spatial contrasts in wind-energy behavior. Zone 1 exhibited the highest mean WPD and a markedly intermittent regime, while Zones 2–4 showed lower and more regular WPD patterns. Weibull outperformed Rayleigh across all zones, confirming the need for a flexible distributional model. Temporal analysis revealed relevant daily persistence in WPD, particularly in Zone 1, whereas spectral analysis identified distinct temporal-energy regimes across zones. The results demonstrate that WPD-based characterization provides a stronger physical basis than wind-speed-only assessment and offers a reproducible framework for evaluating wind-energy potential in complex Andean terrain.

---

## Keywords

Wind power density; Wind energy; Weibull distribution; Complex terrain; Andean region; Temporal dependence; Spectral analysis

---

# 1. Introduction

Wind-energy assessment is a key component of renewable-energy planning, particularly in regions where topographic complexity produces strong spatial and temporal variability in near-surface atmospheric conditions. In mountainous and Andean environments, wind behavior cannot be adequately represented by simple averages or isolated station-level summaries, because terrain, altitude, pressure, temperature and local atmospheric circulation can modify both the intensity and persistence of wind regimes.

Most preliminary wind-resource assessments rely on wind speed as the main descriptive variable. However, from a physical point of view, wind speed alone is not sufficient to represent the available energy in the flow. Wind power density (WPD) provides a stronger descriptor because it incorporates the cubic dependence on wind speed and the influence of air density. This makes WPD more directly related to the kinetic energy available in the moving air mass and therefore more appropriate for regional wind-energy characterization.

The department of Nariño, Colombia, is located in a complex Andean setting where topographic gradients, altitude variation and heterogeneous meteorological conditions can generate spatially differentiated wind-energy regimes. Despite this potential complexity, localized physical–statistical characterizations of wind power density in the region remain limited. A reproducible analysis based on observed meteorological records is therefore needed to identify how wind-energy potential varies across the territory and whether the observed dynamics show distributional, temporal and spectral structure.

This study presents a physical–statistical characterization of wind power density in Nariño, Colombia, using multi-station meteorological observations grouped into analytical zones. The analysis estimates WPD from wind speed and daily zone-level air density, applies quality control to reduce the influence of extreme cubic amplification, compares Weibull and Rayleigh distributional models, evaluates temporal persistence using autocorrelation and partial autocorrelation functions, and identifies dominant temporal-energy regimes using FFT-based spectral analysis.

The main contribution of this article is a reproducible framework for characterizing wind-energy regimes in complex Andean terrain using observational meteorological data. The study moves beyond wind-speed-only assessment by integrating air-density-supported WPD estimation, distributional fitting, temporal dependence analysis and spectral interpretation.

---

# 2. Study area and meteorological data

## 2.1 Study region

The study focuses on the department of Nariño, located in southwestern Colombia. Nariño is characterized by complex Andean terrain, marked altitudinal gradients and heterogeneous atmospheric conditions. These characteristics make the region suitable for a physical–statistical analysis of wind-energy behavior, because wind regimes may vary substantially across zones due to local terrain and meteorological forcing.

## 2.2 Meteorological stations and analytical zoning

Meteorological records from IDEAM stations located in Nariño were grouped into four analytical zones. This zonal grouping was used to reduce station-level fragmentation and to support regional comparison of wind speed, air density and wind power density.

The analytical zones are used throughout the manuscript as the main spatial unit for comparison.

**Insert Table 1 here.**

```text
Table 1. Dataset, analytical zones and temporal coverage.
```

## 2.3 Variables and observational period

The analysis used meteorological variables required to estimate wind power density and characterize its temporal behavior. The main variable was wind speed (VV), while pressure and temperature variables were used to estimate air density. The corrected observational period covered 2017–2022 after datetime validation.

The main variables used in the article were:

```text
VV: wind speed
PA: atmospheric pressure
TM / temperature variables: air temperature
rho: air density
WPD: wind power density
zone: analytical zone
datetime: temporal reference
```

## 2.4 Datetime validation and preprocessing

Before computing WPD, the datetime structure was validated to avoid temporal misinterpretation. The correct date parser was identified as DMY, which allowed the study period to be consistently restricted to the 2017–2022 interval. This preprocessing step was necessary because incorrect date interpretation can distort seasonal, temporal-dependence and spectral analyses.

---

# 3. Methodology

## 3.1 Air density and wind power density formulation

Wind power density was used as the main physical descriptor of wind-energy potential. WPD was computed as:

```text
WPD = 0.5 * rho * v^3
```

where:

```text
WPD = wind power density
rho = air density
v = wind speed
```

This formulation captures the nonlinear dependence of available wind power on wind speed and incorporates local air-density effects.

Air density was estimated from available pressure and temperature information using the ideal-gas relationship:

```text
rho = p / (R * T)
```

where:

```text
rho = air density
p = atmospheric pressure
R = specific gas constant for dry air
T = absolute temperature
```

## 3.2 Daily zone-level density strategy

Exact hourly overlap among wind speed, pressure and temperature records was limited. Therefore, different air-density strategies were evaluated, including hourly observed density, daily zone-level density, monthly zone-level density, overall zone-level density and standard air density.

The selected strategy was daily zone-level air density. This approach preserves physical dependence on local air-density variation while retaining a larger proportion of useful wind-speed records than exact hourly matching.

## 3.3 Quality-control criterion

Because WPD depends on the cubic power of wind speed, extreme wind-speed values can disproportionately affect the resulting energy-density estimates. A quality-control criterion of:

```text
VV <= 20 m s^-1
```

was selected as the main scenario. This threshold removed a small fraction of extreme values while preserving the dominant structure of the dataset. The final article-level dataset after quality control contained 137,484 records.

## 3.4 Descriptive and distributional analysis

Descriptive statistics were computed by analytical zone for wind speed and WPD. These statistics included the number of records, mean, median, selected percentiles and maximum values.

Wind-speed distributions were then fitted using Weibull and Rayleigh models. The Weibull distribution was used because of its flexibility in representing different wind regimes, while the Rayleigh distribution was used as a constrained reference model commonly applied in wind-resource studies.

Model comparison was performed using distribution parameters, information criteria and visual evaluation of density and cumulative distribution fits.

## 3.5 Temporal dependence analysis

Daily WPD and wind-speed series were constructed by analytical zone. Short gaps were interpolated conservatively to allow regular time-series diagnostics. Autocorrelation functions (ACF) and partial autocorrelation functions (PACF) were used to evaluate temporal persistence and direct short-lag dependence.

The ACF was used to identify whether WPD behaves as independent noise or as a temporally persistent physical process. The PACF was used to evaluate how much direct dependence remains after accounting for intermediate lags.

## 3.6 Spectral analysis

FFT-based spectral analysis was applied to daily WPD and wind-speed series by zone. For each zone, the longest continuous daily segment was selected to reduce distortion caused by large missing gaps. Spectral power was summarized using physically interpretable period bands:

```text
2–10 days
10–30 days
30–120 days
120–365 days
>365 days
```

This analysis was used to identify whether WPD variability was dominated by short-term, intra-monthly, seasonal or low-frequency components.

---

# 4. Results

## 4.1 Wind speed variability by analytical zone

Wind-speed behavior showed clear differences among analytical zones. Monthly mean wind speed revealed temporal variability across the study period, indicating that the wind regime was not spatially homogeneous.

**Insert Figure 1 here.**

```text
Figure 1. Monthly mean wind speed by analytical zone.
```

The empirical wind-speed distributions further showed that the zones differed not only in central tendency but also in distributional shape. This supports the need for zone-level characterization rather than a single regional average.

**Insert Figure 3 here.**

```text
Figure 3. Wind-speed distribution by analytical zone.
```

## 4.2 Zonal contrast in wind power density

WPD showed stronger zonal contrast than wind speed because of the cubic dependence on wind speed. Zone 1 exhibited the highest WPD regime, with a mean WPD substantially greater than the other analytical zones. This indicates that relatively infrequent but energetic wind events can dominate the energy-density signal.

**Insert Figure 2 here.**

```text
Figure 2. Monthly mean WPD by analytical zone.
```

The WPD distributions were strongly asymmetric, especially in the zone with the highest energetic contribution. The pseudo-logarithmic representation allowed both low-energy states and high-energy events to be visualized within the same figure.

**Insert Figure 4 here.**

```text
Figure 4. Wind power density distribution by analytical zone.
```

**Insert Table 2 here.**

```text
Table 2. Descriptive statistics of wind speed and wind power density by analytical zone.
```

## 4.3 Weibull and Rayleigh fitting

Weibull and Rayleigh models were fitted to wind-speed distributions by analytical zone. The Weibull model outperformed the Rayleigh model in all zones, indicating that the additional flexibility of the Weibull distribution was necessary to represent the observed wind-speed regimes.

**Insert Figure 5 here.**

```text
Figure 5. Weibull and Rayleigh density fits by analytical zone.
```

The cumulative distribution comparison confirmed the superiority of the Weibull model across the complete wind-speed range.

**Insert Figure 6 here.**

```text
Figure 6. Weibull and Rayleigh cumulative distribution fits by analytical zone.
```

Zone 1 showed a Weibull shape parameter below unity, indicating a highly asymmetric and intermittent wind-speed regime. In contrast, Zones 2–4 showed shape parameters closer to two, suggesting more regular wind-speed behavior closer to the Rayleigh assumption, although Weibull remained the better model.

**Insert Table 3 here.**

```text
Table 3. Weibull and Rayleigh distribution parameters and goodness-of-fit metrics by analytical zone.
```

## 4.4 Temporal persistence of WPD

The daily autocorrelation analysis revealed substantial temporal persistence in WPD across the analytical zones. Zone 1 showed the strongest persistence, with autocorrelation remaining elevated across long lag windows. Zones 2 and 3 showed intermediate persistence, while Zone 4 showed shorter memory and should be interpreted cautiously due to its lower temporal coverage.

**Insert Figure 7 here.**

```text
Figure 7. Daily autocorrelation function of wind power density by analytical zone.
```

The PACF analysis showed that most direct temporal dependence was concentrated at the first lag, indicating that short-term autoregressive structure plays an important role in WPD dynamics.

## 4.5 Spectral structure of WPD

FFT-based spectral analysis revealed distinct temporal-energy regimes across zones. Zone 1 was dominated by low-frequency variability, while other zones showed more distributed spectral structures across short-term, intra-monthly and seasonal bands.

**Insert Figure 8 here.**

```text
Figure 8. Spectral power distribution of daily wind power density by analytical zone.
```

This result supports the interpretation that WPD in complex terrain is not only spatially heterogeneous but also temporally structured. The spectral-band analysis provides a physical view of how wind-energy variability is distributed across characteristic temporal scales.

**Insert Table 4 here.**

```text
Table 4. Temporal and spectral summary of wind power density by analytical zone.
```

---

# 5. Discussion

## 5.1 Physical interpretation of Zone 1 dominance

The dominance of Zone 1 in WPD can be interpreted as the result of an intermittent but energetically relevant wind regime. Because WPD scales with the cube of wind speed, relatively infrequent high-wind events can strongly increase mean WPD even when median wind speed remains moderate or low. This explains why WPD provides additional physical insight beyond wind-speed-only analysis.

The Weibull shape parameter below unity in Zone 1 supports this interpretation by indicating a high frequency of low wind-speed states combined with occasional energetic events. The temporal and spectral results further suggest that this zone is not dominated by random short-term fluctuations alone, but by a structured low-frequency energetic regime.

## 5.2 Implications for wind-energy assessment in complex Andean terrain

The results show that wind-energy assessment in complex terrain should not rely solely on regional averages or isolated wind-speed indicators. WPD reveals stronger contrasts among zones and provides a more physically meaningful estimate of available energy.

In regions such as Nariño, where topography and atmospheric variability are highly heterogeneous, zone-level analysis can help identify areas with stronger wind-energy potential and distinguish between regular, intermittent and low-frequency energetic regimes.

## 5.3 Methodological contribution

The methodological contribution of this study is the integration of:

```text
air-density-supported WPD estimation,
quality-controlled wind-speed records,
Weibull/Rayleigh distribution fitting,
ACF/PACF temporal persistence analysis,
FFT spectral-band interpretation,
and reproducible computational documentation.
```

This combination provides a transparent and extensible framework for wind-energy characterization in complex terrain.

## 5.4 Limitations

This study is focused on regional WPD characterization and does not perform turbine-level production modeling, wind-farm micrositing, CFD simulation, economic feasibility analysis or grid-integration assessment.

The use of daily zone-level air density is a practical strategy under limited hourly overlap among variables, but it does not replace fully synchronized high-resolution meteorological observations. Zone 4 results should be interpreted cautiously due to lower temporal coverage and shorter continuous segments available for some time-series analyses.

Future studies may extend this work by incorporating turbine power curves, high-resolution terrain modeling, mesoscale atmospheric simulations, forecasting models and uncertainty quantification.

---

# 6. Conclusions

This study presented a physical–statistical characterization of wind power density in Nariño, Colombia, using multi-station meteorological observations grouped into analytical zones.

The main conclusions are:

1. WPD provides a stronger physical descriptor of wind-energy potential than wind speed alone because it incorporates air density and the cubic dependence on wind speed.

2. Daily zone-level air density offers a practical and physically meaningful strategy for WPD estimation when exact hourly overlap among wind speed, pressure and temperature is limited.

3. The quality-controlled WPD dataset preserved the dominant structure of the observations while reducing the influence of extreme cubic amplification.

4. Zone 1 exhibited the strongest and most intermittent wind-energy regime, with substantially higher WPD than the other analytical zones.

5. Weibull outperformed Rayleigh across all zones, indicating that flexible distributional modeling is necessary for representing wind-speed behavior in complex terrain.

6. Daily WPD showed relevant temporal persistence, especially in Zone 1, supporting the interpretation of WPD as a structured physical process rather than independent random variability.

7. FFT-based spectral analysis revealed distinct temporal-energy regimes across zones, confirming that WPD variability is distributed across characteristic period bands.

Overall, the results demonstrate that WPD-based physical–statistical characterization provides a reproducible framework for evaluating wind-energy potential in complex Andean terrain.

---

# Data availability statement

The meteorological records used in this study were obtained from IDEAM, the official meteorological and hydrological data source in Colombia. Due to source-data redistribution considerations, the raw observational dataset is not redistributed in this repository. The scripts, derived summary outputs, figures, tables and reproducibility documentation supporting the results of this study are available in the associated GitHub repository. Access to the original raw meteorological records should be requested or downloaded from the official IDEAM data platform.

---

# CRediT author statement

Favio Nicolás Rosero Rodríguez: Conceptualization, Methodology, Software, Validation, Formal analysis, Investigation, Data curation, Visualization, Writing – original draft, Writing – review and editing.

---

# Declaration of competing interest

The author(s) declare that they have no known competing financial interests or personal relationships that could have appeared to influence the work reported in this paper.

---

# Funding statement

This research did not receive any specific grant from funding agencies in the public, commercial, or not-for-profit sectors.

---

# Declaration of generative AI and AI-assisted technologies

During the preparation of this work, the author used ChatGPT as an AI-assisted tool to support manuscript organization, editorial planning, language refinement and code-review discussion. All scientific analyses, data processing, statistical calculations, figures and tables were generated from the author-controlled research workflow in R. After using this tool, the author reviewed, edited and verified the content as needed and takes full responsibility for the content of the manuscript.

---

# References

[Pending. Build from verified literature only.]

---

# Internal TDQ notes

## Current manuscript status

```text
Title: drafted
Highlights: drafted
Abstract: drafted
Keywords: drafted
Introduction: first draft
Methods: first draft
Results: first draft
Discussion: first draft
Conclusions: first draft
Declarations: drafted
References: pending
```

## Pending actions

1. Insert final table values.
2. Insert final figure files.
3. Add verified references.
4. Refine Results with exact numerical values.
5. Refine Discussion with literature contrast.
6. Verify Energy Reports formatting.
7. Convert to DOCX before submission.
8. Cross-check all figure and table citations.
9. Confirm final author list.
10. Confirm final affiliations and ORCID.

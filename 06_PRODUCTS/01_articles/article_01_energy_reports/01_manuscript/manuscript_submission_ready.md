# Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

## Highlights

- Daily air density supported wind power density estimation.
- Weibull outperformed Rayleigh in all analytical zones.
- Zone 1 showed the strongest and most intermittent WPD regime.
- Daily WPD showed clear temporal persistence across zones.
- FFT revealed distinct temporal-energy regimes in complex terrain.

## Abstract

Wind-energy assessment in complex terrain requires physical descriptors that account for atmospheric variability and the nonlinear dependence of available power on wind speed. This study presents a physical–statistical characterization of wind power density (WPD) in Nariño, Colombia, a complex Andean region with heterogeneous topographic and meteorological conditions. Multi-station meteorological records from 2017 to 2022 were grouped into analytical zones and used to estimate WPD from wind speed and daily zone-level air density. A quality-control criterion of wind speed ≤20 m s^-1 was applied to reduce cubic amplification by extreme values while preserving 137,484 records. The analysis combined descriptive statistics, Weibull and Rayleigh distribution fitting, autocorrelation and partial autocorrelation functions, and FFT-based spectral analysis. Results showed strong spatial contrasts in wind-energy behavior. Zone 1 exhibited the highest mean WPD and a markedly intermittent regime, while Zones 2–4 showed lower and more regular WPD patterns. Weibull outperformed Rayleigh across all zones, confirming the need for a flexible distributional model. Temporal analysis revealed relevant daily persistence in WPD, particularly in Zone 1, whereas spectral analysis identified distinct temporal-energy regimes across zones. The results demonstrate that WPD-based characterization provides a stronger physical basis than wind-speed-only assessment and offers a reproducible framework for evaluating wind-energy potential in complex Andean terrain.

## Keywords

Wind power density; Wind energy; Weibull distribution; Complex terrain; Andean region; Temporal dependence; Spectral analysis

# 1. Introduction

Wind-energy assessment is a key component of renewable-energy planning, particularly in regions where topographic complexity produces strong spatial and temporal variability in near-surface atmospheric conditions. In mountainous and complex-terrain environments, wind behavior cannot be adequately represented by simple averages or isolated station-level summaries, because terrain, altitude, pressure, temperature and local atmospheric circulation can modify wind intensity, persistence and energy availability (Palma et al., 2008; Carvalho et al., 2013; Radünz et al., 2020).

Most preliminary wind-resource assessments rely on wind speed as the main descriptive variable. However, from a physical point of view, wind speed alone is not sufficient to represent the available energy in the atmospheric flow. Wind power density (WPD) provides a stronger descriptor because it incorporates the cubic dependence on wind speed and the influence of air density (Manwell et al., 2009; Burton et al., 2011; Carta and Mentado, 2007). This makes WPD more directly related to the kinetic energy available in the moving air mass and therefore more appropriate for regional wind-energy characterization.

Colombia has an official wind-resource assessment background through the national wind and wind-energy atlas developed by IDEAM and UPME (2006). Recent Colombian studies have also evaluated wind-power potential using observational and reanalysis data, especially in the Caribbean region (Gil Ruiz et al., 2021; Gil Ruiz et al., 2022). However, localized physical–statistical characterizations of WPD in complex Andean regions remain limited. In Nariño, Eraso Checa and Escobar Rosero (2018) provided a direct regional precedent for wind-resource characterization in Túquerres, supporting the relevance of further wind-energy analysis in this department.

Nariño, located in southwestern Colombia, is characterized by complex Andean terrain, marked altitudinal gradients and heterogeneous meteorological conditions. These characteristics make the region suitable for a physical–statistical analysis of WPD, because wind-energy regimes may vary substantially across zones due to terrain-mediated atmospheric dynamics. Similar Andean and mountainous wind-assessment studies have shown that complex topography can produce non-uniform wind-resource distributions and requires careful spatial characterization (Ayala et al., 2017; Tang et al., 2019).

This study presents a physical–statistical characterization of WPD in Nariño, Colombia, using multi-station meteorological observations grouped into analytical zones. The analysis estimates WPD from wind speed and daily zone-level air density, applies quality control to reduce the influence of extreme cubic amplification, compares Weibull and Rayleigh distributional models, evaluates temporal persistence using autocorrelation and partial autocorrelation functions, and identifies dominant temporal-energy regimes using FFT-based spectral analysis.

The main contribution of this article is a reproducible framework for characterizing wind-energy regimes in complex Andean terrain using observational meteorological data. The study moves beyond wind-speed-only assessment by integrating air-density-supported WPD estimation, distributional fitting, temporal-dependence analysis and spectral interpretation.

# 2. Study area and meteorological data

## 2.1 Study region

The study focuses on the department of Nariño, located in southwestern Colombia. Nariño is part of the Colombian Andes and contains strong topographic variation, which can generate heterogeneous atmospheric and wind-energy conditions. This regional setting justifies the use of a zone-level approach rather than a single aggregated analysis.

## 2.2 Meteorological stations and analytical zoning

Meteorological records from IDEAM stations located in Nariño were grouped into four analytical zones. This zonal grouping was used to reduce station-level fragmentation and to support regional comparison of wind speed, air density and WPD. The analytical zones are used throughout the manuscript as the main spatial unit for comparison.

**Table 1. Dataset, analytical zones and temporal coverage.**

## 2.3 Variables and observational period

The meteorological records were obtained from IDEAM, the official Colombian institution responsible for hydrological and meteorological information. The DHIME system provides access to hydrological and meteorological data series and supports the data-origin traceability of this study (IDEAM, 2024).

The analysis used meteorological variables required to estimate WPD and characterize its temporal behavior. The main variable was wind speed (VV), while pressure and temperature variables were used to estimate air density. The corrected observational period covered 2017–2022 after datetime validation.

The main variables used in the article were wind speed, atmospheric pressure, air temperature, air density, WPD, analytical zone and datetime.

## 2.4 Datetime validation and preprocessing

Before computing WPD, the datetime structure was validated to avoid temporal misinterpretation. The correct date parser was identified as DMY, which allowed the study period to be consistently restricted to the 2017–2022 interval. This preprocessing step was necessary because incorrect date interpretation can distort seasonal, temporal-dependence and spectral analyses.

# 3. Methodology

## 3.1 Air density and wind power density formulation

WPD was used as the main physical descriptor of wind-energy potential. The available wind power per unit area depends on air density and the cube of wind speed, which makes WPD more physically informative than wind speed alone (Manwell et al., 2009; Burton et al., 2011).

WPD was computed as:

```text
WPD = 0.5 · rho · v^3
```

where WPD is wind power density, rho is air density and v is wind speed.

Air density was estimated from available pressure and temperature information using the ideal-gas relationship:

```text
rho = p / (R · T)
```

where rho is air density, p is atmospheric pressure, R is the specific gas constant for dry air and T is absolute temperature.

The inclusion of air density is relevant because density variations can affect WPD and wind-energy estimates, particularly when atmospheric conditions vary across space or time (Carta and Mentado, 2007; Ulazia et al., 2019; Jung et al., 2019).

## 3.2 Daily zone-level density strategy

Exact hourly overlap among wind speed, pressure and temperature records was limited. Therefore, different air-density strategies were evaluated, including hourly observed density, daily zone-level density, monthly zone-level density, overall zone-level density and standard air density.

The selected strategy was daily zone-level air density. This approach preserves physical dependence on local air-density variation while retaining a larger proportion of useful wind-speed records than exact hourly matching.

## 3.3 Quality-control criterion

Because WPD depends on the cubic power of wind speed, extreme wind-speed values can disproportionately affect the resulting energy-density estimates. A quality-control criterion of VV ≤20 m s^-1 was selected as the main scenario. This threshold removed a small fraction of extreme values while preserving the dominant structure of the dataset. The final article-level dataset after quality control contained 137,484 records.

## 3.4 Descriptive and distributional analysis

Descriptive statistics were computed by analytical zone for wind speed and WPD. These statistics included the number of records, mean, median, selected percentiles and maximum values.

Wind-speed distributions were fitted using Weibull and Rayleigh models. Weibull distributions are widely used in wind-energy analysis because they can represent different wind-speed regimes through their shape and scale parameters, while several estimation approaches have been proposed for wind-energy applications (Justus et al., 1978; Seguro and Lambert, 2000; Akdağ and Dinler, 2009; Carta et al., 2009). The Rayleigh distribution was included as a constrained reference model commonly used in wind-resource assessment (Celik, 2004; Pishgar-Komleh et al., 2015).

Model comparison was performed using distribution parameters, information criteria and visual evaluation of density and cumulative distribution fits. The interpretation of Weibull performance was made cautiously, recognizing that alternative distributions may outperform Weibull in some contexts and that distributional selection should be dataset-specific (Drobinski et al., 2015).

## 3.5 Temporal-dependence analysis

Daily WPD and wind-speed series were constructed by analytical zone. Short gaps were interpolated conservatively to allow regular time-series diagnostics. Autocorrelation functions (ACF) and partial autocorrelation functions (PACF) were used to evaluate temporal persistence and direct short-lag dependence.

ACF and PACF are standard tools in time-series analysis for evaluating persistence, memory and autoregressive structure (Box et al., 2008). In wind-energy studies, time-series models have been used to simulate, forecast and interpret wind speed and wind power, supporting the relevance of temporal-dependence analysis in wind-resource characterization (Brown et al., 1984; Torres et al., 2005; Kavasseri and Seetharaman, 2009; Erdem and Shi, 2011).

## 3.6 Spectral analysis

FFT-based spectral analysis was applied to daily WPD and wind-speed series by zone. For each zone, the longest continuous daily segment was selected to reduce distortion caused by large missing gaps.

The fast Fourier transform provides a computational basis for decomposing time series into frequency components (Cooley and Tukey, 1965). Spectral analysis has a long tradition in atmospheric wind studies, including the classic analysis of horizontal wind-speed spectra by Van der Hoven (1957). More recent studies have also connected wind-power spectral analysis with wind-resource assessment and complex-terrain interpretation (Lopez-Villalobos et al., 2021; Telesca et al., 2016).

Spectral power was summarized using physically interpretable period bands: 2–10 days, 10–30 days, 30–120 days, 120–365 days and >365 days. This analysis was used to identify whether WPD variability was dominated by short-term, intra-monthly, seasonal or low-frequency components.

# 4. Results

## 4.1 Wind-speed variability by analytical zone

Wind-speed behavior showed clear differences among analytical zones. Monthly mean wind speed revealed temporal variability across the study period, indicating that the wind regime was not spatially homogeneous.

**Figure 1. Monthly mean wind speed by analytical zone.**

The empirical wind-speed distributions further showed that the zones differed not only in central tendency but also in distributional shape. This supports the need for zone-level characterization rather than a single regional average.

**Figure 3. Wind-speed distribution by analytical zone.**

## 4.2 Zonal contrast in wind power density

WPD showed stronger zonal contrast than wind speed because of the cubic dependence on wind speed. Zone 1 exhibited the highest WPD regime, with a mean WPD substantially greater than the other analytical zones. This indicates that relatively infrequent but energetic wind events can dominate the energy-density signal.

**Figure 2. Monthly mean WPD by analytical zone.**

The WPD distributions were strongly asymmetric, especially in the zone with the highest energetic contribution. The pseudo-logarithmic representation allowed both low-energy states and high-energy events to be visualized within the same figure.

**Figure 4. Wind power density distribution by analytical zone.**

**Table 2. Descriptive statistics of wind speed and wind power density by analytical zone.**

## 4.3 Weibull and Rayleigh fitting

Weibull and Rayleigh models were fitted to wind-speed distributions by analytical zone. The Weibull model outperformed the Rayleigh model in all zones, indicating that the additional flexibility of the Weibull distribution was necessary to represent the observed wind-speed regimes. This result is consistent with previous wind-energy studies in which Weibull-based modeling has provided useful representation of empirical wind-speed distributions, while Rayleigh has served as a simpler reference model (Celik, 2004; Carta et al., 2009; Pishgar-Komleh et al., 2015).

**Figure 5. Weibull and Rayleigh density fits by analytical zone.**

The cumulative distribution comparison confirmed the superiority of the Weibull model across the complete wind-speed range.

**Figure 6. Weibull and Rayleigh cumulative distribution fits by analytical zone.**

Zone 1 showed a Weibull shape parameter below unity, indicating a highly asymmetric and intermittent wind-speed regime. In contrast, Zones 2–4 showed shape parameters closer to two, suggesting more regular wind-speed behavior closer to the Rayleigh assumption, although Weibull remained the better model.

**Table 3. Weibull and Rayleigh distribution parameters and goodness-of-fit metrics by analytical zone.**

## 4.4 Temporal persistence of WPD

The daily autocorrelation analysis revealed substantial temporal persistence in WPD across the analytical zones. Zone 1 showed the strongest persistence, with autocorrelation remaining elevated across long lag windows. Zones 2 and 3 showed intermediate persistence, while Zone 4 showed shorter memory and should be interpreted cautiously due to its lower temporal coverage.

**Figure 7. Daily autocorrelation function of wind power density by analytical zone.**

The PACF analysis showed that most direct temporal dependence was concentrated at the first lag, indicating that short-term autoregressive structure plays an important role in WPD dynamics. This persistence is relevant because wind-power behavior may be governed by sustained high- and low-energy regimes rather than isolated independent events (Weber et al., 2019). This result is coherent with the broader use of autoregressive and time-series approaches in wind-speed and wind-power analysis (Brown et al., 1984; Torres et al., 2005; Erdem and Shi, 2011).

## 4.5 Spectral structure of WPD

FFT-based spectral analysis revealed distinct temporal-energy regimes across zones. Zone 1 was dominated by low-frequency variability, while other zones showed more distributed spectral structures across short-term, intra-monthly and seasonal bands.

**Figure 8. Spectral power distribution of daily wind power density by analytical zone.**

This result supports the interpretation that WPD in complex terrain is not only spatially heterogeneous but also temporally structured. The spectral-band analysis provides a physical view of how wind-energy variability is distributed across characteristic temporal scales, consistent with the use of wind-spectrum analysis for identifying relevant time-scale structures in wind-resource studies (Van der Hoven, 1957; Lopez-Villalobos et al., 2021; Telesca et al., 2016).

**Table 4. Temporal and spectral summary of wind power density by analytical zone.**

# 5. Discussion

## 5.1 Physical interpretation of Zone 1 dominance

The dominance of Zone 1 in WPD can be interpreted as the result of an intermittent but energetically relevant wind regime. Because WPD scales with the cube of wind speed, relatively infrequent high-wind events can strongly increase mean WPD even when median wind speed remains moderate or low. This explains why WPD provides additional physical insight beyond wind-speed-only analysis.

The Weibull shape parameter below unity in Zone 1 supports this interpretation by indicating a high frequency of low wind-speed states combined with occasional energetic events. The temporal and spectral results further suggest that this zone is not dominated by random short-term fluctuations alone, but by a structured low-frequency energetic regime.

## 5.2 Implications for wind-energy assessment in complex Andean terrain

The results show that wind-energy assessment in complex terrain should not rely solely on regional averages or isolated wind-speed indicators. Complex terrain can produce spatially heterogeneous wind-resource behavior, and studies using observational, mesoscale–microscale or CFD-based approaches have shown that terrain-induced flow variability must be treated carefully (Palma et al., 2008; Carvalho et al., 2013; Radünz et al., 2020; Tang et al., 2019).

In regions such as Nariño, where topography and atmospheric variability are highly heterogeneous, zone-level analysis can help identify areas with stronger wind-energy potential and distinguish between regular, intermittent and low-frequency energetic regimes. The local precedent in Túquerres-Nariño supports the relevance of developing wind-energy characterization studies in the department, while the present study expands the analysis using a multi-station and zone-level approach (Eraso Checa and Escobar Rosero, 2018).

## 5.3 Methodological contribution

The methodological contribution of this study is the integration of air-density-supported WPD estimation, quality-controlled wind-speed records, Weibull/Rayleigh distribution fitting, ACF/PACF temporal-persistence analysis, FFT spectral-band interpretation and reproducible computational documentation.

This combination provides a transparent and extensible framework for wind-energy characterization in complex terrain. The reproducibility orientation of the workflow is aligned with current expectations for computational science, where traceability, data-management principles and verifiable code-based analysis strengthen scientific reliability (Peng, 2011; Wilkinson et al., 2016).

## 5.4 Limitations

This study is focused on regional WPD characterization and does not perform turbine-level production modeling, wind-farm micrositing, CFD simulation, economic feasibility analysis or grid-integration assessment.

The use of daily zone-level air density is a practical strategy under limited hourly overlap among variables, but it does not replace fully synchronized high-resolution meteorological observations. Zone 4 results should be interpreted cautiously due to lower temporal coverage and shorter continuous segments available for some time-series analyses.

Future studies may extend this work by incorporating turbine power curves, high-resolution terrain modeling, mesoscale atmospheric simulations, forecasting models and uncertainty quantification.

# 6. Conclusions

This study presented a physical–statistical characterization of WPD in Nariño, Colombia, using multi-station meteorological observations grouped into analytical zones.

The main conclusions are:

1. WPD provides a stronger physical descriptor of wind-energy potential than wind speed alone because it incorporates air density and the cubic dependence on wind speed.

2. Daily zone-level air density offers a practical and physically meaningful strategy for WPD estimation when exact hourly overlap among wind speed, pressure and temperature is limited.

3. The quality-controlled WPD dataset preserved the dominant structure of the observations while reducing the influence of extreme cubic amplification.

4. Zone 1 exhibited the strongest and most intermittent wind-energy regime, with substantially higher WPD than the other analytical zones.

5. Weibull outperformed Rayleigh across all zones, indicating that flexible distributional modeling is necessary for representing wind-speed behavior in complex terrain.

6. Daily WPD showed relevant temporal persistence, especially in Zone 1, supporting the interpretation of WPD as a structured physical process rather than independent random variability.

7. FFT-based spectral analysis revealed distinct temporal-energy regimes across zones, confirming that WPD variability is distributed across characteristic period bands.

Overall, the results demonstrate that WPD-based physical–statistical characterization provides a reproducible framework for evaluating wind-energy potential in complex Andean terrain.

# Data availability statement

The meteorological records used in this study were obtained from IDEAM, the official meteorological and hydrological data source in Colombia. Due to source-data redistribution considerations, the raw observational dataset is not redistributed in this repository. The scripts, derived summary outputs, figures, tables and reproducibility documentation supporting the results of this study are available in the associated GitHub repository. Access to the original raw meteorological records should be requested or downloaded from the official IDEAM data platform (IDEAM, 2024).

# CRediT author statement

Favio Nicolás Rosero Rodríguez: Conceptualization, Methodology, Software, Validation, Formal analysis, Investigation, Data curation, Visualization, Writing – original draft, Writing – review and editing.

# Declaration of competing interest

The author declares that there are no known competing financial interests or personal relationships that could have appeared to influence the work reported in this paper.

# Funding statement

This research did not receive any specific grant from funding agencies in the public, commercial, or not-for-profit sectors.

# Declaration of generative AI and AI-assisted technologies

During the preparation of this work, the author used ChatGPT as an AI-assisted tool to support manuscript organization, editorial planning, language refinement and code-review discussion. All scientific analyses, data processing, statistical calculations, figures and tables were generated from the author-controlled research workflow in R. After using this tool, the author reviewed, edited and verified the content as needed and takes full responsibility for the content of the manuscript.

# References

Akdağ, S.A., Dinler, A., 2009. A new method to estimate Weibull parameters for wind energy applications. Energy Conversion and Management 50, 1761–1766. https://doi.org/10.1016/j.enconman.2009.03.020

Ayala, M., Maldonado, J., Paccha, E., Riba, C., 2017. Wind Power Resource Assessment in Complex Terrain: Villonaco Case-study Using Computational Fluid Dynamics Analysis. Energy Procedia 107, 41–48. https://doi.org/10.1016/j.egypro.2016.12.127

Box, G.E.P., Jenkins, G.M., Reinsel, G.C., 2008. Time Series Analysis: Forecasting and Control, 4th ed. John Wiley & Sons. https://doi.org/10.1002/9781118619193

Brown, B.G., Katz, R.W., Murphy, A.H., 1984. Time series models to simulate and forecast wind speed and wind power. Journal of Climate and Applied Meteorology 23, 1184–1195. https://doi.org/10.1175/1520-0450(1984)023<1184:TSMTSA>2.0.CO;2

Burton, T., Jenkins, N., Sharpe, D., Bossanyi, E., 2011. Wind Energy Handbook, 2nd ed. John Wiley & Sons. https://doi.org/10.1002/9781119992714

Carta, J.A., Mentado, D., 2007. A continuous bivariate model for wind power density and wind turbine energy output estimations. Energy Conversion and Management 48, 420–432. https://doi.org/10.1016/j.enconman.2006.06.019

Carta, J.A., Ramírez, P., Velázquez, S., 2009. A review of wind speed probability distributions used in wind energy analysis: Case studies in the Canary Islands. Renewable and Sustainable Energy Reviews 13, 933–955. https://doi.org/10.1016/j.rser.2008.05.005

Carvalho, D., Rocha, A., Santos, C.S., Pereira, R., 2013. Wind resource modelling in complex terrain using different mesoscale–microscale coupling techniques. Applied Energy 108, 493–504. https://doi.org/10.1016/j.apenergy.2013.03.074

Celik, A.N., 2004. A statistical analysis of wind power density based on the Weibull and Rayleigh models at the southern region of Turkey. Renewable Energy 29, 593–604. https://doi.org/10.1016/j.renene.2003.07.002

Cooley, J.W., Tukey, J.W., 1965. An algorithm for the machine calculation of complex Fourier series. Mathematics of Computation 19, 297–301. https://doi.org/10.1090/S0025-5718-1965-0178586-1

Drobinski, P., Coulais, C., Jourdier, B., 2015. Surface wind-speed statistics modelling: Alternatives to the Weibull distribution and performance evaluation. Boundary-Layer Meteorology 157, 97–123. https://doi.org/10.1007/s10546-015-0035-7

Eraso Checa, F., Escobar Rosero, E., 2018. Metodología para la determinación de características del viento y evaluación del potencial de energía eólica en Túquerres-Nariño. Revista Científica 31, 19–31. https://doi.org/10.14483/23448350.12304

Erdem, E., Shi, J., 2011. ARMA based approaches for forecasting the tuple of wind speed and direction. Applied Energy 88, 1405–1414. https://doi.org/10.1016/j.apenergy.2010.10.031

Gil Ruiz, S.A., Cañón Barriga, J.E., Martínez, J.A., 2021. Wind power assessment in the Caribbean region of Colombia, using ten-minute wind observations and ERA5 data. Renewable Energy 172, 158–176. https://doi.org/10.1016/j.renene.2021.03.033

Gil Ruiz, S.A., Cañón Barriga, J.E., Martínez, J.A., 2022. Assessment and validation of wind power potential at convection-permitting resolution for the Caribbean region of Colombia. Energy 244, 123127. https://doi.org/10.1016/j.energy.2022.123127

IDEAM, 2024. Sistema de Información para la gestión de datos Hidrológicos y Meteorológicos — DHIME. Instituto de Hidrología, Meteorología y Estudios Ambientales, Colombia. https://www.ideam.gov.co/dhime

IDEAM, UPME, 2006. Atlas de viento y energía eólica de Colombia. Instituto de Hidrología, Meteorología y Estudios Ambientales; Unidad de Planeación Minero Energética. https://www1.upme.gov.co/Hemeroteca/Paginas/atlas-viento-energia-eolica-2006.aspx

Jung, C., Schindler, D., Albrecht, A., Buchholz, A., 2019. The role of air density in wind energy assessment — A case study from Germany. Energy 171, 385–392. https://doi.org/10.1016/j.energy.2019.01.041

Justus, C.G., Hargraves, W.R., Mikhail, A., Graber, D., 1978. Methods for estimating wind speed frequency distributions. Journal of Applied Meteorology 17, 350–353. https://doi.org/10.1175/1520-0450(1978)017<0350:MFEWSF>2.0.CO;2

Kavasseri, R.G., Seetharaman, K., 2009. Day-ahead wind speed forecasting using f-ARIMA models. Renewable Energy 34, 1388–1393. https://doi.org/10.1016/j.renene.2008.09.006

Lopez-Villalobos, C.A., Rodriguez-Hernandez, O., Martínez-Alvarado, O., Hernandez-Yepes, J.G., 2021. Effects of wind power spectrum analysis over resource assessment. Renewable Energy 167, 761–773. https://doi.org/10.1016/j.renene.2020.11.147

Manwell, J.F., McGowan, J.G., Rogers, A.L., 2009. Wind Energy Explained: Theory, Design and Application, 2nd ed. John Wiley & Sons. https://doi.org/10.1002/9781119994367

Palma, J.M.L.M., Castro, F.A., Ribeiro, L.F., Rodrigues, A.H., Pinto, A.P., 2008. Linear and nonlinear models in wind resource assessment and wind turbine micro-siting in complex terrain. Journal of Wind Engineering and Industrial Aerodynamics 96, 2308–2326. https://doi.org/10.1016/j.jweia.2008.03.012

Peng, R.D., 2011. Reproducible research in computational science. Science 334, 1226–1227. https://doi.org/10.1126/science.1213847

Pishgar-Komleh, S.H., Keyhani, A., Sefeedpari, P., 2015. Wind speed and power density analysis based on Weibull and Rayleigh distributions: A case study of Firouzkooh county of Iran. Renewable and Sustainable Energy Reviews 42, 313–322. https://doi.org/10.1016/j.rser.2014.10.028

Radünz, W.C., Mattuella, J.M.L., Petry, A.P., 2020. Wind resource mapping and energy estimation in complex terrain: A framework based on field observations and computational fluid dynamics. Renewable Energy 152, 494–515. https://doi.org/10.1016/j.renene.2020.01.014

Seguro, J.V., Lambert, T.W., 2000. Modern estimation of the parameters of the Weibull wind speed distribution for wind energy analysis. Journal of Wind Engineering and Industrial Aerodynamics 85, 75–84. https://doi.org/10.1016/S0167-6105(99)00122-1

Tang, X.-Y., Zhao, S., Fan, B., Peinke, J., Stoevesandt, B., 2019. Micro-scale wind resource assessment in complex terrain based on CFD coupled measurement from multiple masts. Applied Energy 238, 806–815. https://doi.org/10.1016/j.apenergy.2019.01.129

Telesca, L., Lovallo, M., Kanevski, M., 2016. Power spectrum and multifractal detrended fluctuation analysis of high-frequency wind measurements in mountainous regions. Applied Energy 162, 1052–1061. https://doi.org/10.1016/j.apenergy.2015.10.187

Torres, J.L., García, A., De Blas, M., De Francisco, A., 2005. Forecast of hourly average wind speed with ARMA models in Navarre, Spain. Solar Energy 79, 65–77. https://doi.org/10.1016/j.solener.2004.09.013

Ulazia, A., Sáenz, J., Ibarra-Berastegi, G., González-Rojí, S.J., Carreno-Madinabeitia, S., 2019. Global estimations of wind energy potential considering seasonal air density changes. Energy 187, 115938. https://doi.org/10.1016/j.energy.2019.115938

Van der Hoven, I., 1957. Power spectrum of horizontal wind speed in the frequency range from 0.0007 to 900 cycles per hour. Journal of Meteorology 14, 160–164. https://doi.org/10.1175/1520-0469(1957)014<0160:PSOHWS>2.0.CO;2

Weber, J., Reyers, M., Beck, C., Timme, M., Pinto, J.G., Witthaut, D., Schäfer, B., 2019. Wind Power Persistence Characterized by Superstatistics. Scientific Reports 9, 19971. https://doi.org/10.1038/s41598-019-56286-1

Wilkinson, M.D., Dumontier, M., Aalbersberg, I.J., Appleton, G., Axton, M., Baak, A., et al., 2016. The FAIR Guiding Principles for scientific data management and stewardship. Scientific Data 3, 160018. https://doi.org/10.1038/sdata.2016.18

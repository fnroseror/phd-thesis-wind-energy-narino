# Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

F.N. Rosero-Rodríguez a,b,c,*, N.V. Naranjo-Castaño a,b, J.M. López-Moreno c, E. Restrepo-Parra a,b, J.C. Riaño-Rojas a,b, S.G. Rosero-Rodríguez d

a Laboratorio de Física del Plasma, Facultad de Ciencias Exactas y Naturales, Universidad Nacional de Colombia Sede Manizales, Manizales 170003, Colombia.

b PCM Computational Applications Research, Facultad de Ciencias Exactas y Naturales, Universidad Nacional de Colombia Sede Manizales, Manizales 170003, Colombia.

c GISMAR Grupo de Investigación de Ingeniería de Sistemas, Universidad Mariana, Pasto 520001, Colombia.

d Escuela Normal Superior Pio XII, Pupiales, Nariño, Colombia.

* Corresponding author.

E-mail address: [favionrosero@umariana.edu.co](mailto:favionrosero@umariana.edu.co)

## Highlights

* WPD was characterized as a physical state variable in complex Andean terrain.
* Zone 1 showed intermittent energetic dominance driven by high-speed tails.
* Weibull fitting captured zone-dependent wind-speed probability structures.
* Daily WPD revealed temporal memory rather than independent fluctuations.
* FFT identified distinct spectral-energy signatures across analytical zones.

## Abstract

Wind-energy assessment in complex terrain requires physical descriptors capable of representing spatial heterogeneity, nonlinear energy transformation and temporal structure. This study presents a physical–statistical and spectral characterization of wind power density (WPD) in Nariño, Colombia, a complex Andean region with heterogeneous topographic and meteorological conditions. Multi-station meteorological records from 2017 to 2022 were grouped into four analytical zones and used to estimate WPD from wind speed and daily zone-level air density. A conservative quality-control criterion of wind speed ≤20 m s^-1 was applied, preserving 137,484 records, equivalent to 99.7562% of the selected WPD dataset. The analysis integrated descriptive statistics, Weibull and Rayleigh distribution fitting, autocorrelation diagnostics and FFT-based spectral-band decomposition. Results showed that WPD provides a stronger physical separation among zones than wind speed alone. Zone 1 dominated the regional energetic structure, with mean WPD of approximately 140.76 W m^-2, despite not presenting the highest mean wind speed. This dominance was explained by an intermittent regime with frequent low-speed states, a long high-speed tail and nonlinear cubic amplification in WPD. Weibull outperformed Rayleigh in all zones, with Zone 1 showing a shape parameter below one, confirming strong asymmetry. Daily WPD exhibited temporal memory, with Zone 1 maintaining autocorrelation above the selected threshold within the 90-day lag window. FFT analysis revealed distinct temporal-energy signatures, including low-frequency dominance in Zone 1 and shorter-period variability in Zone 4. These results demonstrate that WPD-based characterization can move wind-resource assessment beyond average-based description toward state, memory and spectral characterization in complex Andean terrain.

## Keywords

Wind power density; Complex terrain; Physical–statistical characterization; Weibull distribution; Temporal memory; Spectral analysis; Andean region

# 1. Introduction

Wind-energy assessment is a key component of renewable-energy planning, particularly in regions where topographic complexity produces strong spatial and temporal variability in near-surface atmospheric conditions. In mountainous and complex-terrain environments, wind behavior cannot be adequately represented by simple averages or isolated station-level summaries, because terrain, altitude, pressure, temperature and local atmospheric circulation can modify wind intensity, persistence and energy availability (Palma et al., 2008; Carvalho et al., 2013; Radünz et al., 2020).

Most preliminary wind-resource assessments rely on wind speed as the main descriptive variable. However, from a physical point of view, wind speed alone is not sufficient to represent the available energy in the atmospheric flow. Wind power density (WPD) provides a stronger descriptor because it incorporates the cubic dependence on wind speed and the influence of air density (Manwell et al., 2009; Burton et al., 2011; Carta and Mentado, 2007). This makes WPD more directly related to the kinetic energy available in the moving air mass and therefore more appropriate for regional wind-energy characterization.

Colombia has an official wind-resource assessment background through the national wind and wind-energy atlas developed by IDEAM and UPME (2006). Recent Colombian studies have also evaluated wind-power potential using observational and reanalysis data, especially in the Caribbean region (Gil Ruiz et al., 2021; Gil Ruiz et al., 2022). However, localized physical–statistical characterizations of WPD in complex Andean regions remain limited. In Nariño, Eraso Checa and Escobar Rosero (2018) provided a direct regional precedent for wind-resource characterization in Túquerres, supporting the relevance of further wind-energy analysis in this department.

Nariño, located in southwestern Colombia, is characterized by complex Andean terrain, marked altitudinal gradients and heterogeneous meteorological conditions. These characteristics make the region suitable for a physical–statistical analysis of WPD, because wind-energy regimes may vary substantially across zones due to terrain-mediated atmospheric dynamics. Similar Andean and mountainous wind-assessment studies have shown that complex topography can produce non-uniform wind-resource distributions and requires careful spatial characterization (Ayala et al., 2017; Tang et al., 2019).

This study presents a physical–statistical characterization of WPD in Nariño, Colombia, using multi-station meteorological observations grouped into analytical zones. The analysis estimates WPD from wind speed and daily zone-level air density, applies quality control to reduce the influence of extreme cubic amplification, compares Weibull and Rayleigh distributional models, evaluates temporal persistence using autocorrelation and partial autocorrelation functions, and identifies dominant temporal-energy regimes using FFT-based spectral analysis.

The main contribution of this article is a reproducible framework for characterizing wind-energy regimes in complex Andean terrain using observational meteorological data. The study moves beyond wind-speed-only assessment by integrating air-density-supported WPD estimation, distributional fitting, temporal-dependence analysis and spectral interpretation.

# 2. Study area and meteorological data

## 2.1 Study region

The study focuses on the department of Nariño, located in southwestern Colombia. Nariño is part of the Colombian Andes and contains strong topographic variation, which can generate heterogeneous atmospheric and wind-energy conditions. This regional setting justifies the use of a zone-level approach rather than a single aggregated analysis. Figure 1 presents the physiographic setting, topographic relief, IDEAM meteorological stations and analytical zoning used in this study.

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

Because WPD depends on the cubic power of wind speed, extreme wind-speed values can disproportionately affect the resulting energy-density estimates. A quality-control criterion of VV ≤20 m s^-1 was selected as the main scenario. This threshold was designed to reduce the influence of extreme cubic amplification while preserving the dominant structure of the observational dataset.

After applying this criterion, the final article-level dataset retained 137,484 records, corresponding to 99.7562% of the available records under the selected WPD strategy. Therefore, the quality-control procedure was not an aggressive filtering stage, but a conservative correction aimed at stabilizing the energy-density calculation without altering the main statistical structure of the data.

This decision is particularly important because small changes in high wind-speed values may produce disproportionately large changes in WPD. Consequently, the selected threshold improves the robustness of the physical–statistical characterization while maintaining the representativeness of the regional wind-energy signal.

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

## 4.1 Wind-speed variability as the initial kinematic state

The monthly mean wind-speed series showed that the wind field in Nariño cannot be treated as a spatially homogeneous or temporally stationary signal. Each analytical zone exhibited a different kinematic behavior, reflecting the influence of the complex physiographic setting and the zone-level structure defined in the study area.

**Figure 2. Monthly mean wind speed by analytical zone.**

Zone 1 showed the most pronounced temporal contrast. During 2017–2018, monthly mean wind speed remained generally low, but a marked high-speed interval appeared during 2018–2019, followed by a return to lower values after late 2019. Zones 2 and 3 showed more moderate variability, with monthly wind-speed values concentrated in lower ranges and only isolated peaks. Zone 4 presented a more fragmented temporal record and was therefore interpreted cautiously.

This first layer of analysis defines the kinematic state of the wind system. The differences observed in Figure 2 are physically relevant because wind speed is not linearly transferred into available wind power. Instead, wind power density depends on the cube of wind speed. Therefore, even moderate changes in wind-speed state may become strongly amplified when transformed into WPD.

## 4.2 Wind power density as an energetic state variable

Monthly mean WPD amplified the spatial and temporal contrasts previously observed in wind speed. The global mean WPD after quality control was approximately 53.82 W m^-2, but this value masked strong zonal heterogeneity.

Zone 1 exhibited the highest mean WPD, reaching approximately 140.76 W m^-2. In contrast, Zones 2, 3 and 4 showed substantially lower mean WPD values, approximately 15.82 W m^-2, 12.97 W m^-2 and 16.95 W m^-2, respectively. Thus, mean WPD in Zone 1 was about 8.9 times higher than in Zone 2, 10.9 times higher than in Zone 3 and 8.3 times higher than in Zone 4.

**Figure 3. Monthly mean wind power density by analytical zone.**

The temporal structure of WPD showed that Zone 1 changed from a low-energy state to a short but energetically dominant regime during 2018–2019. This transition was much more evident in WPD than in wind speed, confirming that WPD acts as a more discriminating physical descriptor of wind-energy behavior. Zones 2 and 3 showed lower energetic regimes, although both presented isolated peaks. Zone 4 showed moderate WPD values, but its lower temporal continuity requires caution.

The descriptive statistics confirmed that WPD provides a stronger physical separation among zones than wind speed alone. Although Zone 1 did not have the highest mean wind speed, it exhibited the highest mean WPD. This result is explained by the strong asymmetry of its wind-speed distribution: Zone 1 had a low median wind speed, high standard deviation and an upper tail reaching the quality-control threshold. After the cubic transformation from wind speed to WPD, these intermittent high-speed states produced a disproportionate energetic contribution.

**Table 2. Descriptive statistics of wind speed and wind power density by analytical zone.**

## 4.3 Distribution of kinematic and energetic states

The empirical wind-speed distributions showed that the analytical zones differed not only in central tendency, but also in the probability structure of wind-speed states.

**Figure 4. Wind-speed distribution by analytical zone.**

Zone 1 presented the most asymmetric wind-speed distribution. Most of its records were concentrated at low wind speeds, but the distribution retained a long upper tail reaching values close to the quality-control threshold. This indicates an intermittent kinematic regime in which low-speed states are frequent, while occasional high-speed events remain physically relevant. Zones 2 and 3 exhibited more regular distributions, with moderate central values and shorter upper tails. Zone 4 presented a more compact distribution and a lower extreme range, although its interpretation remains constrained by temporal coverage.

The WPD distributions confirmed the nonlinear amplification of wind-speed variability. Because WPD depends on the cube of wind speed, the upper tail of the wind-speed distribution became energetically decisive.

**Figure 5. Wind power density distribution by analytical zone.**

Zone 1 showed a WPD distribution dominated by low-energy states but with a long high-energy tail, reaching the largest WPD values observed in the study. This indicates that its energetic dominance is not associated with a permanently high-energy condition, but with intermittent events that carry disproportionate energy-density weight. Zones 2 and 3 exhibited more compact WPD distributions with shorter upper tails, whereas Zone 4 showed a narrower energetic range and was interpreted cautiously due to its lower temporal continuity.

Together, Figures 4 and 5 show that the energetic structure of the wind field cannot be inferred from mean wind speed alone. Instead, the full distribution of wind-speed states must be considered, because rare high-speed states may control the energetic response after the cubic transformation into WPD.

## 4.4 Weibull and Rayleigh probabilistic characterization

Weibull and Rayleigh models were fitted to the wind-speed distributions to characterize the probability structure of the wind regimes. The goodness-of-fit results confirmed that Weibull was the best-performing distribution in all analytical zones.

**Figure 6. Weibull and Rayleigh density fits by analytical zone.**

The density-fit comparison showed the strongest contrast in Zone 1. The empirical density was highly concentrated at low wind speeds and extended through a long upper tail. The Rayleigh model shifted excessive probability mass toward intermediate wind speeds and did not adequately represent the asymmetric low-speed concentration. In contrast, the Weibull model better captured the intermittent structure of the zone.

In Zones 2 and 3, Weibull and Rayleigh fits were visually closer, reflecting more regular wind-speed regimes. However, Weibull retained greater flexibility to adjust the empirical shape. Zone 4 showed a compact distribution with local empirical irregularities and was interpreted cautiously.

The cumulative distribution comparison confirmed the density-based interpretation.

**Figure 7. Weibull and Rayleigh cumulative distribution fits by analytical zone.**

In Zone 1, the empirical CDF increased rapidly at low wind speeds, indicating that a large proportion of records belonged to low-speed states. However, the distribution also retained an upper tail associated with intermittent high-speed events. Weibull followed this cumulative structure more closely than Rayleigh, which smoothed the transition between low and intermediate wind speeds.

The estimated Weibull parameters supported this interpretation. Zone 1 presented a shape parameter below one, approximately k = 0.789, confirming a highly asymmetric and intermittent wind-speed regime. In contrast, Zones 2, 3 and 4 showed shape parameters close to or above two, with k ≈ 1.984, k ≈ 2.089 and k ≈ 2.164, respectively. These values indicate more regular wind-speed regimes, closer to a Rayleigh-like structure, although Weibull remained the best-fitting model in all zones.

**Table 3. Weibull and Rayleigh distribution parameters and goodness-of-fit metrics by analytical zone.**

Therefore, Weibull fitting provides a probabilistic characterization of the wind-speed states and supports the interpretation that Zone 1 is governed by an intermittent rather than uniformly high-speed regime.

## 4.5 Temporal memory of the WPD state variable

The daily ACF analysis showed that WPD has a zone-dependent temporal memory structure. Autocorrelation remained positive at short lags in all zones, indicating that daily WPD values are not independent fluctuations.

**Figure 8. Daily autocorrelation function of wind power density by analytical zone.**

Lag-1 autocorrelation was high in all zones, with values of approximately 0.884 in Zone 1, 0.862 in Zone 2, 0.757 in Zone 3 and 0.575 in Zone 4. Zone 1 showed the strongest and most persistent autocorrelation decay, confirming that its energetic regime is not only intermittent in distributional terms, but also temporally structured.

The first lag at which the absolute ACF decreased below 0.2 also differed by zone. Zone 1 did not fall below this threshold within the 90-day lag window, indicating the longest energetic persistence among the analyzed zones. Zone 2 crossed the threshold at lag 54, Zone 3 at lag 22 and Zone 4 at lag 13.

These results show that WPD behaves as a temporally structured physical state variable rather than as an uncorrelated sequence of daily energy-density values. Zone 4 was interpreted cautiously because of its lower temporal coverage.

## 4.6 Spectral-energy signatures of WPD

FFT-based spectral-band analysis revealed that daily WPD has zone-dependent temporal-energy signatures. The spectral decomposition allowed the WPD signal to be evaluated in physically interpretable period bands: 2–10 days, 10–30 days, 30–120 days, 120–365 days and periods longer than 365 days.

**Figure 9. FFT-based spectral-band energy of daily wind power density by analytical zone.**

Zone 1 was dominated by low-frequency variability, with approximately 70.23% of its normalized WPD spectral power concentrated in periods longer than 365 days. This result indicates that the strongest energetic zone is not only characterized by high WPD values and strong temporal persistence, but also by a dominant long-period spectral structure.

Zone 2 showed a more distributed spectrum, with relevant contributions from intermediate and low-frequency bands. Its largest contribution appeared in the 120–365 day band, followed by periods longer than 365 days and the 30–120 day band. Zone 3 presented a more balanced spectral structure, with substantial contributions from short, intra-monthly and seasonal scales. Zone 4 was dominated by the 2–10 day band, suggesting a shorter-period energetic regime, although this result should be interpreted cautiously because of its lower temporal continuity.

**Table 4. Temporal and spectral summary of wind power density by analytical zone.**

Overall, the spectral analysis confirms that WPD regimes in Nariño are not only spatially heterogeneous and temporally persistent, but also spectrally differentiated. In this sense, FFT-based WPD analysis provides a spectral diagnostic of wind-energy variability, identifying dominant temporal-energy modes that characterize each analytical zone.

# 5. Discussion

## 5.1 From complex terrain to wind-energy state characterization

The results show that WPD characterization in complex Andean terrain requires more than an average-based description of wind speed. The physiographic configuration of Nariño, the spatial distribution of IDEAM stations and the analytical zoning define a heterogeneous atmospheric domain where wind behavior changes across space and time. Therefore, the wind field must be interpreted as a set of zone-dependent physical states rather than as a single homogeneous regional signal.

This study organized the analysis through a sequential physical–statistical framework. First, the analytical zones defined the spatial boundary conditions of the system. Second, monthly wind speed described the initial kinematic state of the wind. Third, WPD transformed that kinematic signal into an energetic state variable. Fourth, empirical and fitted distributions characterized the probability structure of wind-speed and WPD states. Fifth, ACF analysis revealed temporal memory. Finally, FFT-based spectral analysis identified dominant temporal-energy modes.

This sequence moves wind-energy assessment from descriptive visualization toward physical state characterization. Rather than treating wind assessment as a collection of independent figures, the workflow connects spatial conditions, nonlinear energy transformation, probability-state structure, temporal persistence and spectral-energy signatures.

## 5.2 Intermittent energetic dominance of Zone 1

The dominant result of the study is the behavior of Zone 1. This zone exhibited the highest mean WPD, the strongest wind-speed asymmetry, the most extreme WPD tail, the lowest Weibull shape parameter, the longest temporal persistence and the strongest low-frequency spectral dominance. The convergence of these independent diagnostics supports the interpretation of Zone 1 as an intermittent but energetically dominant regime.

Importantly, Zone 1 should not be interpreted as a zone with uniformly high wind speed. The descriptive statistics and empirical distributions show that low-speed states are frequent. However, the same zone also presents a long upper tail in wind speed. After transformation into WPD, this tail becomes energetically decisive because of the cubic dependence on velocity. Thus, the energetic dominance of Zone 1 emerges from intermittent high-speed states rather than from a permanently elevated wind-speed condition.

This distinction is central for wind-resource interpretation. A wind-speed-only assessment could underestimate or misrepresent the energetic structure of the region because it would not fully capture how rare high-speed states contribute to WPD. In contrast, the WPD-based approach reveals the nonlinear energy response of the atmospheric flow and allows the identification of zones whose energy signal is controlled by intermittent events.

## 5.3 Probabilistic structure and cumulative state behavior

The Weibull and Rayleigh comparisons showed that the wind-speed regimes require flexible probabilistic characterization. Weibull was selected as the best distribution in all analytical zones, but the physical interpretation of its parameters differed by zone.

In Zone 1, the Weibull shape parameter below one confirmed a highly asymmetric and intermittent wind-speed regime. This result is consistent with the empirical density, the rapid CDF accumulation at low wind speeds and the long upper tail. In Zones 2–4, shape parameters close to or above two indicated more regular wind-speed behavior, closer to a Rayleigh-like regime, although Weibull remained preferable because it better represented zone-specific distributional forms.

The probabilistic results are not only statistical descriptors. They provide a bridge between the kinematic state of the wind and the energetic response observed in WPD. In particular, the upper tail of the wind-speed distribution becomes physically important because it is amplified by the WPD equation. Therefore, probability-state analysis is necessary to understand why a zone with frequent low-speed records can still dominate the regional WPD structure.

## 5.4 Temporal memory and spectral-energy modes

The ACF results demonstrated that daily WPD is temporally structured. Zone 1 and Zone 2 showed the strongest lag-1 autocorrelation, while Zone 1 maintained persistence across the 90-day window considered in the analysis. This indicates that WPD does not behave as a set of independent daily fluctuations. Instead, it expresses zone-specific memory, where energetic states may persist over characteristic time scales.

This temporal memory is important because it links physical characterization with future forecasting-oriented analysis. The present study does not claim to validate a predictive model, but the persistence detected in daily WPD indicates that the energetic state variable contains temporal structure that may support future forecasting and uncertainty modeling.

The FFT results provided the final layer of characterization. While the distributional analysis described the probability structure of wind-speed and WPD states, and the ACF described temporal memory, the FFT identified the dominant temporal scales through which the energetic signal is organized. Zone 1 was dominated by low-frequency WPD variability, with most of its spectral power concentrated at periods longer than 365 days. Zone 2 combined intermediate and low-frequency components, Zone 3 distributed its energy across several bands, and Zone 4 was dominated by shorter-period variability, although this result must be interpreted cautiously due to lower temporal coverage.

Analogous to how spectral methods identify characteristic signatures of physical systems, the FFT-based WPD analysis identifies dominant temporal-energy modes of wind variability in complex terrain. This interpretation strengthens the methodological contribution of the study because it moves wind-resource assessment from average-based description toward state, memory and spectral characterization.

## 5.5 Methodological contribution

The methodological contribution of this study is the integration of air-density-supported WPD estimation, conservative quality control, distributional fitting, temporal-dependence analysis, spectral-band decomposition and reproducible computational documentation within a single physical–statistical workflow.

The key contribution is not only the calculation of WPD, but the interpretation of WPD as a physical state variable. In this framework, WPD connects atmospheric density, wind-speed variability, energetic amplification, probability structure, temporal persistence and spectral organization. This provides a more complete characterization of wind-energy regimes than wind-speed averages alone.

The framework is especially relevant for complex terrain because spatial heterogeneity can produce regimes that differ not only in magnitude, but also in distributional shape, memory and dominant temporal scales. Therefore, the approach can support future studies focused on forecasting, uncertainty quantification, regional energy planning and more detailed micrositing analysis.

## 5.6 Implications and limitations

The results suggest that WPD-based characterization is useful for identifying regional wind-energy regimes in complex Andean terrain. In Nariño, the most relevant result is the identification of a spatially localized, intermittent and spectrally differentiated energetic regime in Zone 1. However, this finding should be interpreted as regional physical–statistical evidence, not as a direct demonstration of turbine-level feasibility or commercial wind-farm viability.

This study does not perform hub-height extrapolation, turbine power-curve modeling, micrositing analysis, CFD simulation, economic feasibility analysis or grid-integration assessment. These elements are required before operational or investment decisions can be made.

The use of daily zone-level air density was a practical strategy under limited hourly overlap among wind speed, pressure and temperature records. Although this strategy preserves physically meaningful density variation and improves record retention, it does not replace fully synchronized high-resolution meteorological observations. Zone 4 results should also be interpreted cautiously because of lower temporal continuity and limited data availability for some time-series analyses.

Future work should extend this framework by incorporating turbine-specific power curves, vertical wind extrapolation, high-resolution terrain modeling, mesoscale atmospheric simulations, forecasting models and uncertainty quantification. These developments would allow the physical–statistical characterization presented here to evolve toward operational wind-energy assessment under complex-terrain conditions.

# 6. Conclusions

This study presented a physical–statistical and spectral characterization of wind power density in Nariño, Colombia, using multi-station meteorological observations grouped into four analytical zones. The proposed workflow characterized WPD not only as an energy indicator, but as a physical state variable shaped by spatial boundary conditions, nonlinear wind-speed transformation, probability-state structure, temporal memory and spectral-energy organization.

The main conclusions are:

1. WPD provided a stronger physical descriptor of wind-energy behavior than wind speed alone. Because WPD depends on air density and the cube of wind speed, moderate differences in wind-speed states were transformed into stronger energetic contrasts among analytical zones.

2. Zone 1 was identified as the dominant energetic regime in the study area. However, this dominance was not produced by uniformly high wind speed. Instead, it emerged from an intermittent structure characterized by frequent low-speed states, a long high-speed tail and strong cubic amplification in WPD.

3. The empirical wind-speed and WPD distributions showed that regional wind-energy characterization cannot rely only on central tendency. The energetic response was controlled by the full distribution of states, especially the upper tail of wind speed, which became decisive after transformation into WPD.

4. Weibull fitting provided the most appropriate probabilistic characterization of wind-speed regimes in all analytical zones. The shape parameter below one in Zone 1 confirmed a highly asymmetric and intermittent regime, while Zones 2–4 showed more regular behavior with shape parameters close to or above two.

5. Daily WPD exhibited zone-dependent temporal memory. The strongest persistence occurred in Zone 1, where autocorrelation did not fall below the selected threshold within the 90-day lag window. This indicates that WPD behaves as a temporally structured physical signal rather than as a sequence of independent daily fluctuations.

6. FFT-based spectral-band analysis revealed distinct temporal-energy signatures across zones. Zone 1 was dominated by low-frequency variability, Zone 2 showed mixed intermediate-to-low-frequency behavior, Zone 3 presented a more balanced spectral structure and Zone 4 was dominated by shorter-period variability, although the latter must be interpreted cautiously due to lower temporal continuity.

7. The combined analysis of spatial conditions, WPD transformation, probability structure, temporal persistence and spectral-energy modes provides a reproducible framework for wind-energy characterization in complex Andean terrain.

Overall, the results demonstrate that WPD-based characterization can move wind-resource assessment beyond average-based description toward a more complete physical interpretation of wind-energy regimes. The study does not establish turbine-level feasibility or commercial wind-farm viability; rather, it provides regional physical–statistical evidence that can support future forecasting, uncertainty analysis, terrain-specific modeling and energy-planning studies.

# Data availability statement

The meteorological records used in this study were obtained from IDEAM, the official meteorological and hydrological data source in Colombia. Due to source-data redistribution considerations, the raw observational dataset is not redistributed in this repository. The scripts, derived summary outputs, figures, tables and reproducibility documentation supporting the results of this study are available in the associated GitHub repository. Access to the original raw meteorological records should be requested or downloaded from the official IDEAM data platform (IDEAM, 2024).

# CRediT author statement

Favio Nicolás Rosero Rodríguez: Conceptualization, Methodology, Software, Validation, Formal analysis, Investigation, Data curation, Visualization, Writing – original draft, Writing – review and editing.

Nini Valentina Naranjo Castaño: Methodology, Validation, Formal analysis, Writing – review and editing.

Javier Mauricio López Moreno: Software, Data curation, Validation, Visualization, Writing – review and editing.

Elisabeth Restrepo Parra: Conceptualization, Methodology, Supervision, Project administration, Writing – review and editing.

Juan Carlos Riaño Rojas: Methodology, Validation, Supervision, Writing – review and editing.

Sonia Graciela Rosero Rodríguez: Resources, Writing – review and editing.


# Declaration of competing interest

The authors declare that they have no known competing financial interests or personal relationships that could have appeared to influence the work reported in this paper.

# Funding statement

This research did not receive any specific grant from funding agencies in the public, commercial, or not-for-profit sectors.

# Declaration of generative AI and AI-assisted technologies

During the preparation of this work, the corresponding author used ChatGPT as an AI-assisted tool to support manuscript organization, editorial planning, language refinement and code-review discussion. All scientific analyses, data processing, statistical calculations, figures and tables were generated from the author-controlled research workflow in R. After using this tool, all authors reviewed, edited and verified the content as needed and take full responsibility for the content of the manuscript.

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

# Supplementary Methods — Article 01 Energy Reports

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  
**Author:** Favio Nicolás Rosero Rodríguez

---

## Purpose

This supplementary methods file documents the computational and methodological workflow used to support the reproducibility of Article 01.

The workflow includes:

1. datetime validation;
2. air-density strategy selection;
3. wind power density calculation;
4. quality control;
5. Weibull/Rayleigh distribution fitting;
6. temporal-dependence analysis;
7. FFT-based spectral analysis;
8. final study-area map generation.

---

## Data structure

The analysis was based on meteorological records from IDEAM stations located in Nariño, Colombia, for the period 2017–2022.

The main variables used in the article workflow were:

```text
VV  — wind speed
TM  — mean temperature
PA  — atmospheric pressure
HR  — relative humidity
DV  — wind direction
PR  — precipitation
NU  — cloudiness
EV  — evaporation
```

The final article-level WPD analysis was performed using quality-controlled wind-speed records and a daily zone-level air-density strategy.

---

## Analytical zoning

The IDEAM meteorological stations were grouped into four analytical zones according to their geographic and physiographic distribution within Nariño.

These zones were used to:

```text
1. reduce spatial heterogeneity;
2. support regional physical interpretation;
3. compare wind power density behavior by zone;
4. evaluate distributional, temporal and spectral differences.
```

The analytical zones are not administrative or official territorial boundaries. They represent station groupings defined for the physical–statistical assessment of wind power density.

---

## Datetime validation

Datetime validation was performed before the WPD calculation to ensure temporal consistency in the 2017–2022 article-period dataset.

This step was implemented in:

```text
00C_datetime_parser_validation.R
```

The purpose of this step was to compare candidate datetime parsers and select the parser that produced the most consistent temporal structure for the meteorological records.

---

## Air-density strategy

Wind power density depends on air density. However, complete hourly overlap among all variables required for exact air-density estimation was limited.

Therefore, several air-density strategies were evaluated:

```text
hourly observed density
daily zone-level density
monthly zone-level density
overall zone-level density
standard air density
```

The selected strategy for the article was:

```text
daily zone-level air density
```

This strategy provided a balance between physical consistency and data coverage.

This step was implemented in:

```text
01D_density_overlap_strategy.R
```

---

## Wind power density calculation

Wind power density was calculated as:

```text
WPD = 0.5 × rho × v^3
```

where:

```text
WPD  — wind power density
rho  — air density
v    — wind speed
```

The cubic dependence on wind speed makes WPD highly sensitive to extreme wind-speed values. For this reason, quality control was applied before the final descriptive, distributional and spectral analyses.

---

## Quality control

The final quality-control criterion applied to wind speed was:

```text
VV <= 20 m s^-1
```

This criterion was used to reduce the influence of anomalous or physically inconsistent extreme values while preserving the main wind-speed structure of the dataset.

This step was implemented in:

```text
02E_quality_control_daily_density_wpd.R
```

The final article-level quality-controlled dataset contains:

```text
137,484 records
```

---

## Distribution fitting

Wind-speed distributions were evaluated using Weibull and Rayleigh models.

The distributional analysis was performed by analytical zone.

The objective was to identify which theoretical distribution better represented the empirical wind-speed behavior in each zone.

This step was implemented in:

```text
03F_weibull_rayleigh_distribution_fitting.R
05H_distribution_and_publication_figures.R
```

The final distributional comparison showed that the Weibull distribution provided the best fit across the analytical zones.

---

## Temporal-dependence analysis

Temporal dependence was evaluated using:

```text
ACF   — autocorrelation function
PACF  — partial autocorrelation function
```

The analysis was performed using daily WPD and wind-speed series by analytical zone.

This step supported the identification of persistence structures and temporal memory in the wind-energy signal.

This step was implemented in:

```text
06I_acf_pacf_temporal_dependence.R
```

---

## Spectral analysis

Spectral behavior was evaluated using FFT-based analysis on the longest continuous daily segment available for each analytical zone.

The spectral analysis supported the identification of dominant periodic components and spectral-energy bands in daily WPD.

This step was implemented in:

```text
07J_fft_spectral_analysis.R
```

The main spectral result used in the article is the WPD spectral-band energy by analytical zone.

---

## Physiographic map

The final study-area map includes:

```text
Nariño, Colombia
topographic relief
municipal boundaries
Pacific context
IDEAM meteorological stations
analytical zones
station labels S01–S16
```

This step was implemented in:

```text
13_final_map_article_ready.R
```

The station labels used in Figure 1 are documented in:

```text
Table_S01_station_key_for_Figure_1.csv
```

The analytical-zone station summary is documented in:

```text
Table_S02_zone_station_summary_for_Figure_1.csv
```

---

## Reproducibility chain

The complete computational workflow follows this chain:

```text
00C_datetime_parser_validation.R
        ↓
01D_density_overlap_strategy.R
        ↓
02E_quality_control_daily_density_wpd.R
        ↓
03F_weibull_rayleigh_distribution_fitting.R
        ↓
04G_publication_ready_figures_article1.R
        ↓
05H_distribution_and_publication_figures.R
        ↓
06I_acf_pacf_temporal_dependence.R
        ↓
07J_fft_spectral_analysis.R
        ↓
13_final_map_article_ready.R
```

---

## Traceability rule

Each manuscript claim should be traceable through the following chain:

```text
Script
↓
Output file
↓
Figure or table
↓
Result statement
↓
Manuscript section
```

---

## Software environment

The main R packages used across the workflow include:

```text
data.table
dplyr
lubridate
stringr
ggplot2
scales
zoo
fitdistrplus
moments
openxlsx
sf
terra
geodata
ggrepel
ggspatial
patchwork
ggnewscale
stats
utils
```

The final software environment should be documented in:

```text
08_reproducibility/software_versions.md
08_reproducibility/session_info.txt
```

---

## Final note

The supplementary methods are intended to support transparency, reproducibility and editorial review. They complement the main manuscript without replacing the methodological description included in the article text.

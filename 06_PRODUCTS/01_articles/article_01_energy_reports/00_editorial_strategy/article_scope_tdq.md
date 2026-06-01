# Article Scope TDQ — Article 01 Energy Reports

## Purpose

This document defines the scientific and editorial scope of Article 01.

The objective is to prevent dispersion, avoid unnecessary additional analyses and keep the manuscript aligned with the target journal, the available evidence and the submission strategy.

---

## Provisional title

Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

---

## Target journal

Energy Reports

---

## Article type

Research Article.

---

## Current phase

Manuscript construction and repository consolidation.

---

## Central research focus

This article characterizes Wind Power Density (WPD) in complex Andean terrain using multi-station meteorological observations from Nariño, Colombia.

The study combines:

1. physically based WPD estimation;
2. quality-controlled wind-speed records;
3. daily zone-level air-density estimation;
4. distributional analysis using Weibull and Rayleigh models;
5. temporal dependence analysis using ACF/PACF;
6. spectral analysis using FFT;
7. physical interpretation of zonal wind-energy regimes.

---

## Main scientific question

How does wind power density vary across analytical zones in complex Andean terrain, and what distributional, temporal and spectral structures characterize its behavior?

---

## Secondary questions

1. Which analytical zone shows the strongest wind-energy potential?
2. Does Weibull or Rayleigh better describe wind-speed behavior by zone?
3. Does daily WPD show temporal persistence?
4. Which temporal bands dominate the WPD spectral structure?
5. What methodological value does daily zone-level air density provide for WPD estimation when exact hourly overlap is limited?

---

## Main contribution

The article contributes a physical–statistical framework for characterizing WPD in a complex Andean region using observational meteorological data.

The contribution is not limited to descriptive wind-speed statistics. It integrates air-density-supported WPD estimation, distributional modeling, temporal persistence and spectral structure to characterize wind-energy regimes by analytical zone.

---

## Main novelty

The novelty of the article is based on the integration of five elements:

1. regional WPD estimation in complex Andean terrain;
2. air-density-supported WPD calculation under limited hourly variable overlap;
3. zonal physical–statistical comparison of wind-energy regimes;
4. distributional characterization using Weibull and Rayleigh models;
5. temporal and spectral interpretation of WPD dynamics.

---

## What the article includes

The article includes:

- corrected datetime validation;
- study-period validation;
- analytical zoning of meteorological stations;
- air-density estimation;
- WPD calculation;
- quality-control analysis;
- descriptive statistics of wind speed and WPD;
- Weibull and Rayleigh distribution fitting;
- ACF/PACF temporal dependence;
- FFT spectral analysis;
- publication-ready figures;
- editable tables;
- reproducibility documentation;
- Energy Reports compliance documentation.

---

## What the article does not include

The article does not include:

- turbine-specific energy production modeling;
- micrositing analysis;
- wind-farm design;
- CFD simulation;
- mesoscale atmospheric modeling;
- economic feasibility analysis;
- grid integration modeling;
- final predictive forecasting models;
- TDQ as a theoretical framework in the main scientific argument.

---

## TDQ control decision

TDQ is used here as an internal organization and decision-control method, not as the central theoretical framework of the Energy Reports article.

The submitted article should remain focused on:

```text
Wind power density
Physical-statistical characterization
Complex terrain
Meteorological data
Distributional, temporal and spectral analysis
```

The broader TDQ framework can be reserved for future products such as:

- theoretical article;
- book chapter;
- research program;
- methodological essay;
- decision-support model.

---

## Core manuscript narrative

The manuscript should follow this scientific narrative:

```text
Nariño is a complex Andean region.
        ↓
Wind-energy potential cannot be characterized only with average wind speed.
        ↓
Wind power density provides a physically stronger energy descriptor.
        ↓
Air density must be incorporated using available pressure and temperature data.
        ↓
Daily zone-level density provides a practical and physically meaningful strategy.
        ↓
Quality control removes extreme cubic distortions while preserving most records.
        ↓
WPD differs strongly among analytical zones.
        ↓
Weibull better describes wind-speed behavior than Rayleigh in all zones.
        ↓
ACF/PACF reveal temporal persistence in WPD.
        ↓
FFT reveals distinct temporal-energy regimes.
        ↓
The study provides a reproducible physical-statistical framework for wind-energy assessment in complex Andean terrain.
```

---

## Main results to protect

The following results form the backbone of the article:

1. Daily zone-level density is the selected WPD strategy.
2. The main QC scenario is VV <= 20 m s^-1.
3. The final WPD dataset retains nearly all records after QC.
4. Zone 1 shows the strongest WPD regime.
5. Weibull outperforms Rayleigh in all analytical zones.
6. Zone 1 shows strong intermittency and energetic episodes.
7. Daily WPD has relevant temporal persistence.
8. Spectral analysis shows distinct temporal-energy regimes by zone.

---

## Main figures

The main manuscript should include the following figures:

1. Monthly mean wind speed by analytical zone.
2. Monthly mean WPD by analytical zone.
3. Wind-speed distribution by analytical zone.
4. WPD distribution by analytical zone.
5. Weibull/Rayleigh density fits.
6. Weibull/Rayleigh CDF fits.
7. Daily WPD ACF by analytical zone.
8. WPD spectral band energy by analytical zone.

---

## Supplementary figures

The supplementary material should include:

1. QC sensitivity of mean WPD.
2. Delta AIC/BIC Weibull vs Rayleigh.
3. Daily WPD PACF by analytical zone.
4. Daily VV ACF/PACF support.
5. Raw FFT spectrum support.

---

## Main tables

The main manuscript should include:

1. Dataset, stations, zones and temporal coverage.
2. Descriptive statistics of VV and WPD by zone.
3. Weibull/Rayleigh parameters and goodness-of-fit metrics.
4. Temporal and spectral summary by zone.

---

## Supplementary tables

The supplementary material should include:

1. quality-control scenario comparison;
2. full Weibull/Rayleigh fitting metrics;
3. ACF/PACF values by lag and zone;
4. FFT top periods by zone and variable;
5. FFT spectral-band energy by zone and variable.

---

## Target reader

The target reader includes:

- renewable energy researchers;
- wind-energy analysts;
- applied physicists;
- environmental data scientists;
- energy planners;
- researchers working with complex terrain;
- researchers working with meteorological observational data.

---

## Expected reviewer concerns

| Reviewer concern | Planned response |
|---|---|
| Why use WPD instead of only wind speed? | WPD incorporates the cubic dependence of wind speed and air-density effects, making it more physically linked to wind-energy potential. |
| Why daily zone-level air density? | Exact hourly overlap among wind speed, pressure and temperature is limited; daily zone-level density preserves physical dependence while retaining more useful records. |
| Why use VV <= 20 m s^-1 as QC? | It removes a small fraction of extreme values that disproportionately distort WPD through cubic amplification while retaining the dominant dataset structure. |
| Why Weibull and Rayleigh? | They are standard distributions for wind-speed characterization; Weibull provides flexibility, while Rayleigh acts as a constrained reference model. |
| Why include ACF/PACF? | Temporal dependence helps determine whether WPD behaves as independent noise or as a persistent physical process. |
| Why include FFT? | FFT identifies dominant period bands and supports physical interpretation of temporal-energy regimes. |
| Why not include forecasting models? | This article is focused on characterization; forecasting models can be developed as a separate manuscript. |
| Why not include turbine-level analysis? | The article evaluates regional WPD regimes, not site-specific turbine production. |
| Why not use TDQ as the main theory? | TDQ is used as an internal organization method; the article remains focused on physical-statistical wind-energy characterization. |

---

## Editorial position

This article should be presented as:

```text
A reproducible physical-statistical characterization of wind power density in complex Andean terrain.
```

It should not be presented as:

```text
A complete wind-farm feasibility study.
A turbine-level production study.
A final predictive modeling paper.
A TDQ theoretical paper.
```

---

## Manuscript structure

The proposed manuscript structure is:

```text
Title

Highlights

Abstract

Keywords

1. Introduction
   1.1 Wind-energy assessment in complex terrain
   1.2 Wind power density as a physical descriptor
   1.3 Research gap in Andean meteorological contexts
   1.4 Contribution of this study

2. Study area and meteorological data
   2.1 Study region
   2.2 Meteorological stations and analytical zoning
   2.3 Variables and observational period
   2.4 Datetime validation and preprocessing

3. Methodology
   3.1 Air density and wind power density formulation
   3.2 Daily zone-level density strategy
   3.3 Quality-control criterion
   3.4 Distributional fitting: Weibull and Rayleigh
   3.5 Temporal dependence: ACF and PACF
   3.6 Spectral analysis: FFT and period bands

4. Results
   4.1 Wind speed and WPD variability
   4.2 Zonal contrast in wind-energy potential
   4.3 Weibull and Rayleigh fitting
   4.4 Temporal persistence of WPD
   4.5 Spectral structure of WPD

5. Discussion
   5.1 Physical interpretation of Zone 1 dominance
   5.2 Implications for wind-energy assessment in complex Andean terrain
   5.3 Methodological contribution
   5.4 Limitations

6. Conclusions

Data availability statement

CRediT author statement

Declaration of competing interest

Funding statement

Declaration of generative AI and AI-assisted technologies

References
```

---

## Immediate manuscript objective

The immediate objective is to build:

```text
Title
Highlights
Abstract
Keywords
Methods
Results
Discussion
Conclusions
Declarations
Submission package
```

from the evidence already generated.

---

## Final TDQ rule

No additional analysis should be added unless it directly improves one of the following:

1. reviewer defensibility;
2. Energy Reports compliance;
3. reproducibility;
4. clarity of the main scientific contribution.

Otherwise, the priority is manuscript writing and submission preparation.

---

## Current scope decision

```text
Scope status: defined
Scientific core: closed
Additional analyses: frozen unless required
Priority: repository consolidation and manuscript writing
```

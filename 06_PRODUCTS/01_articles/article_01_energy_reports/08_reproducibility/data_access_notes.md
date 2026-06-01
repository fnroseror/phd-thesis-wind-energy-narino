# Data Access Notes — Article 01 Energy Reports

## Purpose

This file documents the data-access strategy for Article 01.

The objective is to clarify the origin of the meteorological records, the role of derived datasets and the limits of raw-data redistribution.

---

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  
**Current phase:** Manuscript construction and repository consolidation  

---

## Data origin

The meteorological records used in this study were obtained from IDEAM, the official meteorological and hydrological data source in Colombia.

The records correspond to meteorological stations located in the department of Nariño, Colombia, and were grouped into analytical zones for regional wind-energy characterization.

---

## Study region

The study focuses on Nariño, Colombia, a complex Andean region characterized by strong topographic variability, altitudinal gradients and heterogeneous atmospheric conditions.

This regional complexity motivates the use of a physical–statistical approach rather than a simple wind-speed-only characterization.

---

## Data period

The corrected observational period used for Article 01 is:

```text
2017–2022
```

The datetime validation process confirmed that the correct date structure follows the DMY format.

---

## Main meteorological variables

The article uses the following variables:

| Variable | Description | Role in the article |
|---|---|---|
| VV | Wind speed | Main input for WPD calculation |
| PA | Atmospheric pressure | Air-density estimation |
| TM / temperature variables | Air temperature | Air-density estimation |
| rho | Air density | Physical correction for WPD |
| WPD | Wind Power Density | Main energy variable |
| Zone | Analytical zone | Spatial grouping for comparison |
| Date/time | Temporal reference | Temporal, ACF/PACF and FFT analyses |

---

## Main derived variable

Wind Power Density is computed as:

```text
WPD = 0.5 * rho * v^3
```

where:

```text
WPD = wind power density
rho = air density
v = wind speed
```

The use of WPD is physically justified because wind-energy potential depends on the cubic power of wind speed and on local air density.

---

## Air-density strategy

Exact hourly overlap among wind speed, pressure and temperature records was limited. Therefore, different air-density strategies were evaluated.

The selected strategy for Article 01 is:

```text
Daily zone-level air density
```

This strategy preserves the physical dependence of WPD on air density while retaining a larger proportion of useful wind-speed records.

---

## Quality-control strategy

The main quality-control criterion selected for the article is:

```text
VV <= 20 m s^-1
```

This criterion removes a small fraction of extreme wind-speed values that can disproportionately distort WPD through cubic amplification.

The final article-level dataset after quality control is:

```text
02E_article_main_wpd_dataset_after_qc.rds
```

---

## Raw data redistribution

Raw IDEAM data are not redistributed in this repository unless their redistribution is explicitly permitted by the source-data conditions.

This decision is based on scientific and ethical reproducibility control:

1. avoid unauthorized redistribution of third-party observational records;
2. preserve traceability to the official data provider;
3. allow reproducibility through scripts, derived outputs and documented processing steps;
4. protect the repository from including files with uncertain redistribution status.

---

## Repository data strategy

This repository prioritizes:

- reproducible scripts;
- derived outputs;
- methodological documentation;
- statistical tables;
- publication-ready figures;
- manuscript evidence files;
- editorial compliance documentation.

The repository does not aim to replace the official data source.

---

## Reproducibility strategy

The repository is designed to allow external readers to understand and reproduce the workflow if they have access to the raw IDEAM records or to permitted derived datasets.

The reproducibility chain is:

```text
Raw IDEAM data
        ↓
Datetime validation
        ↓
Density strategy selection
        ↓
WPD calculation
        ↓
Quality control
        ↓
Final article-level dataset
        ↓
Figures and tables
        ↓
Manuscript
```

---

## Derived outputs

Derived outputs generated from the analytical workflow include:

- final WPD dataset after QC;
- density strategy comparison;
- descriptive statistics;
- Weibull/Rayleigh fitting metrics;
- temporal-dependence summaries;
- spectral-analysis summaries;
- publication-ready figures;
- manuscript tables;
- supplementary tables.

---

## Files that may be shared safely

The following files can generally be included in the repository:

```text
R scripts
Markdown documentation
README files
Figure files generated from analysis
Summary tables
Model-comparison tables
Figure captions
Submission checklists
Declaration drafts
Data access notes
```

---

## Files that require caution before sharing

The following files should not be uploaded unless redistribution permission is clear:

```text
Raw IDEAM observational data
Full station-level raw records
Large intermediate datasets derived directly from raw records
Files containing restricted or non-public metadata
Any dataset whose redistribution status is uncertain
```

---

## Minimum reproducibility package

If raw data redistribution is not allowed, the minimum reproducibility package should include:

```text
1. Scripts
2. Derived summary tables
3. Figures
4. Methodological documentation
5. Data access notes
6. Data availability statement
7. Execution order
8. Software versions
9. Session information
```

---

## Data availability statement draft

The meteorological records used in this study were obtained from the official IDEAM meteorological data source. Due to source-data redistribution considerations, the raw observational dataset is not redistributed in this repository. All scripts used to process the data, generate derived outputs, compute the statistical and spectral analyses, and reproduce the tables and figures are provided in the article repository. Access to the original raw meteorological observations should be requested or downloaded from the official IDEAM data platform.

---

## Pending decisions before submission

Before submission, the following points must be confirmed:

- whether raw IDEAM data can be redistributed publicly;
- whether derived article-level datasets can be uploaded;
- whether summary-only derived tables are sufficient;
- whether a Zenodo or institutional repository deposit is required;
- whether the final GitHub repository should include only scripts, figures and derived tables;
- whether the journal requires a specific data repository link.

---

## Recommended repository decision

For the first submission version, the safest approach is:

```text
Do not upload raw IDEAM data.
Upload scripts, figures, summary tables and documentation.
Explain raw data access through IDEAM in the Data Availability Statement.
```

This keeps the article reproducible in logic and transparent in method while avoiding redistribution risks.

---

## TDQ data rule

Do not upload raw data if redistribution conditions are uncertain.

The safe evidence chain is:

```text
Official source acknowledged
        ↓
Processing scripts documented
        ↓
Derived outputs provided
        ↓
Figures and tables reproducible
        ↓
Data availability statement included
```

---

## Current status

```text
Raw data source: identified
Raw data redistribution: pending confirmation
Derived outputs: generated
Scripts: generated
Figures: generated
Tables: generated
Data availability statement: draft created
Repository data strategy: defined
```

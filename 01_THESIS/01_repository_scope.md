# Repository Scope

## Purpose

This repository preserves the computational, analytical, documentary, and validation support associated with the doctoral thesis:

**Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas**  
**Author:** Favio Nicolás Rosero Rodríguez  
**Program:** Doctorado en Ciencias - Física  
**Institution:** Universidad Nacional de Colombia, Sede Manizales  
**Year:** 2026

Its purpose is to provide a navigable and auditable connection between the dissertation, canonical outputs, source code, figures, tables, appendices, and reproducibility evidence.

## Frozen scientific scope

The dissertation has been corrected and submitted, and the final response letters to the jurors have been closed. The scientific content is therefore frozen.

Repository maintenance must not:

- recalculate or replace approved results;
- modify reported figures, metrics, conclusions, or methodological decisions;
- reinterpret complementary analyses as substitutes for the approved historical outputs;
- transform internal workflow labels into universal physical claims;
- present the repository as evidence of wind-farm feasibility or actual electricity generation.

A change to scientific content is permitted only if a demonstrable contradiction is identified and formally documented.

## Canonical observational and analytical scope

The repository must preserve the following thesis-level constants:

- 8,175,686 raw meteorological records;
- 2,218,605 valid wind-speed records after initial control;
- 365,512 analytical station-hour wind-speed/WPD records;
- 16 IDEAM meteorological stations;
- four analytical zones;
- nominal observational period 2017-2022;
- effective availability through 1 July 2022;
- hourly prediction horizons `h = 1, 12, 72`;
- a methodologically separate quarterly stage beginning at 2022-Q3 for the central annual scenario 2023-2028.

## Scientific interpretation rules

### Wind Power Density

Wind Power Density (WPD) is the principal physical variable:

`WPD(t) = 0.5 * rho(t) * v(t)^3`

It represents available wind power per unit area. It does not represent the electrical output of a specific turbine or wind farm.

### TDQ-PIESS/KFAS

TDQ-PIESS/KFAS is an operational physical-statistical framework used in the approved predictive pipeline. It is not presented as a universal physical theory.

### Internal state index

`I_TDQ` is an internal causal state variable of the hourly pipeline. It is not equivalent to FNRR.

### Regional irregularity

FNRR is a regional structural descriptor based on the median and 90th percentile of WPD within the temporal aggregation defined in the thesis. It is not a universal constant and does not replace predictive uncertainty or residual validation.

### Energy indicators

`E_free` is an annualized indicator of integrated WPD per unit area before structural modulation.

`E_usable` is an annualized indicator structurally modulated by `1 - FNRR`.

These quantities must not be interpreted as:

- actual electricity generation;
- thermodynamic free energy;
- firm or technically guaranteed energy;
- a wind-farm production forecast.

### Multiyear scenario

The 2023-2028 scenario is generated through a quarterly stage that is methodologically separate from the hourly `h = 1, 12, 72` forecasting pipeline. It is a conditioned regional scenario, not a direct extension of the hourly forecasts and not a guaranteed generation trajectory.

## Included repository layers

The repository may include:

- data metadata and access instructions;
- preprocessing and quality-control code;
- physical-statistical characterization;
- candidate predictive models and the approved final integration;
- deterministic, residual, and probabilistic evaluation;
- FNRR and regional energy-indicator outputs;
- canonical figures and tables;
- complementary robustness analyses clearly separated from approved outputs;
- reproducibility documentation, manifests, hashes, and validation logs;
- derived academic products separated from the doctoral evidence layer.

## Excluded or restricted material

The public repository must exclude:

- raw institutional data when redistribution is not authorized or technically appropriate;
- credentials, API keys, personal identifiers, private correspondence, and sensitive metadata;
- temporary files, caches, `.Rhistory`, unnecessary `.RData`, editor backups, and local absolute paths;
- superseded outputs mixed with canonical results;
- editable working documents that are not required for verification;
- the full thesis PDF until institutional similarity analysis is confirmed as complete.

## Reproducibility boundary

The repository supports reproducibility within the declared data-access, software, and historical-execution constraints. Reproducibility means that the documented pipeline, canonical inputs, approved outputs, manifests, and checks can be inspected and validated. It does not imply that all raw institutional data are redistributed or that every historical model can be retrained identically on arbitrary hardware without the documented environment.

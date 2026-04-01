# Data Availability

## Purpose

This document explains the availability status of the observational data used in the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

Its purpose is to clarify:

- which types of data are part of the doctoral workflow,
- which data structures are represented in the repository,
- which materials may not be distributed in full public form,
- and how reproducibility is preserved despite those practical limitations.

---

## General availability statement

The doctoral research is based on an observational meteorological system composed of approximately **8 million hourly records** corresponding to the period **2017–2022**, obtained from **16 meteorological stations** and grouped into **four representative geographic zones** in the department of **Nariño, Colombia**.

These observations constitute the empirical foundation of the physical characterization, predictive modeling, uncertainty quantification, and energetic interpretation developed throughout the thesis.

However, the repository should not be interpreted as a raw public dump of every original observational file. Its role is broader and more rigorous: it is a **reproducible scientific support environment** for the doctoral framework.

---

## What is conceptually available in the doctoral system

The thesis makes clear that the full scientific system includes:

- the zonally consolidated observational basis,
- preprocessing logic,
- generation of derived physical variables,
- classical forecasting pipelines,
- machine learning pipelines,
- deep learning pipelines,
- TDQ–PIESS implementation,
- FNRR computation,
- PI90 calibration,
- energetic projection up to 2028,
- experimental configurations,
- performance metrics,
- training curves,
- and extended outputs required for computational reproducibility.

This means that the doctoral data ecosystem is larger than a single folder of raw measurements. It includes both observational and computational layers.

---

## What is expected to be available in the repository

The repository is expected to contain, in structured form:

### 1. Metadata and observational descriptions
- variable definitions,
- station-to-zone mapping,
- dataset overview,
- processing notes,
- data availability notes.

### 2. Processed analytical structures
- zonal data organization,
- curated analysis-ready data representations,
- derived physical variables required by the thesis workflow.

### 3. Reproducibility material
- preprocessing scripts,
- model pipelines,
- evaluation outputs,
- uncertainty-calibration artifacts,
- supplementary tables and figures,
- and extended technical support files.

The repository is therefore designed to make the doctoral process understandable, auditable, and reproducible at the methodological level.

---

## What may not be fully available in public form

For scientific, technical, and platform-related reasons, the repository may not include the complete original raw database in unrestricted form.

The following materials may be absent or only partially represented:

- full raw station-by-station source files in their original operational format,
- very large intermediate files exceeding practical GitHub storage limits,
- temporary local working files,
- exploratory drafts not belonging to the validated doctoral workflow,
- redundant copies of raw observational exports,
- and non-curated auxiliary files generated during experimentation.

This is not a limitation of scientific scope, but a practical decision to preserve repository clarity, traceability, and usability.

---

## Why full raw publication is not required for coherence

The scientific coherence of the thesis does not depend on uploading every raw source file into the public repository.

What the thesis requires is that the repository preserve the elements necessary to understand and reproduce the doctoral workflow, namely:

- the structure of the observational system,
- the logic of preprocessing,
- the construction of derived variables,
- the predictive and probabilistic pipeline,
- the regional organization by zone,
- and the outputs supporting the reported results.

For this reason, reproducibility is preserved through **documented structure + executable logic + structured outputs**, not only through raw data exposure.

---

## Variable-level availability is heterogeneous

The observational system used in the thesis is multivariable, and the number of downloaded records is not uniform across variables.

The recorded counts are:

| Variable | Number of downloaded records |
|---|---:|
| Velocidad de Viento | 2,218,605 |
| Dirección de Viento | 2,210,920 |
| Fenómeno Atmosférico | 21,018 |
| Presión Atmosférica | 280,741 |
| Precipitación | 1,977,895 |
| Evaporación | 13,753 |
| Nubosidad | 35,688 |
| Temperatura Máxima | 422,999 |
| Temperatura Mínima | 414,278 |
| Humedad Relativa | 674,093 |

This heterogeneity is methodologically important because not all variables are available with the same density across the observational system. The zonal strategy used in the thesis helps preserve analytical coherence despite that uneven availability.

---

## Availability of derived variables

Some of the most important variables in the thesis are not directly observed but derived through processing and physical formulation.

These include:

- **ρ (air density)**,
- **WPD (Wind Power Density)**,
- **Eh**,
- **E_free**,
- **E_usable**,
- and **FNRR**.

Their availability in the repository depends on the presence of:

- sufficient observed input variables,
- preprocessing consistency,
- physical construction scripts,
- and analysis-ready structured outputs.

In this sense, the repository does not only provide “data”; it provides the computational pathway that makes these variables scientifically reproducible.

---

## Reproducibility versus raw storage

This repository is designed primarily for **scientific reproducibility**, not for unlimited raw archival storage.

That distinction is important.

A reproducible doctoral repository should guarantee that a qualified reader can:

- understand the observational basis,
- identify the stations and zones,
- reconstruct the processing logic,
- follow the variable construction process,
- examine the model pipeline,
- and verify the reported outputs.

It is not necessary that GitHub serve as the sole permanent storage location of every raw operational file.

---

## Practical repository interpretation

Within this repository, data availability should be interpreted under three levels:

### Level 1 — Observational traceability
The repository documents what data were used, where they come from conceptually, how they are grouped, and what variables they contain.

### Level 2 — Analytical usability
The repository preserves the structures required to run the doctoral workflow, especially processed and derived data representations.

### Level 3 — Computational reproducibility
The repository includes the scripts, outputs, and technical support needed to reproduce the reported analysis and results.

---

## Final statement

The doctoral thesis is based on a large and heterogeneous observational meteorological system. The public repository associated with the thesis is not intended to function as a raw archival mirror of every original source file, but as a **structured reproducible environment** that preserves:

- observational provenance,
- zonal organization,
- variable definitions,
- preprocessing logic,
- computational workflows,
- and the outputs necessary to support the scientific results reported in the thesis.

For that reason, **data availability in this repository must be understood in terms of scientific reproducibility and methodological traceability**, not merely in terms of raw file volume.

# Repository Scope

## Purpose

This repository contains the computational, analytical, and documentary support material associated with the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**  
**Author:** Favio Nicolás Rosero Rodríguez  
**Program:** Doctorado en Ciencias – Física  
**Institution:** Universidad Nacional de Colombia, Sede Manizales  
**Year:** 2026

Its main purpose is to provide a structured, reproducible, and traceable scientific repository for the methodological and computational components that support the results reported in the thesis.

---

## What this repository contains

This repository includes the materials required to reproduce, audit, and extend the main computational workflow of the thesis, including:

- Metadata and structural documentation of the meteorological dataset used in the research.
- Scripts for preprocessing, quality control, and generation of physical variables.
- Code for computing air density, Wind Power Density (WPD), and horizon-integrated energy (Eh).
- Physical characterization workflows, including:
  - descriptive statistics,
  - Weibull/Rayleigh comparison,
  - ACF/PACF analysis,
  - FFT-based spectral analysis,
  - Wavelet-based time–frequency analysis.
- Predictive modeling pipelines, including:
  - classical models (ARIMA/ARIMAX),
  - machine learning models (Random Forest, XGBoost),
  - deep learning models (LSTM-based architectures).
- Implementation files related to the hybrid TDQ–PIESS framework.
- Code and outputs for:
  - FNRR computation,
  - PI90 uncertainty calibration,
  - deterministic and probabilistic model evaluation,
  - regional energy projection up to 2028.
- Extended outputs not fully included in the main PDF document, such as:
  - supplementary figures,
  - supplementary tables,
  - training curves,
  - validation outputs,
  - calibration notes,
  - technical appendices.
- Documentary evidence and working material for associated products derived from the thesis (articles, patent draft, dashboard, book, conference outputs, and related academic developments).

---

## What this repository does not contain

For scientific, institutional, and practical reasons, this repository does **not** necessarily include all raw source material in fully public form.

In particular, it may exclude:

- The complete raw meteorological database in its original large-scale operational form.
- Files whose size exceeds practical GitHub versioning limits.
- Source datasets subject to institutional, operational, or redistribution restrictions.
- Temporary files, exploratory drafts, intermediate local caches, or non-curated working copies.
- Materials unrelated to the validated doctoral workflow.

When raw data are not included, the repository preserves the corresponding metadata, structural descriptions, processing logic, and reproducibility notes required to understand and reconstruct the computational pipeline.

---

## Thesis components represented here

The repository is intended to support the computational and technical backbone of the thesis, especially the following components:

### Chapter 2 — Physical–statistical characterization of wind in Nariño
This repository contains the analytical support for the characterization of wind dynamics through distributional, temporal, spectral, and multiscale analysis.

### Chapter 3 — Predictive modeling of Wind Power Density (WPD)
This repository contains the model pipelines, evaluation logic, benchmark comparison against persistence, and uncertainty calibration procedures.

### Chapter 4 — Energy integration and regional projection (2017–2028)
This repository contains the computational support for free energy, usable energy, FNRR-based modulation, PI90 intervals, and projected regional energy scenarios.

### Annexes
This repository functions as the main digital support for the annexed reproducible material of the thesis, including code, extended results, configurations, and supplementary technical evidence.

### Associated products
This repository also serves as an organizational base for derivative products formally linked to the thesis, such as scientific articles, patent-oriented developments, dashboard components, and related academic outputs.

---

## Scientific scope

This repository is centered on a **hybrid physical–statistical framework** for regional wind-energy analysis and forecasting in Nariño, Colombia.

Its scientific core includes:

- physical interpretation of wind as a nonlinear, multiscale atmospheric system,
- WPD as the central target variable,
- Eh as a derived operational energy quantity,
- benchmark-based predictive validation using Skill Score against persistence,
- explicit uncertainty control using calibrated PI90 intervals,
- formalization of the **FNRR** as an adimensional regional irregularity index,
- translation from physically available energy to structurally usable energy.

---

## Reproducibility statement

This repository is designed to preserve the **reproducibility logic** of the thesis, even when some large-scale raw inputs are not directly distributed.

Reproducibility is supported through:

- documented folder structure,
- code organization by methodological stage,
- preserved model logic,
- stored results and supplementary outputs,
- validation and calibration artifacts,
- explicit mapping between thesis sections and repository contents.

This repository should therefore be interpreted as the **scientific support environment** of the thesis, rather than as a simple file container.

---

## Intended use

This repository is intended for:

- academic review,
- scientific traceability,
- methodological verification,
- reproducibility support,
- controlled extension of the doctoral research line,
- preparation of derivative scientific and technological products.

It is **not** intended to be interpreted as a finalized industrial platform or as a public operational forecasting service.

---

## Version note

This repository may continue evolving after thesis submission in order to:

- improve structure,
- document missing support materials,
- organize derivative products,
- strengthen reproducibility,
- and prepare postdoctoral scientific outputs.

Such updates do not alter the central scientific scope of the doctoral thesis, but rather improve its traceability and usability.

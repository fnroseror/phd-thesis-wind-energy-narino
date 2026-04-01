# Preprocessing

## Purpose

This folder contains the preprocessing and physical-variable construction stage of the doctoral repository associated with the thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

Its function is to transform the unified observational source file into analysis-ready hourly zonal structures that can be used consistently across:

- physical characterization,
- classical forecasting,
- machine learning,
- deep learning,
- hybrid TDQ–PIESS modeling,
- uncertainty calibration,
- and structural energy projection.

This folder therefore represents the operational entry point of the computational workflow.

---

## Scientific role within the thesis

The doctoral framework is built from a large meteorological observational system and then organized into a reproducible pipeline that integrates:

- multiscale physical characterization of wind,
- comparative predictive modeling,
- probabilistic validation,
- and energetic interpretation under uncertainty.

Within that structure, preprocessing is the stage that guarantees that the observational data become physically interpretable and computationally reusable.

This includes:

- reading the unified source data,
- validating mandatory columns,
- parsing date-time records,
- standardizing variable names,
- aggregating data to hourly resolution,
- organizing observations by zone,
- and constructing the main physical variables required by the thesis.

---

## Source input

The original working process was built from a unified text file named:

`Datos.txt`

During development, absolute local paths were used in different stages of the thesis workflow. In the final repository version, those paths should be treated as implementation-specific historical paths and progressively replaced by repository-relative or configurable paths.

The expected conceptual input structure is:

- `Estación`
- `FechaYHora`
- `Valor`
- `Zona`
- `Variable`

These fields are required because the downstream workflow depends on zonal hourly aggregation and multivariable physical construction.

---

## Main preprocessing functions represented in this folder

The scripts documented in this folder are responsible for the following tasks:

### 1. Input validation and ingestion
- reading the unified file,
- verifying required columns,
- handling delimiter differences when necessary,
- and ensuring the source file can be interpreted as a structured observational table.

### 2. Date-time parsing
- normalization of date-time strings,
- conversion of AM/PM variants when present,
- parsing into a valid temporal index,
- and alignment to hourly resolution.

### 3. Variable normalization
- standardization of variable names,
- reconciliation of naming differences across source records,
- and preparation for wide-format hourly aggregation.

### 4. Hourly zonal aggregation
- grouping by `Zona`, `FechaHora`, and `Variable`,
- aggregation to hourly resolution,
- reshaping from long format to wide format,
- and ordering of the time series for downstream modeling.

### 5. Physical-variable construction
- conversion of pressure to Pascals when needed,
- conversion of temperature to Kelvin when needed,
- estimation of air density `rho`,
- computation of Wind Power Density `WPD`,
- and derivation of `Eh` as the hourly energetic base quantity used in later stages.

At this preprocessing level, `Eh` is stored as an hourly derived quantity associated with `WPD`. The horizon-integrated energetic quantity used for forecasting evaluation is computed later within the modeling pipelines.

### 6. Cache generation
This preprocessing stage also creates reusable intermediate files that support later chapters without requiring full re-ingestion of the raw source each time.

The main cache products associated with this stage are:

- `WPD_hourly_por_zona.csv`
- `WPD_Eh_hourly_por_zona.csv`

These files are especially important because they are used later by the classical/ML pipeline, the deep learning pipeline, the TDQ–PIESS workflow, and the energy projection stage.

---

## Expected scripts in this folder

The final repository organization for this folder should contain the following scripts:

### `01_qc_cleaning_traceability.R`
Responsible for:
- initial ingestion,
- mandatory-column checks,
- parsing control,
- basic cleaning logic,
- and traceability of preprocessing decisions.

### `02_build_hourly_wpd_cache.R`
Responsible for:
- hourly aggregation by zone,
- variable normalization,
- construction of `rho`,
- construction of `WPD`,
- and export of `WPD_hourly_por_zona.csv`.

### `03_build_hourly_wpd_eh_cache.R`
Responsible for:
- generation of the hourly cache including
  `VV`, `PA`, `TM`, `rho`, `WPD`, and `Eh`,
- and export of `WPD_Eh_hourly_por_zona.csv`.

### `04_physical_variable_construction.R`
Responsible for:
- documenting or modularizing the reusable physical formulas,
- especially pressure conversion,
- temperature conversion,
- air density estimation,
- WPD calculation,
- and energetic derivation rules used later in the thesis.

---

## Relationship with later stages

The outputs of this folder feed all subsequent parts of the repository.

### Feeds `02_physical_characterization`
The physical characterization of wind depends on clean and temporally coherent data.

### Feeds `03_classical_models` and `04_machine_learning`
The comparative predictive framework requires stable zonal hourly inputs and derived physical variables.

### Feeds `05_deep_learning`
The LSTM pipeline uses structured hourly WPD inputs and aligned horizon preparation.

### Feeds `06_hybrid_tdq`
The TDQ–PIESS stage depends on physically valid inputs, especially `VV`, `PA`, `TM`, `rho`, `WPD`, and `Eh`.

### Feeds `07_energy_projection`
The projection stage depends on the final energetic caches and the consistency of the temporal structure created here.

---

## Reproducibility note

This folder should be interpreted as the preprocessing backbone of the thesis repository, not as a generic cleaning stage.

Its purpose is to preserve the transition from raw observational input to physically meaningful and computationally reproducible structures.

For that reason, all scripts placed here should satisfy four conditions:

1. preserve the zonal logic of the thesis,
2. maintain hourly temporal consistency,
3. keep physical-variable construction explicit,
4. and export reusable intermediate products for the downstream pipeline.

---

## Final interpretation

This folder represents the first executable layer of the doctoral computational system.

Without this preprocessing stage, the later components of the thesis — physical analysis, predictive comparison, uncertainty calibration, FNRR construction, and energy projection — would not remain traceable or reproducible.

It should therefore be read as the bridge between the observational system and the scientific architecture of the thesis.

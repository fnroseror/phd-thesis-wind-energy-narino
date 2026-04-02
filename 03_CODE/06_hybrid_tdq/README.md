# Hybrid TDQ

## Purpose

This folder contains the hybrid TDQ–PIESS stage of the doctoral repository associated with the thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

Its purpose is to implement the hybrid physical–statistical forecasting layer that integrates physical variables, structural irregularity, state-space modeling, and calibrated uncertainty within a unified regional framework.

This folder corresponds specifically to the **hybrid TDQ–PIESS component** of the comparative predictive design.

---

## Scientific role within the thesis

The doctoral work does not stop at comparing classical, ML, and DL approaches independently. It also proposes a hybrid framework capable of integrating:

- physical structure,
- regional forcing conditions,
- temporal memory,
- structural irregularity,
- and probabilistic uncertainty.

Within that logic, the TDQ–PIESS stage plays four scientific roles:

1. it translates the atmospheric system into a structured physical representation;
2. it introduces FNRR as a regional irregularity descriptor;
3. it estimates uncertainty explicitly through calibrated PI90 intervals;
4. it provides the predictive and structural output used later in Chapter 4.

For that reason, this folder should be interpreted as the hybrid methodological core of the thesis.

---

## Main components represented in this folder

The hybrid TDQ workflow used in the doctoral process includes:

- hourly reconstruction of the zonal observational system,
- physical-variable construction (`rho`, `WPD`),
- contextual thermodynamic indicators,
- potential-well and barrier structure,
- memory dynamics by zone,
- FNRR construction,
- state-space regression through KFAS,
- and calibrated PI90 prediction intervals.

---

## Target structure in the workflow

Within the final computational design, the TDQ pipeline works directly from the unified observational system and constructs a hybrid representation of the regional wind-energy regime.

In the final script logic used during thesis closure:

- the source observational file is read from `Datos.txt`,
- hourly zonal grids are reconstructed,
- missing values are handled under physically controlled rules,
- `rho` and `WPD` are calculated,
- TDQ variables are derived,
- KFAS is fitted by zone and horizon,
- PI90 is calibrated,
- and the final global prediction file is exported for Chapter 4 interpretation.

---

## Main computational tasks represented in this folder

The scripts documented in this folder are responsible for the following tasks:

### 1. Observational reconstruction
- reading the unified source file,
- parsing date-time records,
- aggregating observations to hourly resolution,
- and rebuilding complete zonal hourly grids.

### 2. Physical base construction
- converting pressure and temperature to consistent physical units,
- computing air density,
- constructing WPD,
- and preserving a physically interpretable energy basis.

### 3. TDQ state-variable construction
- building rolling mean and rolling dispersion terms,
- computing CTI,
- defining the potential well and barrier structure,
- deriving transition-related variables,
- and constructing free-energy-related quantities.

### 4. Memory dynamics
- constructing zonal memory recursively,
- allowing different memory decay by zone,
- and incorporating structural persistence into the hybrid framework.

### 5. FNRR construction
- transforming the physical state into a bounded structural irregularity index,
- defining regime labels,
- and preserving regional interpretability.

### 6. KFAS hybrid modeling
- fitting state-space regression models by zone and horizon,
- including seasonal structure when required,
- and generating hybrid forecasts.

### 7. PI90 uncertainty calibration
- constructing 90% prediction intervals,
- adjusting coverage empirically,
- and preserving probabilistic interpretability.

### 8. Export of hybrid outputs
- saving tables,
- saving calibrated predictions,
- saving figures,
- and generating the global output later used by Chapter 4.

---

## Expected script in this folder

### `01_cap3_tdq_piess_pipeline.R`

This is the main script expected in this folder.

Its role is to preserve the final hybrid TDQ–PIESS sub-block of the Chapter 3 workflow, including:

- hourly reconstruction,
- physical base creation,
- TDQ variable construction,
- FNRR generation,
- KFAS modeling,
- PI90 calibration,
- and export of hybrid predictions and figures.

This script should be interpreted as the reproducible hybrid core of the comparative predictive framework.

---

## Main outputs expected from this folder

The outputs associated with this folder include:

- hybrid performance tables,
- calibrated prediction files,
- FNRR-related summaries,
- PI90 interval outputs,
- hybrid figures,
- and the final prediction files used by Chapter 4.

These outputs are later reflected in:

- `04_RESULTS/uncertainty_pi90/`
- `04_RESULTS/fnrr/`
- `06_TABLES/chapter_3/`
- `05_FIGURES/chapter_3/`
- and structural projection inputs consumed in `07_energy_projection/`

---

## Relationship with previous stages

This folder depends conceptually on all previous computational stages.

### Depends on `01_preprocessing`
because it shares the same observational basis and physical variables.

### Depends on `02_physical_characterization`
because the hybrid interpretation assumes that wind has already been understood as a structured physical signal.

### Depends on `03_classical_models`, `04_machine_learning`, and `05_deep_learning`
because the hybrid stage is interpreted comparatively within the full predictive architecture of Chapter 3.

---

## Relationship with later stages

This folder directly feeds the final structural interpretation of the thesis.

### Feeds `07_energy_projection`
The hybrid outputs, especially calibrated predictions and FNRR-related quantities, are the bridge toward the structural projection of Chapter 4.

### Feeds energetic interpretation
The distinction between structural regularity and irregularity becomes operational only after the hybrid variables are explicitly estimated here.

---

## Reproducibility note

This folder should be interpreted as the reproducible hybrid layer of Chapter 3.

Its purpose is not only to run a hybrid model, but to preserve the explicit computational path by which physical variables, memory structure, irregularity, uncertainty, and prediction were integrated into a single doctoral framework.

For that reason, the scripts placed here should satisfy four conditions:

1. preserve the physical meaning of the variables,
2. keep FNRR construction explicit,
3. include calibrated probabilistic uncertainty,
4. and export outputs reusable in Chapter 4.

---

## Final interpretation

This folder represents the methodological center of the doctoral workflow.

If classical, ML, and DL models provide comparative predictive baselines, this folder provides the integrative framework through which the thesis moves from forecasting performance toward structural scientific interpretation.

Without this stage, the connection between regional physical irregularity, uncertainty, and energetic projection would remain incomplete.

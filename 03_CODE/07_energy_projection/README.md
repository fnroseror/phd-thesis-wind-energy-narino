# Energy Projection

## Purpose

This folder contains the energy-integration and structural-projection stage of the doctoral repository associated with the thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

Its purpose is to translate the calibrated predictive outputs of the hybrid TDQ–PIESS stage into regional energetic interpretation, historical synthesis, and structural projection up to 2028.

This folder corresponds specifically to the **computational core of Chapter 4**.

---

## Scientific role within the thesis

The doctoral work does not end with predictive comparison. It extends the validated framework toward a regional energetic interpretation in which the wind regime is not only predicted, but also summarized, penalized by structural irregularity, and projected prospectively.

Within that logic, the energy-projection stage plays four scientific roles:

1. it aggregates the hybrid predictive output into annual and quarterly energetic summaries;
2. it formalizes the distinction between **free energy** and **usable energy**;
3. it preserves **FNRR** as a structural regional signature;
4. it projects the regional energetic regime from the historical basis toward **2028**.

For that reason, this folder should be interpreted as the final energetic stage of the thesis.

---

## Main components represented in this folder

The energy-projection workflow used in the doctoral process includes:

- reading the global hybrid prediction outputs,
- summarizing annual historical energy,
- constructing structural summaries for 2017–2022,
- generating prospective projections for 2023–2028,
- preserving PI90-related uncertainty information,
- propagating FNRR as a regional structural quantity,
- and distinguishing between free and usable energy.

---

## Target structure in the workflow

Within the final computational design, the projection stage works from two main inputs:

- the hybrid output file generated in the TDQ–PIESS stage,
- and, in the final closure stage, the hourly cache containing `WPD` and `Eh`.

In the final script logic used during thesis closure:

- the file `TDQ_PIESS_PREDS_GLOBAL.csv` is used to summarize historical energy and build structural projection tables,
- `WPD_Eh_hourly_por_zona.csv` is used in the final closure workflow,
- quarterly and annual structures are built,
- `FNRR` is propagated as a structural descriptor,
- and the projection is extended to **2028**.

---

## Main computational tasks represented in this folder

The scripts documented in this folder are responsible for the following tasks:

### 1. Historical energy synthesis
- reading validated hybrid outputs,
- aggregating annual energetic quantities,
- estimating historical central tendency and dispersion,
- and preserving the observed energetic baseline of the system.

### 2. Structural summary
- summarizing the 2017–2022 energetic regime,
- extracting representative mean and quantile-based bounds,
- and preserving `FNRR` as a structural annual signature.

### 3. Structural projection to 2028
- extending the historical energetic structure toward 2028,
- producing annual and quarterly projection tables,
- and preserving coherence with the hybrid predictive stage.

### 4. Energetic interpretation
- distinguishing between `E_free` and `E_usable`,
- applying the structural role of `FNRR`,
- and translating physical availability into usable energetic interpretation.

### 5. Uncertainty propagation
- preserving PI90-derived lower and upper bounds,
- exporting interval summaries,
- and maintaining coherence with the calibrated uncertainty logic established in Chapter 3.

### 6. Export of tables and figures
- saving historical-energy tables,
- saving structural-summary tables,
- saving projected-energy tables,
- and generating publication-ready figures for energy and FNRR evolution.

---

## Expected scripts in this folder

### `01_cap4_structural_projection_2017_2028.R`

This is the main structural-projection script expected in this folder.

Its role is to preserve the historical-to-prospective energetic workflow, including:

- reading `TDQ_PIESS_PREDS_GLOBAL.csv`,
- computing annual historical energy,
- summarizing the 2017–2022 structure,
- projecting 2023–2028,
- and exporting the corresponding figures and tables.

### `02_cap4_final_closure.R`

This is the final closure script expected in this folder.

Its role is to preserve the extended Capítulo 4 closure workflow, including:

- reconstruction from hourly `WPD` and `Eh`,
- quarterly and annual aggregation,
- structural FNRR evolution,
- `E_free` and `E_usable`,
- and final formal exports for the thesis.

---

## Main outputs expected from this folder

The outputs associated with this folder include:

- annual historical energy tables,
- structural summary tables for 2017–2022,
- projected energy tables for 2023–2028,
- quarterly and annual TDQ closure tables,
- FNRR annual and quarterly summaries,
- and figures of historical versus projected energy.

These outputs are later reflected in:

- `04_RESULTS/energy_projection_2028/`
- `04_RESULTS/fnrr/`
- `06_TABLES/chapter_4/`
- `05_FIGURES/chapter_4/`

---

## Relationship with previous stages

This folder depends directly on:

- `03_CODE/06_hybrid_tdq/`

because the hybrid TDQ–PIESS stage provides the calibrated predictive outputs and structural quantities used here.

It also depends on:

- `03_CODE/01_preprocessing/`

because the final closure stage may rebuild quarterly and annual energy structures from the hourly `WPD` and `Eh` cache.

---

## Reproducibility note

This folder should be interpreted as the reproducible energetic-projection layer of Chapter 4.

Its purpose is not only to extend numerical outputs into the future, but to preserve the full computational path by which historical energy, structural irregularity, and usable energy interpretation were integrated into the final doctoral results.

For that reason, the scripts placed here should satisfy four conditions:

1. preserve historical-to-prospective continuity,
2. keep FNRR explicit as a structural descriptor,
3. distinguish clearly between free and usable energy,
4. and export outputs directly traceable to the thesis discussion.

---

## Final interpretation

This folder represents the final energetic stage of the doctoral workflow.

If the hybrid TDQ–PIESS stage provides the calibrated predictive and structural core, this folder translates that core into a regional energetic outlook that is interpretable, reproducible, and scientifically aligned with the final contribution of the thesis.

Without this stage, the doctoral work would remain at the level of prediction alone and would not complete the transition toward regional wind-energy interpretation and structural projection.

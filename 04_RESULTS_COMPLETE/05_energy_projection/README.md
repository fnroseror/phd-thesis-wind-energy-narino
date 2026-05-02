# 05_energy_projection

## Purpose

This folder contains the structured documentation and outputs associated with the energetic integration and regional energy-projection stage of the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

It corresponds to the energetic interpretation layer of the thesis and supports the transformation of physical wind characterization, predictive modeling, uncertainty quantification, and FNRR structural interpretation into regional energy-potential results.

This folder is part of:

```text
04_RESULTS_COMPLETE/
```

and must be interpreted as a component of the complete scientific evidence layer of the repository.

---

## 1. Scientific role of this folder

The doctoral thesis does not stop at predicting wind speed or Wind Power Density.

Its final scientific objective is to interpret how atmospheric behavior can be translated into regional wind-energy potential under uncertainty and structural irregularity.

For that reason, this folder documents the result layer where the thesis connects:

```text
Wind Power Density
→ prediction
→ uncertainty
→ FNRR structural adjustment
→ free energy
→ usable energy
→ regional energy projection
```

This stage gives applied meaning to the physical and predictive framework developed in the thesis.

---

## 2. Physical basis

The central physical target variable of the thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

WPD expresses the available wind power per unit area. Because of the cubic dependence on wind speed, the energetic interpretation is highly sensitive to wind variability, regional irregularity, and predictive uncertainty.

The energy-projection stage integrates this WPD behavior over time and interprets it under the zonal structure of Nariño.

---

## 3. Energy quantities interpreted in the thesis

### 3.1 Free energy

Free energy represents the physically available energetic potential before structural irregularity adjustment.

It is associated with the integrated behavior of WPD over a defined temporal horizon.

Conceptually:

```text
E_free = integral or accumulated WPD over the analysis/projection horizon
```

In the thesis, this quantity represents the gross energetic potential of the regional wind system.

---

### 3.2 Usable energy

Usable energy represents the portion of free energy that remains after accounting for structural regional irregularity through FNRR.

Conceptually:

```text
E_usable = (1 − FNRR) · E_free
```

where:

- `E_usable` is the structurally usable energy,
- `E_free` is the physically available energy,
- and `FNRR` is the regional irregularity factor.

This relationship allows the thesis to avoid overinterpreting physically available energy as fully usable energy.

---

### 3.3 Projected energy

Projected energy refers to the energetic behavior estimated beyond the historical observational window, using the predictive framework developed in the thesis.

In this doctoral work, the historical observational basis corresponds to **2017–2022**, while the projection stage extends the energetic interpretation toward **2028**.

The projection must therefore be interpreted as a model-based energetic scenario, not as an observed measurement.

---

## 4. Relationship with uncertainty

Energy projection must not be interpreted only as a deterministic value.

Because predicted WPD is uncertain, the projected energy must also be interpreted under uncertainty.

The PI90 layer provides probabilistic context for the projected energetic outputs.

This allows the thesis to distinguish between:

- central projected energy,
- uncertainty around projected energy,
- lower-bound scenarios,
- upper-bound scenarios,
- and structurally adjusted usable energy.

This is essential because energy planning requires not only a central forecast, but also information about the range of plausible behavior.

---

## 5. Relationship with FNRR

This folder should be read together with:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
```

FNRR provides the structural irregularity adjustment that allows the thesis to distinguish between free energy and usable energy.

The energy-projection layer estimates or organizes the energetic quantities, while the FNRR layer supports their structural interpretation.

Together, they form the energetic closure of the doctoral framework:

```text
predicted WPD
→ free energy
→ FNRR adjustment
→ usable energy
→ regional projection
```

---

## 6. Expected result outputs

This folder may contain or document outputs such as:

- annual free energy by zone,
- annual usable energy by zone,
- free-versus-usable energy comparisons,
- projected WPD summaries,
- projected energy scenarios toward 2028,
- PI90-supported energy intervals,
- zone-level energy-projection summaries,
- energy-projection logs,
- and final regional energetic synthesis outputs.

If numerical outputs are stored in `04_RESULTS_COMPLETE/08_TABLES/`, this folder should be interpreted as the conceptual and methodological result layer that explains how those tables must be read.

---

## 7. Suggested naming logic for future files

If numerical outputs are added directly to this folder, the naming should remain explicit and traceable.

Recommended naming examples:

```text
annual_free_energy_2017_2028.csv
annual_usable_energy_2017_2028.csv
energy_free_vs_usable_by_zone.csv
energy_pi90_projection_2023_2028.csv
scenario_2028_by_zone.csv
quarterly_wpd_projection.csv
energy_projection_log.csv
regional_energy_projection_summary.csv
```

This naming logic preserves the relationship between WPD, FNRR, uncertainty, free energy, usable energy, and projection horizon.

---

## 8. Thesis linkage

This folder is aligned primarily with the energetic interpretation and projection stage developed in Chapter 4 of the thesis.

It supports:

- the integration of WPD into energetic quantities,
- the distinction between free energy and usable energy,
- the use of FNRR as structural adjustment,
- the interpretation of PI90-supported energy uncertainty,
- the projected energetic scenarios toward 2028,
- and the regional decision-support interpretation of wind-energy potential.

The outputs and documentation in this folder should be interpreted together with the corresponding figures and tables organized in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

The formal mathematical and physical support for WPD, FNRR, and energy integration should be documented in:

```text
05_APPENDICES_SUPPORT/
```

---

## 9. Relationship with code

The energy-projection outputs should be reproducible from the corresponding computational workflow contained in:

```text
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
```

The folder `03_CODE/06_hybrid_tdq/` reflects the current repository naming. In this results layer, its role should be interpreted as part of the hybrid physical–statistical integration stage of the doctoral workflow.

The logical relationship is:

```text
processed zonal data
→ WPD construction
→ predictive modeling
→ uncertainty quantification
→ FNRR computation
→ free-energy integration
→ usable-energy estimation
→ projection toward 2028
→ regional energetic interpretation
```

---

## 10. Relationship with the complete results folder

This folder is part of the broader result structure:

```text
04_RESULTS_COMPLETE/
├── 01_physical_characterization/
├── 02_model_comparison/
├── 03_pi90_uncertainty/
├── 04_fnrr_outputs/
├── 05_energy_projection/
├── 06_extended_results/
├── 07_FIGURES/
└── 08_TABLES/
```

Within this structure, `05_energy_projection/` provides the energetic projection layer.

It is the stage where the doctoral workflow connects physical modeling and predictive analysis with regional energy interpretation.

---

## 11. Methodological caution

Projected energy values should not be interpreted as direct observations.

They are model-based energetic scenarios derived from:

- the historical observational basis,
- physical construction of WPD,
- predictive modeling,
- uncertainty quantification,
- FNRR structural adjustment,
- and the projection horizon defined in the thesis.

Therefore, projected energy must always be read as a scientifically constrained scenario rather than as a guaranteed future value.

---

## 12. Interpretation role

This folder supports the applied closure of the doctoral thesis.

Its role is to translate the physical and predictive behavior of the wind system into energetic quantities that can be interpreted at the regional level.

The core idea preserved in this folder is:

```text
The value of a wind-energy forecast is not only in predicting the atmospheric signal, but in translating that signal into physically meaningful and uncertainty-aware energy potential.
```

---

## 13. Final note

This folder documents the energy-projection layer of the doctoral thesis.

Its role is to connect:

- Wind Power Density,
- predictive modeling,
- uncertainty quantification,
- FNRR structural interpretation,
- free energy,
- usable energy,
- and regional projection toward 2028.

It is a central component of the repository because it preserves the evidence and documentation associated with the final energetic interpretation of the doctoral work.

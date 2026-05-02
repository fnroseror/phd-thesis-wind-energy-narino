# 04_fnrr_outputs

## Purpose

This folder contains the structured documentation and outputs associated with the **Factor de No Regularidad Regional (FNRR)** developed in the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

It corresponds to the structural regional-irregularity result layer of the thesis and supports the interpretation of how regional wind-energy potential is affected by irregularity, variability, and usable-energy constraints.

This folder is part of:

```text
04_RESULTS_COMPLETE/
```

and must be interpreted as a component of the complete scientific evidence layer of the repository.

---

## 1. Scientific role of this folder

The doctoral thesis does not limit wind-energy assessment to the estimation of physically available energy.

It introduces **FNRR** as a structural descriptor designed to quantify regional irregularity in the behavior of Wind Power Density (**WPD**) and to support the distinction between:

- physically available energy,
- and structurally usable energy.

This distinction is central to the thesis because a region may present relevant wind-energy potential while also exhibiting irregularity that reduces the portion of that potential that can be interpreted as stable or usable.

For that reason, this folder documents one of the original contributions of the doctoral work.

---

## 2. Physical basis

The central energetic variable of the thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

Because WPD depends cubically on wind speed, the energetic response of the system is highly sensitive to variability, intermittency, asymmetry, and regional irregularity.

FNRR is introduced to quantify part of that structural irregularity and to connect the physical behavior of wind with an energetic interpretation at the regional level.

---

## 3. Conceptual definition of FNRR

Within the thesis, **FNRR** is interpreted as a dimensionless regional irregularity factor derived from the internal structure of the WPD distribution.

Its purpose is to transform the qualitative notion of irregularity into a measurable quantity that can be used to compare zones and to adjust energetic interpretation.

Conceptually, FNRR acts as a bridge between:

```text
WPD distribution
→ regional irregularity
→ structural energetic penalization
→ usable energy interpretation
```

FNRR should therefore be interpreted as a structural descriptor, not as a conventional forecasting metric.

---

## 4. Energetic interpretation

The thesis distinguishes between two energetic quantities:

### 4.1 Free energy

Free energy represents the physically available energetic potential before applying the structural irregularity adjustment.

It can be interpreted as the gross energetic potential obtained from the projected or integrated WPD behavior.

### 4.2 Usable energy

Usable energy represents the portion of free energy that remains after accounting for regional irregularity through FNRR.

Conceptually:

```text
E_usable = (1 − FNRR) · E_free
```

where:

- `E_usable` is the structurally usable energy,
- `E_free` is the physically available or free energy,
- and `FNRR` is the regional irregularity factor.

This relationship allows the thesis to move from a purely physical estimate of available wind-energy potential to a more cautious structural interpretation of usable energy.

---

## 5. Why FNRR is necessary

A conventional wind-energy analysis may report wind speed, WPD, or projected energy values without explicitly quantifying how irregularity affects the usability of that potential.

The thesis introduces FNRR because regional wind-energy evaluation requires more than identifying energetic magnitude.

It also requires understanding whether the energy signal is:

- regular or irregular,
- concentrated or dispersed,
- structurally stable or unstable,
- comparable across zones,
- and suitable for cautious energetic projection.

FNRR helps express this structural condition in a compact and interpretable way.

---

## 6. Expected result outputs

This folder may contain or document outputs such as:

- FNRR values by zone,
- annual FNRR values,
- mean FNRR by zone,
- structural FNRR summaries,
- regional coherence indicators,
- FNRR quantile-support outputs,
- FNRR evolution across the projection horizon,
- free-energy estimates,
- usable-energy estimates,
- and comparative zone-level irregularity results.

If numerical outputs are stored in `04_RESULTS_COMPLETE/08_TABLES/`, this folder should be interpreted as the conceptual and methodological result layer that explains how those tables must be read.

---

## 7. Suggested naming logic for future files

If numerical outputs are added directly to this folder, the naming should remain explicit and traceable.

Recommended naming examples:

```text
fnrr_annual_by_zone.csv
fnrr_mean_by_zone.csv
fnrr_structural_summary.csv
fnrr_quantiles_support.csv
fnrr_evolution_2017_2028.csv
regional_coherence_by_zone.csv
free_energy_by_zone.csv
usable_energy_by_zone.csv
energy_penalization_by_fnrr.csv
```

This naming structure preserves the relationship between FNRR, regional irregularity, free energy, usable energy, and projected energetic interpretation.

---

## 8. Relationship with uncertainty

FNRR should not be interpreted independently from the uncertainty framework.

The PI90 uncertainty layer provides information about predictive uncertainty, while FNRR provides information about structural regional irregularity.

These two components answer different but complementary questions:

| Component | Main question |
|---|---|
| **PI90** | How uncertain are the predictions? |
| **FNRR** | How irregular is the regional energetic structure? |

Together, they support a more cautious interpretation of projected wind-energy potential.

---

## 9. Relationship with energy projection

This folder should be read together with:

```text
04_RESULTS_COMPLETE/05_energy_projection/
```

The energy-projection layer estimates future or accumulated energetic behavior.

The FNRR layer contributes to that interpretation by distinguishing between:

```text
free energetic potential
→ structural irregularity adjustment
→ usable energetic potential
```

For this reason, FNRR is not an isolated index. It is part of the energetic interpretation architecture of the thesis.

---

## 10. Thesis linkage

This folder is aligned primarily with the structural and energetic interpretation developed in Chapter 4 of the thesis.

It supports:

- the formal definition of FNRR,
- the interpretation of regional irregularity,
- the structural comparison across zones,
- the distinction between free and usable energy,
- the annual or projected evolution of regional irregularity,
- and the integration between WPD, uncertainty, FNRR, and energy projection.

The outputs and documentation in this folder should be interpreted together with the corresponding figures and tables organized in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

The formal mathematical derivation and extended scientific discussion should be documented in:

```text
05_APPENDICES_SUPPORT/
```

---

## 11. Relationship with code

The FNRR outputs should be reproducible from the corresponding computational workflow contained in:

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
→ uncertainty interpretation
→ robust structural analysis
→ FNRR computation
→ free-energy estimation
→ usable-energy interpretation
→ regional energy projection
```

---

## 12. Relationship with the complete results folder

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

Within this structure, `04_fnrr_outputs/` provides the structural irregularity layer.

It connects uncertainty-aware prediction with energetic interpretation.

---

## 13. Methodological caution

FNRR should not be interpreted as a universal physical constant.

It is a regional, dimensionless, data-derived structural descriptor associated with the WPD behavior of the studied system.

Its interpretation depends on:

- the observational dataset,
- the zonal structure,
- the preprocessing workflow,
- the WPD construction,
- the robust distributional logic used in its formulation,
- and the energetic interpretation framework of the thesis.

Therefore, FNRR should be used as a structural descriptor within the scope of this doctoral work and not as an independent universal law.

---

## 14. Interpretation role

This folder supports one of the key doctoral contributions:

The thesis does not only forecast wind-energy potential; it also proposes a way to interpret how regional irregularity affects the usable portion of that potential.

FNRR gives quantitative structure to the following idea:

```text
Not all physically available energy should be interpreted as structurally usable energy.
```

This makes FNRR essential for connecting physics, prediction, uncertainty, and regional energy interpretation.

---

## 15. Final note

This folder documents the FNRR result layer of the doctoral thesis.

Its role is to connect:

- Wind Power Density,
- regional irregularity,
- robust structural interpretation,
- uncertainty-aware forecasting,
- free energy,
- usable energy,
- and regional energy projection.

It is a central component of the repository because it preserves the evidence and documentation associated with one of the original methodological contributions of the doctoral work.

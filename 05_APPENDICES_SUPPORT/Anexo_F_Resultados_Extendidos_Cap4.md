# Appendix F — Extended Results for Chapter 4

## Purpose

This appendix documents the extended results associated with Chapter 4 of the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

Its purpose is to provide technical support for the integrated physical–statistical and energetic interpretation stage of the thesis, including Wind Power Density, PI90 uncertainty, FNRR, free energy, usable energy, and regional energy projection toward 2028.

This appendix complements the Chapter 4 materials contained in:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

---

## F.1 Role of Chapter 4 in the thesis

Chapter 4 represents the integrated closure of the doctoral work.

After Chapter 2 characterizes the physical and statistical behavior of wind speed, and Chapter 3 evaluates predictive modeling performance, Chapter 4 integrates prediction, uncertainty, regional irregularity, and energy interpretation into a unified physical–statistical framework.

The general logic of Chapter 4 is:

```text
Wind Power Density
→ predictive modeling
→ PI90 uncertainty
→ FNRR structural interpretation
→ free energy
→ usable energy
→ regional projection toward 2028
```

This chapter is essential because the thesis does not stop at forecasting atmospheric behavior. It translates atmospheric prediction into regional wind-energy interpretation.

---

## F.2 Central physical variable: Wind Power Density

The central physical target variable of the thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

WPD expresses the available wind power per unit area.

This variable is central because it transforms the observed atmospheric behavior of wind into a physically meaningful energetic quantity.

The cubic dependence on wind speed implies that small changes in wind behavior may produce amplified changes in energy interpretation. For that reason, uncertainty, irregularity, and zonal behavior must be considered carefully.

---

## F.3 Energetic interpretation

Chapter 4 distinguishes between several energy-related quantities.

### F.3.1 Free energy

Free energy represents the physically available energetic potential before structural irregularity adjustment.

Conceptually:

```text
E_free = accumulated or integrated WPD over a defined temporal horizon
```

This quantity represents the gross energetic potential associated with the regional wind system.

---

### F.3.2 Usable energy

Usable energy represents the portion of free energy that remains after accounting for regional structural irregularity through FNRR.

Conceptually:

```text
E_usable = (1 − FNRR) · E_free
```

where:

- `E_usable` is the structurally usable energy,
- `E_free` is the physically available energy,
- and `FNRR` is the regional irregularity factor.

This distinction is important because not all physically available energy should be interpreted as fully usable energy.

---

### F.3.3 Projected energy

Projected energy refers to the model-based energetic interpretation beyond the historical observational window.

In this thesis:

```text
Historical observational basis: 2017–2022
Projection horizon: toward 2028
```

Projected energy should therefore be interpreted as a model-based energetic scenario, not as a direct observation.

---

## F.4 FNRR as structural regional descriptor

The **Factor de No Regularidad Regional (FNRR)** is one of the original methodological contributions of the thesis.

FNRR is interpreted as a dimensionless descriptor of regional irregularity associated with the internal behavior of WPD.

Its role is to support the distinction between:

```text
physically available energy
```

and

```text
structurally usable energy
```

FNRR should not be interpreted as a universal physical constant. It is a regional, data-derived, structural descriptor defined within the scope of the doctoral framework.

---

## F.5 Why FNRR is needed

A conventional energy-potential analysis may estimate wind speed, WPD, or annual energy values without explicitly considering how irregularity affects usability.

However, in a regional wind-energy system, high energetic potential does not automatically imply stable usable potential.

FNRR is introduced because the thesis needs to quantify whether the energetic structure is:

- regular or irregular,
- concentrated or dispersed,
- structurally stable or unstable,
- comparable across zones,
- and suitable for cautious energy projection.

The conceptual transition is:

```text
WPD behavior
→ regional irregularity
→ FNRR
→ structural energy adjustment
→ usable energy
```

---

## F.6 PI90 uncertainty support

Chapter 4 must be interpreted together with the PI90 uncertainty layer.

A 90% prediction interval is used to represent the uncertainty associated with forecasted or projected quantities.

Conceptually:

```text
PI90 = [lower bound, upper bound]
```

The role of PI90 is to prevent projected energy from being interpreted as a single deterministic value.

Instead, the thesis interprets energy projection as an uncertainty-aware scenario.

The uncertainty layer supports the distinction between:

- central projected value,
- lower plausible bound,
- upper plausible bound,
- empirical interval behavior,
- and calibrated uncertainty interpretation.

---

## F.7 Relationship between PI90 and FNRR

PI90 and FNRR answer different but complementary questions.

| Component | Main question |
|---|---|
| **PI90** | How uncertain is the predicted or projected value? |
| **FNRR** | How irregular is the regional energetic structure? |

PI90 represents predictive uncertainty.

FNRR represents structural regional irregularity.

Together, they support a more cautious and physically meaningful interpretation of projected wind-energy potential.

---

## F.8 Energy-projection logic

The energy-projection stage follows this conceptual sequence:

```text
processed zonal data
→ WPD construction
→ model prediction
→ PI90 uncertainty
→ FNRR computation
→ free-energy estimation
→ usable-energy estimation
→ projection toward 2028
```

This sequence is important because the final energy projection is not an isolated output.

It depends on:

- data traceability,
- preprocessing,
- physical construction of WPD,
- predictive modeling,
- uncertainty calibration,
- structural irregularity interpretation,
- and zonal organization.

---

## F.9 Chapter 4 result folders

The main Chapter 4 result folders are:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

Each folder plays a different role.

| Repository location | Role |
|---|---|
| `04_fnrr_outputs/` | Documents FNRR and structural irregularity support. |
| `05_energy_projection/` | Documents free energy, usable energy, and projection logic. |
| `07_FIGURES/chapter_4/` | Stores visual evidence for Chapter 4. |
| `08_TABLES/chapter_4/` | Stores numerical evidence for Chapter 4. |

Together, these locations form the Chapter 4 evidence layer.

---

## F.10 Chapter 4 figures

The visual evidence for Chapter 4 is located in:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
```

The figures support the interpretation of:

- annual free energy,
- annual usable energy,
- PI90-supported energy behavior,
- annual FNRR,
- FNRR projection from 2017 to 2028,
- projected free energy,
- projected usable energy,
- and quarterly WPD projection.

These figures provide visual support for the final energetic interpretation of the thesis.

---

## F.11 Scientific role of Chapter 4 figures

Chapter 4 figures should not be interpreted as decorative images.

They represent the visual evidence of the integrated energetic framework.

Their role is to show how the thesis moves from:

```text
prediction
→ uncertainty
→ irregularity
→ free energy
→ usable energy
→ regional projection
```

The figures allow reviewers to inspect whether the energetic interpretation is consistent across zones and across the projection horizon.

---

## F.12 Chapter 4 tables

The numerical evidence for Chapter 4 is located in:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

This folder contains tables associated with:

- annual FNRR and coherence,
- WPD projection,
- free energy,
- usable energy,
- PI90 intervals,
- quarterly energy summaries,
- integrated annual outputs,
- and projection structures from 2017 to 2028.

These tables provide the numerical support required to verify the results discussed in Chapter 4.

---

## F.13 Scientific role of Chapter 4 tables

Chapter 4 tables support the quantitative interpretation of:

- projected WPD,
- uncertainty intervals,
- regional irregularity,
- energy available before adjustment,
- energy usable after FNRR adjustment,
- and temporal evolution toward 2028.

The tables should be interpreted together with the figures.

The figures provide visual interpretation.

The tables provide numerical verification.

---

## F.14 Annual projection outputs

Annual projection outputs support the interpretation of year-by-year energetic behavior.

These outputs are relevant because the thesis evaluates how wind-energy potential evolves across the projection horizon.

The annual structure supports interpretation of:

- long-term energetic tendency,
- interannual variability,
- FNRR evolution,
- free energy,
- usable energy,
- and uncertainty-supported projection.

The projection should always be interpreted as model-based and conditioned by the assumptions of the doctoral workflow.

---

## F.15 Quarterly projection outputs

Quarterly outputs support a more detailed temporal interpretation of projected energy behavior.

They allow the thesis to examine whether the energetic signal changes within the year, rather than only at the annual scale.

Quarterly outputs are relevant because wind behavior may vary seasonally or intra-annually.

The quarterly structure supports interpretation of:

- subannual WPD behavior,
- free energy by quarter,
- usable energy by quarter,
- FNRR and coherence by quarter,
- and PI90-supported uncertainty by quarter.

---

## F.16 WPD projection outputs

WPD projection outputs represent the projected behavior of the central energetic variable.

They support the transition from forecasted atmospheric behavior to energy-potential interpretation.

Projected WPD must be interpreted under:

- zonal structure,
- prediction horizon,
- uncertainty,
- and physical sensitivity to wind speed.

Because WPD depends on `v³`, projected WPD values should be interpreted with caution and always in relation to uncertainty and FNRR.

---

## F.17 Free-energy outputs

Free-energy outputs represent the energetic potential before structural irregularity adjustment.

These outputs are necessary because they show the physically available energetic potential implied by the WPD behavior.

However, free energy should not be interpreted as fully usable energy.

It represents the gross energetic potential of the regional wind system.

---

## F.18 Usable-energy outputs

Usable-energy outputs represent the energy remaining after FNRR adjustment.

The central relationship is:

```text
E_usable = (1 − FNRR) · E_free
```

This output is important because it introduces a more cautious interpretation of wind-energy potential.

A zone may present significant free energy while also showing irregularity that reduces the structurally usable component.

---

## F.19 Coherence and regional irregularity

Some Chapter 4 outputs refer to coherence or structural behavior by zone.

These outputs should be interpreted as support for the regional irregularity framework.

The purpose is to evaluate whether each zone presents stable or irregular energetic behavior over the analysis and projection horizon.

This supports the thesis argument that regional wind-energy interpretation requires more than average WPD or total energy.

---

## F.20 Relationship with Chapter 2

Chapter 4 depends on the physical characterization developed in Chapter 2.

The transition is:

```text
wind-speed characterization
→ distributional structure
→ temporal and spectral behavior
→ WPD construction
→ energy interpretation
```

Chapter 2 provides the physical foundation required to justify why wind behavior must be interpreted carefully before energy projection.

---

## F.21 Relationship with Chapter 3

Chapter 4 also depends on the predictive modeling stage developed in Chapter 3.

The transition is:

```text
predictive modeling
→ deterministic evaluation
→ uncertainty-aware outputs
→ FNRR support
→ energy projection
```

Chapter 3 provides the model-based forecasts and uncertainty structures required for Chapter 4.

Therefore, Chapter 4 should be interpreted as the energetic closure of the predictive framework, not as an isolated projection exercise.

---

## F.22 Relationship with Appendix G

The formal physical and mathematical formulation of the model and FNRR should be documented in:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.docx
```

If the Markdown companion file is added, it should also be referenced as:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

Appendix F documents extended Chapter 4 results.

Appendix G should document the mathematical and physical formulation underlying those results.

The relationship is:

```text
Appendix F → extended results and interpretation
Appendix G → formal physical and mathematical support
```

---

## F.23 Relationship with code

The Chapter 4 extended results should be reproducible from:

```text
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
03_CODE/08_utils/
```

The folder `03_CODE/06_hybrid_tdq/` reflects the current repository naming. In this appendix, it should be interpreted as part of the hybrid physical–statistical integration stage of the doctoral workflow.

The computational relationship is:

```text
processed zonal data
→ WPD construction
→ predictive outputs
→ PI90 uncertainty
→ FNRR computation
→ energy integration
→ projection outputs
→ Chapter 4 extended results
```

---

## F.24 Relationship with reproducibility

The Chapter 4 results should be interpreted together with:

```text
07_REPRODUCIBILITY/
```

The reproducibility section provides execution logic, software environment information, and validation support.

For Chapter 4, reproducibility requires that reviewers understand:

- how WPD was constructed,
- how predictions were obtained,
- how uncertainty intervals were generated,
- how FNRR was computed,
- how free energy was estimated,
- how usable energy was derived,
- and how projection outputs were organized.

---

## F.25 Interpretation of internal workflow labels

Some Chapter 4 files may include internal labels such as:

```text
TDQ
PIESS
FNRR
WPD
Eh
PI90
BAYES
ML
DL
```

These labels should be interpreted as internal workflow, modeling, uncertainty, or traceability labels.

For doctoral evaluation, the scientific interpretation should remain focused on:

- physical construction of WPD,
- uncertainty-aware prediction,
- FNRR as a structural regional descriptor,
- free-energy estimation,
- usable-energy interpretation,
- and regional projection.

Internal labels should not be overinterpreted as separate theoretical claims unless they are formally defined in the corresponding appendix.

---

## F.26 Methodological caution

Projected energy values should not be interpreted as direct observations.

They are model-based scenarios derived from:

- the historical observational basis,
- preprocessing,
- physical construction of WPD,
- predictive modeling,
- uncertainty quantification,
- FNRR structural interpretation,
- and the projection horizon.

Therefore, projected energy should be interpreted as a scientifically constrained scenario, not as a guaranteed future value.

---

## F.27 What this appendix does not claim

This appendix does not claim that projected values are certain.

It does not claim that FNRR eliminates uncertainty.

It does not claim that all physically available energy is usable.

It does not claim that a single zone represents the entire department of Nariño.

Instead, it documents extended evidence supporting a cautious energetic interpretation based on physical modeling, predictive outputs, uncertainty, regional irregularity, and energy projection.

---

## F.28 Closure criterion

The extended results of Chapter 4 are considered sufficiently documented when:

1. WPD is identified as the central physical target variable,
2. free energy and usable energy are distinguished,
3. FNRR is interpreted as a structural regional descriptor,
4. PI90 uncertainty is connected to projection,
5. annual and quarterly outputs are documented,
6. figures are connected to tables,
7. tables are connected to code,
8. internal labels are interpreted with caution,
9. projection is described as model-based,
10. and Chapter 4 is clearly linked to Chapters 2 and 3.

---

## F.29 Final statement

The extended results of Chapter 4 provide the energetic closure of the doctoral thesis.

Their central message is:

```text
Wind-energy projection must be interpreted through physical construction,
predictive modeling, uncertainty quantification, regional irregularity,
and the distinction between free and usable energy.
```

For that reason, Appendix F supports the final scientific transition from wind prediction to regional energy-potential interpretation.

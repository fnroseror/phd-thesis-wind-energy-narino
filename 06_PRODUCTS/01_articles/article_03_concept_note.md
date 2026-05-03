# Article 03 — Concept Note

## Tentative title

**FNRR as a structural indicator of regional wind-energy irregularity and usable energy estimation under uncertainty**

---

## Current status

```text
Status: Concept note
Maturity level: Pre-manuscript
Repository role: Publication planning and scientific traceability
```

This file does not represent a submitted, accepted, or published manuscript.

It defines the scientific scope, evidence base, methodological orientation, and development path for the third derivative article projected from the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

---

## 1. Article role within the publication portfolio

This article is intended to be the third scientific publication derived from the doctoral thesis.

Its role is to present the most original structural and energetic contribution of the doctoral work: the definition and interpretation of the **Factor de No Regularidad Regional (FNRR)** as a bounded, dimensionless, robust descriptor of regional irregularity in Wind Power Density behavior.

The article corresponds mainly to the scientific development associated with Chapter 4 of the thesis.

The publication sequence is:

```text
Article 01
Physical–statistical characterization of wind and WPD

Article 02
Predictive modeling and model comparison

Article 03
FNRR, uncertainty, free energy, and usable energy
```

Article 03 should function as the conceptual and methodological closure of the publication portfolio.

---

## 2. Scientific problem

In wind-energy assessment, the existence of physically available energetic potential does not automatically imply the same degree of structural usability.

A region may present relevant wind-energy potential while also exhibiting irregularity, dispersion, intermittency, or uncertainty that limits the interpretation of that potential as usable energy.

Traditional wind-energy assessment frequently emphasizes variables such as:

- wind speed,
- Wind Power Density,
- annual energy,
- model performance,
- or projected production.

However, these quantities may not explicitly distinguish between:

```text
physically available energy
```

and

```text
structurally usable energy
```

This distinction is essential in regional energy analysis because energetic magnitude alone does not describe regularity, stability, or usability.

The scientific problem can be stated as follows:

```text
How can regional irregularity in Wind Power Density be quantified through a physically interpretable, mathematically bounded, and robust descriptor, and how can this descriptor support the distinction between free energy and usable energy under uncertainty?
```

---

## 3. Main objective

To define and analyze the **Factor de No Regularidad Regional (FNRR)** as a structural indicator of regional wind-energy irregularity and to relate it to the estimation of usable wind energy under uncertainty.

---

## 4. Specific objectives

1. To formalize FNRR as a dimensionless structural descriptor derived from the robust distributional behavior of Wind Power Density.

2. To establish the mathematical boundedness and physical interpretation of FNRR.

3. To distinguish between physically available free energy and structurally usable energy.

4. To connect FNRR with uncertainty-aware wind-energy projection.

5. To analyze FNRR behavior by analytical zone and temporal window.

6. To interpret annual and quarterly energy-projection outputs under regional irregularity.

7. To provide a methodological framework for avoiding overinterpretation of free energy as fully usable energy.

---

## 5. Expected contribution

This article is expected to contribute:

- the formal introduction of FNRR as an original regional irregularity descriptor;
- a mathematical definition of FNRR based on robust WPD quantiles;
- proof or formal argumentation that FNRR is dimensionless and bounded;
- a scientific distinction between free energy and usable energy;
- an interpretation of regional wind-energy irregularity under uncertainty;
- a bridge between physical modeling, predictive outputs, PI90 uncertainty, and energy usability;
- and a methodological contribution for regional wind-energy assessment.

The article should not claim that FNRR is a universal physical constant.

It should present FNRR as a regional, data-derived, physically interpretable, and mathematically bounded descriptor within the scope of the doctoral framework.

---

## 6. Proposed article type

```text
Original research article
```

Possible journal areas:

- renewable energy,
- wind-energy assessment,
- energy systems analysis,
- uncertainty quantification,
- applied physics,
- physical–statistical modeling,
- regional energy planning,
- environmental modeling.

This concept note does not define a final target journal.

Target-journal selection should be performed after the manuscript scope, mathematical formulation, result selection, figure selection, and novelty statement are consolidated.

---

## 7. Proposed abstract draft

Wind-energy assessment often reports physically available energetic potential without explicitly quantifying the structural irregularity that may affect its usability. This study introduces the Factor de No Regularidad Regional (FNRR) as a dimensionless and robust descriptor of regional irregularity in Wind Power Density behavior. The proposed framework distinguishes between free energy, interpreted as physically available energetic potential, and usable energy, interpreted as the fraction of energy remaining after structural irregularity adjustment. FNRR is formulated from robust quantile-based properties of Wind Power Density and is integrated with uncertainty-aware energy projection using PI90-supported predictive outputs. The framework is applied to the regional wind-energy system of Nariño, Colombia, organized into analytical zones and projected toward 2028. The study contributes a physical–statistical interpretation that prevents the overestimation of usable wind-energy potential and provides a methodological bridge between prediction, uncertainty, regional irregularity, and energy usability.

---

## 8. Keywords

Suggested keywords:

```text
FNRR
Wind Power Density
Usable energy
Free energy
Wind-energy irregularity
Uncertainty quantification
Prediction intervals
Regional energy projection
Physical–statistical modeling
Renewable energy
Wind-energy assessment
Nariño
PI90
```

---

## 9. Central physical variable

The central physical target variable of the thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

WPD expresses the available wind power per unit area.

Because WPD depends cubically on wind speed, regional variability in wind behavior may be amplified in the energetic interpretation.

For this reason, the article should frame FNRR as a descriptor applied to the energetic behavior of the wind system, not merely to wind speed alone.

---

## 10. Conceptual basis of FNRR

FNRR is introduced to quantify regional irregularity in the WPD distribution.

Conceptually:

```text
WPD behavior
→ robust central dispersion
→ regional irregularity
→ FNRR
→ structural energy adjustment
→ usable energy
```

FNRR is not a conventional predictive metric.

It does not measure model error.

It does not replace RMSE, MAE, R², Skill Score, or PI90.

Instead, it provides a structural descriptor of how irregular the regional energetic signal is.

---

## 11. Formal definition of FNRR

Let:

```text
Y_z(T) = {WPD_z(t) : t ∈ T}
```

be the Wind Power Density sample for zone `z` over a temporal window `T`.

Let:

```text
Q_25,z(T) = 25th percentile of Y_z(T)
Q_75,z(T) = 75th percentile of Y_z(T)
```

The interquartile range is:

```text
IQR_z(T) = Q_75,z(T) − Q_25,z(T)
```

FNRR is defined as:

```text
FNRR_z(T) = IQR_z(T) / [Q_75,z(T) + Q_25,z(T) + ε_z]
```

where `ε_z` is a small positive numerical-stability term expressed in the same physical unit as WPD.

The formulation is dimensionally consistent because the numerator and denominator have the same unit.

Therefore, FNRR is dimensionless.

The formal mathematical support is documented in:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

---

## 12. Mathematical properties to emphasize

The article should emphasize the following properties:

### 12.1 Nonnegativity

For nonnegative WPD:

```text
FNRR_z(T) ≥ 0
```

### 12.2 Boundedness

Under the stated assumptions:

```text
0 ≤ FNRR_z(T) < 1
```

A conservative practical statement is:

```text
0 ≤ FNRR_z(T) ≤ 1
```

### 12.3 Dimensional consistency

FNRR is dimensionless because it is the ratio between two quantities with the same physical unit.

### 12.4 Robustness

FNRR is based on quantiles rather than extreme values.

This makes the descriptor less sensitive to isolated extreme WPD events.

### 12.5 Scale behavior

If WPD and the stability term are scaled consistently, FNRR measures relative irregularity rather than absolute energetic magnitude.

---

## 13. Free energy and usable energy

The article should distinguish clearly between:

```text
E_free
```

and

```text
E_usable
```

### 13.1 Free energy

Free energy represents the physically available energetic potential before structural irregularity adjustment.

Conceptually:

```text
E_free = accumulated or integrated WPD over a temporal window
```

### 13.2 Usable energy

Usable energy represents the portion of free energy that remains after accounting for structural irregularity through FNRR.

The central relationship is:

```text
E_usable = (1 − FNRR) · E_free
```

This relationship ensures that usable energy cannot exceed free energy under the stated assumptions.

---

## 14. Mathematical interpretation of usable energy

If:

```text
0 ≤ FNRR < 1
```

and:

```text
E_free ≥ 0
```

then:

```text
0 ≤ E_usable ≤ E_free
```

This proves that the FNRR adjustment cannot create energy artificially.

It can only reduce the physically available energy according to structural irregularity.

The derivative with respect to FNRR is:

```text
∂E_usable/∂FNRR = −E_free
```

Therefore, usable energy decreases as irregularity increases.

This provides a coherent mathematical interpretation:

```text
higher irregularity → lower structurally usable energy
```

---

## 15. Relationship with uncertainty

FNRR and PI90 uncertainty should be interpreted as complementary components.

| Component | Main question |
|---|---|
| PI90 | How uncertain is the prediction? |
| FNRR | How irregular is the regional energetic structure? |

PI90 represents predictive uncertainty.

FNRR represents structural irregularity.

Together, they support a more cautious interpretation of regional wind-energy projection.

The article should make clear that FNRR does not replace uncertainty intervals.

Instead, FNRR complements uncertainty by describing the irregularity of the energetic structure.

---

## 16. Relationship with prediction

FNRR depends on WPD behavior.

In the article, WPD may be historical, predicted, or projected depending on the temporal window.

The general sequence is:

```text
observed WPD
→ predicted WPD
→ uncertainty-aware WPD
→ FNRR
→ energy interpretation
```

The predictive support is derived from Article 02 and Chapter 3 of the thesis.

Article 03 should not repeat the full model-comparison discussion.

It should use the predictive outputs as input for the structural and energetic interpretation.

---

## 17. Relationship with energy projection

The article should connect FNRR to energy projection toward 2028.

The conceptual sequence is:

```text
projected WPD
→ free energy
→ FNRR structural adjustment
→ usable energy
→ regional energy interpretation
```

Projection should be described as a model-based scenario, not as direct observation.

The article should avoid presenting projected values as guaranteed future outcomes.

---

## 18. Annual and quarterly interpretation

FNRR can be evaluated over different temporal windows.

For annual analysis:

```text
FNRR_z(year)
```

For quarterly analysis:

```text
FNRR_z(quarter)
```

Annual analysis supports long-term interpretation.

Quarterly analysis supports subannual or seasonal interpretation.

This allows the article to examine whether irregularity changes across time scales.

---

## 19. Zonal interpretation

The article should interpret FNRR across the four analytical zones:

```text
Z1, Z2, Z3, Z4
```

Zonal interpretation is necessary because regional wind-energy behavior is heterogeneous.

A zone may present:

- high free energy and low irregularity,
- high free energy and high irregularity,
- moderate energy with greater regularity,
- or lower energy with lower structural usability.

The article should avoid ranking zones only by free energy.

The main interpretation should combine:

```text
free energy + FNRR + usable energy + uncertainty
```

---

## 20. Proposed methodological structure

The methodology of the article should follow this structure:

```text
1. Study area and zonal structure
2. Wind Power Density formulation
3. Prediction and uncertainty support
4. Definition of free energy
5. Definition of FNRR
6. Mathematical properties of FNRR
7. Definition of usable energy
8. Annual and quarterly computation
9. Regional interpretation by zone
10. Projection toward 2028
```

This structure keeps the article focused on FNRR and usable energy.

---

## 21. Suggested figures for the article

A preliminary figure set could include:

| Figure | Source | Purpose |
|---|---|---|
| FNRR conceptual diagram | To be created | Shows WPD → FNRR → usable energy. |
| Annual FNRR behavior | Chapter 4 figures | Shows irregularity evolution by year. |
| Projected FNRR 2017–2028 | Chapter 4 figures | Shows temporal evolution of irregularity. |
| Free energy projection | Chapter 4 figures | Shows physically available energy. |
| Usable energy projection | Chapter 4 figures | Shows structurally adjusted energy. |
| PI90-supported energy figure | Chapter 4 figures | Shows uncertainty-aware interpretation. |
| Quarterly WPD or energy figure | Chapter 4 figures | Shows subannual structure. |

Primary figure folder:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
```

The final manuscript should use a controlled number of figures.

Additional figures may be moved to supplementary material.

---

## 22. Suggested tables for the article

A preliminary table set could include:

| Table | Source | Purpose |
|---|---|---|
| Mathematical definition table | Appendix G | Defines FNRR, free energy, usable energy, PI90. |
| Annual FNRR table | Chapter 4 tables | Supports yearly irregularity interpretation. |
| Annual free and usable energy table | Chapter 4 tables | Supports energy distinction. |
| Quarterly FNRR table | Chapter 4 tables | Supports subannual interpretation. |
| Quarterly WPD/energy table | Chapter 4 tables | Supports temporal projection. |
| PI90-supported energy table | Chapter 4 tables | Supports uncertainty-aware interpretation. |

Primary table folder:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

The article should include only the tables required for a clear scientific narrative.

Additional tables may be referenced as supplementary material.

---

## 23. Expected results narrative

The results section should be organized around five interpretive blocks.

### 23.1 Formal behavior of FNRR

Purpose:

```text
show that FNRR is bounded, dimensionless, robust, and interpretable
```

### 23.2 Zonal irregularity

Purpose:

```text
compare structural irregularity across analytical zones
```

### 23.3 Free energy versus usable energy

Purpose:

```text
demonstrate why available energy should not be treated as fully usable energy
```

### 23.4 Uncertainty-aware projection

Purpose:

```text
interpret energy projection under PI90-supported uncertainty
```

### 23.5 Annual and quarterly evolution

Purpose:

```text
evaluate how energy and irregularity change across temporal windows
```

---

## 24. Discussion focus

The discussion should emphasize:

- why energetic magnitude alone is insufficient;
- why FNRR helps quantify structural irregularity;
- how FNRR differs from conventional predictive metrics;
- how FNRR complements PI90 uncertainty;
- why free energy and usable energy should be distinguished;
- how regional interpretation changes when FNRR is included;
- and how this framework may support cautious energy-planning interpretation.

The discussion should avoid presenting FNRR as a universal law.

It should present FNRR as a bounded and interpretable methodological descriptor derived from the doctoral framework.

---

## 25. Main novelty statement

A possible novelty statement is:

```text
This study introduces FNRR as a bounded, dimensionless, quantile-based descriptor of regional irregularity in Wind Power Density and uses it to distinguish physically available free energy from structurally usable energy under uncertainty.
```

A stronger version for the manuscript introduction:

```text
The novelty of this study lies in moving beyond the estimation of wind-energy potential toward a structural interpretation of usability, where regional irregularity is quantified through FNRR and incorporated into the distinction between free energy and usable energy.
```

---

## 26. Repository evidence supporting the article

Primary support:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
05_APPENDICES_SUPPORT/Anexo_F_Resultados_Extendidos_Cap4.md
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.docx
```

Secondary support:

```text
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
07_REPRODUCIBILITY/
```

---

## 27. Relationship with Article 01

Article 03 depends on Article 01 because FNRR is applied to WPD behavior, and WPD depends on the physical characterization of wind speed.

The relationship is:

```text
Article 01
characterizes wind behavior and WPD

Article 03
uses WPD structure to define irregularity and usable energy
```

Article 01 provides the physical basis for FNRR.

---

## 28. Relationship with Article 02

Article 03 depends on Article 02 because uncertainty-aware energy projection uses predictive outputs.

The relationship is:

```text
Article 02
produces forecasts and uncertainty-aware predictive outputs

Article 03
uses those outputs to interpret free energy, FNRR, and usable energy
```

Article 02 provides the predictive basis.

Article 03 provides the structural energetic interpretation.

---

## 29. Possible manuscript structure

A recommended manuscript structure is:

```text
1. Introduction
2. Study area and data basis
3. Wind Power Density and energy interpretation
4. Predictive and uncertainty support
5. FNRR formulation
   5.1 Definition
   5.2 Dimensional consistency
   5.3 Mathematical boundedness
   5.4 Robust quantile-based interpretation
6. Free energy and usable energy
7. Results
   7.1 FNRR by zone
   7.2 Annual irregularity behavior
   7.3 Quarterly irregularity behavior
   7.4 Free energy versus usable energy
   7.5 Projection toward 2028
8. Discussion
9. Limitations
10. Conclusions
11. Data and code availability
12. References
```

---

## 30. Limitations to declare

The article should declare limitations honestly.

Possible limitations include:

- FNRR is data-derived and depends on preprocessing, WPD construction, temporal window, and quantile definition;
- FNRR is not a universal physical constant;
- usable energy is a structural interpretation, not a direct measurement of electrical production;
- projection outputs are model-based scenarios, not observed future values;
- uncertainty in FNRR itself may require further development;
- the framework requires validation in other regions before generalization;
- and the current formulation should be interpreted within the scope of the doctoral dataset and workflow.

These limitations strengthen the article because they show scientific caution.

---

## 31. Ethical and authorship note

This concept note does not define final authorship.

Authorship should be determined according to actual scientific contribution, thesis supervision, data work, methodological support, mathematical development, writing, review, and institutional guidelines.

The article should clearly distinguish between:

- thesis-validated results,
- article-specific mathematical refinement,
- future work,
- and broader conceptual interpretations.

---

## 32. Internal label caution

Some repository outputs may contain internal labels such as:

```text
TDQ
PIESS
BAYES
ML
DL
WPD
Eh
FNRR
PI90
ELSEVIER
NATURE
ANEXO
```

For article development, these labels should be treated carefully.

The article narrative should prioritize formally defensible scientific language:

- Wind Power Density,
- physical–statistical modeling,
- uncertainty quantification,
- FNRR,
- free energy,
- usable energy,
- regional irregularity,
- and energy projection.

Internal labels should not be overinterpreted as publication claims, journal claims, or independent theoretical claims unless formally defined in the manuscript.

---

## 33. Development tasks

Next tasks for converting this concept note into a manuscript:

1. Select the final target journal category.
2. Define final article length and figure/table limits.
3. Select final Chapter 4 figures.
4. Select final Chapter 4 tables.
5. Confirm the final FNRR mathematical notation.
6. Prepare a compact derivation of FNRR for the methodology section.
7. Prepare a formal explanation of free energy and usable energy.
8. Write the introduction around energy usability and irregularity.
9. Convert Chapter 4 results into article-style results.
10. Write discussion around uncertainty, usability, and regional interpretation.
11. Prepare data/code availability statement.
12. Prepare references in the target journal format.

---

## 34. Current development status

```text
Current status: Concept note expanded
Next stage: Draft manuscript
Priority: High
Dependency: Final verification of Chapter 4 figures, tables, FNRR outputs, and Appendix G
```

---

## 35. Final note

This article should function as the original structural contribution of the publication portfolio derived from the doctoral thesis.

Its central message should be:

```text
Wind-energy potential should not be interpreted only as available energy;
it must also be evaluated through uncertainty, regional irregularity,
and the distinction between free and usable energy.
```

Article 03 therefore establishes the final conceptual bridge between physical prediction and regional wind-energy usability.

# Patent Disclosure Note

## Preliminary title

**System and method for estimating structurally usable wind-energy potential under regional non-regularity conditions using physical–statistical modeling, uncertainty quantification, and FNRR**

---

## Current status

```text
Status: Preliminary technical disclosure note
Maturity level: Conceptual / technical basis
Repository role: Intellectual-property planning and traceability
Formal filing status: Not filed
Legal status: Not a patent application
```

This document does **not** constitute a formal patent application.

It is a preliminary, non-confidential, repository-level technical disclosure note derived from the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

Any formal intellectual-property process must be reviewed by qualified legal, technical, and institutional authorities before filing.

---

## 1. Purpose of this document

The purpose of this note is to document a possible patent-oriented technical development derived from the doctoral thesis.

The potential development is associated with a system, method, or computational workflow for estimating **structurally usable wind-energy potential** by integrating:

- meteorological observations,
- physical construction of Wind Power Density,
- predictive modeling,
- uncertainty quantification,
- regional non-regularity estimation through FNRR,
- distinction between free energy and usable energy,
- and decision-support interpretation.

This document is intended to support future evaluation of protectability, novelty, technical applicability, and institutional intellectual-property strategy.

---

## 2. Technical field

The possible invention belongs to the technical field of:

- renewable energy systems,
- wind-energy assessment,
- physical–statistical modeling,
- computational energy forecasting,
- uncertainty-aware prediction,
- energy decision-support systems,
- environmental data analytics,
- and regional energy-planning technologies.

The development is especially oriented toward wind-energy systems where meteorological variability, regional heterogeneity, and uncertainty affect the interpretation of available energy.

---

## 3. Technical problem

Conventional wind-energy assessment often estimates wind speed, Wind Power Density, annual energy, or projected energy production.

However, these outputs may not explicitly distinguish between:

```text
physically available energy
```

and

```text
structurally usable energy
```

This distinction is technically relevant because a region may present considerable wind-energy potential while also exhibiting:

- temporal variability,
- regional irregularity,
- intermittency,
- uncertainty,
- heterogeneous station-level behavior,
- and instability in the energetic signal.

In such cases, the gross energetic potential may overstate the energy that can be interpreted as structurally usable.

The technical problem can be stated as follows:

```text
Existing wind-energy assessment methods may estimate available wind-energy potential,
but they do not always provide an interpretable and regionally structured mechanism
for adjusting available energy according to irregularity, uncertainty,
and usability conditions.
```

---

## 4. Proposed technical solution

The proposed solution consists of a physical–statistical computational method for estimating structurally usable wind-energy potential.

The method integrates:

1. **Meteorological data ingestion**  
   Receives meteorological records from multiple stations.

2. **Physical transformation**  
   Computes air density and Wind Power Density from meteorological variables.

3. **Predictive modeling**  
   Generates wind-energy-related forecasts using classical, machine learning, deep learning, or hybrid physical–statistical models.

4. **Uncertainty quantification**  
   Estimates prediction uncertainty using PI90 or related interval structures.

5. **Regional non-regularity estimation**  
   Computes the Factor de No Regularidad Regional (**FNRR**) as a structural descriptor of WPD irregularity.

6. **Energy adjustment**  
   Distinguishes between free energy and usable energy.

7. **Decision-support interpretation**  
   Provides a structured interpretation of regional wind-energy usability.

The central computational chain is:

```text
meteorological observations
→ physical variables
→ Wind Power Density
→ predictive modeling
→ uncertainty quantification
→ FNRR
→ free energy
→ usable energy
→ decision-support output
```

---

## 5. Central physical variable

The central physical variable is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

WPD is used because it transforms wind behavior into an energetic quantity.

The cubic dependence on wind speed means that small variations in wind behavior may produce amplified energetic effects.

This justifies the need for physical–statistical modeling and uncertainty-aware interpretation.

---

## 6. Regional non-regularity descriptor

The proposed technical development uses **FNRR** as a regional structural descriptor.

FNRR is defined from robust quantile-based properties of WPD.

Let:

```text
Y_z(T) = {WPD_z(t) : t ∈ T}
```

be the WPD sample for zone `z` over a temporal window `T`.

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

where `ε_z` is a small positive numerical-stability term expressed in the same unit as WPD.

This formulation makes FNRR:

- dimensionless,
- bounded,
- robust to extreme values,
- interpretable,
- and suitable for regional comparison.

---

## 7. Free energy and usable energy

The possible invention distinguishes between:

```text
E_free
```

and

```text
E_usable
```

### Free energy

Free energy represents physically available energetic potential before structural irregularity adjustment.

Conceptually:

```text
E_free = accumulated or integrated WPD over a temporal window
```

### Usable energy

Usable energy represents the energetic component remaining after regional irregularity adjustment.

The central relationship is:

```text
E_usable = (1 − FNRR) · E_free
```

This relationship prevents the direct interpretation of all physically available energy as fully usable energy.

Under the stated assumptions:

```text
0 ≤ E_usable ≤ E_free
```

Thus, the adjustment cannot create energy artificially; it only reduces the free-energy estimate according to structural irregularity.

---

## 8. Novelty logic

The potential novelty may be explored around the integration of the following elements:

1. **WPD-centered physical formulation**  
   The method uses Wind Power Density as the central energetic target rather than relying only on wind speed.

2. **Uncertainty-aware prediction**  
   The method incorporates prediction intervals or equivalent uncertainty-support structures.

3. **Regional non-regularity descriptor**  
   FNRR provides a bounded and dimensionless descriptor of structural irregularity in the WPD signal.

4. **Free-energy versus usable-energy distinction**  
   The method explicitly transforms physically available energy into structurally usable energy.

5. **Decision-support interpretation**  
   The output supports cautious regional interpretation of wind-energy potential.

The novelty should be evaluated through formal prior-art analysis before drafting claims or filing any application.

---

## 9. Possible technical modules

A possible system implementation may include the following modules.

### 9.1 Data ingestion module

Receives meteorological records from one or more stations.

Possible inputs include:

- station identifier,
- date-time record,
- wind speed,
- atmospheric pressure,
- temperature,
- relative humidity,
- and other meteorological variables.

### 9.2 Data preprocessing module

Performs data cleaning, quality checks, temporal organization, unit harmonization, and station-to-zone assignment.

### 9.3 Physical transformation module

Computes air density and Wind Power Density.

Core transformation:

```text
meteorological variables → ρ → WPD
```

### 9.4 Predictive modeling module

Generates forecasts for WPD or related energetic variables.

Possible model families include:

- classical time-series models,
- machine learning models,
- deep learning models,
- hybrid physical–statistical models.

### 9.5 Uncertainty module

Computes prediction intervals, coverage metrics, or related uncertainty-support outputs.

Possible output:

```text
PI90 = [lower bound, upper bound]
```

### 9.6 Regional irregularity module

Computes FNRR for each analytical zone or temporal window.

### 9.7 Energy-adjustment module

Computes free energy and usable energy.

Core relationship:

```text
E_usable = (1 − FNRR) · E_free
```

### 9.8 Visualization and decision-support module

Presents outputs such as:

- WPD projections,
- uncertainty bands,
- FNRR values,
- free energy,
- usable energy,
- zonal comparisons,
- and regional energy-usability indicators.

These modules are preliminary technical components and should not be interpreted as final patent claims.

---

## 10. Possible method sequence

A possible method sequence is:

```text
Step 1. Acquire meteorological records from multiple stations.
Step 2. Organize records into analytical zones.
Step 3. Apply preprocessing and unit harmonization.
Step 4. Estimate air density.
Step 5. Compute Wind Power Density.
Step 6. Train or apply predictive models.
Step 7. Generate WPD predictions.
Step 8. Quantify prediction uncertainty.
Step 9. Compute FNRR using WPD quantile structure.
Step 10. Estimate free energy.
Step 11. Estimate usable energy using FNRR.
Step 12. Produce regional decision-support outputs.
```

This sequence should be refined after technical and legal review.

---

## 11. Potential technical effect

The potential technical effect of the proposed method is that it provides a structured computational mechanism for estimating wind-energy usability under regional irregularity and uncertainty.

Possible technical effects include:

- improved interpretation of wind-energy potential,
- distinction between gross and usable energy,
- reduction of overestimation risk,
- uncertainty-aware regional energy assessment,
- structured comparison between analytical zones,
- and decision-support output for planning or research.

These effects should be validated with technical evidence before being used in formal patent claims.

---

## 12. Relationship with the doctoral thesis

This potential intellectual-property development is derived from the doctoral thesis.

The thesis provides:

- physical characterization of wind behavior,
- construction of Wind Power Density,
- predictive modeling outputs,
- PI90 uncertainty support,
- FNRR formalization,
- distinction between free energy and usable energy,
- and regional projection toward 2028.

The relationship is:

```text
doctoral thesis
→ physical–statistical framework
→ FNRR and usable-energy formulation
→ possible technical method or system
→ patentability evaluation
```

---

## 13. Repository evidence

The potential patent-oriented development is supported by the following repository sections:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
05_APPENDICES_SUPPORT/Anexo_F_Resultados_Extendidos_Cap4.md
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.docx
07_REPRODUCIBILITY/
```

Supporting sections may also include:

```text
02_DATA_METADATA/
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
```

---

## 14. Relationship with scientific articles

This folder should be coordinated with:

```text
06_PRODUCTS/01_articles/
```

The potential patent pathway is especially connected to:

```text
06_PRODUCTS/01_articles/article_03_concept_note.md
```

because Article 03 focuses on FNRR, regional irregularity, uncertainty, free energy, and usable energy.

Publication strategy and intellectual-property strategy should be coordinated carefully.

Any future disclosure in articles, presentations, dashboards, or public repositories should be reviewed before formal patent filing if protection is pursued.

---

## 15. Public-disclosure caution

This repository is public.

Therefore, this document should avoid unnecessary claim-level disclosure.

The purpose of this note is to preserve a technical direction, not to publish a complete claim set.

Before any formal patent process, the following should be evaluated:

- what has already been publicly disclosed,
- whether novelty may still be preserved,
- whether the method meets patentability criteria,
- whether software-related elements require special treatment,
- whether institutional ownership or co-ownership applies,
- and whether a confidential invention disclosure should be prepared.

---

## 16. What this document does not claim

This document does not claim that:

- a patent has been filed,
- a patent has been granted,
- the invention is legally patentable,
- novelty has been confirmed,
- inventive step has been confirmed,
- industrial applicability has been legally evaluated,
- formal claims have been drafted,
- or the described method is ready for commercial deployment.

This document only preserves a structured technical basis for future evaluation.

---

## 17. Formal review required

Before any formal intellectual-property action, the following reviews are recommended:

1. Technical review by domain experts.
2. Prior-art search.
3. Patentability assessment.
4. Institutional intellectual-property review.
5. Legal review.
6. Authorship and inventorship clarification.
7. Public-disclosure risk assessment.
8. Decision about filing before further publication.

---

## 18. Possible future confidential disclosure structure

A future confidential invention disclosure may include:

```text
1. Title
2. Inventor information
3. Institutional affiliation
4. Technical field
5. Background
6. Technical problem
7. Proposed solution
8. Technical advantages
9. Diagrams
10. Experimental evidence
11. Repository evidence
12. Possible claims
13. Prior disclosures
14. Funding or institutional support
15. Authorship/inventorship declaration
```

This public note should not replace that confidential process.

---

## 19. Possible diagrams to develop

Future diagrams may include:

1. **System architecture diagram**

```text
data ingestion → preprocessing → WPD → prediction → uncertainty → FNRR → usable energy
```

2. **Energy transformation diagram**

```text
free energy → FNRR adjustment → usable energy
```

3. **Decision-support dashboard diagram**

```text
zone → WPD → PI90 → FNRR → E_free → E_usable → recommendation layer
```

4. **Module interaction diagram**

```text
physical module + predictive module + uncertainty module + irregularity module + visualization module
```

These diagrams should be prepared carefully to avoid premature claim-level exposure.

---

## 20. Maturity assessment

Current maturity:

```text
Scientific foundation: Available
Mathematical formulation: Available
Repository evidence: Available
Prototype system: Not formally documented as patent prototype
Formal claims: Not drafted
Patentability search: Pending
Legal review: Pending
Institutional review: Pending
Formal filing: Not completed
```

---

## 21. Recommended next steps

Recommended next steps:

1. Preserve this note as a public, non-confidential technical planning document.
2. Avoid adding claim-level content to the public repository.
3. Prepare a private prior-art search document.
4. Identify what has already been disclosed publicly.
5. Consult the institutional intellectual-property office.
6. Decide whether protection should be pursued before article submission.
7. Prepare a confidential invention disclosure if the pathway is viable.
8. Define whether the protectable element is a method, system, software-assisted process, dashboard, or decision-support architecture.
9. Draft claims only with legal and technical support.
10. Coordinate patent timing with article publication strategy.

---

## 22. Final note

This file documents a possible intellectual-property pathway derived from the doctoral thesis.

Its central principle is:

```text
The doctoral thesis provides the scientific foundation;
this disclosure note preserves a cautious technical basis
for evaluating whether part of the framework can become
a protectable method, system, or decision-support technology.
```

This document should be treated as preliminary, non-confidential, and subject to future legal, technical, and institutional review.

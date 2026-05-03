# 02_patent

## Purpose

This folder contains the preliminary documentary basis for a potential intellectual-property development derived from the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The purpose of this folder is to organize the technical rationale, novelty logic, maturity level, and repository evidence associated with a possible patent-oriented product.

This folder does **not** constitute a formal patent application.

It is a repository-level technical support folder intended to preserve the conceptual and documentary basis for future legal, technical, and institutional evaluation.

---

## 1. Current status

```text
Status: Preliminary patent-oriented documentation
Maturity level: Conceptual / technical disclosure note
Repository role: Intellectual-property planning and traceability
Formal filing status: Not filed
```

The contents of this folder should not be interpreted as a granted patent, a submitted patent application, or a final legal document.

Any formal patent process must be reviewed by qualified intellectual-property professionals and, when applicable, by the corresponding institutional technology-transfer or legal office.

---

## 2. Main file

The main file in this folder is:

```text
patent_disclosure_note.md
```

This file provides a preliminary technical disclosure note for a possible invention derived from the doctoral work.

Its current role is to document:

- tentative title,
- technical problem,
- proposed technical solution,
- novelty logic,
- relationship with the thesis,
- repository evidence,
- maturity level,
- and possible projection toward formal intellectual-property evaluation.

---

## 3. Proposed technical focus

The potential intellectual-property development is associated with a system or method for estimating usable wind energy under regional irregularity conditions.

The technical focus may include:

- physical construction of Wind Power Density,
- hybrid physical–statistical modeling,
- uncertainty-aware prediction,
- FNRR as a structural regional irregularity descriptor,
- distinction between free energy and usable energy,
- and decision-support interpretation for regional wind-energy assessment.

The central conceptual chain is:

```text
meteorological observations
→ Wind Power Density
→ predictive modeling
→ uncertainty quantification
→ FNRR
→ free energy
→ usable energy
→ decision-support interpretation
```

---

## 4. Relationship with the doctoral thesis

This folder is derived from the doctoral thesis, but it is not part of the core evidentiary structure of the thesis.

The thesis establishes the scientific foundation.

The patent-oriented folder explores whether part of that scientific foundation may be formalized as a technical development.

The relationship is:

```text
doctoral thesis
→ physical–statistical framework
→ FNRR and usable-energy interpretation
→ possible technical solution
→ patentability evaluation
```

The potential patent pathway should remain aligned with the validated doctoral contribution and should not overstate the current legal status of the invention.

---

## 5. Relationship with repository evidence

The possible patent-oriented development is supported by the following repository sections:

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

These materials provide scientific and technical support for the potential development.

However, repository evidence is not equivalent to a formal patent application.

---

## 6. Intellectual-property caution

This folder must be handled carefully because patentability may depend on legal and technical conditions such as novelty, inventive step, industrial applicability, sufficient disclosure, and prior public disclosure.

Since this repository is public, the folder should avoid exposing unnecessary claim-level detail before a formal patentability analysis is completed.

Recommended caution:

```text
Document the technical direction.
Avoid premature claim drafting.
Avoid revealing implementation details beyond what is already academically necessary.
Separate scientific publication material from patent-claim material.
Request legal and institutional review before formal filing.
```

---

## 7. What this folder may contain

This folder may contain:

- preliminary invention disclosure notes,
- technical problem statements,
- conceptual diagrams,
- novelty summaries,
- non-confidential technical descriptions,
- maturity assessments,
- patentability-analysis checklists,
- institutional review notes,
- and future claim-drafting support.

---

## 8. What this folder should not contain yet

This folder should not contain, unless formally reviewed:

- final legal claims,
- confidential implementation details,
- unreviewed source code intended as protected invention core,
- commercially sensitive information,
- legal conclusions about patentability,
- statements claiming that a patent has already been filed or granted,
- or technical disclosures that could unnecessarily weaken future protection.

---

## 9. Candidate invention framing

A cautious preliminary framing is:

```text
System and method for estimating structurally usable wind-energy potential
using physical–statistical modeling, uncertainty quantification,
and a regional irregularity descriptor derived from Wind Power Density.
```

This framing remains broad enough for documentation while avoiding premature legal claim language.

---

## 10. Possible invention components

Potential components to evaluate may include:

1. **Data ingestion module**  
   Receives meteorological records from multiple stations.

2. **Physical transformation module**  
   Computes air density and Wind Power Density.

3. **Prediction module**  
   Generates WPD forecasts using physical–statistical or hybrid modeling.

4. **Uncertainty module**  
   Produces PI90 or related prediction intervals.

5. **Irregularity module**  
   Computes FNRR or an equivalent regional irregularity descriptor.

6. **Energy-adjustment module**  
   Estimates free energy and usable energy.

7. **Decision-support module**  
   Presents regional energy-potential interpretation for planning or analysis.

These components are not final patent claims.

They are preliminary technical elements to support future evaluation.

---

## 11. Potential novelty logic

The potential novelty may be explored around the integration of:

- Wind Power Density as the central physical target variable,
- uncertainty-aware prediction,
- regional irregularity quantification through FNRR,
- distinction between free energy and usable energy,
- and decision-support interpretation for regional wind-energy assessment.

The novelty should be evaluated against the state of the art before any formal claim is drafted.

---

## 12. Potential technical problem

A preliminary technical problem may be stated as:

```text
Existing wind-energy assessment methods may estimate available wind-energy potential,
but they do not always provide an interpretable and regionally structured mechanism
for adjusting available energy according to irregularity, uncertainty,
and usability conditions.
```

This statement should be refined after patentability review and prior-art analysis.

---

## 13. Potential technical solution

A preliminary technical solution may be stated as:

```text
A physical–statistical computational method that estimates Wind Power Density,
quantifies prediction uncertainty, computes a regional non-regularity factor,
and transforms free wind-energy potential into structurally usable energy.
```

This solution should remain aligned with the mathematical formulation documented in Appendix G.

---

## 14. Relationship with FNRR

FNRR is the main structural descriptor associated with the potential invention pathway.

The formal support is documented in:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

FNRR should be interpreted as:

```text
a bounded, dimensionless, quantile-based descriptor of regional irregularity
in Wind Power Density behavior.
```

Its role in the potential patent pathway is to support the transformation:

```text
free energy → usable energy
```

through:

```text
E_usable = (1 − FNRR) · E_free
```

---

## 15. Maturity level

Current maturity:

```text
Conceptual and technical basis available
Formal patentability analysis pending
Legal review pending
Institutional review pending
Claim drafting not started
Formal filing not completed
```

This maturity status should be updated only when a real formal step has occurred.

---

## 16. Recommended next steps

Recommended next steps:

1. Review public disclosure risk.
2. Identify what has already been publicly disclosed in the thesis and repository.
3. Conduct a preliminary prior-art search.
4. Define whether the protectable element is a method, system, software-assisted process, dashboard, or decision-support architecture.
5. Consult institutional intellectual-property office or legal counsel.
6. Decide whether to protect before submitting derivative articles.
7. If viable, prepare a confidential invention disclosure.
8. Draft formal claims only after legal and technical review.

---

## 17. Relationship with articles

This folder should be coordinated with:

```text
06_PRODUCTS/01_articles/
```

Publication and patent strategy should be handled carefully.

If formal patent protection is considered, the patent strategy should be evaluated before disclosing additional technical details in articles, presentations, dashboards, or public repositories.

---

## 18. Methodological caution

This folder documents a potential intellectual-property pathway.

It does not establish patentability.

It does not guarantee novelty.

It does not guarantee inventive step.

It does not guarantee industrial applicability.

It does not replace legal review.

It does not replace a formal patent application.

Its role is to preserve a structured basis for future evaluation.

---

## 19. Closure criterion

This folder is considered properly organized when:

1. the technical problem is defined,
2. the proposed solution is described cautiously,
3. the novelty logic is documented without overstating legal conclusions,
4. the relation with FNRR and usable energy is clear,
5. repository evidence is linked,
6. maturity level is stated honestly,
7. public-disclosure risks are acknowledged,
8. claim-level material is not exposed prematurely,
9. and the folder can support future institutional or legal evaluation.

---

## 20. Final note

This folder represents the intellectual-property projection of the doctoral work.

Its central principle is:

```text
The thesis provides the scientific foundation;
the patent folder preserves a cautious technical basis
for evaluating possible protection of an applied method or system.
```

For that reason, `06_PRODUCTS/02_patent/` should be treated as a preliminary and non-confidential patent-planning folder, not as a formal patent filing.

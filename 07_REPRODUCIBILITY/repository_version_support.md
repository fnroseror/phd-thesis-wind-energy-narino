# Repository Version Support

## Purpose

This document describes the repository state associated with the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The purpose of this file is to document the version-support logic of the repository at the doctoral review stage, including its structure, evidence organization, reproducibility scope, limitations, and interpretation criteria.

This file supports the reproducibility layer:

```text
07_REPRODUCIBILITY/
```

and should be read together with:

```text
README.md
07_REPRODUCIBILITY/README.md
07_REPRODUCIBILITY/data_contract.md
07_REPRODUCIBILITY/execution_pipeline.md
07_REPRODUCIBILITY/software_versions.md
07_REPRODUCIBILITY/sessionInfo.txt
07_REPRODUCIBILITY/validation_checks.md
05_APPENDICES_SUPPORT/Anexo_H_Reproducibilidad_Computacional.md
```

---

## 1. Repository status

```text
Status: Final doctoral repository alignment
Repository role: Scientific support environment for doctoral thesis review
Review stage: Doctoral evaluation / thesis-defense support
```

This repository is designed to support:

- thesis traceability;
- methodological transparency;
- computational reproducibility;
- result organization;
- appendix support;
- product documentation;
- and academic review.

The repository should be interpreted as the structured scientific support system of the doctoral thesis, not as a generic file-storage space.

---

## 2. Final repository structure

The final repository structure is:

```text
phd-thesis-wind-energy-narino/
├── 01_THESIS/
├── 02_DATA_METADATA/
├── 03_CODE/
├── 04_RESULTS_COMPLETE/
├── 05_APPENDICES_SUPPORT/
├── 06_PRODUCTS/
├── 07_REPRODUCIBILITY/
└── README.md
```

Each folder has a defined role in the scientific architecture of the thesis.

---

## 3. Folder roles

| Folder | Repository role |
|---|---|
| `01_THESIS/` | Thesis-level orientation, contribution summary, repository scope, and citation guidance. |
| `02_DATA_METADATA/` | Dataset overview, variable dictionary, station-zone mapping, data-processing notes, and data-availability statement. |
| `03_CODE/` | Computational workflow for preprocessing, physical characterization, modeling, uncertainty, FNRR, and energy projection. |
| `04_RESULTS_COMPLETE/` | Complete result evidence, including outputs, figures, tables, uncertainty, FNRR, and energy projection. |
| `05_APPENDICES_SUPPORT/` | Technical, mathematical, methodological, and reproducibility appendices. |
| `06_PRODUCTS/` | Academic, technological, pedagogical, and institutional products derived from the doctoral work. |
| `07_REPRODUCIBILITY/` | Reproducibility support, data contract, execution pipeline, software context, validation checks, and repository-version documentation. |

---

## 4. Scientific core supported by the repository

The repository supports the following doctoral scientific chain:

```text
meteorological observations
→ preprocessing and traceability
→ physical characterization
→ Wind Power Density
→ predictive modeling
→ PI90 uncertainty
→ FNRR
→ free energy
→ usable energy
→ regional projection
```

The central physical variable is:

```text
WPD = 0.5 · ρ · v³
```

The central structural descriptor is:

```text
FNRR_z(T) = [Q_75,z(T) − Q_25,z(T)] / [Q_75,z(T) + Q_25,z(T) + ε_z]
```

The central usable-energy relation is:

```text
E_usable = (1 − FNRR) · E_free
```

Formal support is documented in:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.docx
```

---

## 5. Version interpretation

This repository version should be interpreted as the version aligned with:

```text
doctoral thesis support
repository final organization
juror-review preparation
product evidence organization
reproducibility documentation
```

It is not necessarily the final version of every future product.

Some derivative products may continue evolving after doctoral review, including:

```text
articles
patent-oriented material
book material
dashboard updates
presentations
directed theses
professorial project reports
```

The repository version at this stage preserves the thesis-support structure and the evidence available for review.

---

## 6. Core evidence layer

The core evidence layer of the repository is:

```text
01_THESIS/
02_DATA_METADATA/
03_CODE/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/
07_REPRODUCIBILITY/
```

These folders support the thesis directly.

The folder:

```text
06_PRODUCTS/
```

documents derivative products and academic projection. It is important, but it should not be confused with the core computational evidence required to support the thesis results.

---

## 7. Results version support

The main result folder is:

```text
04_RESULTS_COMPLETE/
```

Expected structure:

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

This folder supports:

- Chapter 2 physical characterization;
- Chapter 3 predictive modeling and uncertainty;
- Chapter 4 FNRR, free energy, usable energy, and energy projection;
- figure evidence;
- table evidence;
- and extended technical outputs.

---

## 8. Appendix version support

The appendix-support folder is:

```text
05_APPENDICES_SUPPORT/
```

Expected structure:

```text
05_APPENDICES_SUPPORT/
├── Anexo_A_Base_Datos_y_Zonificacion.md
├── Anexo_B_Preprocesamiento_y_Trazabilidad.md
├── Anexo_C_Configuracion_Experimental.md
├── Anexo_D_Resultados_Extendidos_Cap2.md
├── Anexo_E_Resultados_Extendidos_Cap3.md
├── Anexo_F_Resultados_Extendidos_Cap4.md
├── Anexo_G_Physical_Mathematical_Model_FNRR.md
├── Anexo_G_Physical_Mathematical_Model_FNRR.docx
└── Anexo_H_Reproducibilidad_Computacional.md
```

Appendix G is the main physical and mathematical support for the model and FNRR.

Appendix H is the main extended reproducibility support.

---

## 9. Product version support

The product folder is:

```text
06_PRODUCTS/
```

Expected structure:

```text
06_PRODUCTS/
├── 01_articles/
├── 02_patent/
├── 03_book/
├── 04_dashboard/
├── 05_presentations/
├── 06_directed_theses/
├── 07_professorial_project/
└── README.md
```

Product interpretation:

| Product folder | Version-support interpretation |
|---|---|
| `01_articles/` | Article concept notes and manuscript-development planning. |
| `02_patent/` | Preliminary, non-confidential patent-oriented documentation. |
| `03_book/` | Book outline and scientific-pedagogical projection. |
| `04_dashboard/` | Published Power BI visualization product for meteorological variable behavior. |
| `05_presentations/` | Presentation records and certificates. |
| `06_directed_theses/` | Directed theses and supervised-project evidence. |
| `07_professorial_project/` | Institutional evidence of the professorial research project. |

Product folders document academic projection and applied outputs, but not all products are necessarily final or closed.

---

## 10. Reproducibility version support

The reproducibility folder is:

```text
07_REPRODUCIBILITY/
```

Expected structure:

```text
07_REPRODUCIBILITY/
├── README.md
├── data_contract.md
├── execution_pipeline.md
├── software_versions.md
├── sessionInfo.txt
├── validation_checks.md
└── repository_version_support.md
```

This folder documents:

- data expectations;
- execution order;
- software environment;
- session information;
- validation checks;
- repository state;
- and reproducibility limitations.

---

## 11. Data availability

The full raw dataset may not be included in the public repository.

This repository supports reproducibility through:

```text
metadata
data contract
variable dictionary
station-zone mapping
processing notes
code structure
complete results
figures
tables
appendices
software documentation
validation checks
```

The formal data-availability statement is documented in:

```text
02_DATA_METADATA/05_data_availability.md
```

This is a responsible reproducibility strategy for a large environmental observational dataset.

---

## 12. Code version support

The code folder is:

```text
03_CODE/
```

Expected structure:

```text
03_CODE/
├── 01_preprocessing/
├── 02_physical_characterization/
├── 03_classical_models/
├── 04_machine_learning/
├── 05_deep_learning/
├── 06_hybrid_tdq/
├── 07_energy_projection/
└── 08_utils/
```

Code interpretation:

- some scripts may reflect historical development stages;
- local paths may require adjustment;
- stochastic models may require seed control;
- deep learning outputs may vary across systems;
- and internal workflow labels should be interpreted cautiously.

The code folder supports traceability and progressive reproducibility.

---

## 13. Internal-label caution

Some repository files may contain internal labels such as:

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

These labels should not be overinterpreted.

For doctoral review, the formal scientific language is:

```text
physical characterization
Wind Power Density
predictive modeling
persistence benchmark
uncertainty quantification
PI90
FNRR
free energy
usable energy
regional energy projection
```

Internal labels are part of workflow traceability unless formally defined in the corresponding appendix or product document.

---

## 14. Known limitations

This repository version may include the following limitations:

- raw data may not be fully included;
- some scripts may require local path adjustment;
- not all outputs may be regenerated with one command;
- deep learning outputs may not reproduce bit-for-bit;
- historical exploratory files may exist;
- some derivative products may continue evolving;
- and external links, such as dashboard links, may depend on platform availability.

These limitations do not invalidate the repository.

They define the realistic scope of doctoral computational reproducibility.

---

## 15. What this repository version does not claim

This repository version does not claim that:

- the repository is a one-click production pipeline;
- all raw data are publicly available;
- every script runs without local configuration;
- every result is bit-identical across machines;
- every product is final or published;
- patent material represents a filed patent;
- article concept notes represent submitted manuscripts;
- or the dashboard implements the complete physical–statistical model.

Instead, this repository version documents:

```text
scientific evidence
computational traceability
mathematical support
result organization
product projection
reproducibility limitations
```

---

## 16. Reviewer interpretation

A reviewer should interpret this repository as:

```text
a doctoral scientific support repository
```

Its purpose is to help understand, verify, and evaluate the thesis.

Recommended review sequence:

```text
1. README.md
2. 01_THESIS/
3. 02_DATA_METADATA/
4. 05_APPENDICES_SUPPORT/
5. 04_RESULTS_COMPLETE/
6. 03_CODE/
7. 07_REPRODUCIBILITY/
8. 06_PRODUCTS/
```

For mathematical review, prioritize:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

For reproducibility review, prioritize:

```text
07_REPRODUCIBILITY/
```

For product evidence, prioritize:

```text
06_PRODUCTS/
```

---

## 17. Suggested repository tag

If a release or tag is created for doctoral review, a suggested label is:

```text
doctoral-review-support-v1.0
```

Suggested release description:

```text
Repository version aligned with doctoral thesis review, including
metadata, code structure, complete results, appendices, product evidence,
and reproducibility documentation.
```

A tag or release is optional, but recommended for preserving a stable review state.

---

## 18. Suggested citation

Suggested repository citation:

```text
Rosero-Rodríguez, F. N. (2026). PhD thesis repository:
Wind energy forecasting and usable energy assessment in Nariño.
Doctorado en Ciencias — Física, Universidad Nacional de Colombia, Sede Manizales.
GitHub repository: phd-thesis-wind-energy-narino.
```

If a formal GitHub release or DOI is generated later, the citation should be updated accordingly.

---

## 19. Closure criterion

This repository version can be considered ready for doctoral review when:

```text
[ ] Main README reflects the final structure.
[ ] 01_THESIS is documented.
[ ] 02_DATA_METADATA is documented.
[ ] 03_CODE structure is clear.
[ ] 04_RESULTS_COMPLETE is organized.
[ ] 05_APPENDICES_SUPPORT is complete.
[ ] 06_PRODUCTS contains derivative-product evidence.
[ ] 07_REPRODUCIBILITY contains all reproducibility support files.
[ ] Appendix G is mathematically consistent.
[ ] Appendix H aligns with reproducibility documentation.
[ ] Dashboard scope is documented honestly.
[ ] Product evidence is uploaded where available.
[ ] Reproducibility limitations are acknowledged.
```

---

## 20. Final statement

This repository version supports the doctoral thesis by preserving the relationship between:

```text
data
→ code
→ results
→ figures
→ tables
→ appendices
→ reproducibility
→ products
```

Its central principle is:

```text
The thesis establishes the scientific contribution;
the repository preserves the evidence, structure, reproducibility support,
and academic projection required for doctoral review.
```

This file documents the repository state and interpretation criteria for the doctoral review stage.

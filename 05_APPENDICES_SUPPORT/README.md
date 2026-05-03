# 05_APPENDICES_SUPPORT

## Purpose

This folder contains the technical, methodological, mathematical, and reproducibility appendices that support the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The purpose of this section is to provide extended scientific support for aspects that are essential for evaluation but should not overload the main thesis document.

This folder should be interpreted as the formal appendix layer of the repository.

It connects the thesis document, the metadata, the computational workflow, the complete results, and the reproducibility structure.

---

## 1. Scientific role of the appendices

The thesis develops a physical–statistical and computational framework for the characterization, prediction, uncertainty evaluation, and energetic interpretation of wind power potential in Nariño, Colombia.

The appendices support that framework by documenting:

- the observational database and zonal structure,
- preprocessing and traceability criteria,
- experimental configuration,
- extended results for Chapters 2, 3, and 4,
- the physical and mathematical formulation of the model,
- the formal interpretation of FNRR,
- and computational reproducibility support.

The appendices do not replace the thesis. They provide additional technical evidence required for external academic review.

---

## 2. Folder contents

The current appendix structure is:

| File | Role |
|---|---|
| `Anexo_A_Base_Datos_y_Zonificacion.md` | Documents the observational database, variable structure, station network, and zonal organization. |
| `Anexo_B_Preprocesamiento_y_Trazabilidad.md` | Documents preprocessing principles, cleaning decisions, traceability, and preparation of analysis-ready data. |
| `Anexo_C_Configuracion_Experimental.md` | Documents experimental configuration, modeling families, validation logic, metrics, horizons, and reproducibility parameters. |
| `Anexo_D_Resultados_Extendidos_Cap2.md` | Provides extended support for Chapter 2 physical characterization results. |
| `Anexo_E_Resultados_Extendidos_Cap3.md` | Provides extended support for Chapter 3 predictive modeling, model comparison, and uncertainty-aware results. |
| `Anexo_F_Resultados_Extendidos_Cap4.md` | Provides extended support for Chapter 4 FNRR, uncertainty, usable energy, and projection results. |
| `Anexo_G_Physical_Mathematical_Model_FNRR.docx` | Contains the extended physical and mathematical formulation of the model and FNRR. |
| `Anexo_H_Reproducibilidad_Computacional.md` | Documents computational reproducibility support, execution logic, software context, and traceability limits. |

---

## 3. Relationship with thesis chapters

The appendices are aligned with the thesis structure as follows:

| Thesis component | Appendix support |
|---|---|
| Dataset, variables, stations, and zones | Anexo A |
| Preprocessing and data treatment | Anexo B |
| Experimental configuration and model evaluation design | Anexo C |
| Physical characterization results | Anexo D |
| Predictive modeling and uncertainty support | Anexo E |
| FNRR, usable energy, and projection support | Anexo F |
| Physical–mathematical formulation of the model and FNRR | Anexo G |
| Computational reproducibility | Anexo H |

---

## 4. Relationship with repository structure

This folder should be read together with:

```text
01_THESIS/
02_DATA_METADATA/
03_CODE/
04_RESULTS_COMPLETE/
07_REPRODUCIBILITY/
```

The logical relationship is:

```text
thesis document
→ metadata
→ code
→ complete results
→ appendices
→ reproducibility
```

The appendices serve as the explanatory bridge between the main thesis narrative and the technical evidence preserved in the repository.

---

## 5. Role of Anexo G

`Anexo_G_Physical_Mathematical_Model_FNRR.docx` is a central technical document because it contains the extended physical and mathematical formulation associated with:

- Wind Power Density,
- air density,
- energy integration,
- free energy,
- usable energy,
- FNRR,
- uncertainty-aware interpretation,
- and the hybrid physical–statistical model.

Because GitHub does not render Word files as transparently as Markdown files, it is recommended to maintain a Markdown companion file:

```text
Anexo_G_Physical_Mathematical_Model_FNRR.md
```

The Word file may be preserved for formal presentation, while the Markdown file should provide direct web readability for reviewers.

---

## 6. Interpretation principles

The appendices should be interpreted according to the following principles.

### 6.1 Scientific support

Each appendix must support a specific part of the doctoral thesis and repository.

### 6.2 No unnecessary conceptual overload

The appendices should strengthen the physical, statistical, computational, and energetic interpretation of the thesis without introducing speculative or disconnected material.

### 6.3 Traceability

Each appendix should be traceable to metadata, code, results, figures, tables, or reproducibility files.

### 6.4 Reviewer readability

Each appendix should be understandable by an external reviewer without requiring verbal explanation from the author.

### 6.5 Controlled extension

The appendices may contain extended technical explanations, but they should remain aligned with the doctoral scope.

---

## 7. Treatment of internal workflow labels

Some files in the repository may preserve internal development labels such as:

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
```

These labels should be interpreted carefully.

For doctoral evaluation, the core interpretation should remain focused on:

- physical characterization,
- statistical modeling,
- predictive evaluation,
- uncertainty quantification,
- FNRR as a structural regional descriptor,
- and energy projection.

Internal workflow labels should not be interpreted as separate theoretical claims unless explicitly formalized in the corresponding appendix.

---

## 8. Appendix closure criterion

This folder is considered properly organized when:

1. every appendix has a clear purpose,
2. every appendix is connected to a thesis chapter or repository section,
3. obsolete routes are corrected,
4. internal labels are interpreted with academic caution,
5. the physical–mathematical model and FNRR are formally documented,
6. reproducibility support is aligned with `07_REPRODUCIBILITY/`,
7. no appendix contains unsupported claims,
8. and the folder can be reviewed without requiring verbal explanation from the author.

---

## 9. Recommended update order

The recommended order for closing this folder is:

```text
README.md
→ Anexo_A_Base_Datos_y_Zonificacion.md
→ Anexo_B_Preprocesamiento_y_Trazabilidad.md
→ Anexo_C_Configuracion_Experimental.md
→ Anexo_D_Resultados_Extendidos_Cap2.md
→ Anexo_E_Resultados_Extendidos_Cap3.md
→ Anexo_F_Resultados_Extendidos_Cap4.md
→ Anexo_G_Physical_Mathematical_Model_FNRR.md
→ Anexo_H_Reproducibilidad_Computacional.md
```

This order follows the scientific flow of the thesis:

```text
data
→ preprocessing
→ experimental configuration
→ chapter 2 results
→ chapter 3 results
→ chapter 4 results
→ physical–mathematical formulation
→ reproducibility
```

---

## 10. Final note

This folder is one of the most important parts of the repository because it protects the thesis against technical ambiguity.

Its function is not to add volume, but to provide structured scientific support for the doctoral work.

A well-organized appendix layer allows reviewers to understand how the thesis connects:

```text
observational evidence
→ physical reasoning
→ computational implementation
→ predictive results
→ uncertainty
→ FNRR
→ usable energy
→ reproducibility
```

For that reason, `05_APPENDICES_SUPPORT/` should be treated as the technical defense layer of the repository.

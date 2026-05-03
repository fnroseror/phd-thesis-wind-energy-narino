# 01_articles

## Purpose

This folder contains the conceptual and organizational basis for the scientific articles derived from the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The purpose of this folder is to organize the publication portfolio emerging from the doctoral work.

This folder does not contain final submitted manuscripts yet. It documents the scientific direction, scope, contribution, maturity level, and repository evidence supporting each projected article.

This folder is part of:

```text
06_PRODUCTS/
```

and should be interpreted as the article-development layer of the doctoral repository.

---

## 1. Role of this folder

The doctoral thesis produced a physical–statistical and computational framework for regional wind-energy analysis in Nariño, Colombia.

The publication portfolio translates that framework into article-oriented scientific products.

The articles are derived from the thesis, but they should not be confused with the thesis itself.

The thesis is the formal doctoral document.

The articles are derivative academic products that may later be developed, submitted, reviewed, and published independently.

The general relationship is:

```text
doctoral thesis
→ validated scientific framework
→ repository evidence
→ article concept notes
→ manuscript development
→ journal submission
```

---

## 2. Current article portfolio

The current portfolio is organized into three main projected articles:

| File | Tentative focus | Status |
|---|---|---|
| `article_01_concept_note.md` | Physical–statistical characterization of wind power density in Nariño. | Concept note |
| `article_02_concept_note.md` | Hybrid physical–statistical forecasting and model comparison for WPD. | Concept note |
| `article_03_concept_note.md` | FNRR, regional irregularity, uncertainty, free energy, and usable energy. | Concept note |

These articles are intended to transform the thesis results into a coherent publication sequence.

---

## 3. Publication logic

The article portfolio follows the scientific sequence of the thesis:

```text
Article 01
Physical characterization of the wind-energy system

Article 02
Predictive modeling and model comparison

Article 03
FNRR, uncertainty, and usable-energy interpretation
```

This sequence is intentional.

It allows the publication strategy to move from physical characterization to predictive modeling and finally to the original structural contribution associated with FNRR and usable energy.

---

## 4. Article 01 — Physical characterization

File:

```text
article_01_concept_note.md
```

Tentative title:

```text
Physical-statistical characterization of wind power density in Nariño, Colombia, using multi-station meteorological records
```

Scientific role:

This article should present the physical and statistical basis of the thesis.

Its focus is the characterization of wind behavior and Wind Power Density in Nariño before predictive modeling.

Main expected components:

- observational meteorological system,
- station and zonal structure,
- wind-speed characterization,
- Wind Power Density construction,
- descriptive statistics,
- Weibull analysis,
- Rayleigh comparison,
- temporal dependence,
- spectral and wavelet interpretation,
- and regional physical interpretation.

Main repository support:

```text
02_DATA_METADATA/
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
05_APPENDICES_SUPPORT/Anexo_D_Resultados_Extendidos_Cap2.md
```

Expected contribution:

This article should establish why wind-energy analysis in Nariño should not be reduced to wind speed alone, but should be interpreted through physical and energetic variables such as WPD.

---

## 5. Article 02 — Predictive modeling

File:

```text
article_02_concept_note.md
```

Tentative title:

```text
Hybrid physical-statistical forecasting of wind power density in Nariño, Colombia: comparison of classical, machine learning, and deep learning approaches
```

Scientific role:

This article should present the predictive core of the thesis.

Its focus is model comparison for Wind Power Density and related energetic quantities.

Main expected components:

- WPD as central target variable,
- prediction horizons,
- zonal forecasting structure,
- classical models,
- machine learning models,
- deep learning models,
- persistence benchmark,
- RMSE,
- MAE,
- R²,
- Skill Score,
- PI90 uncertainty support,
- and residual interpretation.

Main repository support:

```text
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
05_APPENDICES_SUPPORT/Anexo_C_Configuracion_Experimental.md
05_APPENDICES_SUPPORT/Anexo_E_Resultados_Extendidos_Cap3.md
```

Expected contribution:

This article should show whether the predictive framework provides meaningful improvement over persistence and how different model families behave under a physical–statistical wind-energy forecasting framework.

---

## 6. Article 03 — FNRR and usable energy

File:

```text
article_03_concept_note.md
```

Tentative title:

```text
FNRR as a structural indicator of regional wind-energy irregularity and usable energy estimation under uncertainty
```

Scientific role:

This article should present the most original conceptual and methodological contribution derived from the thesis.

Its focus is the formal definition and interpretation of FNRR as a structural regional irregularity descriptor.

Main expected components:

- formal definition of FNRR,
- robust quantile-based irregularity,
- dimensional consistency,
- mathematical boundedness,
- distinction between free energy and usable energy,
- PI90-supported uncertainty interpretation,
- annual and quarterly energy projection,
- regional interpretation toward 2028,
- and methodological limits of the descriptor.

Main repository support:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
05_APPENDICES_SUPPORT/Anexo_F_Resultados_Extendidos_Cap4.md
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.docx
```

Expected contribution:

This article should formalize the distinction between physically available energy and structurally usable energy, using FNRR as a bounded, dimensionless, and interpretable descriptor of regional irregularity.

---

## 7. Relationship with the thesis

The article portfolio is derived from the doctoral thesis, but each article should have a narrower and more publishable focus.

The relationship is:

```text
Chapter 2 → Article 01
Chapter 3 → Article 02
Chapter 4 → Article 03
```

The thesis provides the complete doctoral argument.

The articles extract specific contributions suitable for journal publication.

---

## 8. Relationship with repository evidence

Every article must remain traceable to repository evidence.

The minimum traceability chain for each manuscript should be:

```text
thesis chapter
→ code stage
→ results folder
→ figures
→ tables
→ appendix support
→ article manuscript
```

This prevents article development from becoming disconnected from the validated doctoral workflow.

---

## 9. Recommended manuscript-development structure

Each future article manuscript should include, at minimum:

```text
Title
Abstract
Keywords
Introduction
Scientific problem
Materials and methods
Data and study area
Physical formulation
Modeling or analytical framework
Results
Discussion
Limitations
Conclusions
References
Supplementary material
Repository/data availability statement
```

Each concept note should later evolve into a complete manuscript using this structure.

---

## 10. Development status

Current status of the article folder:

```text
Status: Conceptual portfolio defined
Maturity level: Pre-manuscript
Repository role: Publication planning and traceability
```

The files in this folder should not be described as submitted, accepted, or published manuscripts unless that status changes formally.

Recommended status labels:

```text
Concept note
Draft manuscript
Internal review
Advisor review
Pre-submission
Submitted
Under review
Accepted
Published
Archived
```

---

## 11. Authorship and ethical caution

Future manuscripts should define authorship according to real scientific contribution, institutional guidelines, and academic ethics.

This folder does not assign final authorship.

It only organizes the article ideas derived from the doctoral work.

Any future manuscript should clearly distinguish between:

- results already validated in the thesis,
- additional analysis prepared for the article,
- methodological extensions,
- and speculative future work.

---

## 12. Target-journal caution

Suggested journal areas may include:

- renewable energy,
- applied physics,
- wind-energy forecasting,
- environmental modeling,
- energy systems,
- uncertainty quantification,
- and physical–statistical modeling.

However, this folder does not claim that any article has already been submitted to a specific journal.

Target journals should be selected later according to:

- manuscript scope,
- novelty,
- article length,
- methodological depth,
- journal aims,
- indexing,
- publication ethics,
- open-access conditions,
- and review time.

---

## 13. Internal label caution

Some repository outputs may contain internal workflow labels such as:

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

The article narrative should prioritize the formally defensible scientific language:

- physical characterization,
- Wind Power Density,
- physical–statistical modeling,
- model comparison,
- persistence benchmark,
- uncertainty quantification,
- FNRR,
- free energy,
- usable energy,
- and regional energy projection.

Internal development labels should not be overinterpreted as publication claims, journal claims, or independent theoretical claims unless formally defined in the manuscript.

---

## 14. Recommended update order

The recommended update order for this folder is:

```text
README.md
→ article_01_concept_note.md
→ article_02_concept_note.md
→ article_03_concept_note.md
```

Each concept note should be expanded until it contains:

- tentative title,
- article type,
- status,
- scientific problem,
- objective,
- novelty,
- methods,
- expected results,
- repository evidence,
- potential target journal category,
- limitations,
- next development steps.

---

## 15. Closure criterion

This folder is considered properly organized when:

1. the article portfolio is clearly defined,
2. each concept note has a specific scope,
3. article status is honestly declared,
4. each article is traceable to thesis evidence,
5. no article is presented as submitted or accepted unless formally true,
6. internal workflow labels are interpreted carefully,
7. article development does not overstate the thesis results,
8. and the folder can be reviewed without requiring verbal explanation from the author.

---

## 16. Final note

This folder organizes the publication strategy derived from the doctoral thesis.

Its central principle is:

```text
The thesis proves the doctoral contribution;
the articles translate that contribution into focused scientific manuscripts.
```

For that reason, `06_PRODUCTS/01_articles/` should be treated as a publication-planning and manuscript-development support folder, not as a folder of completed publications.

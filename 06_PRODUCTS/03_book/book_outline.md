# Book Outline

## Tentative title

**From Wind to Usable Energy: Physics, Prediction, Uncertainty, and the Discipline of Scientific Decision**

Alternative titles:

```text
From Wind to Decision: A Physical–Statistical Journey Through Energy, Uncertainty, and Coherence

The Physics of Usable Energy: Wind, Prediction, Regional Irregularity, and Scientific Decision

Wind, Uncertainty, and Usable Energy: A Physical–Statistical Framework for Regional Energy Interpretation
```

---

## Current status

```text
Status: Conceptual outline
Maturity level: Preliminary book structure
Repository role: Book-development planning
Publication status: Not published
```

This file does not represent a finished book manuscript.

It defines the conceptual, scientific, pedagogical, and reflective structure of a possible book derived from the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

---

## 1. General purpose

The purpose of this projected book is to expand the doctoral thesis into a broader scientific and pedagogical work.

The book should explain how a regional atmospheric problem can be transformed into a structured physical–statistical framework for understanding, predicting, and interpreting wind-energy potential under uncertainty.

The central scientific chain is:

```text
meteorological observations
→ physical characterization
→ Wind Power Density
→ predictive modeling
→ uncertainty quantification
→ FNRR
→ free energy
→ usable energy
→ regional energy projection
```

The book may also include broader reflections on scientific decision-making, uncertainty, coherence, and intellectual discipline, but these reflections must be clearly separated from the formal doctoral evidence.

---

## 2. Core idea

The central idea of the book is:

```text
Energy potential is not enough.
A physical system must be interpreted through structure, uncertainty,
regularity, usability, and decision value.
```

In the doctoral case, this idea is expressed through:

- wind speed as observed atmospheric motion,
- Wind Power Density as physical energetic transformation,
- predictive modeling as temporal anticipation,
- PI90 as uncertainty representation,
- FNRR as structural regional irregularity,
- free energy as available energetic potential,
- usable energy as structurally adjusted energetic interpretation,
- and regional projection as decision-support evidence.

---

## 3. Relationship with the doctoral thesis

The thesis is the scientific backbone of the book.

The thesis provides:

- the formal research problem,
- the physical and statistical framework,
- the observational dataset,
- the computational workflow,
- the predictive models,
- the uncertainty analysis,
- the FNRR formulation,
- the energy projection,
- and the reproducible repository evidence.

The book should not replace the thesis.

The book should explain, expand, teach, and project the thesis.

The relationship is:

```text
Doctoral thesis
→ formal scientific contribution

Book
→ expanded scientific, pedagogical, and reflective interpretation
```

---

## 4. Relationship with TDQ and broader conceptual work

The book may include an emerging decision-oriented interpretation connected with TDQ, entropy, coherence, uncertainty, and scientific discipline.

However, this material must be treated carefully.

The correct separation is:

```text
Doctoral core:
physical–statistical modeling of wind-energy potential

Book extension:
broader interpretation of uncertainty, decision, coherence, and scientific order
```

TDQ should not be presented as the central proof of the doctoral thesis.

It may appear as:

- future work,
- conceptual extension,
- reflective framework,
- decision-oriented interpretation,
- or postdoctoral research direction.

This separation protects both the thesis and the future book.

---

## 5. Intended audience

The book may be written for several possible audiences.

Primary audiences:

- physics students,
- engineering students,
- renewable-energy researchers,
- data-science students,
- early-career researchers,
- thesis writers,
- professors interested in applied physics and modeling.

Secondary audiences:

- regional planners,
- energy-sector professionals,
- interdisciplinary readers,
- readers interested in uncertainty and decision-making,
- readers interested in the human process behind scientific work.

The final writing style should depend on the selected audience.

A technical version should include more equations, methods, and reproducibility details.

A pedagogical version should include more explanations, diagrams, analogies, and conceptual transitions.

A reflective version should include the scientific process, discipline, mental order, and broader intellectual development, without weakening the technical rigor.

---

## 6. Proposed book orientation

The recommended orientation is:

```text
Scientific–pedagogical book with reflective extension
```

This means:

1. The scientific core remains rigorous and traceable to the thesis.
2. The explanations are written to teach and guide.
3. The reflective material is included only where it strengthens the intellectual narrative.
4. The broader conceptual material is clearly marked as extension or future work.

The book should not become a speculative text.

It should remain anchored in physics, data, evidence, uncertainty, and reproducible scientific reasoning.

---

## 7. Proposed book structure

The book may be organized into seven parts.

```text
Part I — The physical problem
Part II — The regional wind system
Part III — From wind speed to Wind Power Density
Part IV — Prediction and uncertainty
Part V — FNRR, free energy, and usable energy
Part VI — Reproducibility and scientific discipline
Part VII — Decision, coherence, and future research
```

---

# Part I — The physical problem

## Chapter 1 — Why wind is not only wind

### Purpose

Introduce the central problem of the book: wind-energy potential cannot be understood only by observing wind speed.

### Core ideas

- Wind as atmospheric motion.
- Wind as a physical signal.
- Wind speed as an observed variable.
- Energy as a transformation of motion.
- Why physical interpretation must precede prediction.

### Key message

```text
The first scientific error is to treat a physical signal as a simple number.
```

### Thesis connection

This chapter connects with the general introduction and motivation of the doctoral thesis.

---

## Chapter 2 — Nariño as a regional atmospheric system

### Purpose

Present Nariño, Colombia, as the territorial and atmospheric context of the doctoral work.

### Core ideas

- Regional heterogeneity.
- Meteorological station network.
- Zonal organization.
- Atmospheric variability.
- Local relevance of renewable-energy analysis.

### Key message

```text
A region is not only a geographic space; it is a physical system with structure.
```

### Thesis connection

This chapter connects with:

```text
02_DATA_METADATA/
05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
```

---

# Part II — The regional wind system

## Chapter 3 — The observational database

### Purpose

Explain how the meteorological database supports the scientific work.

### Core ideas

- Meteorological records.
- IDEAM stations.
- Variables.
- Time structure.
- Data heterogeneity.
- Traceability.

### Key message

```text
A dataset becomes scientific evidence only when it is traceable.
```

### Thesis connection

This chapter connects with:

```text
02_DATA_METADATA/
05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
05_APPENDICES_SUPPORT/Anexo_B_Preprocesamiento_y_Trazabilidad.md
```

---

## Chapter 4 — Cleaning without destroying the signal

### Purpose

Explain preprocessing as a physically informed stage, not as a mechanical cleaning process.

### Core ideas

- Missing values.
- Non-physical values.
- Zero values.
- Temporal resolution.
- Unit harmonization.
- Preservation of physical meaning.

### Key message

```text
Preprocessing is not about making data look perfect;
it is about preserving the truth of the physical signal.
```

### Thesis connection

This chapter connects with:

```text
03_CODE/01_preprocessing/
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
05_APPENDICES_SUPPORT/Anexo_B_Preprocesamiento_y_Trazabilidad.md
```

---

# Part III — From wind speed to Wind Power Density

## Chapter 5 — The physics of Wind Power Density

### Purpose

Explain the physical transformation from wind speed to Wind Power Density.

### Core equation

```text
WPD = 0.5 · ρ · v³
```

### Core ideas

- Kinetic energy of moving air.
- Mass flow rate.
- Air density.
- Cubic dependence on wind speed.
- Energetic amplification.

### Key message

```text
A small change in wind speed can become a large change in energy.
```

### Thesis connection

This chapter connects with:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

---

## Chapter 6 — Describing the wind before predicting it

### Purpose

Present the physical–statistical characterization of wind behavior.

### Core ideas

- Descriptive statistics.
- Zonal behavior.
- Variability.
- Skewness.
- Kurtosis.
- Regional differences.

### Key message

```text
Prediction without characterization is only numerical ambition.
```

### Thesis connection

This chapter connects with:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
05_APPENDICES_SUPPORT/Anexo_D_Resultados_Extendidos_Cap2.md
```

---

## Chapter 7 — Weibull, Rayleigh, and the shape of wind

### Purpose

Explain distributional characterization of wind speed.

### Core ideas

- Weibull distribution.
- Shape parameter.
- Scale parameter.
- Rayleigh comparison.
- Distributional structure.
- Wind regimes.

### Key message

```text
The form of the distribution tells part of the story of the wind.
```

### Thesis connection

This chapter connects with:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
```

---

## Chapter 8 — Time, frequency, and hidden structure

### Purpose

Explain temporal dependence, spectral structure, and multiscale behavior.

### Core ideas

- ACF.
- PACF.
- FFT.
- Wavelet analysis.
- Persistence.
- Nonstationarity.
- Multiscale physical behavior.

### Key message

```text
A physical signal may hide its structure in time, frequency, or both.
```

### Thesis connection

This chapter connects with:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
05_APPENDICES_SUPPORT/Anexo_D_Resultados_Extendidos_Cap2.md
```

---

# Part IV — Prediction and uncertainty

## Chapter 9 — Prediction as controlled uncertainty

### Purpose

Introduce predictive modeling as structured uncertainty reduction, not as certainty.

### Core ideas

- Forecasting.
- Prediction horizons.
- Model families.
- Temporal validation.
- Error metrics.
- Forecast uncertainty.

### Key message

```text
A prediction is not a promise; it is a disciplined estimate under uncertainty.
```

### Thesis connection

This chapter connects with:

```text
05_APPENDICES_SUPPORT/Anexo_C_Configuracion_Experimental.md
```

---

## Chapter 10 — Classical models, machine learning, and deep learning

### Purpose

Explain the model families used in the thesis.

### Core ideas

- ARIMA.
- ARIMAX.
- Random Forest.
- XGBoost.
- LSTM.
- Hybrid physical–statistical integration.
- Model comparison.

### Key message

```text
The best model is not the most complex one;
it is the one that adds real predictive value.
```

### Thesis connection

This chapter connects with:

```text
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

---

## Chapter 11 — Persistence: the model that must be defeated

### Purpose

Explain the role of persistence as a meaningful benchmark.

### Core ideas

- Atmospheric memory.
- Baseline prediction.
- Skill Score.
- Why R² is not enough.
- Predictive value beyond persistence.

### Key equation

```text
Skill = 1 − (RMSE_model / RMSE_persistence)
```

### Key message

```text
A model is useful only if it improves what the system already remembers.
```

### Thesis connection

This chapter connects with:

```text
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
05_APPENDICES_SUPPORT/Anexo_E_Resultados_Extendidos_Cap3.md
```

---

## Chapter 12 — Prediction intervals and the humility of science

### Purpose

Explain PI90 uncertainty and why intervals are necessary.

### Core ideas

- Point prediction.
- Prediction intervals.
- Empirical coverage.
- Calibration.
- Uncertainty-aware interpretation.
- Limits of certainty.

### Key message

```text
Scientific prediction becomes stronger when it admits its uncertainty.
```

### Thesis connection

This chapter connects with:

```text
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

---

# Part V — FNRR, free energy, and usable energy

## Chapter 13 — Free energy is not usable energy

### Purpose

Introduce the distinction between physically available energy and structurally usable energy.

### Core ideas

- Available potential.
- Structural usability.
- Regional irregularity.
- Overestimation risk.
- Decision-support interpretation.

### Key message

```text
Not all energy that exists in the system can be interpreted as usable energy.
```

### Thesis connection

This chapter connects with:

```text
04_RESULTS_COMPLETE/05_energy_projection/
05_APPENDICES_SUPPORT/Anexo_F_Resultados_Extendidos_Cap4.md
```

---

## Chapter 14 — FNRR: measuring regional non-regularity

### Purpose

Explain FNRR as the central structural descriptor introduced in the thesis.

### Core equation

```text
FNRR_z(T) = [Q_75,z(T) − Q_25,z(T)] / [Q_75,z(T) + Q_25,z(T) + ε_z]
```

### Core ideas

- Quantile-based irregularity.
- Dimensionless descriptor.
- Boundedness.
- Robustness.
- Regional interpretation.
- Structural penalty.

### Key message

```text
FNRR transforms irregularity into a measurable structural condition.
```

### Thesis connection

This chapter connects with:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

---

## Chapter 15 — Usable energy and structural adjustment

### Purpose

Explain the mathematical and physical meaning of usable energy.

### Core equation

```text
E_usable = (1 − FNRR) · E_free
```

### Core ideas

- Free energy.
- Usable energy.
- Structural penalty.
- Mathematical boundedness.
- Interpretation by zone.
- Projection under uncertainty.

### Key message

```text
Usable energy is energy interpreted through structure.
```

### Thesis connection

This chapter connects with:

```text
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
05_APPENDICES_SUPPORT/Anexo_F_Resultados_Extendidos_Cap4.md
```

---

## Chapter 16 — Projection toward 2028

### Purpose

Explain the model-based energy projection.

### Core ideas

- Projection as scenario.
- Not direct observation.
- Annual projection.
- Quarterly projection.
- PI90 support.
- Regional interpretation.

### Key message

```text
A projection is not the future; it is a disciplined scenario built from evidence.
```

### Thesis connection

This chapter connects with:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
05_APPENDICES_SUPPORT/Anexo_F_Resultados_Extendidos_Cap4.md
```

---

# Part VI — Reproducibility and scientific discipline

## Chapter 17 — The repository as scientific memory

### Purpose

Explain the repository as a reproducibility and traceability system.

### Core ideas

- Metadata.
- Code.
- Results.
- Figures.
- Tables.
- Appendices.
- Reproducibility.
- Scientific memory.

### Key message

```text
A repository is not a folder of files; it is the memory of a scientific process.
```

### Thesis connection

This chapter connects with:

```text
07_REPRODUCIBILITY/
05_APPENDICES_SUPPORT/Anexo_H_Reproducibilidad_Computacional.md
```

---

## Chapter 18 — Reducing informational entropy

### Purpose

Explain how scientific work requires order, hierarchy, and reduction of informational noise.

### Core ideas

- Informational entropy.
- Disorder in projects.
- Structure.
- Traceability.
- Scientific decisions.
- Clean repositories.
- Defensible evidence.

### Key message

```text
A thesis advances when information stops being noise and becomes structure.
```

### Thesis connection

This chapter connects with the final repository organization:

```text
01_THESIS/
02_DATA_METADATA/
03_CODE/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/
06_PRODUCTS/
07_REPRODUCIBILITY/
```

---

# Part VII — Decision, coherence, and future research

## Chapter 19 — From physical prediction to scientific decision

### Purpose

Introduce the broader decision-oriented interpretation derived from the thesis.

### Core ideas

- Prediction.
- Uncertainty.
- Decision.
- Usability.
- Risk.
- Scientific judgment.
- Energy planning.

### Key message

```text
The purpose of prediction is not only to know;
it is to decide better under uncertainty.
```

### Relationship with TDQ

This chapter may introduce decision-oriented interpretation as a future conceptual extension.

It should not present TDQ as proof of the doctoral thesis.

---

## Chapter 20 — Coherence, uncertainty, and the scientist

### Purpose

Reflect on the personal and intellectual discipline required to complete scientific work.

### Core ideas

- Mental order.
- Scientific discipline.
- Coherence.
- Emotional maturity.
- Thesis process.
- Research identity.
- Responsibility with evidence.

### Key message

```text
Scientific work also requires internal order.
```

### Relationship with TDQ

This chapter may connect the scientific process with a broader framework of coherence and decision, clearly identified as reflective extension.

---

## Chapter 21 — Future pathways

### Purpose

Present future research and product lines.

### Core ideas

- Scientific articles.
- Patent-oriented development.
- Dashboard.
- Directed theses.
- Regional energy applications.
- FNRR validation in other regions.
- Educational products.
- TDQ as postdoctoral conceptual development.

### Key message

```text
A thesis ends as a document, but it can begin as a research program.
```

### Thesis connection

This chapter connects with:

```text
06_PRODUCTS/
```

---

## 8. Proposed writing style

The recommended writing style is:

```text
rigorous but accessible
technical but pedagogical
reflective but controlled
personal only when it strengthens the scientific narrative
```

The book should avoid:

- excessive speculation,
- unsupported conceptual leaps,
- overuse of metaphors without explanation,
- confusing TDQ with the formal thesis,
- and presenting future work as already validated.

The book should preserve:

- scientific clarity,
- mathematical respect,
- physical intuition,
- methodological honesty,
- and narrative strength.

---

## 9. Possible introductory thesis of the book

A possible opening thesis is:

```text
This book was born from a physical question:
how can wind-energy potential be understood, predicted, and interpreted
in a region where the atmosphere does not behave as a perfectly regular system?

The answer required more than data.
It required physics, statistics, uncertainty, computation,
and a deeper understanding of what it means for energy to be usable.
```

---

## 10. Possible preface direction

The preface may explain:

- the origin of the doctoral problem,
- why Nariño matters,
- why wind energy is physically interesting,
- why prediction is not certainty,
- why usable energy matters,
- and how the thesis became a broader reflection on decision and coherence.

The preface should remain elegant, serious, and controlled.

It may contain personal elements, but the scientific purpose must remain central.

---

## 11. Relationship with the three projected articles

The book can integrate and expand the three projected articles:

```text
Article 01
Physical–statistical characterization of wind and WPD

Article 02
Predictive modeling and model comparison

Article 03
FNRR, uncertainty, free energy, and usable energy
```

The book may use those articles as scientific pillars, while adding pedagogical explanation and broader conceptual interpretation.

---

## 12. Relationship with the patent-oriented product

The book may mention the possibility of technological development, but should avoid revealing sensitive claim-level material.

Patent-oriented content should remain primarily in:

```text
06_PRODUCTS/02_patent/
```

If the book discusses applied technology, it should do so in general terms:

```text
decision-support systems
energy-usability estimation
regional renewable-energy assessment
uncertainty-aware dashboards
```

---

## 13. Relationship with the dashboard

The book may include future visualization ideas, such as:

- WPD maps,
- FNRR dashboards,
- usable-energy comparison panels,
- PI90 uncertainty displays,
- regional decision-support interfaces.

Dashboard-related material should remain connected to:

```text
06_PRODUCTS/04_dashboard/
```

---

## 14. Scientific evidence base

The book should remain traceable to:

```text
01_THESIS/
02_DATA_METADATA/
03_CODE/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/
07_REPRODUCIBILITY/
```

Specific evidence includes:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/07_FIGURES/
04_RESULTS_COMPLETE/08_TABLES/
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

---

## 15. Development roadmap

Recommended development stages:

### Stage 1 — Scope definition

```text
Define final title
Define audience
Define book type
Define technical depth
```

### Stage 2 — Structural consolidation

```text
Confirm parts
Confirm chapters
Define chapter summaries
Select key figures
Select key equations
```

### Stage 3 — Scientific writing

```text
Draft Part I
Draft Part II
Draft Part III
Draft Part IV
Draft Part V
```

### Stage 4 — Reflective extension

```text
Draft Part VI
Draft Part VII
Control TDQ integration
Separate thesis evidence from future interpretation
```

### Stage 5 — Editorial preparation

```text
Create glossary
Prepare diagrams
Select references
Prepare proposal
Define publication route
```

---

## 16. Possible glossary

The book should include a glossary with terms such as:

```text
Wind speed
Wind Power Density
Air density
Weibull distribution
Rayleigh distribution
ACF
PACF
FFT
Wavelet
Prediction horizon
Persistence
Skill Score
PI90
FNRR
Free energy
Usable energy
Uncertainty
Regional irregularity
Reproducibility
Informational entropy
Scientific decision
```

---

## 17. Limitations of the book project

The book should acknowledge:

- the thesis is the validated scientific base;
- broader interpretations require careful separation;
- TDQ is a future conceptual extension, not the proof of the thesis;
- the wind-energy framework is developed in the context of Nariño;
- generalization to other regions requires additional validation;
- the book is not yet a formal manuscript;
- and publication route has not been selected.

---

## 18. Current development status

```text
Current status: Expanded outline
Next stage: Define final book orientation and draft sample chapter
Priority: Medium
Dependency: Thesis defense, article strategy, and product roadmap
```

---

## 19. Final note

The book should preserve the following central identity:

```text
The thesis proves the scientific contribution.
The repository preserves the evidence.
The articles specialize the results.
The book explains the journey, teaches the framework,
and projects the science toward broader decision-oriented thinking.
```

The book should be ambitious, but controlled.

It should carry the author’s voice, but remain scientifically disciplined.

Its central message is:

```text
To understand a complex system, it is not enough to measure its potential.
One must understand its structure, uncertainty, regularity,
and the conditions under which that potential becomes usable.
```

# Appendix H — Computational Reproducibility

## Purpose

This appendix documents the computational reproducibility support associated with the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

Its purpose is to describe the repository logic, execution structure, software context, traceability conditions, portability considerations, and reproducibility limits of the computational workflow.

This appendix complements the reproducibility folder:

```text
07_REPRODUCIBILITY/
```

and should be read together with:

```text
01_THESIS/
02_DATA_METADATA/
03_CODE/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/
```

This appendix does not claim that the repository is a fully containerized one-click production system. Instead, it documents the scientific and computational traceability required for academic review, methodological interpretation, and future technical refinement.

---

## H.1 Role of reproducibility in the thesis

The thesis develops a physical–statistical and computational framework for characterizing, forecasting, and interpreting wind-energy potential in Nariño, Colombia.

Computational reproducibility is necessary because the doctoral results are generated through a sequence of data-processing, modeling, uncertainty, FNRR, and energy-projection operations.

The general reproducibility chain is:

```text
metadata
→ preprocessing
→ physical characterization
→ predictive modeling
→ uncertainty quantification
→ FNRR computation
→ energy projection
→ figures and tables
→ appendix-level support
```

Reproducibility is therefore not interpreted only as rerunning one script. It is interpreted as preserving the relationship between data, code, outputs, figures, tables, appendices, and thesis interpretation.

---

## H.2 Reproducibility philosophy

The repository is organized as a scientific support environment for the doctoral thesis.

The reproducibility philosophy is based on the following principles:

1. **Traceability**  
   Each result should be conceptually traceable to data, code, and documented methodology.

2. **Transparency**  
   The repository should allow reviewers to understand how the computational workflow is organized.

3. **Separation of roles**  
   Metadata, code, results, appendices, products, and reproducibility files serve different purposes.

4. **Physical consistency**  
   Reproducibility must preserve the physical meaning of derived variables such as WPD, Eh, FNRR, free energy, and usable energy.

5. **Realistic portability**  
   Some historical scripts may preserve development-stage paths or local configurations. These should be documented and progressively replaced with portable structures when necessary.

6. **Academic reviewability**  
   The repository should support external academic evaluation without requiring verbal explanation from the author.

---

## H.3 Final repository structure

The final repository structure is organized as follows:

```text
01_THESIS/
02_DATA_METADATA/
03_CODE/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/
06_PRODUCTS/
07_REPRODUCIBILITY/
```

Each folder has a defined role within the reproducible architecture.

| Folder | Reproducibility role |
|---|---|
| `01_THESIS/` | Contains the thesis document and conceptual repository support. |
| `02_DATA_METADATA/` | Documents dataset structure, variables, stations, zones, processing notes, and data availability. |
| `03_CODE/` | Preserves the computational workflow used to generate results. |
| `04_RESULTS_COMPLETE/` | Contains complete result outputs, figures, tables, uncertainty products, FNRR outputs, and energy-projection evidence. |
| `05_APPENDICES_SUPPORT/` | Provides extended methodological, mathematical, and technical support. |
| `06_PRODUCTS/` | Organizes derivative academic products. |
| `07_REPRODUCIBILITY/` | Preserves execution logic, software context, data contracts, and validation support. |

This structure is designed to reduce informational entropy and support scientific navigation of the doctoral work.

---

## H.4 Main reproducibility support files

The main reproducibility-oriented files should be located in:

```text
07_REPRODUCIBILITY/
```

Expected support files include:

```text
07_REPRODUCIBILITY/data_contract.md
07_REPRODUCIBILITY/execution_pipeline.md
07_REPRODUCIBILITY/software_versions.md
07_REPRODUCIBILITY/sessionInfo.txt
07_REPRODUCIBILITY/validation_checks.md
07_REPRODUCIBILITY/repository_version_support.md
```

These files provide technical support for understanding:

- expected data structure,
- execution order,
- software environment,
- package versions,
- validation logic,
- repository status,
- and reproducibility assumptions.

If some files are not yet fully completed, they should be created or updated progressively while preserving the final folder structure.

---

## H.5 Computational workflow overview

The computational workflow of the thesis can be interpreted through the following sequence:

```text
1. Dataset and metadata documentation
2. Preprocessing and traceability
3. Physical characterization
4. Classical forecasting
5. Machine learning modeling
6. Deep learning modeling
7. Hybrid physical–statistical integration
8. PI90 uncertainty quantification
9. FNRR computation
10. Energy projection
11. Generation of figures and tables
12. Reproducibility documentation
```

This sequence reflects the scientific logic of the thesis.

The workflow is not only computational. It is physical, statistical, predictive, probabilistic, structural, and energetic.

---

## H.6 Relationship with metadata

The metadata layer is located in:

```text
02_DATA_METADATA/
```

It supports reproducibility by documenting:

- dataset overview,
- variable dictionary,
- station-to-zone mapping,
- data-processing notes,
- data-availability conditions.

The metadata layer answers the following reproducibility questions:

```text
What data were used?
What variables were analyzed?
Which stations were included?
How were stations grouped into zones?
What are the limitations of data availability?
How should the dataset be interpreted?
```

Without metadata, the code and results would lose interpretability.

---

## H.7 Relationship with code

The computational workflow is preserved in:

```text
03_CODE/
```

The expected code structure is:

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

Each folder corresponds to a stage of the doctoral workflow.

| Code folder | Role |
|---|---|
| `01_preprocessing/` | Cleans, organizes, and prepares observational data. |
| `02_physical_characterization/` | Generates descriptive, distributional, temporal, spectral, and physical-characterization outputs. |
| `03_classical_models/` | Implements classical forecasting models such as ARIMA and ARIMAX. |
| `04_machine_learning/` | Implements machine learning models such as Random Forest and XGBoost. |
| `05_deep_learning/` | Implements deep learning models such as LSTM. |
| `06_hybrid_tdq/` | Preserves the current repository naming for the hybrid integration workflow. Scientifically, this folder should be interpreted as the hybrid physical–statistical integration stage. |
| `07_energy_projection/` | Implements energy integration, FNRR support, and projection outputs. |
| `08_utils/` | Contains auxiliary functions or support utilities. |

The folder `03_CODE/06_hybrid_tdq/` preserves internal development naming. For doctoral evaluation, it should be interpreted cautiously as part of the integrated physical–statistical workflow, not as an unsupported separate theoretical claim.

---

## H.8 Relationship with complete results

The complete result layer is located in:

```text
04_RESULTS_COMPLETE/
```

Its structure is:

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

This folder supports reproducibility by preserving:

- numerical outputs,
- graphical evidence,
- tabular evidence,
- uncertainty products,
- FNRR outputs,
- energy projections,
- extended technical results.

The result layer must be interpreted together with code and metadata.

The logical connection is:

```text
metadata + code → complete results
```

---

## H.9 Relationship with figures

Figures are located in:

```text
04_RESULTS_COMPLETE/07_FIGURES/
```

The structure is:

```text
07_FIGURES/
├── chapter_2/
├── chapter_3/
└── chapter_4/
```

Figures support reproducibility by allowing reviewers to visually inspect:

- physical characterization,
- distributional behavior,
- temporal dependence,
- spectral and wavelet structure,
- model performance,
- uncertainty calibration,
- FNRR behavior,
- free energy,
- usable energy,
- and energy projection.

Figures are not decorative. They are part of the scientific evidence layer.

---

## H.10 Relationship with tables

Tables are located in:

```text
04_RESULTS_COMPLETE/08_TABLES/
```

The structure is:

```text
08_TABLES/
├── chapter_2/
├── chapter_3/
└── chapter_4/
```

Tables support reproducibility by preserving numerical evidence for:

- data traceability,
- quality control,
- physical characterization,
- Weibull and Rayleigh comparison,
- model comparison,
- machine learning outputs,
- deep learning outputs,
- prediction results,
- PI90 uncertainty,
- FNRR,
- free energy,
- usable energy,
- and projection toward 2028.

Tables should be interpreted together with figures and code.

The reproducibility relationship is:

```text
code → tables
code → figures
tables + figures → thesis interpretation
```

---

## H.11 Relationship with appendices

Appendices are located in:

```text
05_APPENDICES_SUPPORT/
```

They support reproducibility by explaining the scientific, mathematical, and methodological logic behind the repository.

The appendix structure includes:

```text
Anexo_A_Base_Datos_y_Zonificacion.md
Anexo_B_Preprocesamiento_y_Trazabilidad.md
Anexo_C_Configuracion_Experimental.md
Anexo_D_Resultados_Extendidos_Cap2.md
Anexo_E_Resultados_Extendidos_Cap3.md
Anexo_F_Resultados_Extendidos_Cap4.md
Anexo_G_Physical_Mathematical_Model_FNRR.md
Anexo_G_Physical_Mathematical_Model_FNRR.docx
Anexo_H_Reproducibilidad_Computacional.md
```

Each appendix supports a specific layer of the reproducible workflow.

| Appendix | Reproducibility function |
|---|---|
| Appendix A | Documents database and zonal structure. |
| Appendix B | Documents preprocessing and traceability. |
| Appendix C | Documents experimental configuration. |
| Appendix D | Documents extended Chapter 2 results. |
| Appendix E | Documents extended Chapter 3 results. |
| Appendix F | Documents extended Chapter 4 results. |
| Appendix G | Documents physical and mathematical formulation of the model and FNRR. |
| Appendix H | Documents computational reproducibility. |

---

## H.12 Data reproducibility

The thesis is based on a large observational meteorological system.

The repository should not be interpreted as a raw public dump of every original source file.

Instead, reproducibility is preserved through:

```text
documented structure + executable logic + organized outputs + methodological traceability
```

The data reproducibility layer depends on:

- dataset description,
- variable definitions,
- station-to-zone mapping,
- data-availability statement,
- preprocessing notes,
- code,
- results,
- and appendices.

This is a realistic reproducibility model for a large environmental observational dataset.

---

## H.13 Data availability limits

The complete original raw database may not be fully included in unrestricted public form due to:

- file size,
- redundancy,
- platform limitations,
- source-format complexity,
- temporary local files,
- and the need to preserve repository clarity.

This does not invalidate the scientific value of the repository.

The important reproducibility requirement is that the repository preserves enough structure, code, outputs, and documentation to understand and evaluate the doctoral workflow.

The data-availability statement is documented in:

```text
02_DATA_METADATA/05_data_availability.md
```

---

## H.14 Execution logic

The general execution logic of the repository should follow this order:

```text
1. Review metadata
2. Confirm data availability and station-zone structure
3. Run preprocessing scripts
4. Generate physical-characterization outputs
5. Run classical models
6. Run machine learning models
7. Run deep learning models
8. Run hybrid physical–statistical integration
9. Generate PI90 uncertainty outputs
10. Generate FNRR outputs
11. Generate energy-projection outputs
12. Export figures and tables
13. Review reproducibility files
```

This execution sequence is documented conceptually in this appendix and should be operationally supported by:

```text
07_REPRODUCIBILITY/execution_pipeline.md
```

---

## H.15 Software environment

The software environment should be documented in:

```text
07_REPRODUCIBILITY/software_versions.md
07_REPRODUCIBILITY/sessionInfo.txt
```

These files should preserve information about:

- R version,
- package versions,
- TensorFlow or deep learning backend configuration when applicable,
- operating system context,
- relevant dependencies,
- and computational environment notes.

This is important because model results may depend on package versions, random seeds, numerical libraries, and deep learning configurations.

---

## H.16 Session information

The file:

```text
07_REPRODUCIBILITY/sessionInfo.txt
```

should preserve the R session information associated with the final or representative execution of the workflow.

This file supports reproducibility by documenting:

- loaded packages,
- package versions,
- R version,
- platform information,
- and locale or environment details.

Session information does not guarantee perfect reproduction on every machine, but it provides essential technical context for academic verification.

---

## H.17 Data contract

The file:

```text
07_REPRODUCIBILITY/data_contract.md
```

should define the expected structure of the input data.

It may include:

- required columns,
- variable names,
- station identifiers,
- zone identifiers,
- date-time format,
- accepted units,
- target variables,
- and expected processed outputs.

The data contract helps ensure that the scripts operate on correctly structured inputs.

A recommended minimum data contract includes:

```text
Station identifier
Date-time index
Variable code
Observed value
Zone
Processed value when applicable
Derived physical variables when applicable
```

---

## H.18 Validation checks

The file:

```text
07_REPRODUCIBILITY/validation_checks.md
```

should document the validation checks required to verify that the workflow is coherent.

Recommended checks include:

1. Confirm that station codes match the station-zone mapping.
2. Confirm that all four zones are represented.
3. Confirm that negative non-physical values are treated.
4. Confirm that time fields are correctly parsed.
5. Confirm that units are harmonized before WPD construction.
6. Confirm that WPD is nonnegative when inputs are physically valid.
7. Confirm that model outputs include zone and horizon information.
8. Confirm that PI90 intervals contain lower and upper bounds.
9. Confirm that FNRR values remain within expected bounds.
10. Confirm that usable energy does not exceed free energy.

These checks protect the repository from silent methodological inconsistencies.

---

## H.19 Repository version support

The file:

```text
07_REPRODUCIBILITY/repository_version_support.md
```

should document the state of the repository at the moment of doctoral evaluation.

It may include:

- repository structure,
- commit reference,
- main folders,
- known limitations,
- portability notes,
- and instructions for future refinement.

This is useful because repositories evolve over time. A version-support file helps reviewers understand which structure corresponds to the thesis evaluation stage.

---

## H.20 Portability note

Some scripts may preserve traces of historical local implementation paths used during active development of the thesis.

These paths may include local drive structures, personal directories, or project-specific working folders.

This does not invalidate the scientific logic of the repository, but it should be handled carefully.

Recommended portability improvements include:

- replacing absolute paths with relative paths,
- defining a configurable project root,
- using input/output configuration files,
- documenting required local data locations,
- and separating raw data paths from reproducible output paths.

A recommended pattern is:

```text
project_root/
├── data/
├── 03_CODE/
├── 04_RESULTS_COMPLETE/
└── 07_REPRODUCIBILITY/
```

---

## H.21 Randomness and seeds

Some modeling workflows may involve stochastic components, especially in:

- machine learning,
- deep learning,
- hyperparameter tuning,
- Bayesian optimization,
- train-test splitting,
- and neural-network initialization.

For reproducibility, scripts should define and document random seeds whenever applicable.

A recommended statement is:

```text
All stochastic workflows should define a fixed seed when exact rerun comparability is required.
```

However, even with seeds, exact deep learning reproduction may vary across systems due to hardware, backend, GPU/CPU differences, and numerical libraries.

For this reason, reproducibility should be interpreted as scientific and computational traceability, not always as bit-level identity.

---

## H.22 Reproducibility of physical variables

Derived physical variables must be reproducible from documented equations and code.

The key physical construction is:

```text
WPD = 0.5 · ρ · v³
```

where:

- `ρ` is air density,
- `v` is wind speed,
- and `WPD` is Wind Power Density.

The reproducibility of WPD requires:

- physically admissible wind speed values,
- unit harmonization,
- air-density formulation,
- temperature and pressure consistency,
- and traceable preprocessing.

The mathematical support is documented in:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

---

## H.23 Reproducibility of FNRR

FNRR is defined as a structural regional irregularity descriptor based on WPD quantiles.

The reproducibility of FNRR requires:

- the same WPD series,
- the same zone,
- the same temporal window,
- the same quantile definition,
- the same numerical-stability term,
- and the same preprocessing criteria.

The formal definition is documented in:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

A key reproducibility condition is that FNRR must remain dimensionless and bounded under the stated assumptions.

---

## H.24 Reproducibility of energy outputs

Energy outputs depend on:

```text
WPD
→ prediction
→ temporal integration
→ PI90 uncertainty
→ FNRR
→ free energy
→ usable energy
```

The reproducibility of energy outputs requires:

- consistent WPD construction,
- consistent prediction horizon,
- consistent temporal resolution,
- consistent FNRR computation,
- consistent energy integration,
- and correct distinction between free and usable energy.

The key relationship is:

```text
E_usable = (1 − FNRR) · E_free
```

This relationship should be verified in the final energy outputs.

---

## H.25 Reproducibility of PI90 uncertainty

PI90 outputs should be reproducible from:

- model predictions,
- residual or error structure,
- interval construction method,
- calibration factor,
- and empirical coverage calculation.

The empirical coverage is:

```text
Coverage_PI90 = (1/n) · Σ I[L_i ≤ Y_i ≤ U_i]
```

A calibrated PI90 should satisfy:

```text
Coverage_PI90 ≈ 0.90
```

The uncertainty workflow is documented conceptually in:

```text
04_RESULTS_COMPLETE/03_pi90_uncertainty/
```

and mathematically in:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

---

## H.26 Reproducibility limits

This appendix does not claim that every historical script version can be executed universally without adjustment.

The repository may contain:

- historical development labels,
- local path traces,
- large-data constraints,
- software-version sensitivity,
- and outputs generated during different stages of the doctoral workflow.

These limitations should be interpreted realistically.

The purpose of the repository is to preserve the final scientific logic, evidence structure, methodological transparency, and reproducibility support required for doctoral evaluation.

---

## H.27 What this appendix does not claim

This appendix does not claim that:

- the repository is a fully containerized production pipeline,
- every raw file is publicly included,
- every script is fully portable without local configuration,
- stochastic models will reproduce bit-by-bit on every machine,
- or all historical exploratory files belong to the final workflow.

Instead, it states that the repository preserves:

- the scientific workflow,
- the computational logic,
- the evidence structure,
- the documentation required for review,
- and the conditions needed for future technical refinement.

---

## H.28 Interpretation of internal labels

Some repository files may include labels such as:

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

These labels should be interpreted as internal workflow, modeling, optimization, formatting, or product-orientation labels.

For doctoral evaluation, the core reproducibility interpretation should remain focused on:

- physical characterization,
- predictive modeling,
- uncertainty quantification,
- FNRR computation,
- energy projection,
- and scientific traceability.

Internal labels should not be overinterpreted as separate theoretical claims unless formally defined in the corresponding appendix.

---

## H.29 Reviewer guidance

A reviewer who wants to inspect the repository should follow this route:

```text
1. Read the main README.md
2. Review 01_THESIS/
3. Review 02_DATA_METADATA/
4. Inspect 03_CODE/ structure
5. Review 04_RESULTS_COMPLETE/
6. Inspect figures and tables by chapter
7. Read 05_APPENDICES_SUPPORT/
8. Review 07_REPRODUCIBILITY/
```

For mathematical understanding, the reviewer should prioritize:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

For data interpretation, the reviewer should prioritize:

```text
02_DATA_METADATA/
05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
05_APPENDICES_SUPPORT/Anexo_B_Preprocesamiento_y_Trazabilidad.md
```

For model interpretation, the reviewer should prioritize:

```text
05_APPENDICES_SUPPORT/Anexo_C_Configuracion_Experimental.md
05_APPENDICES_SUPPORT/Anexo_E_Resultados_Extendidos_Cap3.md
```

For energy interpretation, the reviewer should prioritize:

```text
05_APPENDICES_SUPPORT/Anexo_F_Resultados_Extendidos_Cap4.md
```

---

## H.30 Closure criterion

The computational reproducibility layer is considered sufficiently documented when:

1. final repository structure is clear,
2. metadata files define the observational system,
3. code folders correspond to workflow stages,
4. complete results are organized,
5. figures and tables are grouped by chapter,
6. appendices explain methodological and mathematical support,
7. reproducibility files are aligned with `07_REPRODUCIBILITY/`,
8. data-availability limitations are documented,
9. portability limitations are acknowledged,
10. internal labels are interpreted with caution,
11. physical variables are mathematically defined,
12. FNRR and energy outputs are traceable,
13. and reviewers can understand the workflow without verbal explanation.

---

## H.31 Final statement

The computational reproducibility support preserved in this repository is designed to sustain scientific reading, methodological interpretation, and future technical refinement.

Its main value lies in maintaining coherence between:

```text
thesis
→ metadata
→ code
→ complete results
→ figures
→ tables
→ appendices
→ reproducibility files
```

The core principle of this appendix is:

```text
A doctoral computational repository is reproducible when its data structure,
code logic, result evidence, mathematical formulation, and limitations
are sufficiently documented for scientific evaluation.
```

For that reason, Appendix H closes the technical support layer of the repository by documenting the conditions under which the doctoral workflow can be understood, evaluated, and progressively reproduced.

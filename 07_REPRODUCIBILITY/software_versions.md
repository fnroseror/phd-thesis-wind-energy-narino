# Software Versions

## Purpose

This document summarizes the software environment associated with the computational workflow of the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The purpose of this file is to document the main software, language, packages, execution environment, and reproducibility considerations required to understand and progressively reproduce the computational work.

This file supports the reproducibility layer of the repository:

```text
07_REPRODUCIBILITY/
```

and should be read together with:

```text
07_REPRODUCIBILITY/sessionInfo.txt
07_REPRODUCIBILITY/data_contract.md
07_REPRODUCIBILITY/execution_pipeline.md
07_REPRODUCIBILITY/validation_checks.md
05_APPENDICES_SUPPORT/Anexo_H_Reproducibilidad_Computacional.md
```

---

## 1. Software reproducibility scope

The repository is designed to support scientific traceability and progressive reproducibility.

This document does not guarantee exact bit-level reproduction on every machine.

Instead, it documents the software context required to understand, review, and reproduce the workflow under comparable computational conditions.

This distinction is important because the thesis includes:

- data preprocessing;
- physical characterization;
- statistical modeling;
- machine learning;
- deep learning;
- uncertainty quantification;
- FNRR computation;
- energy projection;
- figure generation;
- table export;
- and reproducibility documentation.

The goal is not to claim that every result will be reproduced identically on every computer, but to preserve the computational context that supports scientific review.

---

## 2. Main programming environment

The main computational environment used in the workflow is:

```text
R / RStudio
```

R is used for:

- data reading;
- data cleaning;
- data transformation;
- exploratory analysis;
- statistical summaries;
- physical characterization;
- model execution;
- result export;
- figure generation;
- table generation;
- and reproducibility documentation.

Some deep learning components may also depend on Python-related backends accessed through R packages such as `reticulate`, `tensorflow`, or `keras`.

---

## 3. R version

The representative R environment is documented in:

```text
07_REPRODUCIBILITY/sessionInfo.txt
```

This file should be considered the detailed technical record of the R session.

Recommended interpretation:

```text
The final reproducibility reference should be based on sessionInfo.txt,
which preserves the R version, platform, loaded packages,
namespace information, and system context from the computational environment
used during the doctoral workflow.
```

If multiple R versions were used during development, the final reproducibility review should prioritize the session recorded in:

```text
sessionInfo.txt
```

---

## 4. Operating system context

The computational workflow was developed primarily in a local desktop environment.

The representative environment may include:

```text
Operating system: Windows
Execution environment: RStudio / local machine
```

Exact operating-system details should be read from:

```text
07_REPRODUCIBILITY/sessionInfo.txt
```

Some scripts may contain local path structures from the development environment.

These should be interpreted as historical execution paths and may require adjustment for execution on another machine.

---

## 5. Main package categories

The computational workflow may require packages associated with the following categories:

| Category | Purpose |
|---|---|
| Data manipulation | Cleaning, filtering, grouping, joining, reshaping. |
| Date-time handling | Parsing and organizing time-indexed records. |
| Statistical analysis | Descriptive statistics, distribution fitting, inferential support. |
| Time-series analysis | ACF, PACF, forecasting, temporal modeling. |
| Machine learning | Random Forest, XGBoost, model training, evaluation. |
| Deep learning | LSTM or related neural-network models. |
| Visualization | Figures, plots, exportable graphics. |
| Table export | CSV, Excel, or formatted table outputs. |
| Document support | Word, Markdown, or report-generation support. |
| Reproducibility | Session information, logs, validation outputs. |

---

## 6. Representative R packages

The workflow may involve packages such as the following, depending on the execution stage, script version, and specific analysis block:

```text
readr
readxl
dplyr
tidyr
stringr
lubridate
janitor
purrr
ggplot2
openxlsx
forecast
tseries
fitdistrplus
moments
randomForest
ranger
xgboost
caret
yardstick
keras
tensorflow
reticulate
officer
flextable
```

This list should be interpreted as a representative software environment for the doctoral workflow, not as a guarantee that every package is loaded in every script.

The definitive technical evidence should be checked against:

```text
07_REPRODUCIBILITY/sessionInfo.txt
03_CODE/
```

Not every package listed here is necessarily required for every execution stage.

---

## 7. Data manipulation packages

Data manipulation may involve packages such as:

```text
readr
readxl
dplyr
tidyr
stringr
janitor
purrr
```

These packages support:

- reading source files;
- importing tabular data;
- cleaning column names;
- filtering variables;
- grouping by station, zone, and variable;
- reshaping data;
- summarizing values;
- and preparing analysis-ready datasets.

These packages are mainly related to:

```text
03_CODE/01_preprocessing/
02_DATA_METADATA/
04_RESULTS_COMPLETE/08_TABLES/
```

---

## 8. Date-time packages

Date-time handling may involve:

```text
lubridate
```

This package supports:

- parsing `FechaYHora`;
- extracting year, month, day, hour, or quarter;
- organizing time-indexed observations;
- supporting temporal aggregation;
- and preparing data for time-series modeling.

Correct date-time parsing is essential because the thesis depends on temporal analysis, forecasting, and projection.

---

## 9. Visualization packages

Visualization may involve:

```text
ggplot2
```

and other plotting utilities available through the R environment.

Visualization outputs are stored in:

```text
04_RESULTS_COMPLETE/07_FIGURES/
```

Expected figure folders:

```text
04_RESULTS_COMPLETE/07_FIGURES/chapter_2/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
04_RESULTS_COMPLETE/07_FIGURES/chapter_4/
```

Figures should be interpreted as part of the scientific evidence layer.

---

## 10. Table and spreadsheet export packages

Table and spreadsheet export may involve:

```text
openxlsx
```

This package supports:

- Excel export;
- structured table outputs;
- reviewable spreadsheets;
- and evidence organization for thesis tables.

Exported tables are stored in:

```text
04_RESULTS_COMPLETE/08_TABLES/
```

Expected table folders:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
04_RESULTS_COMPLETE/08_TABLES/chapter_4/
```

---

## 11. Statistical and distributional packages

Statistical and distributional analysis may involve packages such as:

```text
forecast
tseries
fitdistrplus
moments
```

These packages support:

- descriptive statistics;
- distribution fitting;
- Weibull parameter estimation;
- Rayleigh comparison;
- skewness;
- kurtosis;
- ACF and PACF analysis;
- time-series modeling;
- and statistical diagnostics.

These packages are mainly related to:

```text
03_CODE/02_physical_characterization/
03_CODE/03_classical_models/
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/02_model_comparison/
```

---

## 12. Machine learning packages

Machine learning workflows may involve packages such as:

```text
randomForest
ranger
xgboost
caret
yardstick
```

These packages support:

- model training;
- feature-based prediction;
- nonlinear modeling;
- Random Forest approaches;
- XGBoost approaches;
- model comparison;
- error metrics;
- and predictive-performance evaluation.

Machine learning outputs are connected to:

```text
03_CODE/04_machine_learning/
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

The use of each package should be verified in the corresponding scripts before claiming that it is required for a specific execution stage.

---

## 13. Deep learning packages

Deep learning workflows may involve:

```text
keras
tensorflow
reticulate
```

These packages support:

- LSTM modeling;
- neural-network training;
- sequential learning;
- hyperparameter configuration;
- TensorFlow backend execution;
- and R–Python environment interaction.

Deep learning reproducibility may depend on:

- R version;
- Python environment;
- TensorFlow version;
- Keras version;
- CPU or GPU execution;
- random seeds;
- backend configuration;
- and numerical-library behavior.

Exact bit-level reproduction is not guaranteed across systems.

Deep learning outputs are connected to:

```text
03_CODE/05_deep_learning/
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
04_RESULTS_COMPLETE/07_FIGURES/chapter_3/
```

---

## 14. Document and report-generation packages

Document and report-generation workflows may involve:

```text
officer
flextable
```

These packages support:

- Word document generation;
- formatted table outputs;
- appendix support;
- formal report generation;
- and institutional or technical documentation.

These packages are useful for producing or supporting:

```text
05_APPENDICES_SUPPORT/
06_PRODUCTS/
```

Their use should be verified in the specific scripts or document-generation workflows.

---

## 15. Power BI environment

The dashboard product is developed in:

```text
Microsoft Power BI
```

Dashboard documentation is stored in:

```text
06_PRODUCTS/04_dashboard/
```

The public dashboard link is preserved in:

```text
06_PRODUCTS/04_dashboard/powerbi_public_link.txt
```

Power BI is used as an applied visualization and dissemination tool.

It is not the primary computational reproducibility environment for the thesis.

The current dashboard scope is documented in:

```text
06_PRODUCTS/04_dashboard/dashboard_status.md
```

---

## 16. Version-control environment

The repository is hosted on:

```text
GitHub
```

Repository role:

```text
scientific evidence organization
computational traceability
appendix support
product documentation
reproducibility documentation
```

GitHub is used to preserve the structure of the doctoral repository, not necessarily as a complete automated execution platform.

---

## 17. Relationship with `sessionInfo.txt`

The file:

```text
sessionInfo.txt
```

is the most specific technical record of the computational environment.

It should preserve:

- R version;
- platform;
- operating system;
- loaded packages;
- attached packages;
- namespace versions;
- and locale information.

This file is especially important for reproducibility review.

The package list in this document should therefore be interpreted together with:

```text
07_REPRODUCIBILITY/sessionInfo.txt
03_CODE/
```

---

## 18. Local path caution

Some scripts may contain historical local path references used during development.

Examples of local-path dependencies may include:

```text
local drive folders
personal working directories
temporary output folders
cloud-synchronized folders
```

For execution on another machine, local paths should be replaced with project-relative paths.

Recommended approach:

```r
project_root <- "path/to/phd-thesis-wind-energy-narino"
```

Then define inputs and outputs relative to:

```text
project_root
```

This improves portability and reduces dependence on personal directory structures.

---

## 19. Random seed caution

Some workflows include stochastic components.

Examples include:

- train-test splitting;
- machine learning model training;
- hyperparameter tuning;
- Bayesian optimization;
- neural-network initialization;
- and deep learning training.

Recommended practice in R:

```r
set.seed(...)
```

Equivalent seed-control mechanisms should be used for Python/TensorFlow workflows when applicable.

However, even with seeds, exact reproduction may vary across systems due to:

- hardware differences;
- backend differences;
- TensorFlow behavior;
- package versions;
- operating-system differences;
- numerical libraries;
- and parallel computation.

---

## 20. Dependency installation note

A reviewer or future user may need to install missing packages before running the scripts.

Recommended R pattern:

```r
install.packages("package_name")
```

For TensorFlow/Keras workflows, additional configuration may be required through:

```text
reticulate
tensorflow
keras
Python environment
```

The exact environment should be checked against:

```text
sessionInfo.txt
```

and the relevant deep learning scripts.

---

## 21. Package-use caution

The list of packages in this file is intentionally conservative and representative.

It should not be interpreted as a claim that:

- every package was used in every script;
- every package is required for every execution stage;
- all packages were loaded simultaneously;
- or the package list alone is sufficient to reproduce every result.

The correct interpretation is:

```text
The listed packages represent the software ecosystem associated with
the doctoral computational workflow.
Specific package use should be verified through sessionInfo.txt
and the scripts stored in 03_CODE/.
```

---

## 22. Minimum software documentation expected

The reproducibility layer is considered sufficiently documented when it includes:

1. this `software_versions.md` file;
2. `sessionInfo.txt`;
3. package-category information;
4. representative package information;
5. operating-system context;
6. deep learning backend notes when applicable;
7. Power BI documentation for the dashboard product;
8. local path caution;
9. randomness and seed caution;
10. and relationship with the code folders.

---

## 23. What this file does not guarantee

This file does not guarantee that:

- every package version is identical across all historical execution stages;
- every script can run without local configuration;
- all dependencies are automatically installed;
- deep learning results reproduce bit-by-bit;
- the workflow is containerized;
- or the listed packages alone fully define the computational environment.

Instead, it documents the software context needed for scientific review and progressive reproducibility.

---

## 24. Recommended reviewer action

A reviewer interested in software reproducibility should:

```text
1. Read this file.
2. Open sessionInfo.txt.
3. Inspect the relevant scripts in 03_CODE/.
4. Confirm package requirements by execution stage.
5. Verify local paths and input data availability.
6. Review validation_checks.md.
7. Review execution_pipeline.md.
```

---

## 25. Relationship with repository structure

This file is connected to:

```text
03_CODE/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/
06_PRODUCTS/04_dashboard/
07_REPRODUCIBILITY/sessionInfo.txt
07_REPRODUCIBILITY/execution_pipeline.md
07_REPRODUCIBILITY/validation_checks.md
```

It supports the reproducibility interpretation of the computational workflow without replacing the scripts or the recorded session information.

---

## 26. Final statement

The software environment documented here supports the computational traceability of the doctoral thesis.

Its central principle is:

```text
The computational results must be interpreted together with
the software environment, package context, local execution assumptions,
and documented reproducibility limitations.
```

This file therefore supports scientific transparency without overclaiming full automated reproduction across all systems.

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

This is especially important because the thesis includes:

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

---

## 3. R version

The representative R environment is documented in:

```text
07_REPRODUCIBILITY/sessionInfo.txt
```

This file should be considered the detailed technical record of the R session.

Recommended statement:

```text
The final reproducibility reference should be based on sessionInfo.txt,
which preserves the R version, platform, loaded packages, and namespace information
from the computational environment used during the doctoral workflow.
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

The workflow may involve packages such as:

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

This list is representative and should be checked against:

```text
07_REPRODUCIBILITY/sessionInfo.txt
```

and the specific scripts in:

```text
03_CODE/
```

Not every package listed here is necessarily required for every execution stage.

---

## 7. Data manipulation packages

Data manipulation may use packages such as:

```text
dplyr
tidyr
readr
readxl
stringr
purrr
janitor
```

These packages support:

- reading source files;
- cleaning column names;
- filtering variables;
- grouping by station, zone, and variable;
- reshaping data;
- summarizing values;
- and exporting processed data.

---

## 8. Date-time packages

Date-time handling may use packages such as:

```text
lubridate
```

These packages support:

- parsing `FechaYHora`;
- extracting year, month, day, hour, or quarter;
- organizing time-indexed observations;
- and supporting temporal aggregation or filtering.

Correct date-time parsing is essential because the thesis depends on temporal analysis, forecasting, and projection.

---

## 9. Statistical and distributional packages

Statistical and distributional analysis may use packages such as:

```text
fitdistrplus
moments
stats
tseries
forecast
```

These packages support:

- descriptive statistics;
- distribution fitting;
- Weibull parameter estimation;
- Rayleigh comparison;
- ACF and PACF analysis;
- time-series modeling;
- and statistical diagnostics.

---

## 10. Machine learning packages

Machine learning workflows may use packages such as:

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
- error metrics;
- model comparison;
- and performance evaluation.

Machine learning outputs are connected to:

```text
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/08_TABLES/chapter_3/
```

---

## 11. Deep learning packages

Deep learning workflows may use:

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
- and prediction generation.

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

---

## 12. Visualization packages

Visualization may use packages such as:

```text
ggplot2
```

and other plotting utilities.

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

## 13. Table and document export packages

Table and document export may use packages such as:

```text
openxlsx
officer
flextable
```

These packages support:

- Excel export;
- formatted tables;
- Word document generation;
- appendix support;
- and institutional or technical reporting.

Exported tables are stored in:

```text
04_RESULTS_COMPLETE/08_TABLES/
```

---

## 14. Power BI environment

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

---

## 15. Version-control environment

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

## 16. Local path caution

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

```text
project_root <- "path/to/phd-thesis-wind-energy-narino"
```

Then define inputs and outputs relative to:

```text
project_root
```

This improves portability and reduces dependence on personal directory structures.

---

## 17. Random seed caution

Some workflows include stochastic components.

Examples:

- train-test splitting;
- machine learning model training;
- hyperparameter tuning;
- Bayesian optimization;
- neural-network initialization;
- deep learning training.

Recommended practice:

```text
set.seed(...)
```

and equivalent seed control in Python/TensorFlow when applicable.

However, even with seeds, exact reproduction may vary across systems due to:

- hardware differences;
- backend differences;
- TensorFlow behavior;
- package versions;
- operating-system differences;
- and numerical libraries.

---

## 18. Dependency installation note

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

## 19. Relationship with `sessionInfo.txt`

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

---

## 20. Minimum software documentation expected

The reproducibility layer is considered sufficiently documented when it includes:

1. this `software_versions.md` file;
2. `sessionInfo.txt`;
3. package information;
4. operating-system context;
5. deep learning backend notes when applicable;
6. local path caution;
7. randomness and seed caution;
8. and relationship with the code folders.

---

## 21. What this file does not guarantee

This file does not guarantee that:

- every package version is identical across all historical execution stages;
- every script can run without local configuration;
- all dependencies are automatically installed;
- deep learning results reproduce bit-by-bit;
- or the workflow is containerized.

Instead, it documents the software context needed for scientific review and progressive reproducibility.

---

## 22. Recommended reviewer action

A reviewer interested in software reproducibility should:

```text
1. Read this file.
2. Open sessionInfo.txt.
3. Inspect the relevant scripts in 03_CODE/.
4. Confirm package requirements by execution stage.
5. Verify local paths and input data availability.
6. Review validation_checks.md.
```

---

## 23. Final statement

The software environment documented here supports the computational traceability of the doctoral thesis.

Its central principle is:

```text
The computational results must be interpreted together with
the software environment, package context, local execution assumptions,
and documented reproducibility limitations.
```

This file therefore supports scientific transparency without overclaiming full automated reproduction across all systems.

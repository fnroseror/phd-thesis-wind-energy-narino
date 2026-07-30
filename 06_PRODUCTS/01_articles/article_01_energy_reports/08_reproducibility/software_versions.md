# Software Versions — Article 01 Energy Reports

## Purpose

This file documents the main software environment required to reproduce the analytical workflow of Article 01.

The objective is to support computational reproducibility by identifying the programming language, working environment and R packages used to generate the article-level datasets, tables and figures.

---

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  
**Current phase:** Manuscript construction and repository consolidation  

---

## Main software environment

The analytical workflow was developed in:

```text
R / RStudio
```

The scripts were designed to process meteorological records, calculate wind power density, generate statistical summaries, fit probability distributions, compute temporal-dependence diagnostics, perform FFT spectral analysis, and export publication-ready figures and editable tables.

---

## Operating system

The workflow was executed in a Windows-based local environment.

```text
Operating system: Windows
```

The working directory used during development was organized under the local article folder:

```text
E:/Academia/UNAL/DOCTORADO/Productos/Articulo 1
```

For reproducibility, external users should adapt the root path in the scripts to their own local environment.

---

## Main R packages

The main R packages used in the workflow include:

| Package | Main role in the workflow |
|---|---|
| `data.table` | High-performance data manipulation |
| `dplyr` | Data transformation and summary operations |
| `lubridate` | Date and time handling |
| `stringr` | String manipulation |
| `ggplot2` | Figure generation |
| `scales` | Axis labels and scale formatting |
| `zoo` | Short-gap interpolation and regular time-series handling |
| `fitdistrplus` | Weibull distribution fitting |
| `openxlsx` | Export of editable Excel tables |
| `stats` | ACF, PACF, FFT and basic statistical functions |
| `utils` | General R utilities |

---

## Package use by script

| Script | Main packages used |
|---|---|
| `00C_datetime_parser_validation.R` | `data.table`, `lubridate`, `stringr` |
| `01D_density_overlap_strategy.R` | `data.table`, `dplyr`, `lubridate`, `openxlsx` |
| `02E_quality_control_daily_density_wpd.R` | `data.table`, `dplyr`, `ggplot2`, `openxlsx` |
| `05H_distribution_and_publication_figures.R` | `data.table`, `dplyr`, `ggplot2`, `scales`, `fitdistrplus`, `openxlsx` |
| `06I_acf_pacf_temporal_dependence.R` | `data.table`, `dplyr`, `lubridate`, `zoo`, `ggplot2`, `openxlsx`, `stats` |
| `07J_fft_spectral_analysis.R` | `data.table`, `dplyr`, `lubridate`, `zoo`, `ggplot2`, `scales`, `openxlsx`, `stats` |
| `08K_energy_reports_submission_framework.R` | Base R file and folder operations |

---

## Recommended package installation

If the required packages are not installed, they can be installed using:

```r
required_packages <- c(
  "data.table",
  "dplyr",
  "lubridate",
  "stringr",
  "ggplot2",
  "scales",
  "zoo",
  "fitdistrplus",
  "openxlsx"
)

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}

invisible(lapply(required_packages, install_if_missing))
```

---

## Recommended reproducibility command

After running the complete workflow, the following command should be executed in R to save the computational session information:

```r
sink("08_reproducibility/session_info.txt")
sessionInfo()
sink()
```

If the script is executed from the root folder of the article, the recommended path is:

```r
sink("06_PRODUCTS/01_articles/article_01_energy_reports/08_reproducibility/session_info.txt")
sessionInfo()
sink()
```

---

## Session information

The detailed session information should be stored in:

```text
08_reproducibility/session_info.txt
```

This file should include:

```text
R version
Platform
Operating system
Attached packages
Loaded namespaces
Package versions
Locale information
```

---

## Path reproducibility note

The original scripts were developed using a local article root path. Before external execution, users must update the variable:

```r
ARTICLE_ROOT <- "E:/Academia/UNAL/DOCTORADO/Productos/Articulo 1"
```

to match their local repository or article folder.

Example:

```r
ARTICLE_ROOT <- "path/to/article_01_energy_reports"
```

---

## Data reproducibility note

The scripts assume access to the required input data files generated during the workflow.

The final article-level dataset is:

```text
02E_article_main_wpd_dataset_after_qc.rds
```

If raw data are not redistributed, users must obtain the original meteorological records from IDEAM and execute the scripts in the order defined in:

```text
08_reproducibility/execution_order.md
```

---

## Figure reproducibility

All main and supplementary figures must be generated from R scripts.

Main figure scripts:

```text
05H_distribution_and_publication_figures.R
06I_acf_pacf_temporal_dependence.R
07J_fft_spectral_analysis.R
```

Figures should be exported in publication-ready formats such as:

```text
PNG
TIFF
PDF
```

---

## Table reproducibility

All tables should be exported as editable files, preferably:

```text
XLSX
CSV
DOCX
```

Tables should not be submitted as images.

---

## Recommended file naming

Script names should preserve execution order using numeric prefixes:

```text
00C_
01D_
02E_
05H_
06I_
07J_
08K_
```

This naming logic preserves the chronological and methodological order of the workflow.

---

## Computational reproducibility status

```text
R/RStudio workflow: defined
Main packages: identified
Script execution order: defined
Session info: pending
Package versions: pending after final execution
External path adaptation: required
Raw data access: subject to IDEAM data availability
```

---

## TDQ reproducibility rule

No computational result should be included in the manuscript unless it can be traced to:

```text
Script → Package environment → Output file → Figure/table → Manuscript claim
```

This rule ensures that the article remains reproducible, defensible and editorially organized.

# 04_RESULTS_COMPLETE — canonical doctoral results

This directory preserves the approved figures, tables and machine-readable result summaries associated with the corrected doctoral thesis.

## Authority rule

The corrected dissertation PDF is the primary authority. The evidence included here is extracted from that PDF or copied from correction packages explicitly identified as final/canonical. No result was recalculated for this folder.

## Scientific freeze

- WPD remains the principal physical variable.
- TDQ–PIESS/KFAS is an operational physical–statistical workflow.
- `I_TDQ` is internal to the hourly pipeline and is not FNRR.
- FNRR is the separate regional irregularity descriptor used in the quarterly/annual stage.
- `E_free` and `E_usable` are annualized indicators per unit area; they are not actual electricity generation, thermodynamic free energy, or guaranteed energy.
- The 2023–2028 scenario is not a direct extension of the hourly forecasts.

## Evidence coverage

- 31 indexed scientific figures, each with a canonical crop from the corrected dissertation.
- 25 indexed scientific tables, each with page-image evidence and layout-preserving text from the corrected dissertation.
- Selected verified machine-readable exports for Chapters 2–5.
- Chapter 4 editorial package with explicit zero-numerical-change control.

## Directory map

- `00_CANONICAL_INDEX/`: figure/table registries and source authority.
- `01_physical_characterization/`: Chapter 2 machine-readable outputs.
- `02_model_comparison/`: approved candidate/final model summaries.
- `03_pi90_uncertainty/`: PI90 and residual summaries.
- `04_fnrr_outputs/`: interpretation boundary for FNRR outputs.
- `05_energy_projection/`: canonical Chapter 4 tables, traceability and logs.
- `06_extended_results/`: strict separation point for complementary analyses.
- `07_FIGURES/`: 31 canonical thesis figure crops plus verified source exports.
- `08_TABLES/`: 25 canonical table evidence packages plus selected CSVs.

Run the validator from RStudio with:

```r
source("validate_results.R")
```

or from a terminal with:

```bash
Rscript validate_results.R
```

The validator uses base R plus the `digest` package for SHA-256 verification. Global repository closure remains the responsibility of `07_REPRODUCIBILITY`.

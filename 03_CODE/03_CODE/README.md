# 03_CODE — final doctoral code map

This directory documents the computational implementation associated with the corrected doctoral thesis. It preserves the existing eight-stage structure while removing obsolete or contradictory execution paths.

## Scientific authority

The canonical scientific outputs are the values, figures and tables already approved in the corrected thesis. Running these scripts is a reproducibility operation; it does not authorize replacing approved outputs with newly generated alternatives.

Core constraints:

- WPD is the principal physical variable.
- TDQ–PIESS/KFAS is an operational physical–statistical workflow, not a universal physical theory.
- `I_TDQ` is an internal hourly-pipeline state variable.
- FNRR is a separate quarterly regional-irregularity descriptor and is not `I_TDQ`.
- `E_free` and `E_usable` are annualized indicators per unit area. They are not actual electricity generation, thermodynamic free energy, or guaranteed usable energy.
- The 2022-Q3–2028-Q4 quarterly scenario is methodologically separate from hourly horizons `h = 1, 12, 72`.

## Configuration

Run scripts from the repository root. Define the restricted IDEAM source outside Git with:

```bash
# Windows PowerShell
$env:TDQ_DATA_FILE = Join-Path $HOME "restricted/IDEAM/Datos.txt"
$env:TDQ_WORK_DIR  = Join-Path $HOME "tdq_work"

# Linux/macOS
export TDQ_DATA_FILE="/restricted/IDEAM/Datos.txt"
export TDQ_WORK_DIR="/tmp/tdq_work"
```

No raw IDEAM data are distributed in this public folder.

## Folder sequence

1. `01_preprocessing`: canonical station-hour dataset and WPD construction.
2. `02_physical_characterization`: final Chapter 2 execution blocks A–C.
3. `03_classical_models`: persistence, ARIMA and ARIMAX candidate families.
4. `04_machine_learning`: RF/XGBoost candidate families and tuned variants.
5. `05_deep_learning`: LSTM candidate family.
6. `06_hybrid_tdq`: final TDQ–PIESS/KFAS output and complementary diagnostics.
7. `07_energy_projection`: separate quarterly scenario from 2022-Q3 to 2028-Q4.
8. `08_utils`: shared helpers and static code validation.

## Execution modes

- `Rscript 03_CODE/00_run_pipeline.R --check`: configuration and file checks only.
- `Rscript 03_CODE/00_run_pipeline.R --preprocess`: build the controlled station-hour dataset.
- Chapter-specific scripts should be run only when the exact restricted source and declared software environment are available.

The final repository validator in `07_REPRODUCIBILITY` remains the authority for repository closure.

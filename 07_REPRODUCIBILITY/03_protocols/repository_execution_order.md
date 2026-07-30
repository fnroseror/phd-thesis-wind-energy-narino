# Repository execution order

## Documentary validation

1. `02_DATA_METADATA`
2. `03_CODE`
3. `04_RESULTS_COMPLETE`
4. `05_APPENDICES_SUPPORT`
5. `06_PRODUCTS`
6. `07_REPRODUCIBILITY`
7. root README and release files

## Scientific workflow

1. Configure paths in `03_CODE/00_config.R`.
2. Build the station–hour analytical dataset.
3. Run physical–statistical characterization.
4. Verify candidate forecasting families.
5. Verify frozen TDQ–PIESS/KFAS outputs.
6. Run complementary diagnostics without replacing approved results.
7. Run the methodologically separate quarterly scenario from 2022-Q3.
8. Compare generated outputs against canonical tables, figures, and manifests.

The repository must not use a rerun to redefine thesis results.

# Energy Reports — Revision R1/V2 reproducibility scripts

Manuscript EGYR-D-26-02665. Deposit prepared 2026-10-29. These scripts are published for methodological transparency; the deposit **does not certify independent end-to-end reproducibility**.

## Recommended core execution order

1. `R1_06_QC_station_v2.R` — station diagnostics and QC.
2. `R1_07_physical_architecture_comparison_v2.R` — compare physical aggregation architectures.
3. `R1_08_V2_core_LOSO_gap_audit_v2.R` — construct V2 canonical zone-hour data.
4. `R1_09_paired_LOSO_station_influence_v2.R` — paired station influence and leave-one-station-out sensitivity.
5. `R1_10_V2_statistical_core.R` — Weibull/Rayleigh and nonparametric inference.
6. `R1_11_V2_temporal_spectral_core.R` — temporal and spectral diagnostics; **v4 source version**, with earlier alternatives excluded.
7. `R1_12_V2_moving_block_bootstrap_sensitivity_v2.R` — sensitivity analysis, not the primary confidence intervals.
8. `R1_13_run_stratified_circular_block_bootstrap.R` — main bootstrap; requires R1_10 and R1_12 outputs.
9. `R1_14_V2_publication_results_package_v2.R` — publication package; requires R1_10, R1_11 and R1_13 intermediates.

Supporting visualization scripts are in `02_figures/`. Historical, non-primary exploratory scripts are in `03_archive_not_primary/`. An unchanged upstream reference, `01D_density_overlap_strategy.R`, appears under `00_upstream_method_reference/`; its canonical original is located at `../../02_scripts/01D_density_overlap_strategy.R` relative to the current directory.

## Execution constraints

The original IDEAM `Datos.txt`, upstream `01D_final_wpd_candidate_dataset_corrected_datetime.rds` and `02E_article_main_wpd_dataset_after_qc.rds`, and other intermediate analysis objects are required. **Raw meteorological measurements are not redistributed here.** Some scripts use absolute Windows file paths and write to results folders; change paths and work on copies before execution. Dependencies include R packages such as `data.table`, `openxlsx`, `lubridate` and `stringr`. R runtime was unavailable for this pre-submission audit, so the full pipeline has not been re-executed independently.

## Scientific scope and limitations

- The 20 m/s station QC threshold is applied to **station-hour mean** wind speed after subhourly consolidation, not to individual subhourly measurements.
- Daily zone density is the mean of valid hourly density estimates `p/(R_d T)`; it is not generally the ratio of daily mean pressure to daily mean temperature.
- V2 reuses upstream density and candidate temporal support, which must be reconstructed for a complete provenance audit.
- Station 51025060 (Biotopo) has repeated anomalously high observations in 2019; their instrumental validity is unconfirmed. Do not interpret Zone 1 as independently validated turbine-site potential.
- Run-stratified circular block bootstrap resamples within contiguous observed runs; blocks may be shorter than the requested window if the run is shorter. This preserves the missing-interval boundaries but introduces circular wraparound inside a run.

`SHA256_MANIFEST.csv` lists the exact byte count and SHA-256 of each deposited R source file. The files match the authors' staged source package. This addition does not delete or overwrite existing repository content.

These materials support auditability of the manuscript, but the availability of source code and derived result files alone does not demonstrate reproducibility from public inputs.

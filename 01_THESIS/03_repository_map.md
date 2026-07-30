# Repository Map and Thesis Alignment

## Authority hierarchy

Repository interpretation follows this order:

1. Exact corrected thesis PDF submitted after juror review.
2. Three final response letters actually sent to the jurors.
3. Corrected repository with the accepted observations applied.
4. Observation matrix as historical control.

Intermediate drafts and similarly named files are not sources of authority.

## Repository structure

```text
phd-thesis-wind-energy-narino/
├── 01_THESIS/
├── 02_DATA_METADATA/
├── 03_CODE/
├── 04_RESULTS_COMPLETE/
├── 05_APPENDICES_SUPPORT/
├── 06_PRODUCTS/
├── 07_REPRODUCIBILITY/
├── .gitignore
└── README.md
```

The top-level structure is retained. Internal changes are limited to those required to separate canonical evidence, complementary analyses, superseded objects, and reproducibility controls.

## 01_THESIS

Role: formal entry point, scientific scope, contribution summary, version control, checksum record, citation, and temporary PDF-publication status.

The public package does not include the full thesis PDF until institutional similarity analysis is confirmed as complete. The exact PDF checksum is retained for future verification.

## 02_DATA_METADATA

Role: observational foundation and data contract.

Required contents include:

- IDEAM source and access conditions;
- 8,175,686 raw records;
- 2,218,605 valid wind-speed records;
- 365,512 analytical station-hour records;
- 16-station inventory and four-zone mapping;
- effective availability through 1 July 2022;
- variable dictionary;
- missingness, zero-value, plausibility, and air-density-source controls;
- explicit statement that the public repository may not redistribute the complete raw database.

Primary thesis alignment: Chapter 2 and Annex A.

## 03_CODE

Role: executable methodology organized by scientific stage.

Expected retained structure:

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

The code layer must distinguish:

- historical approved pipelines;
- final canonical integration;
- complementary strict-chronology robustness analyses;
- scripts used only for figures, audits, or packaging.

Primary thesis alignment: Chapters 2-4 and Annexes B-H.

## 04_RESULTS_COMPLETE

Role: canonical evidence layer.

It must contain:

- canonical numerical outputs;
- evidence for 31 scientific figures;
- evidence for 25 scientific tables;
- predictive outputs for twelve zone-horizon combinations;
- PI90 and residual evidence;
- FNRR and quarterly/annual scenario outputs;
- explicit separation of complementary and superseded results.

Recommended internal separation:

```text
04_RESULTS_COMPLETE/
├── 01_physical_characterization/
├── 02_model_comparison/
├── 03_pi90_uncertainty/
├── 04_fnrr_outputs/
├── 05_energy_projection/
├── 06_extended_results/
├── 07_FIGURES/
├── 08_TABLES/
├── 09_CANONICAL_MANIFEST/
└── 99_SUPERSEDED_ARCHIVE/   # only when retention is justified
```

The superseded archive must never be referenced as the source of final thesis figures or metrics.

## 05_APPENDICES_SUPPORT

Role: digital annex layer corresponding to the final thesis map.

Expected alignment:

- Annex A - Data traceability and quality control.
- Annex B - Extended physical-statistical characterization.
- Annex C - Configurations and approved predictive-pipeline results.
- Annex D - Chapter 3 freezing and reproducibility.
- Annex E - Complementary robustness analysis; does not replace body results.
- Annex F - Distinction between `I_TDQ` and FNRR.
- Annex G - Canonical Chapter 4 package, identities, hashes, and superseded-file registry.
- Annex H - Computational reproducibility, scripts, software environment, manifests, and repository structure.

## 06_PRODUCTS

Role: derivative-product layer, not core doctoral evidence.

Articles, software/dashboard work, presentations, directed theses, book material, patent-oriented notes, and professorial-project evidence must be labeled by verifiable status. Product materials must not be used to overwrite thesis-level statements or canonical outputs.

## 07_REPRODUCIBILITY

Role: validation and execution-control layer.

Required contents include:

- data contract;
- execution order;
- environment and software versions;
- session information;
- canonical manifest;
- file hashes;
- link and path checks;
- final validator;
- validation log ending in `VALIDATION PASSED`;
- clean-download validation instructions.

## Closure relation

The repository is closed only when the following relation is verified:

`submitted thesis <-> canonical results <-> code <-> figures and tables <-> README`

The final test must be performed on a clean download or clone of the public GitHub repository.

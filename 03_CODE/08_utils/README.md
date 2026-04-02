# 08_utils

## Purpose

This folder contains reusable support functions for the scientific workflow of the repository.

Its role is not to implement domain-specific modeling logic, but to provide transversal utilities that improve:

- consistency,
- portability,
- traceability,
- and reproducibility.

These scripts support the execution of the methodological stages contained in:

- `01_preprocessing/`
- `02_physical_characterization/`
- `03_classical_models/`
- `04_machine_learning/`
- `05_deep_learning/`
- `06_hybrid_tdq/`
- `07_energy_projection/`

---

## Scope

The utilities contained here are restricted to repository-level support tasks such as:

- path handling,
- package verification,
- common evaluation metrics,
- export helpers,
- and validation checks.

This folder must not contain duplicated scientific logic already implemented in the methodological modules.

---

## Files

### `01_paths_config.R`
Defines portable repository paths and output locations.

### `02_packages_setup.R`
Centralizes required package verification and loading.

### `03_metrics_helpers.R`
Contains shared evaluation metrics and interval-quality support functions.

### `04_export_helpers.R`
Contains helper functions for exporting tables, objects, and structured outputs.

### `05_validation_helpers.R`
Contains basic validation checks for inputs, outputs, and required data structure.

---

## Scientific role

This folder reduces structural entropy in the repository by avoiding duplicated support code and by standardizing recurring operations across the pipeline.

Its contribution is operational rather than analytical.

---

## Closure criterion

`08_utils/` is considered complete when:

1. all functions are transversal,
2. no domain-specific modeling logic is duplicated here,
3. scripts in other folders can call these utilities consistently,
4. and the repository becomes easier to execute and audit externally.

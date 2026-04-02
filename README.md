# PhD Thesis Repository – Wind Energy Forecasting in Nariño

This repository contains the computational, methodological, and documentary support material associated with the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The repository is designed to support:

- scientific traceability,
- methodological transparency,
- computational reproducibility,
- and external academic evaluation.

---

## Scientific scope

The repository covers the full analytical pipeline developed in the thesis:

1. Data preprocessing and quality control  
2. Physical–statistical characterization of wind behavior  
3. Classical forecasting models  
4. Machine learning models  
5. Deep learning models  
6. Hybrid TDQ-based modeling  
7. Energy projection framework

---

## Repository structure

### `01_THESIS/`
Core thesis-context documents:
- thesis PDF,
- repository scope,
- contribution summary,
- thesis-to-repository correspondence.

### `02_DATA_METADATA/`
Documentation of the observational basis:
- variable dictionary,
- station-to-zone mapping,
- data structure notes,
- processing assumptions.

### `03_CODE/`
Executable R scripts organized by methodological stage:

- `01_preprocessing/`
- `02_physical_characterization/`
- `03_classical_models/`
- `04_machine_learning/`
- `05_deep_learning/`
- `06_hybrid_tdq/`
- `07_energy_projection/`
- `08_utils/`

### `07_APPENDICES_SUPPORT/`
Extended technical support documents associated with the thesis and computational workflow.

### `09_REPRODUCIBILITY/`
Reproducibility support files:
- data contract,
- execution pipeline,
- software versions,
- session information.

### `data/`
Reduced or demonstration data resources used only for repository-level support and validation.

---

## Reproducibility policy

Raw institutional research data are not fully included in this repository.

The structure, variables, assumptions, and execution requirements are documented in:

- `02_DATA_METADATA/`
- `09_REPRODUCIBILITY/`

This repository is intended to make the workflow understandable, auditable, and reproducible under the documented data contract and software environment.

---

## Methodological architecture

The computational workflow follows this order:

`preprocessing -> physical characterization -> classical models -> machine learning -> deep learning -> hybrid TDQ -> energy projection`

This order reflects the scientific logic of the thesis and the dependency structure between outputs.

---

## Thesis–repository relationship

This repository is not a generic code dump.

It is the structured computational extension of the doctoral thesis, preserving the connection between:

- scientific argument,
- data structure,
- executable methodology,
- generated evidence,
- and derived academic products.

---

## Citation

If this repository is cited, it should be cited together with the corresponding doctoral thesis and its institutional affiliation.

---

## Status

Repository under final scientific closure and reproducibility alignment.

# Physical Characterization

## Purpose

This folder contains the computational workflow associated with the physical characterization stage of the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

Its purpose is to analyze the wind-speed signal (**VV**) as a physical atmospheric system with distributional structure, temporal memory, spectral organization, and multiscale time–frequency behavior.

This folder corresponds specifically to the analytical core of **Chapter 2** of the thesis.

---

## Scientific role within the thesis

The doctoral work does not treat wind speed as a purely numerical input for prediction. Instead, it first develops a structured physical characterization of the signal in order to understand:

- its probabilistic structure,
- its temporal persistence,
- its dominant scales,
- and its intermittency.

This stage is scientifically necessary because the predictive and energetic interpretations developed in later chapters depend on a physically defensible understanding of the wind regime.

Within the thesis, this characterization is performed for the four regional zones defined in Nariño, with **Zone 1** used as the representative zone for the most detailed interpretation.

---

## Conceptual structure of the analysis

The physical characterization is organized into four levels.

### 1. Distributional level
This level evaluates the probabilistic structure of wind speed through:

- descriptive statistics,
- distributional asymmetry and kurtosis,
- Weibull estimation by maximum likelihood,
- Rayleigh comparison,
- and cubic-moment interpretation.

This level establishes whether the wind regime can be approximated by simple canonical models or whether it requires a more flexible distributional representation.

### 2. Temporal-memory level
This level evaluates persistence and dependence structure through:

- ACF,
- and PACF.

Its role is to determine whether the wind regime exhibits short-term inertia, gradual decay, or rigid oscillatory behavior.

### 3. Global spectral level
This level evaluates dominant scales in the signal through:

- FFT-based spectral analysis.

Its role is to identify concentration of spectral power and the presence or absence of dominant global frequencies.

### 4. Time–frequency level
This level evaluates non-stationary multiscale behavior through:

- Wavelet Morlet analysis.

Its role is to detect transient energetic structures, time-localized scale changes, and multiscale intermittency.

---

## Main computational contents of this folder

The scripts in this folder are designed to perform the following tasks:

### 1. Quality control and traceability for VV
- generation of QC tables,
- cleaning traceability for wind-speed records,
- and consistency checks before physical interpretation.

### 2. Descriptive characterization by zone
- descriptive statistics,
- boxplots,
- histograms,
- and signal summaries by zone.

### 3. Weibull–Rayleigh comparison
- MLE fitting of Weibull,
- Rayleigh comparison,
- PDF/CDF outputs,
- Q-Q plots,
- P-P plots,
- and energetic interpretation through the cubic moment.

### 4. Zonal signal construction
- building a representative zonal signal by timestamp,
- and identifying the dominant temporal step for analysis.

### 5. Spectral analysis
- FFT for all zones in annex format,
- and a representative FFT analysis for the main document.

### 6. Time–frequency analysis
- Wavelet analysis for all zones in annex format,
- and a representative Wavelet result for the main document.

### 7. Memory analysis
- ACF and PACF for all zones in annex format,
- and representative ACF/PACF outputs for the main chapter discussion.

### 8. Final synthesis
- generation of a master table integrating the main physical descriptors of the signal.

---

## Expected script in this folder

### `01_cap2_vv_physical_pipeline.R`

This is the main script expected in this folder.

Its role is to execute the reproducible physical-characterization pipeline for **VV**, including:

- QC (`A1`, `A2`, `A3`) and wind-speed cleaning traceability,
- descriptive statistics by zone,
- Weibull vs Rayleigh fitting and comparison,
- zonal signal construction,
- FFT analysis,
- Wavelet analysis,
- ACF/PACF analysis,
- and final master-table generation.

This script should be interpreted as the executable representation of the physical analysis described in Chapter 2 of the thesis.

---

## Main outputs expected from this folder

The computational outputs associated with this folder include:

- descriptive tables by zone,
- QC tables,
- Weibull/Rayleigh comparison tables,
- representative and supplementary figures,
- FFT outputs,
- Wavelet outputs,
- ACF/PACF outputs,
- and a final master summary table.

These outputs are later reflected in:

- `04_RESULTS/physical_characterization/`
- `05_FIGURES/chapter_2/`
- `06_TABLES/chapter_2/`
- and supplementary material in appendices.

---

## Relationship with the preprocessing stage

This folder depends directly on the outputs of:

- `03_CODE/01_preprocessing/`

In particular, it assumes that the observational system has already been:

- cleaned,
- traced,
- temporally parsed,
- organized by zone,
- and physically preserved without distortion of the original signal structure.

For that reason, this stage does not replace preprocessing; it builds on it.

---

## Relationship with later chapters

This physical-characterization stage feeds the scientific logic of later parts of the thesis.

### Feeds Chapter 3
The predictive modeling stage depends on understanding whether the signal is persistent, intermittent, heavy-tailed, or spectrally structured.

### Feeds Chapter 4
The energetic interpretation of wind and the later construction of WPD, uncertainty, and structural projection are more defensible when the wind regime has already been physically characterized.

### Feeds the hybrid interpretation
The TDQ–PIESS stage benefits from this folder because it builds on the idea that the wind system must first be understood as a structured physical process, not only as a forecasting target.

---

## Reproducibility note

This folder should be interpreted as the reproducible physical-analysis layer of the doctoral repository.

Its purpose is not only to generate figures and tables, but to preserve the analytical logic by which the wind regime in Nariño was physically characterized before moving into predictive and energetic modeling.

For that reason, the scripts placed here should satisfy four conditions:

1. remain centered on **VV** as the core signal of Chapter 2,
2. preserve zonal interpretation,
3. make all physical-analysis stages explicit,
4. and export both main-document and supplementary outputs.

---

## Final interpretation

This folder represents the first major interpretive stage of the doctoral workflow.

If preprocessing builds the observational basis, this folder builds the **physical understanding of the wind signal**.

Without this stage, the later predictive and energetic components of the thesis would lose part of their scientific grounding, because the system would be modeled without first being physically characterized.

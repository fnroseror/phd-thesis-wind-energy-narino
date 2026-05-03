# Appendix B — Preprocessing and Traceability

## Purpose

This appendix documents the preprocessing principles, data-treatment decisions, and traceability logic used in the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

Its purpose is to provide extended support for the transformation of the observational meteorological records into analysis-ready structures used for physical characterization, predictive modeling, uncertainty quantification, FNRR computation, and energy projection.

This appendix complements the repository metadata file:

```text
02_DATA_METADATA/04_data_processing_notes.md
```

and should be read together with the preprocessing scripts contained in:

```text
03_CODE/01_preprocessing/
```

---

## B.1 Role of preprocessing in the thesis

Preprocessing is one of the foundational stages of the doctoral workflow.

In this thesis, preprocessing is not interpreted as a purely technical cleaning procedure. It is treated as a physically informed preparation process required to preserve the meaning of the atmospheric signal before characterization, modeling, uncertainty analysis, and energetic interpretation.

The general logic is:

```text
raw observational records
→ quality control
→ cleaning traceability
→ unit harmonization
→ temporal verification
→ station-to-zone organization
→ analysis-ready data
→ physical characterization
→ predictive modeling
→ energetic interpretation
```

The preprocessing stage protects the thesis from two major risks:

1. **Physical distortion of the signal**  
   The atmospheric variables must be treated without introducing artificial transformations that alter their physical meaning.

2. **Loss of methodological traceability**  
   Each processing decision must remain connected to the source data, code, generated outputs, figures, tables, and thesis interpretation.

---

## B.2 Observational basis

The preprocessing workflow was applied to an observational meteorological system composed of approximately **8 million hourly records** corresponding to the period **2017–2022**.

The records were obtained from **16 IDEAM meteorological stations** and organized into **four analytical zones** in the department of **Nariño, Colombia**.

The observational variables considered in the doctoral system include:

- wind speed,
- wind direction,
- atmospheric pressure,
- temperature variables,
- relative humidity,
- precipitation,
- evaporation,
- cloudiness,
- and atmospheric phenomenon.

These variables represent the empirical atmospheric basis from which the thesis constructs its physical, statistical, predictive, and energetic analysis.

---

## B.3 Scientific principle of preprocessing

The central principle of preprocessing in the thesis is:

```text
The atmospheric signal must be processed while preserving its physical nature.
```

This principle is especially important because the central target variable of the thesis, **Wind Power Density (WPD)**, depends directly on wind speed and air density:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

Because wind speed enters the equation with cubic dependence, small distortions in the wind-speed signal may propagate nonlinearly into the energetic interpretation.

Therefore, preprocessing decisions must preserve the physical structure of the signal and avoid transformations that artificially suppress, amplify, or regularize the atmospheric behavior.

---

## B.4 General preprocessing workflow

The preprocessing workflow can be summarized as follows:

```text
1. Source data inspection
2. Variable identification
3. Station identification
4. Quality-control diagnosis
5. Negative-value treatment
6. Missing-value and zero-proportion diagnosis
7. Temporal-resolution verification
8. Unit harmonization for physical calculations
9. Zonal organization
10. Construction of analysis-ready structures
11. Traceability documentation
12. Export of tables, figures, and reproducibility outputs
```

Each stage contributes to the construction of a scientifically consistent dataset.

---

## B.5 Source data inspection

The first step consists of identifying the structure of the original observational records.

This includes verifying:

- station names,
- station codes,
- variable names,
- temporal fields,
- recorded values,
- source formats,
- and potential inconsistencies in naming or formatting.

The goal is not only to read the data, but to preserve the relationship between source records and later outputs.

The station code is treated as the primary traceability key because station names may appear with minor formatting differences across raw files, processed files, tables, and figures.

---

## B.6 Variable identification

The preprocessing stage identifies the meteorological variables required for the thesis workflow.

The core observed variable is:

```text
VV — wind speed
```

Other variables provide physical and contextual support, including:

```text
DV, PA, temperature variables, HR, PR, EV, NU, FA
```

The variable dictionary located in:

```text
02_DATA_METADATA/02_variable_dictionary.md
```

serves as the harmonized reference for interpreting variable names, units, roles, and derived quantities.

---

## B.7 Quality-control diagnosis

A quality-control stage is required before physical characterization and predictive modeling.

This stage includes the identification of:

- missing values,
- non-physical values,
- negative values where physically inadmissible,
- zero-value proportions,
- inconsistent records,
- and temporal irregularities.

The purpose of quality control is not to force the dataset into an ideal structure, but to identify and document the real observational conditions under which the analysis is performed.

This is essential because meteorological datasets often present heterogeneous availability across variables, stations, and time.

---

## B.8 Treatment of non-physical negative values

Negative values that are not physically admissible are removed or excluded according to the physical meaning of each variable and the requirements of the analysis.

For example, negative wind-speed values do not have physical meaning within the observational interpretation used in the thesis.

The treatment of negative values is necessary to prevent invalid results in:

- descriptive statistics,
- distributional fitting,
- WPD construction,
- model training,
- uncertainty estimation,
- and energy projection.

The decision must remain traceable through processing logs or exported cleaning summaries.

---

## B.9 Missing values and zero proportions

The preprocessing workflow documents missing values and zero proportions.

These two quantities must not be treated as equivalent.

### Missing values

Missing values indicate absent information and may result from:

- station interruptions,
- sensor failure,
- download limitations,
- operational gaps,
- or incomplete source records.

### Zero values

Zero values may represent:

- physically meaningful calm conditions,
- sensor behavior,
- low-intensity regimes,
- or source-specific encoding.

For that reason, zero values require diagnostic interpretation rather than automatic deletion.

In wind-energy analysis, zero or near-zero wind-speed values may be physically meaningful because they represent low-energy states of the atmospheric system.

---

## B.10 Temporal-resolution verification

The thesis uses hourly meteorological records.

Temporal-resolution verification is therefore necessary because several analytical stages depend on the time structure of the signal, including:

- autocorrelation analysis,
- partial autocorrelation analysis,
- spectral analysis,
- wavelet analysis,
- time-series forecasting,
- horizon-based prediction,
- and integrated energy estimation.

Temporal irregularity can affect the interpretation of lag structure, frequency content, and forecast horizon.

For this reason, preprocessing must verify the time organization before applying temporal or spectral methods.

---

## B.11 Unit harmonization

Observed variables may originate from source-specific units or formats.

For physical calculations, variables must be harmonized into units compatible with the equations used in the thesis.

This is especially relevant for:

- wind speed,
- atmospheric pressure,
- temperature,
- air density,
- and Wind Power Density.

The physical construction of air density and WPD requires unit consistency.

Without unit harmonization, derived energetic variables may lose physical meaning.

---

## B.12 Zonal organization

After the source records are inspected and processed, the data are organized according to the four analytical zones defined in the thesis.

The zone is the operational spatial unit used for:

- physical characterization,
- predictive modeling,
- uncertainty analysis,
- FNRR computation,
- and energy projection.

The zonal organization connects station-level observations with regional interpretation.

The corresponding station-to-zone mapping is documented in:

```text
02_DATA_METADATA/03_station_zone_mapping.md
```

and extended in:

```text
05_APPENDICES_SUPPORT/Anexo_A_Base_Datos_y_Zonificacion.md
```

---

## B.13 Analysis-ready data structures

The preprocessing stage produces analysis-ready structures for later stages of the thesis.

These structures may include:

- cleaned variable-specific datasets,
- zonal datasets,
- processed wind-speed series,
- temporal summaries,
- quality-control tables,
- diagnostic logs,
- and intermediate structures required for modeling.

The purpose of these outputs is to create a consistent bridge between raw observational records and the scientific analyses reported in the thesis.

---

## B.14 Traceability outputs

Preprocessing must generate or support traceability outputs such as:

- count of records by variable,
- missing-value diagnostics,
- negative-value diagnostics,
- temporal-resolution summaries,
- cleaning logs,
- processing parameters,
- station-to-zone tables,
- master zonal tables,
- and exported configuration files.

In the current repository structure, several Chapter 2 traceability tables are located in:

```text
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
```

Examples include:

```text
A1_Conteo_Registros_por_Variable.csv
A2_QC_NA_y_Negativos_por_Variable.csv
A3_Resolucion_Temporal_por_Zona_Estacion.csv
CFG_Cap2_parametros_usados.csv
VV_Log_Parametros_Procesamiento.csv
VV_Trazabilidad_Limpieza.csv
VV_Tabla_Maestra_Zonas.csv
```

These files provide numerical support for the preprocessing and traceability stage.

---

## B.15 Relationship with Chapter 2

Preprocessing directly supports Chapter 2 of the thesis.

Chapter 2 depends on preprocessing because physical characterization requires reliable data structures before applying:

- descriptive statistics,
- variance analysis,
- Weibull fitting,
- Rayleigh comparison,
- ACF,
- PACF,
- FFT,
- and Wavelet analysis.

The logical relationship is:

```text
preprocessing
→ clean wind-speed signal
→ zonal organization
→ descriptive statistics
→ distributional fitting
→ temporal analysis
→ spectral analysis
→ physical characterization
```

If preprocessing is weak, the physical interpretation of Chapter 2 becomes less reliable.

For that reason, this appendix is part of the scientific defense of the thesis.

---

## B.16 Relationship with predictive modeling

Preprocessing also supports the predictive modeling stage.

The outputs of preprocessing feed:

```text
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
```

The folder `03_CODE/06_hybrid_tdq/` reflects the current repository naming. In this appendix, it should be interpreted as part of the hybrid physical–statistical integration layer of the doctoral workflow.

The predictive modeling stage requires consistent inputs because model comparison depends on:

- equivalent target construction,
- comparable validation logic,
- stable zonal organization,
- correct temporal ordering,
- and physically meaningful derived variables.

---

## B.17 Relationship with WPD construction

The preprocessing stage is essential for constructing **Wind Power Density**.

The physical chain is:

```text
wind speed + pressure + temperature
→ air density
→ WPD
→ predictive modeling
→ uncertainty analysis
→ energy interpretation
```

Because WPD is highly sensitive to wind speed, the preprocessing of wind-speed observations has direct impact on the final energetic interpretation.

This is why the thesis treats preprocessing as a physically informed stage rather than as a purely statistical filtering process.

---

## B.18 Relationship with uncertainty analysis

The PI90 uncertainty framework depends on the quality and structure of the data used for forecasting.

If preprocessing introduces inconsistencies, uncertainty calibration may become unreliable.

Preprocessing supports uncertainty analysis by preserving:

- temporal consistency,
- target-variable coherence,
- validation structure,
- residual interpretability,
- and zone-level comparability.

The uncertainty result layer is documented in:

```text
04_RESULTS_COMPLETE/03_pi90_uncertainty/
```

and supported by corresponding tables and figures in:

```text
04_RESULTS_COMPLETE/08_TABLES/
04_RESULTS_COMPLETE/07_FIGURES/
```

---

## B.19 Relationship with FNRR

FNRR is computed from the structural behavior of Wind Power Density.

Therefore, the reliability of FNRR depends on:

- correct preprocessing,
- correct construction of WPD,
- consistent zonal organization,
- robust treatment of irregularity,
- and traceable energetic outputs.

The FNRR result layer is documented in:

```text
04_RESULTS_COMPLETE/04_fnrr_outputs/
```

and the formal physical–mathematical support should be documented in:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

or its corresponding Word version.

---

## B.20 Relationship with energy projection

Energy projection depends on the full preprocessing chain.

The logical relationship is:

```text
preprocessed observations
→ WPD construction
→ model prediction
→ PI90 uncertainty
→ FNRR adjustment
→ free energy
→ usable energy
→ projection toward 2028
```

Any inconsistency in preprocessing can propagate through the entire energy-projection pipeline.

Therefore, preprocessing is not only a preliminary stage; it is part of the scientific foundation of the projected results.

The energy-projection layer is documented in:

```text
04_RESULTS_COMPLETE/05_energy_projection/
```

---

## B.21 Relationship with reproducibility

This appendix should be read together with:

```text
07_REPRODUCIBILITY/
```

The reproducibility section provides execution logic, software environment information, and verification support.

The preprocessing stage contributes to reproducibility by documenting:

- input assumptions,
- cleaning criteria,
- output structures,
- processing parameters,
- and traceability files.

The relationship is:

```text
metadata
→ preprocessing scripts
→ traceability tables
→ results
→ reproducibility documentation
```

---

## B.22 Recommended preprocessing traceability chain

The recommended traceability chain for the preprocessing stage is:

```text
source file
→ station code
→ variable code
→ date-time
→ raw value
→ quality-control diagnosis
→ cleaning decision
→ processed value
→ zone assignment
→ derived variable
→ output table or figure
→ thesis interpretation
```

This chain allows reviewers to understand how observational records become scientific results.

---

## B.23 Repository locations associated with preprocessing

The main repository locations associated with preprocessing are:

```text
02_DATA_METADATA/
03_CODE/01_preprocessing/
04_RESULTS_COMPLETE/08_TABLES/chapter_2/
04_RESULTS_COMPLETE/01_physical_characterization/
05_APPENDICES_SUPPORT/
07_REPRODUCIBILITY/
```

Each location plays a different role:

| Location | Role |
|---|---|
| `02_DATA_METADATA/` | Defines dataset structure, variables, stations, zones, and data availability. |
| `03_CODE/01_preprocessing/` | Contains executable preprocessing logic. |
| `04_RESULTS_COMPLETE/08_TABLES/chapter_2/` | Stores preprocessing and traceability tables. |
| `04_RESULTS_COMPLETE/01_physical_characterization/` | Stores physical-characterization outputs derived from preprocessed data. |
| `05_APPENDICES_SUPPORT/` | Provides extended methodological explanation. |
| `07_REPRODUCIBILITY/` | Supports reproducibility and execution verification. |

---

## B.24 Methodological caution

This appendix documents the scientific rationale of preprocessing and traceability.

It does not replace the executable scripts.

Exact implementation details must be verified in the corresponding code files and reproducibility documentation.

This distinction is important because the appendix explains the methodological logic, while the code provides the executable implementation.

---

## B.25 What this appendix does not claim

This appendix does not claim that preprocessing eliminates all uncertainty from the dataset.

It also does not claim that the observational system is perfectly balanced across variables, stations, or zones.

Instead, it states that preprocessing was designed to preserve:

- physical interpretability,
- methodological traceability,
- zonal coherence,
- predictive consistency,
- uncertainty-awareness,
- and energetic meaning.

This is the correct scientific position for a large environmental observational system.

---

## B.26 Closure criterion

The preprocessing and traceability stage is considered sufficiently documented when:

1. variable structure is defined,
2. station and zone structure is documented,
3. quality-control criteria are explained,
4. negative and missing values are addressed methodologically,
5. temporal resolution is considered,
6. unit harmonization is acknowledged,
7. traceability outputs are linked to result tables,
8. preprocessing scripts are linked to code folders,
9. derived variables are connected to physical equations,
10. and reproducibility material is aligned with the final repository structure.

---

## B.27 Final statement

Preprocessing in this doctoral thesis is not a secondary technical task.

It is the scientific preparation stage that allows observational meteorological records to become physically interpretable, statistically analyzable, computationally modelable, probabilistically evaluable, and energetically meaningful.

The core principle of this appendix is:

```text
A forecast is only scientifically meaningful if the signal used to build it
has been processed with physical consistency and methodological traceability.
```

For that reason, preprocessing and traceability form one of the essential foundations of the doctoral repository.

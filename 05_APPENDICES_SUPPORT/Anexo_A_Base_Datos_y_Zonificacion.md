# Appendix A — Database and Zonal Structure

## Purpose

This appendix documents the observational database, variable structure, meteorological station network, and zonal organization used in the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

Its purpose is to provide extended support for the empirical foundation of the thesis and to clarify how the observational meteorological system was organized before physical characterization, predictive modeling, uncertainty analysis, FNRR computation, and energy projection.

This appendix complements the metadata files contained in:

```text
02_DATA_METADATA/
```

and should be read together with the complete result structure contained in:

```text
04_RESULTS_COMPLETE/
```

---

## A.1 Role of the database in the thesis

The doctoral thesis is based on a large observational meteorological dataset corresponding to the department of **Nariño, Colombia**.

The dataset provides the empirical basis for:

- physical characterization of wind behavior,
- construction of derived physical variables,
- estimation of Wind Power Density,
- model comparison,
- uncertainty quantification,
- FNRR computation,
- and regional energy-potential projection.

Within the thesis, the database is not interpreted as a simple numerical table. It is treated as the observational representation of a regional atmospheric system.

The general scientific workflow is:

```text
meteorological observations
→ preprocessing
→ zonal organization
→ physical characterization
→ derived physical variables
→ predictive modeling
→ uncertainty quantification
→ FNRR interpretation
→ energy projection
```

---

## A.2 Observational basis

The observational basis of the thesis consists of approximately **8 million hourly meteorological records** corresponding to the period **2017–2022**.

The data were organized from **16 meteorological stations** and consolidated into **four analytical zones**.

This structure allowed the thesis to preserve station-level traceability while enabling regional physical and predictive interpretation.

The observational system supports the analysis of:

- wind speed,
- wind direction,
- temperature,
- atmospheric pressure,
- relative humidity,
- evaporation,
- cloudiness,
- precipitation,
- and atmospheric phenomena.

---

## A.3 General structure of the database

The database can be interpreted through five main layers:

| Layer | Description | Role in the thesis |
|---|---|---|
| Observational layer | Original meteorological measurements by station and time. | Provides the empirical atmospheric signal. |
| Variable layer | Meteorological variables recorded in the dataset. | Defines the physical quantities available for analysis. |
| Station layer | IDEAM station network used in the study. | Preserves source-level spatial traceability. |
| Zonal layer | Grouping of stations into four analytical zones. | Supports regional physical and predictive interpretation. |
| Derived-variable layer | Physical and energetic variables computed from observations. | Enables WPD, energy, uncertainty, and FNRR analysis. |

This layered interpretation is important because the thesis does not treat the data as isolated observations. The data are organized as a reproducible physical–statistical system.

---

## A.4 Variable codes used in the database

The following meteorological variables are included in the observational system.

| Code | Variable | Physical interpretation | Role in the thesis |
|---|---|---|---|
| **VV** | Wind speed | Intensity of wind motion. | Primary observed variable and basis for WPD construction. |
| **DV** | Wind direction | Directional behavior of wind flow. | Complementary descriptor of wind-regime structure. |
| **PA** | Atmospheric pressure | Pressure state of the atmosphere. | Required for air-density estimation and physical interpretation. |
| **TM / Tmax** | Maximum or source-recorded temperature variable | Thermal condition of the atmosphere. | Supports thermodynamic interpretation and air-density estimation when applicable. |
| **Tmin / Tm** | Minimum or source-recorded minimum temperature variable | Lower thermal bound of the observational period. | Supports thermal characterization of the regional atmospheric system. |
| **HR** | Relative humidity | Moisture content relative to saturation. | Complementary atmospheric condition. |
| **PR** | Precipitation | Hydrometeorological forcing. | Supports interpretation of regional atmospheric variability. |
| **EV** | Evaporation | Surface-atmosphere exchange indicator. | Supports interpretation of surface-related atmospheric processes. |
| **NU** | Cloudiness | Cloud-cover condition. | Supports interpretation of radiative and atmospheric-state conditions. |
| **FA** | Atmospheric phenomenon | Qualitative or categorical atmospheric-state descriptor. | Contextual atmospheric variable. |

### Note on temperature notation

Some source files or processing stages may use different labels for temperature variables, such as `TM`, `Tmax`, `Tm`, or `Tmin`.

For repository interpretation, the variable dictionary in:

```text
02_DATA_METADATA/02_variable_dictionary.md
```

should be used as the harmonized reference.

The station code, variable code, and processing script should always be preserved as the primary traceability elements.

---

## A.5 Variable-level record availability

The observational system is heterogeneous. Not all variables have the same number of downloaded records, temporal density, or station-level coverage.

The recorded variable-level counts are:

| Variable | Number of downloaded records |
|---|---:|
| Velocidad de Viento | 2,218,605 |
| Dirección de Viento | 2,210,920 |
| Fenómeno Atmosférico | 21,018 |
| Presión Atmosférica | 280,741 |
| Precipitación | 1,977,895 |
| Evaporación | 13,753 |
| Nubosidad | 35,688 |
| Temperatura Máxima | 422,999 |
| Temperatura Mínima | 414,278 |
| Humedad Relativa | 674,093 |

This heterogeneity is methodologically relevant.

It indicates that the database is not a uniform rectangular structure where all variables are equally available across all stations and times. Instead, it reflects the real behavior of large meteorological observational systems, where variable availability may differ due to station instrumentation, reporting continuity, operational conditions, and variable-specific measurement practices.

For this reason, the thesis adopts a zonal and physically informed organization strategy.

---

## A.6 Meteorological station inventory

The observational basis is composed of 16 meteorological stations.

| No. | Station code | Source station name |
|---:|---:|---|
| 1 | 52055230 | AEROPUERTO SAN LUIS - AUT |
| 2 | 51025060 | BIOTOPO - AUT |
| 3 | 52055210 | BOTANA - AUT |
| 4 | 51025080 | ALTAQUER - AUT |
| 5 | 52040050 | APONTE |
| 6 | 51035020 | CCCP DL PACIFICO |
| 7 | 52055150 | CERRO PARAMO - AUT |
| 8 | 52055220 | EL PARAISO - AUT |
| 9 | 47015100 | EL ENCANO - AUT |
| 10 | 51025090 | GRANJA MIRA |
| 11 | 5205500123 | LAS IGLESIAS - AUT |
| 12 | 52055160 | VOLCAN CHILES - AUT |
| 13 | 52055170 | LA JOSEFINA - AUT |
| 14 | 52045080 | UNIVERSIDAD DE NARINO - AUT |
| 15 | 5102500128 | RESERVA NATURAL LA PLANADA - AUT |
| 16 | 52035040 | VIENTO LIBRE - AUT |

The station code is the primary traceability key.

Station names may appear with minor formatting differences across outputs, scripts, or tables. For that reason, the station code should be used as the stable identifier when linking source data, processed outputs, figures, tables, and thesis results.

---

## A.7 Zonal organization

The thesis organizes the 16 stations into four analytical zones.

The zone is the operational spatial unit used in the thesis to support:

- regional physical characterization,
- comparison of wind regimes,
- predictive modeling,
- uncertainty analysis,
- FNRR computation,
- and energy projection.

This zonal structure is methodological and analytical. It should not be interpreted as an official administrative, geographic, or climatic classification unless additional evidence is explicitly provided.

The purpose of the zonal organization is to preserve regional interpretability and analytical stability in the presence of heterogeneous observational availability.

---

## A.8 Zone 1

### Stations assigned to Zone 1

| Zone | Station code | Normalized station name | Source station name |
|---:|---:|---|---|
| 1 | 51035020 | CCCP DL PACIFICO | CCCP DL PACIFICO |
| 1 | 51025090 | GRANJA MIRA | GRANJA MIRA |
| 1 | 51025080 | ALTAQUER | ALTAQUER - AUT |
| 1 | 51025060 | BIOTOPO | BIOTOPO - AUT |
| 1 | 5102500128 | RESERVA NATURAL LA PLANADA | RESERVA NATURAL LA PLANADA - AUT |

**Total stations in Zone 1:** 5

### Interpretation

Zone 1 represents one of the regional atmospheric units used for physical and statistical analysis.

Its role is to support the characterization of wind behavior and associated meteorological variables under a common analytical structure.

---

## A.9 Zone 2

### Stations assigned to Zone 2

| Zone | Station code | Normalized station name | Source station name |
|---:|---:|---|---|
| 2 | 52055220 | EL PARAISO | EL PARAISO - AUT |
| 2 | 52055170 | LA JOSEFINA | LA JOSEFINA - AUT |
| 2 | 52055230 | AEROPUERTO SAN LUIS | AEROPUERTO SAN LUIS - AUT |
| 2 | 52055160 | VOLCAN CHILES | VOLCAN CHILES - AUT |

**Total stations in Zone 2:** 4

### Interpretation

Zone 2 is used as a regional atmospheric unit for physical characterization, predictive modeling, uncertainty analysis, and energetic interpretation.

The zone supports evaluation of how wind-energy behavior varies across the regional structure defined in the thesis.

---

## A.10 Zone 3

### Stations assigned to Zone 3

| Zone | Station code | Normalized station name | Source station name |
|---:|---:|---|---|
| 3 | 5205500123 | LAS IGLESIAS | LAS IGLESIAS - AUT |
| 3 | 52045080 | UNIVERSIDAD DE NARINO | UNIVERSIDAD DE NARINO - AUT |
| 3 | 47015100 | EL ENCANO | EL ENCANO - AUT |
| 3 | 52055210 | BOTANA | BOTANA - AUT |
| 3 | 52055150 | CERRO PARAMO | CERRO PARAMO - AUT |

**Total stations in Zone 3:** 5

### Interpretation

Zone 3 contributes to regional comparison across the thesis.

Its inclusion allows the modeling framework to evaluate whether physical characterization, predictive behavior, uncertainty, and energetic interpretation remain coherent across different analytical zones.

---

## A.11 Zone 4

### Stations assigned to Zone 4

| Zone | Station code | Normalized station name | Source station name |
|---:|---:|---|---|
| 4 | 52035040 | VIENTO LIBRE | VIENTO LIBRE - AUT |
| 4 | 52040050 | APONTE | APONTE |

**Total stations in Zone 4:** 2

### Interpretation

Zone 4 is the smallest zonal unit in terms of station count.

For that reason, its results should be interpreted with methodological caution, especially when comparing it with zones that contain a larger number of stations.

Its inclusion preserves the complete zonal structure of the doctoral dataset and allows the thesis to compare physical, predictive, and energetic behavior across all defined zones.

---

## A.12 Global zonal summary

| Zone | Number of stations | Percentage of station network |
|---:|---:|---:|
| 1 | 5 | 31.25% |
| 2 | 4 | 25.00% |
| 3 | 5 | 31.25% |
| 4 | 2 | 12.50% |
| **Total** | **16** | **100.00%** |

This distribution shows that the station network is not equally balanced across zones.

Therefore, all zonal comparisons should be interpreted in relation to both the physical structure of the atmospheric system and the observational density available in each zone.

---

## A.13 Consolidated station-to-zone mapping

| Zone | Station code | Normalized station name | Source station name |
|---:|---:|---|---|
| 1 | 51035020 | CCCP DL PACIFICO | CCCP DL PACIFICO |
| 1 | 51025090 | GRANJA MIRA | GRANJA MIRA |
| 1 | 51025080 | ALTAQUER | ALTAQUER - AUT |
| 1 | 51025060 | BIOTOPO | BIOTOPO - AUT |
| 1 | 5102500128 | RESERVA NATURAL LA PLANADA | RESERVA NATURAL LA PLANADA - AUT |
| 2 | 52055220 | EL PARAISO | EL PARAISO - AUT |
| 2 | 52055170 | LA JOSEFINA | LA JOSEFINA - AUT |
| 2 | 52055230 | AEROPUERTO SAN LUIS | AEROPUERTO SAN LUIS - AUT |
| 2 | 52055160 | VOLCAN CHILES | VOLCAN CHILES - AUT |
| 3 | 5205500123 | LAS IGLESIAS | LAS IGLESIAS - AUT |
| 3 | 52045080 | UNIVERSIDAD DE NARINO | UNIVERSIDAD DE NARINO - AUT |
| 3 | 47015100 | EL ENCANO | EL ENCANO - AUT |
| 3 | 52055210 | BOTANA | BOTANA - AUT |
| 3 | 52055150 | CERRO PARAMO | CERRO PARAMO - AUT |
| 4 | 52035040 | VIENTO LIBRE | VIENTO LIBRE - AUT |
| 4 | 52040050 | APONTE | APONTE |

---

## A.14 Methodological meaning of zoning

The zonal structure was adopted to reduce fragmentation in the analysis and to support regional interpretation.

Its methodological functions are:

1. **Spatial organization**  
   It provides an operational spatial unit for the dataset.

2. **Physical interpretation**  
   It allows the wind signal to be interpreted by regional atmospheric subsystems.

3. **Statistical stability**  
   It supports the construction of zonal datasets from heterogeneous station-level observations.

4. **Predictive comparability**  
   It allows model behavior to be compared across zones.

5. **Uncertainty interpretation**  
   It allows PI90 and related uncertainty outputs to be interpreted regionally.

6. **Energetic interpretation**  
   It supports the computation and interpretation of WPD, FNRR, free energy, usable energy, and projected energy by zone.

---

## A.15 Derived physical and energetic variables

The thesis does not rely only on raw meteorological observations.

It constructs derived physical and energetic variables, including:

| Variable | Description | Role in the thesis |
|---|---|---|
| **ρ** | Air density | Required for WPD computation. |
| **WPD** | Wind Power Density | Central physical target variable of the thesis. |
| **Eh** | Horizon-integrated energy | Energetic quantity accumulated over a prediction horizon. |
| **E_free** | Free energy | Physically available energetic potential before FNRR adjustment. |
| **E_usable** | Usable energy | Energy remaining after structural irregularity adjustment. |
| **FNRR** | Factor de No Regularidad Regional | Dimensionless descriptor of regional irregularity. |
| **PI90** | 90% prediction interval | Probabilistic uncertainty representation. |

---

## A.16 Wind Power Density

The central physical target variable of the thesis is **Wind Power Density (WPD)**:

```text
WPD = 0.5 · ρ · v³
```

where:

- `WPD` is Wind Power Density,
- `ρ` is air density,
- and `v` is wind speed.

This expression is central because it connects observed wind speed with energetic potential.

The cubic dependence on wind speed means that small changes in wind speed can produce amplified changes in energy interpretation. Therefore, the integrity of the wind-speed signal and the consistency of preprocessing are critical.

---

## A.17 From observational variables to energy interpretation

The role of the database can be summarized as follows:

```text
VV + PA + temperature variables
→ air density estimation
→ WPD construction
→ predictive modeling
→ uncertainty intervals
→ FNRR computation
→ free energy
→ usable energy
→ projected regional energy
```

This chain shows why the database must be documented carefully.

The reliability of the final energy interpretation depends on the traceability of the observational variables, the preprocessing logic, the zonal structure, and the construction of derived physical variables.

---

## A.18 Relationship with repository metadata

This appendix should be read together with the following metadata files:

```text
02_DATA_METADATA/01_dataset_overview.md
02_DATA_METADATA/02_variable_dictionary.md
02_DATA_METADATA/03_station_zone_mapping.md
02_DATA_METADATA/04_data_processing_notes.md
02_DATA_METADATA/05_data_availability.md
```

Those files provide the repository-level metadata, while this appendix provides an extended thesis-support explanation of the database and zonal structure.

---

## A.19 Relationship with results

The database and zonal structure documented in this appendix support the result folders:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/07_FIGURES/
04_RESULTS_COMPLETE/08_TABLES/
```

The logical connection is:

```text
database and zones
→ physical characterization
→ model comparison
→ uncertainty analysis
→ FNRR outputs
→ energy projection
→ figures and tables
```

---

## A.20 Relationship with code

The database and zonal structure are operationally connected with the computational workflow contained in:

```text
03_CODE/01_preprocessing/
03_CODE/02_physical_characterization/
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
03_CODE/08_utils/
```

The folder `03_CODE/06_hybrid_tdq/` reflects the current repository naming. In the scientific interpretation of this appendix, it should be understood as part of the hybrid physical–statistical integration stage of the doctoral workflow.

---

## A.21 Methodological caution

The zonal structure documented in this appendix should be interpreted as the validated operational structure of the doctoral dataset.

It should not be interpreted as:

- an official administrative classification,
- a universal climatological classification,
- or a standalone geographic zoning system independent of the thesis.

Its role is methodological: it organizes the observational system into regional units that allow coherent physical, statistical, predictive, uncertainty-aware, and energetic analysis.

Any more detailed geographic, topographic, or climatological interpretation should be supported by additional station metadata, maps, or specialized territorial evidence.

---

## A.22 Traceability principle

The traceability chain of the database is:

```text
station code
→ source station name
→ normalized station name
→ zone
→ observed variables
→ processed data
→ derived variables
→ model outputs
→ figures and tables
→ thesis interpretation
```

The station code should always be treated as the primary identifier.

This protects the repository from ambiguity caused by name formatting differences, accents, suffixes such as `- AUT`, or variations between source exports and processed files.

---

## A.23 Final statement

This appendix defines the empirical and spatial foundation of the doctoral thesis.

It documents:

- the observational database,
- the variable structure,
- the station inventory,
- the zonal organization,
- the methodological meaning of zoning,
- the derived physical variables,
- and the traceability chain connecting data with results.

For that reason, Appendix A is essential for understanding how the thesis moves from meteorological observations to physical characterization, predictive modeling, uncertainty quantification, FNRR interpretation, and regional energy projection.

The core principle is:

```text
The scientific validity of the final energy projection depends on the traceability,
organization, and physical interpretation of the observational database.
```

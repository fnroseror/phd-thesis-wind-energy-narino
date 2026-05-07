# Data Contract

## Purpose

This document defines the expected data structure required by the computational workflow associated with the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The purpose of this data contract is to document the minimum structure, required fields, variable conventions, expected formats, and physical interpretation required for reproducible processing of the meteorological dataset.

This document supports the reproducibility layer of the repository:

```text
07_REPRODUCIBILITY/
```

and should be read together with:

```text
02_DATA_METADATA/
03_CODE/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/
```

---

## 1. Data contract scope

The computational workflow expects meteorological observations organized in a long-format structure.

The minimum expected structure is:

```text
Estación
FechaYHora
Valor
Zona
Variable
```

This structure allows the workflow to represent multiple stations, variables, zones, and timestamps in a unified format.

The data contract applies to:

- preprocessing;
- physical characterization;
- descriptive statistics;
- variable-specific analysis;
- wind-speed analysis;
- Wind Power Density construction;
- predictive modeling;
- uncertainty support;
- FNRR computation;
- energy projection;
- and dashboard or visualization products.

---

## 2. Minimum required columns

| Column | Required | Type | Description |
|---|---|---|---|
| `Estación` | Yes | Character / factor | Name or identifier of the meteorological station. |
| `FechaYHora` | Yes | Datetime | Date and time of the observation. |
| `Valor` | Yes | Numeric | Observed value associated with the corresponding variable. |
| `Zona` | Yes | Integer / factor | Analytical zone assigned to the station. |
| `Variable` | Yes | Character / factor | Meteorological variable code. |

The workflow assumes that each row corresponds to one observation of one meteorological variable at one station and one timestamp.

---

## 3. Expected long-format structure

The expected input format is:

```text
Estación | FechaYHora | Valor | Zona | Variable
```

Illustrative example:

```text
AEROPUERTO SAN LUIS - AUT | 2017-01-01 00:00:00 | 2.4    | 2 | VV
AEROPUERTO SAN LUIS - AUT | 2017-01-01 00:00:00 | 1012.5 | 2 | PA
AEROPUERTO SAN LUIS - AUT | 2017-01-01 00:00:00 | 17.8   | 2 | Tmax
```

The previous rows are illustrative examples of the expected structure. They should not be interpreted as mandatory values or as a complete representation of the dataset.

This format allows the workflow to filter by:

```text
station
zone
variable
time period
```

and to reshape data when required for modeling or derived-variable construction.

---

## 4. Variable dictionary

The official variable definitions are documented in:

```text
02_DATA_METADATA/02_variable_dictionary.md
```

The expected observed meteorological variable codes include:

| Code | Variable | General interpretation |
|---|---|---|
| `VV` | Wind speed | Primary wind variable used for physical characterization and WPD construction. |
| `DV` | Wind direction | Directional information associated with wind behavior. |
| `Tmin` | Minimum temperature | Thermodynamic support variable. |
| `Tmax` | Maximum temperature | Thermodynamic support variable. |
| `PA` | Atmospheric pressure | Required or useful for air-density estimation. |
| `HR` | Relative humidity | Atmospheric humidity condition. |
| `EV` | Evaporation | Hydrometeorological variable. |
| `NU` | Cloudiness | Atmospheric condition descriptor. |
| `PR` | Precipitation | Hydrometeorological variable. |
| `FA` | Atmospheric phenomenon | Categorical or coded atmospheric descriptor. |

---

## 5. Temperature-code normalization note

Some historical scripts, intermediate files, or development-stage outputs may contain alternative temperature labels such as:

```text
TM
Tm
Tmin
Tmax
```

For final reproducibility, temperature labels should be normalized according to the official variable dictionary.

Recommended convention:

```text
Tmin → minimum temperature
Tmax → maximum temperature
```

If `TM`, `Tm`, or any other temperature alias appears in a script or intermediate file, the mapping should be explicitly documented before analysis.

This prevents ambiguity between mean, minimum, and maximum temperature fields.

---

## 6. Primary target variable

The primary observed variable for the doctoral thesis is:

```text
VV
```

interpreted as wind speed.

Wind speed is the physical basis for the construction of Wind Power Density:

```text
WPD = 0.5 · ρ · v³
```

where:

```text
v = wind speed
ρ = air density
```

Therefore, the quality, consistency, and physical validity of `VV` are essential for the entire workflow.

---

## 7. Derived physical variables

The workflow may generate derived variables, including:

| Derived variable | Description |
|---|---|
| `rho` or `ρ` | Air density estimated from pressure and temperature when implemented. |
| `WPD` | Wind Power Density. |
| `Eh` | Horizon-integrated energy or accumulated energetic quantity. |
| `FNRR` | Regional non-regularity factor derived from WPD behavior. |
| `E_free` | Physically available energy before structural irregularity adjustment. |
| `E_usable` | Energy adjusted by the FNRR structural factor. |

The formal mathematical support is documented in:

```text
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
```

---

## 8. Date-time requirements

The column:

```text
FechaYHora
```

must be parsable as a date-time field.

Recommended format:

```text
YYYY-MM-DD HH:MM:SS
```

Illustrative examples:

```text
2017-01-01 00:00:00
2020-06-15 13:00:00
2022-12-31 23:00:00
```

The workflow assumes that temporal ordering can be reconstructed from this field.

Required checks:

- no invalid date strings;
- no unparsed dates;
- consistent time-zone interpretation when applicable;
- correct chronological order after parsing;
- and no duplicated observations unless explicitly justified.

---

## 9. Temporal resolution

The thesis workflow is based on meteorological time-series analysis.

The expected temporal resolution is:

```text
hourly or harmonized time-indexed observations
```

When temporal resolution varies, preprocessing must document:

- aggregation;
- interpolation;
- filtering;
- resampling;
- or harmonization procedures.

Any temporal modification must preserve physical interpretability.

---

## 10. Station requirements

The column:

```text
Estación
```

must identify the meteorological station associated with each observation.

Station names or codes should remain consistent across the dataset.

Recommended checks:

- no unintended duplicate station labels;
- no inconsistent spelling;
- no mixing of station name and code without documentation;
- and correspondence with the station-zone mapping.

The station-to-zone structure is documented in:

```text
02_DATA_METADATA/03_station_zone_mapping.md
```

---

## 11. Station inventory

The doctoral dataset is organized from a meteorological station network documented in the repository metadata.

The station inventory and spatial grouping are formally described in:

```text
02_DATA_METADATA/03_station_zone_mapping.md
```

The mapping defines the relationship between the observational station network and the four analytical zones used in the doctoral workflow.

---

## 12. Zone requirements

The column:

```text
Zona
```

must assign each station to one analytical zone.

Expected zones:

```text
1
2
3
4
```

or equivalent labels:

```text
Z1
Z2
Z3
Z4
```

The workflow assumes that every observation can be associated with one zone.

Recommended checks:

- all stations have a valid zone;
- no missing zone assignments;
- no observations outside the expected zone set;
- and station-zone mapping is stable across the analysis.

---

## 13. Value requirements

The column:

```text
Valor
```

must be numeric.

Recommended checks:

- parse as numeric;
- detect missing values;
- detect non-finite values;
- detect physically impossible values;
- detect extreme values;
- and preserve traceability of cleaning decisions.

Examples of values requiring review:

```text
NA
NaN
Inf
-Inf
non-numeric text
negative wind speed
invalid pressure values
unrealistic temperature values
```

These examples are diagnostic categories, not automatic deletion criteria.

---

## 14. Physical admissibility

The workflow requires physically coherent inputs.

Minimum physical expectations:

| Variable | Physical expectation |
|---|---|
| `VV` | Wind speed should be nonnegative. |
| `PA` | Atmospheric pressure should be positive. |
| `Tmin`, `Tmax` | Temperature should be physically plausible. |
| `HR` | Relative humidity should be within an interpretable range. |
| `PR` | Precipitation should be nonnegative. |
| `EV` | Evaporation should be nonnegative when applicable. |

Non-physical values should not be silently removed.

They should be documented through preprocessing notes or quality-control outputs.

---

## 15. Missing data

Missing values may occur due to:

- station downtime;
- sensor gaps;
- transmission failures;
- variable-specific availability;
- historical data limitations;
- or source-file inconsistencies.

Missing data must be handled according to the methodology documented in:

```text
02_DATA_METADATA/04_data_processing_notes.md
05_APPENDICES_SUPPORT/Anexo_B_Preprocesamiento_y_Trazabilidad.md
```

Recommended documentation:

```text
number of missing values
percentage of missing values
affected variable
affected station
affected zone
affected time period
treatment applied
```

---

## 16. Zero values

Zero values require variable-specific interpretation.

For example:

| Variable | Possible interpretation of zero |
|---|---|
| `VV` | Calm wind or recorded zero wind speed. |
| `PR` | No precipitation. |
| `EV` | No evaporation or recorded zero. |
| `NU` | No cloudiness or coded condition. |

Zero values should not be treated as missing automatically.

The interpretation depends on the variable and physical context.

---

## 17. Unit requirements

Units must be harmonized before physical calculations.

Recommended unit expectations:

| Variable | Expected or required unit logic |
|---|---|
| `VV` | m/s for WPD calculation. |
| `PA` | Pa or convertible pressure unit for air-density estimation. |
| `Tmin`, `Tmax` | °C or K, with conversion documented. |
| `HR` | Percentage or fraction, with convention documented. |
| `PR` | Precipitation unit documented. |
| `EV` | Evaporation unit documented. |

The WPD calculation requires:

```text
v in m/s
ρ in kg/m³
WPD in W/m²
```

If source units differ, conversion must be documented.

---

## 18. Air-density requirements

If air density is computed using pressure and temperature, the expected physical relation is:

```text
ρ = p / (R_d · T_K)
```

where:

```text
p = atmospheric pressure
R_d = dry-air gas constant
T_K = temperature in Kelvin
```

Temperature conversion:

```text
T_K = T_C + 273.15
```

The exact implemented formulation should follow the code and Appendix G.

---

## 19. WPD construction requirements

Wind Power Density is defined as:

```text
WPD = 0.5 · ρ · v³
```

Required checks before WPD construction:

1. `VV` is available.
2. Wind speed is nonnegative.
3. Air density is available or computable.
4. Units are harmonized.
5. Date-time alignment is correct.
6. Station and zone assignment is valid.

Expected WPD condition:

```text
WPD ≥ 0
```

when wind speed and air density are physically valid.

---

## 20. FNRR construction requirements

FNRR is computed from WPD behavior over a zone and temporal window.

Formal expression:

```text
FNRR_z(T) = [Q_75,z(T) − Q_25,z(T)] / [Q_75,z(T) + Q_25,z(T) + ε_z]
```

Requirements:

- WPD series must be available.
- Zone must be defined.
- Temporal window must be defined.
- Quantile method should be consistent.
- `ε_z` must be positive and expressed in the same unit as WPD.

Expected condition:

```text
0 ≤ FNRR_z(T) < 1
```

under the assumptions documented in Appendix G.

---

## 21. Energy-output requirements

Energy-related outputs depend on WPD and temporal integration.

Free energy:

```text
E_free = integrated WPD over a temporal window
```

Usable energy:

```text
E_usable = (1 − FNRR) · E_free
```

Required checks:

- `E_free ≥ 0`;
- `0 ≤ FNRR < 1`;
- `0 ≤ E_usable ≤ E_free`;
- temporal window is documented;
- and units are consistent.

---

## 22. Prediction-output requirements

Predictive outputs should contain enough information to identify:

- target variable;
- model;
- zone;
- horizon;
- observed value;
- predicted value;
- error metric;
- and uncertainty interval when applicable.

Recommended prediction-output fields:

```text
target
model
zone
horizon
date_time
observed
predicted
residual
lower_PI90
upper_PI90
```

When not all fields are present, the file-specific structure should be documented in the corresponding results folder.

---

## 23. PI90 interval requirements

PI90 outputs should include:

```text
lower bound
upper bound
observed value
predicted value
coverage indicator
```

Required check:

```text
lower bound ≤ upper bound
```

Coverage interpretation:

```text
Coverage_PI90 = mean(observed value inside interval)
```

Expected interpretation:

```text
Coverage_PI90 ≈ 0.90
```

when the interval is calibrated.

---

## 24. File-format requirements

Accepted or expected file formats may include:

```text
.csv
.xlsx
.rds
.txt
.md
.png
.pdf
.docx
```

Recommended use:

| Format | Use |
|---|---|
| `.csv` | Tabular reproducible outputs. |
| `.xlsx` | Human-readable tables when needed. |
| `.rds` | R-native objects when required. |
| `.txt` | Logs, session information, plain-text links. |
| `.md` | Documentation and appendices. |
| `.png` | Figures and screenshots. |
| `.pdf` | Formal evidence and static documents. |
| `.docx` | Formal institutional or appendix documents. |

---

## 25. Output-location expectations

Outputs should be stored in:

```text
04_RESULTS_COMPLETE/
```

Figures:

```text
04_RESULTS_COMPLETE/07_FIGURES/
```

Tables:

```text
04_RESULTS_COMPLETE/08_TABLES/
```

Appendix-level support:

```text
05_APPENDICES_SUPPORT/
```

Product-level evidence:

```text
06_PRODUCTS/
```

Reproducibility documentation:

```text
07_REPRODUCIBILITY/
```

---

## 26. Minimum validation before analysis

Before running analysis, confirm:

1. required columns exist;
2. date-time values parse correctly;
3. values are numeric where required;
4. variable codes are valid;
5. zones are valid;
6. stations match the station-zone mapping;
7. units are harmonized;
8. non-physical values are identified;
9. missing values are documented;
10. and the dataset corresponds to the intended study period.

---

## 27. Minimum validation after analysis

After running analysis, confirm:

1. WPD values are nonnegative;
2. FNRR values remain within expected bounds;
3. usable energy does not exceed free energy;
4. PI90 intervals have valid lower and upper bounds;
5. model outputs include zone and horizon identifiers;
6. figures are saved in the correct folders;
7. tables are saved in the correct folders;
8. and output files match the thesis interpretation.

---

## 28. Data availability note

The full raw dataset may not be included in the public repository due to size, format, local-processing, or responsible data-management constraints.

The data-availability statement is documented in:

```text
02_DATA_METADATA/05_data_availability.md
```

Reproducibility is supported through:

```text
metadata
data contract
code structure
results
figures
tables
appendices
software documentation
validation checks
```

---

## 29. Relationship with repository files

This data contract is connected to:

```text
02_DATA_METADATA/01_dataset_overview.md
02_DATA_METADATA/02_variable_dictionary.md
02_DATA_METADATA/03_station_zone_mapping.md
02_DATA_METADATA/04_data_processing_notes.md
02_DATA_METADATA/05_data_availability.md
03_CODE/
04_RESULTS_COMPLETE/
05_APPENDICES_SUPPORT/Anexo_B_Preprocesamiento_y_Trazabilidad.md
05_APPENDICES_SUPPORT/Anexo_G_Physical_Mathematical_Model_FNRR.md
07_REPRODUCIBILITY/validation_checks.md
```

---

## 30. Final statement

The data contract defines the minimum structure required for the computational workflow to remain interpretable and reproducible.

Its central principle is:

```text
The dataset must preserve the relationship between station, time,
variable, observed value, and analytical zone.
```

Without this structure, the physical characterization, predictive modeling, uncertainty analysis, FNRR computation, and energy projection lose traceability.

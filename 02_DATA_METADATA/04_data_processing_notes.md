# Data processing notes

## 1. Raw structure and parser

The frozen source is a long-format file with the fields:

```text
Estación, FechaYHora, Valor, Zona, Variable
```

The final parser decision is `dmy`. Column names are normalized internally, but the source names are retained in the metadata.

## 2. Temporal scope

- Nominal doctoral period: 2017–2022.
- Source-audit upper timestamp: 2022-07-01 12:00 in the raw audit record.
- Final analytical station-hour upper timestamp: 2022-07-01 00:00, local Colombia time.

The repository must report 2022 as a partial year and must not imply complete calendar-year coverage.

## 3. Wind-speed quality control

The canonical wind-speed layer contains 2,218,605 records. The final audit applies:

1. valid date-time;
2. numeric, finite value;
3. `VV >= 0`;
4. `VV <= 75 m/s`.

All 2,218,605 records in the frozen VV layer satisfy these conditions. Zeros are retained and quantified because they may represent physical calm.

## 4. Missing-data policy

For Chapter 2 descriptive and distributional characterization:

- missing wind-speed values are not imputed;
- zeros are not treated as missing;
- Weibull/Rayleigh fitting uses strictly positive wind-speed values, while zeros are reported separately;
- the station-hour consolidation preserves observed support.

The air-density fallback hierarchy is not an imputation of wind speed. It is a documented physical-construction rule used to retain VV coverage when pressure and temperature are incomplete.

## 5. Station-hour consolidation

The 2,218,605 valid source-level VV records include a nominal 10-minute median resolution at the station level. Consolidation to station-hour produces 365,512 analytical rows used to construct the main VV/WPD layer.

Analytical rows by zone:

| Zone | Rows |
|---|---:|
| 1 | 104,055 |
| 2 | 98,480 |
| 3 | 123,109 |
| 4 | 39,868 |

## 6. Air-density hierarchy

When pressure and temperature are available and valid, dry-air density is estimated from the ideal-gas relation. To preserve traceability and coverage, the final construction uses this hierarchy:

1. `station_hour`;
2. `zone_hour`;
3. `zone_month`;
4. `rho_ref = 1.10 kg/m³`.

Global source shares:

| Source | Rows | Share |
|---|---:|---:|
| station-hour | 48,055 | 13.1473% |
| zone-hour | 7,295 | 1.9958% |
| zone-month | 61,482 | 16.8208% |
| reference density | 248,680 | 68.0361% |

Zones 2 and 3 use reference density for all analytical rows in the frozen Chapter 2 construction. Zones 1 and 4 contain partial variable-density support.

## 7. WPD construction

For each analytical station-hour record:

```text
WPD = 0.5 × rho × VV^3
```

The field `rho_source` must accompany WPD in any reproducible analytical dataset. Removing it would break the physical provenance of the calculation.

## 8. Frozen-results rule

The repository may execute validation and robustness scripts, but it must not overwrite approved canonical tables or figures with newly recalculated outputs. Any new run must be stored as a complementary validation with a distinct path and manifest.

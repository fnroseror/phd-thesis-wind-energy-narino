# Data and metadata

This directory documents the observational and analytical data layers used in the doctoral thesis **“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas.”**

The corrected thesis is the scientific authority. This directory does not redefine the methodology or regenerate approved results. Its purpose is to make the data lineage, station network, variables, quality controls, and access conditions explicit and auditable.

## Canonical dataset scale

| Layer | Canonical count |
|---|---:|
| Raw meteorological records | 8,175,686 |
| Valid wind-speed records | 2,218,605 |
| Analytical station-hour VV/WPD records | 365,512 |
| Meteorological stations | 16 |
| Analytical zones | 4 |

The nominal observational period is **2017–2022**. The source snapshot has effective availability through **1 July 2022**. The final analytical station-hour dataset runs from **2017-01-01 00:00** to **2022-07-01 00:00**, local Colombia time, as declared in the corrected thesis.

## Directory contents

- [`01_dataset_overview.md`](01_dataset_overview.md): observational scope and data layers.
- [`02_variable_dictionary.md`](02_variable_dictionary.md): observed, derived, predictive, and energetic variables.
- [`03_station_zone_mapping.md`](03_station_zone_mapping.md): 16-station inventory, four-zone organization, and identifier policy.
- [`04_data_processing_notes.md`](04_data_processing_notes.md): quality control, station-hour consolidation, air-density hierarchy, and WPD construction.
- [`05_data_availability.md`](05_data_availability.md): public availability, source access, redistribution boundaries, and exact-snapshot requirements.
- [`06_data_lineage.md`](06_data_lineage.md): traceability from the raw source to approved scientific outputs.
- [`07_known_metadata_constraints.md`](07_known_metadata_constraints.md): documented limitations and identifier discrepancies that must not be hidden.
- [`tables/`](tables/): machine-readable metadata and audit summaries.
- [`data/`](data/): expected schema and instructions; the exact raw source snapshot is not embedded here.

## Identifier rule

The **IDEAM station code is the primary and stable identifier**. The aliases `S01`–`S16` are presentation labels. A discrepancy exists between the alias ordering in Table 2.1 and the alias ordering used in Figure 2.1/source map artifacts. The repository resolves this operationally by joining data only through the IDEAM station code and preserving both alias systems in [`tables/station_inventory.csv`](tables/station_inventory.csv).

## Interpretation limits

- WPD is the central physical variable.
- `I_TDQ` is an internal state variable of the hourly pipeline and is not FNRR.
- FNRR is a regional irregularity descriptor used in the separate quarterly/annual energy-scenario stage.
- `E_free` and `E_usable` are operational indicators per unit area; they are not actual electrical generation, thermodynamic free energy, or guaranteed energy.
- The 2023–2028 scenario is methodologically separate from the hourly forecasts at `h = 1, 12, 72`.

## Data publication policy

The repository prioritizes a frozen, traceable workflow over uncontrolled duplication of large source files. The exact raw IDEAM snapshot used in the thesis should be reproduced from the documented source or supplied under the applicable access conditions. Current external downloads may differ from the frozen thesis snapshot because public data services can be updated.

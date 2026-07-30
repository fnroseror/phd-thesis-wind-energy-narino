# Data lineage

## Canonical traceability chain

```text
IDEAM long-format source
    ↓
8,175,686 raw records
    ↓ date parsing and field normalization
10 audited meteorological variables / 16 stations / 4 zones
    ↓ wind-speed selection and physical quality control
2,218,605 valid VV records
    ↓ station-hour consolidation
365,512 station-hour rows
    ↓ hierarchical rho construction
station_hour → zone_hour → zone_month → rho_ref
    ↓ physical transformation
WPD = 0.5 × rho × VV³
    ↓
Chapter 2 characterization
    ↓
hourly forecasting pipeline at h = 1, 12, 72
    ↓
approved model outputs, diagnostics, and PI90
    ↓ methodologically separate quarterly stage from 2022-Q3
FNRR and annualized energy indicators for 2023–2028
```

## Layer authority

| Layer | Authority | Canonical count/status | Public location |
|---|---|---:|---|
| Raw source snapshot | Frozen IDEAM file used by thesis | 8,175,686 rows | Not embedded; access instructions in this directory. |
| Valid VV source layer | Final Chapter 2 audit | 2,218,605 rows | Metadata summaries only. |
| Station-hour VV/WPD layer | Corrected thesis / frozen Chapter 2 outputs | 365,512 rows | To be placed only if publication and size policy are satisfied. |
| Hourly forecast outputs | Approved Chapter 3 results | 12 zone-horizon combinations | `04_RESULTS_COMPLETE/` and validation manifests. |
| Quarterly/annual scenario | Approved Chapter 4 results | 2022-Q3–2028-Q4; annual 2023–2028 | `04_RESULTS_COMPLETE/`; separate from hourly outputs. |

## Non-substitution rule

A complementary strict-chronology analysis or a new execution environment may verify robustness, but it does not replace the frozen historical outputs approved in the thesis. The repository must label any new output as complementary and preserve the canonical result path unchanged.

## Required future checks

Before repository closure:

- compute and register SHA-256 for the exact raw source snapshot;
- verify the hash of any published processed dataset;
- verify that all code reads data through relative/configured paths;
- verify that every published table and figure points to a frozen source artifact;
- verify that no manifest references a missing data file.

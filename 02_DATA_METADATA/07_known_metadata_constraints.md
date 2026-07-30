# Known metadata constraints

This file records limitations that must remain visible during repository validation. They are not invitations to recalculate or alter the approved science.

## 1. Partial 2022 coverage

The nominal period is 2017–2022, but the source is effectively available only through 1 July 2022. Any annual summary for 2022 must be identified as partial or mixed according to the stage described in the thesis.

## 2. Unequal variable and station coverage

Meteorological variables are not measured with equal density. Wind-speed coverage also differs by station and zone. The repository must not imply a complete balanced panel.

## 3. Air-density fallback predominance

Reference density is used for 68.0361% of the analytical station-hour rows. Zones 2 and 3 use reference density for all rows in the frozen Chapter 2 construction. WPD therefore includes partial, not complete, thermodynamic variability.

## 4. Station alias discrepancy

The S01–S16 ordering in Table 2.1 differs from the ordering used in Figure 2.1/source map artifacts for multiple stations. IDEAM codes, station names, coordinates, and zone membership remain consistent.

Operational resolution:

- use `station_code` as the join key;
- preserve both aliases in the crosswalk;
- never infer station identity from an Sxx label alone.

## 5. Altitude values are reported, not independently corrected

The altitude column in the station inventory is preserved as reported in the corrected thesis/source metadata. This metadata package does not perform external correction of station elevation values.

## 6. Raw-file hash pending

The available audit records do not contain a SHA-256 hash for the exact 8,175,686-row source file. The repository cannot claim byte-level raw-data reproducibility until that hash is computed from the frozen source.

## 7. No synthetic data presented as evidence

Synthetic or illustrative rows are not scientific evidence. The previous demonstration CSV has been removed. Any future example must be labeled explicitly as either schema-only, synthetic, or a verified extract from the frozen source.

# Data availability and access

## Public metadata

This repository publishes the station inventory, zone mapping, variable schema, quality-control rules, coverage summaries, and data-lineage documentation required to understand the observational basis of the thesis.

IDEAM provides public data-access channels, including its open-data section, the Colombian open-data platform, and the DHIME hydrological and meteorological information system. Those services may be updated independently of this repository.

## Exact thesis snapshot

The exact source snapshot used in the thesis is a frozen long-format file containing **8,175,686 records**. It is not embedded in this metadata package.

A current download from an external IDEAM service is not automatically identical to the thesis snapshot. Exact reproduction requires:

1. the same station universe;
2. the same variable codes;
3. the same temporal boundary;
4. the same parser and normalization rules;
5. the same source snapshot or a verified equivalent;
6. a recorded cryptographic hash.

The currently available correction artifacts document the source path, approximate size, row count, parser, station count, zone count, and temporal range, but do not provide a verified SHA-256 hash of the raw source file. This hash remains a reproducibility-closure requirement.

## Repository storage decision

The public Git repository should not be used as an uncontrolled mirror of all raw and intermediate files. The original normalized dataset and several processed artifacts are too large or too operationally specific for ordinary source-code versioning.

The repository should include only files that are:

- scientifically necessary;
- legally and institutionally appropriate to redistribute;
- frozen and documented;
- below the applicable platform limit or managed through an explicit large-file strategy;
- referenced by the validation manifest.

## Current publication status

This directory includes no raw observations and no fabricated demonstration data. The previous `Datos_demo.csv` file is intentionally removed because it used synthetic station labels and repeated values that could be mistaken for a scientific subset.

The [`data/`](data/) directory contains the expected source schema and instructions only. A real sample or processed analytical dataset may be added later only when its provenance, redistribution basis, hash, and relationship to the canonical workflow are explicit.

## External source references

- IDEAM open-data section: `https://www.ideam.gov.co/transparencia/datos-abiertos/seccion-de-datos-abiertos`
- Colombia open-data portal: `https://www.datos.gov.co/`
- IDEAM DHIME system: `https://www.ideam.gov.co/dhime`

These links identify access channels; they do not guarantee byte-for-byte equivalence with the thesis snapshot.

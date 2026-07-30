# Repository status

## Release designation

```text
v1.0.0-rc1
```

This designation indicates that the repository architecture and documentary packages are prepared, but final public closure still depends on release gates.

## Frozen components

- Scientific content of the corrected thesis.
- Canonical results.
- R code structure.
- 31 figures and 25 scientific tables.
- 16-station / four-zone metadata.
- 19-product registry.
- 129/129 original product-evidence files.
- SHA-256 manifests for folders and delivered packages.

## Pending gates

| Gate | Status |
|---|---|
| Root files copied to the local Git repository | Pending user integration |
| Exact identity of the corrected thesis PDF confirmed | Pending |
| Institutional similarity review completed | Pending |
| Power BI public link checked manually | Pending |
| GitHub clean clone validated | Pending |
| Final release tag `v1.0.0` created | Pending |

## Promotion to v1.0.0

Promote the repository from `v1.0.0-rc1` to `v1.0.0` only after:

1. all seven folders and root files are committed;
2. the thesis PDF decision is resolved;
3. the repository is cloned into a new directory;
4. `source("00_validate_repository.R")` ends with `VALIDATION PASSED`;
5. the validated commit hash and date are archived.

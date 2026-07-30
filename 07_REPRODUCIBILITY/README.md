# 07_REPRODUCIBILITY

This folder controls computational environment evidence, SHA-256 manifests, release gates, and final repository validation.

## What is frozen

`repository_snapshot_manifest_01_06.csv` records every file in the delivered versions of folders `01_THESIS` through `06_PRODUCTS`.

At package construction:

- folders indexed: 6;
- files indexed: 408;
- product source evidence preserved: 129/129;
- scientific evidence indexed: 31 figures and 25 tables;
- executable validation language: R.

## Main validation commands

Validate this folder:

```r
source("07_REPRODUCIBILITY/02_validation/validate_reproducibility.R")
```

Check the R environment:

```r
source("07_REPRODUCIBILITY/02_validation/check_environment.R")
```

Run the final repository validator after the root package is installed:

```r
source("07_REPRODUCIBILITY/02_validation/validate_repository.R")
```

The exact final success line is:

```text
VALIDATION PASSED
```

## Current gates

The root package `00_ROOT_final.zip` has been prepared. The global validator requires its complete set of root files and verifies `_root_manifest_sha256.csv`.

The thesis PDF may remain absent while institutional similarity review is active. When included, its SHA-256 must match the registered corrected candidate.

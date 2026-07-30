# 00_REPOSITORY_INDEX — Product evidence control

This index was added without deleting, renaming, anonymizing, or modifying the original contents of `06_PRODUCTS`.

## Preservation rule

Every file from the source version is retained byte-for-byte, including:

- manuscripts and editorial packages;
- editable documents;
- scientific figures and tables;
- R scripts and session files;
- conference certificates;
- directed-project evidence;
- institutional-project evidence;
- dashboard records;
- patent-concept documents;
- audit files and logs.

The exact preservation check is recorded in:

```text
SOURCE_PRESERVATION_MANIFEST.csv
```

## Documentary index

`PRODUCTS_REGISTRY.csv` summarizes the 19 products declared in the final thesis. It does not replace the underlying evidence.

## Temporary-publication notice

The user has expressly directed that no evidence be anonymized or removed because the repository will be shared temporarily. Therefore, this package may contain:

- national identification numbers;
- signatures;
- student names;
- editorial correspondence;
- unpublished manuscripts;
- institutional information;
- local paths or R session traces.

These materials are intentionally preserved. Access control and later withdrawal are repository-administration decisions, not file-processing decisions.

## Validation

Run from RStudio:

```r
source("06_PRODUCTS/validate_products.R")
```

Expected result:

```text
PRODUCTS VALIDATION PASSED
SOURCE FILES PRESERVED: 129/129
```

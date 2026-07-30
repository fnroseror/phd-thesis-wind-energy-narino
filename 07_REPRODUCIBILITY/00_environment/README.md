# Computational environment

The doctoral workflow was developed in R/RStudio.

## Reference environment

The available execution evidence records:

- R 4.4.2;
- Windows 11 x64;
- time zone `America/Bogota`;
- Spanish (Colombia) locale for the recorded runs.

The original `sessionInfo()` outputs are preserved in:

```text
session_info_original/
```

## Version interpretation

The thesis was consolidated through several chapter-specific runs. Some packages therefore appear with more than one observed version, especially `data.table`. This folder preserves those stage-specific records rather than fabricating a single universal environment.

`package_dependencies_from_R_scripts.csv` records packages referenced by executable R files. When a package version is absent from the available `sessionInfo()` evidence, it is explicitly marked as not recorded.

No synthetic `renv.lock` has been created. A lockfile built from incomplete metadata would suggest a degree of restoration certainty that is not supported by the archived evidence.

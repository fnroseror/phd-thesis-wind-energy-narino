# Clean-clone validation protocol

The final repository is not closed merely because the local working copy validates. Closure requires an independent clean download or clone.

## Procedure

1. Commit and push the intended release.
2. Close RStudio and any file browser using the repository.
3. Clone the GitHub repository into a new directory with no inherited local files.
4. Open the cloned directory as an RStudio project or set it as the working directory.
5. Confirm the authorized IDEAM source remains outside Git.
6. Run:

```r
source("07_REPRODUCIBILITY/02_validation/check_environment.R")
source("07_REPRODUCIBILITY/02_validation/validate_repository.R")
```

7. Require the exact final line:

```text
VALIDATION PASSED
```

8. Compare the commit identifier and record the date, R version, and validation output.
9. Do not repair the clone manually. Any failure must be corrected in the source repository, committed, pushed, and tested through a new clean clone.

## Scientific execution

The global validator checks repository identity and documentary coherence. A complete scientific rerun additionally requires the authorized observational source, recorded package dependencies, and sufficient computational resources.

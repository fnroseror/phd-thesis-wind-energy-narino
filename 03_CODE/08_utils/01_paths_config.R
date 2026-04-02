get_repo_root <- function() {
  wd <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  wd
}

build_repo_paths <- function() {
  root <- get_repo_root()

  list(
    root = root,
    data = file.path(root, "data"),
    thesis = file.path(root, "01_THESIS"),
    metadata = file.path(root, "02_DATA_METADATA"),
    code = file.path(root, "03_CODE"),
    results = file.path(root, "04_RESULTS"),
    figures = file.path(root, "05_FIGURES"),
    tables = file.path(root, "06_TABLES"),
    appendices = file.path(root, "07_APPENDICES_SUPPORT"),
    products = file.path(root, "08_PRODUCTS"),
    reproducibility = file.path(root, "09_REPRODUCIBILITY")
  )
}

ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)
}

# 01_paths_config.R
# Portable repository path configuration

find_repo_root <- function(start = getwd()) {
  current <- normalizePath(start, winslash = "/", mustWork = TRUE)

  repeat {
    has_code <- dir.exists(file.path(current, "03_CODE"))
    has_meta <- dir.exists(file.path(current, "02_DATA_METADATA"))
    has_repro <- dir.exists(file.path(current, "09_REPRODUCIBILITY"))

    if (has_code && has_meta && has_repro) {
      return(current)
    }

    parent <- dirname(current)
    if (identical(parent, current)) {
      stop("Repository root could not be identified from the current working directory.", call. = FALSE)
    }
    current <- parent
  }
}

build_repo_paths <- function(start = getwd()) {
  root <- find_repo_root(start)

  list(
    root = root,
    thesis = file.path(root, "01_THESIS"),
    metadata = file.path(root, "02_DATA_METADATA"),
    code = file.path(root, "03_CODE"),
    results = file.path(root, "04_RESULTS"),
    figures = file.path(root, "05_FIGURES"),
    tables = file.path(root, "06_TABLES"),
    appendices = file.path(root, "07_APPENDICES_SUPPORT"),
    products = file.path(root, "08_PRODUCTS"),
    reproducibility = file.path(root, "09_REPRODUCIBILITY"),
    data = file.path(root, "data")
  )
}

ensure_dir <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  invisible(path)
}

ensure_repo_dirs <- function(paths) {
  dir_fields <- c(
    "results", "figures", "tables", "appendices",
    "products", "reproducibility", "data"
  )

  invisible(lapply(paths[dir_fields], ensure_dir))
}

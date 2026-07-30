# 04_export_helpers.R
# Standardized export helpers

safe_write_csv <- function(df, path, row.names = FALSE) {
  ensure_dir(dirname(path))
  utils::write.csv(df, path, row.names = row.names)
  invisible(path)
}

safe_save_rds <- function(object, path) {
  ensure_dir(dirname(path))
  saveRDS(object, path)
  invisible(path)
}

timestamp_tag <- function() {
  format(Sys.time(), "%Y%m%d_%H%M%S")
}

build_output_name <- function(prefix, stem, ext) {
  paste0(prefix, "_", stem, ".", ext)
}

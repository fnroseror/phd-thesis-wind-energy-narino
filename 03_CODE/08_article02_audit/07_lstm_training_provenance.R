
suppressPackageStartupMessages(library(data.table))

ROOT <- "C:/Users/UMARIANA/Documents/GitHub/phd-thesis-wind-energy-narino"
LOCAL <- file.path(ROOT, "local_work")
OUT <- file.path(LOCAL, "12_manuscript/audit")
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

stopifnot(dir.exists(LOCAL))

cat("\n====================================================\n")
cat("STEP 07 — LSTM TRAINING PROVENANCE\n")
cat("====================================================\n")

# 1. Locate relevant artifacts without loading model weights
all_files <- list.files(
  LOCAL, recursive = TRUE, full.names = TRUE,
  include.dirs = FALSE
)

info <- file.info(all_files)
all_files <- all_files[!is.na(info$isdir) & !info$isdir]
info <- file.info(all_files)

root_norm <- normalizePath(ROOT, winslash = "/")
paths <- normalizePath(
  all_files, winslash = "/", mustWork = FALSE
)

inv <- data.table(
  full_path = all_files,
  path = substring(paths, nchar(root_norm) + 2L),
  ext = tolower(tools::file_ext(all_files)),
  size_mb = round(info$size / 1024^2, 4)
)

relevant_pattern <- paste(
  "lstm", "deep.learning", "sequence",
  "keras", "tensorflow",
  sep = "|"
)

L <- inv[
  grepl(relevant_pattern, path, ignore.case = TRUE)
]

cat("\nLSTM-related files:", nrow(L), "\n")

cat("\nARTIFACT SAMPLE\n")
if (nrow(L)) {
  print(
    head(L[, .(path, ext, size_mb)], 60L),
    nrows = 60L
  )
}

# 2. Find source code or logs potentially documenting sequences
text_ext <- c(
  "r", "py", "rmd", "qmd", "ipynb",
  "txt", "log", "md", "json", "yaml", "yml"
)

sources <- L[
  ext %in% text_ext &
  size_mb <= 2 &
  !grepl("/08_article02_audit/", path)
]

history <- inv[
  grepl("\\.Rhistory$", path, ignore.case = TRUE) &
  size_mb <= 2
]

sources <- unique(
  rbindlist(list(sources, history), fill = TRUE),
  by = "path"
)

cat("\nPOTENTIAL SOURCE FILES:", nrow(sources), "\n")

pattern <- paste(
  c(
    "make_windows", "sequence_length", "lookback",
    "input_shape", "pad_sequences", "masking",
    "layer_lstm", "keras", "tensorflow",
    "time_grid", "imput", "origin_time",
    "target_time", "shift\\(", "seq_len"
  ),
  collapse = "|"
)

hits <- list()

for (i in seq_len(nrow(sources))) {
  f <- sources$full_path[i]

  lines <- tryCatch(
    readLines(f, warn = FALSE, encoding = "UTF-8"),
    error = function(e) character()
  )

  ix <- grep(pattern, lines, ignore.case = TRUE)

  if (length(ix)) {
    hits[[length(hits) + 1L]] <- data.table(
      file = sources$path[i],
      line = ix,
      code = substr(lines[ix], 1, 300)
    )
  }
}

H <- if (length(hits)) {
  rbindlist(hits, fill = TRUE)
} else {
  data.table(
    file = character(),
    line = integer(),
    code = character()
  )
}

cat("\nSOURCE MATCHES:", nrow(H), "\n")
if (nrow(H)) print(head(H, 50L), nrows = 50L)

# 3. Inspect lightweight training metadata
metadata <- L[
  ext %in% c("csv", "rds") &
  size_mb <= 2 &
  grepl(
    "config|metadata|summary|selection|manifest|tuning|checkpoint",
    path,
    ignore.case = TRUE
  )
]

setorder(metadata, path)
metadata <- head(metadata, 40L)

details <- list()

for (i in seq_len(nrow(metadata))) {
  f <- metadata$full_path[i]

  obj <- tryCatch(
    if (metadata$ext[i] == "csv") {
      fread(f, nrows = 5)
    } else {
      readRDS(f)
    },
    error = function(e) NULL
  )

  if (is.null(obj)) next

  details[[length(details) + 1L]] <- data.table(
    file = metadata$path[i],
    object_class = paste(class(obj), collapse = "/"),
    fields = paste(names(obj), collapse = " | ")
  )
}

DETAILS <- if (length(details)) {
  rbindlist(details, fill = TRUE)
} else {
  data.table(
    file = character(),
    object_class = character(),
    fields = character()
  )
}

cat("\nTRAINING METADATA\n")
if (nrow(DETAILS)) {
  print(DETAILS, nrows = 40L)
} else {
  cat("No readable lightweight metadata identified.\n")
}

# 4. Save audit evidence locally
fwrite(
  L[, .(path, ext, size_mb)],
  file.path(OUT, "lstm_artifact_inventory_v1_0.csv")
)

fwrite(
  H,
  file.path(OUT, "lstm_training_source_hits_v1_0.csv")
)

fwrite(
  DETAILS,
  file.path(OUT, "lstm_training_metadata_inventory_v1_0.csv")
)

cat("\n====================================================\n")
cat("STEP 07 COMPLETE\n")
cat("No models or predictions were modified.\n")
cat("====================================================\n")

# 5. Commit only this script if index is clean
setwd(ROOT)
REL <- "03_CODE/08_article02_audit/07_lstm_training_provenance.R"

staged <- system2(
  "git", c("diff", "--cached", "--name-only"),
  stdout = TRUE
)

if (!length(staged)) {
  add <- system2(
    "git", c("add", "--", REL),
    stdout = TRUE, stderr = TRUE
  )

  add_status <- attr(add, "status")
  if (is.null(add_status)) add_status <- 0L
  if (add_status != 0L) stop("Git add failed.")

  commit <- system2(
    "git",
    c(
      "commit", "-m",
      shQuote("Audit Article 2 LSTM training provenance")
    ),
    stdout = TRUE,
    stderr = TRUE
  )

  cat(paste(commit, collapse = "\n"), "\n")
} else {
  cat("Other staged changes exist; automatic commit skipped.\n")
}


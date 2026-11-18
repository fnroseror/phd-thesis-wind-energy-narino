# ============================================================
# ARTICLE 2 — REPOSITORY SYNCHRONIZATION
# STEP 01: protect local work, checkpoint, rebase and push
# ============================================================

ROOT <- "C:/Users/UMARIANA/Documents/GitHub/phd-thesis-wind-energy-narino"
setwd(ROOT)

# ------------------------------------------------------------
# Helper
# ------------------------------------------------------------

run_git <- function(args, stop_on_error = TRUE) {

  out <- system2(
    "git",
    args = args,
    stdout = TRUE,
    stderr = TRUE
  )

  status <- attr(out, "status")

  if (is.null(status)) status <- 0L

  if (length(out)) {
    cat(paste(out, collapse = "\n"), "\n")
  }

  if (stop_on_error && status != 0L) {
    stop(
      "Git command failed: git ",
      paste(args, collapse = " "),
      call. = FALSE
    )
  }

  invisible(
    list(
      output = out,
      status = status
    )
  )
}

cat("\n============================================================\n")
cat("ARTICLE 2 — SAFE LOCAL/REMOTE SYNCHRONIZATION\n")
cat("============================================================\n\n")

# ============================================================
# 1. Protect local_work from Git
# ============================================================

cat("STEP 1 — PROTECT local_work\n")
cat("------------------------------------------------------------\n")

GITIGNORE <- file.path(ROOT, ".gitignore")

if (file.exists(GITIGNORE)) {
  gi <- readLines(GITIGNORE, warn = FALSE)
} else {
  gi <- character(0)
}

ignore_rule <- "/local_work/"

if (!ignore_rule %in% trimws(gi)) {

  cat("\n# Local Article-2 working artifacts — never publish raw/local objects\n",
      file = GITIGNORE,
      append = TRUE)

  cat("/local_work/\n",
      file = GITIGNORE,
      append = TRUE)

  cat("Added to .gitignore: /local_work/\n")

} else {

  cat("local_work already protected by .gitignore.\n")
}

cat("\nGit ignore verification:\n")
run_git(
  c("check-ignore", "-v", "local_work/"),
  stop_on_error = FALSE
)

# ============================================================
# 2. Stage ONLY intentional repository content
# ============================================================

cat("\n============================================================\n")
cat("STEP 2 — STAGE INTENTIONAL FILES ONLY\n")
cat("============================================================\n\n")

# Never use git add . here.

run_git(c("add", ".gitignore"))

run_git(
  c(
    "add",
    "03_CODE/08_article02_audit"
  )
)

run_git(
  c(
    "add",
    "06_PRODUCTS/01_articles/article_01_energy_reports/10_V2"
  )
)

cat("\nSTAGED FILES:\n")
cat("------------------------------------------------------------\n")
run_git(c("diff", "--cached", "--name-status"))

cat("\nSTAGED SUMMARY:\n")
cat("------------------------------------------------------------\n")
run_git(c("diff", "--cached", "--stat"))

# ============================================================
# 3. Verify local_work is NOT staged
# ============================================================

STAGED <- system2(
  "git",
  args = c("diff", "--cached", "--name-only"),
  stdout = TRUE,
  stderr = TRUE
)

if (any(grepl("^local_work/", STAGED))) {
  stop(
    "SAFETY STOP: local_work was staged. Nothing will be committed.",
    call. = FALSE
  )
}

cat("\nSAFETY CHECK: local_work is not staged — PASS\n")

# ============================================================
# 4. Create local checkpoint commit
# ============================================================

cat("\n============================================================\n")
cat("STEP 3 — LOCAL CHECKPOINT COMMIT\n")
cat("============================================================\n\n")

if (length(STAGED) == 0L) {

  cat("No staged changes. Commit not required.\n")

} else {

  run_git(
    c(
      "commit",
      "-m",
      shQuote(
        "Sync Energy Reports R1/V2 and initialize Article 2 audit trail"
      )
    )
  )
}

# ============================================================
# 5. Fetch and rebase on origin/main
# ============================================================

cat("\n============================================================\n")
cat("STEP 4 — REBASE ON origin/main\n")
cat("============================================================\n\n")

run_git(c("fetch", "origin"))

cat("Before rebase — ahead/behind:\n")
run_git(
  c(
    "rev-list",
    "--left-right",
    "--count",
    "HEAD...origin/main"
  )
)

REB <- run_git(
  c(
    "pull",
    "--rebase",
    "origin",
    "main"
  ),
  stop_on_error = FALSE
)

if (REB$status != 0L) {

  cat("\n============================================================\n")
  cat("REBASE STOPPED — POSSIBLE CONFLICT\n")
  cat("============================================================\n\n")

  run_git(c("status", "--short"), stop_on_error = FALSE)

  stop(
    paste0(
      "The rebase needs manual review. ",
      "No push was attempted. Copy this output into ChatGPT."
    ),
    call. = FALSE
  )
}

# ============================================================
# 6. Validate repository state before push
# ============================================================

cat("\n============================================================\n")
cat("STEP 5 — POST-REBASE VALIDATION\n")
cat("============================================================\n\n")

cat("Ahead/behind after rebase:\n")
run_git(
  c(
    "rev-list",
    "--left-right",
    "--count",
    "HEAD...origin/main"
  )
)

cat("\nStatus before push:\n")
run_git(c("status", "--short"))

cat("\nLatest commits:\n")
run_git(
  c(
    "log",
    "-5",
    "--oneline",
    "--decorate"
  )
)

# ============================================================
# 7. Push
# ============================================================

cat("\n============================================================\n")
cat("STEP 6 — PUSH TO origin/main\n")
cat("============================================================\n\n")

run_git(
  c(
    "push",
    "origin",
    "main"
  )
)

# ============================================================
# 8. Final verification
# ============================================================

run_git(c("fetch", "origin"))

cat("\n============================================================\n")
cat("FINAL REPOSITORY STATE\n")
cat("============================================================\n\n")

cat("Ahead/behind:\n")
run_git(
  c(
    "rev-list",
    "--left-right",
    "--count",
    "HEAD...origin/main"
  )
)

cat("\nWorking tree:\n")
run_git(c("status", "--short"))

cat("\nHEAD:\n")
run_git(
  c(
    "log",
    "-1",
    "--oneline",
    "--decorate"
  )
)

cat("\n============================================================\n")
cat("REPOSITORY SYNCHRONIZATION COMPLETE\n")
cat("============================================================\n")

# ============================================================
# ARTICLE 2 — REPOSITORY SYNCHRONIZATION
# STEP 00: local Git snapshot before Article-2 continuation
# ============================================================

ROOT <- "C:/Users/UMARIANA/Documents/GitHub/phd-thesis-wind-energy-narino"

setwd(ROOT)

cat("\n============================================================\n")
cat("ARTICLE 2 — LOCAL GIT SNAPSHOT\n")
cat("============================================================\n\n")

run_git <- function(args) {
  out <- system2("git", args = args, stdout = TRUE, stderr = TRUE)
  cat(paste(out, collapse = "\n"), "\n")
  invisible(out)
}

cat("REPOSITORY ROOT\n")
cat(normalizePath(ROOT, winslash = "/"), "\n\n")

cat("------------------------------------------------------------\n")
cat("CURRENT BRANCH\n")
cat("------------------------------------------------------------\n")
run_git(c("branch", "--show-current"))

cat("\n------------------------------------------------------------\n")
cat("REMOTE CONFIGURATION\n")
cat("------------------------------------------------------------\n")
run_git(c("remote", "-v"))

cat("\n------------------------------------------------------------\n")
cat("LOCAL STATUS\n")
cat("------------------------------------------------------------\n")
run_git(c("status", "--short"))

cat("\n------------------------------------------------------------\n")
cat("LOCAL VS ORIGIN/MAIN\n")
cat("------------------------------------------------------------\n")

# Fetch remote metadata only. Does not merge or modify files.
run_git(c("fetch", "origin"))

cat("\nAhead / behind counts (local main vs origin/main):\n")
run_git(c("rev-list", "--left-right", "--count", "HEAD...origin/main"))

cat("\n------------------------------------------------------------\n")
cat("LATEST LOCAL COMMITS\n")
cat("------------------------------------------------------------\n")
run_git(c("log", "-5", "--oneline", "--decorate"))

cat("\n------------------------------------------------------------\n")
cat("LATEST REMOTE COMMITS\n")
cat("------------------------------------------------------------\n")
run_git(c("log", "origin/main", "-5", "--oneline", "--decorate"))

cat("\n------------------------------------------------------------\n")
cat("ARTICLE-2 TRACKED CONTENT\n")
cat("------------------------------------------------------------\n")
run_git(c("ls-files", "06_PRODUCTS/01_articles"))

cat("\n------------------------------------------------------------\n")
cat("LOCAL_WORK GIT STATUS\n")
cat("------------------------------------------------------------\n")

ignored <- system2(
  "git",
  args = c("check-ignore", "-v", "local_work"),
  stdout = TRUE,
  stderr = TRUE
)

if (length(ignored) == 0) {
  cat("local_work is NOT reported as ignored.\n")
} else {
  cat(paste(ignored, collapse = "\n"), "\n")
}

cat("\n============================================================\n")
cat("SNAPSHOT COMPLETE — NO MERGE, COMMIT OR PUSH PERFORMED\n")
cat("============================================================\n")

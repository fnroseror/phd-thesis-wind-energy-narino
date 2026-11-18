# ============================================================
# ARTICLE 2 — REPOSITORY SYNCHRONIZATION
# STEP 01B: configure repository Git identity and resume sync
# ============================================================

ROOT <- "C:/Users/UMARIANA/Documents/GitHub/phd-thesis-wind-energy-narino"
setwd(ROOT)

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
cat("ARTICLE 2 — GIT IDENTITY + SYNCHRONIZATION RESUME\n")
cat("============================================================\n\n")

# ============================================================
# 1. Configure identity ONLY for this repository
# ============================================================

cat("STEP 1 — REPOSITORY-LOCAL GIT IDENTITY\n")
cat("------------------------------------------------------------\n")

run_git(
  c(
    "config",
    "--local",
    "user.name",
    shQuote("Favio Nicolás Rosero Rodríguez")
  )
)

run_git(
  c(
    "config",
    "--local",
    "user.email",
    shQuote("fnroseror@users.noreply.github.com")
  )
)

cat("\nConfigured identity:\n")
run_git(c("config", "--local", "--get", "user.name"))
run_git(c("config", "--local", "--get", "user.email"))

# ============================================================
# 2. Add this recovery script
# ============================================================

cat("\n============================================================\n")
cat("STEP 2 — ADD RECOVERY SCRIPT\n")
cat("============================================================\n\n")

run_git(
  c(
    "add",
    "03_CODE/08_article02_audit/01b_git_identity_resume.R"
  )
)

# ============================================================
# 3. Confirm local_work protection
# ============================================================

cat("\n============================================================\n")
cat("STEP 3 — SAFETY CHECKS\n")
cat("============================================================\n\n")

TEST_LOCAL_FILE <-
  "local_work/12_manuscript/audit/article02_wpd_formula_identity_v1_0.csv"

IGN <- run_git(
  c(
    "check-ignore",
    "-v",
    TEST_LOCAL_FILE
  ),
  stop_on_error = FALSE
)

if (IGN$status != 0L) {
  stop(
    "SAFETY STOP: local_work ignore rule could not be verified.",
    call. = FALSE
  )
}

STAGED <- system2(
  "git",
  args = c("diff", "--cached", "--name-only"),
  stdout = TRUE,
  stderr = TRUE
)

if (any(grepl("^local_work/", STAGED))) {
  stop(
    "SAFETY STOP: local_work is staged.",
    call. = FALSE
  )
}

cat("local_work ignored — PASS\n")
cat("local_work not staged — PASS\n")

cat("\nCurrent staged files:\n")
cat("------------------------------------------------------------\n")
run_git(c("diff", "--cached", "--name-status"))

# ============================================================
# 4. Create checkpoint commit
# ============================================================

cat("\n============================================================\n")
cat("STEP 4 — CHECKPOINT COMMIT\n")
cat("============================================================\n\n")

STAGED <- system2(
  "git",
  args = c("diff", "--cached", "--name-only"),
  stdout = TRUE,
  stderr = TRUE
)

if (length(STAGED) == 0L) {

  cat("No staged files found. No commit required.\n")

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
# 5. Synchronize with origin/main
# ============================================================

cat("\n============================================================\n")
cat("STEP 5 — FETCH + REBASE\n")
cat("============================================================\n\n")

run_git(c("fetch", "origin"))

cat("Ahead / behind before rebase:\n")
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
  cat("REBASE STOPPED — MANUAL REVIEW REQUIRED\n")
  cat("============================================================\n\n")

  run_git(
    c("status", "--short"),
    stop_on_error = FALSE
  )

  stop(
    paste0(
      "Rebase conflict detected. ",
      "No push was performed. Copy the output into ChatGPT."
    ),
    call. = FALSE
  )
}

# ============================================================
# 6. Verify before push
# ============================================================

cat("\n============================================================\n")
cat("STEP 6 — POST-REBASE CHECK\n")
cat("============================================================\n\n")

cat("Ahead / behind:\n")
run_git(
  c(
    "rev-list",
    "--left-right",
    "--count",
    "HEAD...origin/main"
  )
)

cat("\nRepository status:\n")
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
cat("STEP 7 — PUSH origin/main\n")
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
cat("FINAL STATE\n")
cat("============================================================\n\n")

cat("Ahead / behind:\n")
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
cat("GIT SYNCHRONIZATION COMPLETE\n")
cat("============================================================\n")

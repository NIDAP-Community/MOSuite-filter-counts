#!/usr/bin/env Rscript

# Simple test to verify the test setup and data exists
cat("Testing basic test setup...\n")

# Get the current working directory during test execution
cwd <- getwd()
cat("Current directory:", cwd, "\n")

# Calculate repo root the same way the test does in tests/testthat/test-main.R
# When running from tests/testthat, dirname(getwd()) goes to tests/
repo_root_test_calculation <- normalizePath(file.path(dirname(cwd), ".."))
cat(
  "Calculated repo_root (test calculation):",
  repo_root_test_calculation,
  "\n"
)

# From script running in tests directory:
# When this script is in tests/ directory, repo_root should be dirname(getwd())
repo_root_script <- normalizePath(dirname(cwd))
cat("Calculated repo_root (script location):", repo_root_script, "\n")

# Check if test data exists using test calculation
test_data_file <- file.path(repo_root_script, "data", "moo-batch.rds")
cat("\nLooking for test data at:", test_data_file, "\n")
cat("Test data exists:", file.exists(test_data_file), "\n")

# Check code files
code_main <- file.path(repo_root_script, "..", "code", "main.R")
code_run <- file.path(repo_root_script, "..", "code", "run")
cat("code/main.R exists:", file.exists(code_main), "\n")
cat("code/run exists:", file.exists(code_run), "\n")

# Try to load the MOO object
if (file.exists(test_data_file)) {
  cat("\nTrying to load MOO object...\n")
  library(readr)
  moo <- readr::read_rds(test_data_file)
  cat("MOO object loaded successfully!\n")
  cat("MOO class:", class(moo), "\n")
  if (hasSlot(moo, "counts")) {
    cat("MOO columns in counts:", names(moo@counts), "\n")
  }
}

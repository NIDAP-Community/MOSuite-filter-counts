test_that("code/run executes successfully with default CLI arguments", {
  # Create temporary workspace
  workspace <- tempfile("mosuite_filter_counts_test_")
  dir.create(workspace)
  on.exit(unlink(workspace, recursive = TRUE), add = TRUE)

  # Set up directory structure
  code_dir <- file.path(workspace, "code")
  data_dir <- file.path(workspace, "data")
  results_dir <- file.path(code_dir, "..", "results")
  dir.create(code_dir)
  dir.create(data_dir)
  dir.create(results_dir)

  # Get test data from package tests directory
  repo_root <- normalizePath(file.path(dirname(getwd()), ".."))
  test_data_file <- file.path(repo_root, "tests", "data", "moo-clean.rds")

  expect_true(
    file.exists(test_data_file),
    info = paste("Test data file should exist at", test_data_file)
  )
  file.copy(test_data_file, file.path(data_dir, "moo.rds"))

  # Copy main.R and run script to workspace
  file.copy(
    file.path(repo_root, "code", "main.R"),
    file.path(code_dir, "main.R")
  )
  file.copy(
    file.path(repo_root, "code", "run"),
    file.path(code_dir, "run")
  )

  # Run the script from code directory
  old_wd <- getwd()
  setwd(code_dir)
  on.exit(setwd(old_wd), add = TRUE)

  # Execute run script with default CLI arguments
  exit_code <- system2(
    "bash",
    args = c(
      "run",
      "--count_type=clean",
      "--minimum_count_value_to_be_considered_nonzero=8",
      "--minimum_number_of_samples_with_nonzero_counts_in_total=7",
      "--minimum_number_of_samples_with_nonzero_counts_in_a_group=3",
      "--use_cpm_counts_to_filter=TRUE",
      "--use_group_based_filtering=FALSE",
      "--plot_corr_matrix_heatmap=FALSE"
    )
  )

  # Check for successful execution
  expect_equal(exit_code, 0, info = "run script should execute without error")
  expect_true(
    file.exists(file.path(results_dir, "moo", "moo-filt.rds")),
    info = "Output file moo-filt.rds should be created"
  )

  # Validate output is a valid MOO object
  moo <- readr::read_rds(file.path(results_dir, "moo", "moo-filt.rds"))
  expect_true(
    S7::S7_inherits(moo, MOSuite::multiOmicDataSet),
    info = "Output should be an S7 multiOmicDataSet object"
  )
})

test_that("code/run executes with custom CLI arguments", {
  # Create temporary workspace
  workspace <- tempfile("mosuite_filter_counts_custom_test_")
  dir.create(workspace)
  on.exit(unlink(workspace, recursive = TRUE), add = TRUE)

  # Set up directory structure
  code_dir <- file.path(workspace, "code")
  data_dir <- file.path(workspace, "data")
  results_dir <- file.path(code_dir, "..", "results")
  dir.create(code_dir)
  dir.create(data_dir)
  dir.create(results_dir)

  # Get test data from package tests directory
  repo_root <- normalizePath(file.path(dirname(getwd()), ".."))
  test_data_file <- file.path(repo_root, "tests", "data", "moo-clean.rds")

  # Copy test data to workspace
  file.copy(test_data_file, file.path(data_dir, "moo.rds"))

  # Copy main.R and run script to workspace
  file.copy(
    file.path(repo_root, "code", "main.R"),
    file.path(code_dir, "main.R")
  )
  file.copy(
    file.path(repo_root, "code", "run"),
    file.path(code_dir, "run")
  )

  # Run the script from code directory
  old_wd <- getwd()
  setwd(code_dir)
  on.exit(setwd(old_wd), add = TRUE)

  # Execute run script with custom CLI arguments
  exit_code <- system2(
    "bash",
    args = c(
      "run",
      "--count_type=clean",
      "--minimum_count_value_to_be_considered_nonzero=5",
      "--minimum_number_of_samples_with_nonzero_counts_in_total=3",
      "--use_cpm_counts_to_filter=FALSE",
      "--plot_corr_matrix_heatmap=FALSE"
    )
  )

  # Check for successful execution
  expect_equal(
    exit_code,
    0,
    info = "run script with custom args should execute without error"
  )
  expect_true(
    file.exists(file.path(results_dir, "moo", "moo-filt.rds")),
    info = "Output file moo-filt.rds should be created with custom args"
  )

  # Validate output is a valid MOO object
  moo <- readr::read_rds(file.path(results_dir, "moo", "moo-filt.rds"))
  expect_true(
    S7::S7_inherits(moo, MOSuite::multiOmicDataSet),
    info = "Output should be an S7 multiOmicDataSet object"
  )
})

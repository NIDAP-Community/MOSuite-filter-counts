test_that("every app panel parameter is accepted and used by main.R", {
  repo_root <- normalizePath(
    file.path(testthat::test_path(), "..", ".."),
    mustWork = TRUE
  )
  panel <- jsonlite::fromJSON(
    file.path(repo_root, ".codeocean", "app-panel.json")
  )
  main_text <- paste(
    readLines(file.path(repo_root, "code", "main.R"), warn = FALSE),
    collapse = "\n"
  )

  param_names <- panel$parameters$param_name
  expect_true(length(param_names) > 0)

  for (param_name in param_names) {
    expect_match(
      main_text,
      sprintf('"--%s"', param_name),
      fixed = TRUE,
      info = sprintf("main.R should define a --%s CLI argument", param_name)
    )
    expect_match(
      main_text,
      sprintf("args$%s", param_name),
      fixed = TRUE,
      info = sprintf("main.R should read args$%s", param_name)
    )
  }
})

test_that("code/run executes successfully with default CLI arguments", {
  setup <- setup_cli_workspace("mosuite_filter_counts_test_")
  withr::defer(unlink(setup$workspace, recursive = TRUE))

  file.copy(
    file.path(setup$repo_root, "code", "run"),
    file.path(setup$code_dir, "run"),
    overwrite = TRUE
  )

  withr::local_dir(setup$code_dir)

  default_cli_args <- c(
    "--plot_corr_matrix_heatmap=FALSE"
  )
  exit_code <- system2("bash", args = c("run", default_cli_args))
  expect_equal(exit_code, 0, info = "run script should execute without error")

  expect_outputs_created(setup$results_dir)
})

test_that("code/run executes with custom CLI arguments", {
  setup <- setup_cli_workspace("mosuite_filter_counts_custom_test_")
  withr::defer(unlink(setup$workspace, recursive = TRUE))

  file.copy(
    file.path(setup$repo_root, "code", "run"),
    file.path(setup$code_dir, "run"),
    overwrite = TRUE
  )

  withr::local_dir(setup$code_dir)

  custom_cli_args <- c(
    "--minimum_count_value_to_be_considered_nonzero=5",
    "--minimum_number_of_samples_with_nonzero_counts_in_total=3",
    "--use_cpm_counts_to_filter=FALSE",
    "--plot_corr_matrix_heatmap=FALSE"
  )
  exit_code <- system2("bash", args = c("run", custom_cli_args))
  expect_equal(
    exit_code,
    0,
    info = "run script with custom args should execute without error"
  )

  expect_outputs_created(setup$results_dir)
})

test_that("code/run executes with group-based filtering CLI arguments", {
  setup <- setup_cli_workspace("mosuite_filter_counts_group_test_")
  withr::defer(unlink(setup$workspace, recursive = TRUE))

  moo_path <- file.path(setup$workspace, "data", "moo.rds")
  moo <- readr::read_rds(moo_path)
  moo@sample_meta <- as.data.frame(moo@sample_meta)
  rownames(moo@sample_meta) <- as.character(moo@sample_meta[[1]])
  readr::write_rds(moo, moo_path)

  file.copy(
    file.path(setup$repo_root, "code", "run"),
    file.path(setup$code_dir, "run"),
    overwrite = TRUE
  )

  withr::local_dir(setup$code_dir)

  group_based_cli_args <- c(
    "--use_group_based_filtering=TRUE",
    "--plot_corr_matrix_heatmap=FALSE"
  )
  exit_code <- system2("bash", args = c("run", group_based_cli_args))
  expect_equal(
    exit_code,
    0,
    info = "run script with group-based filtering args should execute without error"
  )

  expect_outputs_created(setup$results_dir)
})

test_that("main.R creates output directories when run directly", {
  setup <- setup_cli_workspace("mosuite_filter_counts_direct_main_test_")
  withr::defer(unlink(setup$workspace, recursive = TRUE))

  unlink(file.path(setup$results_dir, "moo"), recursive = TRUE)

  result <- run_command_capture(
    "Rscript",
    args = c("main.R", "--plot_corr_matrix_heatmap=FALSE"),
    wd = setup$code_dir
  )

  expect_equal(
    result$status,
    0,
    info = "main.R should run successfully without pre-created results directories"
  )
  expect_outputs_created(setup$results_dir)
})

test_that("custom ID columns are standardized in DEG handoff outputs", {
  setup <- setup_cli_workspace("mosuite_filter_counts_custom_id_cols_test_")
  withr::defer(unlink(setup$workspace, recursive = TRUE))

  moo_path <- file.path(setup$workspace, "data", "moo.rds")
  moo <- readr::read_rds(moo_path)

  clean_counts <- as.data.frame(moo@counts[["clean"]])
  colnames(clean_counts)[1] <- "FeatureID"
  moo@counts[["clean"]] <- clean_counts

  sample_metadata <- as.data.frame(moo@sample_meta)
  colnames(sample_metadata)[1] <- "SampleID"
  moo@sample_meta <- sample_metadata

  readr::write_rds(moo, moo_path)

  file.copy(
    file.path(setup$repo_root, "code", "run"),
    file.path(setup$code_dir, "run"),
    overwrite = TRUE
  )

  result <- run_command_capture(
    "bash",
    args = c(
      "run",
      "--feature_id_colname=FeatureID",
      "--sample_id_colname=SampleID",
      "--plot_corr_matrix_heatmap=FALSE"
    ),
    wd = setup$code_dir
  )

  expect_equal(
    result$status,
    0,
    info = "run script should support non-default feature and sample ID columns"
  )
  expect_outputs_created(setup$results_dir)
})

test_that("main.R reports missing sample metadata IDs clearly", {
  setup <- setup_cli_workspace("mosuite_filter_counts_missing_sample_col_test_")
  withr::defer(unlink(setup$workspace, recursive = TRUE))

  moo_path <- file.path(setup$workspace, "data", "moo.rds")
  moo <- readr::read_rds(moo_path)

  sample_metadata <- as.data.frame(moo@sample_meta)
  colnames(sample_metadata)[1] <- "SampleID"
  moo@sample_meta <- sample_metadata

  readr::write_rds(moo, moo_path)

  result <- suppressWarnings(
    run_command_capture(
      "Rscript",
      args = c(
        "main.R",
        "--sample_id_colname=Sample",
        "--plot_corr_matrix_heatmap=FALSE"
      ),
      wd = setup$code_dir
    )
  )

  expect_true(
    result$status != 0,
    info = "main.R should fail when the configured sample ID column is absent"
  )
})

setup_cli_workspace <- function(prefix = "mosuite_filter_counts_test_") {
  workspace <- tempfile(prefix)
  dir.create(workspace)

  code_dir <- file.path(workspace, "code")
  data_dir <- file.path(workspace, "data")
  results_dir <- file.path(workspace, "results")
  dir.create(code_dir, recursive = TRUE)
  dir.create(data_dir, recursive = TRUE)
  dir.create(file.path(results_dir, "figures"), recursive = TRUE)
  dir.create(file.path(results_dir, "moo"), recursive = TRUE)

  repo_root <- normalizePath(
    file.path(testthat::test_path(), "..", ".."),
    mustWork = TRUE
  )

  test_data_file <- file.path(repo_root, "tests", "data", "moo-clean.rds")

  expect_true(
    file.exists(test_data_file),
    info = paste("Test data file should exist at", test_data_file)
  )

  file.copy(
    test_data_file,
    file.path(data_dir, "moo.rds"),
    overwrite = TRUE
  )

  file.copy(
    file.path(repo_root, "code", "main.R"),
    file.path(code_dir, "main.R"),
    overwrite = TRUE
  )

  # Patch the hardcoded container path so tests work outside the container.
  main_copy <- file.path(code_dir, "main.R")
  main_lines <- readLines(main_copy)
  main_lines <- gsub(
    'devtools::load_all("/code/MOSuite")',
    sprintf(
      'devtools::load_all("%s")',
      file.path(repo_root, "code", "MOSuite")
    ),
    main_lines,
    fixed = TRUE
  )
  writeLines(main_lines, main_copy)

  list(
    workspace = workspace,
    code_dir = code_dir,
    results_dir = results_dir,
    repo_root = repo_root
  )
}

expect_outputs_created <- function(results_dir) {
  moo_path <- file.path(results_dir, "moo", "moo-filt.rds")
  counts_path <- file.path(results_dir, "Filtered_Counts.csv")
  metadata_path <- file.path(results_dir, "Sample_Metadata.csv")

  expect_true(
    file.exists(moo_path),
    info = "Filtered MOO output should be created"
  )
  expect_true(
    file.info(moo_path)$size > 0,
    info = "Filtered MOO output should be non-empty"
  )

  moo <- readr::read_rds(moo_path)
  expect_true(
    inherits(moo, "MOSuite::multiOmicDataSet"),
    info = "Output should be an S7 multiOmicDataSet object"
  )

  expect_true(
    file.exists(counts_path),
    info = "DEG-compatible filtered counts should be created"
  )
  expect_true(
    file.exists(metadata_path),
    info = "DEG-compatible sample metadata should be created"
  )

  counts <- readr::read_csv(counts_path, show_col_types = FALSE)
  metadata <- readr::read_csv(metadata_path, show_col_types = FALSE)
  filtered_counts <- as.data.frame(moo@counts[["filt"]])

  expect_identical(
    colnames(counts)[1],
    "GeneName",
    info = "Filtered count feature IDs should be standardized for DEG"
  )
  expect_identical(
    colnames(metadata)[1],
    "Sample",
    info = "Metadata sample IDs should be standardized for DEG"
  )
  expect_identical(
    as.character(metadata$Sample),
    colnames(filtered_counts)[-1],
    info = "Metadata rows should be ordered to match filtered count samples"
  )
  expect_equal(
    as.data.frame(counts)[-1],
    filtered_counts[-1],
    info = "DEG handoff should retain the original filtered count values"
  )
}

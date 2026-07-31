test_that("app panel exposes samples_to_include accepted by main.R", {
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

  expect_true("samples_to_include" %in% panel$parameters$param_name)
  expect_match(main_text, '"--samples_to_include"')
  expect_match(
    main_text,
    "samples_to_include = parse_optional_vector\\(args\\$samples_to_include\\)"
  )
})

test_that("code/run executes successfully with default CLI arguments", {
  setup <- setup_cli_workspace("mosuite_filter_counts_test_")
  on.exit(unlink(setup$workspace, recursive = TRUE), add = TRUE)

  file.copy(
    file.path(setup$repo_root, "code", "run"),
    file.path(setup$code_dir, "run"),
    overwrite = TRUE
  )

  old_wd <- getwd()
  setwd(setup$code_dir)
  on.exit(setwd(old_wd), add = TRUE)

  exit_code <- system2("bash", args = c("run", default_cli_args))
  expect_equal(exit_code, 0, info = "run script should execute without error")

  expect_outputs_created(setup$results_dir)
})

test_that("code/run executes with custom CLI arguments", {
  setup <- setup_cli_workspace("mosuite_filter_counts_custom_test_")
  on.exit(unlink(setup$workspace, recursive = TRUE), add = TRUE)

  file.copy(
    file.path(setup$repo_root, "code", "run"),
    file.path(setup$code_dir, "run"),
    overwrite = TRUE
  )

  old_wd <- getwd()
  setwd(setup$code_dir)
  on.exit(setwd(old_wd), add = TRUE)

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
  on.exit(unlink(setup$workspace, recursive = TRUE), add = TRUE)

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

  old_wd <- getwd()
  setwd(setup$code_dir)
  on.exit(setwd(old_wd), add = TRUE)

  exit_code <- system2("bash", args = c("run", group_based_cli_args))
  expect_equal(
    exit_code,
    0,
    info = "run script with group-based filtering args should execute without error"
  )

  expect_outputs_created(setup$results_dir)
})

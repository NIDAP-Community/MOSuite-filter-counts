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

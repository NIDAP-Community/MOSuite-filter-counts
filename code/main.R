#!/usr/bin/env Rscript
rlang::global_entrace()
library(argparse)
library(glue)
library(MOSuite)
library(readr)
library(stringr)
library(dplyr)

# set up results directory
results_dir <- file.path('..','results')
plots_dir <- file.path(results_dir, 'figures')
options(moo_plots_dir = plots_dir, moo_save_plots = TRUE)

# log installed packages & versions
pkg_versions <- tibble::as_tibble(installed.packages())
write_csv(pkg_versions, file.path(results_dir, 'r-packages.csv'))

# parse CLI arguments
parser <- ArgumentParser()

parser$add_argument("--regex_moo", type="character", default=".*\\.rds$")
parser$add_argument("--count_type", type="character", default="clean")
parser$add_argument("--feature_id_colname", type="character", default=NULL, help="Column name for feature IDs")
parser$add_argument("--sample_id_colname", type="character", default=NULL, help="Column name for sample IDs")
parser$add_argument("--group_colname", type="character", default="Group", help="Column name for sample groups")
parser$add_argument("--label_colname", type="character", default=NULL, help="Column name for sample labels")
parser$add_argument("--minimum_count_value_to_be_considered_nonzero", type="integer", default=8, help="Minimum count threshold")
parser$add_argument("--minimum_number_of_samples_with_nonzero_counts_in_total", type="integer", default=7, help="Minimum samples with nonzero counts")
parser$add_argument("--minimum_number_of_samples_with_nonzero_counts_in_a_group", type="integer", default=3, help="Minimum samples per group with nonzero counts")
parser$add_argument("--use_cpm_counts_to_filter", type="logical", default=TRUE, help="Transform to CPM before filtering")
parser$add_argument("--use_group_based_filtering", type="logical", default=FALSE, help="Use group-based filtering")
parser$add_argument("--plot_corr_matrix_heatmap", type="logical", default=TRUE, help="Plot correlation heatmap")
parser$add_argument("--interactive_plots", type="logical", default=FALSE, help="Create interactive plots with plotly")

args <- parser$parse_args()

# validate inputs
data_files <- list.files(file.path('../data'), recursive = TRUE, full.names = TRUE)
moo_files <- Filter(\(x) str_detect(x, regex(args$regex_moo, ignore_case = TRUE)), data_files)

if (length(moo_files) == 0) {
    stop(glue("No files matching regex: {args$regex_moo}"))
}
moo_filename <- moo_files[1]
moo <- read_rds(moo_filename)
message(glue('Reading multiOmicDataSet from {moo_filename}'))
if (!inherits(moo, 'MOSuite::multiOmicDataSet')) {
    stop(glue('The input is not a multiOmicDataSet. class: {class(moo)}'))
}

# run MOSuite
moo |> 
    filter_counts(
        count_type = args$count_type,
        feature_id_colname = args$feature_id_colname,
        sample_id_colname = args$sample_id_colname,
        group_colname = args$group_colname,
        label_colname = args$label_colname,
        minimum_count_value_to_be_considered_nonzero = args$minimum_count_value_to_be_considered_nonzero,
        minimum_number_of_samples_with_nonzero_counts_in_total = args$minimum_number_of_samples_with_nonzero_counts_in_total,
        minimum_number_of_samples_with_nonzero_counts_in_a_group = args$minimum_number_of_samples_with_nonzero_counts_in_a_group,
        use_cpm_counts_to_filter = args$use_cpm_counts_to_filter,
        use_group_based_filtering = args$use_group_based_filtering,
        plot_corr_matrix_heatmap = args$plot_corr_matrix_heatmap,
        interactive_plots = args$interactive_plots
        ) |> 
    write_rds(file.path(results_dir, 'moo', 'moo.rds'))
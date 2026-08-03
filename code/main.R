#!/usr/bin/env Rscript
library(argparse)
library(glue)
library(readr)
library(stringr)
library(dplyr)
devtools::load_all("/code/MOSuite")

# set up capsule environment
setup_capsule_environment()

parse_optional_number <- function(x) {
  if (is.null(x) || length(x) == 0 || is.na(x) || trimws(x) == "") {
    return(NULL)
  }

  value <- suppressWarnings(as.numeric(x))
  if (is.na(value)) {
    stop(glue::glue("Expected a number, got '{x}'"))
  }
  value
}

# parse CLI arguments
parser <- ArgumentParser()

parser$add_argument("--count_type", type = "character", default = "clean")
parser$add_argument(
  "--feature_id_colname",
  type = "character",
  default = NULL,
  help = "Column name for feature IDs"
)
parser$add_argument(
  "--sample_id_colname",
  type = "character",
  default = NULL,
  help = "Column name for sample IDs"
)
parser$add_argument(
  "--group_colname",
  type = "character",
  default = "Group",
  help = "Column name for sample groups"
)
parser$add_argument(
  "--label_colname",
  type = "character",
  default = NULL,
  help = "Column name for sample labels"
)
parser$add_argument(
  "--samples_to_include",
  type = "character",
  default = "",
  help = "Comma-separated list of samples to include"
)
parser$add_argument(
  "--samples_to_rename",
  type = "character",
  default = "",
  help = "Sample renaming pairs: old:new,old2:new2"
)
parser$add_argument(
  "--minimum_count_value_to_be_considered_nonzero",
  type = "integer",
  default = 8,
  help = "Minimum count threshold"
)
parser$add_argument(
  "--minimum_number_of_samples_with_nonzero_counts_in_total",
  type = "integer",
  default = 7,
  help = "Minimum samples with nonzero counts"
)
parser$add_argument(
  "--minimum_number_of_samples_with_nonzero_counts_in_a_group",
  type = "integer",
  default = 3,
  help = "Minimum samples per group with nonzero counts"
)
parser$add_argument(
  "--use_cpm_counts_to_filter",
  type = "logical",
  default = TRUE,
  help = "Transform to CPM before filtering"
)
parser$add_argument(
  "--use_group_based_filtering",
  type = "logical",
  default = FALSE,
  help = "Use group-based filtering"
)
parser$add_argument(
  "--add_label_to_pca",
  type = "logical",
  default = TRUE,
  help = "Label points on the PCA plot"
)
parser$add_argument(
  "--principal_component_on_x_axis",
  type = "integer",
  default = 1,
  help = "PCA component on x-axis"
)
parser$add_argument(
  "--principal_component_on_y_axis",
  type = "integer",
  default = 2,
  help = "PCA component on y-axis"
)
parser$add_argument(
  "--legend_position_for_pca",
  type = "character",
  default = "top",
  help = "Legend position for PCA plot"
)
parser$add_argument(
  "--label_offset_x_",
  type = "double",
  default = 2,
  help = "Label offset x for PCA plot"
)
parser$add_argument(
  "--label_offset_y_",
  type = "double",
  default = 2,
  help = "Label offset y for PCA plot"
)
parser$add_argument(
  "--label_font_size",
  type = "double",
  default = 3,
  help = "Label font size for PCA plot"
)
parser$add_argument(
  "--point_size_for_pca",
  type = "double",
  default = 3,
  help = "Point size for PCA plot"
)
parser$add_argument(
  "--color_histogram_by_group",
  type = "logical",
  default = FALSE,
  help = "Color histogram by group"
)
parser$add_argument(
  "--set_min_max_for_x_axis_for_histogram",
  type = "logical",
  default = FALSE,
  help = "Set min/max x-axis for histogram"
)
parser$add_argument(
  "--minimum_for_x_axis_for_histogram",
  type = "double",
  default = -1,
  help = "Histogram x-axis minimum"
)
parser$add_argument(
  "--maximum_for_x_axis_for_histogram",
  type = "double",
  default = 1,
  help = "Histogram x-axis maximum"
)
parser$add_argument(
  "--legend_font_size_for_histogram",
  type = "character",
  default = "",
  help = "Legend font size for histogram. Leave blank to scale automatically."
)
parser$add_argument(
  "--legend_position_for_histogram",
  type = "character",
  default = "top",
  help = "Legend position for histogram"
)
parser$add_argument(
  "--number_of_histogram_legend_columns",
  type = "integer",
  default = 6,
  help = "Number of legend columns for histogram"
)
parser$add_argument(
  "--plot_corr_matrix_heatmap",
  type = "logical",
  default = TRUE,
  help = "Plot correlation heatmap"
)
parser$add_argument(
  "--colors_for_plots",
  type = "character",
  default = "#5954d6,#e1562c,#b80058,#00c6f8,#d163e6,#00a76c,#ff9287,#008cf9,#006e00,#796880,#FFA500,#878500",
  help = "Comma-separated colors for PCA and histogram. Defaults to the MOSuite palette. Extra group colors are generated when needed."
)
parser$add_argument(
  "--interactive_plots",
  type = "logical",
  default = FALSE,
  help = "Create interactive plots with plotly"
)

args <- parser$parse_args()

# load multiOmicDataSet from data directory
moo <- load_moo_from_data_dir()

# run MOSuite
moo |>
  filter_counts(
    count_type = args$count_type,
    feature_id_colname = args$feature_id_colname,
    sample_id_colname = args$sample_id_colname,
    group_colname = args$group_colname,
    label_colname = args$label_colname,
    samples_to_include = parse_optional_vector(args$samples_to_include),
    samples_to_rename = parse_samples_to_rename(args$samples_to_rename),
    minimum_count_value_to_be_considered_nonzero = args$minimum_count_value_to_be_considered_nonzero,
    minimum_number_of_samples_with_nonzero_counts_in_total = args$minimum_number_of_samples_with_nonzero_counts_in_total,
    minimum_number_of_samples_with_nonzero_counts_in_a_group = args$minimum_number_of_samples_with_nonzero_counts_in_a_group,
    use_cpm_counts_to_filter = args$use_cpm_counts_to_filter,
    use_group_based_filtering = args$use_group_based_filtering,
    add_label_to_pca = args$add_label_to_pca,
    principal_component_on_x_axis = args$principal_component_on_x_axis,
    principal_component_on_y_axis = args$principal_component_on_y_axis,
    legend_position_for_pca = args$legend_position_for_pca,
    label_offset_x_ = args$label_offset_x_,
    label_offset_y_ = args$label_offset_y_,
    label_font_size = args$label_font_size,
    point_size_for_pca = args$point_size_for_pca,
    color_histogram_by_group = args$color_histogram_by_group,
    set_min_max_for_x_axis_for_histogram = args$set_min_max_for_x_axis_for_histogram,
    minimum_for_x_axis_for_histogram = args$minimum_for_x_axis_for_histogram,
    maximum_for_x_axis_for_histogram = args$maximum_for_x_axis_for_histogram,
    legend_font_size_for_histogram = parse_optional_number(
      args$legend_font_size_for_histogram
    ),
    legend_position_for_histogram = args$legend_position_for_histogram,
    number_of_histogram_legend_columns = args$number_of_histogram_legend_columns,
    plot_corr_matrix_heatmap = args$plot_corr_matrix_heatmap,
    colors_for_plots = parse_optional_vector(args$colors_for_plots),
    interactive_plots = args$interactive_plots
  ) |>
  write_rds(file.path(getOption("moo_plots_dir"), "..", "moo", "moo-filt.rds"))

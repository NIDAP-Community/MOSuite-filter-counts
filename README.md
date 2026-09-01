# MOSuite-filter-counts

Code Ocean capsule: MOSuite - filter low counts

## Outputs for downstream DEG analysis

In addition to the legacy filtered MOSuite object (`moo/moo-filt.rds`), this
capsule writes a portable paired handoff in the results directory:

- `Filtered_Counts.csv` — filtered, raw/integer-like counts. The first column
  is standardized to `GeneName`; CPM values are used only to make the filtering
  decision when that option is selected and are not written into this table.
- `Sample_Metadata.csv` — matching metadata, restricted and ordered to the
  retained count-table sample columns. Its sample-ID column is standardized to
  `Sample` and all other metadata columns are preserved.

Attach both CSV files to OMIX DEG Analysis, select **Table** input, and leave
the default `GeneName` and `Sample` column settings in place. Set `Group` and,
when applicable, `Batch` to the matching metadata columns.

[![tests](https://github.com/CCBR/MOSuite-filter-counts/actions/workflows/tests.yml/badge.svg)](https://github.com/CCBR/MOSuite-filter-counts/actions/workflows/tests.yml)

- [Code Ocean Capsule](https://poc-nci.codeocean.io/capsule/2922767/tree)
- [MOSuite R package docs](https://ccbr.github.io/MOSuite/)

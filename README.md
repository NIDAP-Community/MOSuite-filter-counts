# MOSuite-filter-counts

Code Ocean capsule: MOSuite - filter low counts

[![tests](https://github.com/NIDAP-Community/MOSuite-filter-counts/actions/workflows/tests.yml/badge.svg)](https://github.com/NIDAP-Community/MOSuite-filter-counts/actions/workflows/tests.yml)

- [Code Ocean Capsule](https://poc-nci.codeocean.io/capsule/2922767/tree) | [Latest Release](https://poc-nci.codeocean.io/capsule/4565215/tree/latest)
- [MOSuite R package docs](https://ccbr.github.io/MOSuite/)

## Outputs

- `moo/moo-filt.rds` - multiOmicDataSet with filtered counts stored in `moo@counts[['filt']]`.
- `Filtered_Counts.csv` — filtered, raw/integer-like counts. The first column
  is standardized to `GeneName`; CPM values are used only to make the filtering
  decision when that option is selected and are not written into this table.
  This file is compatible for downstream use by the OMIX DEG capsule.
- `Sample_Metadata.csv` — matching sample metadata, restricted and ordered to the
  retained count-table sample columns. Its sample-ID column is standardized to
  `Sample` and all other metadata columns are preserved.
  This file is compatible for downstream use by the OMIX DEG capsule.

### Usage for downstream OMIX DEG Analysis capsule

Attach both CSV files to OMIX DEG Analysis, select **Table** input, and leave
the default `GeneName` and `Sample` column settings in place.
Set `Group` and, when applicable, `Batch` to the matching metadata columns.

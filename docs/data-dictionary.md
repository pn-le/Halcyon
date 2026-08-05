# Data dictionary — `data/studies.csv`

One row per study. Descriptive fields are coded from the sources; effect-size
numbers for the meta-analysis must be extracted from the full-text papers (they
are NOT invented here).

| column | meaning |
|---|---|
| `study_id` | internal id |
| `authors` | first author / label |
| `year` | publication year (NA if unknown) |
| `joint` | anatomical joint (TMJ, shoulder, sacroiliac, multiple, …) |
| `intervention` | `prolotherapy_dextrose`, `prolotherapy_mixed`, `prolotherapy_other`, or `PRP` |
| `design` | `RCT`, `case_series`, `retrospective` |
| `n` | sample size (NA = verify from full text) |
| `comparator` | control condition, or `none` |
| `outcome_measure` | primary outcome(s) reported |
| `direction` | `improved` / `mixed` / `none` (qualitative direction only) |
| `followup_months` | follow-up length (NA if unclear) |
| `quality` | rough appraisal: `very-low`→`high` (replace with a formal risk-of-bias tool) |
| `poolable` | `yes` if comparable enough to meta-analyze |
| `source_url` | link to the paper |
| `notes` | caveats; “VERIFY …” = fill from full text |

## How to add studies
Run a formal search (PubMed, Embase, Scopus, Cochrane), screen, and append a row
per included study. Keep `notes` honest about what still needs verifying.

## Quality / bias
The `quality` column is a placeholder. For a real review, replace it with a
recognized tool: **RoB 2** for RCTs, **ROBINS-I** or a case-series checklist for
observational studies.

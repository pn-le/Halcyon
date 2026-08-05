# Halcyon

*A reproducible evidence map and meta-analysis of regenerative injections (dextrose prolotherapy and platelet-rich plasma) for joint hypermobility, including hypermobile Ehlers–Danlos syndrome (hEDS).*

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Made with R](https://img.shields.io/badge/Made%20with-R-1f65b7.svg)

## About

People with joint hypermobility are often offered regenerative injections (PRP, prolotherapy) to tighten lax, unstable joints — but the evidence is scattered and has never been consolidated. **Halcyon** gathers the published trials, pools the parts that are comparable, and maps the rest to show what is actually known and where the gaps are.

**Headline finding:** dextrose prolotherapy has real (if modest, low-to-moderate quality) evidence for reducing pain in one hypermobile joint — the jaw (TMJ) — but the peripheral joints central to hEDS (shoulder, hip, knee, spine) have **no controlled trials at all.**

## Key results

**Evidence map — what has been studied, and where the gaps are**

![Evidence map](figures/evidence_map.png)

*Each point is a study, placed by joint (rows) and injection type (columns). Triangles are randomized trials; circles/squares are weaker uncontrolled studies. Controlled evidence exists only for the TMJ, and most of the grid is empty.*

**Meta-analysis — dextrose prolotherapy vs placebo for TMJ pain**

![Forest plot](figures/forest_plot.png)

*Published pooled estimate (Sit et al. 2021, 3 RCTs): standardized mean difference −0.76 (95% CI −1.19 to −0.32), favoring prolotherapy, with zero heterogeneity.*

## What this shows

- Independent meta-analyses agree dextrose prolotherapy reduces **TMJ pain** vs placebo (pooled SMD ≈ −0.76, low heterogeneity).
- Effects on mouth opening / function are **inconsistent**, evidence quality is **low–moderate**, and follow-up is **short**.
- All of this is the **jaw only**. The hypermobile joints that matter most in hEDS remain **untested by any randomized trial** — the clearest gap.

## Repository structure

```
Halcyon/
├── run_all.R                # one command rebuilds every figure & table
├── data/
│   ├── raw/                 # source data, read-only (hand-curated)
│   │   ├── studies.csv          # coded primary studies (the evidence map)
│   │   ├── pooled_results.csv   # published pooled estimates, with DOIs
│   │   ├── prisma_counts.csv    # PRISMA record funnel (search log)
│   │   └── rob.csv              # risk-of-bias coding per study
│   └── processed/           # script-generated tables (git-ignored)
├── R/
│   ├── 01_meta_analysis.R   # forest plot (metafor) on real, cited data
│   ├── 02_evidence_map.R    # evidence map + summaries (ggplot2)
│   ├── 03_prisma.R          # PRISMA 2020 flow diagram (PRISMA2020)
│   └── 04_risk_of_bias.R    # risk-of-bias traffic-light plot (robvis)
├── report/evidence-synthesis.qmd   # Quarto report tying it together
├── figures/                 # rendered figures shown above (tracked)
├── docs/data-dictionary.md  # what each data column means
├── renv.lock                # pinned R package versions
└── halcyon.Rproj            # open this in RStudio
```

## Reproduce it

From a fresh clone, one command rebuilds every figure and table:

```r
renv::restore()      # installs the exact package versions from renv.lock
source("run_all.R")  # regenerates figures/ and data/processed/
```

Or from the shell: `Rscript run_all.R`.

Working figures are written to `outputs/` (git-ignored); the README figures are
copied into `figures/` (tracked). Optionally render the full report with
`quarto render report/evidence-synthesis.qmd`.

> **Note.** `R/03_prisma.R` and `R/04_risk_of_bias.R` render the PRISMA flow
> diagram and risk-of-bias plot from `data/raw/prisma_counts.csv` and
> `data/raw/rob.csv`. Those files ship as templates: until the real search-log
> counts and per-study appraisals are entered, both scripts **skip** rather than
> invent numbers, and `run_all.R` still rebuilds everything else.

## Data & sources

Effect sizes come from published, peer-reviewed meta-analyses and trials (full list with DOIs in `data/raw/pooled_results.csv`), including:

- Sit et al. 2021, *Sci Rep* — doi:10.1038/s41598-021-94119-2
- Nagori et al. 2018, *J Oral Rehabil* — doi:10.1111/joor.12698
- Saramantos et al. 2025, *Clin Pract* — doi:10.3390/clinpract15030051

No numbers are invented; where a trial's raw data was unavailable, this is noted in the code.

## How to cite

A `CITATION.cff` is included, so GitHub shows a **"Cite this repository"** button in the sidebar.

## License

Code is released under the MIT License (see `LICENSE`).

## Disclaimer

This is a student research project for educational purposes. It is **not medical advice**, makes no treatment recommendations, and is a scoping-level synthesis — not a definitive verdict on efficacy.

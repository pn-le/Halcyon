# halcyon

**A reproducible evidence map & meta-analysis, in R, of regenerative injections (PRP / prolotherapy) for joint hypermobility including hypermobile Ehlers–Danlos syndrome (hEDS).**

Nobody has consolidated this scattered literature. This project does two things:
1. **Meta-analysis** of the small poolable subset (the TMJ dextrose-prolotherapy RCTs).
2. **Evidence map** of the wider, un-poolable literature (which joints, which interventions, how strong) — so the gaps are obvious at a glance.

> Scoping-level synthesis, student project, **not medical advice** and not a definitive efficacy verdict.

## What's inside

```
halcyon/
├── halcyon.Rproj  # open THIS in RStudio
├── data/studies.csv                # the coded studies (real descriptive data)
├── R/
│   ├── 01_meta_analysis.R          # metafor: pooled effect + forest plot (poolable subset)
│   └── 02_evidence_map.R           # ggplot2: evidence map + summary tables
├── report/evidence-synthesis.qmd   # Quarto report that ties it together
├── docs/data-dictionary.md         # what each CSV column means + sources
└── outputs/                        # generated figures/tables (git-ignored)
```

## How to run it (in RStudio)

1. **Install R and RStudio** (both free): https://posit.co/download/rstudio-desktop/
2. **Open the project**: double-click `halcyon.Rproj` (this sets the working directory correctly).
3. **Install the packages** (once), in the R console:
   ```r
   install.packages(c("metafor", "readr", "dplyr", "ggplot2"))
   ```
4. **Run the evidence map**: open `R/02_evidence_map.R` and click **Source** (or `Ctrl/Cmd+Shift+S`). A plot appears and figures save to `outputs/`.
5. **Run the meta-analysis**: open `R/01_meta_analysis.R` and Source it. It produces a forest plot.
   - ⚠️ The effect-size numbers in that script are **synthetic placeholders** so it runs out of the box. Replace them with real values extracted from the full-text papers before drawing any conclusion.
6. **Build the full report** (optional, needs Quarto — bundled with recent RStudio): open `report/evidence-synthesis.qmd` and click **Render**. You get a self-contained HTML report.

## Roadmap
- [ ] Extract real effect sizes (means/SDs/n) from the TMJ RCT full texts → real meta-analysis
- [ ] Expand the search (PubMed/Embase/Scopus/Cochrane) and add studies to `studies.csv`
- [ ] Add risk-of-bias coding per study
- [ ] Wrap the evidence map in a Shiny app (interactive/filterable)
- [ ] Write up → poster → preprint → journal

## License
Code: MIT (see `LICENSE`). Please cite if reused.

## Disclaimer
Educational research project. Not medical advice; makes no treatment claims.

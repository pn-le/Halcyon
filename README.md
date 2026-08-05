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
├── data/
│   ├── studies.csv          # coded primary studies (the evidence map)
│   └── pooled_results.csv   # published pooled estimates, with DOIs
├── R/
│   ├── 01_meta_analysis.R   # forest plot (metafor) on real, cited data
│   └── 02_evidence_map.R    # evidence map + summaries (ggplot2)
├── report/evidence-synthesis.qmd   # Quarto report tying it together
├── figures/                 # rendered figures shown above
├── docs/data-dictionary.md  # what each data column means
└── halcyon.Rproj            # open this in RStudio
```

## Reproduce it

1. Install [R and RStudio](https://posit.co/download/rstudio-desktop/).
2. Open `halcyon.Rproj` in RStudio.
3. Install packages: `install.packages(c("metafor","readr","dplyr","ggplot2"))`
4. Source `R/02_evidence_map.R` and `R/01_meta_analysis.R`. Figures save to `outputs/`.
5. Optional: render `report/evidence-synthesis.qmd` for the full report.

## Data & sources

Effect sizes come from published, peer-reviewed meta-analyses and trials (full list with DOIs in `data/pooled_results.csv`), including:

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

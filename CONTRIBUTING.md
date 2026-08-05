# Contributing to Hypermobility Injection Evidence

Thanks for your interest! Hypermobility Injection Evidence is an open, reproducible research project (an evidence map and meta-analysis of regenerative injections for joint hypermobility). Contributions — new studies, corrections, code improvements, or a review of the methods — are welcome.

## Ground rules (research integrity)

- **Never invent data.** Effect sizes and counts must come from published sources. If a number isn't available, leave a clearly-marked `# TODO` and stop — the scripts are designed to skip rather than fabricate.
- **Keep claims scoping-level.** This is a preliminary synthesis, not a definitive verdict, and **not medical advice** — don't add treatment claims.
- **Cite everything.** New studies need a source URL/DOI in `data/raw/studies.csv`.
- **Separate retrieval from judgment.** Automated fetching is fine; inclusion and risk-of-bias appraisal are human decisions.

## How to contribute

1. Fork the repo and create a branch (`feature/…`, `fix/…`, or `docs/…`).
2. Make your change:
   - **Adding a study?** Add a row to `data/raw/studies.csv` (see `docs/data-dictionary.md` for the columns) and, if relevant, a risk-of-bias row in `data/raw/rob.csv`.
   - **Changing analysis?** Edit the numbered scripts in `R/`.
3. Rebuild to check nothing breaks: `Rscript run_all.R` (or `renv::restore()` first).
4. Open a pull request describing what changed and why, with sources.

## Setup

Install [R + RStudio](https://posit.co/download/rstudio-desktop/), open `hypermobility-injection-evidence.Rproj`, run `renv::restore()`, then `source("run_all.R")`.

## Reporting issues

Open a GitHub Issue for anything: a missing study, a possible error, a methods question, or an idea. Clear, specific issues (with a link or citation where relevant) are the most useful.

## Code of conduct

Be respectful and constructive. This is a learning-driven project — good-faith questions and corrections are especially welcome.

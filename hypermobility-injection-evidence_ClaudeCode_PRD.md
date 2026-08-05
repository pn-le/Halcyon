# Hypermobility Injection Evidence — Claude Code Build PRD

**Project:** Hypermobility Injection Evidence — a reproducible evidence map & meta-analysis of regenerative injections (dextrose prolotherapy, PRP) for joint hypermobility incl. hEDS.
**Repo:** `github.com/pnle-research/hypermobility-injection-evidence` · **Local path:** `~/Desktop/Admin/hypermobility-injection-evidence`
**Owner:** Phillips Le · **Version:** v1.1 (Aug 2026)

**What this PRD is:** the spec for the **code/build work done in Claude Code.** Evidence gathering (literature search, extracting numbers) and prose writing happen separately in Cowork; this PRD assumes `data/` may still be growing and must never be filled with invented values.

---

## 1. Goal
Turn Hypermobility Injection Evidence from a working analysis into a **proper reproducible research compendium** that (a) anyone can rebuild with one command, (b) reads like a real systematic review (PRISMA + risk-of-bias), (c) keeps its own data current via an automated fetcher, and (d) ships one memorable interactive artifact — all while staying scoping-level and honest.

## 2. Non-goals
- Do **not** invent, estimate, or alter study data / effect sizes. Missing values → a clearly-marked `# TODO` and stop; never fabricate.
- Do **not** make medical claims or weaken the "not medical advice" disclaimer.
- Do **not** run the manual literature search/appraisal here (that's Cowork). The Python fetcher (P2) automates *retrieval only*, not judgment.

## 3. Tech stack (polyglot by design)
Each language does the job it's best at; they hand data to each other via files/APIs.
- **R** (core): analysis, meta-analysis (`metafor`), figures (`ggplot2`), report (`Quarto`).
- **Python** (P2): automated study retrieval from PubMed / ClinicalTrials.gov APIs → writes `data/raw/`. Bridged to R via `reticulate`, or run as a standalone pipeline step.
- **Bash** (P0/P4): orchestration (`run_all`), git, and optional scheduled re-runs (cron) for a "living review."
- **SQL / SQLite** (optional, P5): only if the dataset outgrows CSVs — local DB + queries.
- **JavaScript/D3** (optional, P4 alt): a *static* interactive map for GitHub Pages (no server), as an alternative to the R/Shiny app.

## 4. Conventions
- Extend the existing layout; numbered scripts in `R/`. Everything runs non-interactively via `Rscript`.
- Outputs → `outputs/` (git-ignored); figures shown in README → `figures/` (tracked).
- Small commits, clear messages, author = Phillips Le, push to `origin main`.
- Pin dependencies (`renv` for R; `requirements.txt` for Python). Fail loudly on missing files/packages — never silently skip.

---

## 5. Work items (priority order)

### P0 — Reproducible compendium structure
- [ ] Split `data/` into `data/raw/` (source, read-only) and `data/processed/` (script-generated). Move `studies.csv`, `pooled_results.csv` to `raw/`; fix script paths.
- [ ] `renv::init()`; commit `renv.lock`.
- [ ] Add `run_all.R` at repo root that sources scripts in order and regenerates all outputs/figures end-to-end.
- [ ] Update README "Reproduce it": `renv::restore()` → `source("run_all.R")`.
**Done when:** fresh clone + `renv::restore()` + `source("run_all.R")` rebuilds every figure, no manual steps.

### P1 — Make it a systematic review (not just an analysis)
- [ ] `R/03_prisma.R` using `PRISMA2020` → `figures/prisma.png`; counts live in an editable `data/raw/prisma_counts.csv`.
- [ ] `R/04_risk_of_bias.R` using `robvis` → `figures/rob.png`; RoB coding table in `data/raw/rob.csv` (RoB 2 domains for RCTs; ROBINS-I-style for observational).
- [ ] Embed both figures in the README.
**Done when:** PRISMA + RoB figures render from data files and appear in the README.

### P2 — Python study-fetcher (automated inputs)
- [ ] `python/fetch_studies.py`: query PubMed E-utilities + ClinicalTrials.gov API for the review's terms; output a candidate `data/raw/candidates.csv` (title, year, journal, DOI, abstract, source).
- [ ] Keep retrieval and inclusion **separate**: the script only *fetches*; inclusion/coding stays a human/Cowork decision. Flag new candidates not already in `studies.csv`.
- [ ] `requirements.txt`; document running it standalone and (optionally) from R via `reticulate`.
**Done when:** running the script refreshes a candidate list and highlights new papers, without touching curated data.

### P3 — Deeper analysis
- [ ] Extend `R/01_meta_analysis.R`: when raw per-trial means/SDs/n exist (from Cowork), build a from-scratch pooled model; keep the published-estimate display as a cross-check.
- [ ] Scaffold subgroup/sensitivity analyses (by joint, agent, risk-of-bias); report I², prediction interval, and leave-one-out where k allows. Note limitations where subgroups are tiny.
**Done when:** meta-analysis runs on real data with heterogeneity + ≥1 sensitivity analysis, honestly captioned.

### P4 — Interactive + published
- [ ] **Interactive evidence explorer:** an R/Shiny app (`app.R`) with filters (joint, intervention, quality, design) + study table. *Optional alt:* a static D3/Observable version for GitHub Pages (no server).
- [ ] Publish the Quarto report via **GitHub Pages**; link in README.
- [ ] Tag release `v0.1.0`; connect **Zenodo** for a DOI; add DOI badge to README.
**Done when:** an interactive explorer runs, a live report URL exists, and the README shows a Zenodo DOI badge.

### P5 — (Optional) SQL storage
- [ ] Only if the study set grows large: move curated data into a local **SQLite** DB; add a query layer; keep CSV export for portability.
**Done when:** analysis can read from the DB and still reproduce identical figures.

---

## 6. Suggested sequence
P0 → P1 (both structural, data-agnostic — do first) → **return to Cowork for real numbers** → P3 → P2 (fetcher) → P4 → P5 (only if needed).

## 7. Definition of done (whole PRD)
Fresh clone rebuilds everything with one command; README shows results + PRISMA + RoB figures, reproduce steps, cited sources, and a cite button; a Python fetcher refreshes candidates; an interactive explorer exists; a tagged release has a Zenodo DOI; no fabricated data; disclaimer intact.

## 8. Guardrails (Claude Code must respect)
- Never fabricate numbers — mark gaps `# TODO: value from full text` and stop.
- Keep claims scoping-level; preserve the disclaimer.
- Separate automated *retrieval* from human *inclusion/appraisal*.
- Small commits; author Phillips Le; push to `main`. Fail loudly on missing deps/data.

## 9. Kickoff prompt for Claude Code (paste this)
> "Read `Hypermobility Injection Evidence_ClaudeCode_PRD.md` in this repo. Start with P0 (compendium structure): split data into raw/processed, set up renv, and create run_all.R, updating the README reproduce section. Then do P1 (PRISMA + risk-of-bias figures). Make small commits and push to main. Never fabricate data — leave clearly-marked TODOs where numbers are missing, and stop rather than guessing."

# run_all.R  —  one-command rebuild of the whole compendium
# ---------------------------------------------------------------------
# Usage (from the repo root):
#   Rscript run_all.R
# or, in an R session at the repo root:
#   source("run_all.R")
#
# Regenerates every figure and processed table from data/raw/. Figures for
# the README are copied into figures/ (tracked); working outputs go to
# outputs/ (git-ignored). Fails loudly on missing packages or data.

# --- Ensure we run from the repo root ---------------------------------
if (!file.exists("run_all.R")) {
  stop("Run this from the repository root (where run_all.R lives).")
}

# --- Fail loudly on missing packages ----------------------------------
needed <- c("metafor", "readr", "dplyr", "ggplot2")
missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Missing R packages: ", paste(missing, collapse = ", "),
       "\nRun renv::restore(), or install.packages(c(",
       paste(sprintf('"%s"', missing), collapse = ", "), ")).")
}

dir.create("figures", showWarnings = FALSE)

# --- Core analysis scripts (always run) -------------------------------
core <- c("R/02_evidence_map.R", "R/01_meta_analysis.R")
for (s in core) {
  message("\n=== Sourcing ", s, " ===")
  source(s, echo = FALSE)
}

# --- Systematic-review scripts (skip loudly if data not yet filled) ---
# These read curated data files that may still contain TODO placeholders
# awaiting the literature search / appraisal (done in Cowork). Each script
# renders its figure when its data is complete, or prints a SKIP notice.
review <- c("R/03_prisma.R", "R/04_risk_of_bias.R")
for (s in review) {
  if (file.exists(s)) {
    message("\n=== Sourcing ", s, " ===")
    source(s, echo = FALSE)
  }
}

# --- Copy README figures from outputs/ (working) to figures/ (tracked) -
readme_figs <- c("evidence_map.png", "forest_plot.png",
                 "prisma.png", "rob.png")
for (f in readme_figs) {
  src <- file.path("outputs", f)
  if (file.exists(src)) {
    file.copy(src, file.path("figures", f), overwrite = TRUE)
    message("Updated figures/", f)
  }
}

message("\nDone. See figures/ for README figures and data/processed/ for tables.")

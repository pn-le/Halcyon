# 01_meta_analysis.R
# Targeted mini meta-analysis of the POOLABLE studies (the TMJ dextrose
# prolotherapy RCTs). This is where a pooled number is defensible because
# the studies share a design (RCT), population (TMJ hypermobility), and
# comparable outcomes.
#
# IMPORTANT: real meta-analysis needs effect sizes + their variances
# EXTRACTED FROM THE FULL-TEXT PAPERS (means, SDs, and n per group, or a
# reported effect + CI). The `studies.csv` intentionally does NOT contain
# invented numbers. Below is a SYNTHETIC, CLEARLY-LABELLED example so the
# script runs and you can see the workflow; REPLACE it with your real
# extracted values before drawing any conclusion.

# install.packages("metafor")  # run once
library(metafor)

# ---------------------------------------------------------------------
# STEP 1 — extract effect sizes from the poolable papers into this table.
# Here we use standardized mean differences (SMD). For each RCT you need,
# per group (treatment vs control): mean, SD, and n.
#
# >>> THESE NUMBERS ARE SYNTHETIC PLACEHOLDERS — REPLACE WITH REAL DATA <<<
# ---------------------------------------------------------------------
dat <- data.frame(
  study = c("Louw 2019", "Comert Kilic 2016", "Refai 2011"),
  # treatment group
  m1i = c(2.1, 2.4, 2.0),  sd1i = c(1.2, 1.3, 1.1), n1i = c(20, 15, 12),
  # control/placebo group
  m2i = c(4.0, 3.9, 3.8),  sd2i = c(1.4, 1.5, 1.3), n2i = c(20, 15, 12),
  stringsAsFactors = FALSE
)

# STEP 2 — compute the effect size (SMD) and sampling variance for each study
es <- escalc(measure = "SMD",
             m1i = dat$m1i, sd1i = dat$sd1i, n1i = dat$n1i,
             m2i = dat$m2i, sd2i = dat$sd2i, n2i = dat$n2i,
             data = dat)

# STEP 3 — random-effects model (appropriate when studies differ somewhat)
res <- rma(yi, vi, data = es, method = "REML")
print(summary(res))            # pooled effect, CI, I^2 (heterogeneity)

# STEP 4 — forest plot (the classic meta-analysis figure)
forest(res, slab = dat$study,
       header = "Study",
       xlab = "Standardized mean difference (lower = less pain)")

# STEP 5 — save the figure
dir.create("outputs", showWarnings = FALSE)
png("outputs/forest_plot.png", width = 1000, height = 500, res = 120)
forest(res, slab = dat$study, header = "Study",
       xlab = "Standardized mean difference (lower = less pain)")
dev.off()

# NOTE ON HONESTY: with only ~3 small RCTs (all TMJ), any pooled estimate is
# preliminary. Report the heterogeneity (I^2) and treat this as a scoping-level
# synthesis, not a definitive efficacy verdict.

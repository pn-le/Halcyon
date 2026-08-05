# 01_meta_analysis.R  —  REAL DATA VERSION
# ---------------------------------------------------------------------
# Dextrose prolotherapy vs placebo for TMJ pain: real, cited effect sizes.
#
# SOURCES (all values below are from the published literature, via PubMed):
#  - Sit et al. 2021, Sci Rep  (doi:10.1038/s41598-021-94119-2)
#       Pooled TMJ pain @12wk, 3 RCTs (n=89): SMD -0.76 (95% CI -1.19,-0.32), I^2=0%
#  - Nagori et al. 2018, J Oral Rehabil (doi:10.1111/joor.12698)
#       TMJ hypermobility, 3 RCTs: pain MD -1.00 (-1.58,-0.42); MMO MD -3.32 (-5.26,-1.28)
#  - Mustafa et al. 2018, J Craniofac Surg (doi:10.1097/SCS.0000000000004480)
#       Raw post-tx VAS: 20% dextrose 0.55+/-0.72 (n=9) vs control 1.77+/-1.64 (n=9)
#
# HONESTY NOTES:
#  - Most individual-trial raw tables are paywalled; Mustafa is computed from real raw data.
#  - Refai 2011 reported pain as an ordinal % change -> cannot be pooled as a mean.
#  - We do NOT re-pool the Sit 2021 summary WITH its component studies (overlap). We
#    display the real estimates side by side. To build a from-scratch pool, add each
#    trial's raw means/SDs/n to `raw` below as you obtain them.

# install.packages("metafor")   # run once
library(metafor)

# ---- (A) Real per-study raw data we could obtain ---------------------
# Add rows here as you extract raw means/SDs/n from each trial's results table.
raw <- data.frame(
  study = "Mustafa 2018 (20%D vs control)",
  m1i = 0.55, sd1i = 0.72, n1i = 9,   # dextrose arm (VAS pain, post-tx)
  m2i = 1.77, sd2i = 1.64, n2i = 9,   # control arm
  stringsAsFactors = FALSE
)
raw <- escalc(measure = "SMD",
              m1i = raw$m1i, sd1i = raw$sd1i, n1i = raw$n1i,
              m2i = raw$m2i, sd2i = raw$sd2i, n2i = raw$n2i,
              data = raw)
cat("Mustafa 2018 computed SMD:\n"); print(summary(raw)[, c("yi","vi")])

# ---- (B) Published POOLED estimates (real, cited) --------------------
# Convert reported 95% CI to a standard error:  SE = (upper - lower) / (2*1.96)
pooled <- data.frame(
  label = c("Sit 2021 pooled pain (k=3, n=89)"),
  yi    = c(-0.76),
  ci_lo = c(-1.19),
  ci_hi = c(-0.32),
  stringsAsFactors = FALSE
)
pooled$sei <- (pooled$ci_hi - pooled$ci_lo) / (2 * 1.96)

# ---- (C) Forest plot of the REAL pain-SMD evidence -------------------
# One computed single trial + the published pooled estimate, on the SMD scale.
# (Not re-pooled: the Sit estimate already contains its own trials.)
est   <- c(raw$yi[1], pooled$yi)
se    <- c(sqrt(raw$vi[1]), pooled$sei)
slab  <- c(as.character(raw$study), pooled$label)

dir.create("outputs", showWarnings = FALSE)
png("outputs/forest_plot.png", width = 1100, height = 400, res = 120)
forest(x = est, sei = se, slab = slab,
       header = c("Estimate (source)", "SMD [95% CI]"),
       xlab = "Standardized mean difference (negative = less pain, favors dextrose)",
       refline = 0, psize = 1.2)
title("Dextrose prolotherapy vs placebo for TMJ pain (real, cited data)")
dev.off()

# also render to screen when run interactively
forest(x = est, sei = se, slab = slab,
       header = c("Estimate (source)", "SMD [95% CI]"),
       xlab = "Standardized mean difference (negative = less pain, favors dextrose)",
       refline = 0, psize = 1.2)

# ---- (D) Print the wider published evidence table --------------------
pooled_tbl <- read.csv("data/pooled_results.csv", stringsAsFactors = FALSE)
cat("\nPublished pooled results (see data/pooled_results.csv):\n")
print(pooled_tbl[, c("outcome","source_author","source_year","effect_type","effect","ci_low","ci_high","favors")])

# BOTTOM LINE (real): independent meta-analyses agree that dextrose prolotherapy
# reduces TMJ pain vs placebo (SMD ~ -0.76), with LOW heterogeneity, but effects on
# mouth opening / function are inconsistent, evidence quality is low-moderate, and
# follow-up is short. This is the jaw only; peripheral/hEDS joints remain unstudied by RCT.

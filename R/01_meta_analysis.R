# 01_meta_analysis.R  —  from-scratch meta-analysis engine (real data)
# ---------------------------------------------------------------------
# Dextrose prolotherapy vs placebo for TMJ pain, on the standardized-mean-
# difference (SMD) scale. Per-trial raw arms live in data/raw/trial_arms.csv;
# this script computes each trial's SMD and, WHEN >= 2 trials have extractable
# raw data, fits a random-effects model reporting heterogeneity (I2, tau^2,
# Q), a 95% prediction interval, leave-one-out, and subgroup moderator tests.
#
# HONESTY: only complete rows (all of m/sd/n for both arms) are used. Rows
# still marked TODO are listed as pending, never imputed. Published pooled
# estimates (data/raw/pooled_results.csv) are shown as an independent cross-
# check — NOT re-pooled with their own component trials (that would double
# count). See 02_evidence_map.R for the wider, un-poolable literature.

library(metafor)

# ---- (A) Per-trial raw arms -> SMD -----------------------------------
arms <- read.csv("data/raw/trial_arms.csv", stringsAsFactors = FALSE)
num  <- c("m1i","sd1i","n1i","m2i","sd2i","n2i")
arms[num] <- lapply(arms[num], function(x) suppressWarnings(as.numeric(x)))

complete <- arms[stats::complete.cases(arms[num]), ]
pending  <- arms[!stats::complete.cases(arms[num]), ]

# Hedges' g (default SMD; small-sample corrected) with sampling variance
complete <- escalc(measure = "SMD",
                   m1i = complete$m1i, sd1i = complete$sd1i, n1i = complete$n1i,
                   m2i = complete$m2i, sd2i = complete$sd2i, n2i = complete$n2i,
                   data = complete)

k <- nrow(complete)
cat(sprintf("Controlled trials with extractable raw arms: k = %d\n", k))
print(summary(complete)[, c("study","yi","vi")])
if (nrow(pending)) {
  cat("\nPending raw extraction (TODO from full text, not imputed):\n")
  cat(" -", paste(pending$study, collapse = "\n - "), "\n")
}

# ---- (B) Random-effects pool + heterogeneity + sensitivity -----------
res <- NULL
if (k >= 2) {
  res <- rma(yi, vi, data = complete, method = "REML", slab = complete$study)
  cat("\n== Random-effects model (REML) ==\n"); print(res)

  pi <- predict(res)
  cat(sprintf("\nPooled SMD = %.2f (95%% CI %.2f, %.2f); 95%% prediction interval %.2f, %.2f\n",
              res$b, res$ci.lb, res$ci.ub, pi$pi.lb, pi$pi.ub))
  cat(sprintf("Heterogeneity: I^2 = %.1f%%, tau^2 = %.3f, Q(%d) = %.2f, p = %.3f\n",
              res$I2, res$tau2, res$k - 1, res$QE, res$QEp))

  cat("\n== Leave-one-out sensitivity ==\n")
  print(leave1out(res))

  # Subgroup moderator tests, run only where a factor has >= 2 levels each
  # supported by >= 2 trials (otherwise not estimable -> reported as such).
  for (mod in c("joint","agent","rob")) {
    tab <- table(complete[[mod]])
    if (sum(tab >= 2) >= 2) {
      cat(sprintf("\n== Subgroup by %s ==\n", mod))
      print(rma(yi, vi, mods = ~ factor(complete[[mod]]), data = complete, method = "REML"))
    } else {
      cat(sprintf("\n[subgroup by %s not estimable: subgroups too small]\n", mod))
    }
  }
} else {
  cat("\n[From-scratch pool not run: needs k >= 2 controlled trials with raw",
      "arms; currently k =", k, ".]\n",
      "Heterogeneity/prediction-interval/leave-one-out activate once >= 1 more",
      "trial's raw arms are added to data/raw/trial_arms.csv.\n")

  # Sensitivity we CAN run on the single computed effect: metric robustness.
  # Hedges' g (small-sample corrected, above) vs uncorrected Cohen's d.
  if (k == 1) {
    n1 <- complete$n1i; n2 <- complete$n2i
    J  <- 1 - 3 / (4 * (n1 + n2 - 2) - 1)   # Hedges correction factor
    d  <- complete$yi / J                    # back out Cohen's d
    cat(sprintf("\nMetric-robustness check (single trial):\n  Hedges g = %.2f, Cohen d = %.2f (J = %.3f)\n",
                complete$yi, d, J))
  }
}

# ---- (C) Published pooled estimates (real, cited cross-check) ---------
pooled_tbl <- read.csv("data/raw/pooled_results.csv", stringsAsFactors = FALSE)
cat("\nPublished pooled results (independent reviews; real reported heterogeneity):\n")
print(pooled_tbl[, c("outcome","source_author","source_year","effect_type",
                     "effect","ci_low","ci_high","i2_pct","favors")])

# SMD-scale published pool(s) for the forest cross-check
sit <- subset(pooled_tbl, effect_type == "SMD")
sit$sei <- (sit$ci_high - sit$ci_low) / (2 * 1.96)

# ---- (D) Forest plot (SMD scale) -------------------------------------
# Computed trial SMD(s); the from-scratch pooled diamond if k>=2; and the
# published SMD pool as a clearly-labeled external reference.
est  <- complete$yi
se   <- sqrt(complete$vi)
slab <- as.character(complete$study)
if (!is.null(res)) {                          # append from-scratch pooled row
  est  <- c(est, as.numeric(res$b))
  se   <- c(se,  res$se)
  slab <- c(slab, sprintf("From-scratch pool (k=%d)", k))
}
est  <- c(est, sit$effect)                    # external published pool(s)
se   <- c(se,  sit$sei)
slab <- c(slab, sprintf("%s %s pool (external, k=%s)",
                        sit$source_author, sit$source_year, sit$k_studies))

dir.create("outputs", showWarnings = FALSE)
png("outputs/forest_plot.png", width = 1100, height = 400, res = 120)
forest(x = est, sei = se, slab = slab,
       header = c("Estimate (source)", "SMD [95% CI]"),
       xlab = "Standardized mean difference (negative = less pain, favors prolotherapy)",
       refline = 0, psize = 1.2)
title("Dextrose prolotherapy vs placebo for TMJ pain (SMD; real data)")
dev.off()

# BOTTOM LINE (real): independent published meta-analyses agree dextrose
# prolotherapy reduces TMJ pain vs placebo (SMD ~ -0.76, I^2 = 0%), but effects
# on mouth opening/function are inconsistent, quality is low-moderate, and
# follow-up is short. This is the jaw only; peripheral/hEDS joints have no RCTs.
# A fully from-scratch pool awaits raw arms for >= 1 more controlled trial.

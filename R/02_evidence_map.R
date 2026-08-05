# 02_evidence_map.R
# Evidence MAP of the whole literature — including the studies that CANNOT be
# pooled (different joints, no control groups, tiny samples). Instead of forcing
# a number, we visualize what has been studied, where, and how strong it is.
# This uses only the real descriptive coding in data/raw/studies.csv.

# install.packages(c("readr", "dplyr", "ggplot2"))  # run once
library(readr)
library(dplyr)
library(ggplot2)

studies <- read_csv("data/raw/studies.csv", show_col_types = FALSE)

# order study quality so it maps to a sensible colour scale
quality_levels <- c("very-low", "low", "moderate", "moderate-high", "high")
studies <- studies |>
  mutate(quality = factor(quality, levels = quality_levels),
         design  = factor(design))

# --- Evidence map: joint (y) x intervention (x), point = a study ---
# size ~ sample size (NA -> small default), colour = study quality,
# shape = design (RCT vs observational)
p <- ggplot(studies,
            aes(x = intervention, y = joint,
                size = ifelse(is.na(n), 8, n),
                colour = quality,
                shape = design)) +
  geom_jitter(width = 0.12, height = 0.12, alpha = 0.85) +
  scale_size_continuous(name = "Sample size (N)", range = c(3, 10)) +
  labs(
    title = "Regenerative injections for joint hypermobility: evidence map",
    subtitle = "Each point = one study. Gaps show where evidence is missing.",
    x = "Intervention", y = "Joint",
    colour = "Study quality", shape = "Design",
    caption = "Descriptive map only; see 01_meta_analysis.R for the poolable subset."
  ) +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

# --- Simple count summaries ---
by_design <- studies |> count(design, name = "n_studies")
by_joint  <- studies |> count(joint,  name = "n_studies")
print(by_design)
print(by_joint)

# --- Save outputs ---
# Figures -> outputs/ (git-ignored); script-generated tables -> data/processed/.
dir.create("outputs", showWarnings = FALSE)
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
ggsave("outputs/evidence_map.png", p, width = 9, height = 5, dpi = 150)
write_csv(by_joint,  "data/processed/summary_by_joint.csv")
write_csv(by_design, "data/processed/summary_by_design.csv")

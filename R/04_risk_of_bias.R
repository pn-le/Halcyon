# 04_risk_of_bias.R  —  risk-of-bias traffic-light plot
# ---------------------------------------------------------------------
# Renders figures/rob.png from data/raw/rob.csv. Domain-level judgments
# (RoB 2 for the RCTs; ROBINS-I for observational studies) require reading
# each full text and are a human appraisal step (done in Cowork). While any
# judgment is still "TODO", this script SKIPS rendering rather than guessing.
#
# Fill each domain cell with one of: "Low", "Some concerns", "High",
# "No information" (ROB2) / "Low", "Moderate", "Serious", "Critical",
# "No information" (ROBINS-I).

library(robvis)

rob_file <- "data/raw/rob.csv"
if (!file.exists(rob_file)) stop("Missing ", rob_file)
rob <- read.csv(rob_file, stringsAsFactors = FALSE)

# Focus the traffic-light plot on the controlled trials (RoB 2), where a
# formal RoB assessment is most meaningful.
rcts <- rob[rob$tool == "ROB2", ]
domain_cols <- c("d1", "d2", "d3", "d4", "d5", "overall")
todo <- any(vapply(rcts[domain_cols], function(x)
  any(toupper(trimws(x)) == "TODO"), logical(1)))

if (nrow(rcts) == 0 || todo) {
  message("\n[SKIP] R/04_risk_of_bias.R: RoB judgments not yet filled.\n",
          "       Code each domain in ", rob_file,
          " (RoB 2 for the RCTs) from the full texts.\n",
          "       (No figure written — appraisal must not be guessed.)")
} else {
  rob_df <- data.frame(
    Study   = rcts$study,
    D1 = rcts$d1, D2 = rcts$d2, D3 = rcts$d3, D4 = rcts$d4, D5 = rcts$d5,
    Overall = rcts$overall,
    stringsAsFactors = FALSE
  )

  dir.create("outputs", showWarnings = FALSE)
  tl <- rob_traffic_light(data = rob_df, tool = "ROB2", psize = 10)
  ggplot2::ggsave("outputs/rob.png", tl, width = 8, height = 6, dpi = 150)
  message("Wrote outputs/rob.png")
}

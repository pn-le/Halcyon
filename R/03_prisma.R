# 03_prisma.R  —  PRISMA 2020 flow diagram
# ---------------------------------------------------------------------
# Renders figures/prisma.png from the editable counts in
# data/raw/prisma_counts.csv. The counts are the record funnel from the
# literature search (identification -> screening -> inclusion) and must be
# supplied from the actual search log (done in Cowork). While any count is
# still "TODO", this script SKIPS rendering rather than inventing a funnel.

library(PRISMA2020)

counts_file <- "data/raw/prisma_counts.csv"
if (!file.exists(counts_file)) stop("Missing ", counts_file)
counts <- read.csv(counts_file, stringsAsFactors = FALSE)

# --- Guard: refuse to render a fabricated funnel ----------------------
todo <- counts$key[toupper(trimws(counts$count)) == "TODO" |
                     is.na(suppressWarnings(as.numeric(counts$count)))]
if (length(todo)) {
  message("\n[SKIP] R/03_prisma.R: PRISMA counts not yet filled.\n",
          "       Fill these keys in ", counts_file, " from the search log:\n",
          "         ", paste(todo, collapse = ", "), "\n",
          "       (No figure written — funnel numbers must not be invented.)")
} else {
  n <- setNames(as.numeric(counts$count), counts$key)

  # Map our counts onto the PRISMA2020 template identifiers.
  tmpl <- read.csv(system.file("extdata", "PRISMA.csv", package = "PRISMA2020"),
                   stringsAsFactors = FALSE)
  set_n <- function(id, value) tmpl$n[tmpl$data == id & !is.na(tmpl$data)] <<- value
  set_n("previous_studies",        0)
  set_n("previous_reports",        0)
  set_n("database_results",        n["database_records"])
  set_n("register_results",        n["register_records"])
  set_n("duplicates",              n["duplicates_removed"])
  set_n("records_screened",        n["records_screened"])
  set_n("records_excluded",        n["records_excluded"])
  set_n("dbr_sought_reports",      n["fulltext_sought"])
  set_n("dbr_notretrieved_reports", n["fulltext_not_retrieved"])
  set_n("dbr_assessed",            n["fulltext_assessed"])
  set_n("dbr_excluded",            n["fulltext_excluded"])
  set_n("new_studies",             n["studies_included"])
  set_n("new_reports",             0)
  set_n("total_studies",           n["studies_included"])
  set_n("total_reports",           0)

  data <- PRISMA_data(tmpl)
  plot <- PRISMA_flowdiagram(data,
                             interactive = FALSE,
                             previous = FALSE,
                             other = FALSE)

  dir.create("outputs", showWarnings = FALSE)
  PRISMA_save(plot, "outputs/prisma.png", filetype = "PNG", overwrite = TRUE)
  message("Wrote outputs/prisma.png")
}

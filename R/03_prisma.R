# 03_prisma.R  —  PRISMA 2020 flow diagram
# ---------------------------------------------------------------------
# Renders figures/prisma.png from the editable counts in
# data/raw/prisma_counts.csv (the record funnel: identification ->
# screening -> inclusion), supplied from the actual search log (Cowork).
#
# Uses the official PRISMA2020 renderer when pandoc is available (e.g. inside
# RStudio), and a dependency-free ggplot2 fallback otherwise, so the figure
# builds in any environment. While any count is still "TODO", it SKIPS
# rather than inventing a funnel.

counts_file <- "data/raw/prisma_counts.csv"
if (!file.exists(counts_file)) stop("Missing ", counts_file)
counts <- read.csv(counts_file, stringsAsFactors = FALSE)

todo <- counts$key[toupper(trimws(counts$count)) == "TODO" |
                     is.na(suppressWarnings(as.numeric(counts$count)))]
if (length(todo)) {
  message("\n[SKIP] R/03_prisma.R: PRISMA counts not yet filled.\n",
          "       Fill these keys in ", counts_file, ":\n         ",
          paste(todo, collapse = ", "))
} else {
  n <- setNames(as.numeric(counts$count), counts$key)
  dir.create("outputs", showWarnings = FALSE)

  has_pandoc <- requireNamespace("rmarkdown", quietly = TRUE) &&
    rmarkdown::pandoc_available()
  use_official <- requireNamespace("PRISMA2020", quietly = TRUE) && has_pandoc

  if (use_official) {
    library(PRISMA2020)
    tmpl <- read.csv(system.file("extdata", "PRISMA.csv", package = "PRISMA2020"),
                     stringsAsFactors = FALSE)
    set_n <- function(id, value) tmpl$n[tmpl$data == id & !is.na(tmpl$data)] <<- value
    set_n("previous_studies", 0);          set_n("previous_reports", 0)
    set_n("database_results", n["database_records"])
    set_n("register_results", n["register_records"])
    set_n("duplicates", n["duplicates_removed"])
    set_n("records_screened", n["records_screened"])
    set_n("records_excluded", n["records_excluded"])
    set_n("dbr_sought_reports", n["fulltext_sought"])
    set_n("dbr_notretrieved_reports", n["fulltext_not_retrieved"])
    set_n("dbr_assessed", n["fulltext_assessed"])
    set_n("dbr_excluded", n["fulltext_excluded"])
    set_n("new_studies", n["studies_included"]); set_n("new_reports", 0)
    set_n("total_studies", n["studies_included"]); set_n("total_reports", 0)
    data <- PRISMA_data(tmpl)
    plot <- PRISMA_flowdiagram(data, interactive = FALSE, previous = FALSE, other = FALSE)
    PRISMA_save(plot, "outputs/prisma.png", filetype = "PNG", overwrite = TRUE)
    message("Wrote outputs/prisma.png (PRISMA2020)")
  } else {
    # ---- dependency-free ggplot2 fallback ----------------------------
    library(ggplot2)
    box <- function(x, y, label) data.frame(x = x, y = y, label = label)
    boxes <- rbind(
      box(1, 6, sprintf("Records identified\n(databases n=%g; registers n=%g)",
                        n["database_records"], n["register_records"])),
      box(1, 5, sprintf("After duplicates removed\n(n=%g)", n["records_screened"])),
      box(1, 4, sprintf("Records screened\n(n=%g)", n["records_screened"])),
      box(1, 3, sprintf("Full-text assessed\n(n=%g)", n["fulltext_assessed"])),
      box(1, 2, sprintf("Studies included\n(n=%g)", n["studies_included"])),
      box(3, 4, sprintf("Excluded at screening\n(n=%g)", n["records_excluded"])),
      box(3, 3, sprintf("Full-text excluded\n(n=%g)", n["fulltext_excluded"]))
    )
    hw <- 0.92; hh <- 0.36
    arrows_main <- data.frame(x = 1, xend = 1, y = c(6,5,4,3) - hh, yend = c(5,4,3,2) + hh)
    arrows_side <- data.frame(x = 1 + hw, xend = 3 - hw, y = c(4,3), yend = c(4,3))
    p <- ggplot() +
      geom_rect(data = boxes,
                aes(xmin = x - hw, xmax = x + hw, ymin = y - hh, ymax = y + hh),
                fill = "grey96", colour = "grey40") +
      geom_text(data = boxes, aes(x, y, label = label), size = 3.2, lineheight = 0.95) +
      geom_segment(data = arrows_main, aes(x, y, xend = xend, yend = yend),
                   arrow = arrow(length = unit(0.16, "cm")), colour = "grey40") +
      geom_segment(data = arrows_side, aes(x, y, xend = xend, yend = yend),
                   arrow = arrow(length = unit(0.16, "cm")), colour = "grey40") +
      coord_cartesian(xlim = c(-0.1, 4.1), ylim = c(1.4, 6.7)) +
      labs(title = "PRISMA flow (preliminary, scoping-level)") +
      theme_void(base_size = 12) +
      theme(plot.title = element_text(hjust = 0.5, size = 12))
    ggsave("outputs/prisma.png", p, width = 7.5, height = 6, dpi = 150, bg = "white")
    message("Wrote outputs/prisma.png (ggplot fallback — no pandoc)")
  }
}

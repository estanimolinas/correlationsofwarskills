#!/usr/bin/env Rscript
# 03_cross_national.R — snapshot-year cross-national comparison.
#
# Plots total_use in a chosen year for all states in the international system,
# sorted by adoption level. Uses a dot plot (cleaner than bars for ranked data).

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(ggplot2)
})

SNAPSHOT_YEAR <- 1950  # change to inspect another year

data_dir <- Sys.getenv("COW_ARMS_DATA_DIR",
                       unset = file.path("..", "..", "..", "..", "ArmsTechnologyV1"))

snap <- read_csv(file.path(data_dir, "cow_arms_tech_wide.csv"),
                 show_col_types = FALSE) |>
  filter(year == SNAPSHOT_YEAR, !is.na(total_use)) |>
  arrange(total_use) |>
  mutate(statename = factor(statename, levels = statename))

p <- ggplot(snap, aes(total_use, statename)) +
  geom_point(size = 1.4, color = "#0072B2") +
  geom_segment(aes(x = 0, xend = total_use, y = statename, yend = statename),
               color = "grey70", linewidth = 0.3) +
  scale_x_continuous(limits = c(0, 29), breaks = seq(0, 29, 5)) +
  labs(x = paste0("total_use in ", SNAPSHOT_YEAR, " (0–29)"),
       y = NULL,
       caption = "Source: COW Arms Technology Data Set v1.0 (Hariri & Wingender 2025).") +
  theme_minimal(base_size = 8) +
  theme(panel.grid.minor = element_blank(),
        axis.text.y = element_text(size = 6),
        plot.caption = element_text(size = 8, face = "italic", hjust = 0))

dir.create("output", showWarnings = FALSE)
ggsave(sprintf("output/figure_crossnational_%d.pdf", SNAPSHOT_YEAR), p,
       width = 7.2, height = 9.0, device = cairo_pdf)
cat(sprintf("Wrote output/figure_crossnational_%d.pdf — %d states\n",
            SNAPSHOT_YEAR, nrow(snap)))

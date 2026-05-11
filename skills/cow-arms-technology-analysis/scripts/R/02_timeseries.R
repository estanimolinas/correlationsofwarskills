#!/usr/bin/env Rscript
# 02_timeseries.R — publication-ready total_use trajectories for major powers.
#
# Codebook §3.1: total_use is the count of arms technologies coded 1 (in use) or
# 9 (superseded by a same-category superior). It is described as "a simple, ordinal
# measure of the arms technology level in a country." Disclose in methods.
#
# Adoption is a step function — use geom_step(), not geom_line().

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(ggplot2)
})

data_dir <- Sys.getenv("COW_ARMS_DATA_DIR",
                       unset = file.path("..", "..", "..", "..", "ArmsTechnologyV1"))

panel <- read_csv(file.path(data_dir, "cow_arms_tech_wide.csv"),
                  show_col_types = FALSE) |>
  filter(ccode %in% c(2, 365, 710), year >= 1900, year <= 2023) |>
  mutate(country = recode(statename,
                          "United States of America" = "United States",
                          "Russia"                   = "Russia / Soviet Union"))

okabe_ito <- c("United States"        = "#0072B2",
               "Russia / Soviet Union" = "#D55E00",
               "China"                = "#009E73")

p <- ggplot(panel, aes(year, total_use, color = country, linetype = country)) +
  geom_step(linewidth = 0.7, direction = "hv") +
  geom_hline(yintercept = 29, linetype = "dotted", color = "grey50", linewidth = 0.3) +
  annotate("text", x = 2023, y = 29.4, label = "Sample ceiling (29 techs)",
           hjust = 1, size = 2.8, color = "grey40") +
  scale_y_continuous(limits = c(0, 30), breaks = seq(0, 29, 5)) +
  scale_x_continuous(breaks = seq(1900, 2020, 20)) +
  scale_color_manual(values = okabe_ito) +
  scale_linetype_manual(values = c("United States" = "solid",
                                   "Russia / Soviet Union" = "dashed",
                                   "China" = "dotdash")) +
  labs(x = "Year",
       y = "Adopted or superseded technologies (total_use, 0–29)",
       color = NULL, linetype = NULL,
       caption = "Source: COW Arms Technology Data Set v1.0 (Hariri & Wingender 2025).") +
  theme_minimal(base_size = 10) +
  theme(panel.grid.minor = element_blank(),
        legend.position = "bottom",
        legend.background = element_blank(),
        plot.caption = element_text(size = 8, face = "italic", hjust = 0))

dir.create("output", showWarnings = FALSE)
ggsave("output/figure_timeseries.pdf", p, width = 7.2, height = 4.4, device = cairo_pdf)
ggsave("output/figure_timeseries.png", p, width = 7.2, height = 4.4, dpi = 600)
cat("Wrote output/figure_timeseries.{pdf,png}\n")

#!/usr/bin/env Rscript
# 04_scatter_trend.R — scatter of total_use against system-mean lag, with trend.
#
# A self-contained example that does not require merging external data: plots
# each country's total_use in 2023 against the year it first reached total_use
# >= 10 (a "modernization year" — half the sample). For an actual paper, you'd
# merge in GDP, regime type, military expenditure, etc., and overlay LOESS.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(ggplot2)
})

data_dir <- Sys.getenv("COW_ARMS_DATA_DIR",
                       unset = file.path("..", "..", "..", "..", "ArmsTechnologyV1"))

wide <- read_csv(file.path(data_dir, "cow_arms_tech_wide.csv"),
                 show_col_types = FALSE)

# First year the country reaches total_use >= 10
first_modern <- wide |>
  filter(total_use >= 10) |>
  group_by(ccode, statename) |>
  summarise(first_year_10 = min(year), .groups = "drop")

snap_2023 <- wide |>
  filter(year == 2023) |>
  select(ccode, statename, total_use_2023 = total_use)

joined <- inner_join(first_modern, snap_2023, by = c("ccode", "statename")) |>
  filter(!is.na(total_use_2023))

p <- ggplot(joined, aes(first_year_10, total_use_2023)) +
  geom_point(alpha = 0.6, color = "#0072B2", size = 1.4) +
  geom_smooth(method = "loess", se = TRUE, color = "#D55E00",
              fill = "#D55E00", alpha = 0.15, formula = y ~ x) +
  scale_y_continuous(limits = c(0, 29)) +
  labs(x = "Year country first reached total_use ≥ 10",
       y = "total_use in 2023 (0–29)",
       caption = "Source: COW Arms Technology Data Set v1.0 (Hariri & Wingender 2025). LOESS smoother shown for visualization only.") +
  theme_minimal(base_size = 10) +
  theme(panel.grid.minor = element_blank(),
        plot.caption = element_text(size = 8, face = "italic", hjust = 0))

dir.create("output", showWarnings = FALSE)
ggsave("output/figure_scatter_trend.pdf", p, width = 7.2, height = 4.4, device = cairo_pdf)
cat(sprintf("Wrote output/figure_scatter_trend.pdf — %d states\n", nrow(joined)))

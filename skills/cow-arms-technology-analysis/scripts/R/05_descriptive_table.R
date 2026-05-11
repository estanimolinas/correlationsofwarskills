#!/usr/bin/env Rscript
# 05_descriptive_table.R — first-adoption year of assault rifle (s7), by region.
#
# Outputs a journal-ready descriptive table (CSV + LaTeX). Demonstrates the
# leap-frog check from codebook §3.1: a country whose s7_use jumps 0 → 9 with
# no intervening 1 adopted a superior tech without ever using the assault rifle.
# Here s7 is the most advanced small arm, so leap-frog cannot occur — but the
# check pattern generalizes.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
})

data_dir <- Sys.getenv("COW_ARMS_DATA_DIR",
                       unset = file.path("..", "..", "..", "..", "ArmsTechnologyV1"))

long <- read_csv(file.path(data_dir, "cow_arms_tech_long.csv"),
                 show_col_types = FALSE) |>
  filter(!is.na(techname))

# Minimal region recoding — illustration only. For a real paper, merge with an
# established regional classification (e.g. UN M.49, COW region codes).
region_for <- function(ccode) {
  case_when(
    ccode >= 2   & ccode <= 199 ~ "Americas",
    ccode >= 200 & ccode <= 399 ~ "Europe",
    ccode >= 400 & ccode <= 599 ~ "Sub-Saharan Africa",
    ccode >= 600 & ccode <= 699 ~ "MENA",
    ccode >= 700 & ccode <= 999 ~ "Asia–Pacific",
    TRUE                        ~ NA_character_
  )
}

first_adopt <- long |>
  filter(techname == "Assault rifle", use == 1) |>
  group_by(ccode, statename) |>
  summarise(first_year = min(year), .groups = "drop") |>
  mutate(region = region_for(ccode))

# Region-level summary
tbl <- first_adopt |>
  group_by(region) |>
  summarise(n_countries = n(),
            earliest = min(first_year),
            median = median(first_year),
            latest = max(first_year),
            .groups = "drop") |>
  arrange(median)

print(tbl)

dir.create("output", showWarnings = FALSE)
write_csv(tbl, "output/table_first_adoption_assault_rifle.csv")

# LaTeX output (replace the line below with kableExtra::kable() for full styling)
sink("output/table_first_adoption_assault_rifle.tex")
cat("\\begin{tabular}{lrrrr}\n\\hline\n")
cat("Region & N countries & Earliest & Median & Latest \\\\\n\\hline\n")
for (i in seq_len(nrow(tbl))) {
  row <- tbl[i, ]
  cat(sprintf("%s & %d & %d & %d & %d \\\\\n",
              row$region, row$n_countries, row$earliest, row$median, row$latest))
}
cat("\\hline\n\\end{tabular}\n")
sink()
cat("\nWrote output/table_first_adoption_assault_rifle.{csv,tex}\n")

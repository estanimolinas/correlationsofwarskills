#!/usr/bin/env Rscript
# 01_load_and_clean.R — load COW Arms Tech, filter to a country-year subset, sanity-check.
#
# Codebook: ArmsTechnologyV1/CoW_codebook.pdf §§2–3.1 (Hariri & Wingender 2025).
# Missing values are `.` in Stata, parsed to NA on CSV import — do NOT pass na = "-9".
#
# Usage:
#   export COW_ARMS_DATA_DIR=/path/to/ArmsTechnologyV1
#   Rscript 01_load_and_clean.R
# (Without the env var, falls back to ../../ArmsTechnologyV1 relative to this script.)

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
})

data_dir <- Sys.getenv("COW_ARMS_DATA_DIR",
                       unset = file.path("..", "..", "..", "..", "ArmsTechnologyV1"))
wide_path <- file.path(data_dir, "cow_arms_tech_wide.csv")

stopifnot(file.exists(wide_path))
wide <- read_csv(wide_path, show_col_types = FALSE)

# Major-power illustration: US (2), Russia/USSR (365), China (710).
panel <- wide |>
  filter(ccode %in% c(2, 365, 710), year >= 1900, year <= 2023) |>
  select(ccode, statename, year, total_use, version)

cat("Rows: ", nrow(panel), "\n")
cat("Missing total_use: ", sum(is.na(panel$total_use)), "\n")
cat("Range of total_use: ",
    paste(range(panel$total_use, na.rm = TRUE), collapse = "–"), "\n\n")

# Per-country summary
panel |>
  group_by(statename) |>
  summarise(n_years = n(),
            n_missing = sum(is.na(total_use)),
            first_year = min(year),
            last_year = max(year),
            mean_total_use = round(mean(total_use, na.rm = TRUE), 2),
            .groups = "drop") |>
  print()

# Save the cleaned subset for downstream scripts.
dir.create("output", showWarnings = FALSE)
write_csv(panel, "output/panel_majors_1900_2023.csv")
cat("\nWrote output/panel_majors_1900_2023.csv\n")

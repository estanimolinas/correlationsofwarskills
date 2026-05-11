# Worked example 3 — First-adoption descriptive table for one technology

**Research question:** Build a journal-ready descriptive table showing first-adoption year of a single technology (assault rifles, `s7_use`) across regions. This is the canonical "Table 1" of a diffusion paper that uses one technology as the focal case.

**What this example teaches:**
- Constructing a descriptive table that survives reviewer scrutiny
- Choosing between region operationalizations (and disclosing the choice)
- Reporting medians and ranges, not just means
- LaTeX export with a publication-ready note line
- Cross-checking against the codebook's historical narrative (§4) for sanity

## Step 1 — Build the first-adoption series

Using the inclusive definition from the diffusion-lag example (`use %in% c(1, 9)`) so leap-froggers aren't dropped:

```r
library(readr); library(dplyr)
long <- read_csv(file.path(Sys.getenv("COW_ARMS_DATA_DIR"),
                            "cow_arms_tech_long.csv")) |>
  filter(!is.na(techname))

first_s7 <- long |>
  filter(techname == "Assault rifle", use %in% c(1, 9)) |>
  group_by(ccode, statename) |>
  summarise(first_year = min(year), .groups = "drop")
```

(Since `s7` is the most advanced small arm in the dataset, `use == 9` cannot occur — the inclusive definition collapses to strict here. The pattern still generalizes to other technologies.)

## Step 2 — Region assignment

**Reviewer note:** ccode-range bins are convenient but coarse and politically arbitrary. For a publishable paper, merge against an established classification:

- **COW regions** (from State System Membership v2016)
- **UN M.49** geographic regions
- **World Bank** regional groupings

The script `scripts/R/05_descriptive_table.R` uses ccode bins as a *placeholder* for illustration. Replace with a real classification before submitting. State which one in the table note.

Example using ccode bins (illustrative only):

```r
first_s7 <- first_s7 |>
  mutate(region = case_when(
    ccode >= 2   & ccode <= 199 ~ "Americas",
    ccode >= 200 & ccode <= 399 ~ "Europe",
    ccode >= 400 & ccode <= 599 ~ "Sub-Saharan Africa",
    ccode >= 600 & ccode <= 699 ~ "MENA",
    ccode >= 700 & ccode <= 999 ~ "Asia–Pacific"
  ))
```

## Step 3 — Aggregate

```r
tbl <- first_s7 |>
  group_by(region) |>
  summarise(n_countries = n(),
            earliest = min(first_year),
            median = median(first_year),
            latest = max(first_year),
            .groups = "drop") |>
  arrange(median)
```

Report:
- **N countries** — the denominator. A reviewer will check this against COW membership counts.
- **Earliest** — the regional first-mover. Sanity-check against codebook §4 if it predates the technology's invention.
- **Median** — the central tendency. Robust to outliers, preferred over mean for first-adoption-year data which can be heavily skewed by late entrants.
- **Latest** — the regional laggard, or the latest year in the dataset (2023) if some states still have not adopted. Distinguish these in the table note.

## Step 4 — Export to LaTeX

```r
library(kableExtra)
tbl |>
  kable(format = "latex", booktabs = TRUE,
        col.names = c("Region", "N countries", "Earliest", "Median", "Latest"),
        caption = "First-adoption year of assault rifle (s7\\_use), by region.",
        label = "first_s7") |>
  kable_styling(latex_options = c("hold_position")) |>
  footnote(general = paste(
    "First-adoption year defined as the earliest year with use $\\in \\{1, 9\\}$",
    "for the assault rifle (s7\\_use) per the COW Arms Technology Dataset v1.0",
    "(Hariri \\& Wingender 2025). Regions assigned by ccode range — illustrative",
    "only; replace with UN M.49 or COW regions for publication. Countries that",
    "have not adopted by 2023 are coded as 2023 in this column."
  ), threeparttable = TRUE)
```

In Python, use `pd.DataFrame.to_latex()` plus a manual note line, or the `pylatex` / `tabulate` packages.

## Step 5 — Sanity check against the codebook

Codebook §4 dates the assault rifle to "the Sturmgewehr 44, developed in Nazi Germany towards the end of World War II." The earliest first-adoption year in any region should not be before 1944. If it is, you have a data issue — recheck the filtering. (Spoiler: it shouldn't be; the data are clean.)

A *secondary* sanity check: footnote 4 (codebook §5) notes "Assault rifles were universally adopted by 1990" as a simplifying assumption for the data sources section. The dataset itself codes adoption year by year and does not assume universality — but if your "latest" column shows post-1990 first adoptions, decide whether those reflect real late adopters or coding ambiguity for tiny militaries, and disclose.

## Output

The table goes in the paper as Table 1 of the empirics section, paired with one or two sentences interpreting the regional ordering. Save:

- `output/table_first_adoption_assault_rifle.csv`
- `output/table_first_adoption_assault_rifle.tex`

For replication appendix: also save the row-level first-adoption data (one row per country) so reviewers can recompute the aggregates.

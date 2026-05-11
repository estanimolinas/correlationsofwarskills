# Worked example 1 — The great-power technology gap, 1816–2023

**Research question:** How does the gap in arms technology adoption between major powers and the rest of the international system evolve across the long nineteenth and twentieth centuries?

**What this example teaches:**
- Using the wide format for system-wide aggregation
- Defining a "major powers" set (one defensible operationalization, others discussed)
- Plotting two summary series (major-power mean vs. system mean) with a labeled gap region
- Disclosing the 29-tech sample ceiling so readers don't over-interpret modern convergence

## Step 1 — Define majors

Use COW's Major Powers list. The set changes over time; for this example, hold it constant at the post-1945 set: USA (2), UK (200), France (220), Germany (255), Russia/USSR (365), China (710). For a paper, you'd time-vary it; that's a one-line extension.

## Step 2 — Compute the two series

Long-format aggregation is unnecessary here because `total_use` is already in wide. Compute the unweighted mean of `total_use` per year for (a) the major-power set and (b) the rest of the system.

**R:**
```r
library(readr); library(dplyr)
wide <- read_csv(file.path(Sys.getenv("COW_ARMS_DATA_DIR"),
                            "cow_arms_tech_wide.csv"))

majors <- c(2, 200, 220, 255, 365, 710)
series <- wide |>
  mutate(group = if_else(ccode %in% majors, "Majors", "Rest of system")) |>
  filter(!is.na(total_use)) |>
  group_by(year, group) |>
  summarise(mean_total_use = mean(total_use),
            n = n(),
            .groups = "drop")
```

**Python:**
```python
import os, pandas as pd
wide = pd.read_csv(f"{os.environ['COW_ARMS_DATA_DIR']}/cow_arms_tech_wide.csv")

majors = [2, 200, 220, 255, 365, 710]
wide["group"] = wide["ccode"].isin(majors).map({True: "Majors", False: "Rest of system"})
series = (
    wide.dropna(subset=["total_use"])
    .groupby(["year", "group"])
    .agg(mean_total_use=("total_use", "mean"), n=("total_use", "size"))
    .reset_index()
)
```

## Step 3 — Plot the gap

Use a two-line time-series, fill the area between to visualize the gap. Step plots remain appropriate at the aggregate level (each country's contribution is a step function; the mean is then a step-like trace).

Key axis decisions:
- y range 0–29 with explicit ceiling annotation
- Add a vertical line at 1945 (the year your majors set was defined for) — but note this is descriptive, not a structural break
- Caption: spell out which states are in "Majors" and that the set is held constant

## Step 4 — Caveats to disclose in the paper

1. **The 29-tech ceiling** — both lines asymptote toward 29 in the late period because that's the sample, not the universe of arms tech. State this in the caption and methods.
2. **Major-power set definition** — different defensible sets (with Japan, with India, without UK after Suez) produce different gaps. Run sensitivity.
3. **System composition changes** — the "rest of system" denominator grows from ~30 states in 1816 to ~190 today; decolonization in particular adds many low-`total_use` states in 1960. The gap widens partly because new entrants start low. Show a parallel plot using only continuously-existing states for the methods appendix.
4. **`total_use` is ordinal, not cardinal** — averaging it implicitly treats one-unit gaps as comparable. Acknowledge.

## Output

The plot belongs in the paper as Figure 1 or 2 of an introductory section. Pair with a single sentence interpretation: "Major powers maintain a roughly N-technology lead over the rest of the system from year X to year Y; the gap closes (or narrows / persists) after Z."

Avoid causal language unless the paper has the design to support it.

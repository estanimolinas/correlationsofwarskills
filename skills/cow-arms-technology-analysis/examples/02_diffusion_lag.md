# Worked example 2 — Diffusion lag from invention to adoption

**Research question:** How long, on average, does it take for an arms technology to diffuse from the first adopter to the median state in the international system, and how has that lag changed across technology categories?

**What this example teaches:**
- Using the long format because the unit of observation is the technology, not the country
- Computing first-adoption year per `(techname)` and per `(ccode, techname)`
- Aggregating into per-technology diffusion distributions
- Handling the `9` (superseded) value: a country may "adopt" by skipping straight to a newer in-category tech; decide whether that counts as adoption for the lag measure
- Faceting by `techtype` for visual comparison

## Step 1 — Load long format and filter

```python
import os, pandas as pd
long = pd.read_csv(f"{os.environ['COW_ARMS_DATA_DIR']}/cow_arms_tech_long.csv")
long = long[long["techname"].notna()]      # drop total_use rows
```

```r
library(readr); library(dplyr)
long <- read_csv(file.path(Sys.getenv("COW_ARMS_DATA_DIR"),
                            "cow_arms_tech_long.csv")) |>
  filter(!is.na(techname))
```

## Step 2 — Decide what "adoption" means

Two defensible definitions:

| Definition | Operationalization | When to use |
|------------|--------------------|-------------|
| **Strict** | First year `use == 1` | "When did the country actually field this technology?" |
| **Inclusive** | First year `use %in% c(1, 9)` | "When did the country reach this category's frontier or beyond?" |

The strict definition undercounts leap-froggers (countries that skipped a generation by adopting the next one). The inclusive definition treats leap-froggers as having adopted the prior tech at the year they actually adopted the superior tech.

For diffusion *lag* — how long until each country reaches at least this technology level — the inclusive definition is usually preferable. The skipped tech was "covered" by something better at that moment.

```python
adopt = (
    long.loc[long["use"].isin([1, 9])]
    .groupby(["ccode", "statename", "techname", "techtype"])["year"].min()
    .reset_index(name="adoption_year")
)
```

```r
adopt <- long |>
  filter(use %in% c(1, 9)) |>
  group_by(ccode, statename, techname, techtype) |>
  summarise(adoption_year = min(year), .groups = "drop")
```

## Step 3 — Compute lag from technology-first adoption

For each technology, the *system-first* adopter sets the clock. Per the codebook, this should match the historical invention/first-use year listed in §4 — sanity-check this.

```python
first_anywhere = (
    adopt.groupby(["techname", "techtype"])["adoption_year"].min()
    .reset_index(name="first_anywhere")
)
adopt = adopt.merge(first_anywhere, on=["techname", "techtype"])
adopt["lag_years"] = adopt["adoption_year"] - adopt["first_anywhere"]
```

## Step 4 — Summarize per technology and per category

```python
per_tech = (
    adopt.groupby(["techname", "techtype"])["lag_years"]
    .agg(n_adopters="count", median_lag="median",
         p25=lambda s: s.quantile(0.25), p75=lambda s: s.quantile(0.75))
    .reset_index()
    .sort_values("median_lag")
)
print(per_tech.to_string(index=False))
```

## Step 5 — Visualize

Two strong plots for this question:

1. **Boxplot or beeswarm of lag distribution per technology**, faceted by `techtype`. Order technologies within each facet by chronology (s1, s2, s3, ...). Watch the y-axis: lags can run into the hundreds of years for early small arms in late-joining states (decolonization-era arrivals in 1960+ inherit modern techs straight away).

2. **Line plot of median lag by technology category against the technology's "first anywhere" year**, showing whether modern technologies diffuse faster than historical ones (the common finding — but check before claiming).

Step plots are not appropriate here; this is a distribution-over-units summary, not a state-year trajectory.

## Caveats to disclose

1. **State-system entry effects** — A state that joined COW in 1960 cannot have adopted flintlock muskets in the 1700s. Its lag for `s1` (flintlock musket) is meaningless. Restrict the technology-by-technology analysis to states that were in the system at least N years before the technology was first adopted.
2. **The 500K population floor** — Codebook §2 excludes states under 500K (2016). Small-state diffusion is not in the dataset; do not claim universal coverage.
3. **The leap-frog question is substantive** — A reviewer may ask for both the strict and inclusive definitions side by side. Be ready.
4. **`use == 9` semantics** — recall that `9` means "a superior same-category tech has been adopted." It does not mean "this country once used the prior tech." Some leap-froggers genuinely never used the prior generation; the inclusive definition above is a measurement choice, not a claim of fact.

## Output

This analysis usually anchors the empirics section of a diffusion paper. Pair the per-technology table with one facet plot. Save:

- `output/diffusion_lag_per_tech.csv` — the per-technology summary
- `output/figure_diffusion_lag_facets.pdf` — the faceted distribution plot

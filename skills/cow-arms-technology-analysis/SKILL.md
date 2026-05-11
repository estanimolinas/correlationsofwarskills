---
name: cow-arms-technology-analysis
description: Use when analyzing the Correlates of War Arms Technology Dataset v1.0 (Hariri & Wingender 2025) for IR research — loading cow_arms_tech_long.csv or cow_arms_tech_wide.csv, plotting total_use or per-technology trajectories, comparing arms adoption across states/years, producing publication-ready figures and descriptive tables for IR journal articles, citing the dataset, or handling COW state-system conventions (Russia/USSR continuity, China/Taiwan split, Germany reunification).
---

# COW Arms Technology Analysis

Three-tier reference for IR researchers (PhD and Master's students) working with the Correlates of War Arms Technology Dataset v1.0 — Tier 1 data cleaning, Tier 2 publication-ready visualization in R/ggplot2 and Python/pandas/matplotlib, Tier 3 descriptive tables and figure references for IR papers.

**Core principle:** every column name, code value, and convention in this skill is grounded in the dataset's codebook (`ArmsTechnologyV1/CoW_codebook.pdf`). Cite the codebook section when the convention is non-obvious; do not infer behavior from variable names alone.

## When to use

- Loading `cow_arms_tech_long.csv` or `cow_arms_tech_wide.csv` for the first time
- Producing a time-series of `total_use` for one or more countries
- Comparing technology adoption across states, years, or tech categories
- Computing diffusion lags, first-adoption years, or cross-national summary statistics
- Drafting figure captions, descriptive tables, or methods sections that reference this dataset

**Do not use** for: COW datasets other than Arms Technology v1.0 (Material Capabilities, MIDs, etc. have different conventions); the war/dispute datasets in the COW family.

## Setup

Point the scripts at the data directory. The dataset is in this repo at `ArmsTechnologyV1/`; if you've copied the skill to `~/.claude/skills/`, set the path to wherever you put the CSVs.

```bash
# Bash — set once per shell session
export COW_ARMS_DATA_DIR=/path/to/ArmsTechnologyV1
```

R and Python scripts read this env var with a sensible local fallback. Each runnable script in `scripts/` is self-contained — clone, set the path, run.

## The coding scheme (read this first)

Per codebook §3.1, every `prefix_use` variable (e.g. `s4_use` for breechloading rifle) takes one of four values:

| Value | Meaning |
|-------|---------|
| `0` | Not used in the given year, nor any prior year, and not superseded |
| `1` | Used currently or in any prior year, and not superseded |
| `9` | A superior technology in the same category has been adopted (may or may not still be in use) |
| `.` (blank in CSV → `NaN` in pandas / `NA` in R) | Missing |

**Critical:** missing is `.` (Stata convention), **not** `-9`. pandas `read_csv` and R `readr::read_csv` both parse blank fields to `NaN`/`NA` automatically — do not pass `na_values=-9`.

**`total_use` counts both `1` and `9`** (codebook §3.1): a country at `total_use=29` may hold only the *superseded* versions of older technologies. `total_use` is `NaN` whenever any of the 29 individual `prefix_use` values is missing for that country-year.

**Leap-frog pattern:** a `0 → 9` transition with no intervening `1` means the country adopted a superior technology without ever using the prior generation. Use the long format and a `lag()`/`shift()` to detect.

## Wide vs long: pick before you load

Per codebook §3:

- **Wide** (`cow_arms_tech_wide.csv`, ~1.5 MB): one row per state-year, columns `s1_use`…`u1_use` plus `total_use`. **Use for:** country-year outcomes, `total_use` time-series, regressions where arms tech is the predictor.
- **Long** (`cow_arms_tech_long.csv`, ~33 MB): one row per state-year-technology triad, with `techname`, `techtype`, `use`. **Use for:** per-technology determinants, faceted plots by tech category, mixed-effects models with tech as a random effect.

When in doubt, start wide; reshape to long with `pivot_longer()` (R) or `melt()`/`pd.wide_to_long` (pandas) only when the analysis actually requires it.

## Tier 1 — Data cleaning

### Load + filter by country/year

**R (tidyverse):**
```r
library(readr); library(dplyr)
wide <- read_csv(file.path(Sys.getenv("COW_ARMS_DATA_DIR", "ArmsTechnologyV1"),
                            "cow_arms_tech_wide.csv"))
panel <- wide |>
  filter(ccode %in% c(2, 365, 710), year >= 1900, year <= 2023)
# 2 = USA, 365 = Russia/USSR, 710 = China (see references/codebook-conventions.md)
```

**Python (pandas):**
```python
import os, pandas as pd
data_dir = os.environ.get("COW_ARMS_DATA_DIR", "ArmsTechnologyV1")
wide = pd.read_csv(f"{data_dir}/cow_arms_tech_wide.csv")
panel = wide[wide["ccode"].isin([2, 365, 710]) & wide["year"].between(1900, 2023)]
```

**Do not** filter `total_use` for `total_use >= 0` to "drop missings" — that drops nothing (missings are NaN, not negative). Use `.dropna(subset=["total_use"])` (pandas) or `filter(!is.na(total_use))` (R) only if your specific analysis requires complete cases.

### COW state-system gotchas

Per the dataset's basis in COW State System Membership v2016:

| Country | ccode | Trap |
|---------|-------|------|
| Russia / Soviet Union | 365 | Single continuous entity 1816–present; no separate USSR entry |
| China | 710 | Qing → ROC (1912–1949) → PRC (1949–) coded as one entity |
| Taiwan | 713 | Inherits ROC seat 1949–; not the same series as China before 1949 |
| Germany | 255 | 1816–1945 and 1990–present; **GFR** is 260 (1955–1990), **GDR** is 265 (1949–1990) |
| Yemen | 678 / 680 / 679 | YAR (678, 1926–1990), Yemen PR (680, 1967–1990), Yemen unified (679, 1990–) |
| Vietnam | 816 / 817 | DRV/Vietnam (816, 1954–), RVN (817, 1954–1975) |
| Czechoslovakia / CZ / SK | 315 / 316 / 317 | CSK 1918–1992, Czech (316) and Slovakia (317) 1993– |

Full list and analytical workarounds: see `references/codebook-conventions.md`.

### Recoding ccodes to names

The `statename` column already provides the COW long name. Use it directly; only build a custom lookup if you need a different label (e.g. "Russia / Soviet Union" for a legend).

## Tier 2 — Publication-ready visualization

**Academic standards (enforced in all `scripts/` templates):**

- 300 dpi minimum for raster, 600 dpi preferred; export PDF (vector) for journal submission
- Single-column figure: 3.5″ wide; two-column / full-page: 7.0–7.2″ wide
- Sans-serif or serif consistent with the target journal; same font for axes, legend, title
- No chartjunk: drop top/right spines, no 3D, no drop shadows, no gridline overkill
- Colorblind-safe palette (Okabe-Ito or viridis); test by converting to grayscale
- Axes labeled with units and codebook variable name (e.g. `total_use (count of adopted or superseded technologies, 0–29)`)
- Source line in caption: `Source: COW Arms Technology Data Set v1.0 (Hariri & Wingender 2025).`

Full standards and rationale: `references/publication-standards.md`.

### Time series — minimal pattern

**R (ggplot2):** see `scripts/R/02_timeseries.R` for the full runnable version.
```r
library(ggplot2)
ggplot(panel, aes(year, total_use, color = statename)) +
  geom_step() +
  scale_y_continuous(limits = c(0, 29), breaks = seq(0, 29, 5)) +
  labs(x = "Year",
       y = "Adopted or superseded technologies (total_use, 0–29)",
       color = NULL,
       caption = "Source: COW Arms Technology Data Set v1.0 (Hariri & Wingender 2025).") +
  theme_minimal(base_size = 10) +
  theme(panel.grid.minor = element_blank(),
        legend.position = "bottom")
ggsave("figure.pdf", width = 7.2, height = 4.4, device = cairo_pdf)
```

**Python (matplotlib + pandas):** see `scripts/python/02_timeseries.py`.
```python
import matplotlib.pyplot as plt
fig, ax = plt.subplots(figsize=(7.2, 4.4))
for ccode, label in [(2, "United States"), (365, "Russia / Soviet Union"), (710, "China")]:
    series = panel[panel.ccode == ccode].sort_values("year")
    ax.step(series["year"], series["total_use"], where="post", label=label)
ax.set(xlabel="Year",
       ylabel="Adopted or superseded technologies\n(total_use, 0–29)",
       ylim=(0, 29))
ax.spines[["top", "right"]].set_visible(False)
ax.legend(frameon=False, loc="lower right")
fig.text(0.01, 0.01, "Source: COW Arms Technology Data Set v1.0 (Hariri & Wingender 2025).",
         fontsize=8, style="italic")
fig.tight_layout()
fig.savefig("figure.pdf", dpi=600, bbox_inches="tight")
```

Use `geom_step()`/`ax.step(..., where="post")` rather than `geom_line()`/`ax.plot()` — adoption is a step function, not continuous. Drawing a slope between adoption years is methodologically misleading.

### Other patterns

- Cross-national comparison (bar/dot plots, faceted by tech category): `scripts/{R,python}/03_cross_national.{R,py}`
- Scatter with trend line (e.g. `total_use` against a Polity score): `scripts/{R,python}/04_scatter_trend.{R,py}`

## Tier 3 — Research scaffolding

### Descriptive table — first-adoption year by region

See `scripts/{R,python}/05_descriptive_table.{R,py}` for the runnable script that outputs a journal-ready table (LaTeX via `kableExtra::kable_styling()` in R, `tabulate` or `pd.DataFrame.to_latex()` in Python).

Common moves:
- First-adoption year per country-technology: filter long format to `use == 1`, group by `(ccode, techname)`, take `min(year)`
- Watch for leap-frog: countries where `min(year)` of `use==9` precedes any `use==1` are technological skippers — flag them or exclude depending on the claim
- Report mean / median / range; do **not** report decimals beyond what the data warrants (year integers)

### Figure / table reference conventions (IR style)

- In-text: "Figure 1 plots `total_use` trajectories…" or "Table 2 reports first-adoption years…"
- Captions cite the source line; the article's reference list carries the full Hariri & Wingender (2025) citation
- For replication: state which file (`_wide` or `_long`), which version (the `version` column — currently `1.0 (2025)`), and the filtering applied

### Citation

```
Hariri, J. G., & Wingender, A. M. (2025). A new data set on arms technology adoption
  1816–2023. Unpublished manuscript.
```

The dataset's `version` column makes this machine-readable — include the version string in any saved analytic dataset.

## Three worked examples

End-to-end walkthroughs in `examples/`:

1. **`01_great_power_gap.md`** — `total_use` trajectories for major powers vs. system mean, 1816–2023, with the 29-tech ceiling acknowledged
2. **`02_diffusion_lag.md`** — years from first adoption anywhere to country-level adoption, distribution by decade and technology category
3. **`03_region_first_adoption.md`** — descriptive table of first-adoption year by region for one technology (e.g. assault rifles)

## Common mistakes

| Mistake | Why wrong | Fix |
|---------|-----------|-----|
| Treating `-9` as missing | Codebook §3.1 says missing is `.` (Stata), parsed to `NaN`/`NA`; `-9` is not used | Trust pandas/readr defaults; do not pass custom `na_values` |
| `total_use == 1` means "adopted 1 technology" | `total_use` is the *count*, not a `prefix_use` value | Read codebook §3.1; `total_use` ranges 0–29 |
| Spliced Russia and USSR series | COW v2016 treats them as one entity (ccode 365); the data is already continuous | Use the data as-is; label "Russia / Soviet Union" in the legend |
| Drawing slopes between adoption years | Adoption is a step function | `geom_step()` / `ax.step(where="post")` |
| Plotting `total_use` as cardinal without disclosure | Codebook §3.1 calls it "a simple, ordinal measure" | Acknowledge in the paper's methods section; do not over-interpret unit increments |
| Reading convergence to 29 as substantive | 29 is the sample ceiling, not the universe of arms tech | State the ceiling in the caption or methods |
| Filtering with `total_use >= 0` to drop missing | Missings are `NaN`, not negative — that filter is a no-op | Use `.dropna()` / `filter(!is.na())` explicitly |
| Counting `use == 1` ignoring `use == 9` | A country with `9` has *adopted* the category (just superseded it) — both count for "ever-adopted" | Use `use %in% c(1, 9)` for ever-adopted; `use == 1` only for current/non-superseded |

## Reference index

- `references/codebook-conventions.md` — full codebook quick-reference, all 29 technologies by prefix, complete state-system gotcha list, leap-frog detection
- `references/publication-standards.md` — DPI, dimensions, fonts, colorblind palettes, journal-specific notes
- `scripts/R/` — 5 runnable R/tidyverse/ggplot2 starters
- `scripts/python/` — 5 runnable Python/pandas/matplotlib starters
- `examples/` — 3 end-to-end worked examples

## Companion skill

For design-stage scaffolding (research question, design, case selection, methods justification, ethics, write-up) following Christopher Lamont's *Research Methods in International Relations* (2nd ed., 2021), see `skills/lamont-ir-research-methods/`. Fill in templates 04 (research design) and 06 (methods justification) **before** opening the COW data.

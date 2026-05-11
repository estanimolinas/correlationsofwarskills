# Correlates of War Skills

Downloadable Claude Code skills for IR researchers working with Correlates of War datasets. Each skill is a self-contained reference + runnable scripts designed for PhD and Master's students writing peer-reviewed journal articles.

## What's in this repo

```
correlationsofwarskills/
├── ArmsTechnologyV1/                      ← COW Arms Technology Dataset v1.0
│   ├── cow_arms_tech_long.csv             (long format, 33 MB)
│   ├── cow_arms_tech_wide.csv             (wide format, 1.5 MB)
│   ├── cow_arms_tech_long.dta             (Stata long)
│   ├── cow_arms_tech_wide.dta             (Stata wide)
│   └── CoW_codebook.pdf                   (Hariri & Wingender 2025)
└── skills/
    └── cow-arms-technology-analysis/      ← Skill: cleaning, viz, tables
        ├── SKILL.md
        ├── references/
        ├── scripts/
        │   ├── R/                         (tidyverse + ggplot2)
        │   └── python/                    (pandas + matplotlib)
        └── examples/
```

## Installation (Claude Code users)

1. Clone the repo:
   ```bash
   git clone https://github.com/estanimolinas/correlationsofwarskills.git
   cd correlationsofwarskills
   ```

2. Copy the skill directory into your personal Claude Code skills folder:
   ```bash
   cp -r skills/cow-arms-technology-analysis ~/.claude/skills/
   ```

3. Tell Claude Code where your data lives. The dataset is included in this repo at `ArmsTechnologyV1/`; if you keep it there, set:
   ```bash
   export COW_ARMS_DATA_DIR="$(pwd)/ArmsTechnologyV1"
   ```

   Add the line to `~/.zshrc` or `~/.bashrc` to make it persistent across shell sessions.

4. The skill will auto-load when you ask Claude Code about COW arms technology data, plotting `total_use`, or producing IR-paper-ready figures and tables.

## Using the runnable scripts directly (no Claude Code required)

The scripts in `skills/cow-arms-technology-analysis/scripts/` are standalone R and Python files. Run them directly:

**R (requires `readr`, `dplyr`, `ggplot2`):**
```bash
cd skills/cow-arms-technology-analysis/scripts/R
export COW_ARMS_DATA_DIR=/path/to/ArmsTechnologyV1
Rscript 01_load_and_clean.R
Rscript 02_timeseries.R
# ...
```

**Python (requires `pandas`, `matplotlib`, `statsmodels`):**
```bash
cd skills/cow-arms-technology-analysis/scripts/python
export COW_ARMS_DATA_DIR=/path/to/ArmsTechnologyV1
python 01_load_and_clean.py
python 02_timeseries.py
# ...
```

Each script writes to `./output/` (relative to where you run it).

## Citing the dataset

If you use this dataset in published work, cite:

> Hariri, J. G., & Wingender, A. M. (2025). *A new data set on arms technology adoption 1816–2023*. Unpublished manuscript.

The dataset's `version` column carries the version string (currently `1.0 (2025)`). Include it in your methods section for replication.

## Citing this skill collection

This repo bundles the dataset with reproducible analysis scaffolding. If the skill itself materially shaped your analytical decisions, you may also reference the GitHub URL in a footnote, e.g.:

> Analysis follows the conventions in the `cow-arms-technology-analysis` skill (github.com/estanimolinas/correlationsofwarskills), particularly the inclusive adoption definition (`use ∈ {1, 9}`) and the recommended handling of COW state-system continuity for Russia/USSR and China.

The primary citation remains the underlying dataset.

## What the skill teaches (in three tiers)

1. **Data cleaning** — the four-value coding scheme (`0/1/9/.`), wide-vs-long format choice, COW state-system gotchas (Russia/USSR, China/Taiwan, Germany splits), missing-value handling, leap-frog detection.
2. **Publication-ready visualization** — 300/600 dpi, vector PDF, step plots for adoption (not slopes), Okabe-Ito colorblind-safe palette, no chartjunk, axis labels grounded in the codebook.
3. **Research scaffolding** — descriptive tables (first-adoption year by region, diffusion lag distributions), LaTeX export, in-text figure/table references in IR style, replication checklist.

See `skills/cow-arms-technology-analysis/SKILL.md` for the full reference, and `examples/` for three end-to-end worked examples.

## Feedback

Found a trap the skill doesn't cover, or a convention that should be revised? Open a GitHub issue. Particularly welcome:

- Corrections to state-system gotchas as COW updates membership data
- Suggestions for additional worked examples
- Edge cases the skill mishandles

## License and use

The skill contents in this repository — everything under `skills/cow-arms-technology-analysis/` plus this `README.md` — are © Estanislao Molinas (2026) and released under the **Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0)**.

In plain terms — **scholars are free to**:

- Use the skill, scripts, and references in their own research, dissertations, and teaching
- Adapt and remix the patterns for their own analyses
- Share the skill with colleagues and students
- Redistribute it as part of replication packages for academic publications

In return, **two requirements**:

1. **Attribution.** Credit the author and link back to this repository. A suggested form for academic work:

   > Molinas, E. (2026). *Correlates of War Skills: cow-arms-technology-analysis*. GitHub repository: https://github.com/estanimolinas/correlationsofwarskills.

2. **Non-commercial use only.** The skill content may not be used for commercial purposes — no repackaging into paid courses, paid consultancy deliverables, commercial training materials, or for-profit republication. For commercial licensing, contact the author at estanislao.molinasir@gmail.com.

Full license terms: see `LICENSE` in the repository root, or https://creativecommons.org/licenses/by-nc/4.0/.

The underlying dataset in `ArmsTechnologyV1/` is the work of Hariri & Wingender (2025) and is **not** covered by this license. Cite their manuscript when using the data:

> Hariri, J. G., & Wingender, A. M. (2025). *A new data set on arms technology adoption 1816–2023*. Unpublished manuscript.

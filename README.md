# Correlates of War Skills

Downloadable Claude Code skills for IR researchers. The collection pairs data-analysis tooling (built around COW datasets) with research-design scaffolding (built around standard IR methods references). Each skill is self-contained and designed for PhD and Master's students writing peer-reviewed journal articles.

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
    ├── cow-arms-technology-analysis/      ← Skill: data cleaning, viz, tables
    │   ├── SKILL.md
    │   ├── references/
    │   ├── scripts/
    │   │   ├── R/                         (tidyverse + ggplot2)
    │   │   └── python/                    (pandas + matplotlib)
    │   └── examples/
    └── lamont-ir-research-methods/        ← Skill: design-stage fill-in templates
        ├── SKILL.md
        └── templates/                     (8 templates: epistemology → write-up)
```

The two skills are designed to be used in sequence: fill in the relevant Lamont templates (research design, methods justification) **before** opening the COW data.

## Installation (Claude Code users)

1. Clone the repo:
   ```bash
   git clone https://github.com/estanimolinas/correlationsofwarskills.git
   cd correlationsofwarskills
   ```

2. Copy one or both skill directories into your personal Claude Code skills folder:
   ```bash
   cp -r skills/cow-arms-technology-analysis ~/.claude/skills/
   cp -r skills/lamont-ir-research-methods ~/.claude/skills/
   ```

3. Tell Claude Code where your data lives. The dataset is included in this repo at `ArmsTechnologyV1/`; if you keep it there, set:
   ```bash
   export COW_ARMS_DATA_DIR="$(pwd)/ArmsTechnologyV1"
   ```

   Add the line to `~/.zshrc` or `~/.bashrc` to make it persistent across shell sessions.

4. The skills auto-load on relevant prompts:
   - `cow-arms-technology-analysis` on COW arms technology data, plotting `total_use`, or producing IR-paper-ready figures and tables.
   - `lamont-ir-research-methods` on research-design questions: framing a research puzzle, justifying case selection, drafting an ethics protocol, outlining a paper.

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

## What the skills teach

### `cow-arms-technology-analysis` — data work (three tiers)

1. **Data cleaning** — the four-value coding scheme (`0/1/9/.`), wide-vs-long format choice, COW state-system gotchas (Russia/USSR, China/Taiwan, Germany splits), missing-value handling, leap-frog detection.
2. **Publication-ready visualization** — 300/600 dpi, vector PDF, step plots for adoption (not slopes), Okabe-Ito colorblind-safe palette, no chartjunk, axis labels grounded in the codebook.
3. **Research scaffolding** — descriptive tables (first-adoption year by region, diffusion lag distributions), LaTeX export, in-text figure/table references in IR style, replication checklist.

See `skills/cow-arms-technology-analysis/SKILL.md` for the full reference, and `examples/` for three end-to-end worked examples.

### `lamont-ir-research-methods` — design work (eight templates)

Fill-in templates that operationalise the workflow in Christopher Lamont, *Research Methods in International Relations* (2nd ed., SAGE 2021):

1. Epistemology brief (positivist / interpretivist / critical positioning)
2. Research question (puzzle, type, scope, feasibility)
3. Literature review matrix (source × debate × claim × gap)
4. Research design (units, cases, data, alternative explanations, validity threats)
5. Case selection matrix (Mill's methods, typical / deviant / most-similar / most-different)
6. Methods justification (qualitative / quantitative / mixed, with method-specific specs)
7. Research ethics checklist (consent, anonymisation, data security, IRB / REC)
8. Write-up outline (target venue, contribution statement, section budget, figure plan)

The skill **does not redistribute** Lamont's book — it paraphrases the framework under fair-use academic citation and points scholars back to the relevant chapter (by topic) for the underlying theoretical grounding. Scholars should own or borrow a copy. See `skills/lamont-ir-research-methods/SKILL.md` for the full reference and the citation block.

## Feedback

Found a trap the skill doesn't cover, or a convention that should be revised? Open a GitHub issue. Particularly welcome:

- Corrections to state-system gotchas as COW updates membership data
- Suggestions for additional worked examples
- Edge cases the skill mishandles

## License and use

The skill contents in this repository — everything under `skills/cow-arms-technology-analysis/` and `skills/lamont-ir-research-methods/`, plus this `README.md` — are © Estanislao Molinas (2026) and released under the **Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0)**.

In plain terms — **scholars are free to**:

- Use the skill, scripts, and references in their own research, dissertations, and teaching
- Adapt and remix the patterns for their own analyses
- Share the skill with colleagues and students
- Redistribute it as part of replication packages for academic publications

In return, **two requirements**:

1. **Attribution.** Credit the author and link back to this repository. A suggested form for academic work:

   > Molinas, E. (2026). *Correlates of War Skills: cow-arms-technology-analysis* (or *lamont-ir-research-methods*). GitHub repository: https://github.com/estanimolinas/correlationsofwarskills.

2. **Non-commercial use only.** The skill content may not be used for commercial purposes — no repackaging into paid courses, paid consultancy deliverables, commercial training materials, or for-profit republication. For commercial licensing, contact the author at estanislao.molinasir@gmail.com.

Full license terms: see `LICENSE` in the repository root, or https://creativecommons.org/licenses/by-nc/4.0/.

The underlying dataset in `ArmsTechnologyV1/` is the work of Hariri & Wingender (2025) and is **not** covered by this license. Cite their manuscript when using the data:

> Hariri, J. G., & Wingender, A. M. (2025). *A new data set on arms technology adoption 1816–2023*. Unpublished manuscript.

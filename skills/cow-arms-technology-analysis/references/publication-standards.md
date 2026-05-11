# Publication standards for IR journal figures and tables

Conventions that pass reviewer scrutiny at *International Organization*, *International Security*, *World Politics*, *JCR*, *JPR*, *ISQ*, *AJPS*, *APSR*, and similar venues. Adjust for journal-specific style guides where they conflict.

## Figures

### Resolution and format

- **PDF (vector)** for all submissions. Journals typeset from PDF; vectors stay sharp at any reproduction size.
- **PNG/TIFF at 600 dpi** as a fallback when a journal explicitly requires raster (rare for line figures, common for some maps).
- **Never submit JPEG** for line figures — compression artifacts at line edges are visible after typesetting.
- 300 dpi is the absolute floor; 600 dpi for raster is safer.

```r
# R — PDF (vector, preferred)
ggsave("figure1.pdf", plot = p, width = 7.2, height = 4.4, device = cairo_pdf)
# R — raster fallback
ggsave("figure1.png", plot = p, width = 7.2, height = 4.4, dpi = 600)
```

```python
# Python — PDF
fig.savefig("figure1.pdf", bbox_inches="tight")
# Python — raster fallback
fig.savefig("figure1.png", dpi=600, bbox_inches="tight")
```

### Dimensions

| Layout | Width | Use |
|--------|-------|-----|
| Single-column | 3.4–3.5″ (8.6 cm) | Inset figures in two-column journals (most political-science journals) |
| Two-column / single-page width | 7.0–7.2″ (17.8 cm) | Main figures |
| Full page | 7.0″ × 9.0″ | Multi-panel figures, large maps |

Height typically 60–70% of width for time-series; 1:1 for scatter plots.

### Typography

- One font family throughout the manuscript. Common choices: Helvetica, Arial, or the journal's body font.
- Base size 10pt for axis labels and legend; 8pt for source/notes; 9–10pt for tick labels.
- No bold tick labels. Axis labels in roman (not italic) unless they contain a variable name in math mode (e.g. *β*).
- Source line / caption at 8pt, italic optional.

```r
theme_minimal(base_size = 10, base_family = "Helvetica") +
  theme(axis.text = element_text(size = 9),
        legend.text = element_text(size = 9),
        plot.caption = element_text(size = 8, face = "italic", hjust = 0))
```

```python
plt.rcParams.update({
    "font.family": "Helvetica",
    "font.size": 10,
    "axes.labelsize": 10,
    "xtick.labelsize": 9,
    "ytick.labelsize": 9,
    "legend.fontsize": 9,
})
```

### Color

- **Default to colorblind-safe palettes.** Okabe-Ito (8 hues, all distinguishable under all common color-vision deficiencies) or viridis.
- **Test in grayscale.** Many readers print figures in black-and-white; many journals reproduce online figures in color but print in B&W.
- Use linetype or marker shape alongside color when categories matter — readers should be able to distinguish series from a photocopy.

```r
# Okabe-Ito palette
okabe_ito <- c("#000000", "#E69F00", "#56B4E9", "#009E73",
               "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
scale_color_manual(values = okabe_ito)
```

```python
okabe_ito = ["#000000", "#E69F00", "#56B4E9", "#009E73",
             "#F0E442", "#0072B2", "#D55E00", "#CC79A7"]
ax.plot(..., color=okabe_ito[1])
```

### Chartjunk to remove

- 3D effects (bars, pies, lines)
- Drop shadows
- Background fills (gray, gradient)
- Excessive gridlines (keep major only; drop minor for most plots)
- Top and right spines (Tufte minimalism — keep only the axes that carry information)
- Legend boxes/frames (use `frameon=False` / `legend.background = element_blank()`)
- Long y-axis tick labels expressed in scientific notation when round numbers would do

### Axis labels

- Include the variable name (matching the codebook) when first introducing a measure: `total_use (count of adopted or superseded arms technologies, 0–29)`
- Units in parentheses
- Capitalize sentence-style, not title-style: "Cumulative adoption count" not "Cumulative Adoption Count"
- For time-series, label "Year" rather than "Time"

### Legends

- Below the plot for time-series; right or inside-upper-corner for scatter
- No legend title unless it adds information beyond the axis labels
- Order legend entries by the data's natural ordering (e.g. final-year value descending) rather than alphabetical

### Captions and source lines

The caption belongs in the manuscript text; the figure itself should carry a short source line at the bottom.

In-figure source line:
> Source: COW Arms Technology Data Set v1.0 (Hariri & Wingender 2025).

In-text caption (in the article):
> **Figure 1.** Cumulative arms technology adoption (`total_use`) for the United States (ccode 2), Russia/Soviet Union (365), and China (710), 1900–2023. The y-axis counts technologies coded as either currently used (`1`) or superseded by a same-category newer technology (`9`); see codebook §3.1. Russia/Soviet Union appears as a single COW State System Membership v2016 entity; see Section X for discussion. Source: Hariri & Wingender (2025).

### Step plots for adoption data

Arms technology adoption is a step function: a country either has adopted the technology (`1`) or has not. Drawing a slope between adoption years implies linear interpolation that doesn't exist in the data.

- R: `geom_step()` (defaults to `direction = "hv"` — horizontal then vertical, which is correct for adoption)
- Python: `ax.step(x, y, where="post")`

## Tables

### Format

- LaTeX tables for journal submission; the journal's typesetter will restyle. Avoid Word tables for anything beyond a simple draft.
- R: `kableExtra::kable_styling()`, `gt`, or `modelsummary` for regression tables.
- Python: `pd.DataFrame.to_latex()`, `tabulate`, or `Stargazer` for regression tables.

### Row and column conventions

- One column per variable; one row per unit (country, country-year, etc.).
- Sort rows by the most relevant ordering (year ascending, or by the variable being discussed) — not alphabetical unless that's the natural order.
- Right-align numeric columns; left-align text.
- Decimals: 2 places for percentages and rates, 3 for coefficients, 0 for years and counts.
- Column headers in sentence case; no underscores in headers (replace `total_use` with "Adoption count" or similar; cite the codebook variable name in the table note).

### Notes

Every descriptive table needs a note explaining:
1. The unit of observation
2. The source (COW Arms Tech v1.0)
3. Definitions of any non-obvious column

Example:
> *Note:* Unit of observation is country-decade. "First adoption" is defined as the earliest year in which the country has `s7_use == 1` (assault rifle adopted and not superseded). Countries with `s7_use == 9` before any year of `s7_use == 1` are flagged as leap-froggers (see codebook §3.1) and excluded from the medians but reported in the count column. Source: Hariri & Wingender (2025).

## Replication checklist for figures and tables

Reviewer 2 will ask for replication. Save with every figure/table:

- The exact data file used (`cow_arms_tech_wide.csv` or `_long.csv`) and version (`1.0 (2025)` from the `version` column)
- The script that produced the figure (R or Python)
- The filtering applied (e.g. `ccode %in% c(2, 365, 710), year >= 1900`)
- Any merges with other datasets and their versions (e.g. Polity 5, V-Dem v13)
- The seed if any random sampling is involved

A short top-of-script comment block satisfies most journals' replication requirements.

## Common journal preferences

- *International Organization*, *International Security*: prefer minimalist B&W or duotone figures; check current style guide
- *AJPS*, *APSR*: accept color in print; require replication package on Dataverse
- *JCR*, *JPR*: accept color; figures often run small (single column)
- *World Politics*: traditional typography; B&W or limited color

Always check the current author guidelines — these conventions shift over time.

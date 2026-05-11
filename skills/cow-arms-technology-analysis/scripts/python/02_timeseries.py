#!/usr/bin/env python3
"""02_timeseries.py — publication-ready total_use trajectories for major powers.

Codebook §3.1: total_use counts arms technologies coded 1 (currently used) or 9
(superseded). The codebook calls it "a simple, ordinal measure" — disclose in
methods if treating as cardinal. Adoption is a step function — use ax.step()
with where="post", not ax.plot().
"""

import os
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

data_dir = Path(os.environ.get(
    "COW_ARMS_DATA_DIR",
    Path(__file__).resolve().parents[3] / "ArmsTechnologyV1",
))

wide = pd.read_csv(data_dir / "cow_arms_tech_wide.csv")
mask = wide["ccode"].isin([2, 365, 710]) & wide["year"].between(1900, 2023)
panel = wide.loc[mask].copy()

labels = {2: "United States", 365: "Russia / Soviet Union", 710: "China"}
okabe_ito = {2: "#0072B2", 365: "#D55E00", 710: "#009E73"}
linestyles = {2: "-", 365: "--", 710: "-."}

plt.rcParams.update({
    "font.family": "Helvetica",
    "font.size": 10,
    "axes.labelsize": 10,
    "xtick.labelsize": 9,
    "ytick.labelsize": 9,
    "legend.fontsize": 9,
})

fig, ax = plt.subplots(figsize=(7.2, 4.4))
for ccode, label in labels.items():
    series = panel[panel.ccode == ccode].sort_values("year")
    ax.step(series["year"], series["total_use"], where="post",
            label=label, color=okabe_ito[ccode],
            linestyle=linestyles[ccode], linewidth=1.0)

ax.axhline(29, color="grey", linestyle=":", linewidth=0.5)
ax.text(2023, 29.4, "Sample ceiling (29 techs)",
        ha="right", va="bottom", fontsize=8, color="grey")

ax.set(xlim=(1900, 2025), ylim=(0, 30),
       xticks=range(1900, 2021, 20),
       yticks=range(0, 30, 5),
       xlabel="Year",
       ylabel="Adopted or superseded technologies\n(total_use, 0–29)")
ax.spines[["top", "right"]].set_visible(False)
ax.legend(frameon=False, loc="lower right")

fig.text(0.01, 0.01,
         "Source: COW Arms Technology Data Set v1.0 (Hariri & Wingender 2025).",
         fontsize=8, style="italic")
fig.tight_layout(rect=(0, 0.02, 1, 1))

Path("output").mkdir(exist_ok=True)
fig.savefig("output/figure_timeseries.pdf", bbox_inches="tight")
fig.savefig("output/figure_timeseries.png", dpi=600, bbox_inches="tight")
print("Wrote output/figure_timeseries.{pdf,png}")

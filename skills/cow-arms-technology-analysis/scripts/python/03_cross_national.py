#!/usr/bin/env python3
"""03_cross_national.py — snapshot-year cross-national dot plot of total_use.

Sorts all states by total_use in the chosen year. Lollipop / dot-line is
more legible than bars for ranked data and prints cleanly in B&W.
"""

import os
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

SNAPSHOT_YEAR = 1950  # change to inspect another year

data_dir = Path(os.environ.get(
    "COW_ARMS_DATA_DIR",
    Path(__file__).resolve().parents[3] / "ArmsTechnologyV1",
))

wide = pd.read_csv(data_dir / "cow_arms_tech_wide.csv")
snap = (
    wide.loc[(wide.year == SNAPSHOT_YEAR) & wide.total_use.notna(),
             ["statename", "total_use"]]
    .sort_values("total_use")
    .reset_index(drop=True)
)

plt.rcParams.update({"font.family": "Helvetica", "font.size": 8})

fig, ax = plt.subplots(figsize=(7.2, 9.0))
y_pos = range(len(snap))
ax.hlines(y_pos, 0, snap["total_use"], color="grey", linewidth=0.3)
ax.plot(snap["total_use"], y_pos, "o", color="#0072B2", markersize=3.5)

ax.set(
    yticks=y_pos,
    yticklabels=snap["statename"].tolist(),
    xlim=(0, 29),
    xticks=range(0, 30, 5),
    xlabel=f"total_use in {SNAPSHOT_YEAR} (0–29)",
)
ax.tick_params(axis="y", labelsize=6)
ax.spines[["top", "right"]].set_visible(False)

fig.text(0.01, 0.005,
         "Source: COW Arms Technology Data Set v1.0 (Hariri & Wingender 2025).",
         fontsize=8, style="italic")
fig.tight_layout(rect=(0, 0.015, 1, 1))

Path("output").mkdir(exist_ok=True)
out = f"output/figure_crossnational_{SNAPSHOT_YEAR}.pdf"
fig.savefig(out, bbox_inches="tight")
print(f"Wrote {out} — {len(snap)} states")

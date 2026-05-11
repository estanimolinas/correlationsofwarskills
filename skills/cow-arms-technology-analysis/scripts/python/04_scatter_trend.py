#!/usr/bin/env python3
"""04_scatter_trend.py — scatter of total_use in 2023 vs. modernization year.

Self-contained example that does not require external data. Each country's
"modernization year" is defined as the first year it reached total_use >= 10
(half the 29-tech sample). For a real paper, merge in GDP, Polity, military
expenditure, etc., and overlay LOWESS or a parametric trend.
"""

import os
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
from statsmodels.nonparametric.smoothers_lowess import lowess

data_dir = Path(os.environ.get(
    "COW_ARMS_DATA_DIR",
    Path(__file__).resolve().parents[3] / "ArmsTechnologyV1",
))

wide = pd.read_csv(data_dir / "cow_arms_tech_wide.csv")

# First year each country reaches total_use >= 10
first_modern = (
    wide.loc[wide.total_use >= 10]
    .groupby(["ccode", "statename"])["year"].min()
    .reset_index(name="first_year_10")
)
snap_2023 = (
    wide.loc[wide.year == 2023, ["ccode", "statename", "total_use"]]
    .rename(columns={"total_use": "total_use_2023"})
)
joined = first_modern.merge(snap_2023, on=["ccode", "statename"], how="inner")
joined = joined.dropna(subset=["total_use_2023"])

plt.rcParams.update({"font.family": "Helvetica", "font.size": 10})
fig, ax = plt.subplots(figsize=(7.2, 4.4))
ax.scatter(joined["first_year_10"], joined["total_use_2023"],
           alpha=0.6, color="#0072B2", s=18)

smoothed = lowess(joined["total_use_2023"], joined["first_year_10"],
                  frac=0.4, return_sorted=True)
ax.plot(smoothed[:, 0], smoothed[:, 1], color="#D55E00", linewidth=1.5)

ax.set(xlabel="Year country first reached total_use ≥ 10",
       ylabel="total_use in 2023 (0–29)",
       ylim=(0, 29))
ax.spines[["top", "right"]].set_visible(False)

fig.text(0.01, 0.01,
         "Source: COW Arms Technology Data Set v1.0 (Hariri & Wingender 2025). "
         "LOWESS smoother shown for visualization only.",
         fontsize=8, style="italic")
fig.tight_layout(rect=(0, 0.02, 1, 1))

Path("output").mkdir(exist_ok=True)
fig.savefig("output/figure_scatter_trend.pdf", bbox_inches="tight")
print(f"Wrote output/figure_scatter_trend.pdf — {len(joined)} states")

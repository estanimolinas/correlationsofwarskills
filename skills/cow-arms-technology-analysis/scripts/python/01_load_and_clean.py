#!/usr/bin/env python3
"""01_load_and_clean.py — load COW Arms Tech, filter to a country-year subset.

Codebook: ArmsTechnologyV1/CoW_codebook.pdf §§2-3.1 (Hariri & Wingender 2025).
Missing values are `.` in Stata; pandas parses blank CSV fields to NaN
automatically — do NOT pass na_values=[-9] or na_values=["-9"].

Usage:
    export COW_ARMS_DATA_DIR=/path/to/ArmsTechnologyV1
    python 01_load_and_clean.py
"""

import os
from pathlib import Path
import pandas as pd

data_dir = Path(os.environ.get(
    "COW_ARMS_DATA_DIR",
    Path(__file__).resolve().parents[3] / "ArmsTechnologyV1",
))
wide_path = data_dir / "cow_arms_tech_wide.csv"
assert wide_path.exists(), f"Not found: {wide_path}"

wide = pd.read_csv(wide_path)

# Major-power illustration: US (2), Russia/USSR (365), China (710).
mask = wide["ccode"].isin([2, 365, 710]) & wide["year"].between(1900, 2023)
panel = wide.loc[mask, ["ccode", "statename", "year", "total_use", "version"]].copy()

print(f"Rows: {len(panel)}")
print(f"Missing total_use: {panel['total_use'].isna().sum()}")
print(f"Range of total_use: {panel['total_use'].min()}–{panel['total_use'].max()}")
print()

# Per-country summary
summary = (
    panel.groupby("statename")
    .agg(
        n_years=("year", "size"),
        n_missing=("total_use", lambda s: s.isna().sum()),
        first_year=("year", "min"),
        last_year=("year", "max"),
        mean_total_use=("total_use", lambda s: round(s.mean(), 2)),
    )
    .reset_index()
)
print(summary.to_string(index=False))

Path("output").mkdir(exist_ok=True)
panel.to_csv("output/panel_majors_1900_2023.csv", index=False)
print("\nWrote output/panel_majors_1900_2023.csv")

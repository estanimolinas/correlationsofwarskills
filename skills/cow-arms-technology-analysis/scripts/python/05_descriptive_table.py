#!/usr/bin/env python3
"""05_descriptive_table.py — first-adoption year of the assault rifle, by region.

Outputs CSV + LaTeX. Demonstrates a region-summary pattern. For a real paper,
merge against an established regional classification (UN M.49 or COW regions)
rather than the illustrative ccode-range bins below.
"""

import os
from pathlib import Path
import pandas as pd

data_dir = Path(os.environ.get(
    "COW_ARMS_DATA_DIR",
    Path(__file__).resolve().parents[3] / "ArmsTechnologyV1",
))

long = pd.read_csv(data_dir / "cow_arms_tech_long.csv")
long = long[long["techname"].notna()]   # drop the total_use rows

# Illustrative region bins by ccode range. Replace with a proper classification
# for actual research.
def region_for(ccode: int) -> str:
    if   2   <= ccode <= 199: return "Americas"
    elif 200 <= ccode <= 399: return "Europe"
    elif 400 <= ccode <= 599: return "Sub-Saharan Africa"
    elif 600 <= ccode <= 699: return "MENA"
    elif 700 <= ccode <= 999: return "Asia–Pacific"
    return "Unknown"

first_adopt = (
    long.loc[(long.techname == "Assault rifle") & (long.use == 1)]
    .groupby(["ccode", "statename"])["year"].min()
    .reset_index(name="first_year")
)
first_adopt["region"] = first_adopt["ccode"].map(region_for)

tbl = (
    first_adopt.groupby("region")["first_year"]
    .agg(n_countries="size", earliest="min", median="median", latest="max")
    .reset_index()
    .sort_values("median")
)
tbl["median"] = tbl["median"].astype(int)
print(tbl.to_string(index=False))

Path("output").mkdir(exist_ok=True)
tbl.to_csv("output/table_first_adoption_assault_rifle.csv", index=False)

# LaTeX
with open("output/table_first_adoption_assault_rifle.tex", "w") as f:
    f.write("\\begin{tabular}{lrrrr}\n\\hline\n")
    f.write("Region & N countries & Earliest & Median & Latest \\\\\n\\hline\n")
    for _, r in tbl.iterrows():
        f.write(f"{r.region} & {r.n_countries} & {r.earliest} & "
                f"{r['median']} & {r.latest} \\\\\n")
    f.write("\\hline\n\\end{tabular}\n")
print("\nWrote output/table_first_adoption_assault_rifle.{csv,tex}")

# Codebook conventions — quick reference

Grounded in `ArmsTechnologyV1/CoW_codebook.pdf` (Hariri & Wingender, March 19, 2025). Section references below point back to the codebook.

## The 29 technologies by prefix

Per codebook Table 1, technologies are grouped into 7 categories with letter prefixes; the number indicates vintage (least to most advanced within category).

### Small arms (`s`, codebook §4)
| Prefix | Technology | First adopter / year |
|--------|------------|----------------------|
| `s1_use` | Flintlock musket | 17th century, Normandy |
| `s2_use` | Percussion lock musket | Britain, 1807 (patent); European armies 1830s |
| `s3_use` | Minié bullet rifle | France, 1849 |
| `s4_use` | Breechloading rifle (Dreyse) | Prussia, 1841 (issued 1848) |
| `s5_use` | Tubular magazine rifle | USA, 1860 (Spencer, Henry) |
| `s6_use` | Box magazine rifle | USA, 1879 (Lee patent); Mannlicher/Mauser 1880s |
| `s7_use` | Assault rifle | Nazi Germany Stg 44 (1944), then AK-47 |

### Machine guns (`m`)
| Prefix | Technology | First |
|--------|------------|------|
| `m1_use` | Hand-cranked (Gatling, mitrailleuse) | USA/Belgium, early 1860s |
| `m2_use` | Automatic | Maxim, 1884; European armies ~1890 |

### Artillery (`a`)
| Prefix | Technology | First |
|--------|------------|------|
| `a1_use` | Smoothbore field guns | France, 1494 |
| `a2_use` | Rifled artillery | Britain/France/Prussia, late 1850s |
| `a3_use` | Steel tubes | Krupp 1840s production; Egypt first order 1856 |
| `a4_use` | Practical breech-loading (Krupp sliding breech / de Bange interrupted screw) | 1873 / 1877 |
| `a5_use` | Recoil mechanism | French Canon Modèle 75, 1897 |

### Tanks (`t`)
| Prefix | Technology | First |
|--------|------------|------|
| `t1_use` | Early tank | British Mark I, 1916 |
| `t2_use` | WWII era tank (T-34 class; postwar light tanks coded here) | Soviet T-34, 1940 |
| `t3_use` | 1st gen. main battle tank | Soviet T-54/55, 1948 |
| `t4_use` | 2nd gen. main battle tank | American M-60, 1960 |
| `t5_use` | 3rd gen. main battle tank | West German Leopard 2, 1980 |

### Fighter aircraft (`f`)
| Prefix | Technology | First |
|--------|------------|------|
| `f1_use` | Early attack aircraft | WWI |
| `f2_use` | WWII era fighter | Soviet I-16, 1934; Bf109, Spitfire |
| `f3_use` | 1st gen. jet | Me 262, Gloster Meteor, 1944 |
| `f4_use` | 2nd gen. jet (supersonic, air-to-air missiles) | F-100, 1954 |
| `f5_use` | 3rd gen. jet (variable geometry) | MiG-21, 1960 |
| `f6_use` | 4th gen. jet (precision munitions) | F-14, 1972 |
| `f7_use` | 5th gen. jet (stealth, supercruise) | F-22 Raptor, 2005 |

### Combat helicopters (`h`)
| Prefix | Technology | First |
|--------|------------|------|
| `h1_use` | 1st gen. attack helicopter | AH-1, 1967 |
| `h2_use` | 2nd gen. attack helicopter | AH-64, 1986 |

### Armed UAVs (`u`)
| Prefix | Technology | First |
|--------|------------|------|
| `u1_use` | Armed unmanned aerial vehicle | MQ-1 Predator, 1995 |

## Coding values (codebook §3.1)

Each `prefix_use` variable:

- **`0`** — not used in this year, not used in any prior year, and not superseded
- **`1`** — used currently or in any prior year, and not superseded by a same-category superior tech
- **`9`** — a same-category superior tech has been adopted; the prefix tech may or may not still be in use
- **`.`** (blank in CSV) — missing

**`total_use`** — sum of `prefix_use` values coded `1` or `9` across all 29 technologies. Range 0–29. Missing if any of the 29 individual values is missing.

**Three implications most users miss:**

1. **A country at `total_use = 29` is at the sample ceiling, not the technological frontier of human history.** The dataset covers 29 specific technologies; once all 29 have been touched (currently used or superseded by a same-category newer tech), `total_use` cannot grow. Convergence to 29 in the modern era is partially a sample-frame artifact.

2. **Two countries with the same `total_use` may differ substantively.** Country A may currently field 5th-gen jet fighters (`f7_use == 1`); country B may have only superseded 4th-gen lineage (`f6_use == 9`, `f7_use == 0`). Both contribute the same way to `total_use` from the fighter category. If your claim depends on current capability vs. historical adoption, use the individual `prefix_use` variables, not `total_use`.

3. **`total_use` is described as "a simple, ordinal measure"** (codebook §3.1). Treating it as cardinal — i.e. plotting it on a continuous y-axis or putting it in a linear regression — is common in practice but should be acknowledged in the methods section.

## Leap-frog detection (codebook §3.1)

A `0 → 9` transition with no intervening `1` indicates the country adopted a superior technology without ever using the prior generation. Example: a state that never adopted 3rd-gen jets but jumped from 2nd-gen straight to 4th-gen will show `f5_use` going `0 → 9` at the same year `f6_use` goes `0 → 1`.

**Detect in long format (R):**
```r
library(dplyr)
long |>
  filter(techname == "Third gen. jet fighter") |>   # or any tech
  group_by(ccode) |>
  arrange(year, .by_group = TRUE) |>
  mutate(prev = lag(use)) |>
  filter(prev == 0, use == 9) |>
  select(ccode, statename, techname, year)
```

**Detect in long format (Python):**
```python
mask = long["techname"] == "Third gen. jet fighter"
sub = long.loc[mask].sort_values(["ccode", "year"]).copy()
sub["prev"] = sub.groupby("ccode")["use"].shift(1)
leapfrog = sub.query("prev == 0 and use == 9")[["ccode", "statename", "techname", "year"]]
```

## COW state-system gotchas

The dataset inherits COW State System Membership v2016 (codebook §2). State-year coverage gaps and identity rules trip up newcomers; the table below covers the cases most likely to bite an IR researcher writing on major powers and recent conflicts.

| Country (or group) | ccode | Years | Notes |
|--------------------|-------|-------|-------|
| Russia / Soviet Union | 365 | 1816–present (continuous) | No separate USSR entry. `statename` is "Russia" throughout |
| China | 710 | 1860–present | Covers Qing → ROC (1912–1949) → PRC (1949–) as one entity |
| Taiwan | 713 | 1949–present | Inherits the ROC government, but separate ccode 713 from 1949 onward |
| Germany | 255 | 1816–1945, 1990–present | Imperial / Weimar / Nazi Germany then reunified Germany |
| German Federal Republic | 260 | 1955–1990 | West Germany |
| German Democratic Republic | 265 | 1949–1990 | East Germany |
| Yemen Arab Republic | 678 | 1926–1990 | North Yemen |
| Yemen People's Republic | 680 | 1967–1990 | South Yemen |
| Yemen (unified) | 679 | 1990–present | Sometimes also written as ccode 678 in newer COW updates; check your filtering |
| Vietnam (DRV → SRV) | 816 | 1954–present | North Vietnam, then unified Vietnam from 1975 |
| Republic of Vietnam | 817 | 1954–1975 | South Vietnam |
| Czechoslovakia | 315 | 1918–1992 | Single entity until dissolution |
| Czech Republic | 316 | 1993–present | |
| Slovakia | 317 | 1993–present | |
| Korea | (none) | n/a | Use 731 (North Korea) and 732 (South Korea) separately |
| Serbia / Yugoslavia | 345 | Various | Yugoslavia and Serbia share ccode 345 across different periods; check membership v2016 |
| Pakistan | 770 | 1947–present | Bangladesh (771) is separate from 1971 |

**General rules for analyses that span these breaks:**

- For *continuous* COW entities (Russia/USSR, China, post-1990 Germany): use the data as-is; label the legend to acknowledge the historical span if relevant.
- For *split or reunified* entities (Germany pre/post 1990, Yemen pre/post 1990, Vietnam pre/post 1975): the panel is unbalanced — there are years where multiple entries exist (e.g. GFR 260 and Germany 255 both have rows in 1990) and years where one disappears. Aggregate carefully if pooling. The codebook's data sources section (§5) lists which ccodes have entries for each technology.
- For *Taiwan inheriting ROC*: there is no row for ccode 713 before 1949; ROC pre-1949 lives under 710. If your analysis hinges on continuity, decide and disclose your splicing rule.

## Long-format variables (codebook §3.2)

The long file replaces the wide `prefix_use` columns with:

- `techname` — full technology name (e.g. "Breechloading rifle"). Missing on rows representing `total_use`
- `techtype` — category (e.g. "Small arms"). Missing on `total_use` rows
- `use` — the value (`0`/`1`/`9`/missing) corresponding to that `(state, year, technology)` triad

Long-format rows include both per-technology rows (one per `(ccode, year, techname)`) AND total rows (`techname` and `techtype` missing, `use` blank, `total_use` populated). Filter on `!is.na(techname)` (R) / `long["techname"].notna()` (Python) before doing per-technology analyses.

## Version field

Every row has a `version` column with the current value `1.0 (2025)`. Carry this through any saved analytic dataset for replication; cite the version explicitly in methods sections.

## Excluded states

Codebook §2 footnote: states with fewer than 500,000 inhabitants in 2016 are excluded from the dataset, even if they are COW members. The exclusion list:

Andorra, Antigua and Barbuda, Bahamas, Brunei, Dominica, Federated States of Micronesia, Grenada, Iceland, Kiribati, Liechtenstein, Marshall Islands, Monaco, Nauru, Palau, Samoa, San Marino, São Tomé and Príncipe, Seychelles, St. Kitts and Nevis, St. Lucia, St. Vincent and the Grenadines, Tuvalu, Vanuatu.

If your analysis is a system-wide claim (e.g. "X% of states adopted technology Y by year Z"), state explicitly that the denominator is COW members with population ≥ 500K in 2016.

## What's *not* recorded

Codebook §3.1: only adoption by **branches of government** (military or police). Rebel groups, paramilitaries, and non-state actors are excluded. Adoption requires use by units that "could be called upon to fight" — prototypes, test specimens, and manufacturer demonstrations do not count. This matters when interpreting late-20th-century data on irregular conflicts.

## Data sources

Codebook §5 lists per-state, per-technology sources (~50 pages). Cite specific sources only when challenged on a particular adoption coding; otherwise the standard citation of the dataset suffices.

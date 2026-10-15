# Data Dictionary: GBD Occupational Risks

`scripts/prepare_data.R` combines your GBD Results Tool downloads into
`data/processed/gbd_occupational.csv.gz`. Each row is one modelled estimate.

| Column | Meaning |
| --- | --- |
| `measure` | `Deaths` or `DALYs` (disability-adjusted life years: years of life lost to early death plus years lived with disability, weighted by severity) |
| `location` | `Global`, a GBD region, or a country or territory (GBD's spelling, for example `United States of America`) |
| `level` | `Global`, `Region` (one of the 21 GBD regions) or `Country` |
| `sex` | `Both`, `Male` or `Female` |
| `age` | `All ages` (counts and crude rates) or `Age-standardized` (rates adjusted to GBD's standard population, for comparing places and years) |
| `cause` | `All causes`: the burden from every disease and injury linked to the risk |
| `risk` | The occupational risk (see below) |
| `metric` | `Number`; `Rate` (per 100,000 people in the whole population); or `Percent` (share of all deaths or DALYs from every cause, as a proportion: 0.02 means 2%) |
| `year` | Calendar year |
| `val` | Estimate (mean of GBD's 500 draws) |
| `lower`, `upper` | 95% uncertainty interval (2.5th and 97.5th percentiles of the draws) |

## Risks

GBD organises risks in levels. The downloads use these:

| Level | Risk |
| --- | --- |
| 2 | `Occupational risks` (all of the below together) |
| 3 | `Occupational carcinogens` |
| 4 | `Occupational exposure to` asbestos, arsenic, benzene, beryllium, cadmium, chromium, diesel engine exhaust, formaldehyde, nickel, polycyclic aromatic hydrocarbons, silica, sulfuric acid, trichloroethylene |
| 3 | `Occupational asthmagens` |
| 3 | `Occupational particulate matter, gases, and fumes` |
| 3 | `Occupational noise` |
| 3 | `Occupational injuries` |
| 3 | `Occupational ergonomic factors` |

The level 3 risks do not add up exactly to `Occupational risks`, because GBD combines risks that
affect the same disease so that the same death is not counted twice.

## What is in each download

If you followed the README:

| Download | Places | Years | Sexes | Risks |
| --- | --- | --- | --- | --- |
| First | Global and the 21 GBD regions | Every year | Both, Male, Female | All 20 |
| Second | 204 countries and territories | 1990, 2000, 2010, 2019, latest | Both | Occupational risks and the 6 level 3 risks |

Both include deaths and DALYs; number, rate and percent; and all ages and age-standardized.

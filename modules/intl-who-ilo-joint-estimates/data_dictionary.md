# Data Dictionary: WHO/ILO Joint Estimates

Built by `scripts/build_dataset.R` from the exports of the WHO/ILO Occupational Burden of Disease
application. All values are modelled estimates.

## Shared columns

| Column | Meaning |
| --- | --- |
| `level` | `global`, `region` or `country` |
| `region` | WHO region: `Africa`, `Americas`, `Eastern Mediterranean`, `Europe`, `South-East Asia`, `Western Pacific` (or `Global`) |
| `country` | Country name (WHO's official short name, for example `United States of America`) |
| `year` | 2000, 2010 or 2016 (2019 also for solar UV radiation) |
| `sex` | `Both`, `Female`, `Male` |
| `age_group` | `15+ years` (all ages 15 and over), or a 5-year group from `15-19 years` to `90-94 years`, and `95+ years` |
| `risk_factor` | Occupational risk factor (see README for the list) |

Each estimate comes with a 95% uncertainty interval: columns ending in `_lower` and `_upper`.

## `burden_global_regional.csv.gz` and `burden_country.csv.gz`

| Column | Meaning |
| --- | --- |
| `cause` | Health outcome (disease or kind of injury) |
| `measure` | `deaths` or `dalys` (disability-adjusted life years: years of life lost to early death plus years lived with disability) |
| `number`, `number_lower`, `number_upper` | Number of deaths or DALYs attributable to the risk factor |
| `rate`, `rate_lower`, `rate_upper` | Per 100,000 people in that sex and age group (for `15+ years`, per 100,000 people aged 15 and over) |

`burden_country.csv.gz` has only `15+ years` (no `age_group` or `level` column).

**Adding up:**

- The `15+ years` row is the total of the 5-year age groups; `Both` is the total of `Female` and
  `Male`. Filter on one of each before adding.
- Numbers for different pairs can be added for a total, but a person can be exposed to more than
  one risk factor, so totals for the same disease may overlap.
- Rates for the same population can be added; uncertainty intervals cannot.
- Some pairs cause no deaths, only disability (ergonomic factors and back pain, noise and hearing
  loss): their deaths are 0.

## `exposure.csv.gz`

Available for **exposure to long working hours** (working 55 or more hours a week) and
**occupational exposure to solar ultraviolet radiation**.

| Column | Meaning |
| --- | --- |
| `number`, `number_lower`, `number_upper` | Number of people exposed |
| `percent`, `percent_lower`, `percent_upper` | Exposed people as a percentage of the population in that sex and age group |

Regions and the world have every age group; countries have `15+ years` only.

## `disease_death_rate.csv.gz`

The summary indicator "mortality rate from diseases attributable to selected occupational risk
factors": deaths from all work-related **diseases** (all pairs except injuries) per 100,000
population, with its uncertainty interval (`rate`, `rate_lower`, `rate_upper`). Same levels and age
groups as `exposure.csv.gz`.

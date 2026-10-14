# Data Dictionary: BLS CFOI

Built by `scripts/build_dataset.R` from the BLS CFOI flat files (series `fw`) and the BLS
hours-based fatal injury rate tables. Counts that BLS did not publish are absent (not zero).

## `cfoi_national.csv`: US counts by characteristic, 2011 to 2022

| Column | Meaning |
| --- | --- |
| `year` | Year of death |
| `group` | Characteristic group, for example `Age group`, `Gender`, `Race`, `Worker status`, `Event or exposure`, `Primary source of injury`, `Nature`, `Part`, `Worker activity`, `Worker location`, `Time of incident`, `Occupation`; `All` = all fatal work injuries |
| `category` | Category within the group, for example `65 years and over` |
| `category_code` | BLS category code |
| `fatalities` | Number of fatal work injuries |

Categories within a group are nested (for example "Transportation incidents" includes "Roadway
incidents involving motorized land vehicle"), so do not add up all categories in a group.

## `cfoi_by_detail.csv`: US counts by detailed classification, 2011 to 2022

| Column | Meaning |
| --- | --- |
| `detail_type` | `industry (private)`, `industry (government)`, `occupation`, `event`, or `primary source` |
| `code` | NAICS industry code, SOC occupation code, or OIICS event or source code (BLS format, with `X` as padding) |
| `label` | Name of the industry, occupation, event or source |
| `display_level` | Level in the hierarchy: 0 = all, 1 = broadest (for example the 7 event divisions), higher numbers = more detail |
| `year` | Year of death |
| `fatalities` | Number of fatal work injuries |

Filter on one `display_level` to avoid double counting. Industry codes follow NAICS and
occupation codes follow SOC, as used by BLS for these years.

## `cfoi_states.csv`: counts by state, 2011 to 2022

| Column | Meaning |
| --- | --- |
| `state_code` | BLS area code (`S` + two digits; matches the FIPS code for the 50 states and DC) |
| `state` | State name |
| `area_type` | `State or DC` (the 50 states and DC, including the combined "New York State and New York City"), `New York part` (New York City, and New York State except NYC, already included in the combined row), or `Territory` (Puerto Rico, Guam, US Virgin Islands; not in the US total) |
| `year`, `group`, `category`, `category_code`, `fatalities` | As in `cfoi_national.csv` |

Summing `State or DC` rows gives the US total to within a few deaths (a small number of cases
are not assigned to a state).

## `cfoi_rates.csv`: fatal injury rates, 2023 and 2024

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `section` | `Total`, `Employee status`, `Sex`, `Age`, `Race or ethnic origin`, `Occupation`, or `Industry` |
| `characteristic` | Group, occupation or industry name |
| `code` | SOC occupation code(s) or NAICS industry code(s), as printed in the BLS table |
| `hours_millions` | Total hours worked, millions (annual average, from the Current Population Survey) |
| `rate_per_100k_fte` | Fatal injuries per 100,000 full-time equivalent workers |
| `margin_of_error` | BLS margin of error for the rate, at the 95% confidence level |

**Rate formula:** (N / EH) x 200,000,000, where N = number of fatal work injuries, EH = total hours
worked by all workers in the group, and 200,000,000 = the hours worked by 100,000 full-time
workers (40 hours x 50 weeks). BLS publishes rates only for groups with at least 5 fatal injuries
and 40 million hours worked; rows with a blank rate are headings or did not meet the criteria.

## Definitions

- **Fatal occupational injury**: a death resulting from a traumatic injury related to work. Deaths
  from illnesses are excluded unless an injury event precipitated them. CFOI counts deaths that
  occurred in the reference year, regardless of when the injury occurred. See BLS's
  [CFOI scope](https://www.bls.gov/iif/overview/cfoi-scope.htm) for the full criteria.
- **Event or exposure**: how the fatal injury was produced (OIICS), for example transportation
  incidents or falls.
- **Primary source**: the object, substance, or exposure that directly produced the injury.

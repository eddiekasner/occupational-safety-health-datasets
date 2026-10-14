# Data Dictionary: BLS SOII

Built by `scripts/build_dataset.R` from the BLS flat files `is` (industry data) and `cs`
(case and demographic data). Estimates BLS did not publish are absent, not zero.

## Shared columns

| Column | Meaning |
| --- | --- |
| `year` | Reference year |
| `value` | The estimate (see `measure`) |
| `footnote` | BLS footnote code(s), see below |
| `ownership` | `All ownerships`, `Private industry`, `State government`, `Local government`, or `State and local government combined` |

### Footnotes

| Code | Meaning |
| --- | --- |
| `A` | Industry added in 2019 |
| `C` | Fewer than 15 cases |
| `L` | Fewer than 50 cases |
| `Z` | Rate rounded to zero |

## Industry and state tables (all recordable cases, 2014 to 2024)

### `soii_industry.csv.gz` (US), `soii_states.csv`, `soii_size.csv`

| Column | Meaning |
| --- | --- |
| `supersector` | BLS industry supersector (for example Manufacturing) |
| `industry_code` | NAICS code (`000000` = all industries) |
| `industry` | Industry name |
| `display_level` | Level in the industry hierarchy: 0 = all industries, 1 = goods-producing or service-providing, 2 = supersector, 3 = NAICS sector (2-digit), 4 = subsector (3-digit), 5 to 7 = 4- to 6-digit industries |
| `state` | State (`soii_states.csv` only; all industries) |
| `size_class` | Number of employees at the establishment: `1-10`, `11-49`, `50-249`, `250-999`, `1,000 or more` (`soii_size.csv` only; private industry, industry levels 0 to 3) |
| `case_type` | Type of case (see below). Rows starting with `RSE of` give the relative standard error |
| `measure` | What `value` measures (see below) |

### `case_type`

| Value | Meaning |
| --- | --- |
| Total recordable cases | All injuries and illnesses recorded on the OSHA log |
| Cases involving days away from work, job restriction, or transfer | "DART" cases |
| Cases involving days away from work | "DAFW" cases |
| Cases involving days of job transfer or restriction | "DJTR" cases |
| Other recordable cases | Recordable cases with no days away or restriction |
| Total recordable cases of skin disease / respiratory illnesses / poisoning / hearing loss / all other illnesses | Illnesses by type (use the illness measures) |
| RSE of ... | Relative standard error of the corresponding estimate, in percent |

### `measure`

| Value | Meaning |
| --- | --- |
| `injury_illness_rate_per_100` | Injury and illness cases per 100 full-time equivalent workers |
| `injury_rate_per_100` | Injury cases per 100 full-time equivalent workers |
| `illness_rate_per_10000` | Illness cases per **10,000** full-time equivalent workers |
| `injury_illness_cases_thousands`, `injury_cases_thousands`, `illness_cases_thousands` | Number of cases, in thousands |

**Incidence rate** = (N / EH) x 200,000, where N = number of cases, EH = total hours worked by all
employees, and 200,000 = hours worked by 100 full-time workers in a year (40 hours x 50 weeks).

## Days-away-from-work tables (2011 to 2020)

These describe only cases with at least one day away from work.

### `soii_dafw_characteristics.csv`

| Column | Meaning |
| --- | --- |
| `category_code` | BLS category code (`00X` = all cases) |
| `characteristic` | Worker or case characteristic, for example `Age group (55 - 64 yrs.)`, `Event - Falls, slips, trips`, `DAFW (31+ days)`, or the musculoskeletal disorders category |
| `measure` | `rate_per_10000` (cases per 10,000 full-time workers), `cases`, or `median_days_away` |

### `soii_dafw_detail.csv.gz`

| Column | Meaning |
| --- | --- |
| `detail_type` | `event`, `nature`, `part of body`, `source`, `occupation`, or `industry` |
| `detail_code` | OIICS, SOC or NAICS code in BLS format (`X` is padding) |
| `detail` | Name of the event, nature, body part, source, occupation or industry |
| `display_level` | Level in the hierarchy (filter on one level to avoid double counting) |
| `measure` | As above |

### `soii_dafw_states.csv`

Days-away rates, cases and median days away by `state` and `ownership`, all industries.

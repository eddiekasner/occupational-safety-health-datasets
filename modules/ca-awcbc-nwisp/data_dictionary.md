# Data Dictionary: AWCBC NWISP

Built by `scripts/build_dataset.R` from the 42 tables of the AWCBC publication *National Work
Injury, Disease and Fatality Statistics 2022-2024*. All values are counts of accepted claims.

## Shared columns

| Column | Meaning |
| --- | --- |
| `outcome` | `lost time claims` or `fatalities` (see README for definitions) |
| `year` | Calendar year (of injury or diagnosis for lost time claims; of acceptance for fatalities) |
| `value` | Number of accepted claims |
| `flag` | `X` = 3 or fewer claims, suppressed by AWCBC (`value` is missing) |

### `jurisdiction`

| Code | Province or territory |
| --- | --- |
| `Total` | Canada |
| `NL` | Newfoundland and Labrador |
| `PE` | Prince Edward Island |
| `NS` | Nova Scotia |
| `NB` | New Brunswick |
| `QC` | Quebec |
| `ON` | Ontario |
| `MB` | Manitoba |
| `SK` | Saskatchewan |
| `AB` | Alberta |
| `BC` | British Columbia |
| `NT/NU` | Northwest Territories and Nunavut (one board) |
| `YT` | Yukon |

## `nwisp_jurisdiction_trend.csv`

`outcome`, `year`, `jurisdiction`, `value`, `flag`: lost time claims from 1982 and fatalities from
1993 to 2024 (publication tables 1 and 22).

## `nwisp_jurisdiction.csv.gz`

Tables 2 to 8, 15, 23 to 29 and 36: each characteristic by province, 2022 to 2024.

| Column | Meaning |
| --- | --- |
| `characteristic` | `gender`, `age`, `nature of injury`, `part of body`, `source of injury`, `event`, `occupation` or `industry` |
| `code` | Category code (`Total` = all categories; `NC` = not coded) |
| `category` | Category name |

**Levels.** Nature of injury, part of body, source and event use two-digit codes from CSA Z795
(for example `31` = Malignant neoplasms and tumors). Codes ending in `0` with "uns." are
"unspecified" within a group, and "n.e.c." means "not elsewhere classified". Occupation uses NOC
2011 major groups (`00`, `01-05`, ..., `96`); industry uses NAICS sectors (`11`, `21`, ...,
`31-33`, ...). Within a characteristic, the categories (excluding `Total`) add up to the Total.

**Gender:** `1` Male, `2` Female, `3` Unknown, `NC` Not coded. **Age** (`01` to `12`): 15-19, 20-24,
..., 60-64, 65 years and over, Unknown.

## `nwisp_industry_occupation.csv.gz`

Tables 9 to 14, 16 to 21, 30 to 35 and 37 to 42: each characteristic within industry sectors or
occupation categories, Canada, 2023 and 2024.

| Column | Meaning |
| --- | --- |
| `by` | `industry` or `occupation` |
| `group_code`, `group` | Industry sector (NAICS code, for example `23` Construction) or occupation category (NOC 2011 broad category `0` to `9`); `Total` = all; `NC` = not coded; `NS` = occupation not stated |
| `characteristic`, `code`, `category` | As above (`gender`, `age`, `nature of injury`, `part of body`, `source of injury`, `event`) |

A few tables print no `Total` row (for example fatalities by age and industry). Values can differ
from the province tables by one or two claims because AWCBC's tables were not all produced at the
same time.

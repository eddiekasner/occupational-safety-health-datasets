# Data Dictionary: Child Labour (ILOSTAT and UNICEF)

Built by `scripts/build_dataset.R` from ILOSTAT's child labour tables and UNICEF's child labour
database.

## Rates (`rates.csv.gz`, ILOSTAT)

| Column | Meaning |
| --- | --- |
| `measure` | See below |
| `table` | ILOSTAT table code |
| `iso3`, `country` | Country code (ISO 3166 alpha-3) and name |
| `year` | Survey year |
| `survey`, `survey_code` | The survey the figure comes from, with its type before the dash: `LFS` labour force survey, `HS` household survey (including MICS and DHS), `CLS` child labour survey, `HIES` household income and expenditure survey, `PC` population census |
| `sex` | `Total`, `Male` or `Female` |
| `age` | `5-17`, `5-11`, `12-14` or `15-17` |
| `breakdown`, `category` | `None` (`Total`), `Area` (`Rural`, `Urban`) or `School attendance` (`Attending`, `Not attending`) |
| `value` | Share of the children in the group (%) |
| `flag` | `Unreliable` (small sample) or `Break in series`; blank if neither |
| `note` | ILOSTAT's notes on the survey, such as `Age coverage - minimum age: 16 years old` or `Geographical coverage: Main cities or metropolitan areas` |

Measures, each the share of children in the group who were:

| Measure | Meaning |
| --- | --- |
| `Economic activity` | In employment: work for pay or profit, or in a family business or farm |
| `Child labour` | In child labour, following the ILO's statistical definition (economic activity not allowed for the child's age, including hazardous work) |
| `Hazardous work` | In hazardous work: hazardous industries or occupations, long hours, night work, or hazardous conditions |
| `Child labour (general production boundary)` | In child labour, counting hazardous unpaid household services (household chores) as well as economic activity |
| `SDG 8.7.1: economic activity` | SDG indicator 8.7.1, economic activity only |
| `SDG 8.7.1: economic activity and household chores` | SDG indicator 8.7.1, including household chores above age-specific hours |

`Hazardous work` is part of `Child labour`, which is part of `Economic activity`. For 15 to 17 year
olds, `Child labour` and `Hazardous work` are the same.

## Counts (`counts.csv.gz`, ILOSTAT)

| Column | Meaning |
| --- | --- |
| `measure` | `Children in employment`, `Child labour`, `Hazardous work` or `Child population` |
| `table`, `iso3`, `country`, `year`, `survey`, `survey_code`, `sex`, `age`, `flag`, `note` | As above |
| `breakdown`, `category` | `Economic sector`: `Agriculture`, `Industry`, `Services`, `Not elsewhere classified`, `Total`. `Status in employment` (ICSE-93): `Employees`, `Employers`, `Own-account workers`, `Members of producers' cooperatives`, `Contributing family workers`, `Workers not classifiable by status`, `Total`. `None` for the child population |
| `thousands` | Number of children, in thousands |

Some categories are not published for small samples, so the categories can add up to less than
`Total`.

## UNICEF latest estimates (`unicef_latest.csv`)

| Column | Meaning |
| --- | --- |
| `indicator` | `Child labour (economic activities)`, `Child labour (economic activities and household chores)` (both SDG 8.7.1), or `Household chores (ages 10-14)` (share of 10 to 14 year olds doing household chores) |
| `area_code`, `area` | Country (ISO alpha-3 code) or region |
| `is_region` | `TRUE` for regional and global aggregates (UNICEF, SDG, African Union and other groupings) |
| `sex` | `Total`, `Male` or `Female` |
| `age` | Age group, usually `5-17` (a few surveys cover other ages) |
| `year` | Year of the survey (end of fieldwork) |
| `coverage_years` | Years the survey or the regional estimate covers (regional child labour estimates use surveys from 2020 to 2024; household chores, 2016 to 2024). UNICEF publishes regional estimates for child labour (economic activities) and household chores only |
| `value` | Share of children (%) |
| `data_source` | Survey, such as `MICS 2022-23, UNICEF and ILO calculations` |
| `status` | `Reported`, `Reanalysed` or `Estimated value` |
| `footnote` | UNICEF's notes |

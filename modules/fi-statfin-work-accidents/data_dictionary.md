# Data Dictionary: Finland Occupational Accident Statistics

Built by `scripts/build_dataset.R` from Statistics Finland's StatFin tables. Labels are Statistics
Finland's English labels, some shortened. Blank means not published (zero, confidential or not
applicable).

## Accidents (`accidents.csv.gz`)

From table 12ay. Wage and salary earners and entrepreneurs (not farmers), 2008 to 2024. Rows with
zero accidents are left out.

| Column | Meaning |
| --- | --- |
| `year` | Year of the accident |
| `status` | `Wage and salary earner` or `Entrepreneur` (entrepreneurs other than farmers, who insure themselves voluntarily) |
| `place` | `Workplace` (an accident at work, other than in traffic), `Traffic while working` (a road accident while working), `Commuting` (on the way between home and work) |
| `outcome` | Days of disability: `0-3 days`, `4-6 days`, `7-14 days`, `15-30 days`, `31-90 days`, `91-180 days`, `181 days or more`; or `Disability pension` (a workers' compensation pension for permanent loss of working capacity) or `Fatal`. The categories do not overlap |
| `sex` | `Male`, `Female` |
| `age_group` | `15-24`, `25-34`, `35-44`, `45-54`, `55-64`, `Unknown` |
| `section` | NACE Rev. 2 (TOL 2008) section letter, for example `C` manufacturing, `F` construction, `Q` health and social work; blank for the local government sector and unknown industry |
| `section_name` | Name of the section |
| `industry_division` | Two-digit NACE division, for example `43` specialised construction activities |
| `industry` | Name of the division, or `Local government sector` (municipal employees, reported as a sector rather than by industry) or `Unknown` |
| `accidents` | Number of accidents |

Add rows with `sum(accidents)`. "At least 4 days" (the threshold used in many countries and by
Eurostat) is every outcome except `0-3 days`.

## ESAW causes (`esaw_causes.csv`)

From tables 12b6, 12b9, 13p6, 13iw and 13h8. Workplace accidents (not traffic or commuting) of wage
and salary earners with at least 4 days of disability, 2008 to 2024.

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `variable` | `Specific physical activity` (what the worker was doing), `Deviation` (what went wrong), `Contact - mode of injury` (how the worker was hurt), `Type of injury`, `Part of body injured` |
| `code` | ESAW code of the category (`00` or `000` = missing) |
| `category` | Name of the category |
| `sex` | `Total`, `Male`, `Female` |
| `accidents` | Number of accidents |

## Rates (`rates.csv`)

From tables 12zz and 13ql. Wage and salary earners, accidents with at least 4 days of disability,
2018 to 2024.

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `sex` | `Total`, `Male`, `Female` |
| `section` | NACE section letter, `S1313` (local government sector), `X` (unknown) or `Total` |
| `section_name` | Name of the section |
| `place` | `All`, `At work (including traffic while working)`, `Workplace`, `Traffic while working`, `Commuting` |
| `accidents_4plus_days` | Accidents with at least 4 days of disability |
| `workers` | Wage and salary earners (from the Labour Force Survey) |
| `per_100000_workers` | Accidents per 100,000 wage and salary earners |
| `hours_thousands` | Hours worked by wage and salary earners, in thousands (only for `At work`) |
| `per_million_hours` | Accidents at work per million hours worked (only for `At work`) |

## Farmers (`farmers.csv`)

From table 129t. Farmers insured under the farmers' accident insurance scheme, 2000 to 2024.

| Column | Meaning |
| --- | --- |
| `year`, `sex`, `age_group` | As above (the oldest group is `55-`, 55 and over) |
| `insured_farmers` | Number of insured farmers |
| `accidents_4plus_days` | Accidents with at least 4 days of disability |
| `per_100000_farmers` | Accidents with at least 4 days of disability per 100,000 insured farmers |

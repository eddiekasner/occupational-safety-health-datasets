# Data Dictionary: OSHA ITA Summary (Form 300A)

Built by `scripts/build_dataset.R` from OSHA's yearly ITA 300A files. OSHA's own data dictionary
(`summary_data_dictionary.pdf`) is in `data/raw/` after running `fetch_data.R`. Letters in brackets
are the fields on Form 300A.

## Establishments (`establishments_<year>.csv.gz`)

| Column | Meaning |
| --- | --- |
| `establishment_id` | OSHA's ID for the establishment; the same in every year, and links to the ITA case detail data |
| `year` | Calendar year the injuries and illnesses happened |
| `establishment_name`, `company_name` | As entered by the employer (not standardized) |
| `ein` | Employer Identification Number (federal tax ID), digits only; not published for 2016 to 2018 and missing for 11% to 18% of establishments in later years |
| `city`, `state`, `zip_code` | Location (5-digit ZIP code) |
| `naics_code` | 6-digit North American Industry Classification System code (blank if invalid) |
| `naics_year` | NAICS version used (2012, 2017 or 2022; from 2023 only) |
| `naics_sector` | Industry sector, from the first 2 digits of `naics_code` |
| `ownership` | `Private`, `State government`, `Local government` (blank if not given) |
| `size` | Size by the most employees at any time in the year: `Under 20`, `20-249`, `250+` |
| `size_detail` | From 2023: `20-99` or `100-249` for the 20-249 group |
| `annual_average_employees` | Average number of employees during the year |
| `total_hours_worked` | Hours worked by all employees during the year |
| `any_cases` | `TRUE` if the establishment had any recordable injury or illness |
| `deaths` | Deaths [G] |
| `dafw_cases` | Cases with days away from work [H] |
| `djtr_cases` | Cases with job transfer or restriction (and no days away) [I] |
| `other_cases` | Other recordable cases [J] |
| `total_cases` | `deaths + dafw_cases + djtr_cases + other_cases` |
| `dafw_days` | Total days away from work [K] |
| `djtr_days` | Total days of job transfer or restriction [L] |
| `injuries` | Cases that were injuries [M1] |
| `skin_disorders`, `respiratory_conditions`, `poisonings`, `hearing_loss`, `other_illnesses` | Cases that were each type of illness [M2 to M6]. Respiratory conditions include COVID-19 cases that employers recorded as work-related |
| `submitted` | Date of the submission kept |
| `revised` | `TRUE` if the employer changed the summary after first submitting it |
| `plausible` | `TRUE` if the establishment had more than 0 and at most 50,000 employees and between 250 and 8,760 hours worked per employee (8,760 is the number of hours in a year). Use `filter(plausible)` before computing rates |

## Summary (`summary_by_industry.csv.gz`)

One row per year, `naics_sector`, `state`, `size`, `ownership` and `plausible`, with the number of
`establishments` and the sums of the count columns above.

## Computing rates

Injury rates are per 100 full-time workers, using 200,000 hours (100 workers x 40 hours x 50
weeks):

- **Total recordable case rate (TCR):** `total_cases / total_hours_worked * 200000`
- **DART rate** (days away, restricted or transferred): `(dafw_cases + djtr_cases) / total_hours_worked * 200000`

For a group of establishments, add up the cases and the hours first, then divide. These are the
same rates the BLS publishes from the SOII, so they can be compared (with care: see the README).

## Codes in OSHA's files

| OSHA field | Values | Here |
| --- | --- | --- |
| `establishment_type` | 1 not a government entity, 2 state government, 3 local government | `ownership` |
| `size` | 1 under 20, 2 20-249, 21 20-99, 22 100-249, 3 250+ | `size`, `size_detail` |
| `no_injuries_illnesses` | 1 had injuries or illnesses, 2 did not | `any_cases` |

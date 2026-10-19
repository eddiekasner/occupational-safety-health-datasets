# Finland: Occupational Accident Statistics (Statistics Finland)

**Scope:** Finland | **Publisher:** Statistics Finland, from the records of the workers'
compensation insurers compiled by the Finnish Workers' Compensation Center (TVK) | **Years in this
module:** 2008 to 2024 (rates from 2018; farmers from 2000)

## Background

Finnish employers must insure their employees against accidents at work and while commuting, under
a no-fault workers' compensation scheme. Every accident the insurers compensate, even with no time
off work, is counted. Statistics Finland publishes the counts in its StatFin database by industry,
age, sex, employment status, place of the accident (at the workplace, in traffic while working, or
while commuting) and outcome (days of disability, disability pension or death). Workplace accidents
are also classified with the European Statistics on Accidents at Work (ESAW) variables, which
describe what the worker was doing, what went wrong, how the worker was hurt, the injury and the
part of the body. Finland supplies the same data to Eurostat, so the module pairs well with the
Eurostat ESAW module in this repository.

## What one row represents

- `accidents.csv.gz`: the number of accidents for one combination of year, employment status, place,
  outcome, sex, age group and industry (2-digit NACE division). Only the most detailed level of
  each variable is kept, so rows can be added up without double counting.
- `esaw_causes.csv`: the number of workplace accidents of wage and salary earners (at least 4 days
  off work) in one ESAW category, by year and sex.
- `rates.csv`: wage and salary earners' accidents (at least 4 days off work) per 100,000 workers and
  per million hours worked, by year, sex, industry section and place.
- `farmers.csv`: farmers' accidents per 100,000 insured farmers, by year, sex and age group.

## Why it matters for OSH

- It counts **every compensated accident**, including the two thirds with three days off work or
  less that many countries never record.
- It has **denominators**: workers and hours worked by industry, so students can compare rates
  per worker and per hour.
- It separates **commuting accidents**, which make up a fifth of accidents and a third of deaths,
  and are mostly among women.
- The **ESAW variables** show how accidents happen (slips, trips and falls are the most common
  deviation) in the same terms used across Europe.
- **Farmers**, insured under a separate scheme, have more than twice the accident rate of wage and
  salary earners.

## Limitations to keep in mind

- **Compensated accidents only.** Occupational diseases are not included (Finland's register of
  occupational diseases is kept by the Finnish Institute of Occupational Health). Accidents that
  are never claimed are missing.
- **Who is covered.** Wage and salary earners are insured by law. Entrepreneurs (other than
  farmers) insure themselves voluntarily, so their counts are incomplete. Farmers have their own
  scheme and appear only in `farmers.csv`.
- **Local government.** Municipal employees are reported as the "Local government sector", not by
  industry (about a quarter of all accidents), so the industry figures leave out much of health
  care, social work and education in the public sector.
- **Denominators.** Workers and hours come from the Labour Force Survey, a sample survey; it was
  redesigned in 2021 and the rate series from 2018 was recalculated with the new method (earlier
  rate tables are not comparable). Rates for small industries are imprecise, and some cells are
  confidential. The accident counts in the rate tables can differ by about 1% from the main table.
- **Small numbers.** There are 20 to 55 fatal accidents a year, so year-to-year changes are mostly
  chance.
- **Age.** The published age groups run from 15 to 24 up to 55 to 64, plus `Unknown`.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns and categories |
| `data/tidy/accidents.csv.gz` | Accidents by year, status, place, outcome, sex, age and industry, 2008 to 2024 (1 MB) |
| `data/tidy/esaw_causes.csv` | Workplace accidents by ESAW variable, year and sex |
| `data/tidy/rates.csv` | Accident rates per 100,000 workers and per million hours, 2018 to 2024 |
| `data/tidy/farmers.csv` | Farmers' accidents and rates, 2000 to 2024 |
| `data/raw/` | Statistics Finland's tables as JSON-stat files (not committed; about 145 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the tables through Statistics Finland's API |
| `scripts/build_dataset.R` | Builds the tidy tables |

The build checks that the detailed rows of `accidents.csv.gz` add up to Statistics Finland's
national total for every year (for example, 116,358 accidents in 2024).

## Official documentation

- [Occupational accident statistics](https://stat.fi/en/statistics/ttap) (description, release
  notes and documentation)
- [StatFin database, occupational accidents](https://pxdata.stat.fi/PxWeb/pxweb/en/StatFin/StatFin__ttap/)
  (the tables used here: 12ay, 12b6, 12b9, 13p6, 13iw, 13h8, 12zz, 13ql and 129t)
- [Finnish Workers' Compensation Center](https://www.tvk.fi/en/) (the source of the data)

## Licence

Statistics Finland's data are published under the
[Creative Commons Attribution 4.0 International licence (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).
This module reshaped the tables and shortened some labels.

## Citation

Statistics Finland, Occupational accident statistics (StatFin database, tables 12ay, 12b6, 12b9,
13p6, 13iw, 13h8, 12zz, 13ql and 129t), https://stat.fi/en/statistics/ttap, licensed under CC BY
4.0. Reshaped by the authors of this repository.

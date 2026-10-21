# Hong Kong: Occupational Safety and Health Statistics (Labour Department)

**Scope:** Hong Kong SAR, China | **Publisher:** Labour Department, Occupational Safety and Health
Branch | **Years in this module:** 1999 to 2025 (industrial accidents), 2006 to 2025 (occupational
injuries and diseases), with detail by industry and type of accident for 2024 and 2025

## Background

Hong Kong counts work accidents in two ways, under two laws:

- **Industrial accidents** happen in *industrial undertakings* (factories, construction sites,
  catering and food and beverage businesses, and some others) as defined by the Factories and
  Industrial Undertakings Ordinance. The Labour Department publishes them with **accident rates
  per 1,000 workers**, by industry, back to 1999.
- **Occupational injuries** are all injuries at work reported under the Employees' Compensation
  Ordinance that cause death or **more than three days** of incapacity for work, in every economic
  activity. Industrial accidents are a subset. They come with **injury rates per 1,000
  employees**.

**Work fatalities** combine deaths in industrial undertakings with deaths at other workplaces under
the Occupational Safety and Health Ordinance. **Occupational diseases** are confirmed cases
reported under four ordinances, including the compensation schemes for occupational deafness and
for pneumoconiosis and mesothelioma.

The Labour Department publishes all this in an annual bilingual PDF, *Occupational Safety and
Health Statistics*. This module extracts the tables of the 2025 edition (ten-year series for 2016
to 2025, and tables for 2024 and 2025 by industry and type of accident) and of the 2015 edition
(series for 2006 to 2015, and for industrial accidents from 1999). It also includes two small
tables from data.gov.hk on the department's own occupational health clinics and services.

## What one row represents

- `trends.csv`: one figure (a count, a number of workers, or a rate) for one year, measure and
  industry.
- `occupational_diseases.csv`: the number of confirmed cases of one occupational disease in one
  year.
- `by_industry_2024_2025.csv`: industrial accidents or occupational injuries in one industry in
  2024 or 2025, with fatalities.
- `by_type_2024_2025.csv`: the same for one industry and one type of accident (for example, fall
  of person from height).
- `health_services.csv`: the number of one kind of occupational health service the Labour
  Department provided in one year (clinical consultations, medical examinations, hygiene surveys,
  and so on).
- `clinic_patients.csv`: new patients at the Labour Department's occupational health clinics in
  one year, by disease group.

## Why it matters for OSH

- **One of the steepest long-term declines anywhere.** Construction's accident rate fell from 64.3
  per 1,000 workers in 2006 to 21.3 in 2025, and industrial accidents in all industries fell from
  35,986 in 1999 to 6,486.
- **Two definitions side by side.** Industrial accidents and occupational injuries come from
  different laws and cover different workers, which is a good exercise in reading definitions
  before comparing numbers.
- **Construction is still the deadliest industry** (21 of the 22 industrial accident deaths in
  2025, 6 of them falls from height).
- **Occupational diseases are dominated by occupational deafness and silicosis**, and the
  deafness counts jump when compensation rules change, a clear example of how disease statistics
  follow the law.
- **Food and beverage services** have had more industrial accidents than construction every year
  since 2009, but very few deaths: slips, burns and cuts are frequent but rarely fatal.

## Limitations to keep in mind

- **Classification break in 2009.** Industries follow the Hong Kong Standard Industrial
  Classification (HSIC) Version 1.1 until 2008 and Version 2.0 from 2009. The Labour Department
  says the figures from 2009 are not comparable with earlier ones, except for construction.
  `Catering (to 2008)` and `Food and beverage services (from 2009)` are therefore kept as separate
  industries, and manufacturing and all industries also change coverage in 2009. Occupational
  injuries before 2009 also follow HSIC 1.1.
- **Workers.** Rates divide by the employment size from the Census and Statistics Department's
  Quarterly Report of Employment and Vacancies Statistics. For construction, this counts only
  manual workers on construction sites. Self-employed people are not well covered.
- **More than three days.** Occupational injuries count only deaths and injuries with more than
  three days of incapacity. They include some cases outside the Occupational Safety and Health
  Ordinance's reach, such as natural diseases at work and cases outside Hong Kong.
- **Work fatalities** are available only from 2016 in this module. Industrial accident deaths are
  available from 1999.
- **Occupational diseases.** Mesothelioma was added in April 2008 (`N.A.`, blank here, in 2006 and
  2007). From April 2010, compensation for occupational deafness was extended to hearing loss in
  one ear, and the counts from 2011 include it; 510 older cases of this kind were handled in 2010
  but are not in the 2010 figure. Gas poisoning is counted in cases, with the number of incidents
  in `incidents`.
- **2024 and 2025 detail.** The tables by type of accident use the Labour Department's own
  groupings of industries, which overlap (see the data dictionary). The occupational injury pages
  cover selected industries only, so they do not add up to the total.
- **Clinic patients** are people who chose to attend the Labour Department's clinics, not a measure
  of disease in the population. 2020 is low because of COVID-19.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns and categories |
| `data/tidy/trends.csv` | Industrial accidents, occupational injuries, fatalities, workers and rates by year and industry, 1999 to 2025 |
| `data/tidy/occupational_diseases.csv` | Confirmed occupational disease cases by disease, 2006 to 2025 |
| `data/tidy/by_industry_2024_2025.csv` | Industrial accidents and occupational injuries by industry, 2024 and 2025 |
| `data/tidy/by_type_2024_2025.csv` | The same by industry and type of accident |
| `data/tidy/health_services.csv` | The Labour Department's occupational health services, 2018 to 2025 |
| `data/tidy/clinic_patients.csv` | New patients at the occupational health clinics by disease group, 2017 to 2025 |
| `data/raw/` | The two PDF reports and two Excel workbooks (not committed; about 3 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the reports and workbooks |
| `scripts/extract_tables.py` | Reads the tables (Python, with pdfplumber and openpyxl) |

Checked by `scripts/extract_tables.py`: the occupational diseases add up to the published total in
every year; in the 2024 and 2025 tables, the types of accident add up to each industry's total,
each industry's total matches the table by industry, and the manufacturing industries add up to
manufacturing.

## Official documentation

The reports are on the Labour Department's website, [www.labour.gov.hk](https://www.labour.gov.hk)
(Occupational Safety, then Statistics: "Occupational Safety and Health Statistics"). The
definitions are on the first pages of each report and the notes under each table. The clinic
tables are on [data.gov.hk](https://data.gov.hk) (Labour Department datasets).

## Terms of use

The data.gov.hk terms of use allow anyone to browse, download, distribute, reproduce and use the
data for commercial and non-commercial purposes, free of charge, with acknowledgement of the
Government of the Hong Kong SAR as the source. The PDF reports are © the Government of the Hong
Kong SAR (Labour Department); this module reproduces only statistical figures from them, for
teaching, with attribution.

## Citation

Labour Department, Hong Kong SAR Government, Occupational Safety and Health Statistics (2015 and
2025 editions), www.labour.gov.hk; and Labour Department occupational health datasets,
data.gov.hk. Tables extracted by the authors of this repository.

# Chile: Work Accidents, Commuting Accidents and Occupational Diseases (SUSESO)

**Scope:** Chile, workers covered by the insurance of Law 16.744 | **Publisher:** Superintendencia
de Seguridad Social (SUSESO) | **Years:** 2010 to 2025 (national series), 2013 to 2025 (detail)

## Background

Chile's Law 16.744 (1968) makes employers insure their workers against work accidents, commuting
accidents and occupational diseases. Four bodies administer the insurance:

- three private, non-profit **mutual insurers** (mutualidades): the Asociación Chilena de Seguridad
  (**ACHS**), the Mutual de Seguridad de la Cámara Chilena de la Construcción (**MUSEG**) and the
  Instituto de Seguridad del Trabajo (**IST**), which cover most workers;
- the public **Instituto de Seguridad Laboral (ISL)**, which covers employers who do not join a
  mutual insurer.

The Superintendencia de Seguridad Social (SUSESO) supervises them and publishes a statistical
yearbook each year, *Estadísticas de la Seguridad Social*. Its chapter I has about 60 tables on
the insurance: protected workers, work accidents, commuting accidents and occupational diseases,
accident rates, days lost, and deaths, by insurer, economic sector, region, sex and size of
employer. This module extracts them from the 2014 to 2025 yearbooks.

## What one row represents

Every table has one value per row: one measure (for example `Cases` or `Accidents per 100
workers`) of one kind of case (`case_type`) in one year, for one insurer, and:

- `national.csv`: the whole country (some values by sex).
- `by_sector.csv`: one economic sector.
- `by_region.csv`: one region.
- `by_size.csv`: one size of employer (number of workers).
- `by_sex.csv`: one sex, by insurer, sector or region.

## Why it matters for OSH

- **The work accident rate halved.** Among the mutual insurers' workers, work accidents fell from
  5.4 per 100 workers in 2010 to 2.4 in 2025. Among all insured workers, deaths from work accidents
  fell from 5.3 per 100,000 workers in 2013 to 3.3 in 2025.
- **COVID-19 as an occupational disease.** Occupational disease cases rose from about 5,000 to
  7,000 a year before 2020 to 22,631 in 2020 and 40,721 in 2022 (mutual insurers), because COVID-19
  caught at work counted. The 2025 yearbook leaves COVID-19 out: it counts 8,595 occupational
  diseases in 2022, for all four insurers.
- **Commuting.** Commuting accidents are about 3 in 10 accidents, and 115 workers died commuting
  in 2025. Women have more commuting accidents than men (32,897 against 28,563 in 2025).
- **Who dies at work.** Men had 209 of the 221 deaths from work accidents in 2025 (95%) in the
  table by sex. Transport and communications (13.7 per 100,000 workers) and mining (12.8) had the
  highest death rates.
- **Insurers compete.** The mutual insurers are private bodies that compete for employers, and
  their accident rates differ. This is a good case for asking what drives differences in reported
  rates.

## Limitations to keep in mind

- **Who is covered.** Workers whose employers contribute to the insurance, and self-employed people
  who contribute. Informal workers are not covered.
- **Mutual insurers or all insurers.** Up to the 2024 yearbook, the tables of accident counts and
  rates cover only the three mutual insurers, not the ISL (`insurer` is `Mutual insurers`). The
  2025 yearbook includes the ISL in its accident tables, for 2021 to 2025 (`insurer` is `Total`).
  Tables of deaths, and the national tables of protected workers, include the ISL in every year.
  Do not compare a `Mutual insurers` total with a `Total`. Accident rates are for the mutual
  insurers only.
- **Denominators changed.** Up to the 2024 yearbook, accident rates are accidents per protected
  worker. The 2025 yearbook counts protected employment relationships (one person can have
  several) and unique protected persons separately (`measure`), and its rates are per employment
  relationship.
- **Sector groupings.** Most tables use about 17 sections of the economic classification
  (`grouping` is `Sections`); the 2014 yearbook and the tables of death rates by sector use SUSESO's
  broad groups (`Broad groups`). Do not compare across groupings.
- **Occupational diseases changed in 2025.** Up to the 2024 yearbook, occupational diseases include
  COVID-19. The 2025 yearbook leaves out COVID-19 and counts by date of notification, for 2021 to
  2025. Its figures are kept as a separate `case_type`, `Occupational diseases (excluding
  COVID-19)`, so both series are in the files.
- **Revisions.** Each yearbook repeats the last 2 to 5 years, and later yearbooks revise earlier
  figures (for example occupational diseases at ACHS in 2014: 1,691 in the 2014 yearbook, 2,099
  later). Each year is taken from the latest yearbook that has it (`source_yearbook`).
- **2020.** Lockdowns and the pandemic reduced accidents in 2020 and raised occupational diseases.
- **Published totals.** In 2018, commuting accidents by region add up to about 2% more than the
  published totals. In 2025, the table of deaths by sex has 221 deaths from work accidents and the
  table by insurer 225. Figures are kept as published, with one correction: in the 2025 table of
  accidents by insurer and sex, SUSESO swapped the rows of MUSEG and IST (their totals belong to the
  other insurer in the table by insurer), and this module swaps them back.
- **Totals of the mutual insurers.** Where a table gives ACHS, MUSEG and IST but not their total
  (the tables of deaths, and the 2025 yearbook), the module adds `Mutual insurers` as the sum of
  the three, for counts.
- **Translations.** English names of sectors were translated for this module; the Spanish names
  are kept.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns, measures and categories |
| `data/tidy/national.csv` | National series by insurer: protected workers, cases, accident rates, days lost, mean days lost, deaths and death rates, 2010 to 2025 |
| `data/tidy/by_sector.csv` | The same by economic sector |
| `data/tidy/by_region.csv` | Protected workers, cases, days lost and deaths by region |
| `data/tidy/by_size.csv` | Protected workers, cases and days lost by size of employer |
| `data/tidy/by_sex.csv` | Protected workers, cases, days lost and deaths by sex, and by sex and insurer, sector or region |
| `data/raw/` | SUSESO's 12 yearbooks (not committed; about 35 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the yearbooks listed on SUSESO's annual statistics page |
| `scripts/extract_tables.py` | Finds chapter I's tables by their titles, reads them (Python, with openpyxl) and runs the checks |
| `scripts/labels_es_en.csv` | Spanish to English labels for sectors and regions |

Checked by `scripts/extract_tables.py`, for counts of cases, deaths and days lost:

- The insurers add up to the national totals (180 of 180 for the mutual insurers, 88 of 88 for
  all insurers).
- The sectors (608 of 608), sizes of employer (416 of 416) and sexes (2,227 of 2,227) add up to
  their totals.
- The regions add up to their totals in 467 of 470 cases (the exceptions are 2018 commuting
  accidents).
- The totals by insurer in the tables by sex equal those in the tables by insurer of the same
  yearbook in 285 of 293 cases (the exceptions are 2025 deaths, which differ by 1 to 4).

## Official documentation

The yearbooks are on SUSESO's website, under Estadísticas, then
[Estadísticas anuales](https://www.suseso.gob.cl/608/w3-propertyvalue-10364.html). The notes
under each table define the measures. SUSESO's
[Observatorio de Seguridad y Salud en el Trabajo](https://www.suseso.gob.cl) publishes more
detailed data.

## Terms of use

SUSESO's [conditions of use](https://www.suseso.gob.cl/606/w3-article-19630.html) ask users to use
the site's contents lawfully and prohibit using them for commercial purposes. This module
reproduces only statistical figures from the yearbooks, for non-commercial teaching, with
attribution. Do not use these files commercially.

## Citation

Superintendencia de Seguridad Social. *Estadísticas de la Seguridad Social* (2014 to 2025 editions),
chapter I: Régimen de Accidentes del Trabajo y Enfermedades Profesionales. www.suseso.gob.cl.
Tables extracted and labels translated by the authors of this repository.

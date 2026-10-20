# Singapore: Workplace Safety and Health Statistics (Ministry of Manpower)

**Scope:** Singapore | **Publisher:** Ministry of Manpower (MOM), Occupational Safety and Health
Division | **Years in this module:** 2018 to 2025

## Background

In Singapore, employers must report workplace injuries to MOM under the Workplace Safety and Health
(Incident Reporting) Regulations and the Work Injury Compensation Act, and doctors must report
occupational diseases. MOM publishes national statistics every year in its Workplace Safety and
Health Report: fatal, major and minor injuries, occupational diseases, dangerous occurrences and
man-days lost, by industry, with rates per 100,000 workers. Singapore's national target is a
workplace fatal injury rate below 1.0 per 100,000 workers by 2028.

MOM now publishes these statistics only as PDF reports (they used to be on data.gov.sg). This
module extracts the statistical tables of the 2019, 2021, 2023 and 2025 reports, which together
cover 2018 to 2025.

## What one row represents

- `injuries_by_industry.csv`: one figure (a count or a rate per 100,000 workers) for one year,
  measure (fatal injuries, major injuries, minor injuries, occupational diseases, man-days lost) and
  industry.
- `injury_types.csv`: the number of major or minor injuries of one type in one year.
- `occupational_diseases.csv`: the number of confirmed occupational disease cases of one type in
  one year.

## Why it matters for OSH

- A small, rich economy with a **national fatality target** and detailed reporting rules: a good
  case study of how a government measures progress.
- A **change in reporting rules** in 2021 is visible in the data, because MOM publishes minor
  injuries under both the old and the new rule.
- **Construction, marine and transport** dominate deaths, and much of their workforce is migrant
  workers.
- **Noise-induced hearing loss** and **musculoskeletal disorders** make up most occupational
  disease cases, and the hearing loss counts show how much surveillance drives disease statistics.

## Limitations to keep in mind

- **Reporting rules changed.** Before 2021, major and minor injuries were those with four or more
  days of medical leave or at least 24 hours in hospital. From 2021, employers must report any
  injury with medical leave or light duties. MOM publishes minor injuries and man-days lost both
  ways (`series`): `Standard` (the old rule) and `New (any medical leave)`. Major injuries are
  barely affected (584 against 590 in 2023); from 2023 the major injury tables follow the new rule.
- **Who is covered.** Injuries to employees, and deaths of employees and self-employed people.
  Injuries to self-employed people count only if they are taken to hospital. Work-related traffic
  accidents (while working) are included; MOM's definitions do not mention commuting. Platform
  workers (such as delivery riders) are reported only from 2025; national figures for 2024 and 2025
  exclude them except for fatal injuries, where the 2025 report includes them (2 deaths in 2025).
- **Selected industries.** Each report lists only selected industries and sub-industries, and the
  list changes, so an industry may be missing in some years. Industry names were harmonised by
  this module (`industry`; the published name is in `label`), and each sub-industry's `parent` is
  given. The reports changed to the Singapore Standard Industrial Classification 2020 in this
  period, and MOM revised earlier figures; each year comes from the latest report that covers it.
- **Small numbers.** There are 30 to 46 deaths a year; rates for small industries swing widely.
- **Occupational diseases.** Most cases are found through workplace health surveillance (for
  example, audiometric tests for noise-exposed workers), which MOM enhanced in 2021, so changes in
  surveillance can change the counts. Diseases with long latency, such as cancers, are rarely
  confirmed.
- **Man-days lost** are estimated with a table of scheduled charges (a death counts as 6,000 days),
  not counted directly.
- **Published totals.** In a few years the parts of a table add up to slightly more or less than
  the published total (for example, major injury types in 2025: 585 against 586). Figures are kept
  as published.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns and categories |
| `data/tidy/injuries_by_industry.csv` | Injuries, occupational diseases and man-days lost by industry, counts and rates, 2018 to 2025 |
| `data/tidy/injury_types.csv` | Major and minor injuries by type |
| `data/tidy/occupational_diseases.csv` | Occupational disease cases by type |
| `data/raw/` | MOM's reports (PDF; not committed; about 9 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the four reports |
| `scripts/extract_tables.py` | Reads the statistical tables from the PDFs (Python, with pdfplumber) |

Checked against each report's summary tables: the "All industries" figures for fatal, major and
minor injuries, occupational diseases and man-days lost match the published national figures for
every year, and the occupational disease groups add up to the published totals.

## Official documentation

The reports are on the Ministry of Manpower's website, [www.mom.gov.sg](https://www.mom.gov.sg)
(Workplace safety and health, then Reports and statistics: "Workplace Safety and Health Report,
National Statistics"). Each report's Annex C explains the sources, coverage and definitions.

## Terms of use

The reports are © Government of Singapore (Ministry of Manpower), all rights reserved. MOM's terms
of use permit fair dealing for private study, research, criticism or review and do not allow
reproduction or reuse for any commercial purpose without MOM's written permission. This module
reproduces only statistical figures from the reports, for non-commercial teaching, with
attribution. Do not use these files commercially; for other uses, refer to MOM's terms of use.

## Citation

Ministry of Manpower, Singapore, Workplace Safety and Health Report: National Statistics (2019,
2021, 2023 and 2025 editions), www.mom.gov.sg. Tables extracted by the authors of this repository.

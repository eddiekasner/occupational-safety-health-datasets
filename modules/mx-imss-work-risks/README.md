# Mexico: Work Risks in the IMSS Statistical Yearbooks

**Scope:** Mexico, workers covered by IMSS's work risk insurance | **Publisher:** Instituto
Mexicano del Seguro Social (IMSS) | **Years in this module:** 2016 to 2024, with national figures
and occupational diseases from 2011

## Background

The Mexican Social Security Institute (IMSS) insures most private-sector employees in Mexico.
Under the Social Security Law, employers pay for *work risk insurance* (seguro de riesgos de
trabajo), which pays medical care, wages during incapacity, and pensions after permanent
incapacity or death. IMSS records every case, and publishes national tables each year in its
statistical yearbook, the *Memoria Estadística*. Chapter VII, "Salud en el Trabajo", is an Excel
workbook of about 50 tables.

Mexican law counts three kinds of **work risk** (riesgo de trabajo):

- **Work accidents** (accidentes de trabajo): an injury or death suddenly caused at or because of
  work, wherever and whenever the work is done.
- **Commuting accidents** (accidentes en trayecto): accidents on the direct way between home and
  work. They are covered and counted as work risks, which many countries do not do.
- **Occupational diseases** (enfermedades de trabajo): diseases caused by work or the work
  environment, including all those listed in the Federal Labour Law.

This module extracts the main tables from the 2016 to 2024 yearbooks. It covers national figures,
IMSS's 35 state offices, economic activity, age and sex, occupational diseases, causes of
accidents, injured body regions, and the most affected occupations.

## What one row represents

- `national.csv`: one national figure (companies, workers, cases, permanent incapacities or
  deaths) for one year and type of risk.
- `by_state.csv`: cases, permanent incapacities and deaths of one type of risk in one IMSS state
  office in one year, with the office's companies and workers.
- `by_activity.csv`: cases of one type of risk in one division of economic activity in one year,
  with workers.
- `by_age_sex.csv`: workers and cases (all work risks) in one age group and sex in one year.
- `occupational_diseases.csv`: occupational disease cases with one diagnosis in one year.
- `accident_causes.csv`: work or commuting accidents with one external cause, in one sex and age
  group, in one year.
- `body_region_injury.csv`: work accidents with one injured body region and type of injury, in one
  sex, in one year.
- `occupations.csv`: work accidents in one occupation with one type of injury, in one sex, in one
  year.

## Why it matters for OSH

- **A large middle-income country** with about 22 million insured workers. The work accident rate
  fell from 2.8 to 1.9 per 100 workers between 2011 and 2024, while the number of insured workers
  grew by almost half.
- **COVID-19 as an occupational disease.** In 2020, IMSS accepted 109,287 cases of COVID-19 as
  occupational disease, about nine times the number of all occupational disease cases in 2019. COVID-19 also
  caused 526 of the 682 occupational disease deaths that year. It is a vivid example of how
  compensation rules shape disease statistics.
- **Commuting accidents** have grown faster than work accidents. They rose from 110,174 in 2011 to
  175,357 in 2024, and motorcyclists are the largest group.
- **Musculoskeletal disorders** (back disorders, shoulder lesions, carpal tunnel syndrome) have
  overtaken hearing loss and pneumoconiosis as the main recognised occupational diseases.

## Limitations to keep in mind

- **Who is covered.** Only workers insured by IMSS: mostly private-sector employees in formal jobs.
  Government employees (covered by ISSSTE), the armed forces and PEMEX have their own schemes. The
  self-employed and the informal sector are not covered, and they are more than half of Mexico's
  workforce.
- **Cases are counted when they end.** A case is counted in the year it is closed: by medical
  discharge, the start of a permanent incapacity, or death. It is not counted in the year the
  accident happened.
- **Workers** are the annual average of workers insured against work risks, from IMSS's monthly
  employer reports.
- **COVID-19.** From 2020, IMSS counted COVID-19 (ICD-10 U07 to U12, U92) and "COVID-19-related
  respiratory diseases" (J01, J04 to J06, J10 to J18, J20 to J21) as occupational diseases when
  work-related. For 2020 to 2023 the state table splits
  occupational diseases into COVID-19, COVID-19-related respiratory diseases, and other diseases.
  Compare occupational diseases across years only with COVID-19 left out.
- **Revisions.** In `national.csv`, each year comes from the latest yearbook that has it
  (`source_yearbook`). The other tables come from each year's own yearbook. The 2024 yearbook
  revised 2022's occupational diseases from 78,647 to 35,344 cases in its summary table. Its
  table by diagnosis still shows 78,647, and so does `occupational_diseases.csv`.
- **Disease diagnoses.** The disease total includes cases with no recorded diagnosis, so in 2022
  to 2024 the diagnoses add up to less than the total. In 2016 to 2019 they add up to 5 to 13
  more than the published total.
- **State offices.** IMSS's 35 state offices (OOAD, called *delegaciones* until 2018) match the 32
  states, except that Mexico City, the State of Mexico and Veracruz have two offices each. The
  `state` column groups them by state.
- **Selected occupations.** `occupations.csv` lists the 24 occupations with the most work accidents
  each year, and the rest as "Other, less frequent". The list changes between years.
- **Translations.** English labels were translated for this module (`scripts/labels_es_en.csv`).
  The Spanish labels are kept.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns and categories |
| `data/tidy/national.csv` | National companies, workers, cases, permanent incapacities and deaths by type of risk, 2011 to 2024 |
| `data/tidy/by_state.csv` | The same by IMSS state office, 2016 to 2024 |
| `data/tidy/by_activity.csv` | Workers and cases by division of economic activity |
| `data/tidy/by_age_sex.csv` | Workers and cases by age group and sex |
| `data/tidy/occupational_diseases.csv` | Occupational disease cases by diagnosis, 2011 to 2024 |
| `data/tidy/accident_causes.csv` | Work accidents (2016 to 2024) and commuting accidents (2019 to 2024) by external cause, sex and age group |
| `data/tidy/body_region_injury.csv` | Work accidents by body region, type of injury and sex |
| `data/tidy/occupations.csv` | Work accidents in the most affected occupations, by type of injury and sex |
| `data/raw/` | The nine yearbook workbooks (not committed; about 11 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the workbooks |
| `scripts/extract_tables.py` | Reads the tables (Python, with openpyxl) |
| `scripts/labels_es_en.csv` | Spanish to English labels |

Checked by `scripts/extract_tables.py`. In every year, these all add up to the national totals:

- The state offices (cases, permanent incapacities, deaths and workers).
- The economic activities.
- The age and sex groups.
- The causes of work and commuting accidents.
- The body regions and the occupations.

The exception is 2020, where the activities add up to 152 more cases than the national total.

## Official documentation

The yearbooks are on IMSS's website, under "Memoria Estadística"
([2024 edition](https://www.imss.gob.mx/conoce-al-imss/memoria-estadistica-2024)). Each
workbook's "Glosario" sheet defines the terms. The notes under each table explain coverage and
classifications.

## Terms of use

We found no terms of use on the yearbook pages. The yearbooks are public statistical publications
of the Mexican government, and this module reproduces only statistical figures from them, for
teaching, with attribution. Mexico's open data licence (Libre Uso MX), which covers government
data published as open data, allows reuse with attribution.

## Citation

Instituto Mexicano del Seguro Social, Memoria Estadística, chapter VII: Salud en el Trabajo
(2016 to 2024 editions), www.imss.gob.mx. Tables extracted and labels translated by the authors of
this repository.

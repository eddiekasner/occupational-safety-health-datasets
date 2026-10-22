# Argentina: Work Accidents and Occupational Diseases (Superintendencia de Riesgos del Trabajo)

**Scope:** Argentina, workers covered by the occupational risk system | **Publisher:**
Superintendencia de Riesgos del Trabajo (SRT) | **Years:** 1996 to 2025 (some tables start later)

## Background

Since July 1996, employers in Argentina must insure their employees against work accidents and
occupational diseases under the Occupational Risks Law (Ley 24.557), with a private insurer (an
ART, Aseguradora de Riesgos del Trabajo) or, for some large employers and public bodies, by
self-insuring. Insurers notify every case to the Superintendencia de Riesgos del Trabajo (SRT),
which regulates the system and publishes statistics. From November 2014 the system also covers
domestic workers (casas particulares).

SRT counts:

- **All cases** ("global"): work accidents, occupational diseases, **commuting accidents** (in
  itinere) and relapses (reingresos) of earlier cases.
- **Work accidents and occupational diseases** (AT y EP): the same without commuting accidents and
  relapses.

It publishes counts of cases and deaths, and rates per covered worker. This module extracts all of
SRT's historical series: national figures by sector from 1996, and rates by province, sex, age
group, size of employer and detailed (3-digit) sector.

## What one row represents

Every table has one value per row: one measure (for example `Cases per 1,000 workers`), for one
kind of case (`All cases` or `Work accidents and occupational diseases`), one population (`scope`:
`Workplaces`, `Domestic workers` or `Total system`) and one year, and:

- `national.csv`: one sector (1 digit), or the total.
- `by_jurisdiction.csv`: one province, overall or in one sector.
- `by_sex_age.csv`: one sex and age group.
- `by_sex_sector.csv`: one sex and sector.
- `by_size.csv`: one size of employer (number of workers).
- `by_sector_3digit.csv`: one detailed sector (3-digit code), for both sexes or one sex.

## Why it matters for OSH

- **A long decline.** The death rate fell about fourfold, from 221 per million covered workers in
  1997 to 59 in 2025. Cases per 1,000 workers fell from 77 to 51.
- **Commuting kills.** In 2025, 568 covered workers died, but only 312 of the deaths were work
  accidents or occupational diseases. The other 256 were commuting accidents and relapses of
  earlier cases; Argentina counts and compensates commuting accidents, which many countries do not.
- **Small employers.** Employers with 2 to 10 workers have death rates about three times those of
  employers with more than 1,500 workers, but lower rates of non-fatal cases. That pattern
  suggests that small employers under-report non-fatal injuries.
- **Young men.** Men aged 20 to 24 have the highest rate of cases (75 per 1,000 in 2024), about
  twice that of women of the same age.
- **Construction, agriculture and transport** have the highest death rates.

## Limitations to keep in mind

- **Who is covered.** Only registered employees whose employer insures them (about 10 million
  people). Informal workers, who are a large part of Argentina's workforce, and the self-employed
  are not covered. Domestic workers are covered from November 2014.
- **Rates count serious cases only.** Rates (`Cases per 1,000 workers`) count cases with at least
  one day off work or a disabling injury; the counts in `national.csv` (`Cases`) include all
  notified cases. Death rates are per million covered workers, and lethality is deaths per 100,000
  notified cases.
- **Sector classifications changed in 2019.** Up to 2018, sectors are SRT's groups of the
  International Standard Industrial Classification Revision 2 (`CIIU Rev. 2`; 9 groups at 1 digit);
  from 2019, ISIC Revision 4 (`CIIU Rev. 4`; 21 sections). Sectors cannot be compared across the
  break without a crosswalk; the totals can.
- **COVID-19.** From 2019, the national series exclude COVID-19 accepted as an occupational disease
  (outside the official list) up to 2023. 2020 is low because of lockdowns.
- **1996 is a partial year** (the system began in July 1996).
- **Small numbers.** Death rates for small provinces, sectors or age groups swing widely from year
  to year.
- **Translations.** English names of sectors were translated for this module; the 3-digit sector
  names were translated with the help of an AI model, and checked against ISIC Revision 4 titles
  where the codes match. The Spanish names are kept.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns, measures and categories |
| `data/tidy/national.csv` | Cases, cases with days lost, deaths, rates, lethality and mean days lost by sector, 1996 to 2025 |
| `data/tidy/by_jurisdiction.csv` | Rates of cases and deaths by province, overall (2007 to 2024) and by sector |
| `data/tidy/by_sex_age.csv` | Rates of cases and deaths, and lethality, by sex and age group, 2011 to 2024 |
| `data/tidy/by_sex_sector.csv` | The same by sex and sector, 2011 to 2024 |
| `data/tidy/by_size.csv` | Rates of cases and deaths by size of employer, 1997 to 2024 |
| `data/tidy/by_sector_3digit.csv` | Rates of cases and deaths by 3-digit sector, for both sexes (2010 to 2024) and by sex (2012 to 2024) |
| `data/raw/` | SRT's 21 workbooks (not committed; about 3 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the workbooks listed on SRT's historical series page |
| `scripts/extract_tables.py` | Reads the tables (Python, with openpyxl) and runs the checks |
| `scripts/labels_es_en.csv`, `scripts/labels_sector3_es_en.csv` | Spanish to English labels |

Checked by `scripts/extract_tables.py`:

- In `national.csv`, the sectors add up to the total for workplaces, and workplaces plus domestic
  workers add up to the whole system, for every count and year.
- The national rates in the tables by province (94 of 94) and by 3-digit sector (80 of 80) agree
  with the national series to within 1%.
- The totals for each sex agree between the tables by age and by sector (455 of 456 within 1%).

## Official documentation

SRT's statistics are at [www.srt.gob.ar/estadisticas](https://www.srt.gob.ar/estadisticas/acc_ultimos_datos.php):
the [historical series](https://www.srt.gob.ar/estadisticas/acc_serie_historica.php) and the
[definitions and methodological notes](https://www.srt.gob.ar/estadisticas/acc_definiciones.php).

## License and citation

The content of Argentina.gob.ar, including SRT's statistics pages, is licensed under a Creative
Commons Attribution 4.0 International licence: reuse is allowed with attribution.

Superintendencia de Riesgos del Trabajo. *Serie histórica de accidentabilidad laboral.* Accessed
[date] from https://www.srt.gob.ar/estadisticas. Tables extracted and labels translated by the
authors of this repository.

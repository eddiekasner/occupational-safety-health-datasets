# France: Work Accidents, Commuting Accidents and Occupational Diseases (Assurance Maladie)

**Scope:** France (general scheme) | **Publisher:** Caisse nationale de l'Assurance Maladie (Cnam),
occupational risks branch (risques professionnels) | **Years in this module:** national totals 2005
to 2024; sector detail 2015 to 2024

## Background

In France, the national health insurance fund also runs workers' compensation for the "general
scheme" (régime général), which covers most private-sector employees. Employers report accidents,
doctors certify occupational diseases, and the insurance decides whether each claim is work-related.
Assurance Maladie publishes the recognised claims as open data on data.ameli.fr: work accidents,
commuting accidents (between home and work, which French law covers) and occupational diseases, by
sector of activity (the NAF classification, the French version of the EU's NACE), with the number
of employees, deaths, days off work, permanent incapacities, causes and costs.

Occupational diseases are recognised mostly through "tables" (tableaux): lists of diseases, with the
exposures and jobs that cause them, for which work is presumed to be the cause. Other diseases,
including psychological disorders, must be recognised case by case.

## What one row represents

- `claims_by_sector.csv.gz`: one year, risk (work accidents, commuting accidents, occupational
  diseases or all) and sector: claims, employees, frequency index, deaths, days off work and
  permanent incapacities.
- `accident_causes.csv.gz`: the share of work or commuting accidents with one cause, by year and
  sector.
- `occupational_diseases.csv.gz`: occupational disease cases in one group (and, for diseases outside
  the tables, one ICD-10 chapter), by year and sector.
- `msd.csv.gz` and `msd_body_parts.csv.gz`: musculoskeletal disorders by compensation table, and
  shares by body part and sex.
- `psychological_disorders.csv`, `companies_by_size.csv.gz`, `regions.csv`, `costs.csv`: see the
  data dictionary.
- `sectors.csv`: the sector codes with French and English names.

## Why it matters for OSH

- **Detailed sectors with denominators:** accidents and employees for about 730 detailed activities,
  so students can find the riskiest jobs (home help, nursing homes and roofing are near the top).
- **Twenty years of national figures** show the work accident frequency falling from 38 to 26 per
  1,000 employees.
- **Commuting accidents** are counted, and their causes show the rise of bicycles and scooters.
- **Occupational diseases** are dominated by musculoskeletal disorders; asbestos diseases are still
  about 2,000 a year; recognised psychological disorders grew more than fivefold since 2015.
- **Costs**: about 10 billion euros of benefits a year.

## Limitations to keep in mind

- **Who is covered.** The general scheme only: employees of private companies (and some public
  employees on contracts), and self-employed people who chose to insure themselves. Farmers and farm
  workers (who have their own scheme, the MSA), most civil servants and most self-employed people
  are not included.
- **Recognised claims.** Only claims the insurance accepted. Accidents count if they caused at least
  one day off work. Occupational diseases are known to be under-reported; a commission estimates the
  under-reporting regularly.
- **Confidential cells.** To protect companies, figures are withheld ("NS", blank here) when a
  sector has fewer than three companies or one company has more than 85% of its employees. In some
  years (2016, 2018, 2020, 2023) the row for claims with an unknown sector is withheld, so the
  sectors add up to less than the national total (by under 1% for accidents and up to 13% for
  occupational diseases in 2016).
- **Sector detail from 2015.** For 2005 to 2014, only national totals are published.
- **Frequency index.** Accidents per 1,000 employees. It is not computed for occupational diseases
  or for 2020, when the COVID-19 pandemic and short-time working made the number of employees a poor
  measure of exposure.
- **Deaths** include sudden deaths at work (often cardiovascular), which French law presumes to be
  work accidents; counts of deaths changed markedly in 2019, so check Assurance Maladie's methods
  before comparing years.
- **Causes** are shares (percentages, rounded) of accidents, not counts.
- **English names** of the 732 detailed sectors were translated from French with AI, using the
  official English NACE titles where they apply; French names are kept in `sectors.csv`.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns and categories |
| `data/tidy/claims_by_sector.csv.gz` | Claims, employees, frequency, deaths, days off and incapacities by sector |
| `data/tidy/sectors.csv` | Sector codes with English and French names |
| `data/tidy/accident_causes.csv.gz` | Causes of work and commuting accidents (shares) by sector |
| `data/tidy/occupational_diseases.csv.gz` | Occupational diseases by group, ICD-10 chapter and sector |
| `data/tidy/msd.csv.gz`, `data/tidy/msd_body_parts.csv.gz` | Musculoskeletal disorders by table, body part and sex |
| `data/tidy/psychological_disorders.csv` | Recognised psychological disorders by sector |
| `data/tidy/companies_by_size.csv.gz` | Companies and employees by company size and sector |
| `data/tidy/regions.csv` | Claims, employees and frequency by region, 2005 to 2024 |
| `data/tidy/costs.csv` | Benefits paid by risk and type |
| `data/raw/` | Assurance Maladie's CSV files (not committed; about 200 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the datasets through data.ameli.fr's API |
| `scripts/build_dataset.R` | Builds the tidy tables with English labels |
| `scripts/labels_fr_en.csv`, `scripts/naf5_en.csv` | French categories and sector names with their English translations |

Checked against Assurance Maladie's published national figures (for example, 555,803 work
accidents with time off and 759 deaths in 2023), and the build checks that the sectors add up to
the national totals.

## Official documentation

- [Data ameli](https://data.ameli.fr/) (the open data portal; search for "Risques professionnels";
  each dataset's page describes its fields)
- Assurance Maladie's "Data risques professionnels" site and annual report on occupational risks
  (rapport annuel de l'Assurance Maladie - Risques professionnels), which explain the methods

## Licence

Assurance Maladie publishes data.ameli.fr under the
[Open Database License (ODbL) 1.0](https://opendatacommons.org/licenses/odbl/1-0/). You may share and
adapt the data, provided you credit the source and share any adapted database under the same
licence. The tidy tables in this module are an adapted database and are shared under the ODbL.

## Citation

Caisse nationale de l'Assurance Maladie, Risques professionnels (data.ameli.fr), 2005 to 2024,
licensed under the ODbL 1.0. Translated and reshaped by the authors of this repository.

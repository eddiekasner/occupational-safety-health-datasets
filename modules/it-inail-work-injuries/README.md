# Italy: Work Injury Reports and Occupational Disease Claims (INAIL Open Data)

**Scope:** Italy | **Publisher:** INAIL (Istituto Nazionale per l'Assicurazione contro gli Infortuni
sul Lavoro, the national workers' compensation insurer) | **Years in this module:** injuries that
happened from 2021 to 2025, and occupational disease claims reported from 2021 to 2025 (data as of
30 April 2026)

## Background

In Italy, employers must insure their workers with INAIL against work injuries and occupational
diseases, and must report every injury that keeps a worker off work for more than three days (and,
since October 2017, every injury with at least one day off, for statistics). INAIL publishes **every
report, one row each**, as open data: when and where it happened, the worker's sex, age and country
of birth, whether it happened while commuting, the employer's industry, and what INAIL decided
(accepted or rejected), how much permanent impairment it caused, how many days it compensated, and
whether the worker died.

Two features of Italian law shape these data:

- **Commuting injuries (in itinere)** on the way to or from work are covered and counted.
- **COVID-19 infections** caught at work have been treated as work injuries since 2020, which
  explains the large rise in reports from health care in 2021 and 2022.

## What one row represents

- `injuries_<year>.csv.gz`: one injury report (a "denuncia") for an accident in that year.
- `injuries_summary.csv.gz`: a count of reports for a combination of year, region, sector, sex,
  age group, birthplace and commuting.
- `occupational_diseases.csv.gz`: one occupational disease claim.
- `disease_deaths.csv.gz`: one worker with a recognised occupational disease who died.

## Why it matters for OSH

- Three million case-level records, with the worker's age and country of birth and the employer's
  industry, for a whole country: few countries publish this.
- It shows the **workers' compensation** view of injury: what is reported, and what the insurer
  accepts. About two thirds of reports are accepted, and about half of reported deaths.
- **Migrant workers** (about a fifth of reports are for workers born outside Italy) and
  **commuting** (about a quarter of accepted deaths) can be studied directly.
- Pseudonymous **worker and employer IDs** allow analyses of repeat injuries and of injuries per
  employer.
- The occupational disease claims show the rise of musculoskeletal disorders and the long tail of
  asbestos.

## Limitations to keep in mind

- **Reports, not rates.** The files have no employment figures. For rates, use the number of
  workers by region, sector, sex and age from ISTAT's Labour Force Survey or INAIL's own insured
  workforce figures.
- **School pupils are included.** INAIL also insures pupils and students during school activities
  (under the State scheme), so there are many reports for children: about 230,000 for children
  under 15 in five years. For analyses of workers, leave out the State scheme or children (the
  notebooks show how).
- **Who is covered.** Most self-employed professionals, and workers insured with other bodies, are
  not covered by INAIL (though since 2017 their employers report injuries for statistics). Road
  accidents while working or commuting are included. Injuries covered by INAIL's separate insurance
  for people who work in the home (casalinghe) are not.
- **Decisions change.** The decision, impairment and days compensated are as of 30 April 2026; recent
  cases may still be under investigation or be revised. Impairment is assessed only for accepted
  cases with lasting damage.
- **"Short absence."** Reports of absences of three days or less are not compensated by INAIL (the
  employer pays) and are kept "for statistics only"; they are not rejections.
- **Industry.** The employer's ATECO code (the Italian version of the EU's NACE) is missing for
  agriculture and the State scheme and for some other reports.
- **Codes.** Province is an ISTAT code (no names in the files); birthplace is Italy or a foreign
  country code, grouped here into areas. Occupational disease causal agents and sectors are INAIL
  codes without published labels.
- **Five-year window.** INAIL republishes the files every six months for the latest five years; older
  years are not in this module.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns and codes |
| `data/tidy/injuries_2021.csv.gz` to `injuries_2025.csv.gz` | Every injury report, one file per year of accident (564,000 to 704,000 rows each; 3.05 million in all) |
| `data/tidy/injuries_summary.csv.gz` | Reports, accepted cases, deaths and days compensated by year, region, sector, scheme, sex, age group, birthplace and commuting |
| `data/tidy/occupational_diseases.csv.gz` | Every occupational disease claim reported in 2021 to 2025 (375,000) |
| `data/tidy/disease_deaths.csv.gz` | Deaths of workers with a recognised occupational disease, 2021 to 2025 (4,853) |
| `data/raw/` | INAIL's files and national tables (not committed; about 120 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads INAIL's files (through Italy's open data catalogue) |
| `scripts/build_dataset.R` | Builds the tables, with English labels |

Checked against INAIL's national tables (data as of 30 April 2026): reports by year (564,418 in 2021
to 600,640 in 2025), reports by country of birth, reported deaths by year (1,474 to 1,198), accepted
deaths in 2025 by region, and the reasons fatal cases were rejected in 2025, all match exactly.

## Official documentation

- [INAIL open data portal](https://dati.inail.it) (descriptions of every field, and national and
  regional tables)
- [Italy's national open data catalogue](https://www.dati.gov.it/) (search for INAIL; lists each
  dataset with its licence)
- In `data/raw/` after running `fetch_data.R`: INAIL's national tables for injuries
  (`Tabelle_nazionali_cadenza_semestrale_infortuni.pdf`) and occupational diseases

## Licence

INAIL's open data are published under the
[Creative Commons Attribution 4.0 International licence (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).
This module translated codes into English, combined the regional files and added derived columns.

## Citation

INAIL, Open data: infortuni sul lavoro e malattie professionali, dati con cadenza semestrale (data as
of 30 April 2026), https://dati.inail.it, licensed under CC BY 4.0. Combined and translated by the
authors of this repository.

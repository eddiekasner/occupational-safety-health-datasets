# ILOSTAT: Occupational Safety and Health Statistics

**Scope:** International (about 150 countries and territories) | **Publisher:** International
Labour Organization (ILO) | **Years:** 1969 to 2024 (varies by country)

## Background

The International Labour Organization is the United Nations agency for the world of work.
Through **ILOSTAT**, its statistics database, the ILO collects labour statistics from national
governments, including occupational safety and health (OSH) statistics:

- **Occupational injuries**: fatal and non-fatal cases, rates per 100,000 workers, days lost,
  and the number of workers covered, by sex, migrant status and economic activity
- **Labour inspection**: number of inspectors, inspectors per 10,000 employed, inspection
  visits, and registered workplaces

Countries report these figures from their own systems: workers' compensation and social
insurance records, labour inspectorate records, establishment surveys, or official estimates.
The ILO's 1998 resolution concerning statistics of occupational injuries (16th International
Conference of Labour Statisticians) sets international guidelines, but national practices still
differ a lot.

Fatal and non-fatal occupational injuries per 100,000 workers, by sex and migrant status, are
also an official UN Sustainable Development Goal indicator (SDG 8.8.1). Its
[metadata](https://unstats.un.org/sdgs/metadata/files/Metadata-08-08-01.pdf) cautions that,
because of data quality issues, it may be more relevant to analyse trends than levels.

## What one row represents

All three tables are in long format: **one value for one country, one year, one breakdown
(sex, migrant status or economic sector) and one measure** (for example
`fatal_rate_per_100k`).

## Why it matters for OSH

These are the only harmonized international statistics on occupational injuries. They let you
compare countries and regions, look at trends over several decades, compare economic
sectors, and study migrant workers and labour inspection capacity.

## Limitations to keep in mind

- **Comparability is limited.** Countries differ in what they count (reported vs. compensated
  injuries; whether commuting accidents and occupational diseases are included), whom they
  cover (all workers, employees only, or insured persons only), and where the data come from.
  Read the `source` and `notes` columns before comparing countries.
- **Under-reporting of non-fatal injuries** varies enormously between countries. Fatal injuries
  are more reliably recorded.
- **Gaps.** Many countries report only some years, and some large countries report rarely or not at all.
- **Breaks in series.** A change in data source or classification can create a jump in a trend.
- **Occupational diseases are not included** in most series, although they cause far more
  work-related deaths worldwide than injuries.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns, measures and codes |
| `data/tidy/injuries_national.csv` | Injury rates, cases, days lost and workers covered, by country, year, sex and migrant status (37,838 rows) |
| `data/tidy/injuries_by_sector.csv` | Fatal and non-fatal injury rates by economic activity (41,478 rows) |
| `data/tidy/labour_inspection.csv` | Labour inspection indicators (5,146 rows) |
| `data/raw/` | The 19 original ILOSTAT downloads (not committed) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the 19 indicators from the ILOSTAT API (about 135 MB) |
| `scripts/build_dataset.R` | Builds the three tidy tables from the downloads |

The tidy tables are complete, not samples, and are committed to the repository. They were
built from data downloaded in October 2026. To refresh them, run `fetch_data.R` (delete the old
files in `data/raw/` first) and then `build_dataset.R`.

## Official documentation

- [ILOSTAT safety and health at work topic page](https://ilostat.ilo.org/topics/safety-and-health-at-work/)
- [ILOSTAT data API documentation](https://rplumber.ilo.org/__docs__/)
- [Indicator catalog (CSV)](https://rplumber.ilo.org/metadata/toc/indicator/?lang=en&format=.csv)
- [SDG indicator 8.8.1 metadata (PDF)](https://unstats.un.org/sdgs/metadata/files/Metadata-08-08-01.pdf)

## License and citation

The ILO's [Rights and permissions](https://www.ilo.org/node/9321) page says that, under its
Open Access policy, ILO materials including datasets may be reused without asking permission,
provided the ILO is cited as the source.

International Labour Organization. *ILOSTAT database: Occupational safety and health
statistics.* Accessed [date] from https://ilostat.ilo.org

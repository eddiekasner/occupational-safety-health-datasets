# BLS Survey of Occupational Injuries and Illnesses (SOII)

**Scope:** United States (private industry and state and local government) | **Publisher:**
US Department of Labor, Bureau of Labor Statistics (BLS) | **Years in this module:** industry
and state rates 2014 to 2024; case characteristics 2011 to 2020

## Background

SOII is the main source of national estimates of **non-fatal** work-related injuries and
illnesses in the United States. Each year about 200,000 sampled employers in private industry and
state and local government report the injuries and illnesses they recorded on their
**OSHA 300 logs**, plus their total hours worked. From these BLS estimates:

- **incidence rates** (cases per 100 full-time equivalent workers) and numbers of cases, by
  industry, state, ownership and establishment size, for different types of cases (total
  recordable; days away, restricted or transferred (DART); days away from work (DAFW); and
  types of illness), and
- for cases with **days away from work**, the **characteristics** of the worker and the case:
  age, sex, occupation, event, nature of injury, part of body, source, and how many days away.

## What one row represents

An estimate (a rate, a number of cases, or a median number of days) for one year and one
breakdown, for example "private industry, nursing care facilities, total recordable cases, 2024".

## Why it matters for OSH

SOII is the official yardstick for workplace safety in the US: OSHA uses it to target
inspections, employers compare their own rates with their industry's, and researchers use it
to track trends. It is also the best-known example of under-reporting in occupational
injury surveillance.

## Limitations to keep in mind

- **Coverage.** SOII excludes fatalities (see the CFOI module) and non-fatal cases among the
  self-employed, workers on farms with 10 or fewer employees, private household workers,
  volunteers, and federal government workers.
- **Based on employers' records.** Studies comparing SOII with other sources (for example
  workers' compensation records) suggest it misses a substantial share of injuries.
- **Illnesses are under-captured.** Long-latency illnesses such as cancers are rarely
  recognized as work-related or recorded on OSHA logs.
- **Sampling error.** Estimates come from a sample; BLS publishes relative standard errors (RSE).
- **Suppression.** Estimates that do not meet BLS's publication criteria are not published; they
  are absent from these tables.
- **Not every state participates** in the state-level estimates.
- **Case characteristics end in 2020 here.** Starting with 2021 data, BLS publishes case and
  demographic data for two-year periods; those estimates are not in the flat files used here.
- **COVID-19.** Work-related COVID-19 cases recorded on OSHA logs raised illness counts in 2020 to 2022.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Tables, columns and codes |
| `data/tidy/soii_industry.csv.gz` | US rates and counts by detailed industry and ownership, 2014 to 2024 (gzip) |
| `data/tidy/soii_states.csv` | Rates and counts by state and ownership, all industries, 2014 to 2024 |
| `data/tidy/soii_size.csv` | Private industry rates and counts by establishment size, for all industries, supersectors and sectors, 2014 to 2024 |
| `data/tidy/soii_dafw_characteristics.csv` | Days-away cases by worker and case characteristic, 2011 to 2020 |
| `data/tidy/soii_dafw_detail.csv.gz` | Days-away cases by detailed event, nature, part of body, source, occupation and industry, 2011 to 2020 (gzip) |
| `data/tidy/soii_dafw_states.csv` | Days-away cases by state, 2011 to 2020 |
| `data/raw/` | BLS downloads (not committed) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the BLS files (**requires your email address**; see below) |
| `scripts/build_dataset.R` | Builds the tidy tables |

The tidy tables are complete for the breakdowns they cover and are committed to the repository.
They were built from files downloaded in October 2026.

### Downloading from BLS

BLS blocks automated downloads that do not identify who is making them. Before running
`fetch_data.R`, put your email address in `contact_email` at the top of the script (or set the
environment variable `BLS_CONTACT_EMAIL`).

The case characteristics file is about 6 GB. The script downloads it to a temporary file, checks
that it is complete, keeps only the series this module uses, and deletes it. Long downloads from
BLS are sometimes cut off; the script retries, but you may need to run it again later.

## Official documentation

- [SOII overview and tables](https://www.bls.gov/iif/nonfatal-injuries-and-illnesses-tables.htm)
- [SOII handbook of methods](https://www.bls.gov/opub/hom/soii/home.htm)
- [Industry data documentation (is.txt)](https://download.bls.gov/pub/time.series/is/is.txt)
- [Case and demographic data documentation (cs.txt)](https://download.bls.gov/pub/time.series/cs/cs.txt)

## Citation

US Department of Labor, Bureau of Labor Statistics. *Survey of Occupational Injuries and
Illnesses.* Downloaded [date] from https://www.bls.gov/iif/

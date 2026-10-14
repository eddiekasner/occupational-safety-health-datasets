# BLS Census of Fatal Occupational Injuries (CFOI)

**Scope:** United States | **Publisher:** US Department of Labor, Bureau of Labor Statistics
(BLS) | **Years in this module:** counts 2011 to 2022; rates 2023 and 2024

## Background

The Census of Fatal Occupational Injuries is the official count of work-related deaths from
injuries in the United States. It is a federal-state cooperative program that has covered all
50 states and the District of Columbia since 1992.

To make the count as complete as possible, CFOI identifies deaths from many sources (death
certificates, workers' compensation reports, OSHA and other federal and state agency reports,
news media) and confirms each one with **two or more independent source documents**, or a
source document and a follow-up questionnaire. Every death is coded by:

- worker characteristics (age, sex, race and ethnicity, employee or self-employed),
- industry (NAICS) and occupation (SOC),
- the event or exposure, the source of injury, the nature of injury and the body part, using the
  Occupational Injury and Illness Classification System (OIICS).

BLS combines CFOI counts with hours worked from the Current Population Survey to calculate
**fatal injury rates per 100,000 full-time equivalent (FTE) workers**.

## What one row represents

A count of fatal work injuries (or a rate) for one year and one breakdown, for example
"truck drivers, 2022" or "Texas, falls, 2022".

## Why it matters for OSH

CFOI is the most complete source on fatal work injuries in the US. It covers all workers,
including the self-employed and government workers, in every industry and state. It is used to
identify the most dangerous jobs, track trends, and set prevention priorities.

## Limitations to keep in mind

- **Injuries only.** Deaths from occupational illnesses (for example cancers, lung diseases, heart
  disease caused by work) are excluded unless an injury event caused them. These deaths far
  outnumber fatal injuries.
- **Counts vs. rates.** Counts reflect how many people work in a group. Use rates to compare risk.
- **Suppression.** BLS does not publish counts or rates that do not meet its publication
  criteria (for example, too few cases); those values are simply absent.
- **Rate uncertainty.** Rates depend on survey-based estimates of hours worked and have margins
  of error, which are large for small occupations.
- **Classification changes.** The flat files used here (BLS series `fw`) cover 2011 to 2022 with
  consistent coding. BLS publishes 2023 and later data in tables that use the 2018 SOC and 2022
  NAICS; this module includes the 2023 and 2024 rate tables.
- **Rates exclude some deaths.** Workers under 16, volunteers, and members of the resident military
  are counted in CFOI but left out of rate calculations, to match the Current Population Survey.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns and how to use each table |
| `data/tidy/cfoi_national.csv` | US counts by worker and case characteristics, 2011 to 2022 |
| `data/tidy/cfoi_by_detail.csv` | US counts by detailed industry, occupation, event and primary source, 2011 to 2022 |
| `data/tidy/cfoi_states.csv` | Counts by state and characteristic, 2011 to 2022 |
| `data/tidy/cfoi_rates.csv` | Rates per 100,000 FTE workers with margins of error, 2023 and 2024 |
| `data/raw/` | BLS downloads (not committed; the main data file is about 620 MB) |
| `notebooks/01_starter.Rmd` | Guided exploration for ENVH 312 and ENVH 460/560 |
| `scripts/fetch_data.R` | Downloads the BLS files (**requires your email address**; see below) |
| `scripts/build_dataset.R` | Builds the tidy tables |

The tidy tables are complete for the breakdowns they cover and are committed to the repository.
They were built from files downloaded in October 2026.

### Downloading from BLS

BLS blocks automated downloads that do not identify who is making them. Before running
`fetch_data.R`, put your email address in `contact_email` at the top of the script (or set the
environment variable `BLS_CONTACT_EMAIL`). The script includes it in its requests.

## Official documentation

- [CFOI home page](https://www.bls.gov/iif/fatal-injuries-tables.htm)
- [CFOI data tables, including hours-based rates](https://www.bls.gov/iif/fatal-injuries-tables.htm)
- [CFOI definitions](https://www.bls.gov/iif/definitions/census-of-fatal-occupational-injuries-definitions.htm) and [scope](https://www.bls.gov/iif/overview/cfoi-scope.htm)
- [Flat file documentation (fw.txt)](https://download.bls.gov/pub/time.series/fw/fw.txt)
- [OIICS manual](https://www.bls.gov/iif/definitions/occupational-injuries-and-illnesses-classification-manual.htm)

## Citation

US Department of Labor, Bureau of Labor Statistics. *Census of Fatal Occupational Injuries.*
Downloaded [date] from https://www.bls.gov/iif/fatal-injuries-tables.htm

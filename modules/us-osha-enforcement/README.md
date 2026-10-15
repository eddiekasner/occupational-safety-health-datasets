# OSHA Enforcement Data: Inspections, Violations and Accident Investigations

**Scope:** United States (federal OSHA and state-plan OSHA programs) | **Publisher:** US Department
of Labor, Occupational Safety and Health Administration (OSHA) | **Years in this module:**
inspections opened in federal fiscal years 2015 to 2025 (1 October 2014 to 30 September 2025)

## Background

OSHA enforces workplace safety and health standards by inspecting workplaces. Federal OSHA covers
most private employers; 22 OSHA-approved **state plans** (21 states and Puerto Rico) cover private
and public employers in their states, and several more cover only state and local government
workers. Every
inspection is recorded in OSHA's Integrated Management Information System, together with:

- **why** the inspection happened (planned, complaint, referral, fatality or catastrophe,
  follow-up, and others),
- the **violations** cited: the standard, the type (serious, willful, repeat, other-than-serious),
  and the penalty proposed and finally assessed, and
- for deaths and serious injuries, an **accident investigation summary** with a short narrative
  and details about each injured or killed worker.

DOL publishes these records daily through its open data API.

## What one row represents

- `inspection_summary`: a count of inspections (and their violations and penalties) for one
  fiscal year, state, federal or state plan, inspection type, inspection scope, safety or health,
  ownership and industry sector.
- `violation_standards`: a count of violations of one standard section of one type in one fiscal
  year.
- `accidents`: one accident investigation (one event, which may involve several workers).
- `accident_injuries`: one injured or killed worker.
- `inspections_sample` and `violations_sample`: one inspection, or one cited violation item, for a
  5% random sample of inspections.

## Why it matters for OSH

Enforcement is one of the main tools of OSH policy. These data let students ask where OSHA
inspects and why, which hazards it finds, how large penalties really are, and what happens after
a worker dies. The inspection number (`activity_nr`) links to other OSHA data, including the
Severe Injury Reports and Chemical Exposure modules.

## Limitations to keep in mind

- **Not a sample of workplaces.** Inspections go where OSHA targets them or where workers complain
  and employers report. Violation rates describe inspected workplaces, not all workplaces.
- **"No inspection" records.** About one in ten records are cases opened without an inspection (for
  example, the business had closed). OSHA's published inspection counts leave these out; filter
  on `insp_scope`.
- **State plans differ.** State plans have their own standards (cited under state codes), penalty
  policies and data practices.
- **Penalties change.** `current_penalty` reflects settlements, contests and final orders as of the
  download; recent cases may still change. Penalties are not adjusted for inflation (OSHA's maximum
  penalties rise each year).
- **Accident investigations are incomplete for some years.** Investigations of non-fatal events
  were recorded mainly in fiscal years 2017 to 2022, and the latest year is incomplete because
  summaries are entered when investigations close. Fatality investigations rose sharply in 2020 and
  2021 because of COVID-19 deaths.
- **Not every death is investigated.** OSHA investigates deaths within its jurisdiction; it does
  not investigate most transportation deaths, deaths of the self-employed, or deaths in workplaces
  it does not cover.
- **Coding.** Industry codes (NAICS) are assigned at inspection; injury codes in the accident
  tables are OSHA's own and are not OIICS codes.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Tables, columns and codes |
| `data/tidy/inspection_summary.csv.gz` | All 825,190 inspection records, aggregated |
| `data/tidy/violation_standards.csv.gz` | All 1.58 million violations, aggregated by standard |
| `data/tidy/accidents.csv.gz` | 54,138 accident investigations with events in FY2015 to FY2025, with narratives |
| `data/tidy/accident_injuries.csv.gz` | The workers injured or killed in those investigations |
| `data/sample/inspections_sample.csv.gz` | A 5% random sample of inspections, with per-inspection violation and penalty totals |
| `data/sample/violations_sample.csv.gz` | Every violation for the sampled inspections |
| `data/raw/` | API downloads (not committed; about 650 MB) |
| `notebooks/01_starter.Rmd` | Guided exploration for ENVH 312 and ENVH 460/560 |
| `scripts/fetch_data.R` | Downloads the data from the DOL API (**requires a free API key**; see below) |
| `scripts/build_dataset.R` | Builds the tables |

The tables were built from data downloaded in October 2026. The record-level files for all
inspections and violations are too large for this repository; run the scripts to get them.

### Downloading from the DOL API

The DOL API requires a free key: sign up at https://dataportal.dol.gov and create an API key, then
set the environment variable `DOL_API_KEY` before running `fetch_data.R` (instructions at the top
of the script). Never put your key in a file you share or commit. The API limits how fast a key can
make requests; the script waits and retries automatically, and can be stopped and rerun.

## Official documentation

- [DOL Open Data Portal](https://dataportal.dol.gov) (dataset descriptions and data dictionaries for
  each OSHA table)
- [OSHA enforcement](https://www.osha.gov/enforcement) and
  [annual inspection data](https://www.osha.gov/enforcement/current-enforcement-summary)
- [OSHA Field Operations Manual](https://www.osha.gov/enforcement/directives/cpl-02-00-164)
  (inspection types, violation classification and penalties)
- [Most frequently cited standards](https://www.osha.gov/top10citedstandards)

## Citation

US Department of Labor, Occupational Safety and Health Administration. *OSHA enforcement data
(inspection, violation, accident, accident_injury and accident_abstract tables).* DOL Open Data
Portal, downloaded [date] from https://dataportal.dol.gov

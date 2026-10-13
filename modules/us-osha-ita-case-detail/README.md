# OSHA Injury Tracking Application (ITA): Case Detail Data

**Scope:** United States | **Publisher:** US Department of Labor, Occupational Safety
and Health Administration (OSHA) | **Years in this module:** calendar years 2023, 2024, 2025

## Background

Most US employers with more than 10 employees must keep a record of serious
work-related injuries and illnesses (29 CFR Part 1904). They use three forms:

| Form | What it records |
| --- | --- |
| **OSHA 300** Log of Work-Related Injuries and Illnesses | One line per case: job title, date, where it happened, description, outcome, days away or restricted |
| **OSHA 301** Injury and Illness Incident Report | Details for each case: what the worker was doing, what happened, the injury, the object or substance that caused it |
| **OSHA 300A** Summary | Annual totals for the establishment, plus employees and hours worked |

Since 2017, many employers have submitted their **300A summaries** to OSHA electronically
through the Injury Tracking Application (ITA). A rule that took effect on
January 1, 2024 added a new requirement: establishments with **100 or more employees in
designated high-hazard industries** must also submit the case-level information from
their **300 and 301 forms**. The first submissions (for calendar year 2023) were due in
March 2024. OSHA publishes this as the **case detail** dataset.

Each row is **one recordable injury or illness**. Records include:

- establishment information (name, location, NAICS industry code, size)
- the worker's job title, plus a Standard Occupational Classification (SOC) code that
  OSHA assigns using NIOSH's automated coding system (NIOCCS)
- date and time of the incident, outcome, days away from work or on restriction
- type of case (injury, skin disorder, respiratory condition, poisoning, hearing loss, other illness)
- **free-text narratives** describing what happened, with personal identifiers removed by OSHA

The `establishment_id` field links each case to that establishment's 300A summary.

## Why it matters for OSH

Before this dataset, case-level detail on US workplace injuries was mostly available
only in aggregated form (for example, BLS SOII tables). Case detail data let you ask
questions such as: *Which tasks lead to amputations in food manufacturing? How often do
heat-related illnesses appear in warehouse narratives? Which occupations account for
most days away from work?*

## Limitations to keep in mind

- **Not a census of all workers.** Only establishments with 100+ employees in
  designated industries must submit. Small employers and many sectors are missing.
- **Employer-recorded.** Recordkeeping depends on employers; under-recording of
  injuries and illnesses is well documented.
- **Compliance is incomplete.** Some required establishments do not submit, so
  the data can change between releases as late submissions arrive.
- **Illnesses are under-captured.** Long-latency diseases (for example, occupational
  cancers) are rarely recorded on the 300 log.
- **SOC codes are machine-assigned** from job titles and may be wrong; check any
  probability or review fields in the data dictionary.
- **Counts are not rates.** To compare industries you need a denominator, such as
  hours worked from the 300A summary.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Field guide and code tables, with links to OSHA's official documentation |
| `data/sample/` | A small random sample committed to the repo (built by `scripts/make_sample.R`) |
| `data/raw/` | Full yearly files (not committed; see below) |
| `notebooks/01_starter.Rmd` | Guided exploration for ENVH 312 and ENVH 460/560 |
| `scripts/fetch_data.R` | Downloads the full files from OSHA |
| `scripts/make_sample.R` | Rebuilds the sample from the full files |

## Getting the full data

Open `scripts/fetch_data.R` in RStudio and click **Source**. It downloads the yearly
files from OSHA into `data/raw/`. You can also download them by hand from OSHA's
[ITA data page](https://www.osha.gov/Establishment-Specific-Injury-and-Illness-Data)
and put the CSV or zip files in `data/raw/`. Then set `use_full_data <- TRUE` in the notebook.

The full files are large. If your computer struggles, stay with the sample or filter to
one industry (for example, `filter(str_starts(naics_code, "62"))` for health care).

## Official documentation

- [ITA data page and downloads](https://www.osha.gov/Establishment-Specific-Injury-and-Illness-Data)
- [ITA Data Users Guide (PDF)](https://www.osha.gov/sites/default/files/ITA_data_users_guide.pdf)
- [Case Detail Data Dictionary (PDF)](https://www.osha.gov/sites/default/files/case_detail_data_dictionary.pdf)
  (OSHA has also posted a [May 2026 version](https://www.osha.gov/sites/default/files/case_detail_data_dictionary_2026.pdf))
- [Summary (300A) Data Dictionary (PDF)](https://www.osha.gov/sites/default/files/summary_data_dictionary.pdf)
- [Frequently cited OSHA standards by NAICS](https://www.osha.gov/ords/imis/citedstandard.naicsman?p_esize=&p_state=FEFederal)

## Citation

US Department of Labor, Occupational Safety and Health Administration. *Injury Tracking
Application (ITA) Case Detail Data, calendar years 2023 to 2025.* Downloaded [date] from
https://www.osha.gov/Establishment-Specific-Injury-and-Illness-Data

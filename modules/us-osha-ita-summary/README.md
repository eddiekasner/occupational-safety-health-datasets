# OSHA ITA Summary Data (Form 300A): Establishment Injury and Illness Totals

**Scope:** United States (establishments required to submit, and some that chose to) |
**Publisher:** US Department of Labor, Occupational Safety and Health Administration (OSHA) |
**Years in this module:** calendar years 2016 to 2025

## Background

Under OSHA's recordkeeping rule (29 CFR Part 1904), most employers with more than 10 employees
must record each work-related injury and illness on the **OSHA 300 Log** and describe it on an
**OSHA 301** incident report. After each year they total the log on the **OSHA 300A Summary** and
post it in the workplace from February to April.

Since 2017 (for calendar year 2016), some establishments must also submit their 300A to OSHA
electronically through the **Injury Tracking Application (ITA)**:

- establishments with **250 or more employees** in industries that must keep records, and
- establishments with **20 to 249 employees** in designated high-hazard industries.

Since 2024 (for calendar year 2023), establishments with 100 or more employees in designated
industries must also submit their 300 and 301 case details (see the
[ITA case detail module](../us-osha-ita-case-detail/)). OSHA publishes every submission,
including the employer's name.

## What one row represents

- `establishments_<year>`: one establishment's 300A summary for one calendar year.
- `summary_by_industry`: totals for one year, industry sector, state, size, ownership, and
  whether the records pass the plausibility check.

## Why it matters for OSH

The 300A data are the only national source of injury rates for **named workplaces**. Students can
compute injury rates for industries, companies and individual establishments, follow
establishments over time, see the COVID-19 surge in respiratory illnesses, and link establishments
to their individual cases. They also show what employer self-reported data can and cannot tell us.

## Limitations to keep in mind

- **Not a sample of all workplaces.** Only some establishments must submit, mostly larger ones and
  those in high-hazard industries, and OSHA does not weight the data. Rates are not representative
  of all US workers; use the BLS SOII for national estimates. (OSHA's comparison of the two
  sources is in `data/raw/` after running `fetch_data.R`.)
- **Not everyone required submits**, and some establishments submit voluntarily. OSHA keeps
  submissions from establishments that were not required to submit (for example, many "Under 20"
  establishments).
- **Self-reported and not validated.** OSHA does not check the counts of employees, hours or
  cases. Some records have clear errors (for example, employees and hours entered in the wrong
  boxes). The `plausible` flag marks records with believable employees and hours; nothing is
  deleted.
- **Under-recording.** Employers decide what is recordable, and studies find that many injuries
  are never recorded. A low rate does not prove a workplace is safe, and OSHA cautions against
  calling establishments the "most" or "least" dangerous from these data alone.
- **Who is covered changes.** The number of establishments rose from about 215,000 in 2016 to
  400,000 in 2025, so changes over time partly reflect who submits.
- **Public sector.** State and local government workplaces are included only in states with
  OSHA-approved State Plans that require it.
- **Coding.** Company names, addresses and industry codes are entered by employers and not
  standardized. Before 2023, NAICS codes are 2012 codes; from 2023, employers could use 2012, 2017
  or 2022 codes (`naics_year`).
- **Size codes changed.** From 2023, the 20 to 249 group was split into 20-99 and 100-249
  (`size_detail`).

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns and codes |
| `data/tidy/establishments_2016.csv.gz` to `establishments_2025.csv.gz` | Every establishment that submitted, one file per year (215,000 to 400,000 rows each; 3.2 million in all) |
| `data/tidy/summary_by_industry.csv.gz` | Totals by year, industry sector, state, size and ownership (complete) |
| `data/raw/` | OSHA's files and documentation (not committed; about 260 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads OSHA's files |
| `scripts/build_dataset.R` | Builds the tables |

To keep the repository small, the committed tables leave out street addresses and the industry
description typed by each employer. To include them, set `include_text <- TRUE` in
`scripts/build_dataset.R` and run the scripts. When an establishment submitted more than once for
a year, only its latest submission is kept. The 2025 file was downloaded in October 2026 and
covers submissions through 31 August 2026.

## Official documentation

- [ITA data page](https://www.osha.gov/Establishment-Specific-Injury-and-Illness-Data) (files,
  data dictionaries, users' guide, and comparison with BLS estimates)
- [OSHA injury and illness recordkeeping](https://www.osha.gov/recordkeeping) and the
  [forms package](https://www.osha.gov/sites/default/files/OSHA-RK-Forms-Package.pdf)
- [29 CFR 1904.41](https://www.ecfr.gov/current/title-29/subtitle-B/chapter-XVII/part-1904/subpart-E/section-1904.41)
  (who must submit) and [Appendix A to Subpart E](https://www.ecfr.gov/current/title-29/subtitle-B/chapter-XVII/part-1904/subpart-E/appendix-Appendix%20A%20to%20Subpart%20E%20of%20Part%201904)
  (designated industries)

## Licence

Works of the US federal government are in the public domain in the United States.

## Citation

US Department of Labor, Occupational Safety and Health Administration. *Injury Tracking
Application (ITA) Form 300A summary data, calendar years 2016 to 2025.* Downloaded [date] from
https://www.osha.gov/Establishment-Specific-Injury-and-Illness-Data

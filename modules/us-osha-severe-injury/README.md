# OSHA Severe Injury Reports

**Scope:** United States (federal OSHA jurisdiction) | **Publisher:** US Department of Labor,
Occupational Safety and Health Administration (OSHA) | **Years:** January 2015 to November 2025

## Background

Since January 1, 2015, OSHA's recordkeeping rule (29 CFR 1904.39) has required every employer
to report:

- a work-related **fatality** within 8 hours, and
- a work-related **in-patient hospitalization, amputation, or loss of an eye** within 24 hours.

OSHA publishes the non-fatal reports as the **Severe Injury Reports (SIR)** dataset. Each
report includes the employer's name and address, the date, the industry, a short narrative
of what happened, and codes from the **Occupational Injury and Illness Classification System
(OIICS)** for the event, the nature of the injury, the body part and the source.

After a report, OSHA either inspects the workplace or, more often, asks the employer to
investigate and respond (a "rapid response investigation"). The `inspection` column holds the
inspection number when an inspection took place.

## What one row represents

One severe injury report: one incident at one establishment. A report can involve more than
one injured worker (see the `hospitalized`, `amputation` and `loss_of_eye` counts).

## Why it matters for OSH

These are near-real-time reports of serious injuries, with narratives, from every industry and
establishment size. They show what kinds of incidents put workers in the hospital, which
employers and industries report them, where they happen, and how they change with the season.

## Limitations to keep in mind

- **Federal OSHA jurisdiction only.** States with OSHA-approved State Plans covering private
  employers (for example California, Washington, Michigan, North Carolina) are largely missing.
  The few reports from those states (`federal_state = 0`) are likely workplaces that remain
  under federal jurisdiction there.
- **No fatalities.** Work-related deaths are reported separately ([osha.gov/fatalities](https://www.osha.gov/fatalities)).
- **Under-reporting.** Reporting depends on employers. Studies suggest many qualifying injuries
  are never reported.
- **No denominators.** The data are counts of reports, not rates.
- **Messy fields.** Employer names are not standardized, coordinates have only two decimal places
  (roughly 1 km) and are sometimes wrong, and OSHA warns that geocode accuracy is not guaranteed.
- **The most recent year is incomplete** (data end on November 30, 2025).

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns and OIICS divisions |
| `data/tidy/severe_injury_reports.csv.gz` | All 105,996 reports, cleaned (16.5 MB, gzip; `read_csv()` reads it directly) |
| `data/raw/` | OSHA's original zip file (not committed) |
| `notebooks/01_starter.Rmd` | Guided exploration for ENVH 312 and ENVH 460/560 |
| `scripts/fetch_data.R` | Downloads the full dataset from OSHA |
| `scripts/build_dataset.R` | Cleans it into the tidy file |

The tidy file contains every report, not a sample, and is committed to the repository. It was
built from the file OSHA posted in 2026 (data through November 30, 2025). OSHA renames the file
when it updates the data; see the comments in `fetch_data.R`.

## Official documentation

- [Severe Injury Reports dashboard and download](https://www.osha.gov/severe-injury-reports)
- [Severe Injury Reports overview and annual reports](https://www.osha.gov/severeinjury)
- [29 CFR 1904.39, reporting fatalities, hospitalizations, amputations, and losses of an eye](https://www.osha.gov/laws-regs/regulations/standardnumber/1904/1904.39)
- [BLS OIICS manual and code lists](https://www.bls.gov/iif/definitions/occupational-injuries-and-illnesses-classification-manual.htm)

## Citation

US Department of Labor, Occupational Safety and Health Administration. *Severe Injury Reports,
January 2015 to November 2025.* Downloaded [date] from https://www.osha.gov/severe-injury-reports

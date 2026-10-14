# Eurostat: European Statistics on Accidents at Work (ESAW)

**Scope:** European Union member states plus Iceland, Norway and Switzerland (and the United
Kingdom in earlier years) | **Publisher:** Eurostat, the statistical office of the European
Union | **Years:** 2008 to 2024 (causes and circumstances from 2014)

## Background

The European Statistics on Accidents at Work (ESAW) collect, from each country's national
reporting system, case-level data on **accidents at work** that lead to:

- **death** (fatal accidents), or
- **at least 4 calendar days of absence** from work (non-fatal accidents).

Countries report through either insurance-based systems (accidents are reported to an
insurer or social security body) or legal-obligation systems (employers must report accidents
to a labour inspectorate or similar authority). Eurostat harmonizes the variables using a
common methodology, so ESAW is more comparable across countries than most international
injury statistics. It also classifies the **causes and circumstances** of accidents: what
went wrong (the *deviation*), how the person was hurt (the *contact, mode of injury*), the
work environment, and more.

## What one row represents

One value for one country (or the EU-27), one year, one breakdown (sex, age, sector, or cause)
and one `unit` (number of accidents, incidence rate, standardised incidence rate, or percent).

## Why it matters for OSH

ESAW lets you compare accident rates across about 30 European countries over more than 15
years, by sector, age, sex and cause. It is a natural comparison for US data (BLS, OSHA ITA)
and shows how definitions shape what we see.

## Limitations to keep in mind

- **Under-reporting of non-fatal accidents** varies a lot by country and reporting system.
  Eurostat notes that low non-fatal rates may partly reflect under-reporting. Fatal accidents
  are much harder to leave unreported.
- **Coverage differences.** Countries must report accidents to employees; reporting accidents
  to the self-employed and family workers is voluntary, so coverage differs. Road traffic
  accidents in the course of work are included, but commuting accidents are not.
- **Only accidents.** Occupational diseases are not included.
- **Causes are incomplete.** Countries must report only 3 of the 9 "causes and circumstances"
  variables, so some (for example Czechia, for the deviation) do not code a given variable at all,
  and others code it for only part of their accidents.
- **Breaks in series.** Values flagged `b` mark a break in the time series, for example after a
  change in a national reporting system.
- **Revisions.** Eurostat revises past years; numbers may differ slightly from earlier news releases.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns, units, codes and flags |
| `data/tidy/esaw_main.csv` | Accidents by country, year, sex, age and severity, including standardised incidence rates (from `hsw_mi01`) |
| `data/tidy/esaw_sector.csv` | Accidents by NACE Rev. 2 section, numbers and incidence rates (from `hsw_n2_01`, `hsw_n2_02`) |
| `data/tidy/esaw_causes.csv.gz` | Accidents by deviation and by contact, mode of injury, by sector (from `hsw_ph3_06`, `hsw_ph3_08`). Compressed; `read_csv()` reads it directly |
| `data/tidy/esaw_codes.csv` | Labels for sector and cause codes |
| `data/raw/` | Original JSON downloads (not committed) |
| `notebooks/01_starter.Rmd` | Guided exploration for ENVH 312 and ENVH 460/560 |
| `scripts/fetch_data.R` | Downloads the five Eurostat tables, one country at a time |
| `scripts/build_dataset.R` | Builds the tidy tables from the downloads |

The tidy tables are complete, not samples, and are committed to the repository. They were built
from data downloaded in October 2026. To refresh them, delete `data/raw/`, then run
`fetch_data.R` and `build_dataset.R`. Older EU aggregates (EU-15, EU-28) and NACE divisions below
the section level are left out of the tidy tables to keep them small, but are in the raw downloads.

## Official documentation

- [ESAW metadata (methodology, coverage, country notes)](https://ec.europa.eu/eurostat/cache/metadata/en/hsw_acc_work_esms.htm)
- [Statistics Explained: Accidents at work statistics](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Accidents_at_work_statistics)
- [Statistics Explained: Accidents at work by economic activity](https://ec.europa.eu/eurostat/statistics-explained/index.php/Accidents_at_work_-_statistics_by_economic_activity)
- [Eurostat data browser: hsw_mi01](https://ec.europa.eu/eurostat/databrowser/view/hsw_mi01/default/table?lang=en)

## License and citation

Eurostat's [copyright notice](https://ec.europa.eu/eurostat/web/main/help/copyright-notice)
authorises reuse of its statistical data for commercial or non-commercial purposes, provided
the source is acknowledged.

Eurostat. *European Statistics on Accidents at Work (ESAW), tables hsw_mi01, hsw_n2_01,
hsw_n2_02, hsw_ph3_06 and hsw_ph3_08.* Accessed [date] from https://ec.europa.eu/eurostat

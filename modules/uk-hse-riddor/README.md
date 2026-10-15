# UK HSE Injury Statistics: RIDDOR and the Labour Force Survey

**Scope:** Great Britain (England, Scotland and Wales) | **Publisher:** Health and Safety Executive
(HSE) | **Years in this module:** reported deaths 1974 to 2025/26; reported non-fatal injuries
1974 to 2024/25; self-reported injuries 2000/01 to 2024/25

## Background

HSE regulates workplace health and safety in Great Britain. This module combines two of its
sources on work injuries:

- **RIDDOR** (*Reporting of Injuries, Diseases and Dangerous Occurrences Regulations*).
  Employers must report to HSE or their local authority:
  - **deaths** of workers, and of members of the public killed as a result of work activity,
  - **specified injuries** to workers, a fixed list including most fractures, amputations,
    serious burns and loss of sight (called "major" injuries before October 2013), and
  - **over-7-day injuries**: injuries that keep an employee off work for more than 7 consecutive
    days (over-3-day injuries before April 2012).
- **The Labour Force Survey (LFS).** A household survey run by the Office for National Statistics.
  HSE adds questions asking people who worked in the last 12 months whether they were injured in
  a workplace accident (excluding road traffic accidents) and how long they were off work.

HSE treats RIDDOR as the source for **deaths** and for detail (industry, kind of accident, injury,
body part, local area), and the LFS as its preferred source for the **number** of non-fatal
injuries, because employers report only about half of the non-fatal injuries they should.

## What one row represents

A published count, rate or survey estimate for one year (or period) and one category, for example
"over-7-day injuries to employees in construction, 2023/24" or "LFS estimate of injuries in
manufacturing, 2020/21 to 2024/25 average".

## Why it matters for OSH

- Britain has one of the lowest reported fatal injury rates in the world, and its records go back
  to 1974, the year of the Health and Safety at Work etc. Act.
- Having an employer reporting system and a worker survey side by side lets students measure
  under-reporting directly, which is hard to do with US data.
- The series show how changes in reporting rules create breaks that look like changes in safety.

## Limitations to keep in mind

- **Under-reporting.** Employers report roughly half of reportable non-fatal injuries to
  employees, and far fewer for the self-employed. Reporting levels also differ between
  industries, so differences in RIDDOR non-fatal rates may partly reflect reporting.
- **Rule changes break the series.** Reporting requirements changed in 1981, 1986, 1996, 2012
  and 2013 (see `regulations` in `riddor_history.csv`). Do not compare non-fatal counts across
  these changes.
- **What RIDDOR does not cover.** Most deaths in road traffic accidents on public roads, and
  incidents covered by other regulators (for example sea and air transport), are not reportable.
  Since 2012/13 the non-fatal tables exclude injuries on railways and offshore, and since
  2024/25 injuries in nuclear sites. Since 2014/15, suicides on railways are no longer reportable
  (this caused the drop in deaths of members of the public), and since 2015/16 deaths of patients
  and service users in registered health and social care premises in England are excluded.
- **Occupational disease** is not covered here. HSE estimates that more than 10,000 deaths a year
  in Great Britain are linked to past exposure to dusts and chemicals at work (mostly lung disease
  and cancers, including those caused by asbestos), far more than the deaths from injury.
- **Provisional data.** The latest year is provisional (`status`) and the year before is revised.
- **Survey error.** LFS figures are estimates with 95% confidence intervals; for small groups the
  sample is too small to publish (`flag` = `U1`). Most estimates are averaged over 3 or 5 years.
- **COVID-19.** Injuries and rates in 2020/21 (and to a lesser extent 2019/20 and 2021/22) were
  affected by the pandemic and furlough. LFS days lost are not available for 2020/21.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Tables, columns and codes |
| `data/tidy/riddor_history.csv` | Reported deaths and non-fatal injuries since 1974, by broad industry |
| `data/tidy/riddor_industry.csv.gz` | By detailed industry (SIC 2007 section and division), 2014/15 to 2024/25 |
| `data/tidy/riddor_kind.csv.gz` | By kind of accident and broad industry, 2014/15 to 2024/25 |
| `data/tidy/riddor_age_gender.csv.gz` | By age group, gender and broad industry, 2014/15 to 2024/25 |
| `data/tidy/riddor_nature_site.csv` | By nature of injury and site of injury (body part), 2014/15 to 2024/25 |
| `data/tidy/riddor_region.csv.gz` | By country, region and local authority, 2014/15 to 2024/25 |
| `data/tidy/riddor_fatal_latest.csv` | Deaths 2021/22 to 2025/26, with 5-year totals, by industry, kind of accident, age, and country and region |
| `data/tidy/lfs_injury.csv.gz` | Self-reported injuries and days lost with 95% confidence intervals, 2000/01 to 2024/25 |
| `data/raw/` | HSE Excel downloads (not committed) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the HSE tables |
| `scripts/build_dataset.R` | Builds the tidy tables |

The tidy tables are complete for the breakdowns they cover and are committed to the repository.
They were built from tables downloaded in October 2026: RIDDOR non-fatal and LFS tables published
November 2025, and RIDDOR fatal tables published July 2026. HSE updates them every year.

## Official documentation

- [HSE statistics tables](https://www.hse.gov.uk/statistics/tables/index.htm) and
  [LFS tables](https://www.hse.gov.uk/statistics/lfs/tables.htm); each workbook has Notes and
  Guidance sheets
- [Data sources and methods](https://www.hse.gov.uk/statistics/sources.htm)
- [Work-related fatal injuries](https://www.hse.gov.uk/statistics/fatals-overview.htm)
- [What is reportable under RIDDOR](https://www.hse.gov.uk/riddor/)

## Licence

Contains public sector information published by the Health and Safety Executive and licensed
under the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).

## Citation

Health and Safety Executive. *RIDDOR reported injury tables* and *Labour Force Survey
self-reported workplace injury tables.* Downloaded [date] from
https://www.hse.gov.uk/statistics/tables/index.htm. Open Government Licence v3.0.

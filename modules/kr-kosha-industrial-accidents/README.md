# South Korea: Industrial Accident Microdata (KOSHA)

**Scope:** South Korea | **Publisher:** KOSHA (Korea Occupational Safety and Health Agency) and the
Ministry of Employment and Labor, from workers' compensation data of COMWEL (Korea Workers'
Compensation and Welfare Service) | **Years in this module:** 2017 to 2025

## Background

Korea's official industrial accident statistics count every worker whose claim to the national
workers' compensation insurance (산재보험) is approved: injuries that needed more than three days
of medical care, occupational diseases, and deaths. KOSHA publishes the statistics as **microdata,
one row per injured worker or death**, with the industry, type of accident, size of the workplace,
the worker's sex, age group and length of service, how long the worker needed care, the region,
and, for diseases, the kind of disease.

Korea's headline measures are the **injury rate** (injured workers per 100 insured workers) and the
**fatality rate per 10,000 workers** (사망만인율), especially for accident deaths. Korea's accident
fatality rate has long been among the highest in the OECD, and reducing it has been a national
priority: the Serious Accidents Punishment Act (중대재해처벌법), which can make company executives
criminally liable for workplace deaths, took effect in 2022 for workplaces with 50 or more workers
and in 2024 for workplaces with 5 or more.

## What one row represents

- `injured_workers.csv.gz`: one injured worker or death whose compensation claim was approved in
  that year (about 90,000 to 147,000 a year; 1.09 million in all).
- `insured_workers.csv`: the number of workers covered by the insurance in a year, nationally, by
  industry group and by establishment size, with the published counts of injured workers and
  deaths.

## Why it matters for OSH

- Case-level data for a whole country, with **denominators**, so students can compute rates by
  industry and workplace size themselves.
- It shows two problems Korea shares with many countries: **small workplaces** (the accident
  fatality rate is about six times higher in workplaces with fewer than 5 workers than in those with
  1,000 or more) and an **ageing workforce** (half of accident deaths are workers aged 60 or over).
- **Falls from height in construction** cause a large share of accident deaths, which makes this
  a good dataset for the hierarchy of controls.
- **Occupational disease** has grown fast (9,000 cases in 2017, 34,000 in 2025), with the long tail
  of pneumoconiosis among former coal miners and rising numbers of cancers and musculoskeletal
  disorders.

## Limitations to keep in mind

- **Approved claims only.** Rows are claims COMWEL approved, counted in the year of approval, not
  the year of the accident. Injuries needing three days of care or less are not compensated, and
  injuries that are never claimed (for example, treated under health insurance) are missing.
- **Who is covered.** Employees of insured workplaces, and since the 2020s more "special type" and
  platform workers (such as delivery riders). Civil servants, teachers, military personnel and
  most self-employed people have separate schemes and are not included.
- **Commuting.** Commuting accidents have been compensated since 2018, but the official statistics
  (and these files) leave out ordinary commuting accidents.
- **How deaths are counted.** The official count of deaths, and of accident deaths, leaves out road
  accidents outside the workplace (except in transport and in food and accommodation), deaths at
  sports events and from violence, deaths more than a year after the accident, and commuting deaths.
  KOSHA's files include about 250 to 310 such deaths a year, which they record as injured workers
  "receiving care" (요양재해자); this module labels them `Accident death not in the official count`
  (our reading of KOSHA's definitions). They are counted as injured workers but not as deaths.
- **Industry classification.** Industries follow the workers' compensation insurance classification
  (not KSIC), which changed in 2018, 2019 and 2020. `industry` is the label as published each year;
  `industry_2020` maps older labels to the classification used from 2020 (an approximate mapping by
  the authors of this module; for example, restaurants and hotels were in "Other various businesses"
  before 2020).
- **Region** is the region of the regional labour office, which does not exactly match
  administrative boundaries (for example, Daejeon includes Sejong).
- **Denominators.** `insured_workers.csv` is available only by major industry group and by size,
  so rates by age, sex or detailed industry need other sources (for example, Statistics Korea's
  Economically Active Population Survey). Before 2020, agriculture, fishing, and finance and
  insurance were reported together, so they are combined for every year. In 2025, platform workers
  with several employers are counted once in the national total but in each industry and size
  group, so the groups add up to more than the total.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns and categories |
| `data/tidy/injured_workers.csv.gz` | Every injured worker and death, 2017 to 2025 (1.09 million rows; 7 MB) |
| `data/tidy/insured_workers.csv` | Insured workers, injured workers and deaths by year, industry group and establishment size |
| `data/raw/` | KOSHA's Excel files and the ministry's reports (not committed; about 75 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads KOSHA's microdata (90 Excel files) |
| `scripts/build_dataset.R` | Combines the files and adds English labels |
| `scripts/labels_ko_en.csv` | The Korean categories and their English translations |
| `scripts/extract_insured_workers.py` | Extracts the denominators from the ministry's year-end reports (Python, because the reports are in Hangul word processor format) |

Checked against the Ministry of Employment and Labor's year-end reports: for every year from 2017
to 2025, the number of injured workers and deaths matches the published totals exactly, nationally,
by industry group and by establishment size (for example, 147,130 injured workers and 2,248 deaths in
2025, of which 872 were accident deaths).

## Official documentation

- [KOSHA industrial accident data](https://portal.kosha.or.kr/archive/indus-acc-statis/indus-status-data)
  (the microdata; choose a year and industry and click 마이크로데이터)
- [KOSHA yearly and quarterly reports](https://portal.kosha.or.kr/archive/indus-acc-statis/industrial-acc-statu)
  (year-end reports with definitions and tables; annual analyses back to 1982)
- [Description on Korea's open data portal](https://www.data.go.kr/data/15127634/fileData.do)

## Licence

The microdata are listed on Korea's public data portal (data.go.kr) with no restriction on use
("이용허락범위 제한 없음"). Credit KOSHA and the Ministry of Employment and Labor as the source.
This module combined the files and translated the categories into English.

## Citation

Korea Occupational Safety and Health Agency (KOSHA), 산업재해통계 마이크로데이터 (industrial accident
statistics microdata), 2017 to 2025, https://portal.kosha.or.kr, and Ministry of Employment and Labor,
year-end industrial accident reports. Combined and translated by the authors of this repository.

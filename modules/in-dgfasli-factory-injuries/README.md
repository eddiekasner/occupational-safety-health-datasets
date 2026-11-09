# India: Injuries in Factories and Dock Works (DGFASLI Standard Reference Notes)

**Scope:** India, registered factories under the Factories Act, 1948, and dock works in the major
ports | **Publisher:** Directorate General Factory Advice Service and Labour Institutes (DGFASLI),
Ministry of Labour and Employment | **Years:** 1999 to 2024 (varies by table)

## Background

India's Factories Act, 1948 covers factories that use power and employ 10 or more workers (20 or
more without power). Each state's Inspectorate of Factories, led by a Chief Inspector of Factories,
registers factories, inspects them and receives the notices of accidents that occupiers must send.
DGFASLI, the technical arm of the Ministry of Labour and Employment in Mumbai, advises the
inspectorates and enforces the Dock Workers (Safety, Health and Welfare) Act, 1986 in the major
ports. (Its website now also uses the name DGOSH.)

Each year DGFASLI publishes a **Standard Reference Note**, a PDF whose statistics chapters have
three kinds of tables:

- **Labour Bureau statistics**: injuries in factories, from the annual returns that factories send
  under the Factories Act, compiled by the Labour Bureau. National figures and rates, and figures by
  state, industry and cause. Each note covers five to nine years and runs two years behind.
- **State inspectorate data**: what DGFASLI collects from each Chief Inspector of Factories: fatal
  and non-fatal injuries, dangerous occurrences, factories, employment, occupational diseases,
  inspectors, inspections, prosecutions, and safety, health and welfare provisions.
- **Dock works**: accidents, employment, inspections and facilities in the major ports.

This module extracts all three from the notes for 2006 to 2024.

## What one row represents

Every table has one value per row: one measure (for example `Fatal injuries`) in one year, and:

- `labour_bureau_national.csv`, `inspectorate_national.csv`: the whole country.
- `labour_bureau_by_state.csv`, `inspectorate_by_state.csv`, `enforcement_by_state.csv`: one state
  or union territory (or `Total`).
- `labour_bureau_by_industry.csv`: one of nine industries; `labour_bureau_by_cause.csv`: one cause.
- `occupational_diseases.csv`: one disease in one state.
- `ports_accidents.csv`, `ports_activity.csv`: one major port (or `Total`);
  `ports_accidents_by_agency_type.csv`: one port and one agency or type of accident.

## Why it matters for OSH

- **Two sources that disagree.** In 2022 the state inspectorates counted 1,053 deaths in registered
  factories; the Labour Bureau, from factories' returns, counted 656. The Labour Bureau's figures
  cover only the factories that sent returns (192,372 of the 329,317 registered factories in 2022)
  and, in 2022, no figures for Karnataka, Maharashtra, Tamil Nadu, Uttar Pradesh, Punjab or West
  Bengal.
- **Non-fatal injuries are barely reported.** The inspectorates counted 31,584 non-fatal injuries
  in 2009 and 2,949 in 2023, while deaths fell only from 1,509 to 1,090. In 2023 there were fewer
  than three non-fatal injuries for each death; countries with complete reporting count hundreds.
- **One state can change the national figure.** West Bengal reported 19,180 of the 25,500 non-fatal
  injuries in 2014 and 13,940 in 2015, then 57 in 2016; it sent no data for 2017 or from 2019.
- **Fatal injury rates halved.** Deaths per 100,000 workers in registered factories fell from 11.5
  in 2009 to 5.7 in 2023 (inspectorate data), while employment rose from 13.1 to 19.2 million.
- **Occupational diseases are almost invisible.** All the states that reported recognised 20 cases of
  occupational disease in 2023: 19 cases of noise-induced hearing loss in Gujarat and one of
  asbestosis in Maharashtra. Haryana has reported most of the silicosis (240 cases in 2019).
- **Few inspectors.** In 2023, 630 of 974 sanctioned posts of Inspector of Factories were filled,
  for 334,914 registered factories; 65,676 factories were inspected, against 107,084 in 2008.
- **Causes.** Machinery moved by mechanical power (132 of 622 deaths in 2022), persons falling (91)
  and fires (58) caused the most deaths in the Labour Bureau's tables.

## Limitations to keep in mind

- **Who is covered.** Only registered factories. Most of India's workers are informal, in
  agriculture, construction, small workshops and services, and are not in these figures. Dock
  works cover only the major ports.
- **Missing states.** States that did not send data are missing (not zero) for that year. National
  totals therefore move when a state starts or stops reporting; compare states that report every
  year, and read the notes under each table.
- **The two injury sources measure different things.** The Labour Bureau counts injuries that keep a
  worker off work for 48 hours or more, from factories' returns; its rates are per 100,000 man-days
  worked (frequency rate) and per 1,000 workers employed (incidence rate) in the factories that sent
  returns. The inspectorate data count notified fatal and non-fatal injuries in all registered
  factories. Do not add them together.
- **Revisions.** Each note repeats earlier years, and later notes sometimes revise them (for example
  the Labour Bureau's total injuries in 2014: 4,499 in its state table in the 2021 note, 3,984 in its
  national table in the 2024 note). Each table and year is taken whole from the latest note that has
  it (`source_edition`), so a table's rows come from one note.
- **Published totals.** Figures are kept as published, including errors in the source. The total
  of injuries by state in 2011 is printed as 1,044, though the states add up to 10,441 (the national
  table has 10,441). In 2023, Maharashtra's "imprisonment" cell reads 226,000, which looks like an
  amount of fines. Some totals for 2005 and 2006 include states whose rows are blank.
- **Gaps.** The 2010 note's tables, and some of the 2011 note's, have no cell borders and cannot be
  read reliably, so the single-year state tables for 2009 (inspectors, prosecutions, welfare and so
  on) and some port tables for 2010 and 2011 are missing. The 2013 note merges some rows; the module
  splits them where it can, and leaves out its port tables by agency and type.
- **Industries and states change.** The nine industries of the Labour Bureau's tables follow NIC
  2008 in recent notes and earlier versions of NIC in older ones. Telangana was formed in 2014; Dadra and Nagar
  Haveli and Daman and Diu were merged in 2020 (and reported together before that).

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns, measures and categories |
| `data/tidy/labour_bureau_national.csv` | Working factories submitting returns, employment, injuries and rates, 1999 to 2022 |
| `data/tidy/labour_bureau_by_state.csv` | Total and fatal injuries, frequency and incidence rates by state, 1999 to 2022 |
| `data/tidy/labour_bureau_by_industry.csv` | Injuries and rates in nine industries, 2004 to 2022 |
| `data/tidy/labour_bureau_by_cause.csv` | Total and fatal injuries by cause, 2006 to 2022 |
| `data/tidy/inspectorate_national.csv` | Registered factories, employment, dangerous occurrences, injuries and rates, 2009 to 2023 |
| `data/tidy/inspectorate_by_state.csv` | Fatal and non-fatal injuries, dangerous occurrences, factories, employment, hazardous factories and inspections by state, 2004 to 2023 |
| `data/tidy/enforcement_by_state.csv` | Inspectors, certifying surgeons, prosecutions, safety officers, safety policies and committees, emergency plans, medical and welfare provisions by state, 2005 to 2023 |
| `data/tidy/occupational_diseases.csv` | Occupational diseases reported by states, 2016 to 2023 |
| `data/tidy/ports_accidents.csv` | Accidents, dangerous occurrences, employment and accident rates by major port, 2012 to 2024 |
| `data/tidy/ports_accidents_by_agency_type.csv` | Port accidents by agency (for example lifting appliances) and type (for example fall of persons), 2008 to 2024 |
| `data/tidy/ports_activity.csv` | Inspections, prosecutions, investigations, safety committees, ships, cargo and safety, health and welfare facilities by port, 2008 to 2024 |
| `data/raw/` | DGFASLI's 19 Standard Reference Notes (not committed; about 90 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the notes listed on DGFASLI's Standard Reference Notes page |
| `scripts/extract_tables.py` | Finds the tables by their titles, reads their cells (Python, with pdfplumber) and runs the checks |

Checked by `scripts/extract_tables.py`:

- The states add up to the total in every year for the inspectorate's injuries, factories and
  employment (164 of 164), and DGFASLI's national table equals those state totals (38 of 38).
- The causes add up to the total (30 of 30), and the Labour Bureau's states to their total in 42 of 44
  years (the exceptions are the 2011 misprint and 2005 fatal injuries, 606 against 613).
- The enforcement and welfare tables add up to their totals in 693 of 711 cases, port accidents in
  39 of 40, port accidents by agency and type in 542 of 545, and port activity in 389 of 407 (the
  exceptions are as published, mostly in 2005, 2006, 2009 and 2013).

## Official documentation

The notes are on DGFASLI's website under
[Standard Reference Notes](https://dgfasli.gov.in/Standard-reference-notes). The introduction to each
statistics chapter and the notes under each table define the measures. The Labour Bureau publishes
its statistics under the Factories Act separately.

## Terms of use

DGFASLI's [copyright policy](https://dgfasli.gov.in/en/copyright-policy) says that its website's
contents belong to DGFASLI, should not be reproduced partially or fully without its permission, and
must be acknowledged when referred to. This module reorganises statistical figures from the notes
for non-commercial teaching, with attribution to DGFASLI; it does not reproduce the notes
themselves. If you reuse these files beyond teaching, ask DGFASLI for permission.

## Citation

Directorate General Factory Advice Service and Labour Institutes, Ministry of Labour and Employment,
Government of India. *Standard Reference Note* (2006 to 2024 editions). https://dgfasli.gov.in.
Tables extracted by the authors of this repository.

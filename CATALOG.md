# Dataset Catalog

Candidate datasets for teaching modules. "Status" tracks where each one stands:

- **Module**: module built (see `modules/`)
- **Planned**: confirmed suitable, not started
- **Candidate**: needs review (access, license, size, teaching fit)

Details marked *verify* still need to be checked against the live source page.

## United States

| Dataset | Publisher | What it is | Unit of record | Years | Access | Status |
| --- | --- | --- | --- | --- | --- | --- |
| [ITA case detail (Forms 300/301)](https://www.osha.gov/Establishment-Specific-Injury-and-Illness-Data) | OSHA | Individual recordable injuries and illnesses from establishments with 100+ employees in designated high-hazard industries, including free-text narratives and OSHA-assigned SOC codes | One case | 2023 onward (first collected in 2024 for CY2023) | CSV download | **Module** (2023, 2024, 2025) |
| [ITA summary (Form 300A)](https://www.osha.gov/Establishment-Specific-Injury-and-Illness-Data) | OSHA | Annual establishment totals: cases, days away, hours worked, employees | One establishment-year | 2016 onward | CSV download | Planned (links to case detail via `establishment_id`) |
| [Chemical Exposure Health Data](https://www.osha.gov/opengov/health-samples) ([field definitions](https://www.osha.gov/opengov/osha-health-samples-dataset-field-definitions)) | OSHA | Air, bulk and wipe sampling results from OSHA inspections | One sample result | 1984 onward, updated each January and July | Yearly zip files (CSV from 2013, XML before) | **Module** (1984 to 2025) |
| [Severe Injury Reports](https://www.osha.gov/severeinjury) | OSHA | Employer reports of amputations, in-patient hospitalizations and eye loss, coded with OIICS; federal OSHA states only | One report | 2015 onward | Full CSV download | **Module** (2015 to Nov 2025) |
| [Enforcement data](https://dataportal.dol.gov) (inspections, violations, accidents) | OSHA via DOL | Inspection records, citations, penalties, accident investigation summaries | One inspection / violation | 1970s onward | DOL API (free API key) | **Module** (FY2015 to FY2025) |
| [Frequently cited standards](https://www.osha.gov/ords/imis/citedstandard.naicsman?p_esize=&p_state=FEFederal) | OSHA | Most-cited standards by NAICS code | Standard by industry | Rolling | Web table | Candidate (good companion to ITA) |
| [Census of Fatal Occupational Injuries (CFOI)](https://www.bls.gov/iif/) | BLS | All US work-related fatal injuries | Aggregated series | 1992 onward (3 series with breaks: 1992-2002, 2003-2010, 2011+) | Flat files on download.bls.gov (contact email required) | **Module** (counts 2011 to 2022, rates 2023 to 2024) |
| [Survey of Occupational Injuries and Illnesses (SOII)](https://www.bls.gov/iif/) | BLS | National injury and illness rates by industry, plus case and demographic characteristics | Aggregated series | 1970s onward | Flat files on download.bls.gov (contact email required) | **Module** (rates 2014 to 2024, case characteristics 2011 to 2020) |
| [MSHA mine data](https://arlweb.msha.gov/OpenGovernmentData/OGIMSHA.asp) | MSHA | Mine accidents, injuries and illnesses with narratives, hours worked by operators and contractors, mines, violations and penalties | One accident report / mine-quarter / violation | 2000 onward | Weekly bulk files (pipe-delimited) | **Module** (2000 to 2025) |

## International

| Dataset | Publisher | What it is | Coverage | Access | Status |
| --- | --- | --- | --- | --- | --- |
| [ILOSTAT safety and health at work](https://ilostat.ilo.org/topics/safety-and-health-at-work/) | ILO | Fatal and non-fatal occupational injury counts and rates per 100,000 workers, days lost, labour inspection | About 150 countries, annual (1969 to 2024) | ILOSTAT data API (CSV) | **Module** (19 indicators) |
| [European Statistics on Accidents at Work (ESAW)](https://ec.europa.eu/eurostat/cache/metadata/en/hsw_acc_work_esms.htm) | Eurostat | Non-fatal (4+ days absence) and fatal accidents by NACE sector, sex, age, cause; e.g. tables `hsw_mi01`, `hsw_n2_01`, `hsw_ph3_06` | EU/EFTA, 2008 onward | Eurostat API (JSON-stat) | **Module** (5 tables) |
| [HSE RIDDOR statistics](https://www.hse.gov.uk/statistics/tables/index.htm) and [LFS self-reported injuries](https://www.hse.gov.uk/statistics/lfs/tables.htm) | UK HSE | Reported fatal and non-fatal injuries (series from 1974, by industry, accident kind, age, injury, local area) and survey estimates of self-reported injuries | Great Britain | Excel tables (Open Government Licence) | **Module** (RIDDOR 1974 to 2025/26, LFS 2000/01 to 2024/25) |
| [Safe Work Australia data website](https://data.safeworkaustralia.gov.au/) | Safe Work Australia | Traumatic injury fatalities (TIF), serious workers' compensation claims (NDS), injury frequency rates | Australia, 10 years | Excel detailed data files (manual download; CC BY 4.0) | **Module** (TIF 2016 to 2025, NDS and WCIFR 2015-16 to 2024-25) |
| [WHO/ILO Joint Estimates of the work-related burden of disease and injury](https://www.who.int/teams/environment-climate-change-and-health/monitoring/who-ilo-joint-estimates) | WHO / ILO | Deaths and DALYs attributable to 19 occupational risk factors (41 risk factor and disease pairs), plus solar UV | 183 countries, 2000, 2010, 2016 | Interactive application export (scripted with Playwright); CC BY 3.0 IGO | **Module** |
| Global Burden of Disease (occupational risks) | IHME | Burden attributable to occupational risks over time | Global | GBD Results Tool (registration, non-commercial license) | Candidate |
| [Canada AWCBC National Work Injury, Disease and Fatality Statistics](https://awcbc.org/data-and-statistics/national-work-injury-disease-statistics-program) | AWCBC | Accepted lost time claims and fatalities by province, industry, occupation, injury and worker characteristics | Canada, claims 1982 onward, fatalities 1993 onward | Annual PDF publication (parsed) and Excel summaries; use with acknowledgement | **Module** |

## Selection criteria

1. **Public and redistributable**: we can attach the data (or a sample) to this repo.
2. **Documented**: an official data dictionary exists.
3. **Teachable**: supports questions at both ENVH 312 and ENVH 460/560 level.
4. **Manageable**: works on a student laptop or in Colab (subset if necessary,
   for example by industry or state).

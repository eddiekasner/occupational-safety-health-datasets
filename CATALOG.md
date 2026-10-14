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
| [Severe Injury Reports](https://www.osha.gov/severeinjury) | OSHA | Employer reports of amputations, in-patient hospitalizations and eye loss, coded with OIICS; federal OSHA states only | One report | 2015 onward | Full CSV download | Candidate |
| [Enforcement data](https://enforcedata.dol.gov/) (inspections, violations, accidents) | OSHA via DOL | Inspection records, citations, penalties, accident investigation summaries | One inspection / violation | 1970s onward | Bulk download / [DOL API](https://data.dol.gov/datasets) (API key) (*verify*) | Candidate |
| [Frequently cited standards](https://www.osha.gov/ords/imis/citedstandard.naicsman?p_esize=&p_state=FEFederal) | OSHA | Most-cited standards by NAICS code | Standard by industry | Rolling | Web table | Candidate (good companion to ITA) |
| [Census of Fatal Occupational Injuries (CFOI)](https://www.bls.gov/iif/) | BLS | All US work-related fatal injuries | Aggregated series | 1992 onward (3 series with breaks: 1992-2002, 2003-2010, 2011+) | Flat files on download.bls.gov | Candidate |
| [Survey of Occupational Injuries and Illnesses (SOII)](https://www.bls.gov/iif/) | BLS | National injury and illness rates by industry, plus case and demographic characteristics | Aggregated series | 1970s onward | Flat files / tables (*verify*) | Candidate |
| MSHA mine data | MSHA via DOL | Mine accidents, injuries, employment, violations | One accident / mine-quarter | 1983 onward (*verify*) | Bulk download | Candidate |

## International

| Dataset | Publisher | What it is | Coverage | Access | Status |
| --- | --- | --- | --- | --- | --- |
| [ILOSTAT safety and health at work](https://ilostat.ilo.org/topics/safety-and-health-at-work/) | ILO | Fatal and non-fatal occupational injury counts and rates per 100,000 workers, days lost, labour inspection | About 150 countries, annual (1969 to 2024) | ILOSTAT data API (CSV) | **Module** (19 indicators) |
| [European Statistics on Accidents at Work (ESAW)](https://ec.europa.eu/eurostat/cache/metadata/en/hsw_acc_work_esms.htm) | Eurostat | Non-fatal (4+ days absence) and fatal accidents by NACE sector, sex, age, cause; e.g. tables `hsw_mi01`, `hsw_n2_01`, `hsw_ph3_06` | EU/EFTA, 2008 onward | Eurostat API (JSON-stat) | **Module** (5 tables) |
| [HSE RIDDOR statistics](https://www.hse.gov.uk/statistics/tables/index.htm) | UK HSE | Reported fatal and non-fatal injuries (historical series to 1974, by region, by injury site) | Great Britain | Excel tables | Candidate (non-fatal injuries substantially under-reported; good teaching point) |
| [Safe Work Australia data website](https://data.safeworkaustralia.gov.au/) | Safe Work Australia | Traumatic injury fatalities, workers' compensation claims, industry dashboards | Australia | Interactive + downloads (*verify*) | Candidate |
| WHO/ILO Joint Estimates of the work-related burden of disease and injury | WHO / ILO | Deaths and DALYs attributable to 19 occupational risk factors | 183 countries, 2000-2016 | Downloadable tables (*verify*) | Candidate |
| Global Burden of Disease (occupational risks) | IHME | Burden attributable to occupational risks over time | Global | GBD Results Tool (registration, non-commercial license) | Candidate |
| Canada AWCBC National Work Injury Statistics | AWCBC | Accepted lost-time claims and fatalities by province, industry | Canada | Data request / tables (*verify*) | Candidate |

## Selection criteria

1. **Public and redistributable**: we can attach the data (or a sample) to this repo.
2. **Documented**: an official data dictionary exists.
3. **Teachable**: supports questions at both ENVH 312 and ENVH 460/560 level.
4. **Manageable**: works on a student laptop or in Colab (subset if necessary,
   for example by industry or state).

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
| [ITA summary (Form 300A)](https://www.osha.gov/Establishment-Specific-Injury-and-Illness-Data) | OSHA | Annual establishment totals: deaths, cases, days away, employees and hours worked, with employer names | One establishment-year | 2016 onward | CSV download | **Module** (2016 to 2025; links to case detail via `establishment_id`) |
| [Chemical Exposure Health Data](https://www.osha.gov/opengov/health-samples) ([field definitions](https://www.osha.gov/opengov/osha-health-samples-dataset-field-definitions)) | OSHA | Air, bulk and wipe sampling results from OSHA inspections | One sample result | 1984 onward, updated each January and July | Yearly zip files (CSV from 2013, XML before) | **Module** (1984 to 2025) |
| [Severe Injury Reports](https://www.osha.gov/severeinjury) | OSHA | Employer reports of amputations, in-patient hospitalizations and eye loss, coded with OIICS; federal OSHA states only | One report | 2015 onward | Full CSV download | **Module** (2015 to Nov 2025) |
| [Enforcement data](https://dataportal.dol.gov) (inspections, violations, accidents) | OSHA via DOL | Inspection records, citations, penalties, accident investigation summaries | One inspection / violation | 1970s onward | DOL API (free API key) | **Module** (FY2015 to FY2025) |
| [Frequently cited standards](https://www.osha.gov/ords/imis/citedstandard.naicsman?p_esize=&p_state=FEFederal) | OSHA | Most-cited standards by NAICS code | Standard by industry | Rolling | Web table | Covered by the enforcement module (`standards_by_industry`; OSHA's search tool is behind a CAPTCHA, so the counts are rebuilt from the enforcement data) |
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
| [Global Burden of Disease (occupational risks)](https://vizhub.healthdata.org/gbd-results/) | IHME | Deaths and DALYs attributable to 20 occupational risks, every year since 1990 | Global, 21 regions, 204 countries | GBD Results Tool (free account; non-commercial licence, no redistribution) | **Module** (notebooks and scripts only; students download the data) |
| [Canada AWCBC National Work Injury, Disease and Fatality Statistics](https://awcbc.org/data-and-statistics/national-work-injury-disease-statistics-program) | AWCBC | Accepted lost time claims and fatalities by province, industry, occupation, injury and worker characteristics | Canada, claims 1982 onward, fatalities 1993 onward | Annual PDF publication (parsed) and Excel summaries; use with acknowledgement | **Module** |

## Latin America

| Dataset | Publisher | What it is | Coverage | Access | Status |
| --- | --- | --- | --- | --- | --- |
| SINAN work-related notifications (serious work accidents `ACGR`, biological material exposure, poisonings, and other work-related conditions) | Brazil Ministry of Health (DATASUS) | Case-level notifications of work accidents and work-related diseases from the health system, covering formal and informal workers | Brazil, about 2007 onward (*verify* years for each condition) | DATASUS public FTP (ftp.datasus.gov.br), `.dbc` files (readable in R with `read.dbc`, or the `microdatasus` and `healthbR` packages); free download includes investigated cases only | Candidate (strong: case-level, open, covers informal workers) |
| CAT work accident reports (via the SmartLab Observatory of OSH) | Brazil INSS / Ministry of Labour; observatory by MPT and ILO Brazil | Work accident reports (Comunicação de Acidente de Trabalho) for formally employed workers: about 6.7 million accidents and 25,500 deaths 2012 to 2022 | Brazil, 2012 onward | Interactive panels; downloadable microdata *verify* (no open CSV found yet) | Candidate |
| [SUSESO accident statistics](https://www.suseso.gob.cl/) | Chile Superintendencia de Seguridad Social | Annual accident and occupational disease reports and rates under Law 16.744, by mutual insurer, region and sector | Chile, rates from 2006 onward | Annual reports (PDF, possibly Excel annexes *verify*) | Candidate (needs a machine-readable source) |
| [SRT accident reports](https://www.argentina.gob.ar/node/125610) | Argentina Superintendencia de Riesgos del Trabajo | National registers of work accidents and occupational diseases, by province and sector | Argentina | Annual reports; open data on datos.gob.ar *verify* | Candidate (needs a machine-readable source) |
| Colombian occupational risk system statistics (Fasecolda, Ministry of Labour) | Fasecolda (insurers' federation) / Ministry of Labour | Covered workers, accepted work accidents, occupational diseases and deaths, by economic activity and department; system covers about 57% of the employed | Colombia | Statistics pages; download format *verify* | Candidate (needs a machine-readable source) |
| IMSS statistical yearbook (Memoria Estadística) | Mexico Social Security Institute | 32 tables on work risks: accidents, commuting accidents and diseases by sector, occupation, state | Mexico (insured workers, about a quarter of the economically active population) | Excel or PDF tables *verify* | Candidate |

## Asia

| Dataset | Publisher | What it is | Coverage | Access | Status |
| --- | --- | --- | --- | --- | --- |
| [Fatal accident database (死亡災害データベース)](https://anzeninfo.mhlw.go.jp/anzen_pg/SIB_FND.html) | Japan Ministry of Health, Labour and Welfare (Workplace Safety Site) | Every work-related death since 1991, one row each, with a short description, time, establishment size, industry, agent and accident type (in Japanese) | Japan, 1991 to 2023 | Excel download; licence *verify* (Japanese government standard terms, likely CC BY compatible) | Candidate (strong: case-level with narratives; also a sample database of injuries with 4+ days off) |
| [Industrial accident statistics (산업재해 현황)](https://www.data.go.kr/data/15084677/fileData.do) | Korea Ministry of Employment and Labor and KOSHA | Injured workers and deaths by industry, accident type, region and labour office; disease cases | South Korea, 2004 onward for several series | data.go.kr CSV files and open API (no restriction on use) | Candidate (strong: open, long series) |
| [Workplace safety and health statistics](https://data.gov.sg/datasets/d_29fcac578ced89de06ea40802b852cc4/view) | Singapore Ministry of Manpower | Workplace fatalities, major injuries and rates per 100,000 workers, by industry and accident type | Singapore, 2019 onward (earlier years in MOM yearbook PDFs) | data.gov.sg CSV and API (Singapore Open Data Licence) | Candidate (small but clean; open licence) |
| [Injuries in registered factories](https://dataful.in/datasets/23763/) | India Directorate General Factory Advice Service and Labour Institutes (DGFASLI) | Fatal and non-fatal injuries in registered factories, by state and year (for example 1,017 deaths in 2022) | India, factories only | Standard Reference Note (PDF); some tables on data.gov.in or Dataful *verify* | Candidate (coverage is a teaching point: factories only, large under-reporting) |
| [OSH statistics](https://www.labour.gov.hk/common/osh/pdf/Bulletin2021_issue22_en.pdf) | Hong Kong Labour Department | Occupational injuries and diseases by sector, with rates per 1,000 employees | Hong Kong | Annual PDF bulletins; data.gov.hk tables *verify* | Candidate |

## Africa

Few African countries publish occupational injury data in machine-readable form. ILOSTAT (already a
module) has national figures for some countries.

| Dataset | Publisher | What it is | Coverage | Access | Status |
| --- | --- | --- | --- | --- | --- |
| Mine health and safety statistics | South Africa Department of Mineral Resources and Energy | Mine deaths and injuries by commodity (gold, platinum, coal, other), for example 42 deaths in 2024 | South Africa | Annual ministerial statements and reports (PDF) *verify* | Candidate (compare with MSHA module) |
| [Child labour indicators](https://data.unicef.org/resources/child-labour-data-eastern-southern-africa-2026/) | UNICEF (MICS surveys) and ILO | Share of children in child labour and in hazardous working conditions, by age, sex and sector | Many African and other low and middle income countries | UNICEF data warehouse (CSV); microdata from mics.unicef.org with registration *verify* | Candidate |
| Workers Compensation Fund claims | Tanzania Workers Compensation Fund | Work injury claims (a published study analysed 4,578 claims from 2016 to 2019) | Tanzania | Not public; by request | Candidate (unlikely: no open access) |

## Europe (national and EU surveys)

| Dataset | Publisher | What it is | Coverage | Access | Status |
| --- | --- | --- | --- | --- | --- |
| INAIL open data | Italy National Institute for Insurance against Accidents at Work | Case-level reported work accidents and occupational diseases: date, region, sector, the worker's age, sex and birthplace, outcome | Italy, about 2010 onward | CSV, XML and RDF downloads (also on dati.gov.it); open licence *verify* (a copy on the Milan portal is CC BY 4.0) | Candidate (strong: case-level, open) |
| [Occupational accident statistics](https://stat.fi/en/statistics/ttap) | Statistics Finland | Accidents at work (4+ days of disability) and fatalities by industry, occupation, cause | Finland | StatFin database (PxWeb tables and API; CC BY 4.0) | Candidate |
| Occupational risk statistics (sinistralité AT/MP) | France Assurance Maladie (risques professionnels) | Work accidents, commuting accidents and occupational diseases by sector (NAF code) | France | Annual reports and sector tables; data.gouv.fr datasets *verify* | Candidate |
| European Survey of Enterprises on New and Emerging Risks (ESENER) | EU-OSHA | Survey of workplaces on how they manage safety and health risks, including psychosocial risks | EU and other European countries, 2009, 2014, 2019, 2024 | Microdata via the UK Data Service (free registration) *verify*; summary results online | Candidate |
| [European Working Conditions Survey (EWCS)](https://www.eurofound.europa.eu/surveys/about-eurofound-surveys/data-availability) | Eurofound | Survey of workers on physical and psychosocial exposures, working time and health | EU and other European countries, 1991 to 2024 | Microdata via the UK Data Service (free registration); EWCS 2024 released in 2026 *verify* | Candidate (strong for 460/560: exposures, not just injuries) |
| [Accidents at work and work-related health problems, LFS ad hoc modules](https://ec.europa.eu/eurostat/web/health/database) | Eurostat | Self-reported accidents, work-related health problems and exposure to risk factors (tables `hsw_pb*`, `hsw_exp*`) | EU, 2007, 2013, 2020 | Eurostat API (open) | Candidate (could extend the ESAW module) |

## Selection criteria

1. **Public and redistributable**: we can attach the data (or a sample) to this repo.
2. **Documented**: an official data dictionary exists.
3. **Teachable**: supports questions at both ENVH 312 and ENVH 460/560 level.
4. **Manageable**: works on a student laptop or in Colab (subset if necessary,
   for example by industry or state).

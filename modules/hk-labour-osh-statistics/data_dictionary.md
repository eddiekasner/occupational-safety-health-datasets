# Data Dictionary: Hong Kong Occupational Safety and Health Statistics

Built by `scripts/extract_tables.py` from the Labour Department's *Occupational Safety and Health
Statistics* (2015 and 2025 editions) and two data.gov.hk workbooks. Figures are as published.
Blank means not applicable (`N.A.` in the report).

## Trends (`trends.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `measure` | See below |
| `industry` | `All industries` (all industrial undertakings), `Construction`, `Manufacturing`, `Catering (to 2008)`, `Food and beverage services (from 2009)`, or `All economic activities` (for occupational injuries and work fatalities) |
| `value` | The count, number of workers or rate |
| `source_edition` | Edition of the report the figure comes from (2015 for years up to 2015, 2025 for 2016 onward) |

Measures:

| Measure | Industries | Years |
| --- | --- | --- |
| `Industrial accidents` | industrial undertakings | 1999 to 2025 (construction from 2006; catering to 2008; food and beverage from 2009) |
| `Industrial accident fatalities` | as above | as above |
| `Workers (employment size)` | as above | as above |
| `Industrial accident rate per 1,000 workers` | as above | as above |
| `Industrial accident fatality rate per 1,000 workers` | as above | as above |
| `Occupational injuries` | `All economic activities` | 2006 to 2025 |
| `Occupational injury rate per 1,000 employees` | `All economic activities` | 2006 to 2025 |
| `Work fatalities` | `All economic activities` | 2016 to 2025 |
| `Work fatality rate per 1,000 employees` | `All economic activities` | 2016 to 2025 |

Industrial accidents are injuries and deaths in industrial undertakings under the Factories and
Industrial Undertakings Ordinance. Occupational injuries are cases reported under the Employees'
Compensation Ordinance causing death or more than three days of incapacity, in all economic
activities. Work fatalities are deaths in industrial undertakings plus deaths at other workplaces
under the Occupational Safety and Health Ordinance. For construction, workers are manual workers on
construction sites. Industries before 2009 follow HSIC Version 1.1, and from 2009 HSIC Version 2.0;
only construction is comparable across the break.

## Occupational diseases (`occupational_diseases.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year, 2006 to 2025 |
| `disease` | Occupational disease, or `Total` |
| `cases` | Number of confirmed cases (blank for mesothelioma before it was prescribed in 2008) |
| `incidents` | For gas poisoning only: the number of incidents (one incident can poison several people) |
| `source_edition` | As above |

Diseases listed in one edition only (for example `Beat knee`, `Legionnaires' disease` and
`Mercury poisoning` in the 2025 edition) had no cases in the years of the other. The diseases add
up to `Total` in every year. Occupational deafness includes hearing loss in one ear from 2011.

## By industry, 2024 and 2025 (`by_industry_2024_2025.csv`)

| Column | Meaning |
| --- | --- |
| `statistic` | `Industrial accidents` or `Occupational injuries` |
| `industry` | Industry, or `Total`. Industrial accidents use the Labour Department's industry groups; occupational injuries use the 14 HSIC 2.0 industry sections |
| `parent` | `Manufacturing` for the manufacturing industries listed separately (they add up to `Manufacturing`); blank otherwise |
| `year` | 2024 or 2025 |
| `cases` | Number of accidents or injuries |
| `fatalities` | Number of deaths among them |

## By type of accident, 2024 and 2025 (`by_type_2024_2025.csv`)

| Column | Meaning |
| --- | --- |
| `statistic` | As above |
| `industry` | Industry, or `Total` (all industrial undertakings, or all workplaces) |
| `parent` | As above |
| `accident_type` | Type of accident (for example `Fall of person from height`, `Slip, trip or fall on same level`, `Injured whilst lifting or carrying`), or `Total` |
| `year`, `cases`, `fatalities` | As above |

The types add up to `Total` for each industry and year. For occupational injuries, the pages
cover selected industries only; some are parts of an industry section (for example, `Wholesale`,
`Retail trade` and `Import and export trade` are parts of `Import/export, wholesale and retail
trades`), and `Professional and business services (excluding pest control and cleaning)` plus
`Pest control and cleaning services` make up the section `Professional and business services`.
Do not add industries together to get a total; use the `Total` rows.

## Occupational health services (`health_services.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year, 2018 to 2025 |
| `activity` | Kind of service, as published by the Labour Department (clinical consultations, medical examinations, occupational hygiene surveys, investigations of occupational diseases and health problems, sick leave clearance interviews for injured employees) |
| `count` | Number provided in the year |

## Clinic patients (`clinic_patients.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year, 2017 to 2025 |
| `disease_group` | `Musculoskeletal diseases`, `Injuries`, `Auditory diseases`, `Respiratory diseases`, `Neurological diseases`, `Skin diseases`, `Visual diseases` or `Other diseases` |
| `new_patients` | New patients at the Labour Department's occupational health clinics |

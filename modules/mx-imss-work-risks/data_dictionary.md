# Data Dictionary: Mexico IMSS Work Risks

Built by `scripts/extract_tables.py` from chapter VII ("Salud en el Trabajo") of IMSS's
statistical yearbooks, 2016 to 2024. Every table has English labels and, in a column ending in
`_es`, the Spanish label as published (spelled the same way in every year). Blank means not
published.

## Common categories

**`risk`**, the type of work risk:

| Value | Meaning |
| --- | --- |
| `All work risks` | Work accidents, commuting accidents and occupational diseases |
| `Work accidents` | Accidents at or because of work |
| `Commuting accidents` | Accidents on the direct way between home and work |
| `Occupational diseases` | Diseases caused by work, including COVID-19 from 2020 |
| `Work accidents and diseases` | Work accidents plus occupational diseases (no commuting accidents); IMSS's usual base for rates |
| `COVID-19`, `COVID-19-related respiratory diseases`, `Occupational diseases excluding COVID-19` | The three parts of occupational diseases, in `by_state.csv` for 2020 to 2023 |

**Cases** are work risks that ended in the year: by medical discharge, the start of a permanent
incapacity, or death. **Permanent incapacities** are new permanent incapacity rulings (including
re-evaluations). **Workers** are the annual average number of workers insured against work risks.

`sex` is `Male` or `Female`. `age_group` is `Under 15`, five-year groups from `15-19` to `70-74`,
and `75 and over`.

## National series (`national.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year, 2011 to 2024 |
| `measure` | `Companies` (with work risk insurance), `Workers`, `Cases`, `Permanent incapacities` or `Deaths` |
| `risk` | Type of risk (blank for companies and workers) |
| `value` | The number |
| `source_yearbook` | The yearbook the figure comes from: the latest one that has the year |

## By state office (`by_state.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year, 2016 to 2024 |
| `office` | IMSS state office (OOAD), or `National` |
| `office_es` | Its Spanish name |
| `state` | The state the office is in (Mexico City, the State of Mexico and Veracruz have two offices each) |
| `companies`, `workers` | Companies and workers insured against work risks in the office |
| `risk` | Type of risk |
| `cases`, `permanent_incapacities`, `deaths` | Numbers for that type of risk. Blank when the yearbook does not publish the figure (for example, permanent incapacities and deaths for `Work accidents and diseases`) |

The offices add up to `National`. Workers and companies are repeated on each row of an office.

## By economic activity (`by_activity.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `activity`, `activity_es` | Division of economic activity in IMSS's classification of companies, or `National` |
| `workers` | Workers insured against work risks (blank for `Not identified`) |
| `risk` | Type of risk |
| `cases` | Number of cases |

Divisions: agriculture, livestock, forestry, fishing and hunting; mining and quarrying;
manufacturing; construction; electricity and water supply; commerce; transport and communications;
services to businesses, people and households; social and community services; and not identified.

## By age and sex (`by_age_sex.csv`)

| Column | Meaning |
| --- | --- |
| `year`, `age_group`, `sex` | As above |
| `workers` | Workers insured against work risks |
| `cases` | Cases of all work risks |

## Occupational diseases (`occupational_diseases.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year, 2011 to 2024 |
| `disease`, `disease_es` | Diagnosis group (based on the ICD-10 principal diagnosis), or `Total` |
| `cases` | Number of cases |
| `source_yearbook` | As in `national.csv` |

The total includes cases with no recorded diagnosis. The main groups are `Hearing loss`, `Back
disorders (dorsopathies)`, `Pneumoconiosis`, `Shoulder lesions`, `Carpal tunnel syndrome`,
`Poisoning`, `Contact dermatitis`, and, from 2020, `COVID-19` and `COVID-19-related respiratory
diseases`. Until 2019, `Infectious and parasitic diseases` also included influenza and pneumonia
(ICD-10 J10 to J22).

## Causes of accidents (`accident_causes.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year (commuting accidents from 2019) |
| `risk` | `Work accidents` or `Commuting accidents` |
| `cause`, `cause_es` | External cause (ICD-10 chapter XX groups), for example `Falls`, `Exposure to inanimate mechanical forces` (struck by, caught in or cut by objects and machinery) or `Motorcyclist injured in transport accident` |
| `sex`, `age_group` | As above |
| `cases` | Number of accidents |

## Body regions and types of injury (`body_region_injury.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `body_region`, `body_region_es` | Injured body region, for example `Wrist and hand` |
| `injury`, `injury_es` | Type of injury, for example `Fractures` or `Dislocations, sprains and strains` |
| `sex` | As above |
| `cases` | Number of work accidents |

## Occupations (`occupations.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `occupation`, `occupation_es` | Occupation (Mexican occupational classification, SINCO), for the 24 occupations with the most work accidents that year; the others are `Other, less frequent` |
| `injury`, `injury_es`, `sex`, `cases` | As in `body_region_injury.csv` |

# Data Dictionary: Singapore Workplace Safety and Health Statistics

Built by `scripts/extract_tables.py` from the statistical tables (Annex B) of MOM's Workplace
Safety and Health Reports for 2019, 2021, 2023 and 2025. Each year comes from the latest report
that covers it (`source_report`). Blank `value` means "n.a." in the report (for example, rates
that MOM does not publish for small sub-industries).

## Injuries by industry (`injuries_by_industry.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `measure` | `Fatal injuries`, `Major injuries`, `Minor injuries`, `Occupational diseases` (confirmed cases), `Man-days lost` |
| `series` | For minor injuries and man-days lost: `Standard` (injuries with 4 or more days of medical leave or 24 hours in hospital, the rule before 2021, still published) or `New (any medical leave)` (any medical leave or light duty, from 2021). Blank for the other measures |
| `statistic` | `count`, or `rate` (per 100,000 workers) |
| `industry` | Industry or sub-industry, with names harmonised across reports, or `All industries` (national figure) |
| `parent` | For a sub-industry, the industry it belongs to (the parent's figure includes it); blank for an industry |
| `value` | The count or rate |
| `label` | Name as published in the report |
| `source_report` | Year of the report the figure comes from |

Industries follow MOM's groupings of the Singapore Standard Industrial Classification. `Marine`
(shipbuilding and repair) is reported separately from manufacturing. Main sub-industries:
`Regular construction`, `Smaller scale works (renovation, addition and alteration)` and
`Work-related traffic accidents` under construction (from 2022); `Metalworking` and other
manufacturing activities; `Logistics & transport`; `Wholesale trade` and `Retail trade`;
`Accommodation` and `Food & beverage service activities`; `Cleaning & landscape maintenance
activities` and `Security & investigation activities`; and `Health & social services`,
`Education` and other community services.

For 2024 and 2025, `All industries` excludes platform workers, except for fatal injuries (which
include them; `Platform workers` is listed as its own group in 2025).

## Injury types (`injury_types.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `severity` | `Major` or `Minor` |
| `series` | For minor injuries: `Standard` or `New (any medical leave)`, as above |
| `injury_type` | Type of injury (names harmonised), or `Total` |
| `value` | Number of injuries |
| `label`, `source_report` | As above |

Major injuries are defined by MOM: amputation, blindness, deafness, paralysis, crushing, fractures
and dislocations of the head, back, chest and abdomen, neck, hip and pelvis, exposure to electric
current, asphyxia or drowning, and burns, concussion or mosquito-borne disease with more than 20
days of medical leave. Other injuries are minor.

## Occupational diseases (`occupational_diseases.csv`)

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `disease` | Disease or disease group, or `Total` |
| `group` | For a specific disease, the group it belongs to (for example, `Back injuries due to ergonomic risks` in `Work-related musculoskeletal disorders`); blank for a group |
| `value` | Number of confirmed cases |
| `label`, `source_report` | As above |

The groups (rows with a blank `group`, other than `Total`) add up to `Total` in every year.
Noise-induced deafness was renamed noise-induced hearing loss in the 2025 report; both are
`Noise-induced hearing loss` here.

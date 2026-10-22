# Data Dictionary: Chile Work Accidents, Commuting Accidents and Occupational Diseases (SUSESO)

Built by `scripts/extract_tables.py` from chapter I of SUSESO's yearbooks (*Estadísticas de la
Seguridad Social*, 2014 to 2025 editions). All tables are long: one value per row, with columns
that say what the value is.

## Common columns

| Column | Meaning |
| --- | --- |
| `year` | Year the figure refers to |
| `insurer` | `ACHS`, `MUSEG` or `IST` (the three mutual insurers), `ISL` (the public insurer), `Mutual insurers` (the three mutual insurers together) or `Total` (all four insurers). Where a table of counts gives the three mutual insurers but not their total, `Mutual insurers` is their sum |
| `case_type` | `Work accidents`, `Commuting accidents`, `Work and commuting accidents` (both), `Occupational diseases` (up to the 2024 yearbook; includes COVID-19), or `Occupational diseases (excluding COVID-19)` (2025 yearbook, 2021 to 2025; counted by date of notification). Blank for protected workers |
| `measure` | See below |
| `value` | The number, rate or average |
| `source_yearbook` | Yearbook the figure was taken from. Each yearbook repeats earlier years; each year is taken from the latest yearbook that has it |

## Measures

| Measure | Meaning |
| --- | --- |
| `Protected workers` | Average number of workers covered by the insurance in the year |
| `Protected workers (unique persons)` | (2025 yearbook) Average number of people covered, counting each person once |
| `Protected employment relationships` | (2025 yearbook) Average number of covered employment relationships; one person can have several |
| `Cases` | Accidents or occupational diseases accepted by the insurers |
| `Days lost` | Days off work paid for the cases |
| `Mean days lost per case` | Days lost divided by cases |
| `Accidents per 100 workers` | Accidents per 100 protected workers (per 100 employment relationships in the 2025 yearbook) |
| `Deaths` | Workers who died from the accident |
| `Deaths per 100,000 workers` | Deaths per 100,000 protected workers |

Accident rates cover the mutual insurers only. SUSESO published rates
as fractions in some yearbooks; they are scaled here to per 100 or per 100,000.

**Do not add `Work accidents` and `Commuting accidents` to `Work and commuting accidents`** in a
calculation that also uses the third row: they overlap.

## National series (`national.csv`)

| Column | Meaning |
| --- | --- |
| `year` | 2010 to 2025 |
| `insurer` | As above |
| `sex` | `Total` for all rows except protected workers (unique persons), which are also given for `Female`, `Male` and `Unknown` |
| `case_type`, `measure`, `value`, `source_yearbook` | As above |

`Protected workers` cover 2010 to 2024; for 2021 to 2025 the 2025 yearbook gives `Protected
workers (unique persons)` for all insurers (`Total`).

## By economic sector (`by_sector.csv`)

| Column | Meaning |
| --- | --- |
| `year` | 2013 to 2025 |
| `grouping` | `Sections` (sections of Chile's classification of economic activities, based on ISIC Revision 3; 2014 to 2025) or `Broad groups` (SUSESO's broad groups; the 2014 yearbook and the death rates by sector) |
| `sector`, `sector_es` | Sector in English and Spanish, or `Total` |
| `insurer`, `case_type`, `measure`, `value`, `source_yearbook` | As above |

Sections include `Agriculture, livestock, hunting and forestry`, `Fishing`, `Mining and quarrying`,
`Manufacturing`, `Construction`, `Transport, storage and communications`, `Health and social work`,
`Private households with domestic staff` and `Unknown`. Broad groups include `Agriculture and
fishing`, `Mining`, `Commerce`, `Transport and communications`, `Financial services` and
`Community, social and personal services`; some yearbooks split out `Education` and `Health`, or
group them as `Services`.

## By region (`by_region.csv`)

| Column | Meaning |
| --- | --- |
| `year` | 2014 to 2025 |
| `region`, `region_es` | One of Chile's 16 regions (short English name, for example `Santiago Metropolitan`, `Biobío`; Ñuble, created in 2018, from 2019), `Abroad`, `Unknown`, or `Total` |
| `insurer`, `case_type`, `measure`, `value`, `source_yearbook` | Protected workers, cases, days lost, mean days lost and deaths |

## By size of employer (`by_size.csv`)

| Column | Meaning |
| --- | --- |
| `year` | 2014 to 2025 |
| `workers`, `workers_es` | Number of workers of the employer, or `Self-employed`, `Unknown` or `Total` |
| `insurer`, `case_type`, `measure`, `value`, `source_yearbook` | Protected workers, cases, days lost and mean days lost |

The size groups are `1-9`, `10-25`, `26-100`, `101-499`, `500-999` and `1000 and over`, with
these exceptions, kept as SUSESO labelled them:

- Up to 2019, the tables of days lost use `1-10` and `11-25`.
- In 2024, cases and days lost use finer groups: `26-49`, `50-100`, `101-199` and `200-499`
  (protected workers keep `26-100` and `101-499`).
- In 2025, all tables use `26-49`, `50-99`, `100-199` and `200-499`.

`Self-employed` is missing in 2022 to 2024, and `Unknown` starts in 2022. To compare years, add
the finer groups back into `26-100` and `101-499`.

## By sex (`by_sex.csv`)

| Column | Meaning |
| --- | --- |
| `year` | 2014 to 2025 (by region from 2016) |
| `sex` | `Female`, `Male`, `Unknown` or `Total` |
| `by` | What the table is broken down by besides sex: `Insurer`, `Sector` or `Region` |
| `category`, `category_es` | The sector or region in English and Spanish (as in `by_sector.csv` and `by_region.csv`), or `Total`. For `by` = `Insurer`, always `Total` (the insurer is in `insurer`) |
| `insurer`, `case_type`, `measure`, `value`, `source_yearbook` | Protected workers, cases, days lost and deaths |

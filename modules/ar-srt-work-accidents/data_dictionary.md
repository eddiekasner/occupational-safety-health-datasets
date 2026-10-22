# Data Dictionary: Argentina Work Accidents and Occupational Diseases (SRT)

Built by `scripts/extract_tables.py` from SRT's historical series. All tables are long: one value
per row, with columns that say what the value is.

## Common columns

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `case_type` | `All cases` (work accidents, occupational diseases, commuting accidents and relapses; SRT's "global" indicators) or `Work accidents and occupational diseases` (without commuting accidents and relapses; "AT y EP") |
| `measure` | See below |
| `scope` | `Workplaces` (employers in the private and public sectors; "unidades productivas"), `Domestic workers` (workers employed by households, covered from November 2014; "casas particulares") or `Total system` (both) |
| `value` | The number, rate or average |

## Measures

| Measure | Meaning |
| --- | --- |
| `Cases` | Cases notified by insurers |
| `Cases with days lost or disability` | Cases with at least one day off work, or a permanent disabling injury |
| `Deaths` | Workers who died |
| `Cases per 1,000 workers` | Cases with days lost or disability per 1,000 covered workers (incidence rate) |
| `Deaths per million workers` | Deaths per million covered workers |
| `Lethality per 100,000 cases` | Deaths per 100,000 notified cases |
| `Mean days lost` | Average days off work per case with days lost |

Covered workers are those declared by employers each month. Counts are in `national.csv` only;
the other tables have rates.

## Sectors

`sector` is in English and `sector_es` in Spanish; `classification` says which classification the
sector follows:

- `CIIU Rev. 2` (to 2018): SRT's 9 groups of ISIC Revision 2: agriculture; mining; manufacturing;
  electricity, gas and water; construction; trade, restaurants and hotels; transport, storage and
  communications; financial and business services; community, social and personal services. Plus
  `Not classified` and `No data`.
- `CIIU Rev. 4` (from 2019): the 21 sections of ISIC Revision 4 (for example `Construction`,
  `Human health and social work activities`, `Activities of households as employers of domestic
  personnel`), plus `No data`.

`Total` is all sectors.

## National series (`national.csv`)

| Column | Meaning |
| --- | --- |
| `year` | 1996 to 2025 (1996 covers July to December only; work accident and disease series start in 1997) |
| `classification`, `sector`, `sector_es` | Sector (1 digit), or `Total` |
| `case_type`, `measure`, `scope`, `value` | As above; all seven measures |

## By province (`by_jurisdiction.csv`)

| Column | Meaning |
| --- | --- |
| `year` | 2007 to 2024 |
| `jurisdiction`, `jurisdiction_es` | One of the 23 provinces or Buenos Aires City (`C.A.B.A.`), or `Total` |
| `classification`, `sector`, `sector_es` | `Total` for all sectors, or a sector (1 digit) |
| `case_type`, `measure`, `scope`, `value` | Rates of cases and deaths |

The tables for all sectors cover workplaces, domestic workers (from 2014) and the whole system;
the tables by sector cover workplaces.

## By sex and age (`by_sex_age.csv`) and by sex and sector (`by_sex_sector.csv`)

| Column | Meaning |
| --- | --- |
| `year` | 2011 to 2024 |
| `sex` | `Female` or `Male` |
| `age_group` | `16-19`, five-year groups to `60-64`, `65 and over`, or `Total` |
| `classification`, `sector`, `sector_es` | (`by_sex_sector.csv`) Sector (1 digit), or `Total` |
| `case_type`, `measure`, `scope`, `value` | Rates of cases and deaths, and lethality |

Age groups and sectors are for workplaces; the `Total` rows are given for workplaces, domestic
workers and the whole system.

## By size of employer (`by_size.csv`)

| Column | Meaning |
| --- | --- |
| `year` | 1997 to 2024 |
| `workers`, `workers_es` | Number of workers of the employer: `1`, `2`, `3 to 5`, `6 to 10`, and so on to `More than 5000`, or `Total` |
| `case_type`, `measure`, `scope`, `value` | Rates of cases and deaths, for workplaces |

## By 3-digit sector (`by_sector_3digit.csv`)

| Column | Meaning |
| --- | --- |
| `year` | 2010 to 2024 for both sexes, 2012 to 2024 by sex |
| `classification` | `CIIU Rev. 2` (to 2018) or `CIIU Rev. 4` (from 2019) |
| `code` | 3-digit sector code (blank for totals). From 2019 these are ISIC Revision 4 groups, though SRT numbers a few groups differently |
| `sector`, `sector_es` | Sector name in English (translated with the help of an AI model) and Spanish, or `Total` |
| `sex` | `Total`, `Female` or `Male` |
| `case_type`, `measure`, `scope`, `value` | Rates of cases and deaths |

# Data Dictionary: ILOSTAT Occupational Safety and Health

Built by `scripts/build_dataset.R` from ILOSTAT indicators downloaded through the
[ILOSTAT data API](https://rplumber.ilo.org/__docs__/).

## Columns shared by all three tables

| Column | Meaning |
| --- | --- |
| `country_code` | ISO 3166 three-letter country or territory code |
| `country` | Country or territory name |
| `region` | UN M49 continent: Africa, Americas, Asia, Europe or Oceania |
| `year` | Reference year |
| `measure` | What `value` measures (see below) |
| `value` | The number |
| `source_type` | Short code for the type of source (see below) |
| `source` | Name of the national source |
| `obs_status` | ILO flag on the value, such as "Unreliable" (usually blank) |
| `notes` | ILO notes on coverage and definitions, separated by `|` |

## `injuries_national.csv`

Extra columns: `sex` (Total, Male, Female) and `migrant_status` (Total, Migrants, Non migrants, Unknown).
For national totals, filter `sex == "Total"` and `migrant_status == "Total"`.

| `measure` | Meaning | ILOSTAT indicator |
| --- | --- | --- |
| `fatal_rate_per_100k` | Fatal occupational injuries per 100,000 workers in the reference group | INJ_FATL_SEX_MIG_RT_A |
| `nonfatal_rate_per_100k` | Non-fatal occupational injuries per 100,000 workers in the reference group | INJ_NFTL_SEX_MIG_RT_A |
| `fatal_cases` | Cases of fatal occupational injury | INJ_FATL_SEX_MIG_NB_A |
| `nonfatal_cases` | Cases of non-fatal occupational injury | INJ_NFTL_SEX_MIG_NB_A |
| `days_lost` | Days lost due to injuries with temporary incapacity for work | INJ_DAYS_SEX_MIG_NB_A |
| `workers_covered_thousands` | Workers in the reference group (the denominator), in thousands | INJ_WORK_SEX_MIG_NB_A |

Rate = cases / (workers covered x 1,000) x 100,000.

## `injuries_by_sector.csv`

Extra columns:

| Column | Meaning |
| --- | --- |
| `classification` | `Aggregate` (broad ILO sectors, comparable across ISIC revisions) or `ISIC Rev. 4` (sections A to U) |
| `sector_code` | Sector code, for example `TOTAL`, `F` (construction) or `CON` |
| `sector` | Sector name |

| `measure` | ILOSTAT indicator |
| --- | --- |
| `fatal_rate_per_100k` | INJ_FATL_ECO_RT_A |
| `nonfatal_rate_per_100k` | INJ_NFTL_ECO_RT_A |

Older ISIC revisions, and cases and workers by sector, are in the raw downloads.

## `labour_inspection.csv`

Extra column: `sex` (Total, Male, Female; only for `inspectors`, otherwise Total).

| `measure` | Meaning | ILOSTAT indicator |
| --- | --- | --- |
| `inspectors` | Number of labour inspectors | LAI_INSP_SEX_NB_A |
| `inspectors_per_10k_employed` | Labour inspectors per 10,000 employed persons | LAI_INDE_NOC_RT_A |
| `inspection_visits` | Number of labour inspection visits to workplaces | LAI_VIST_NOC_NB_A |
| `visits_per_inspector` | Labour inspection visits per inspector | LAI_VDIN_NOC_RT_A |
| `workplaces_registered` | Registered workplaces that could be selected for inspection | LAI_WOPL_NOC_NB_A |

## `source_type`

The part of ILOSTAT's source label before " - ". The code and the source name sometimes
disagree (for example, a source coded `ADM-IR` but named "Labour Inspectorate Records"), so
read `source` too.

| Code | Meaning |
| --- | --- |
| ADM | Administrative records (general) |
| ADM-IR | Insurance records (workers' compensation or social insurance) |
| ADM-LIR | Labour inspectorate records |
| ADM-... (other) | Other administrative registers (see `source`) |
| ES | Establishment survey |
| EC | Establishment census |
| LFS | Labour force survey (household survey) |
| OE | Official estimates |
| Other | Other sources |

## Common phrases in `notes`

| Note | Meaning |
| --- | --- |
| Coverage of occupational injuries: Reported injuries | All injuries reported to the authority |
| Coverage of occupational injuries: Compensated injuries | Only injuries that were compensated (usually fewer) |
| Type of cases: Including cases of occupational disease / commuting accidents | Broader than the international guidelines, which keep these separate |
| Reference group coverage: Insured persons / Employees | The denominator is not all workers |
| Data reference period: Noncalendar year | For example, a fiscal year |

## Definitions

Based on the ILO's 1998 resolution concerning statistics of occupational injuries and the
SDG 8.8.1 metadata. National definitions vary.

- **Occupational injury**: an injury resulting from an occupational accident. Occupational
  diseases are a separate category, and commuting accidents should be counted separately.
- **Fatal occupational injury**: an occupational injury leading to death. Countries set different
  time limits between the accident and the death (for example one year, six months, or none).
- **Non-fatal occupational injury**: an injury that does not lead to death and causes absence
  from work. The minimum absence counted differs between countries (often 1, 3 or 4 days).

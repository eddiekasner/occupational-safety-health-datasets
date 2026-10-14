# Data Dictionary: Eurostat ESAW

Built by `scripts/build_dataset.R` from Eurostat tables downloaded through the Eurostat
dissemination API. See the official [ESAW metadata](https://ec.europa.eu/eurostat/cache/metadata/en/hsw_acc_work_esms.htm)
for methodology.

## Shared columns

| Column | Meaning |
| --- | --- |
| `country_code` | Eurostat country code (mostly ISO 2-letter; note `EL` = Greece, `UK` = United Kingdom); `EU27_2020` = the 27 current EU member states |
| `country` | Country name (not in `esaw_causes`; join from `esaw_main` if needed) |
| `year` | Reference year |
| `severity` | `Fatal` (death within one year of the accident) or `Non-fatal (4+ days absence)` |
| `unit` | What `value` measures (see below) |
| `value` | The number |
| `flag` | Eurostat flag (see below); usually blank |

## `unit`

| Value | Meaning |
| --- | --- |
| `number` | Number of accidents |
| `incidence_rate` | Accidents per 100,000 persons employed (crude rate) |
| `standardised_incidence_rate` | Incidence rate adjusted to the EU's sector structure, so countries with more high-risk sectors are comparable (`esaw_main` only) |
| `percent` | Percentage distribution across the breakdown (`esaw_main` only) |

## `flag`

| Flag | Meaning |
| --- | --- |
| `b` | Break in time series |
| `e` | Estimated |
| `p` | Provisional |
| `u` | Low reliability |

## `esaw_main.csv` (table hsw_mi01)

Covers NACE Rev. 2 sections A and C to N (`nace_r2 = A_C-N`): agriculture, industry and
construction (except mining) and services of the business economy.

| Column | Values |
| --- | --- |
| `sex` | `T` total, `M` male, `F` female, `UNK` unknown |
| `age` | `TOTAL`, `Y_LT18`, `Y18-24`, `Y25-34`, `Y35-44`, `Y45-54`, `Y55-64`, `Y_GE65`, and groupings such as `Y_LT25`, `Y25-54`, `Y_GE55` |
| `nace_r2` | `A_C-N` |

## `esaw_sector.csv` (tables hsw_n2_01 and hsw_n2_02)

| Column | Meaning |
| --- | --- |
| `sector_code` | NACE Rev. 2 section (`A` to `U`), `A_C-N`, `TOTAL` (all activities) or `UNK` (unknown) |
| `sector` | Sector name |

Non-fatal values are for both sexes combined.

## `esaw_causes.csv.gz` (tables hsw_ph3_06 and hsw_ph3_08)

Both sexes and all ages combined; 2014 onward. Look up labels in `esaw_codes.csv`.

| Column | Meaning |
| --- | --- |
| `sector_code` | NACE Rev. 2 section, as above |
| `classification` | `deviation` or `contact` |
| `cause_code` | Code within the classification; each classification has its own `TOTAL` row |

**Deviation** (`DEV_1` to `DEV_9`): the last event that deviated from normal working conditions
and led to the accident, for example *loss of control of a machine or tool* or *slipping,
stumbling and falling*.

**Contact, mode of injury** (`CMI10` to `CMI90`): how the victim was hurt, for example *struck by
an object in motion* or *trapped, crushed*.

The listed codes do not always add up to `TOTAL`, because some accidents have no recorded cause
(and some countries do not record causes at all).

## `esaw_codes.csv`

| Column | Meaning |
| --- | --- |
| `classification` | `deviation`, `contact` or `sector` |
| `code` | The code used in the other tables |
| `label` | Eurostat's label |

## Definitions

- **Accident at work**: a discrete occurrence in the course of work which leads to physical or
  mental harm. Commuting accidents are excluded; road traffic accidents in the course of work are included.
- **Fatal accident**: an accident that leads to the death of the victim within one year.
- **Incidence rate**: number of accidents / number of persons employed in the reference
  population x 100,000.
- **Standardised incidence rate**: the incidence rate a country would have if its employment
  were distributed across sectors in the same way as in the EU as a whole.

# Data Dictionary: Safe Work Australia

Built by `scripts/build_dataset.R` from the three Excel files in `data/source/`. Each row is one
cell of a published table. Values Safe Work Australia did not publish are blank (`NA`) with
`flag` = `NP`.

## Shared columns

| Column | Meaning |
| --- | --- |
| `table` | Table number in the source workbook (for example `1.1`) |
| `breakdown` | What the table is broken down by (see below) |
| `period` | Calendar year (`2025`), financial year (`2024-25`, 1 July 2024 to 30 June 2025), or `5-year average to 2024-25` |
| `year` | The year the period ends, as a number (`2024-25` gives 2025) |
| `preliminary` | `TRUE` for the latest financial year of claims data, which will be revised (NDS and WCIFR only) |
| `code` | Classification code, where the category has one (for example ANZSIC `E` = Construction) |
| `group` | For two-way tables, the outer group (age group, or public road status); otherwise blank |
| `category` | The category name |
| `level` | Level in the hierarchy: `0` = Total, `1` = broadest group, then more detailed (see below) |
| `measure` | What `value` measures (see below) |
| `value` | The published number |
| `flag` | `NP` = not published |

**Avoid double counting:** each table contains the total and every level of its hierarchy.
Filter to one `breakdown`, one `measure` and one `level` before adding up. Categories at one
level do not always add up to the total, because some deaths or claims could not be coded.

## `tif_fatalities.csv`: Traumatic Injury Fatalities

Workers who died from a work-related traumatic injury. Most tables have a calendar-year version
(2016 to 2025) and a financial-year version (2015-16 to 2024-25); see `period_type`.

| Column | Meaning |
| --- | --- |
| `period_type` | `calendar` or `financial` |
| `measure` | `fatalities` (count) or `rate_per_100000_workers` |

Rates are deaths per 100,000 employed people (from the ABS Labour Force Survey), and are only
available for industry, occupation, age and sex, and state. A rate is `NP` whenever the count is 0.

| `breakdown` | Tables | Classification and `level` |
| --- | --- | --- |
| `industry` | 1.1 to 1.4 | ANZSIC 2006 industry of employer: 1 = division (letter), 2 = subdivision (2 digits) |
| `occupation` | 2.1 to 2.4 | ANZSCO: 1 = major group (1 digit), 2 = sub-major group (2 digits) |
| `mechanism` | 3.1, 3.2 | TOOCS mechanism of incident: 1 = major group, 2 = sub-major group (`8_` = not further defined) |
| `breakdown agency` | 4.1, 4.2 | TOOCS breakdown agency (what started the incident): 1 = major group, 2 = sub-major group |
| `agency` | 5.1, 5.2 | TOOCS agency (what directly caused the injury): 1 = major group, 2 = sub-major group |
| `age and sex` | 6.1 to 6.4 | `group` = age group; level 1 = `Persons`, level 2 = `Male` or `Female` |
| `state` | 7.1 to 7.4 | State or territory where the death occurred |
| `jurisdiction and road` | 8.1, 8.2 (5 years) | `group` = on or not on a public road; level 2 `category` = regulator with responsibility (a state or territory, `Commonwealth`, or `Aircraft incidents`) |
| `vehicle type` | 9.1, 9.2 | Deaths involving a vehicle, by the deceased's vehicle type (only deaths involving a vehicle; the total is not all deaths) |
| `vehicle activity` | 9.3, 9.4 | Deaths involving a vehicle, by what the deceased was doing |

## `nds_serious_claims.csv`: National Dataset for Compensation-based Statistics

Serious claims (accepted claims with one working week or more of time lost, excluding deaths and
commuting) by financial year of lodgement, 2015-16 to 2024-25.

| `measure` | Meaning |
| --- | --- |
| `claims` | Number of serious claims |
| `frequency_rate_per_million_hours` | Serious claims per million hours worked |
| `incidence_rate_per_1000_employees` | Serious claims per 1,000 employees |
| `median_compensation_aud` | Median total compensation paid per claim, in Australian dollars (not adjusted for inflation; not published for the preliminary year) |
| `median_time_lost_weeks` | Median working weeks lost per claim (not published for the preliminary year) |

Rates are available only for industry, occupation, age and sex, and jurisdiction.

| `breakdown` | Tables | Classification and `level` |
| --- | --- | --- |
| `industry` | 1.1 to 1.5 | ANZSIC: 1 = division, 2 = subdivision (`A0` etc. = division not further defined, `99` = inadequately described) |
| `occupation` | 2.1 to 2.5 | ANZSCO: 1 = major group, 2 = sub-major group |
| `nature` | 3.1 to 3.3 | TOOCS nature of injury or disease: 1 = `0` Injuries or `1` Diseases and conditions, 2 = group (letter), 3 = subgroup (letter and digit) |
| `mechanism` | 4.1 to 4.3 | TOOCS mechanism: 1 = major group (`8` = mental stress), 2 = sub-major group |
| `bodily location` | 5.1 to 5.3 | TOOCS bodily location: 1 = major group, 2 = sub-major group |
| `agency` | 6.1 to 6.3 | TOOCS agency: 1 = major group, 2 = sub-major group |
| `breakdown agency` | 7.1 to 7.3 | TOOCS breakdown agency: 1 = major group, 2 = sub-major group |
| `age and sex` | 8.1 to 8.5 | As in the TIF table |
| `jurisdiction` | 9.1 to 9.5 | Workers' compensation scheme: `NSW`, `VIC`, `QLD`, `SA`, `WA`, `TAS`, `NT`, `ACTPrivate` (ACT private sector), `ACTGov` (ACT public sector), `Comcare` (Commonwealth employees and some national employers), `Seacare` (maritime; no rates) |

## `wcifr.csv`: Workers' compensation injury frequency rates

`measure` = `lost_time_claims_per_million_hours`: accepted claims with time lost from work, per
million hours worked. Lost time claims include shorter absences than serious claims, so these
rates are higher than the NDS serious claim frequency rates.

| Tables | `breakdown` | `period` |
| --- | --- | --- |
| 1.1 | `industry`, ANZSIC levels 1 to 3 (3 = group, 3 digits) | `5-year average to 2024-25` (the headline benchmark) |
| 1.2 | `occupation`, ANZSCO levels 1 to 4 (4 = unit group, 4 digits) | `5-year average to 2024-25` |
| 2.1 | `industry`, levels 1 to 3 | Each financial year 2015-16 to 2024-25 |
| 2.2 | `occupation`, levels 1 to 4 | Each financial year 2015-16 to 2024-25 |

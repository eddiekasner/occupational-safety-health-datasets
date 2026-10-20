# Data Dictionary: France Occupational Risks (Assurance Maladie)

Built by `scripts/build_dataset.R` from Assurance Maladie's datasets on data.ameli.fr. Blank means
withheld for confidentiality ("NS"), not computed ("NC") or not applicable.

## Sector columns (most tables)

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `level` | `All sectors` (national total), `Section` (NAF section, 21 broad sectors plus `x`, sector not known) or `Subclass` (NAF subclass, about 730 detailed activities) |
| `naf1` | NAF section letter (`A` to `U`), `TOUS` for all sectors, `x` for sector not known |
| `naf5` | NAF subclass code (four digits and a letter, for example `4391A`; the first four characters are the NACE Rev. 2 class 43.91); blank for sections and the total |

Join `naf1` or `naf5` to `sectors.csv` for names.

## Sectors (`sectors.csv`)

`level`, `naf1`, `section_name` (English), `naf5`, `nace_class` (NACE Rev. 2 class, for example
`43.91`), `name_en` (English name; AI translation using official NACE titles where they apply),
`name_fr` (official French name).

## Claims by sector (`claims_by_sector.csv.gz`)

Sector columns plus:

| Column | Meaning |
| --- | --- |
| `risk` | `Work accidents`, `Commuting accidents`, `Occupational diseases`, `All risks` |
| `claims` | Recognised claims (accidents with at least one day off work; occupational diseases recognised in the year) |
| `employees` | Employees in the sector (average over the year) |
| `frequency_index` | Accidents per 1,000 employees (not computed for occupational diseases, all risks, or 2020) |
| `claims_note` | `Confidential` or `Not available` where `claims` is blank |
| `deaths` | Deaths (work and commuting accidents; 2015 onward) |
| `days_off_work` | Days of temporary incapacity compensated (2015 onward) |
| `permanent_incapacities` | New permanent incapacities (2015 onward) |

National totals (`level` `All sectors`) start in 2005; sector rows start in 2015.

## Accident causes (`accident_causes.csv.gz`)

Sector columns plus `risk` (`Work accidents` or `Commuting accidents`), `cause`, `vehicle` (for
commuting accidents caused by losing control of a vehicle: `Car`, `Motorised two-wheeler`,
`Bicycle or scooter`, `Other vehicles`, `All vehicles`) and `share_pct` (the percentage of the
sector's accidents with this cause; rounded). Work accident causes: `Manual handling`, `Falls on the
same level`, `Falls from height`, `Hand tools`, `Assault`, `Road traffic`, `Machinery`, `Mechanical
handling`, `Chemical hazards`, `Physical hazards`, `Other causes`, `All causes`.

## Occupational diseases (`occupational_diseases.csv.gz`)

Sector columns plus `disease_group` (`Musculoskeletal disorders`, `Asbestos-related diseases`,
`Cancers`, `COVID-19`, `Other scheduled occupational diseases`, `Unscheduled occupational diseases`
(recognised case by case, outside the tables), `All occupational diseases`), `icd10_chapter_code`
and `icd10_chapter` (for unscheduled diseases only) and `cases`.

## Musculoskeletal disorders (`msd.csv.gz`, `msd_body_parts.csv.gz`)

`msd.csv.gz`: sector columns plus `table_number` (the compensation table of the general scheme: 57
periarticular disorders, 69 vibration, 79 meniscus, 97 and 98 lumbar spine), `table_name`, `cases`
and `frequency_index` (cases per 1,000 employees; published for all tables combined only). `msd_body_parts.csv.gz`: sector
columns plus `sex`, `body_part` and `share_pct` (percentage of cases).

## Other tables

- `psychological_disorders.csv`: sector columns plus `cases` (psychological disorders recognised as
  occupational diseases).
- `companies_by_size.csv.gz`: sector columns plus `company_size` (`Under 10` to `500+`, `All
  sizes`), `companies` and `employees`.
- `regions.csv`: `year`, `region_code`, `region` (French administrative region, or `France`), `risk`,
  `claims`, `employees`, `frequency_index`.
- `costs.csv`: `year`, `risk`, `cost_item` (`Health care`, `Daily allowances (sick pay)`, `Lump
  sums, pensions and death benefits`, `All costs`) and `amount_eur`.

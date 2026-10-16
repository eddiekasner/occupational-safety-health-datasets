# Data Dictionary: INAIL Work Injuries and Occupational Diseases (Italy)

Built by `scripts/build_dataset.R` from INAIL's half-yearly open data files (data as of 30 April
2026). English labels translate INAIL's codes, using INAIL's own descriptions of the fields.

## Injury reports (`injuries_<year>.csv.gz`)

One row per injury report, by year of the accident.

| Column | Meaning |
| --- | --- |
| `case_id` | INAIL's case number |
| `accident_date`, `report_date`, `decision_date`, `death_date` | When the accident happened, was reported to INAIL, was decided (blank if not yet decided), and (if the worker died) when they died |
| `region` | Region where the accident happened |
| `province_code` | ISTAT code of the province where the accident happened (3 digits) |
| `sex` | `Male`, `Female` |
| `age` | Age in completed years on the day of the accident |
| `birthplace_code` | `ITAL` (born in Italy) or the code Italy uses for each foreign country (codice catastale, for example `Z129` Romania, `Z330` Morocco, `Z100` Albania) |
| `birth_area` | `Italy`, `Other EU country`, `Europe outside the EU`, `Africa`, `Asia`, `Americas`, `Oceania`, `Unknown` (EU as INAIL defines it in its tables) |
| `commuting` | `TRUE` if the accident happened on the way to or from work (in itinere); `FALSE` if in the course of work |
| `transport_involved` | `TRUE` if a means of transport was involved |
| `decision` | `Accepted` (recognised as a work injury), `Rejected`, `Short absence (statistical only)` (3 days off or less, which INAIL does not compensate, or reported only for statistics), `Under investigation` |
| `fatal` | `TRUE` if the report concerns a death |
| `fatal_decision` | For deaths: `Accepted`, `Rejected` or `Under investigation` (whether INAIL recognised the death as caused by work) |
| `fatal_rejection_reason` | For rejected deaths: `No causal link with the event`, `Insufficient documentation`, `Not in the course of work`, `Not in the course of commuting`, `Person not insured`, `Activity not insured`, `Other reasons` |
| `compensation` | `Temporary disability` (pay for days off), `Lump sum (permanent impairment)` (6% to 15%), `Annuity to the worker (permanent impairment)` (16% or more), `Annuity to survivors` (deaths), `None` |
| `impairment_pct` | Degree of permanent impairment, in percent (blank if none or not yet assessed) |
| `days_compensated` | Days of temporary total disability compensated |
| `ateco_division` | Employer's industry, as ATECO 2007 section letter and 2-digit division (for example `F 43`, specialised construction; `Q 86`, human health). ATECO is the Italian version of NACE Rev. 2 |
| `sector` | ATECO section in English (blank if not recorded) |
| `insurance_scheme` | `Industry and services`, `Agriculture`, `State (state employees and school pupils)` |
| `tariff_scheme` | For industry and services: `Industry`, `Crafts`, `Tertiary (services)`, `Other activities` |
| `tariff_group` | INAIL tariff group (`Construction and installation`, `Metals and machinery`, `Transport and warehousing`, `Various activities` and others) |
| `worker_id`, `employer_id` | INAIL's pseudonymous codes for the worker and the employer: the same code means the same person or employer, so you can count repeat injuries |

## Summary (`injuries_summary.csv.gz`)

Counts by `year`, `macro_area` (North-West, North-East, Centre, South, Islands), `region`, `sector`,
`insurance_scheme`, `sex`, `age_group` (5-year bands), `birth_group` (Italy, Other EU country,
Outside the EU) and `commuting`:

| Column | Meaning |
| --- | --- |
| `reports` | Injury reports |
| `accepted` | Of which accepted |
| `fatal_reports` | Reports of deaths |
| `fatal_accepted` | Deaths accepted as work injuries |
| `days_compensated` | Total days of temporary disability compensated |

## Occupational disease claims (`occupational_diseases.csv.gz`)

One row per claim reported in 2021 to 2025 (`year` is the year it was reported).

| Column | Meaning |
| --- | --- |
| `case_id`, `worker_id` | INAIL's codes for the claim and the worker (one worker can have several claims) |
| `report_date`, `decision_date`, `death_date` | Dates |
| `inail_office_province` | Province of the INAIL office handling the claim (ISTAT code) |
| `sex`, `birthplace_code`, `birth_area` | As above |
| `icd10_reported`, `icd10_confirmed` | ICD-10 diagnosis as reported and as confirmed by INAIL (for example `M75.1` rotator cuff syndrome, `G56.0` carpal tunnel syndrome, `M51` intervertebral disc disorders, `H83.3` noise-induced hearing loss, `C45` mesothelioma) |
| `icd10_chapter` | ICD-10 chapter in English |
| `causal_agent_code` | INAIL code for the causal agent (no published labels) |
| `scheduled_disease` | `TRUE` if the disease is on Italy's legal list of occupational diseases (malattia tabellata), for which the link to work is presumed |
| `asbestos_related` | `TRUE` if asbestos-related |
| `decision` | Decision on the claim (as for injuries, without "short absence") |
| `worker_decision`, `fatal_decision` | Decision for the worker overall, and on a death |
| `compensation`, `impairment_pct_worker`, `impairment_pct_case`, `days_compensated` | As for injuries |
| `insurance_scheme` | As above |
| `sector_group_code`, `sub_sector_code` | INAIL codes for the sector linked to the disease (no published labels) |

## Deaths from occupational disease (`disease_deaths.csv.gz`)

`case_id`, `death_date`, `year`, `age_at_death`, `sex`, `birth_area`, `silicosis_or_asbestosis`,
`insurance_scheme`, `worker_id`: workers with a recognised occupational disease who died in 2021
to 2025.

## Adding columns left out of the yearly files

```r
injuries |>
  mutate(year = as.integer(format(accident_date, "%Y")),
         age_group = cut(age, c(-Inf, 14, seq(19, 69, 5), Inf)),
         birth_group = case_when(birth_area == "Italy" ~ "Italy",
                                 birth_area == "Other EU country" ~ "Other EU country",
                                 TRUE ~ "Outside the EU"))
```

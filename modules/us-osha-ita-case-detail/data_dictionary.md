# Data Dictionary: ITA Case Detail

Adapted from OSHA's official
[ITA Case Detail Data Dictionary, May 2026 (PDF)](https://www.osha.gov/sites/default/files/case_detail_data_dictionary_2026.pdf).
Check the official version for any updates.

One row = one recordable work-related injury or illness.

**Column names:** OSHA's files mix upper and lower case (for example `establishment_ID`,
`SOC_code`, `New_nar_what_happened`). The notebook and the sample convert all names to
lower case, and rename the 2023 column `year_filing_for` to `year_of_filing`.

## Establishment fields (from Form 300A)

These repeat on every case from the same establishment.

| Field | Definition | Notes |
| --- | --- | --- |
| `id` | Unique number for each record | ITA assigned |
| `establishment_id` | Unique number for each establishment | Links case detail to 300A summary data |
| `establishment_name` | Name of the establishment | |
| `ein` | Employer Identification Number (federal tax ID) | Often blank |
| `company_name` | Company that owns the establishment | |
| `street_address`, `city`, `state`, `zip_code` | Establishment location | `state` is the two-letter state or territory code |
| `naics_code` | North American Industry Classification System code | 2012, 2017 or 2022 NAICS. First 2 digits = sector |
| `naics_year` | NAICS version used | |
| `industry_description` | Industry description | |
| `establishment_type` | 1 = private industry, 2 = state government, 3 = local government | |
| `size` | Maximum employees at any point in the year: 1 = under 20, 21 = 20 to 99, 22 = 100 to 249, 3 = 250+ (older code 2 = 20 to 249 may still appear) | |
| `annual_average_employees` | Annual average number of employees | **Do not sum across cases** |
| `total_hours_worked` | Total hours worked by all employees | **Do not sum across cases.** Use one row per establishment and year |
| `year_of_filing` | Calendar year the injuries and illnesses occurred | Called `year_filing_for` in the 2023 file |

## Case fields (from Forms 300 and 301)

| Field | Definition | Notes |
| --- | --- | --- |
| `case_number` | Employer-assigned case number | |
| `date_of_incident` | Date the incident occurred | |
| `incident_outcome` | Most serious outcome (see code table) | |
| `dafw_num_away` | Days away from work | Employers may stop counting at 180, but larger values appear |
| `djtr_num_tr` | Days on job transfer or restriction | |
| `type_of_incident` | Injury or type of illness (see code table) | |
| `time_started_work` | Time the employee started work, HH:MM | |
| `time_of_incident` | Time of the incident, HH:MM | |
| `time_unknown` | Was the time unknown? 0 = no, 1 = yes | |
| `date_of_death` | Date of death, if applicable | |
| `created_timestamp` / `date_submitted` | When the record was submitted to ITA | Name differs by year |
| `job_description` | The employee's job title | As written by the employer |

### `incident_outcome`

| Code | Meaning |
| --- | --- |
| 1 | Death |
| 2 | Days away from work (DAFW) |
| 3 | Job transfer or restriction (DJTR) |
| 4 | Other recordable case |

### `type_of_incident`

| Code | Meaning |
| --- | --- |
| 1 | Injury |
| 2 | Skin disorder |
| 3 | Respiratory condition |
| 4 | Poisoning |
| 5 | Hearing loss |
| 6 | All other illnesses |

## Narrative fields (redacted)

OSHA used AI plus some manual review to remove information that could identify individuals
or reveal sensitive medical details. The prefix `new_` marks a redacted field. Usually only
part of the text is removed; occasionally the whole field is blank.

| Field | Form question |
| --- | --- |
| `new_incident_location` | Where the event occurred (Form 300) |
| `new_incident_description` | Description of injury or illness, parts of body affected, and object or substance that directly injured or made the person ill (Form 300) |
| `new_nar_before_incident` | What was the employee doing just before the incident occurred? (Form 301) |
| `new_nar_what_happened` | What happened? Tell us how the injury occurred. (Form 301) |
| `new_nar_injury_illness` | What was the injury or illness? (Form 301) |
| `new_nar_object_substance` | What object or substance directly harmed the employee? (Form 301) |

## Occupation fields (machine-assigned)

OSHA assigned 2018 SOC codes from `job_description` and `naics_code` using NIOSH's
NIOCCS autocoder (machine learning). **OSHA does not validate these codes.**

| Field | Definition |
| --- | --- |
| `soc_code` | 2018 Standard Occupational Classification code. `00-9999` = could not be coded |
| `soc_description` | Text description of the SOC code. Includes "Uncoded" and "Insufficient Information - NIOSH" |
| `soc_probability` | NIOCCS confidence score, 0 to 1 (higher = more likely correct) |
| `soc_reviewed` | Review flag (2023 and 2024 files) |
| `unexpected_naics_soc_combo` | Y/N: industry and occupation pairing that BLS data suggest is unlikely (2025 file) |

## Injury classification fields (OIICS, machine-assigned)

BLS used its SOII autocoder to assign **Occupational Injury and Illness Classification
System (OIICS) version 2.01** codes from the narratives. Only **2-digit** codes were
assigned, and only "non-terminal" ones (codes that have more detailed child codes), so
some cases are blank. OSHA adds these after a year is complete, so **the 2025 file does
not have them yet** (expected by January 2027).

| Field | Definition |
| --- | --- |
| `nature_code_pred`, `nature_title_pred` | Nature of injury or illness (e.g. sprains, burns) |
| `part_code_pred`, `part_title_pred` | Part of body affected |
| `event_code_pred`, `event_title_pred` | Event or exposure: how the injury happened (e.g. falls, overexertion) |
| `source_code_pred`, `source_title_pred` | Object, substance or factor that harmed the worker |
| `sec_source_code_pred`, `sec_source_title_pred` | Secondary source, if any |

**Caution:** the title wording differs between the 2023 and 2024 files (for example,
"Falls on same level" in 2023 and "Slip, trip, stumble or fall on same level" in 2024).
Compare codes, not titles, and check the code lists before comparing years.

## Files in this module (as downloaded October 2026)

| Year | OSHA file | Cases | Establishments | Notes |
| --- | --- | --- | --- | --- |
| 2023 | `ITA_Case_Detail_Data_2023_through_12-31-2023OIICS.zip` | 890,934 | 91,334 | Includes OIICS codes |
| 2024 | `ITA_Case_Detail_Data_2024_through_12-31-2025.zip` | 688,649 | 64,674 | Includes OIICS codes |
| 2025 | `ITA_Case_Detail_Data_2025_through_08-31-2026.csv` | 784,227 | 68,832 | Submissions through Aug 31, 2026; no OIICS codes yet |

## Useful definitions

- **Recordable case**: a work-related injury or illness that results in death, days away,
  restricted work or transfer, medical treatment beyond first aid, loss of consciousness,
  or a significant diagnosed injury or illness (29 CFR 1904.7).
- **DART cases**: cases with **D**ays **A**way, **R**estricted, or **T**ransferred
  (outcome codes 2 and 3).
- **Incidence rate**: cases x 200,000 / total hours worked. 200,000 hours is 100
  full-time workers for one year.

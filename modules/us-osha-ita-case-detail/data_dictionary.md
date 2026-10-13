# Data Dictionary: ITA Case Detail

> **Status: draft.** The fields below were confirmed from OSHA documentation. The full
> field list will be completed against the official
> [Case Detail Data Dictionary (PDF)](https://www.osha.gov/sites/default/files/case_detail_data_dictionary.pdf)
> once the 2023 to 2025 files are loaded. OSHA revised the dictionary in May 2026
> ([newer version](https://www.osha.gov/sites/default/files/case_detail_data_dictionary_2026.pdf)),
> so column names may differ slightly between years. The starter notebook prints the
> actual columns in each file.

One row = one recordable work-related injury or illness.

## Key fields

| Field | Meaning | Notes |
| --- | --- | --- |
| `establishment_id` | Unique ID for the establishment | Links to the 300A summary data (one establishment, many cases) |
| `naics_code` | North American Industry Classification System code | First 2 digits = sector, e.g. 31-33 manufacturing, 48-49 transportation and warehousing |
| `incident_outcome` | Most serious outcome of the case | See code table below |
| `dafw_num_away` | Number of days away from work | Filled when `incident_outcome` = 2 |
| `type_of_incident` | Injury or type of illness | See code table below |
| `soc_code` | Standard Occupational Classification code | Assigned by OSHA from the job title using NIOSH's NIOCCS autocoder, not reported by the employer |
| OIICS fields | Occupational Injury and Illness Classification System codes (nature, body part, event, source) | OSHA updated the CY2023 and CY2024 files to add OIICS-coded data; *field names to be filled in* |

## Code tables

### `incident_outcome`

| Code | Meaning | Form 300 column |
| --- | --- | --- |
| 1 | Death | G |
| 2 | Days away from work | H |
| 3 | Job transfer or restriction | I |
| 4 | Other recordable case | J |

### `type_of_incident`

| Code | Meaning | Form 300 column |
| --- | --- | --- |
| 1 | Injury | M(1) |
| 2 | Skin disorder | M(2) |
| 3 | Respiratory condition | M(3) |
| 4 | Poisoning | M(4) |
| 5 | Hearing loss | M(5) |
| 6 | All other illnesses | M(6) |

*Codes 1 to 4 are confirmed in OSHA's dictionary; codes 5 and 6 follow the Form 300
columns and should be confirmed against the files.*

## Narrative fields

The case detail file includes free-text fields from Form 301 (for example, what the
employee was doing just before the incident, what happened, the injury or illness, and
the object or substance that directly harmed the employee). OSHA removes personal
identifiers before release. *Exact field names to be filled in from the official dictionary.*

## Useful definitions

- **Recordable case**: a work-related injury or illness that results in death, days away,
  restricted work or transfer, medical treatment beyond first aid, loss of consciousness,
  or a significant diagnosed injury or illness (29 CFR 1904.7).
- **DART cases**: cases with **D**ays **A**way, **R**estricted, or **T**ransferred
  (outcome codes 2 and 3).
- **Incidence rate**: cases x 200,000 / total hours worked. 200,000 hours is 100
  full-time workers for one year. Hours worked come from the 300A summary data.

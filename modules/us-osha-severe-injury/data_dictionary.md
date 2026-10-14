# Data Dictionary: OSHA Severe Injury Reports

Columns of `data/tidy/severe_injury_reports.csv.gz`, built by `scripts/build_dataset.R` from
OSHA's download. The original OSHA column name is given where it differs.

## Report and establishment

| Column | OSHA column | Meaning |
| --- | --- | --- |
| `upa` | UPA | Unique identifier of the report (use this as the key) |
| `id` | ID | OSHA report ID; a few values are duplicated |
| `event_date` | EventDate | Date of the incident |
| `year`, `month` | | Added from `event_date` |
| `employer` | Employer | Employer name as reported (not standardized) |
| `address` | Address1 | Street address |
| `city`, `state`, `zip` | City, State, Zip | Location of the incident (`state` is the full state name) |
| `latitude`, `longitude` | Latitude, Longitude | Geocoded location, two decimal places; obtained by OSHA from third-party services, accuracy not guaranteed |
| `naics` | Primary NAICS | Six-digit NAICS industry code of the establishment |
| `naics_2` | | Two-digit NAICS sector, added |
| `federal_state` | FederalState | `1` = state under federal OSHA jurisdiction; `0` = report from a State Plan state |
| `inspection` | Inspection | OSHA inspection number if the report led to an inspection; blank otherwise |

## Outcomes

| Column | OSHA column | Meaning |
| --- | --- | --- |
| `hospitalized` | Hospitalized | Number of workers admitted to a hospital as in-patients |
| `amputation` | Amputation | Number of workers with an amputation |
| `loss_of_eye` | Loss of Eye | Number of workers who lost an eye |
| `narrative` | Final Narrative | Short description of what happened |

## OIICS codes

Each injury is coded with the Occupational Injury and Illness Classification System (OIICS),
version 2.01. Codes are hierarchical: the first digit is the **division**, and each extra digit
adds detail. Codes are kept as text. Titles have had stray spaces removed.

| Code column | Title column | Division column (added) | What it describes |
| --- | --- | --- | --- |
| `event_code` | `event` | `event_division` | How the injury happened |
| `nature_code` | `nature` | `nature_division` | The physical characteristics of the injury |
| `body_part_code` | `body_part` | `body_part_division` | The part of the body affected |
| `source_code` | `source` | | The object, substance, or exposure that directly caused the injury |
| `secondary_source_code` | `secondary_source` | | Another object or substance that contributed, if any |

### Event divisions

| Code | Division |
| --- | --- |
| 1 | Violence and other injuries by persons or animals |
| 2 | Transportation incidents |
| 3 | Fires and explosions |
| 4 | Falls, slips, trips |
| 5 | Exposure to harmful substances or environments |
| 6 | Contact with objects and equipment |
| 7 | Overexertion and bodily reaction |
| 9 | Nonclassifiable |

### Body part divisions

| Code | Division |
| --- | --- |
| 1 | Head |
| 2 | Neck, including throat |
| 3 | Trunk |
| 4 | Upper extremities |
| 5 | Lower extremities |
| 6 | Body systems |
| 8 | Multiple body parts |
| 9 | Other body parts or nonclassifiable |

### Nature divisions

| Code | Division |
| --- | --- |
| 1 | Traumatic injuries and disorders |
| 2 | Systemic diseases and disorders |
| 3 | Infectious and parasitic diseases |
| 4 | Neoplasms, tumors, and cancer |
| 5 | Symptoms, signs, and ill-defined conditions |
| 6 | Other diseases, conditions, and disorders |
| 7 | Exposures to disease, no illness incurred |
| 8 | Multiple diseases, conditions, and disorders |
| 9 | Nonclassifiable |

Full code lists are in the [BLS OIICS manual](https://www.bls.gov/iif/definitions/occupational-injuries-and-illnesses-classification-manual.htm).

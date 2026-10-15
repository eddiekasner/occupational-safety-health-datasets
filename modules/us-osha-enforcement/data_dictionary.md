# Data Dictionary: OSHA Enforcement

Built by `scripts/build_dataset.R` from the DOL API tables `inspection`, `violation`, `accident`,
`accident_abstract`, `accident_injury` and `accident_lookup2`. Codes are translated to labels.

## Shared columns

| Column | Meaning |
| --- | --- |
| `activity_nr` | Inspection number: links inspections, violations and accident investigations |
| `fiscal_year` | Federal fiscal year (October to September; fiscal year 2025 began 1 October 2024). For inspections, of the opening date; for accidents, of the event date |
| `jurisdiction` | `Federal` (federal OSHA) or `State plan` (a state-run OSHA program), from the reporting office (the third digit of the reporting ID is 5 for state-plan offices) |
| `site_state` | State of the inspected site |
| `naics_sector` | Industry sector from the 2-digit NAICS code of the inspected establishment |

## Inspections (`inspection_summary.csv.gz`, `inspections_sample.csv.gz`)

| Column | Meaning |
| --- | --- |
| `insp_type` | Why OSHA inspected: `Planned` (programmed, chosen in advance), `Complaint`, `Referral` (from another agency, the media, or an employer's severe injury report), `Fatality/catastrophe` (a death or 3 or more hospitalized), `Follow-up` (to check abatement), `Monitoring`, `Programmed related` / `Unprogrammed related` (another employer at a site already being inspected), `Accident` (used by some state plans), and others |
| `insp_scope` | `Complete`, `Partial`, `Records` (records only) or `No inspection` (case opened but no inspection took place). OSHA's published inspection counts exclude `No inspection` |
| `safety_health` | `Safety` or `Health` inspection |
| `owner_type` | `Private`, `Local government`, `State government`, `Federal` |
| `inspections` | Number of inspection records (summary only) |
| `with_violations` | Number of those inspections with at least one violation cited (summary only) |
| `violations`, `serious`, `willful`, `repeat` | Number of violation items cited (all types, and by type) |
| `initial_penalty` | Total penalty first proposed, US dollars |
| `current_penalty` | Total penalty after settlement, contest and final orders, as of the download |

Sample only:

| Column | Meaning |
| --- | --- |
| `reporting_id` | OSHA office |
| `open_date`, `close_case_date` | When the inspection opened and the case closed |
| `estab_name`, `site_city`, `site_zip` | The inspected establishment |
| `union` | Union representation during the inspection |
| `adv_notice` | Advance notice given |
| `employees` | Number of employees at the establishment (as recorded; some values are implausible) |
| `naics_code`, `sic_code` | Detailed industry codes |

## Violations (`violation_standards.csv.gz`, `violations_sample.csv.gz`)

| Column | Meaning |
| --- | --- |
| `section` | The standard cited, as a section of Title 29 of the Code of Federal Regulations (for example `1926.501`, fall protection in construction; `1910.1200`, hazard communication), or `General Duty Clause` (section 5(a)(1) of the OSH Act). State-plan standards are kept as recorded |
| `viol_type` | `Serious` (substantial probability of death or serious harm), `Willful` (intentional or plain indifference), `Repeat` (same or similar violation cited before), `Other-than-serious`, `Unclassified` (used in settlements) |
| `violations`, `inspections` | Number of violation items, and of inspections with at least one (standards table) |
| `initial_penalty`, `current_penalty` | As above, US dollars |

Sample only: `citation_id` (citation, item and group number), `standard` (as recorded, including
the paragraph), `issuance_date`, `gravity` (1 to 10, for serious violations), `nr_exposed`
(employees exposed), `nr_instances`, `hazard_category`, `contested`, `final_order_date`.

Deleted violations are excluded.

## Violations by industry (`standards_by_industry.csv.gz`)

One row per fiscal year, `jurisdiction`, 6-digit `naics_code` of the inspected establishment, and
`section`. To get the list for a broader industry, filter on the start of the code (for example
`str_starts(naics_code, "23")` for construction) and add up.

| Column | Meaning |
| --- | --- |
| `violations` | Number of violation items |
| `inspections` | Number of inspections with at least one violation of the standard |
| `serious` | Of the violations, how many were serious |
| `willful_repeat` | Of the violations, how many were willful or repeat |
| `initial_penalty`, `current_penalty` | As above, US dollars |

## Standard titles (`standard_titles.csv`)

From the eCFR outline of Title 29 of the Code of Federal Regulations (current version), for the
OSHA parts 1903 (inspections and citations), 1904 (recordkeeping), 1910 (general industry), 1915
(shipyards), 1917 (marine terminals), 1918 (longshoring), 1926 (construction), 1928 (agriculture)
and 1960 (federal agencies), plus the General Duty Clause. Join to the violation tables by
`section`. Almost all federal violations match; state-plan standards cited under state codes do
not. Sections removed before the current version (for example some temporary standards) are
missing.

| Column | Meaning |
| --- | --- |
| `section` | Section number, for example `1926.501` |
| `title` | Section title, for example `Duty to have fall protection` |
| `full_title` | Subpart and title, for example `Fall Protection: Duty to have fall protection` |
| `part`, `part_title` | Part of 29 CFR, for example `1926`, `Safety and Health Regulations for Construction` |
| `subpart` | Subpart and its title (blank where the eCFR does not place the section in a subpart) |

## Accident investigations (`accidents.csv.gz`)

| Column | Meaning |
| --- | --- |
| `summary_nr` | Investigation summary number; links to `accident_injuries` |
| `event_date` | Date of the event |
| `fatality` | `TRUE` if a worker died |
| `estab_name` | Employer (from the linked inspection) |
| `event_desc` | Short description |
| `event_keyword` | Keywords assigned by OSHA's reviewers |
| `narrative` | The investigation summary (abstract) text |

## Injured or killed workers (`accident_injuries.csv.gz`)

| Column | Meaning |
| --- | --- |
| `summary_nr`, `activity_nr` | Investigation and inspection numbers |
| `age`, `sex` | Of the worker (age missing if not recorded) |
| `degree` | `Fatality`, `Hospitalized injuries`, `No Hospitalized injuries` |
| `nature`, `part_of_body`, `source`, `event_type` | Injury details, coded by OSHA (not OIICS) |
| `environmental_factor`, `human_factor` | Contributing factors |
| `occupation` | OSHA occupation code label (not standard SOC titles) |
| `construction_operation`, `fatal_cause` | For construction events |

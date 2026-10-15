# Data Dictionary: MSHA Mine Safety

Built by `scripts/build_dataset.R` from the MSHA open data files `Accidents`, `Mines`,
`MinesProdQuarterly`, `ContractorProdQuarterly` and `Violations`. MSHA's definition file for each
is in `data/raw/` after running `fetch_data.R`. Years are calendar years.

## Shared columns

| Column | Meaning |
| --- | --- |
| `mine_id` | MSHA mine ID (7 digits, kept as text because of leading zeros): links all tables |
| `year` | Calendar year (of the accident, of the hours worked, or of the violation) |
| `coal_metal` | `Coal` or `Metal/nonmetal` (all other mines: metal ores, stone, sand and gravel, and other minerals) |
| `worker_type` | `Operator` (employees of the mine operator) or `Contractor` (employees of an independent contractor working at the mine) |
| `state` | State of the mine (two-letter code), from MSHA's current record for the mine |
| `commodity` | Main commodity of the mine, from its current record: `Coal`, `Metal`, `Nonmetal`, `Stone`, `Sand and gravel` |
| `mine_type` | `Underground`, `Surface` or `Facility` (a mill or plant), from the mine's current record |
| `subunit` | Part of the mine: `Underground`; `Surface at underground mine`; `Strip, quarry, open pit`; `Auger` (coal); `Culm bank or refuse pile` (coal); `Dredge`; `Other surface`; `Independent shop or yard`; `Mill or preparation plant`; `Office workers at mine site` |

## Injury summary (`injury_summary.csv.gz`)

One row per year, worker type, coal or metal/nonmetal, subunit, state and commodity (state and
commodity are blank for contractors, who report hours nationally).

| Column | Meaning |
| --- | --- |
| `reporting_units` | Number of mines reporting hours (operators only) |
| `employees` | Average number of employees: the four quarterly averages summed and divided by 4 |
| `hours` | Hours worked |
| `coal_tons` | Coal produced, short tons (coal only) |
| `fatalities` | Deaths (degree of injury 01) |
| `nfdl_injuries` | Non-fatal injuries with days lost: days away from work and/or restricted activity, or permanent disability (degrees 02 to 05) |
| `ndl_injuries` | Injuries with no days lost (degree 06) |
| `illnesses` | Occupational illnesses (degree 07) |
| `days_lost`, `days_restricted` | Days away from work and days of restricted activity for those injuries and illnesses |

**Computing rates.** MSHA's injury rates are per 200,000 hours worked (100 full-time workers for a
year): `nfdl_injuries / hours * 200000`. A fatality rate per 100,000 full-time workers is
`fatalities / hours * 2000 * 100000`. MSHA leaves out office workers. Accidents with no hours
reported in the same group (for example at a mine that reported no hours) still appear, with
`hours` of 0.

## Accident, injury and illness reports (`fatalities.csv.gz`, `accidents.csv.gz`)

`fatalities` has every report with degree 01 from 2000 to 2025; `accidents` has every report from
2015 to 2025. One row per person (or per accident without injury).

| Column | Meaning |
| --- | --- |
| `document_no` | Report number |
| `contractor_id` | Contractor ID, for contractor employees |
| `operator_name` | Mine operator at the time |
| `accident_date`, `accident_time`, `shift_begin_time` | When it happened (times as HHMM) |
| `degree_code`, `degree` | Degree of injury: `00` accident only (no injury, for example an unplanned roof fall or fire that must be reported); `01` fatality; `02` permanent total or partial disability; `03` days away from work only; `04` days away and restricted activity; `05` restricted activity only; `06` no days away, no restriction; `07` occupational illness; `08` natural causes; `09` non-employee; `10` other, including first aid |
| `classification` | Circumstances that most directly led to the accident (for example `Powered haulage`, `Machinery`, `Fall of roof or back`, `Ignition or explosion of gas or dust`) |
| `accident_type` | How the injury happened (for example `Caught in, under or between...`, `Struck by falling object`, `Over-exertion in lifting objects`) |
| `no_injuries` | Number of people injured in the accident |
| `total_experience`, `mine_experience`, `job_experience` | The miner's years of experience in mining, at this mine, and in this job |
| `occupation`, `activity` | The miner's job and what they were doing |
| `injury_source` | Object or substance that directly caused the injury |
| `nature_injury`, `body_part` | Type of injury and part of body (MSHA's own codes; not OIICS) |
| `ug_location`, `ug_mining_method` | Location and mining method, for underground accidents |
| `mining_equipment`, `equipment_manufacturer` | Equipment involved |
| `days_lost`, `days_restricted` | Days away from work and days of restricted activity |
| `schedule_charge` | Days charged for a death or permanent disability (6,000 for a death) |
| `narrative` | Short description written by the person reporting |

## Mines (`mines.csv.gz`)

| Column | Meaning |
| --- | --- |
| `mine_name`, `operator_name`, `controller_name` | Current names (the controller is the company that ultimately controls the operator) |
| `mine_status`, `status_date` | Current status (for example `Active`, `Intermittent`, `Abandoned`, `NonProducing`) and since when |
| `county` | County |
| `primary_sic` | Main product, as a Standard Industrial Classification description |
| `employees` | Number of employees, from the mine's record (may be out of date) |
| `latitude`, `longitude` | Location (blank where missing or clearly wrong: about half of all mines, mostly old ones) |

## Mine-year table (`mine_year.csv.gz`)

One row per mine and year with any hours, injuries or violations, for the mine operator's own
employees only (contractor injuries and violations cited to contractors are left out).

| Column | Meaning |
| --- | --- |
| `employees`, `hours`, `coal_tons` | As in `injury_summary` |
| `fatalities`, `nfdl_injuries`, `ndl_injuries`, `illnesses`, `days_lost` | As in `injury_summary` |
| `violations` | Violations cited to the operator |
| `ss_violations` | Of these, significant and substantial |
| `orders` | Of these, orders (see `action` below) |
| `proposed_penalty` | Total proposed penalty, US dollars |

## Violations (`violation_summary.csv.gz`, `violation_standards.csv.gz`)

Violations are counted by the year they were issued.

| Column | Meaning |
| --- | --- |
| `violator_type` | `Operator` or `Contractor` |
| `action` | `Citation` (a violation, with time to fix it), `Order` (miners must be withdrawn from the affected area, for example for imminent danger, failure to fix a cited violation, or unwarrantable failure), `Safeguard` (a coal-mine notice that sets a site-specific requirement for haulage), `Other` |
| `act_section` | Section of the Mine Act under which it was issued, for example `104(a)` (citation), `104(b)` (failure to abate), `104(d)(1)` and `104(d)(2)` (unwarrantable failure), `104(g)(1)` (untrained miner), `107(a)` (imminent danger), `103(k)` (control order after an accident), `314(b)` (safeguard) |
| `significant_substantial` | `Yes` if the inspector found the violation significant and substantial (S&S): reasonably likely to result in a reasonably serious injury or illness |
| `likelihood` | Inspector's rating of how likely an injury is: `No likelihood`, `Unlikely`, `Reasonably likely`, `Highly likely`, `Occurred` |
| `injury_severity` | Expected severity of the injury: `No lost workdays`, `Lost workdays or restricted duty`, `Permanently disabling`, `Fatal` |
| `negligence` | Operator's negligence: `None`, `Low`, `Moderate`, `High`, `Reckless disregard` |
| `violations` | Number of violations |
| `special_assessments` | Number whose penalty was specially assessed (set individually, usually higher, rather than by formula) |
| `contested` | Number contested before the Federal Mine Safety and Health Review Commission |
| `proposed_penalty` | Total penalty proposed, US dollars |
| `amount_paid` | Total paid, as of the download |
| `standard` | Standard cited: a section of Title 30 of the Code of Federal Regulations without its paragraph (for example `75.400`, accumulation of combustible materials in underground coal mines; `56.14107`, moving machine parts guarding), or `Mine Act` and a section where no regulation is cited. Blank if not recorded |
| `cfr_part`, `cfr_part_title` | Part of 30 CFR (the number before the dot) and its title |
| `mines` | Number of mines with at least one violation of the standard (standards table) |

### Parts of 30 CFR most often cited

| Part | Covers |
| --- | --- |
| 46 | Training for miners at sand, gravel, surface stone and similar mines |
| 47 | Hazard communication |
| 48 | Training and retraining of miners (other mines) |
| 50 | Reporting of accidents, injuries, illnesses, employment and production |
| 56 | Safety and health standards: surface metal and nonmetal mines |
| 57 | Safety and health standards: underground metal and nonmetal mines |
| 62 | Occupational noise exposure |
| 70, 71, 72 | Health standards (respirable dust and others) for coal mines |
| 75 | Safety standards: underground coal mines |
| 77 | Safety standards: surface coal mines and surface areas of underground coal mines |

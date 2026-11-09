# Data Dictionary: India Injuries in Factories and Dock Works (DGFASLI)

Built by `scripts/extract_tables.py` from DGFASLI's Standard Reference Notes (2006 to 2024
editions). All tables are long: one value per row, with columns that say what the value is.

## Common columns

| Column | Meaning |
| --- | --- |
| `year` | Year the figure refers to |
| `measure` | What the value is (see each table) |
| `value` | The number or rate |
| `source_edition` | Standard Reference Note the figure was taken from. Each table and year is taken whole from the latest note that has it |

Values that the notes give as not available (`NA`, `..`, "Data not provided", or a row of `#` for a
state that sent no data) are left out; nil (`-`, `NIL`, a single `#`) is 0.

`state` is one of India's states and union territories, with current names (`Odisha` for Orissa,
`Uttarakhand` for Uttaranchal, `Puducherry` for Pondicherry), or `Total`.
`Dadra and Nagar Haveli and Daman and Diu` is the union territory formed in 2020; some notes report
the two territories together before that, others separately (`Dadra and Nagar Haveli`, `Daman and
Diu`).

## Labour Bureau statistics (from factories' annual returns)

Injuries are those that keep a worker off work for 48 hours or more. The rates cover the factories
that sent returns.

### `labour_bureau_national.csv` (1999 to 2022)

| Measure | Meaning |
| --- | --- |
| `Working factories submitting returns` | Factories whose returns the figures are based on |
| `Average daily employment (thousands)` | Estimated average daily employment in those factories, in thousands |
| `Total injuries`, `Fatal injuries` | Injuries (all, and fatal) |
| `Frequency rate (total)`, `Frequency rate (fatal)` | Injuries per 100,000 man-days worked |
| `Incidence rate (total)`, `Incidence rate (fatal)` | Injuries per 1,000 workers employed |

### `labour_bureau_by_state.csv` (1999 to 2022)

`year`, `state`, and the same six injury measures (counts, frequency and incidence rates).

### `labour_bureau_by_industry.csv` (2004 to 2022)

| Column | Meaning |
| --- | --- |
| `industry` | `Textiles`, `Paper and printing`, `Chemicals`, `Non-metallic mineral products`, `Basic metals`, `Metal products`, `Machinery (except electrical)`, `Transport equipment`, `Electricity, gas and steam`, `Total of the 9 industries`, or `All industries` |
| `measure` | `Total injuries`, `Fatal injuries`, `Incidence rate (total)`, `Incidence rate (fatal)`, `Frequency rate (total)` |

### `labour_bureau_by_cause.csv` (2006 to 2022)

| Column | Meaning |
| --- | --- |
| `cause` | Causation as in the Factories Act returns: `Prime movers`, `Machinery moved by mechanical power`, `Machinery not moved by mechanical power`, `Transport`, `Electricity`, `Explosions`, `Fires`, `Gassing`, `Molten metals and other hot or corrosive substances`, `Hand tools`, `Falling bodies`, `Persons falling`, `Stepping on or striking against objects`, `Handling goods or articles`, `Others`, `Total` |
| `measure` | `Total injuries` or `Fatal injuries` |

The total by cause can differ from the other Labour Bureau tables, because some returns do not give
causes.

## State inspectorate data (from each state's Chief Inspector of Factories)

### `inspectorate_national.csv` (2009 to 2023)

| Measure | Meaning |
| --- | --- |
| `Registered factories`, `Employment` | Factories registered under the Factories Act, and their workers |
| `Dangerous occurrences` | Dangerous occurrences notified (incidents such as explosions or collapses, with or without injury) |
| `Fatal injuries`, `Non-fatal injuries`, `Total injuries` | Notified injuries |
| `Fatal injuries per 100,000 workers` (and `Non-fatal`, `Total`) | Injuries per 100,000 workers employed |
| `Fatal injuries per 1,000 registered factories` (and `Non-fatal`, `Total`) | Injuries per 1,000 registered factories |

The notes list the states missing from each year's total (for example West Bengal in 2019 to 2023).

### `inspectorate_by_state.csv` (2004 to 2023)

| Measure | Meaning |
| --- | --- |
| `Fatal injuries`, `Non-fatal injuries` | Notified injuries (2004 to 2023) |
| `Dangerous occurrences` | (2016 to 2023) |
| `Registered factories`, `Working factories` | Factories registered, and those working (2005 to 2023) |
| `Employment`, `Women employed`, `Men employed` | Workers in registered factories (men only to 2008) |
| `Hazardous factories`, `Workers in hazardous factories` | Factories carrying on a hazardous process under section 2(cb), and their workers |
| `Factories inspected`, `Hazardous factories inspected` | Inspections in the year (2008 to 2023) |

### `enforcement_by_state.csv` (2005 to 2023; no 2009)

| Column | Meaning |
| --- | --- |
| `topic` | `Inspectors of factories`, `Certifying surgeons`, `Prosecutions`, `Safety officers`, `Safety policy`, `Safety committees`, `On-site emergency plans (major accident hazard units)`, `Medical facilities`, `Canteens, shelters and creches`, `Welfare officers` |
| `measure` | The item, for example `Inspectors, sanctioned` and `Inspectors, in position` (posts sanctioned and filled; also for medical, chemical, hygiene, other and, in older notes, specialist inspectors), `Employed certifying surgeons, in position`, `Prosecutions launched`, `Convictions`, `Fines imposed (rupees)`, `Factories requiring safety officers`, `Factories with safety officers`, `Factories requiring a safety committee`, `Factories with a safety committee`, `Full-time medical officers required`, `Factories with ambulance rooms`, `Factories with creches` |

"Requiring" counts the factories that the Act or the state's rules require to have the provision
(for example a safety officer in factories with 1,000 or more workers); "with" counts those that
have it.

### `occupational_diseases.csv` (2016 to 2023)

| Column | Meaning |
| --- | --- |
| `state` | State that reported the cases (states with no cases are not listed) |
| `disease` | As reported, for example `Silicosis`, `Noise Induced Hearing Loss`, `Byssinosis`, `Asbestosis` |
| `value` | Cases |

## Dock works in the major ports

`port` is one of the major ports (`Mumbai`, `Jawaharlal Nehru Port`, `Kandla (Deendayal)`,
`Mormugao`, `Kolkata`, `Paradip`, `Visakhapatnam`, `Chennai`, `Kochi`, `New Mangalore`,
`Tuticorin (V.O. Chidambaranar)`) or `Total`.

### `ports_accidents.csv` (2012 to 2024)

| Measure | Meaning |
| --- | --- |
| `Fatal accidents`, `Non-fatal accidents`, `Total accidents` | Reportable accidents (non-fatal shown separately from 2021) |
| `Dangerous occurrences` | Dangerous occurrences reported |
| `Average daily employment` | Dock workers |
| `Frequency rate (fatal)`, `Frequency rate (total)` | Accidents per 1,000,000 man-hours worked (IS 3786; man-hours assume 362 working days a year) |
| `Incidence rate (fatal)`, `Incidence rate (total)` | Accidents per 1,000 workers employed |

### `ports_accidents_by_agency_type.csv` (2008 to 2024; no 2013)

| Column | Meaning |
| --- | --- |
| `classification` | `Agency` (what was involved) or `Type` (how it happened) |
| `category` | Agencies: `Lifting appliances`, `Loose gear and ropes`, `Unitised and break bulk cargo`, `Bulk cargo`, `Electrical equipment`, `Tools and implements`, `Means of access`, `Means of transportation`, `Other agencies`. Types: `Fall of persons`, `Fall of objects`, `Stepping on, striking against or struck by objects`, `Caught in or between objects`, `Overexertion or wrong movement`, `Exposure to or contact with extreme temperature`, `Exposure to or contact with electric current`, `Exposure to or contact with dangerous goods`, `Explosion`, `Others`. And `Total` |
| `measure` | `Accidents` or `Fatal accidents` |

### `ports_activity.csv` (2008 to 2024)

| Column | Meaning |
| --- | --- |
| `topic` | `Inspections and visits`, `Prosecutions`, `Investigations of fatal accidents and dangerous occurrences`, `Dock safety committees and safety weeks`, `Ships called`, `Cargo handled`, `Safety facilities`, `Health facilities`, `Welfare facilities`, `Workers` |
| `measure` | The item, for example `Ship inspections`, `Launched`, `Concluded`, `Dock safety committee meetings`, `Oil tankers`, `Containers (TEUs)`, `Petroleum, oil and lubricants (tonnes)`, `Safety officers`, `OSH centres`, `Canteens` |

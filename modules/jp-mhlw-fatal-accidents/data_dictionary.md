# Data Dictionary: Japan Fatal Accident Database

Built by `scripts/build_dataset.R` from MHLW's yearly Excel files. English labels are this module's
translations; the Japanese labels for every code are in `code_labels.csv`.

## Fatalities (`fatalities.csv.gz`)

| Column | Meaning |
| --- | --- |
| `year` | Calendar year of the accident |
| `id` | Row number in MHLW's file for that year (`year` and `id` identify a row) |
| `event_id` | Groups the deaths in one event: rows with the same year, month, time, description, workplace size, industry, agent and accident type. Approximate: two separate events with identical short descriptions would be grouped |
| `deaths_in_event` | Number of deaths in the event |
| `month` | Month of the accident |
| `time_band` | Time of day as recorded, for example `10~11`; 1-hour bands until 2018, 2-hour bands from 2019 |
| `hour_start`, `hour_end` | The band as numbers (hour 0 = midnight); blank if unknown |
| `establishment_size` | Number of workers at the workplace, grouped: `Under 10`, `10-29`, `30-49`, `50-99`, `100-299`, `300+`, `Unknown` |
| `size_reported` | Size band as recorded (bands differ between years, for example `10~19` and `20~29` in some early years, `10~29` later) |
| `industry_sector` | Industry (17 sectors, see below) |
| `industry_group` | Industry subgroup (53 groups, for example `Road freight transport (trucking)`); missing for many deaths before 1999 |
| `agent_group` | Agent: what caused the death (8 groups) |
| `agent_subgroup` | Agent subgroup (26 groups, for example `Cranes and similar`) |
| `accident_type` | Type of accident (21 types, see below) |
| `industry_sector_code`, `industry_group_code`, `industry_detail_code` | MHLW's industry codes (2, 4 and 6 digits) |
| `industry_detail_ja` | Detailed industry, in Japanese |
| `agent_group_code`, `agent_subgroup_code`, `agent_detail_code` | MHLW's agent codes (1, 2 and 3 digits) |
| `agent_detail_ja` | Detailed agent, in Japanese (for example 「はしご等」 ladders) |
| `accident_type_code` | MHLW's accident type code |
| `narrative_ja` | Description of the accident, in Japanese |
| `narrative_en` | English translation of the description (2024 only; machine translation, see the README) |

## Industry sectors

| Code | Sector | Notes |
| --- | --- | --- |
| 01 | Manufacturing | Includes electricity, gas and water |
| 02 | Mining | |
| 03 | Construction | Civil engineering, building, other construction |
| 04 | Transport | Rail, water and air; road passenger (bus, taxi); road freight (trucking) |
| 05 | Cargo handling | Land and port cargo handling |
| 06 | Agriculture and forestry | |
| 07 | Livestock and fisheries | |
| 08 | Commerce | Wholesale and retail |
| 09 | Finance and advertising | |
| 10 | Film and theatre | |
| 11 | Communications | |
| 12 | Education and research | |
| 13 | Health care and social welfare | |
| 14 | Hotels, restaurants and entertainment | |
| 15 | Cleaning, waste and slaughtering | |
| 16 | Government offices | |
| 17 | Other industries | Includes temporary staffing agencies (worker dispatch) |

MHLW's "land freight transport" (陸上貨物運送事業) in official reports is road freight transport
(`0403`) plus land cargo handling (`0501`).

## Accident types

| Code | Type |
| --- | --- |
| 1 | Fall from height (墜落、転落) |
| 2 | Fall on the same level: slip or trip (転倒) |
| 3 | Striking against an object (激突) |
| 4 | Struck by flying or falling object (飛来、落下) |
| 5 | Collapse of structures, soil or stacked material (崩壊、倒壊) |
| 6 | Struck by moving object (激突され) |
| 7 | Caught in or between (はさまれ、巻き込まれ) |
| 8 | Cut or abrasion (切れ、こすれ) |
| 9 | Stepping on or through (踏み抜き) |
| 10 | Drowning (おぼれ) |
| 11 | Contact with hot or cold objects, including heatstroke (高温・低温の物との接触) |
| 12 | Contact with harmful substances, for example poisoning or lack of oxygen (有害物等との接触) |
| 13 | Electric shock (感電) |
| 14 | Explosion (爆発) |
| 15 | Rupture (破裂) |
| 16 | Fire (火災) |
| 17 | Traffic accident, road (交通事故（道路）) |
| 18 | Traffic accident, other: rail, ship, aircraft (交通事故（その他）) |
| 19 | Overexertion or awkward movement (動作の反動、無理な動作) |
| 90 | Other |
| 99 | Unclassifiable |

A handful of rows have an accident type code that does not match its Japanese label; the build
uses the label.

## Agents

| Code | Group | Subgroups |
| --- | --- | --- |
| 1 | Power machinery | Engines, power transmission, woodworking, construction machinery, metalworking, other powered machinery, timber harvesting vehicles |
| 2 | Lifting and transport machinery, vehicles | Cranes; powered transport machinery (trucks, forklifts, conveyors); vehicles (cars, buses, motorcycles, trains, ships, aircraft) |
| 3 | Other equipment | Pressure vessels, chemical plant, welding, furnaces, electrical equipment, hand tools, tools and equipment (ladders, slings, scaffold boards) |
| 4 | Temporary structures, buildings and structures | Scaffolds, roofs, openings, stairs and similar |
| 5 | Substances and materials | Hazardous and harmful substances; materials |
| 6 | Loads | |
| 7 | Environment | Ground, water, heat, weather |
| 9 | Other | Other agents, no agent, unclassifiable |

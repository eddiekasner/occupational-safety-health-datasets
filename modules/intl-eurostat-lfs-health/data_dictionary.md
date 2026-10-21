# Data Dictionary: EU Labour Force Survey, Accidents at Work and Work-Related Health Problems

Built by `scripts/build_dataset.R` from 40 Eurostat tables. `accidents.csv.gz`,
`health_problems.csv.gz` and `exposures.csv.gz` have the same columns.

## Columns

| Column | Meaning |
| --- | --- |
| `table` | Eurostat table code (see `tables.csv`) |
| `measure` | What is counted: `Accident at work`, `Accident at work with time off work`, `Road traffic accident at work`, `Work-related health problem`, `Work-related health problem with time off work`, `Work-related health problem limiting daily activities`, `Exposure to risk factors for physical health` or `Exposure to risk factors for mental well-being` |
| `year` | Survey year: 2007, 2013 or 2020 |
| `geo`, `country` | Eurostat country code and name. Aggregates: `EU27_2020` (European Union, 27 countries), `EU28` (with the United Kingdom, 2013 to 2020) and `EA19` (euro area) |
| `sex` | `Total`, `Male` or `Female` |
| `age` | Age group, such as `15-64` or `15-34`. Groups overlap; `15-64` is in every table |
| `breakdown` | The table's other variable (see below), or `None` |
| `category_code`, `category` | Category of that variable; `TOTAL` (or `EMP` for professional status) is everyone |
| `unit` | What the percentage is of (see below) |
| `value` | The percentage |
| `flag` | Eurostat's flags (see below); blank if none |

## Units

| Unit | Percentage of |
| --- | --- |
| `PC_EMP_PREEMP_M12` | People working now or in the past 12 months (accidents) |
| `PC_EMP_PREEMP` | People working now or in the past (health problems) |
| `PC_EMP` | People working now (exposures) |
| `PC_PER_ACC` | People who reported an accident at work |
| `PC_PER_HPB` | People who reported a work-related health problem |

For example, in `hsw_ac3`, `PC_PER_ACC` for `1 month or over` is the share of people with an
accident whose time off work was a month or more.

## Breakdowns

| Breakdown | Categories |
| --- | --- |
| `Education` | ISCED 2011 levels 0-2, 3-4 and 5-8 |
| `Time off work` | `From 1 to 3 days`, `4 days or over`, `1 month or over` (and for health problems `3 months or over`, `6 months or over`), `Unknown` |
| `Activity (NACE Rev. 2)` | Six groups of sections, 2013 and 2020 (agriculture; industry; construction; trade, transport, accommodation and information; finance and other services) |
| `Activity (NACE Rev. 1.1)` | Six groups of sections, 2007 only |
| `Occupation` | Four groups of ISCO-08 major groups (managers and professionals; clerical, service and sales; skilled agricultural and craft; plant operators and elementary) |
| `Professional status` | `Employed persons` (`EMP`, the total), `Employees`, `Self-employed persons`, `Contributing family workers` |
| `Size of local unit` | `Small`, `Medium`, `Large` |
| `Full-time or part-time` | `Full-time`, `Part-time` |
| `Atypical working time` | How often the person works at atypical working times: `Usually`, `Sometimes`, `Never` |
| `Working from home` | Works from home: `Usually`, `Sometimes`, `Never` |
| `Country of birth` | Reporting country, other EU country, non-EU country, any foreign country |
| `Limitation of daily activities` | `Some`, `Severe`, `None` |
| `Type of health problem` | The most serious work-related health problem: musculoskeletal disorders; stress, depression or anxiety; headaches and eyestrain; cardiovascular; pulmonary; hearing; skin; infectious; digestive; other |
| `Risk factor` | The main risk factor for physical health (such as handling heavy loads, chemicals, dusts, fumes, smoke or gases, noise or vibration) or for mental well-being (such as time pressure or overload of work, harassment or bullying, violence or threat of violence). The list changed in 2020 |

## Flags

| Flag | Meaning |
| --- | --- |
| `b` | Break in time series: not comparable with earlier years |
| `d` | Definition differs (see Eurostat's metadata) |
| `u` | Low reliability (small sample) |
| `p` | Provisional |

Flags can combine (for example `bu`). Confidential values are not published by Eurostat and are
not in these files.

## Tables (`tables.csv`)

| Column | Meaning |
| --- | --- |
| `table`, `title` | Eurostat table code and title |
| `measure`, `breakdown` | As above |
| `years`, `units` | Years and units in the table |
| `values` | Number of values |

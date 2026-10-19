# Data Dictionary: South Korea Industrial Accident Microdata (KOSHA)

Built by `scripts/build_dataset.R` from KOSHA's microdata. The English labels are translations of
KOSHA's Korean categories (see `scripts/labels_ko_en.csv` for every Korean term and its
translation). Blank means not applicable or unknown.

## Injured workers (`injured_workers.csv.gz`)

One row per injured worker or death whose workers' compensation claim was approved in the year.

| Column | Meaning |
| --- | --- |
| `year` | Year the claim was approved (not the year of the accident) |
| `case_type` | `Accident injury`, `Occupational disease`, `Accident death`, `Occupational disease death`, or `Accident death not in the official count` (deaths that Korea's official statistics leave out, such as road accidents outside the workplace and deaths more than a year after the accident; see the README) |
| `industry_group` | Major industry of the workplace: `Mining`, `Manufacturing`, `Electricity, gas, steam and water supply`, `Construction`, `Transport, warehousing and communications`, `Forestry`, `Fishing`, `Agriculture`, `Finance and insurance`, `Other businesses (services)` (which includes retail, health care, food and accommodation, public administration and other services) |
| `industry` | Detailed industry as published that year (the workers' compensation insurance classification, which changed in 2018, 2019 and 2020) |
| `industry_2020` | `industry` mapped to the classification used since 2020, for trends (approximate for 2017 to 2019) |
| `accident_type` | How the accident happened: `Falls from height`, `Slips and trips`, `Caught in or between`, `Cuts and punctures`, `Struck against or collision`, `Struck by object`, `Caught under or overturned`, `Collapse`, `Overexertion and awkward movement`, `Contact with hot or cold objects`, `Electric shock`, `Fire`, `Explosion or rupture`, `Chemical release or contact`, `Oxygen deficiency`, `Drowning`, `Traffic accident in the workplace`, `Traffic accident outside the workplace`, `Sports event`, `Violence`, `Injury by animal`, `Other`, `Unclassifiable`; `Occupational disease` for disease cases |
| `establishment_size` | Number of workers at the workplace: `1-4`, `5-9`, `10-19`, `20-29`, `30-49`, `50-99`, `100-299`, `300-499`, `500-999`, `1000+` |
| `sex` | `Male`, `Female` |
| `age_group` | `Under 18`, `18-24`, `25-29`, then 5-year groups to `55-59`, and `60+` |
| `length_of_service` | Time with the employer: `Under 6 months`, `6 months to 1 year`, `1-2 years`, `2-3 years`, `3-4 years`, `4-5 years`, `5-10 years`, `10+ years` |
| `days_of_care` | Days of medical care (the severity measure): `4-7 days`, `8-14 days`, `15-28 days`, `29-90 days`, `91-180 days`, `More than 6 months`; blank for deaths |
| `region` | Region (by the regional labour office responsible, which does not exactly follow administrative boundaries): `Seoul`, `Busan`, `Daegu`, `Incheon`, `Gwangju`, `Daejeon`, `Ulsan`, `Gyeonggi`, `Gangwon`, `North Chungcheong`, `South Chungcheong`, `North Jeolla`, `South Jeolla`, `North Gyeongsang`, `South Gyeongsang`, `Jeju` |
| `labour_office` | Labour office responsible (49 offices; "regional office" marks the six regional headquarters) |
| `construction_value` | For construction, the contract value of the project: `Under 0.3 billion won` to `100+ billion won`, or `Unknown` (1 billion won is about 700,000 US dollars) |
| `disease_group` | For disease cases: `Musculoskeletal disorders from physically demanding work`, `Low back pain`, `Noise-induced hearing loss`, `Pneumoconiosis`, `Cerebrovascular and cardiovascular disease`, `Metals and heavy metals`, `Organic compounds`, `Other chemicals`, `Other` |
| `disease` | More detail for disease cases, for example `Low back pain from an accident`, `Carpal tunnel syndrome`, `Occupational cancer`, `Asbestos-related disease`, `Mental illness`, `Infectious disease`, `Benzene`, `Lead` |

To match Korea's official counts: injured workers are all rows; deaths are rows with `case_type`
`Accident death` or `Occupational disease death`; accident deaths are `Accident death` only.

## Insured workers (`insured_workers.csv`)

From the Ministry of Employment and Labor's year-end reports.

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `breakdown` | `All`, `Industry group` or `Establishment size` |
| `group` | For industry: `Mining`, `Manufacturing`, `Construction`, `Electricity, gas, steam and water supply`, `Transport, warehousing and communications`, `Forestry`, `Other businesses (services)`, `Agriculture, fishing, finance and insurance` (reported together before 2020). For size: `1-4`, `5-49`, `50-99`, `100-299`, `300-999`, `1000+` |
| `insured_workers` | Workers covered by workers' compensation insurance (the denominator for rates) |
| `reported_injured`, `reported_deaths` | Injured workers and deaths as published (they match the microdata) |
| `source_report` | Year of the report the figures come from (each report also gives the previous year) |

Rates: injury rate (%) = 100 x injured / insured workers; fatality rate per 10,000 workers =
10,000 x deaths / insured workers.

## National trend (`national_trend.csv`)

One row per year, 1964 to 2025. Blank where not published.

| Column | Meaning |
| --- | --- |
| `year` | Year |
| `insured_workers` | Workers covered by workers' compensation insurance |
| `injured` | Injured workers (including deaths and disease cases) |
| `injury_rate_pct` | Injured workers per 100 insured workers |
| `deaths` | Deaths under the current definition (2003 onward; see the README) |
| `accident_deaths` | Accident deaths under the current definition (2007 onward) |
| `deaths_old_definition` | Deaths under the definition used before 2011 (1964 to 2016; includes, for example, road accidents outside the workplace) |
| `injured_no_lasting_disability` | Injured workers without lasting disability (1964 to 2016) |
| `disease_cases_in_care` | Occupational disease cases receiving care (1972 to 2016) |
| `permanent_disability` | Workers left with a permanent disability (1989 to 2016) |
| `frequency_rate` | Injured workers per million hours worked (1972 to 2016) |
| `severity_rate` | Working days lost per 1,000 hours worked (1989 to 2016) |
| `compensation_million_won` | Compensation paid, in millions of won (current prices, 1964 to 2016) |

From 1964 to 2016, `injured` = `injured_no_lasting_disability` + `disease_cases_in_care` +
`permanent_disability` + `deaths_old_definition` (except 1978, as published).

## Accident case descriptions (`accident_cases.csv.gz`)

One row per serious accident in manufacturing, as summarised by KOSHA.

| Column | Meaning |
| --- | --- |
| `case_id` | Row number in KOSHA's file |
| `year` | Year of the accident, where the description gives it |
| `title_en`, `title_ko` | Short title (English translation, original Korean) |
| `overview_en`, `overview_ko` | What happened |
| `causes_en`, `causes_ko` | Causes |
| `prevention_en`, `prevention_ko` | Measures to prevent a similar accident |

In the English, "[company]" and "[name]" replace names that are masked in the source.

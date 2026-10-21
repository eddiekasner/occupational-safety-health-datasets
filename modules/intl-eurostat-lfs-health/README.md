# Europe: Self-Reported Accidents, Work-Related Health Problems and Exposures (EU Labour Force Survey)

**Scope:** EU countries, Iceland, Norway, Switzerland, the United Kingdom (2007 and 2013) and
Türkiye (2013) | **Publisher:** Eurostat | **Years:** 2007, 2013 and 2020

## Background

The EU Labour Force Survey (LFS) interviews a large sample of households in every European
country each quarter. In some years it adds an *ad hoc module* on a special topic. Three of those
modules (2007, 2013 and 2020) asked people about their safety and health at work:

- **Accidents at work:** did you have an accident at work in the past 12 months that injured
  you, and how long were you off work? Commuting accidents are excluded, and only living people
  are interviewed, so there are no fatal accidents.
- **Work-related health problems:** in the past 12 months, did you have any illness, disability
  or other physical or mental health problem, other than an accidental injury, that was caused or
  made worse by your work? What was the most serious one?
- **Exposure to risk factors:** in your work, are you exposed to risk factors for your physical
  health (such as heavy loads, chemicals or noise) or your mental well-being (such as time
  pressure, harassment or violence)? What is the main one?

Because these are answers from workers rather than claims or employer reports, they show harm that
never reaches a compensation or reporting system. They include minor accidents, chronic health
problems that are not recognised occupational diseases, and exposures. Eurostat publishes the
results as 40 tables by country, sex, age and one other variable (education, economic activity,
occupation, professional status, size of workplace, country of birth, and others). This module
puts all 40 together.

## What one row represents

`accidents.csv.gz`, `health_problems.csv.gz` and `exposures.csv.gz`: one percentage, from one
Eurostat table, for one year, country, sex, age group and category of that table's breakdown (for
example, the percentage of people working in construction in Spain in 2020 who reported an
accident at work). `tables.csv` lists the 40 tables, with what each measures and how it is broken
down.

## Why it matters for OSH

- **Harm that registers miss.** About 2 to 3% of workers in the EU report an accident at work each
  year, and about 10% a work-related health problem. That is far more than appears in
  administrative statistics such as ESAW (see the `intl-eurostat-esaw` module).
- **Musculoskeletal disorders** are 60% of the most serious work-related health problems, and
  stress, depression and anxiety are another 19% (EU, 2020).
- **Reporting culture.** In 2020, 9.6% of workers in Finland reported an accident at work, against
  0.5% in Lithuania. Differences this large are mostly about how people perceive, remember and
  report accidents, not about how dangerous work is. This is a classic lesson in comparing
  countries.
- **How the question shapes the answer.** The list of risk factors changed in 2020, and the share
  of workers reporting a risk to their mental well-being rose from 29% to 45%.

## Limitations to keep in mind

- **Percentages only.** The tables give percentages, not numbers of people. The base differs by
  `unit` (see the data dictionary): for accidents, people working now or in the past 12 months;
  for health problems, people working now or in the past; for exposures, people working now.
  `PC_PER_ACC` and `PC_PER_HPB` are shares of people who reported an accident or a health problem
  (for example, the share whose time off work was a month or more).
- **The questions changed.** Ages covered were 15 and over in 2007 and 2013, and 15 to 74 in 2020.
  The list of risk factors changed in 2020: some were split ("tiring or painful positions" and
  "repetitive hand or arm movements" replaced "difficult work postures"), and five new factors for
  mental well-being were added. Exposure figures are therefore not comparable across years, and
  Eurostat flags many 2020 values as breaks in series (`b`).
- **Main factor, most serious problem.** The tables by type of factor give the *main* risk factor
  of each person exposed, and the tables by type of health problem give the *most serious*
  problem. Their categories add up to the share exposed, or with a health problem.
- **Small samples.** Many values for small countries or groups are flagged as having low
  reliability (`u`). Values Eurostat keeps confidential are not published and are missing here.
- **Self-report.** Recall over 12 months, the wording of the question in each language, and what
  people think of as "caused by work" all affect the answers.
- **Overlapping tables.** The same figure (for example, the national accident rate) appears in many
  tables. Use the `table` column to pick one table at a time.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns, units, flags and categories |
| `data/tidy/tables.csv` | The 40 Eurostat tables: what each measures, its breakdown, years and units |
| `data/tidy/accidents.csv.gz` | People reporting an accident at work (16 tables, `hsw_ac*`) |
| `data/tidy/health_problems.csv.gz` | People reporting a work-related health problem (14 tables, `hsw_pb*`) |
| `data/tidy/exposures.csv.gz` | People reporting exposure to risk factors (10 tables, `hsw_exp*`) |
| `data/raw/` | Eurostat's JSON-stat files (not committed; about 4 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the 40 tables from the Eurostat API |
| `scripts/build_dataset.R` | Builds the tidy tables |

Checked by `scripts/build_dataset.R`: the headline share of people reporting an accident at work
(all education levels, activities, occupations, and so on) agrees across tables to within 0.1
percentage points.

## Official documentation

- Eurostat's [metadata for the 2020 module](https://ec.europa.eu/eurostat/cache/metadata/en/lfso_20_esms.htm),
  which defines accidents, health problems and risk factors in all three years.
- [EU-LFS ad hoc modules](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=EU_labour_force_survey_-_modules)
  (Statistics Explained), with an evaluation report for each module.

## License and citation

Eurostat's [copyright notice](https://ec.europa.eu/eurostat/web/main/help/copyright-notice)
authorises reuse of its statistical data for commercial or non-commercial purposes, provided
the source is acknowledged.

Eurostat. *Labour Force Survey ad hoc modules on accidents at work and work-related health
problems (2007, 2013, 2020), tables hsw_ac1 to hsw_ac14, hsw_pb1 to hsw_pb13 and hsw_exp1 to
hsw_exp10.* Accessed [date] from https://ec.europa.eu/eurostat

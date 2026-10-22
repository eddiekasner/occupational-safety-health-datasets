# Child Labour: ILOSTAT Survey Estimates and UNICEF Country Estimates

**Scope:** 164 countries, mostly low and middle income | **Publishers:** International Labour
Organization (ILOSTAT) and UNICEF | **Years:** surveys from 1995 to 2025

## Background

About 1 in 13 children aged 5 to 17 in the world, and 1 in 5 in sub-Saharan Africa, are in child
labour (UNICEF's estimate for 2020 to 2024). Child labour is work that is harmful to children or
that keeps them from school. It is measured with household surveys that ask about each child's
work: labour force surveys, child labour surveys, and UNICEF's Multiple Indicator Cluster Surveys
(MICS).

Three concepts nest inside each other:

- **Economic activity** (children in employment): any work for pay or profit, or in a family
  business or farm, for at least one hour in the reference week.
- **Child labour**: economic activity that is not allowed for the child's age. The ILO's
  statistical definition counts children aged 5 to 11 in any economic activity, children aged 12 to
  14 working more than light work allows, and children aged 15 to 17 in hazardous work.
- **Hazardous work**: work in hazardous industries or occupations, for long hours, at night, or in
  hazardous conditions (for example with dangerous tools, chemicals or heavy loads). It is one of
  the worst forms of child labour, and the most direct link to occupational safety and health.

The SDG target 8.7 calls for an end to child labour in all its forms by 2025. Its indicator,
**SDG 8.7.1**, is published in two versions: economic activity only, and economic activity plus
household chores above age-specific hours.

This module combines two sources:

- **ILOSTAT**, the ILO's database, which processes the microdata of national surveys. It gives the
  share of children in economic activity, child labour and hazardous work, by sex and age, and also
  by rural or urban area and school attendance. It also gives the number of children working by
  economic sector and status in employment. There can be several surveys per country.
- **UNICEF**, which publishes the latest estimate for each country, region and the world, with the
  survey it comes from.

## What one row represents

- `rates.csv.gz`: the share of children (%) of one age group and sex in one country, from one
  survey, who were in economic activity, child labour or hazardous work (or SDG 8.7.1). It can
  also be for rural or urban children, or for children attending or not attending school.
- `counts.csv.gz`: the number of children (thousands) of one age group and sex in one country,
  from one survey, in employment, child labour or hazardous work, in one economic sector or status
  in employment; or the number of children in the population.
- `unicef_latest.csv`: UNICEF's latest estimate (%) for one country or region, indicator and sex.

## Why it matters for OSH

- **Hazardous work is an occupational hazard for children.** Children are more vulnerable than
  adults to injuries, chemicals and long hours. For 15 to 17 year olds, child labour *is* hazardous
  work by definition; across ages 5 to 17, hazardous work is a median of 39% of child labour.
- **Agriculture** accounts for the largest share of child labour (a median of 45% in each
  country's latest survey), followed by services and industry.
- **Rural children and children out of school** are about twice as likely to be in child labour as
  urban children and children attending school (medians of 18% against 7%, and 18% against 10%,
  in each country's latest survey).
- **Measurement choices matter.** UNICEF and the ILO agree exactly for the labour force, household
  income and child labour surveys that the ILO processes. For MICS and DHS surveys they often
  differ, sometimes a lot (Gabon 2021: 5.4% from UNICEF, 34.7% from ILOSTAT). This is a good case
  for reading definitions before comparing numbers.

## Limitations to keep in mind

- **Surveys, not registers.** Every figure comes from a household survey, with sampling error.
  ILOSTAT flags many values as unreliable (`flag`), mostly for small groups.
- **Different surveys, different questions.** Labour force surveys often cover only children aged
  15 and over (see `note`), so many countries have figures for 15 to 17 year olds only. Questions
  about hazards, hours and chores differ between survey programmes, and between rounds of the same
  programme. Compare years within a country only when the survey is the same (`survey`), and look
  out for breaks in series.
- **Survey years differ.** UNICEF's latest estimates come from surveys between 2010 and 2025, so
  countries are compared at different times.
- **Missing categories.** In the counts by sector or status in employment, some categories are not
  published, so the categories add up to less than the total in about a fifth of cases. In some
  surveys many children's sector is not classified.
- **Household chores** count as child labour only in the SDG 8.7.1 indicator that includes them
  and in the "general production boundary" measure. Girls do more household chores, so the gap
  between boys and girls depends on which measure you use.
- **Hidden child labour.** Surveys of households miss children who live away from home, such as
  children in domestic work in other households, on the streets, or in forced labour.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns, measures and categories |
| `data/tidy/rates.csv.gz` | ILOSTAT: shares of children in economic activity, child labour and hazardous work, and SDG 8.7.1, by sex and age, area and school attendance |
| `data/tidy/counts.csv.gz` | ILOSTAT: numbers of children in employment, child labour and hazardous work by economic sector and status in employment, and child population |
| `data/tidy/unicef_latest.csv` | UNICEF: latest child labour estimates for countries, regions and the world, by sex |
| `data/raw/` | The ILOSTAT and UNICEF files (not committed; about 60 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the tables from the ILOSTAT and UNICEF APIs |
| `scripts/build_dataset.R` | Builds the tidy tables and runs the checks |

Checked by `scripts/build_dataset.R`:

- The national figures in ILOSTAT's tables by area match its tables without a breakdown (8,605 of
  8,605).
- Economic sectors and statuses in employment never add up to more than their totals.
- UNICEF and ILOSTAT are compared for the same country and year, by type of survey (see above).

## Official documentation

- ILOSTAT ([ilostat.ilo.org](https://ilostat.ilo.org), Topics, then Child labour) and the
  resolutions of the International Conference of Labour Statisticians on child labour statistics
  (2008, amended 2018).
- UNICEF: [child labour data](https://data.unicef.org/topic/child-protection/child-labour/),
  including the MICS child labour module.
- ILO and UNICEF, *Child Labour: Global estimates 2020, trends and the road forward* (2021).

## License and citation

The ILO's [Rights and permissions](https://www.ilo.org/node/9321) page says that, under its
Open Access policy, ILO materials including datasets may be reused without asking permission,
provided the ILO is cited as the source. UNICEF Data's content is licensed under a Creative Commons
Attribution-NonCommercial 3.0 IGO licence, except where otherwise noted: reuse with attribution,
for non-commercial purposes.

International Labour Organization. *ILOSTAT database: Child labour statistics.* Accessed [date]
from https://ilostat.ilo.org. UNICEF. *Child labour, UNICEF global databases.* Accessed [date] from
https://data.unicef.org

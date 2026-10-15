# Canada: AWCBC National Work Injury, Disease and Fatality Statistics

**Scope:** Canada (10 provinces and 3 territories) | **Publisher:** Association of Workers'
Compensation Boards of Canada (AWCBC) | **Years in this module:** lost time claims 1982 to 2024,
fatalities 1993 to 2024; detailed breakdowns 2022 to 2024

## Background

Each Canadian province and territory runs its own workers' compensation board or commission (WCB):
12 in total (Nunavut and the Northwest Territories share one). Through its National Work Injury,
Disease and Fatality Statistics Program (NWISP), the AWCBC collects the claims each WCB has
**accepted**, codes them to national standards, and publishes national statistics every year:

- **Lost time claims:** accepted claims for a work-related injury or disease in which the worker
  lost time from work (was paid compensation for lost wages), or received a permanent disability
  award without lost time (except in Newfoundland and Labrador and Ontario).
- **Fatalities:** accepted claims for a death from a work-related injury or disease, counted in the
  year the WCB **accepted** the claim, which can be years or decades after the exposure.

Claims are broken down by province, industry (NAICS 2017), occupation (NOC 2011), gender, age,
nature of injury or disease, part of body, source, and event or exposure (coded to CSA Z795).

## What one row represents

A count of accepted claims for one year and one category, for example "accepted fatalities from
cancer in Ontario in 2023" or "lost time claims in construction among women aged 25 to 29, 2024".

## Why it matters for OSH

- **Fatalities include occupational disease.** About two thirds of accepted fatalities in 2022 to
  2024 were diseases, mostly cancers (many of them from past asbestos exposure) and lung
  disease. The US (CFOI) and Australian (TIF) fatality counts include injuries only.
- **A 40-year series.** Lost time claims fell by more than half between 1990 and 2010, while
  fatalities did not fall at all.
- **Twelve systems, one dataset.** Differences between provinces show how compensation law and
  policy shape what gets counted.

## Limitations to keep in mind

- **Accepted claims only.** Injuries never reported, claims denied, and claims with no time lost
  are not included. Under-claiming of work injuries is well documented in Canada.
- **Coverage varies.** The share of workers covered by a WCB ranges from roughly three quarters in
  some provinces to nearly all workers in others (see AWCBC's Year at a Glance); the self-employed and some industries are often not
  covered. There are **no denominators** in this dataset, so it cannot give rates per worker.
- **Twelve sets of rules.** Each WCB has its own laws, policies and coding practices, so
  differences between provinces are not simply differences in safety.
- **Jumps that are not about safety.** Quebec's lost time claims rose by half in 2022, and
  Ontario's roughly doubled in 2024 in almost every industry at once. A jump across every industry
  in a single year points to changes in policy, reporting or data submission rather than to a
  real change in injuries; check with the WCB before interpreting it.
- **Fatalities by year of acceptance.** Disease deaths are accepted long after exposure, and a lost
  time claim that later becomes a fatality is counted as both.
- **Suppression.** Counts of 3 or fewer are shown as "X" (missing here, with `flag` = `X`).
- **Small inconsistencies.** A few of AWCBC's tables differ from others by one or two claims
  (for example, the fatalities by part of body table totals 1,044 deaths in 2024, the others
  1,046), and some industry tables do not print a Total row.
- **Missing codes.** Many claims are not coded for some characteristics (for example, about one
  in five fatalities in 2024 has no industry), which limits detailed comparisons.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Tables, columns and codes |
| `data/tidy/nwisp_jurisdiction_trend.csv` | Lost time claims (1982 to 2024) and fatalities (1993 to 2024) by province or territory |
| `data/tidy/nwisp_jurisdiction.csv.gz` | Claims and fatalities by each characteristic and province, 2022 to 2024 |
| `data/tidy/nwisp_industry_occupation.csv.gz` | Claims and fatalities by each characteristic within industry sectors and occupation categories, Canada, 2023 and 2024 |
| `data/raw/` | The AWCBC publication (PDF, not committed) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the publication |
| `scripts/build_dataset.R` | Reads the 42 tables from the PDF (needs the `pdftotext` command) and checks them against the published totals |

The tidy tables contain every number in the 42 tables of the publication *National Work Injury,
Disease and Fatality Statistics 2022-2024*, downloaded in October 2026.

## Official documentation

- [NWISP home page and downloads](https://awcbc.org/data-and-statistics/national-work-injury-disease-statistics-program)
- [NWISP definitions](https://awcbc.org/data-and-statistics/national-work-injury-disease-statistics-program/nwisp-definitions)
  and [data considerations](https://awcbc.org/data-and-statistics/national-work-injury-disease-statistics-program/nwisp-data-considerations)
- [NAICS Canada 2017](https://www.statcan.gc.ca/en/subjects/standard/naics/2017/v3/index) and
  [NOC 2011](https://www.statcan.gc.ca/en/subjects/standard/noc/2011/index)

## Terms of use

The data are © AWCBC. Under the
[NWISP Terms and Conditions](https://awcbc.org/data-and-statistics/national-work-injury-disease-statistics-program/nwisp-terms-and-conditions),
the source must be acknowledged and any interpretation must be identified as the user's own:

> Source: Association of Workers' Compensation Boards of Canada (AWCBC), National Work
> Injury/Disease Statistics Program (NWISP), *National Work Injury, Disease and Fatality Statistics
> 2022-2024*. The tables in this module were reformatted from the publication; any analyses and
> interpretations are those of the users and not of the AWCBC or its member Boards and Commissions.

## Citation

Association of Workers' Compensation Boards of Canada. *National Work Injury, Disease and Fatality
Statistics 2022-2024.* Toronto: AWCBC. https://awcbc.org/data-and-statistics/national-work-injury-disease-statistics-program

# Safe Work Australia: Work-related Fatalities and Workers' Compensation Claims

**Scope:** Australia | **Publisher:** Safe Work Australia | **Years in this module:** deaths
2016 to 2025 (calendar) and 2015-16 to 2024-25 (financial); serious claims and injury frequency
rates 2015-16 to 2024-25

## Background

Safe Work Australia is the national policy agency for work health and safety (WHS) and workers'
compensation. It does not enforce the law; the states, territories and the Commonwealth do that.
It compiles two national collections, which this module covers:

- **Traumatic Injury Fatalities (TIF).** Every person in Australia who died from an injury caused
  by work activity. Safe Work Australia starts from media reports, then confirms and codes each
  death using notifications from WHS regulators, the National Coronial Information System (NCIS),
  and workers' compensation claims. Unlike claims data, it covers the self-employed, contractors,
  volunteers and defence personnel. The public tables count workers; deaths of bystanders are in
  the database but not published.
- **National Dataset for Compensation-based Statistics (NDS).** Accepted workers' compensation
  claims from every state, territory and Commonwealth scheme. Safe Work Australia reports mostly
  on **serious claims**: accepted claims with **one working week or more** of time lost, excluding
  deaths and injuries while commuting or on a break away from the workplace.

From NDS data it also publishes **workers' compensation injury frequency rates (WCIFR)**: lost time
claims per million hours worked, by detailed industry and occupation, meant as benchmarks that
businesses can compare themselves against.

## What one row represents

A published estimate for one year (or one 5-year average) and one category, for example
"deaths in Construction in 2025" or "serious claims for mental stress in 2023-24".

## Why it matters for OSH

Australia is a good comparison for the US modules: similar economy and industries, but a
different system. Workers' compensation claims are the main national source of non-fatal injury
statistics (the US relies on an employer survey, SOII), and the fatality census uses a narrower
definition than the US CFOI. The data also show trends the US data hide, such as a fast rise in
mental health claims.

## Limitations to keep in mind

- **What the TIF counts.** Only deaths from *traumatic injury*: it excludes deaths from
  occupational disease (for example cancers, silicosis, asbestos-related disease), suicides,
  commuting, and natural causes such as heart attacks not directly triggered by work. Deaths
  are counted by date of death, and the most recent years can be revised.
- **Rates suppressed when the count is 0.** A TIF rate shows as `NP` (not published) whenever
  there were no deaths in that category and year.
- **Who can claim.** Workers' compensation covers about 85% of jobs. The self-employed are
  largely not covered, and some groups (Australian Defence Force members, Western Australian
  police) are under separate schemes. The Australian Bureau of Statistics estimates only about
  one in three workers with a work-related injury or illness makes a claim.
- **Diseases are under-counted** in claims, because long-latency diseases are hard to link to
  work and some (such as mesothelioma) are compensated through other schemes.
- **Eight schemes, eight sets of rules.** Each jurisdiction has its own law on who and what is
  covered, so differences between states partly reflect their schemes, not their safety.
- **Preliminary year.** The latest financial year (`preliminary = TRUE`) will be revised upward
  as late claims arrive, and its median compensation and time lost are not published. The prior
  five years are also revised each year.
- **Suppression.** Claim counts under 5 and rates whose denominator has a relative standard
  error of 50% or more are `NP`.
- **Coding changes.** Older claims were coded with earlier industry, occupation and injury
  classifications and converted. In 2021-22 and 2022-23, a coding default in NSW inflated claims
  for "Other miscellaneous labourers". Mental stress codes changed in 2021.
- **COVID-19.** Many COVID-19 claims (notably in NSW in 2021-22) lowered the median compensation
  and time lost for that year.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Tables, columns and codes |
| `data/tidy/tif_fatalities.csv` | Work-related deaths, counts and rates per 100,000 workers, by industry, occupation, mechanism, agency, age and sex, state, jurisdiction and vehicle |
| `data/tidy/nds_serious_claims.csv` | Serious claims: counts, frequency and incidence rates, median compensation and median time lost, by industry, occupation, nature, mechanism, bodily location, agency, age and sex, and jurisdiction |
| `data/tidy/wcifr.csv` | Lost time claims per million hours worked by detailed industry and occupation |
| `data/source/` | The Safe Work Australia Excel files and explanatory notes these tables were built from |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | How to get newer versions of the source files |
| `scripts/build_dataset.R` | Builds the tidy tables from `data/source/` |

The tidy tables contain every number in the three published detailed data files (released
9 October 2026) and are committed to the repository. The source files are small (under 1 MB
each), so they are committed too.

### Updating

Safe Work Australia releases new detailed data files each year. Its website does not allow
scripted downloads, so download the files by hand (see `scripts/fetch_data.R` for where), save
them in `data/source/` in place of the old ones, and run `scripts/build_dataset.R`.

## Official documentation

- [Work-related fatalities data](https://data.safeworkaustralia.gov.au/about-our-datasets/work-related-fatalities-data)
- [Workers' compensation data](https://data.safeworkaustralia.gov.au/about-our-datasets/workers-compensation-data)
- [Understanding workers' compensation injury frequency rates](https://data.safeworkaustralia.gov.au/help-resources/understanding-workers-compensation-injury-frequency-rates)
- [Type of Occurrence Classification System (TOOCS), 3rd edition](https://data.safeworkaustralia.gov.au/about-our-datasets/type-occurrence-classification-system-toocs-3rd-edition)
- [ANZSIC 2006 industry classification](https://www.abs.gov.au/statistics/classifications/australian-and-new-zealand-standard-industrial-classification-anzsic/2006-revision-2-0)
  and [ANZSCO occupation classification](https://www.abs.gov.au/statistics/classifications/anzsco-australian-and-new-zealand-standard-classification-occupations/2022)
- In `data/source/`: TIF explanatory notes (November 2024), TIF data dictionary (January 2025),
  and NDS 3.2 explanatory notes (July 2025)

## Licence

Safe Work Australia data and documents are licensed under
[Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/)
(except the Safe Work Australia logo). You may copy and adapt them as long as you credit
Safe Work Australia.

## Citation

Safe Work Australia. *Traumatic Injury Fatalities detailed data file 2025*; *National Dataset for
Compensation-based Statistics detailed data file 2024-25*; *Workers' compensation injury
frequency rate detailed data file 2024-25.* Published 9 October 2026.
https://data.safeworkaustralia.gov.au/. Licensed under CC BY 4.0.

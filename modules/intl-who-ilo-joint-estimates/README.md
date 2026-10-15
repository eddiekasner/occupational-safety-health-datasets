# WHO/ILO Joint Estimates of the Work-related Burden of Disease and Injury

**Scope:** 183 countries, 6 WHO regions and the world | **Publishers:** World Health Organization
(WHO) and International Labour Organization (ILO) | **Years in this module:** 2000, 2010 and 2016
(plus 2019 for solar ultraviolet radiation)

## Background

Most people whose work kills them do not die in an accident. They die of heart disease, stroke,
lung disease or cancer, often years after the exposure and after they have retired, and their
deaths are rarely recorded as work-related. The WHO/ILO Joint Estimates are the first official
global estimates of this burden.

WHO and the ILO selected **41 pairs** of an occupational risk factor and a health outcome with
strong enough evidence, covering **19 risk factors**:

- long working hours (55 or more hours a week): stroke and ischaemic heart disease
- particulate matter, gases and fumes: chronic obstructive pulmonary disease (COPD)
- occupational injuries: 19 kinds of injury, from road injuries to falls and drowning
- 13 carcinogens: asbestos (lung, larynx and ovary cancer, mesothelioma), arsenic, benzene,
  beryllium, cadmium, chromium, diesel engine exhaust, formaldehyde, nickel, polycyclic aromatic
  hydrocarbons, silica, sulphuric acid and trichloroethylene
- asthmagens (asthma), ergonomic factors (low back pain) and noise (hearing loss)

A separate estimate for **solar ultraviolet radiation** and non-melanoma skin cancer was added in
2023 and is included here too.

For each pair, the **population attributable fraction (PAF)** is the share of all deaths (or
DALYs) from the disease that would not have occurred without the occupational exposure. The PAF
times the total burden of the disease gives the attributable burden. For 39 pairs the PAFs come from
the Global Burden of Disease study; for long working hours, WHO and the ILO estimated exposure and
risk themselves through new systematic reviews.

**Headline result:** in 2016, about 1.88 million deaths and 89.7 million DALYs were attributable to
the 41 pairs. Long working hours caused the most deaths (745,000), followed by particulate matter,
gases and fumes (450,000) and injuries (363,000). Diseases accounted for 81% of the deaths.

## What one row represents

A modelled estimate, with its 95% uncertainty interval, for one risk factor and disease pair, one
year, one place (world, WHO region or country), one sex and one age group, for example "deaths
from mesothelioma attributable to occupational asbestos exposure, men aged 65 to 69, Europe, 2016".

## Why it matters for OSH

- It shows that work-related **disease** kills about four times as many people as work-related
  injury, while most national surveillance systems (including the other modules in this
  repository) count injuries.
- It puts **work organisation** (long hours) on the map as a health hazard alongside chemicals.
- It supports monitoring of progress towards the Sustainable Development Goals on health and decent work.

## Limitations to keep in mind

- **Modelled, not counted.** No death in this dataset was individually recorded as work-related.
  The estimates depend on exposure data (often sparse in low-income countries), relative risks from
  other populations, and the total disease burden estimates they are applied to.
- **Uncertainty intervals are incomplete.** They do not capture all sources of error, such as
  errors in the model's structure.
- **An underestimate.** Many hazards are not included (for example shift work, job strain,
  infectious diseases at work, pesticides, many carcinogens and mental health outcomes).
- **Pairs overlap.** A person can be exposed to several risk factors. Adding up deaths across pairs
  for the same disease may double count (for example lung cancer from asbestos and from silica).
- **Rates are per population, not per worker.** Rates are per 100,000 people in the age group
  (for "15+ years", everyone aged 15 and over), so they are not comparable with rates per worker in
  the other modules.
- **Long latency.** Deaths from cancers and COPD in 2016 reflect exposures decades earlier.
- **Point in time.** The main estimates stop in 2016 (2019 for solar UV radiation).

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Tables, columns and codes |
| `data/tidy/burden_global_regional.csv.gz` | Deaths and DALYs by pair, for the world and WHO regions, by sex and 5-year age group |
| `data/tidy/burden_country.csv.gz` | Deaths and DALYs by pair for 183 countries, by sex, ages 15+ |
| `data/tidy/exposure.csv.gz` | People exposed to long working hours and to solar UV radiation at work |
| `data/tidy/disease_death_rate.csv.gz` | Deaths from all work-related diseases per 100,000 population (the summary indicator) |
| `data/raw/` | Exports from the WHO application (not committed; about 1 GB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | How to get the exports (by hand, or by running `export_from_app.js`) |
| `scripts/export_from_app.js` | Downloads every export from the WHO application with a headless browser (Node.js and Playwright) |
| `scripts/build_dataset.R` | Builds the tidy tables, with checks against the 2021 report |

The tidy tables were built from exports downloaded in October 2026 (file version
`WHO_ILO_BOD_2023_05`). Country-level estimates by 5-year age group are in the exports but are left
out of the committed tables to keep them small; run the scripts to get them.

### Notes on the source data

- The application labels the WHO South-East Asia Region "South-East Pacific". It is called
  "South-East Asia" here.
- The application's column "Number (for DALYs in 1000s)" actually holds whole numbers of DALYs, not
  thousands (for example 10,655,256 DALYs from ischaemic heart disease due to long working hours in
  2016, which the report gives as 10.66 million).
- Age groups are written as "15+ years" and "95+ years" (the application uses the symbol ≥).
- The solar UV estimates call Turkey by its current name, Türkiye; this name is used throughout.

## Official documentation

- [WHO/ILO Joint Estimates page](https://www.who.int/teams/environment-climate-change-and-health/monitoring/who-ilo-joint-estimates)
- [WHO/ILO joint estimates of the work-related burden of disease and injury, 2000-2016: global monitoring report](https://www.who.int/publications/i/item/9789240034945) (2021)
- Pega F, et al. Global, regional, and national burdens of ischemic heart disease and stroke
  attributable to exposure to long working hours for 194 countries, 2000-2016. *Environment
  International* 2021;154:106595. https://doi.org/10.1016/j.envint.2021.106595
- [Occupational Burden of Disease Application](https://who-ilo-joint-estimates.shinyapps.io/OccupationalBurdenOfDisease/) (source of the data; see its About tab and Terms of Use)

## Licence and terms of use

The estimates are © WHO and ILO and are published under the
[Creative Commons Attribution 3.0 IGO licence](https://creativecommons.org/licenses/by/3.0/igo/).
The application's Terms of Use also forbid use in commercial, promotional or political activities
and any suggestion that WHO endorses the user; educational use such as this course is allowed.
The global monitoring report is licensed CC BY-NC-SA 3.0 IGO.

## Citation

As required by the application's Terms of Use:

Occupational Burden of Disease Application: App for exploring and visualizing occupational burden of
disease estimates, by country, sex and age group. Estimates from Pega et al., 2021. Version 1.0.
Geneva, World Health Organization, 2021.

and

World Health Organization and International Labour Organization. *WHO/ILO joint estimates of the
work-related burden of disease and injury, 2000-2016: global monitoring report.* Geneva, 2021.

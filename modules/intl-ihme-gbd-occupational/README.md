# Global Burden of Disease: Occupational Risks (IHME)

**Scope:** the world, 21 GBD regions and 204 countries and territories | **Publisher:** Institute
for Health Metrics and Evaluation (IHME), University of Washington | **Years:** 1990 to the
latest GBD round (GBD 2023 covers 1990 to 2023)

> **The data are not in this repository.** IHME's licence does not allow us to post its data for
> others to download. Each student downloads the data from IHME (free, with an account) by
> following the steps below, then runs one script. This takes about 20 minutes the first time.

## Background

The Global Burden of Disease (GBD) study estimates deaths and ill health from more than 370
diseases and injuries, and how much of that burden is attributable to 88 risk factors, for every
country, every year since 1990. One group of risk factors is **occupational risks**:

| Risk (GBD level 3) | Health outcomes |
| --- | --- |
| Occupational carcinogens (13: asbestos, arsenic, benzene, beryllium, cadmium, chromium, diesel engine exhaust, formaldehyde, nickel, polycyclic aromatic hydrocarbons, silica, sulfuric acid, trichloroethylene) | Cancers of the lung, larynx, ovary and other sites, mesothelioma, leukaemia |
| Occupational asthmagens | Asthma |
| Occupational particulate matter, gases, and fumes | Chronic obstructive pulmonary disease (COPD), and some pneumoconioses |
| Occupational noise | Age-related and other hearing loss |
| Occupational injuries | Injuries at work |
| Occupational ergonomic factors | Low back pain |

For each pair of a risk and a disease, GBD estimates the **population attributable fraction
(PAF)**: the share of the disease that would not have happened if no one had been exposed at work.
The PAF times the total burden of the disease gives the burden attributable to the risk.

Burden is measured in **deaths** and **disability-adjusted life years (DALYs)**: years of life
lost to early death plus years lived with disability, weighted by its severity.

## How this module differs from the WHO/ILO Joint Estimates

The [WHO/ILO Joint Estimates module](../intl-who-ilo-joint-estimates/) uses GBD's methods for
most of its estimates, so the two are closely related. The differences that matter:

| | GBD (this module) | WHO/ILO Joint Estimates |
| --- | --- | --- |
| Years | Every year since 1990 | 2000, 2010, 2016 |
| Long working hours | Not included | Included (the largest single risk) |
| Countries | 204 | 183 |
| Updated | Every one to three years, with all past years re-estimated | Once (2021), with a later addition |
| Licence | Non-commercial, no redistribution | Open (CC BY 3.0 IGO) |

## What one row represents

A modelled estimate, with its 95% uncertainty interval, for one measure (deaths or DALYs), metric
(number, rate per 100,000, or percent of all deaths or DALYs), place, year, sex, age group and
risk, for example "DALYs attributable to occupational noise, age-standardized rate per 100,000,
India, 2010, both sexes".

## Getting the data

You need a free IHME account. The download tool and options change from time to time; if a step
does not match what you see, choose the closest option.

1. Go to the **GBD Results Tool**: https://vizhub.healthdata.org/gbd-results/ and sign in (or
   create an account; it is free for non-commercial use, and you must accept IHME's
   Free-of-Charge Non-commercial User Agreement).
2. Make the **first download (world and regions, every year)** with these settings:

   | Setting | Choose |
   | --- | --- |
   | GBD Estimate | Risk factor |
   | Measure | Deaths; DALYs (Disability-Adjusted Life Years) |
   | Metric | Number; Percent; Rate |
   | Risk | Occupational risks, and everything under it (select all) |
   | Cause | All causes |
   | Location | Global; all 21 GBD regions (not the 7 super-regions) |
   | Age | All ages; Age-standardized |
   | Sex | Both; Male; Female |
   | Year | Select all |

3. Click **Download**. Large requests are prepared in the background and IHME emails you a link.
   If the tool says the request is too large, download it in parts (for example by year range):
   the script combines them.
4. Make the **second download (countries)** with the same settings except:

   | Setting | Choose |
   | --- | --- |
   | Risk | Occupational risks and the six risks one level below it (not the 13 carcinogens) |
   | Location | All countries and territories |
   | Sex | Both |
   | Year | 1990, 2000, 2010, 2019, and the latest year |

5. Put the downloaded files (zip or CSV; no need to unzip) in this module's `data/raw/` folder.
6. Open `scripts/prepare_data.R` in RStudio and click **Source**. It checks the files, combines
   them, and writes `data/processed/gbd_occupational.csv.gz`, which the notebooks read.

`data/raw/` and `data/processed/` are excluded from git, so the data will not be uploaded if you
commit your work. Please do not share the files with others; anyone who wants them can download
them from IHME.

## Why it matters for OSH

- GBD gives a consistent time series: students can see whether the burden of work-related disease
  and injury is falling, where, and why.
- It shows work-related disease (cancer, COPD, hearing loss, back pain) next to injuries, which most
  national surveillance systems count far better.
- It places occupational risks among all other risk factors (smoking, air pollution, diet) with
  the same methods, so their importance can be compared.

## Limitations to keep in mind

- **Modelled, not counted.** No death here was individually recorded as work-related. Estimates
  depend on exposure data (sparse in many countries), relative risks often from other populations,
  and modelled totals for each disease. Estimates for countries with little data lean heavily on
  their neighbours and on covariates.
- **Re-estimated every round.** Each GBD round re-estimates every past year, so numbers from
  different rounds (for example GBD 2019 and GBD 2023) should not be mixed. Note which round you
  downloaded.
- **Incomplete list of risks.** Long working hours, shift work, psychosocial risks, pesticides,
  infectious diseases at work and many carcinogens are not included, so the total is an
  underestimate.
- **Occupational injuries.** GBD counts injuries attributable to work using data on fatal
  injury rates by industry; it may not match national counts such as the CFOI.
- **Uncertainty.** The 95% uncertainty intervals (`lower`, `upper`) can be wide. Do not treat small
  differences between countries or years as real unless the intervals support it.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns and values in the prepared file |
| `data/raw/` | Your GBD downloads (not committed) |
| `data/processed/gbd_occupational.csv.gz` | Made by `prepare_data.R` (not committed) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Opens the GBD Results Tool and checks which downloads you have |
| `scripts/prepare_data.R` | Combines and tidies your downloads |

## Official documentation

- [GBD Results Tool](https://vizhub.healthdata.org/gbd-results/)
- [GBD Compare](https://vizhub.healthdata.org/gbd-compare/) (interactive charts of the same
  estimates)
- [GBD risk factor descriptions and methods](https://www.healthdata.org/research-analysis/gbd)
  (see the risk factors paper for the latest round, published in *The Lancet*)

## Licence

GBD data are provided under the
[IHME Free-of-Charge Non-commercial User Agreement](https://www.healthdata.org/data-tools-practices/data-practices/ihme-free-charge-non-commercial-user-agreement).
You may use them for non-commercial purposes, including teaching and research, and publish results
and analyses, with attribution. You may not post the data sets for others to download without
IHME's written permission, which is why this module contains no data.

## Citation

Global Burden of Disease Collaborative Network. *Global Burden of Disease Study [round] Results.*
Seattle, United States: Institute for Health Metrics and Evaluation (IHME), [year]. Available from
https://vizhub.healthdata.org/gbd-results/ (accessed [date]).

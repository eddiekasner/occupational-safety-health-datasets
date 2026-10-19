# Occupational Safety and Health Datasets

A collection of public occupational safety and health (OSH) datasets, organized as
self-contained teaching modules. Used in **ENVH 312** (undergraduate) and
**ENVH 460/560** (undergraduate/graduate).

Each module gives students:

| Piece | What it is |
| --- | --- |
| `README.md` | Background: who collects the data, why, what it can and cannot tell you |
| `data_dictionary.md` | Field-by-field guide, with links to the official dictionary |
| `data/` | The data, committed to the repo: complete tables where they are small enough, otherwise a sample (full files are downloaded with the module's scripts) |
| `notebooks/` | Two starter R Markdown notebooks with guided questions: `312_starter.Rmd` for ENVH 312 and `460_560_starter.Rmd` for ENVH 460/560 |
| `scripts/` | Scripts to fetch the full data and rebuild the sample |

## Modules

| Module | Scope | Source | Status |
| --- | --- | --- | --- |
| [BLS Census of Fatal Occupational Injuries (CFOI)](modules/us-bls-cfoi/) | US | BLS | Ready |
| [BLS Survey of Occupational Injuries and Illnesses (SOII)](modules/us-bls-soii/) | US | BLS | Ready |
| [Brazil SINAN work accidents and work-related diseases](modules/br-sinan-work-accidents/) | Brazil | Ministry of Health (DATASUS) | Ready |
| [Canada AWCBC work injury, disease and fatality statistics](modules/ca-awcbc-nwisp/) | Canada | AWCBC | Ready |
| [Eurostat accidents at work (ESAW)](modules/intl-eurostat-esaw/) | Europe | Eurostat | Ready |
| [Finland occupational accident statistics: accidents, causes and rates](modules/fi-statfin-work-accidents/) | Finland | Statistics Finland | Ready for review |
| [Global Burden of Disease: occupational risks](modules/intl-ihme-gbd-occupational/) (students download the data from IHME) | International | IHME | Draft (not yet tested on real data) |
| [ILOSTAT occupational safety and health](modules/intl-ilostat-osh/) | International | ILO | Ready |
| [Italy INAIL work injury reports and occupational disease claims](modules/it-inail-work-injuries/) | Italy | INAIL | Ready |
| [Japan fatal accident database: every work-related death since 1991](modules/jp-mhlw-fatal-accidents/) | Japan | MHLW | Ready |
| [Korea industrial accidents: microdata since 2017, national totals since 1964, and accident case descriptions](modules/kr-kosha-industrial-accidents/) | South Korea | KOSHA / Ministry of Employment and Labor | Ready |
| [MSHA mine safety: accidents, injury rates and violations](modules/us-msha-mine-safety/) | US | MSHA | Ready |
| [OSHA Chemical Exposure Health Data](modules/us-osha-chemical-exposure/) | US | OSHA | Ready |
| [OSHA enforcement: inspections, violations, cited standards and accident investigations](modules/us-osha-enforcement/) | US | OSHA | Ready |
| [OSHA ITA case detail (Forms 300/301)](modules/us-osha-ita-case-detail/) | US | OSHA | Ready |
| [OSHA ITA summary (Form 300A): establishment injury rates](modules/us-osha-ita-summary/) | US | OSHA | Ready |
| [OSHA Severe Injury Reports](modules/us-osha-severe-injury/) | US | OSHA | Ready |
| [Safe Work Australia fatalities and workers' compensation](modules/intl-safework-australia/) | Australia | Safe Work Australia | Ready |
| [UK HSE injury statistics (RIDDOR and LFS)](modules/uk-hse-riddor/) | Great Britain | HSE | Ready |
| [WHO/ILO Joint Estimates of the work-related burden of disease](modules/intl-who-ilo-joint-estimates/) | International | WHO / ILO | Ready |

See [CATALOG.md](CATALOG.md) for candidate datasets (US and international) and their status.

## Getting started (students)

1. Install [R](https://cran.r-project.org/) and [RStudio Desktop](https://posit.co/download/rstudio-desktop/)
   (or use [Posit Cloud](https://posit.cloud/) in a browser).
2. Download this repository (green **Code** button > **Download ZIP**, or clone it).
3. Open `install_packages.R` in RStudio and click **Source** (one time only).
4. Open a module folder and read its `README.md`.
5. Open the starter notebook for your course in the module's `notebooks/` folder:
   `312_starter.Rmd` (ENVH 312) or `460_560_starter.Rmd` (ENVH 460/560). It runs on the data
   committed to the repository; if a data file is missing on your computer, it reads it directly
   from GitHub.

## Notebooks by course (instructors)

Each module has two notebooks with the same data and setup:

| Notebook | Course | Contents |
| --- | --- | --- |
| `312_starter.Rmd` | ENVH 312 | Parts 1 to 5 (4 or 6 in a few modules): getting oriented, trends, comparisons, and interpreting what the data can show |
| `460_560_starter.Rmd` | ENVH 460/560 | The same parts, then two or three more on methods: rates and denominators, uncertainty, linking datasets, study design, and limitations |

Part numbers match between the two notebooks, so Part 3 is the same in both. Students answer the
questions under each **Your answer** heading and knit the notebook to HTML to submit.

## Where the large files live

GitHub limits browser uploads to 25 MB and git pushes to 100 MB per file, so full
datasets are **not** stored in the repo itself. Each module commits a small sample and
includes a script that downloads the full files from the official source.
See [docs/large-files.md](docs/large-files.md).

## Repository layout

```
CATALOG.md                 candidate datasets and status
docs/                      instructor and contributor notes
modules/
  _template/                    copy this to start a new module
  br-sinan-work-accidents/      Brazilian notifications of work accidents and diseases, incl. informal work
  ca-awcbc-nwisp/               Canadian accepted lost time claims and fatalities since 1982
  fi-statfin-work-accidents/    Finnish accidents at work and commuting by industry, with ESAW causes and rates
  intl-eurostat-esaw/           Eurostat accidents at work in Europe
  intl-ihme-gbd-occupational/   GBD deaths and DALYs from occupational risks (download from IHME)
  intl-ilostat-osh/             ILO injury and labour inspection statistics by country
  intl-safework-australia/      Australian work-related deaths and workers' compensation claims
  intl-who-ilo-joint-estimates/ deaths and DALYs from occupational risk factors, 183 countries
  it-inail-work-injuries/       every Italian work injury report and occupational disease claim, 2021 to 2025
  jp-mhlw-fatal-accidents/      every work-related death in Japan since 1991, with descriptions
  kr-kosha-industrial-accidents/ every approved industrial accident in South Korea since 2017, with rates
  uk-hse-riddor/                British reported and self-reported work injuries since 1974
  us-bls-cfoi/                  BLS counts and rates of fatal work injuries
  us-bls-soii/                  BLS rates of non-fatal work injuries and illnesses
  us-msha-mine-safety/          mine accidents, injury rates, employment and violations since 2000
  us-osha-chemical-exposure/    OSHA air, wipe and bulk sampling results
  us-osha-enforcement/          OSHA inspections, violations, penalties and accident investigations
  us-osha-ita-case-detail/      OSHA Injury Tracking Application case detail data
  us-osha-ita-summary/          OSHA Form 300A injury totals and hours for each establishment
  us-osha-severe-injury/        OSHA reports of amputations, hospitalizations and eye loss
install_packages.R         one-time R package setup
```

## Data sources and licensing

The code and written materials here are MIT licensed (see [LICENSE](LICENSE)).
The datasets belong to their publishers. US federal data are generally in the public
domain; international sources have their own terms, noted in each module README.
Always cite the original source.

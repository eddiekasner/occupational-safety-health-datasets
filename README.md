# Occupational Safety and Health Datasets

A collection of public occupational safety and health (OSH) datasets, organized as
self-contained teaching modules. Used in **ENVH 312** (undergraduate) and
**ENVH 460/560** (undergraduate/graduate).

Each module gives students:

| Piece | What it is |
| --- | --- |
| `README.md` | Background: who collects the data, why, what it can and cannot tell you |
| `data_dictionary.md` | Field-by-field guide, with links to the official dictionary |
| `data/` | A small sample committed to the repo; full files are downloaded separately |
| `notebooks/` | A starter R Markdown notebook with guided questions |
| `scripts/` | Scripts to fetch the full data and rebuild the sample |

## Modules

| Module | Scope | Source | Status |
| --- | --- | --- | --- |
| [OSHA ITA case detail (Forms 300/301)](modules/us-osha-ita-case-detail/) | US | OSHA | Ready |
| [OSHA Chemical Exposure Health Data](modules/us-osha-chemical-exposure/) | US | OSHA | Ready |
| [ILOSTAT occupational safety and health](modules/intl-ilostat-osh/) | International | ILO | Ready |
| [Eurostat accidents at work (ESAW)](modules/intl-eurostat-esaw/) | Europe | Eurostat | Ready |
| [OSHA Severe Injury Reports](modules/us-osha-severe-injury/) | US | OSHA | Ready |
| [BLS Census of Fatal Occupational Injuries (CFOI)](modules/us-bls-cfoi/) | US | BLS | Ready |
| [BLS Survey of Occupational Injuries and Illnesses (SOII)](modules/us-bls-soii/) | US | BLS | Ready for review |

See [CATALOG.md](CATALOG.md) for candidate datasets (US and international) and their status.

## Getting started (students)

1. Install [R](https://cran.r-project.org/) and [RStudio Desktop](https://posit.co/download/rstudio-desktop/)
   (or use [Posit Cloud](https://posit.cloud/) in a browser).
2. Download this repository (green **Code** button > **Download ZIP**, or clone it).
3. Open `install_packages.R` in RStudio and click **Source** (one time only).
4. Open a module folder and read its `README.md`.
5. Open the starter notebook (`notebooks/01_starter.Rmd`). It runs on the committed
   sample by default, and on the full data once you download it (instructions in each module).

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
  _template/               copy this to start a new module
  us-osha-ita-case-detail/ OSHA Injury Tracking Application case detail data
  us-osha-chemical-exposure/ OSHA air, wipe and bulk sampling results
  intl-ilostat-osh/        ILO injury and labour inspection statistics by country
  intl-eurostat-esaw/      Eurostat accidents at work in Europe
  us-osha-severe-injury/   OSHA reports of amputations, hospitalizations and eye loss
  us-bls-cfoi/             BLS counts and rates of fatal work injuries
  us-bls-soii/             BLS rates of non-fatal work injuries and illnesses
install_packages.R         one-time R package setup
```

## Data sources and licensing

The code and written materials here are MIT licensed (see [LICENSE](LICENSE)).
The datasets belong to their publishers. US federal data are generally in the public
domain; international sources have their own terms, noted in each module README.
Always cite the original source.

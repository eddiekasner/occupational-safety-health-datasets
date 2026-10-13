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
| `notebooks/` | A starter Jupyter notebook with guided questions |
| `scripts/` | Scripts to fetch the full data and rebuild the sample |

## Modules

| Module | Scope | Source | Status |
| --- | --- | --- | --- |
| [OSHA ITA case detail (Forms 300/301)](modules/us-osha-ita-case-detail/) | US | OSHA | Pilot, in progress |

See [CATALOG.md](CATALOG.md) for candidate datasets (US and international) and their status.

## Getting started (students)

1. Install Python 3.10+ and run `pip install -r requirements.txt`
   (or open a notebook in Google Colab, which already has these packages).
2. Open a module folder and read its `README.md`.
3. Open the starter notebook in `notebooks/`. It runs on the committed sample by
   default, and on the full data once you download it (instructions in each module).

## Where the large files live

GitHub limits browser uploads to 25 MB and git pushes to 100 MB per file, so full
datasets are **not** stored in the repo itself. They are attached to
[GitHub Releases](../../releases) (up to 2 GB per file) or downloaded from the
official source. See [docs/large-files.md](docs/large-files.md).

## Repository layout

```
CATALOG.md                 candidate datasets and status
docs/                      instructor and contributor notes
modules/
  _template/               copy this to start a new module
  us-osha-ita-case-detail/ OSHA Injury Tracking Application case detail data
requirements.txt
```

## Data sources and licensing

The code and written materials here are MIT licensed (see [LICENSE](LICENSE)).
The datasets belong to their publishers. US federal data are generally in the public
domain; international sources have their own terms, noted in each module README.
Always cite the original source.

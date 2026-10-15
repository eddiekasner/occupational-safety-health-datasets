# MSHA Mine Safety Data: Accidents, Injuries, Employment and Violations

**Scope:** United States (all coal and metal/nonmetal mines) | **Publisher:** US Department of
Labor, Mine Safety and Health Administration (MSHA) | **Years in this module:** calendar years
2000 to 2025 (individual accident reports 2015 to 2025)

## Background

The Federal Mine Safety and Health Act of 1977 (the Mine Act) created MSHA to enforce safety and
health standards at every mine in the US. Mining law differs from the OSH Act in ways that make
these data unusual:

- **Every mine is inspected.** MSHA must inspect every underground mine at least four times a
  year and every surface mine at least twice a year. OSHA, by contrast, reaches only a small share
  of workplaces.
- **Every injury and every hour is reported.** Under 30 CFR Part 50, mine operators and
  contractors must report every accident, injury and illness (MSHA Form 7000-1) and, every
  quarter, the hours their employees worked (Form 7000-2). So injury rates can be computed for the
  whole industry, for each commodity and part of a mine, and even for each mine.
- **Penalties are mandatory.** Every citation carries a proposed penalty.

After disasters at the Sago, Aracoma and Darby mines in 2006, Congress passed the **MINER Act**,
which raised penalties and required new emergency equipment. After the Upper Big Branch
explosion killed 29 miners in 2010, MSHA stepped up enforcement again.

MSHA publishes its data as weekly bulk files. This module covers four of them: accidents,
injuries and illnesses; quarterly employment and hours (from mine operators and from
contractors); mines; and violations.

## What one row represents

- `injury_summary`: hours worked, average employees, coal production and injuries for one year,
  worker type (mine operator's employees or contractors), coal or metal/nonmetal, and part of the
  mine (subunit); for mine operators, also one state and commodity.
- `fatalities` and `accidents`: one report of an accident, injury or illness (one person; an
  event that injures several miners has one report for each).
- `mines`: one mine.
- `mine_year`: one mine in one year (mine operator's employees only).
- `violation_summary`: a count of violations for one year and combination of mine and violation
  characteristics.
- `violation_standards`: a count of violations of one standard in one year.

## Why it matters for OSH

Mining has always been among the most dangerous industries, and mine disasters drove much of
US OSH law. Because MSHA collects both injuries and hours for every mine, students can compute
real injury rates, compare coal with metal/nonmetal mining and operators with contractors, see
how enforcement changed after disasters, and ask whether mines with more violations have more
injuries. The narratives show how miners are killed and what could have prevented it.

## Limitations to keep in mind

- **Self-reported injuries.** Mine operators and contractors report their own injuries. MSHA
  audits reports, but non-fatal injuries, especially minor ones, are under-reported. Some mines
  with many workers report none at all.
- **Contractors report hours nationally.** Contractors report hours worked by subunit and coal or
  metal/nonmetal, but not by mine, so contractor rates cannot be broken down by state, commodity
  or mine. In `injury_summary`, contractor rows have no state or commodity.
- **Current, not historical, mine details.** State, commodity and mine type come from MSHA's
  current record for each mine. A mine that changed commodity is counted under its current one.
- **Fatality counts.** The counts here include every report coded as a fatality. MSHA's official
  annual counts can differ slightly, because MSHA later decides whether some deaths are
  "chargeable" to mining. Deaths from natural causes (such as heart attacks) are coded separately
  and are not counted as fatalities.
- **Occupational disease.** Diseases with long latency, such as coal workers' pneumoconiosis
  (black lung) and silicosis, are rarely reported as occupational illnesses, because they appear
  years later, often after the miner has left the mine.
- **Short narratives.** Accident narratives are a few sentences at most (under 400 characters
  since 2015).
- **Penalties change.** Amounts paid are as of the download; recent violations may still be
  contested or unpaid. Penalties are not adjusted for inflation.
- **Office workers.** Rates in the notebooks leave out office workers at mine sites (subunit
  "Office workers at mine site"), as MSHA does.
- **2026 left out.** The source files include part of 2026; this module stops at 2025 so that
  every year is complete.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Tables, columns and codes |
| `data/tidy/injury_summary.csv.gz` | Hours, employees, coal production, fatalities, injuries and illnesses, 2000 to 2025 (complete) |
| `data/tidy/fatalities.csv.gz` | Every fatal injury, 2000 to 2025 (1,191), with narratives |
| `data/tidy/accidents.csv.gz` | Every accident, injury and illness report, 2015 to 2025 (70,710), with narratives |
| `data/tidy/mines.csv.gz` | Every mine (92,060), with location, type, status and commodity |
| `data/tidy/mine_year.csv.gz` | Hours, injuries, violations and penalties for each mine and year, 2000 to 2025 |
| `data/tidy/violation_summary.csv.gz` | All 3.0 million violations, 2000 to 2025, aggregated by their characteristics |
| `data/tidy/violation_standards.csv.gz` | The same violations, aggregated by the standard cited |
| `data/raw/` | MSHA files (not committed; about 2 GB unzipped) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the MSHA files |
| `scripts/build_dataset.R` | Builds the tables |

The tables were built from files downloaded in October 2026. Accident reports from 2000 to 2014
(other than fatalities) and individual violation records are too large for this repository; run
the scripts to get them.

## Official documentation

- [MSHA open government data](https://arlweb.msha.gov/OpenGovernmentData/OGIMSHA.asp) (the
  files and a definition file for each)
- [Mine Data Retrieval System](https://www.msha.gov/data-and-reports/mine-data-retrieval-system)
  (look up a single mine)
- [Fatality reports](https://www.msha.gov/data-and-reports/fatality-reports/search) (MSHA's
  investigation report for each death)
- [30 CFR Part 50](https://www.ecfr.gov/current/title-30/chapter-I/subchapter-M/part-50)
  (reporting of accidents, injuries, illnesses, employment and production)
- [Title 30 CFR, Chapter I](https://www.ecfr.gov/current/title-30/chapter-I) (MSHA standards)

## Licence

Works of the US federal government are in the public domain in the United States.

## Citation

US Department of Labor, Mine Safety and Health Administration. *MSHA open government data:
Accidents, Mines, MinesProdQuarterly, ContractorProdQuarterly and Violations files.* Downloaded
[date] from https://arlweb.msha.gov/OpenGovernmentData/OGIMSHA.asp

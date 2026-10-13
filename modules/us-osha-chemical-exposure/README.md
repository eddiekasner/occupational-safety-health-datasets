# OSHA Chemical Exposure Health Data

**Scope:** United States | **Publisher:** US Department of Labor, Occupational Safety
and Health Administration (OSHA) | **Years in this module:** samples analyzed 2013 to 2025

## Background

During inspections, OSHA compliance safety and health officers (CSHOs) often collect
industrial hygiene samples to measure workers' exposure to chemical hazards. Many of these
samples are sent to the **OSHA Technical Center (OTC)** laboratory in Utah for analysis. OSHA publishes the results, from 1984 onward, as the Chemical Exposure Health Data
(also called the "health samples" dataset).

The data include four kinds of samples:

| Type | What it measures |
| --- | --- |
| **Personal** | Air in the breathing zone of a specific worker, who wears the sampler |
| **Area** | Air at a fixed location |
| **Bulk** | The material itself (for example, the percentage of quartz in a dust) |
| **Wipe** | Contamination on a surface |

Results are compared against OSHA's **Permissible Exposure Limits (PELs)**, which are
usually set as 8-hour time-weighted averages (TWA) or ceiling limits.

## What one row represents

One **substance result** from one piece of sampling media. The identifiers nest:

```
inspection_number      one inspection of one establishment
  sampling_number      one exposure assessment (e.g. one worker, one day)
    field_number       one sampling medium (filter, tube, wipe) sent to the lab
      row              one substance measured on that medium
```

A single welding fume filter can be analyzed for a dozen metals, producing a dozen rows.

## Why it matters for OSH

These are real measurements of worker exposure, collected by trained professionals
using validated methods. They can show which industries and tasks produce high exposures
to lead, silica, hexavalent chromium and other hazards, and how often exposures exceed
legal limits.

## Limitations to keep in mind

- **Not a random sample of workplaces.** OSHA targets inspections through emphasis programs,
  complaints, referrals and accidents. Officers often sample the worst-case tasks.
- **Partial-shift samples.** Most samples cover only part of a shift, and media may be changed
  several times. A single result usually cannot be compared directly to an 8-hour PEL.
- **Non-detects.** Results below the lab's limit of quantitation are recorded as 0 with the
  qualifier `ND`. The limit itself is not reported.
- **Units vary.** The same substance can be reported in different units (for example,
  respirable quartz as a *percentage* of the dust under code 9010, but mixed respirable
  silica as an *air concentration* under code 9000). Always check `unit_of_measurement`.
- **Delayed release.** Results from open inspections and contested citations are withheld
  until the case closes, so recent years are incomplete.
- **Inconsistent files.** OSHA's yearly files change format from year to year.
  `scripts/build_dataset.R` handles this (see the comments at the top of that script).

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Field guide and code tables |
| `data/sample/chemical_exposure_sample.csv` | Every result from a random 10% of inspections (54,855 rows, 9 MB) |
| `data/raw/` | OSHA's yearly zip files (not committed) |
| `data/processed/` | The combined, cleaned table (not committed; built by `build_dataset.R`) |
| `notebooks/01_starter.Rmd` | Guided exploration for ENVH 312 and ENVH 460/560 |
| `scripts/fetch_data.R` | Downloads the yearly files from OSHA (about 25 MB) |
| `scripts/build_dataset.R` | Cleans and combines the yearly files |
| `scripts/make_sample.R` | Rebuilds the sample from the combined table |

## The data at a glance

| | Count |
| --- | --- |
| Results (rows), 2013 to 2025 | 571,504 |
| Inspections | 27,601 |
| Personal, non-blank results | 317,577 |
| Blank results | 121,788 |

Figures are from files downloaded in October 2026. OSHA updates the data each January and July.

## Getting the full data

In RStudio, open and **Source** these scripts in order:

1. `scripts/fetch_data.R` downloads the yearly zip files into `data/raw/`.
2. `scripts/build_dataset.R` writes `data/processed/chemical_exposure_2013_2025.csv` (about 96 MB).

Then set `use_full_data <- TRUE` in the notebook.

Years 1984 to 2012 are available from OSHA as XML files with a different layout. They are
not included in this module yet.

## Official documentation

- [Chemical Exposure Health Data page and downloads](https://www.osha.gov/opengov/health-samples)
- [Field definitions](https://www.osha.gov/opengov/osha-health-samples-dataset-field-definitions)
- [OSHA Annotated PELs tables](https://www.osha.gov/annotated-pels)
- [OSHA Chemical Database (sampling and analytical methods)](https://www.osha.gov/chemicaldata)

## Citation

US Department of Labor, Occupational Safety and Health Administration. *Chemical Exposure
Health Data, 2013 to 2025.* Downloaded [date] from https://www.osha.gov/opengov/health-samples

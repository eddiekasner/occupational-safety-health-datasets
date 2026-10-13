# Data Dictionary: OSHA Chemical Exposure Health Data

Adapted from OSHA's
[Dataset Field Definitions](https://www.osha.gov/opengov/osha-health-samples-dataset-field-definitions).
Column names are lower case in the processed file and the sample. OSHA calls the blank
field `Blank_Used` in its definitions (and in the 1984 to 2011 XML files); the CSV files
call it `blank_sample`, which is the name used here.

## Fields

| Field | Definition | Notes |
| --- | --- | --- |
| `inspection_number` | Unique identifier of the OSHA inspection | Links to OSHA enforcement data. A few are non-numeric (state plan or consultation formats) |
| `establishment_name` | Name of the sampled establishment | Not standardized: the same establishment may be spelled several ways |
| `city`, `state`, `zip_code` | Location of the inspection site | |
| `sic_code` | 1987 Standard Industrial Classification code | Recorded 1984 to 2011; blank afterward |
| `naics_code` | North American Industry Classification System code | First 2 digits = sector. Recorded from 2003 onward (blank before 2002) |
| `sampling_number` | Identifier for one exposure assessment | Several media (rows with different `field_number`) can share one sampling number, for example when filters are changed during a shift |
| `office_id` | OSHA office that collected the sample | |
| `date_sampled` | Date the sample was taken | Converted to YYYY-MM-DD |
| `date_reported` | Date results were released to the OSHA office | Converted to YYYY-MM-DD |
| `eight_hr_twa_calc` | Whether an 8-hour TWA calculation was used (Y/N) | Not recorded before 2005 |
| `instrument_type` | Laboratory instrument or method used for analysis | 1984 to 2011 only |
| `lab_number` | Laboratory's internal identifier | |
| `field_number` | Identifier for one sampling medium submitted for analysis | |
| `sample_type` | P = personal, A = area, B = bulk, W = wipe | Older years include rare undocumented codes (S, BL, BU, ...) |
| `blank_sample` | Is this a blank? Y/N | **Remove blanks before analyzing exposures** |
| `time_sampled` | Sampling time in minutes | |
| `air_volume_sampled` | Air volume sampled in liters | |
| `sample_weight` | Sample weight, for bulk and silica samples | |
| `imis_substance_code` | OSHA's code for the substance | Use the code, not the name, to filter |
| `substance` | Substance name | Mostly as listed in the OSHA PEL tables or ACGIH TLVs |
| `sample_result` | Laboratory result | Non-detects are recorded as 0. In older years they are often not flagged `ND` |
| `unit_of_measurement` | Unit of the result | See table below |
| `qualifier` | Result qualifier | See table below |
| `file_year` | Year of the OSHA file the row came from | Added by `build_dataset.R`. Mostly equals the year sampled |

## `unit_of_measurement`

| Code | Unit |
| --- | --- |
| M | mg/m³ |
| X | micrograms (total mass on the sample) |
| P | parts per million (ppm) |
| Y | milligrams |
| F | fibers/cc |
| % | percent (for example, percent quartz in a dust sample) |
| mcg/m3 | µg/m³ (used for mixed respirable silica, code 9000) |

Other codes (`N`, `E`, `BM/S`, `AAAAA`, ...) appear but are not documented by OSHA.

## `qualifier`

| Value | Meaning |
| --- | --- |
| *(blank)* | Detected, quantified result |
| ND | Not detected: below the limit of quantitation |
| BLK | Blank |
| ND-BLK | Blank, not detected |
| @ | Approximate |
| <=, =< | Less than or equal to |

Other values appear (for example `BLNK`, `BULK`, `WIPE`, `SER`, `MOIS`, `SEVR`, `COMB`, `POSI`);
OSHA does not document them.

## Substances used in the notebook

| Code | Substance | Unit used | OSHA PEL (8-hour TWA) | Action level |
| --- | --- | --- | --- | --- |
| 1591 | Lead, inorganic (as Pb) | M (mg/m³) | 50 µg/m³ | 30 µg/m³ |
| 9000 | Silica, crystalline, mixed respirable (2015 onward) | mcg/m3 or M | 50 µg/m³ | 25 µg/m³ |
| 0689 | Chromium (VI), TWA | M (mg/m³) | 5 µg/m³ | 2.5 µg/m³ |
| 9010 | Silica, crystalline quartz (respirable fraction) | % of dust | *(not an air concentration)* | |

## Useful definitions

- **TWA (time-weighted average)**: average concentration over a period, weighted by time.
  For several samples: TWA = Σ(Cᵢ × tᵢ) / total time. An 8-hour TWA divides by 480 minutes.
- **PEL (Permissible Exposure Limit)**: OSHA's legally enforceable exposure limit.
- **Action level**: a lower level (often half the PEL) that triggers requirements such as
  exposure monitoring and medical surveillance.
- **Geometric mean**: exp(mean(log(x))). Used because exposure data are usually lognormally distributed.

# Japan: Work-related Deaths, 1991 to 2024 (MHLW Fatal Accident Database)

**Scope:** Japan | **Publisher:** Ministry of Health, Labour and Welfare (MHLW, 厚生労働省),
Workplace Safety Site (職場のあんぜんサイト) | **Years in this module:** 1991 to 2024

## Background

Under Japan's Industrial Safety and Health Act, employers must report every death and every injury
causing four or more days off work to the Labour Standards Inspection Office (労働基準監督署),
using the Report of Workers' Deaths and Injuries (労働者死傷病報告). MHLW publishes every
work-related death since 1991 as a **fatal accident database (死亡災害データベース)**: one
row per person killed, with a short description of what happened, the industry, the size of the
workplace, the agent (the machine, structure or substance involved), and the type of accident.

Deaths at work in Japan fell from 2,489 in 1991 to 746 in 2024, the lowest on record. Construction
still accounts for nearly a third of them.

## What one row represents

One worker killed in a work-related accident. Several people killed in one event have one row each,
with the same description; `event_id` and `deaths_in_event` group them.

## Why it matters for OSH

- Every death for 34 years, with a narrative: few countries publish this.
- It shows a long, steady decline that students can compare with the US (CFOI module), Britain
  (RIDDOR) and others, and ask what explains it.
- It is a natural setting for the hierarchy of controls: falls, vehicles, machinery and heat.
- Japanese uses its own classification of industries, agents and accident types, which shows how
  classification choices shape what statistics can say.

## Limitations to keep in mind

- **Employees only.** The database covers deaths of workers covered by the Industrial Safety and
  Health Act. It leaves out the self-employed and family workers, most public servants, seafarers,
  and deaths from natural disasters (the 1995 Kobe and 2011 Tohoku earthquakes do not appear as
  spikes). Deaths from COVID-19 infection are excluded.
- **Injuries only, not disease.** Deaths from occupational diseases and from overwork (karoshi,
  過労死) are recognised separately through workers' compensation and are not here.
- **Counts, not rates.** The database has no employment figures. To compute rates, you need the
  number of workers from another source (for example the Labour Force Survey, 労働力調査).
- **Classifications.** Industries follow MHLW's own industry classification for labour statistics,
  not the Japan Standard Industrial Classification. Detailed industry groups are missing for many
  deaths before 1999. The time of day is recorded in 1-hour bands until 2018 and 2-hour bands from
  2019. Workplace size bands changed over time (see the data dictionary).
- **Short narratives.** Descriptions are usually one or two sentences. Searching them misses cases
  (for example, a search for heatstroke finds fewer deaths than MHLW's separate heatstroke
  statistics).
- **Language.** Descriptions and detailed categories are in Japanese. This module adds English
  labels for the main categories and English translations of the 2024 descriptions (see below).

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Columns and codes |
| `data/tidy/fatalities.csv.gz` | Every work-related death, 1991 to 2024 (49,326 rows) |
| `data/tidy/code_labels.csv` | English and Japanese labels for each industry, agent and accident type code |
| `data/tidy/narratives_en.csv` | English translations of the 2024 descriptions |
| `data/raw/` | MHLW's yearly Excel files and guide (not committed; about 22 MB) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/fetch_data.R` | Downloads the yearly files |
| `scripts/build_dataset.R` | Builds the tables |

Checked against MHLW's official count for 2024 (*令和6年における労働災害発生状況（確定）*): 746
deaths, 232 in construction, 142 in manufacturing, 108 in land freight transport, 188 falls from
height and 123 road traffic deaths, all matching this module exactly.

### English translations

The English labels for industries, agents and accident types are this module's translations of
MHLW's categories. The English narratives for 2024 (`narrative_en`) were machine-translated with
an AI model (Claude) for teaching use. They have not been checked by a professional translator and
are not official. For other years, use a translation tool on the Japanese text if needed, and
treat the Japanese as authoritative.

## Official documentation

- [Fatal accident database (死亡災害データベース)](https://anzeninfo.mhlw.go.jp/anzen_pg/SIB_FND.html)
- [Workplace Safety Site: occupational accident statistics (労働災害統計)](https://anzeninfo.mhlw.go.jp/user/anzen/tok/toukei_index.html)
- [MHLW occupational accident statistics (労働災害発生状況)](https://www.mhlw.go.jp/bunya/roudoukijun/anzeneisei11/rousai-hassei/)
- MHLW's guide to the database (データベース使用方法, Word, in Japanese) is in `data/raw/` after
  running `fetch_data.R`.

## Licence

MHLW's website content may be reused under the
[Public Data License version 1.0 (PDL1.0)](https://www.mhlw.go.jp/chosakuken/index.html), which is
compatible with CC BY 4.0: credit the source, and say that you edited it if you did. The
Workplace Safety Site is run by MHLW and does not state separate terms. This module translated
labels into English, combined the yearly files and added derived columns.

## Citation

Source: Ministry of Health, Labour and Welfare, Workplace Safety Site, fatal accident database
(厚生労働省 職場のあんぜんサイト 死亡災害データベース),
https://anzeninfo.mhlw.go.jp/anzen_pg/SIB_FND.html (accessed October 2026). Combined, coded in
English and partly translated by the authors of this repository.

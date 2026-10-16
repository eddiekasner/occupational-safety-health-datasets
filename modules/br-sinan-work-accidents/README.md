# Brazil: Work Accidents and Work-related Diseases Notified to SINAN

**Scope:** Brazil | **Publisher:** Ministry of Health (Ministério da Saúde), DATASUS |
**Years in this module:** notifications from 2006 to 2025

## Background

Brazil's **Notifiable Diseases Information System (SINAN, Sistema de Informação de Agravos de
Notificação)** collects reports of diseases and conditions that health services must notify.
Among them are eight **work-related conditions** (agravos relacionados ao trabalho), which the
health system's Workers' Health network (RENAST, with its regional reference centres, CEREST)
investigates:

| Condition | Who notifies |
| --- | --- |
| **Work accident** (acidente de trabalho) | Any health service. Until early 2023 only *serious* work accidents had to be notified (fatal, causing mutilation, or involving workers under 18); since Ministry of Health Ordinance GM/MS 217 of March 2023, all work accidents must be |
| Exposure to biological material at work (for example needlestick injuries) | Any health service |
| Repetitive strain injury and work-related musculoskeletal disorder (LER/DORT) | Sentinel services |
| Noise-induced hearing loss (PAIR) | Sentinel services |
| Occupational dermatosis | Sentinel services |
| Pneumoconiosis | Sentinel services |
| Work-related cancer | Sentinel services |
| Work-related mental disorder | Sentinel services |

What makes SINAN unusual is that it comes from the **health system**, not from employers or
insurers. It covers every worker who seeks care, whether or not they have a formal job. Brazil's
other main source, the CAT (Comunicação de Acidente de Trabalho) reported to the social security
institute (INSS), covers only formally registered employees, while roughly two in five Brazilian
workers are informal.

## Where the data come from

SINAN's case-level files are published as `.dbc` files on DATASUS's FTP server, which many networks
cannot reach and which reportedly limits downloads from outside Brazil. This module instead uses
**TabNet**, DATASUS's web tool that tabulates the same records: `fetch_data.R` asks TabNet for
about 170 two-way tables and `build_dataset.R` combines them. So the module has **counts**, not
individual cases.

## What one row represents

A number of notifications for one year and one or two characteristics, for example "work
accidents notified in 2023 for unregistered employees whose outcome was death from the accident".

## Why it matters for OSH

- It is one of the few sources anywhere that counts injuries among **informal workers**, and it
  records each worker's employment status, so students can compare formal and informal work.
- The variable "CAT issued" shows how many injured workers were also reported to social security:
  a direct measure of under-reporting in the official compensation statistics.
- The huge rise in notifications (from about 20,000 in 2007 to 646,000 in 2025) is mostly the
  result of changes in **surveillance**, not in risk: a lesson in reading trends.
- Motorcycle couriers, construction labourers, health care workers and agricultural workers all
  appear in large numbers, as in many middle-income countries.

## Limitations to keep in mind

- **Notifications, not incidence.** A case is counted only if a worker sought care at a health
  service that notified it. Notification depends on local surveillance capacity, which varies a
  great deal between states and municipalities and has grown over time. Do not read changes over
  time or differences between states as changes in risk without thinking about this.
- **Definition changed in 2023.** Before 2023 the work accident form was for serious accidents; from
  2023 it covers all work accidents. Notifications were already rising steeply before then (they
  more than doubled from 2019 to 2022), so the outcome mix changes gradually rather than all at once.
- **Sentinel conditions** (all except work accidents and biological exposure) are notified mainly
  by sentinel services, so their counts reflect where those services exist.
- **Many unknowns.** Industry (CNAE) is unknown for over half of work accident notifications, and
  employment status, education and outcome are often missing. Missingness itself changes over
  time.
- **Recent years.** SINAN data are revised for several years after notification; 2024 and 2025
  may still change. 2006 is incomplete (the SINAN Net system was being introduced).
- **Counts only.** The module has no denominators. To compute rates, you need the number of workers,
  for example from IBGE's continuous household survey (PNAD Contínua).
- **Year.** Counts are by year of notification, not of the accident.
- **TabNet's groupings.** Categories are TabNet's; for example, causes are ICD-10 external cause codes
  that this module groups into ICD-10 blocks in English.

## Files

| Path | Contents |
| --- | --- |
| `data_dictionary.md` | Tables, columns and categories |
| `data/tidy/accidents_by_year.csv.gz` | Work accidents by year and one characteristic at a time |
| `data/tidy/accidents_crosstabs.csv.gz` | Work accidents by year and pairs of characteristics |
| `data/tidy/accidents_occupation_industry.csv.gz` | Work accidents, deaths and permanent disabilities by occupation and by industry, 2006 to 2025 |
| `data/tidy/other_conditions.csv.gz` | The seven other work-related conditions by year and state, sex, age, employment status and occupation |
| `data/raw/tabnet/` | The tables downloaded from TabNet (not committed) |
| `notebooks/312_starter.Rmd` | Guided exploration for ENVH 312 |
| `notebooks/460_560_starter.Rmd` | Guided exploration for ENVH 460/560 (includes the ENVH 312 parts plus more advanced ones) |
| `scripts/tabnet.R` | Functions for querying TabNet from R |
| `scripts/fetch_data.R` | Downloads the tables from TabNet (needs the `curl` package) |
| `scripts/build_dataset.R` | Builds the tidy tables, with English labels |

The tables were downloaded from TabNet in October 2026.

## Official documentation

- [TabNet: work accident notifications (Acidente de Trabalho)](https://tabnet.datasus.gov.br/cgi/deftohtm.exe?sinannet/cnv/acgrbr.def),
  and the other work-related conditions from the
  [DATASUS SINAN page](https://datasus.saude.gov.br/acesso-a-informacao/doencas-e-agravos-de-notificacao-de-2007-em-diante-sinan/)
- [Portal SINAN](https://portalsinan.saude.gov.br/) (notification forms and instructions, in
  Portuguese)
- Ministry of Health Ordinance GM/MS 217 of 1 March 2023 (notification of work accidents)

## Licence

SINAN tabulations are public information published by the Brazilian Ministry of Health; no
restriction on reuse is stated. Cite the source as below.

## Citation

Brasil, Ministério da Saúde, Sistema de Informação de Agravos de Notificação (SINAN Net), via
DATASUS TabNet, https://tabnet.datasus.gov.br (accessed October 2026). Tabulated and translated by
the authors of this repository.

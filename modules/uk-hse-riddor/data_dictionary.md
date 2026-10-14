# Data Dictionary: UK HSE RIDDOR and LFS

Built by `scripts/build_dataset.R` from the HSE Excel tables. Each row is one published number.

## Shared RIDDOR columns

| Column | Meaning |
| --- | --- |
| `period` | Reporting year. From 1986/87, years run 1 April to 31 March (`2024/25`); before that, calendar years (`1981`) |
| `year` | The year the period ends, as a number (`2024/25` gives 2025) |
| `status` | `final`, `revised` (finalised this release) or `provisional` (latest year; will change) |
| `worker_group` | `Workers` (employees and self-employed), `Employees`, `Self-employed`, or `Members of the public` (people killed by someone else's work activity) |
| `injury_type` | See below |
| `measure` | `count`, `rate_per_100000` (per 100,000 people in `worker_group`), or `share` (proportion of the total for that industry, from 0 to 1) |
| `value` | The published number |
| `flag` | Why `value` is missing: `u` = rate unavailable (employment estimate unreliable, or self-employed under-reporting), `x` = not available, `z` = not applicable, `k` = share less than 1% |

### `injury_type`

| Value | Meaning |
| --- | --- |
| `Fatal` | Death from a work-related injury |
| `Specified` | A listed serious injury (most fractures, amputations, serious burns, loss of sight, and others); "major" injuries before October 2013 |
| `Over-7-day` | Off work more than 7 consecutive days (not counting the day of the injury); reportable from April 2012 |
| `Over-3-day` | Off work more than 3 days; reportable from 1986/87 to 2011/12 |
| `All non-fatal` | Specified (or major) plus over-7-day (or over-3-day) injuries |

Non-fatal injuries are reported for employees; injuries to the self-employed are so under-reported
that HSE gives rates for them only in the historical table, and not in recent years.

## `riddor_history.csv`

| Column | Meaning |
| --- | --- |
| `industry` | Broad industry group. Definitions changed with the industry classification; see `industry_classification` |
| `regulations` | Regulations in force: `a` 1974 to 1980 various (not all injuries were reportable); `b` 1981 to 1985 NADOR (only major injuries); `c` 1986/87 to 1995/96 RIDDOR 1985 (over-3-day added); `d` 1996/97 to 2011/12 RIDDOR 1995; `e` 2012/13 RIDDOR 2012 (over-7-day threshold); `f` 2013/14 RIDDOR 2012 then 2013; `g` 2014/15 onward RIDDOR 2013 ("specified" injuries) |
| `industry_classification` | `h` 1974 to 1980 by regulation; `i` SIC 1980; `j` SIC 1992; `k` SIC 1992 for rates and SIC 2007 for counts; `l` SIC 2007 |
| `rate_denominator_source` | Source of employment numbers for rates: `m` no rates; `n` ONS Workforce Jobs (1981 to 2003/04); `o` Annual Population Survey (2004/05 onward) |

Members of the public are counted from 1981. From 1996/97 to 2013/14 their deaths include deaths
on railways, including suicides and trespassers, which made up about three quarters of deaths of
members of the public in service industries.

## `riddor_industry.csv.gz`

| Column | Meaning |
| --- | --- |
| `sic_level` | `All`, `Section` (letter, for example `F (41-43)` Construction) or `Division` (2 digits) |
| `sic_code` | UK SIC 2007 code; for sections, the divisions they contain are in brackets |
| `industry` | Industry name |

Filter on one `sic_level` to avoid double counting.

## `riddor_kind.csv.gz` and `riddor_age_gender.csv.gz`

| Column | Meaning |
| --- | --- |
| `sic_section` | SIC 2007 section (`A-U` = all industries; some sections are combined, for example `J-N`) |
| `main_industry` | Section name |
| `accident_kind` | Kind of accident (for example `Falls from a height`); `All accident kinds` = total |
| `gender` | `All`, `Male`, `Female`, `Identify in another way`, `Unknown` |
| `age_group` | `All`, `Under 16`, `16-19`, `20-24`, `25-34`, `35-44`, `45-54`, `55-59`, `60-64`, `65+`, `Unknown` |

In `riddor_kind`, `share` is the proportion of the industry's injuries of that kind.

## `riddor_nature_site.csv`

| Column | Meaning |
| --- | --- |
| `breakdown` | `nature of injury` (for example fracture, amputation) or `site of injury` (body part) |
| `body_region` | For site of injury: the region (`All injuries to head locations`, ..., `General locations`) |
| `category` | Nature of injury, or body region or part |
| `level` | `0` = all injuries, `1` = nature of injury or body region, `2` = body part |

Some natures apply only to specified or only to over-7-day injuries (`flag` = `z`).

## `riddor_region.csv.gz`

| Column | Meaning |
| --- | --- |
| `area_type` | `Country`, `Region`, `County`, `UA` (unitary authority), `LA` (local authority district) |
| `area_code` | ONS geography code (9 characters, for example `E92000001` = England) |
| `area` | Area name. Injuries are assigned to where they happened |

Areas at different types overlap (for example, England contains its regions). Filter on one `area_type`.

## `riddor_fatal_latest.csv`

Deaths for 2021/22 to 2025/26, one year newer than the other RIDDOR tables.

| Column | Meaning |
| --- | --- |
| `period_length` | `1 year`, or `5-year total` (`2021/22 - 2025/26`); 5-year rates are annual averages |
| `breakdown` | `industry`, `kind of accident`, `age group`, or `country and region` |
| `category` | Category name. Industry rows starting with `- of which` are part of the row above |
| `area_code`, `area_type` | For `country and region` |

## `lfs_injury.csv.gz`: Labour Force Survey

Estimates of injuries in workplace accidents (excluding road traffic accidents) reported by people
who worked in the last 12 months. If someone had more than one accident, only the most recent counts.

| Column | Meaning |
| --- | --- |
| `source` | Source workbook and table (for example `lfsinjind Table-1`) |
| `breakdown` | `all`, `industry`, `occupation`, `kind of accident`, `nature of injury`, `age and gender`, `country and region`, `workplace size` |
| `injury_type` | `All workplace injuries`, `Over-3-day absence`, `Over-7-day absence` (consecutive calendar days off, not counting the day of the accident) |
| `period_length` | `Annual` (summary only), `3 year` or `5 year` average |
| `period` | Years covered, for example `2022/23 - 2024/25`. Some periods skip 2020/21 for days lost (not collected) |
| `year` | Last year of the period, as a number |
| `level` | Level of the breakdown, for example `Section`, `Division`, `Group`, `Class` (industry, SIC 2007); `Major` to `Unit` (occupation, SOC); `Age`, `Gender`, `Age - Gender`; `Country`, `Region` |
| `code` | SIC, SOC or area code |
| `category` | Category name |
| `measure` | `injuries_thousands`, `rate_per_100000_workers`, `days_lost_thousands` (full-day equivalents), `days_lost_per_worker` (per full-time equivalent worker), `days_lost_per_case` |
| `estimate`, `ci_lower`, `ci_upper` | Estimate and 95% confidence interval |
| `flag` | `U1` = sample too small for a reliable estimate (estimate missing) |
| `sig_vs_all` | Is the rate statistically different from all workers? `Higher`, `Lower`, `No`, or `U2` (comparison not possible) |
| `sig_vs_previous` | Is the rate statistically different from the previous period? |
| `low_sample` | `TRUE` if based on few sample cases (20 to 29 for injuries, 20 to 39 for days lost): interpret with caution |

Detailed industries and occupations (`Group`, `Class`, `Minor`, `Unit`) with no estimate (`U1`)
are left out of this file.

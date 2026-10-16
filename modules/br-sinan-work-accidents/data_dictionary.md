# Data Dictionary: SINAN Work-related Notifications (Brazil)

Built by `scripts/build_dataset.R` from DATASUS TabNet tables. Counts are numbers of
**notifications**, by **year of notification**. Every table has the English category
(`category`, `row_category`, `col_category`) and TabNet's Portuguese label (`..._pt`).

## Work accidents by year (`accidents_by_year.csv.gz`)

| Column | Meaning |
| --- | --- |
| `variable` | The characteristic (see below) |
| `category`, `category_pt` | Its value, in English and in Portuguese |
| `year` | Year of notification |
| `notifications` | Number of work accident notifications |

For each `variable`, the counts add up to the same yearly total. TabNet leaves out records whose
code is not in its list for a variable; this module adds them as the category `Not listed by
TabNet` (with a blank `category_pt`). This matters most for `industry` (about a third of
notifications from 2021 on) and `hours_into_shift` (about 8%).

## Work accidents by pairs of characteristics (`accidents_crosstabs.csv.gz`)

`year`, `row_variable`, `row_category`, `col_variable`, `col_category` (and the Portuguese labels),
`notifications`. Pairs included: employment status by outcome, by CAT issued and by sex; state by
outcome; accident type by outcome; sex by outcome.

## Occupation and industry (`accidents_occupation_industry.csv.gz`)

All notifications from 2006 to 2025 together.

| Column | Meaning |
| --- | --- |
| `variable` | `occupation` (Brazilian Classification of Occupations, CBO, 6-digit code) or `industry` (National Classification of Economic Activities, CNAE, 5-digit code, as listed by TabNet) |
| `code`, `label_pt` | Code and Portuguese title |
| `notifications` | Work accident notifications |
| `deaths` | Of which the outcome was death from the accident |
| `permanent_disability` | Of which the outcome was permanent partial or total disability |

## Other work-related conditions (`other_conditions.csv.gz`)

`condition`, `variable`, `category`, `category_pt`, `year`, `notifications`, for:
exposure to biological material at work; repetitive strain injury and work-related musculoskeletal
disorder (LER/DORT); noise-induced hearing loss (PAIR); occupational dermatosis; pneumoconiosis;
work-related cancer; work-related mental disorder. Variables: `state` (of notification), `sex`,
`age_group`, `employment_status` and `occupation`, where TabNet offers them.

## Variables

| Variable | Meaning | Categories |
| --- | --- | --- |
| `employment_status` | The worker's situation in the labour market (situação no mercado de trabalho) | Registered employee (formal, with a signed work card); Unregistered employee (informal); Self-employed; Public servant (statutory); Public employee (labour-law contract); Temporary worker; Casual worker (avulso, for example dockers hired through a pool); Cooperative member; Employer; Retired; Unemployed; Other; Unknown |
| `sex` | | Male, Female, Unknown |
| `age_group` | Age in years | Under 1, 1-4, ..., 80+ (ages under 14 are mostly child labour or recording errors) |
| `race` | Race or colour, self-reported in IBGE categories | White, Black, Mixed (parda), East Asian (amarela), Indigenous, Unknown |
| `education` | Highest schooling | From No schooling to Higher education complete |
| `state` | State where the accident happened (work accidents) or was notified (other conditions), with its IBGE code | 27 states; "Unknown" includes accidents abroad |
| `occupation` | CBO occupation, code and Portuguese title | About 2,500 occupations |
| `industry` | CNAE economic activity of the employer, code and Portuguese title | Unknown for most notifications |
| `accident_type` | | Typical (at work), Commuting, Unknown |
| `outcome` | Evolution of the case (evolução) | Recovered; Temporary disability; Permanent partial disability; Permanent total disability; Death from the accident; Death from other causes; Other; Unknown |
| `cat_issued` | Whether a CAT (work accident report to social security, INSS) was issued | Yes, No, Not applicable (the worker is not covered by INSS work accident insurance, for example informal or self-employed), Unknown |
| `body_part` | Main part of the body injured | Hand, Upper limb, Lower limb, Foot, Head, Eye, Neck, Thorax, Abdomen, Whole body, Other, Unknown |
| `cause` | External cause of the injury, as an ICD-10 code (V01 to Y98), grouped into ICD-10 blocks | For example "Transport accidents (V01-V99)", "Falls (W00-W19)", "Exposure to inanimate mechanical forces (W20-W49)". Y96 ("work-related condition") is often coded instead of a specific cause. The Portuguese label in `category_pt` has the code and its title |
| `outsourced` | Whether the worker was employed by an outsourced (subcontracted) company | Yes, No, Not applicable, Unknown |
| `hours_into_shift` | Hours since the start of the working day when the accident happened | 1 to 24, Unknown |
| `medical_care` | Whether the worker received medical care | Yes, No, Unknown |

## Rates

The tables have no denominators. Population and employment by state, sex, age and employment status
can be taken from IBGE's PNAD Contínua (https://www.ibge.gov.br) to compute rates, keeping in mind
that notifications are not a complete count of accidents.

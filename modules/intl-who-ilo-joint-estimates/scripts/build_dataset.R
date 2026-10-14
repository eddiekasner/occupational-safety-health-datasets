# Build tidy tables from the WHO/ILO Joint Estimates exports.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads the CSV files exported from the WHO/ILO Occupational Burden of Disease application
# (see fetch_data.R) in data/raw/ and writes to data/tidy/:
#   burden_global_regional.csv.gz  deaths and DALYs by risk factor, disease, WHO region (and
#                                  global), sex and 5-year age group, 2000, 2010 and 2016
#   burden_country.csv.gz          the same for 183 countries, for ages 15 and over (15+ years)
#   exposure.csv.gz                number and percentage of people exposed to long working hours
#                                  and to solar UV radiation at work (regions and global by age;
#                                  countries for ages 15+)
#   disease_death_rate.csv.gz      deaths from all work-related diseases per 100,000 population
#                                  (the summary indicator; same levels as exposure.csv.gz)
#
# Each export has one row per estimate type (Point, Lower, Upper). Here they become columns:
# number, number_lower, number_upper, rate, rate_lower, rate_upper.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
})

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
raw_dir <- file.path(module_dir, "data", "raw")
tidy_dir <- file.path(module_dir, "data", "tidy")
dir.create(tidy_dir, recursive = TRUE, showWarnings = FALSE)

burden_files <- list.files(raw_dir, pattern = "^Estimate_Burden_of_Disease_.*\\.csv$", full.names = TRUE)
if (!length(burden_files)) stop("No exports in ", raw_dir, ". See fetch_data.R.")

read_export <- function(path) {
  read_csv(path, col_types = cols(.default = col_character()), na = c("NA", ""),
           progress = FALSE) |>
    rename(any_of(c(risk_factor = "Risk Factor", year = "Year", region = "Region",
                    country = "Country", sex = "Sex", age_group = "Age group", cause = "Cause",
                    measure = "Measure", estimate = "Estimate",
                    # Despite its name, this column holds whole DALYs (not thousands); see README
                    number = "Number (for DALYs in 1000s)", number = "Number",
                    rate = "Rate (per 100,000 of population)", percent = "Percentage (%)")))
}

# Shared clean-up; the Point, Lower and Upper rows become columns
tidy_export <- function(d, value_cols) {
  d |>
    mutate(year = as.integer(year),
           across(all_of(value_cols), as.numeric),
           # The application labels the WHO South-East Asia Region "South-East Pacific"
           region = recode(region, "South-East Pacific" = "South-East Asia"),
           # The solar UV estimates (2023) use the country's current name
           country = recode(country, "Turkey" = "T\u00fcrkiye"),
           # Plain-text age labels ("\u226515 years" -> "15+ years") so they compare reliably
           # whatever the computer's language settings
           age_group = str_replace(age_group, "\u2265(\\d+) years", "\\1+ years"),
           estimate = recode(estimate, "Point" = "", "Lower" = "_lower", "Upper" = "_upper"),
           level = case_when(region == "Global" ~ "global", is.na(country) ~ "region",
                             TRUE ~ "country")) |>
    pivot_wider(names_from = estimate, values_from = all_of(value_cols),
                names_glue = "{.value}{estimate}")
}

burden <- bind_rows(lapply(burden_files, read_export)) |>
  mutate(measure = recode(measure, "Deaths" = "deaths", "Disability-adjusted life years" = "dalys")) |>
  tidy_export(c("number", "rate")) |>
  select(level, region, country, year, sex, age_group, risk_factor, cause, measure,
         number, number_lower, number_upper, rate, rate_lower, rate_upper) |>
  arrange(level, region, country, risk_factor, cause, measure, year, sex, age_group)

stopifnot(!anyNA(burden$year), !anyNA(burden$cause), !anyNA(burden$measure))

# --- Checks against the 2021 global monitoring report ------------------------------------------

check <- function(..., expected) {
  got <- filter(burden, level == "global", sex == "Both", age_group == "15+ years", ...)$number
  if (length(got) != 1 || abs(got - expected) > 0.5) {
    stop("Check failed: expected ", expected, ", got ", paste(got, collapse = ", "))
  }
}
check(risk_factor == "Exposure to long working hours", cause == "Stroke", measure == "deaths",
      year == 2016, expected = 398306)
check(risk_factor == "Exposure to long working hours", cause == "Ischaemic heart disease",
      measure == "deaths", year == 2000, expected = 244844)

# All 2016 deaths except solar UV radiation (added in 2023) = 1,879,890 in the report
total_2016 <- burden |>
  filter(level == "global", sex == "Both", age_group == "15+ years", year == 2016,
         measure == "deaths", risk_factor != "Occupational exposure to solar ultraviolet radiation") |>
  summarise(n = sum(number, na.rm = TRUE)) |>
  pull(n)
stopifnot(abs(total_2016 - 1879890) <= 5)

# --- Exposure and the summary indicator --------------------------------------------------------

exposure <- bind_rows(lapply(list.files(raw_dir, "^Estimate_Exposure_.*\\.csv$", full.names = TRUE),
                             read_export)) |>
  tidy_export(c("number", "percent")) |>
  select(level, region, country, year, sex, age_group, risk_factor,
         number, number_lower, number_upper, percent, percent_lower, percent_upper)

disease_rate <- bind_rows(lapply(list.files(raw_dir, "^Indicator_.*\\.csv$", full.names = TRUE),
                                 read_export)) |>
  tidy_export("rate") |>
  select(level, region, country, year, sex, age_group, rate, rate_lower, rate_upper)

stopifnot(nrow(exposure) > 0, nrow(disease_rate) > 0)

# Countries: ages 15+ only, to keep the files small
countries_15plus <- function(d) filter(d, level != "country" | age_group == "15+ years")

# --- Write ----------------------------------------------------------------------------------------

global_regional <- filter(burden, level != "country") |> select(-country)
country <- filter(burden, level == "country", age_group == "15+ years") |>
  select(-level, -age_group)

write_csv(global_regional, file.path(tidy_dir, "burden_global_regional.csv.gz"), na = "")
write_csv(country, file.path(tidy_dir, "burden_country.csv.gz"), na = "")
write_csv(countries_15plus(exposure), file.path(tidy_dir, "exposure.csv.gz"), na = "")
write_csv(countries_15plus(disease_rate), file.path(tidy_dir, "disease_death_rate.csv.gz"), na = "")
message("burden_global_regional: ", nrow(global_regional), " rows; burden_country: ",
        nrow(country), " rows; exposure: ", nrow(countries_15plus(exposure)),
        " rows; disease_death_rate: ", nrow(countries_15plus(disease_rate)), " rows")

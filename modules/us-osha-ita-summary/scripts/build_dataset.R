# Build tidy OSHA ITA Form 300A summary tables from the files downloaded by fetch_data.R.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads the yearly files in data/raw/ and writes:
#   data/tidy/establishments_<year>.csv.gz  one row per establishment for each year 2016 to 2025
#                                           (every establishment that submitted)
#   data/tidy/summary_by_industry.csv.gz    totals by year, industry sector, state, size and
#                                           ownership (complete)
#
# Cleaning:
#   - When an establishment submitted more than once for a year (usually a correction), only its
#     latest submission is kept.
#   - Codes are translated to labels, NAICS codes and ZIP codes are tidied, and text that is not
#     valid UTF-8 (in the 2018 file) is converted from Windows-1252.
#   - Nothing is deleted for implausible values. Instead `plausible` flags records with more than
#     0 and at most 50,000 employees and between 250 and 8,760 hours worked per employee (8,760
#     is the number of hours in a year).
#   - To keep the repository small, street addresses and the employer's own industry description
#     are left out. Set `include_text <- TRUE` below to keep them.

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

include_text <- FALSE  # TRUE keeps street_address and industry_description

files <- list.files(raw_dir, pattern = "^ITA.*\\.(zip|csv)$", full.names = TRUE)
if (!length(files)) stop("No ITA files in ", raw_dir, ". Run fetch_data.R first.")

naics_sectors <- c(
  "11" = "Agriculture, forestry, fishing and hunting", "21" = "Mining, oil and gas extraction",
  "22" = "Utilities", "23" = "Construction", "31" = "Manufacturing", "32" = "Manufacturing",
  "33" = "Manufacturing", "42" = "Wholesale trade", "44" = "Retail trade", "45" = "Retail trade",
  "48" = "Transportation and warehousing", "49" = "Transportation and warehousing",
  "51" = "Information", "52" = "Finance and insurance", "53" = "Real estate and rental and leasing",
  "54" = "Professional, scientific and technical services",
  "55" = "Management of companies and enterprises",
  "56" = "Administrative, support and waste management services", "61" = "Educational services",
  "62" = "Health care and social assistance", "71" = "Arts, entertainment and recreation",
  "72" = "Accommodation and food services", "81" = "Other services",
  "92" = "Public administration")

# Submission times are written in several formats across the years
parse_time <- function(x) {
  x <- str_squish(x)
  out <- as.POSIXct(x, format = "%m/%d/%Y %H:%M:%S", tz = "UTC")
  for (fmt in c("%m/%d/%Y %H:%M", "%m/%d/%Y", "%d%b%y:%H:%M:%S")) {
    miss <- is.na(out)
    out[miss] <- as.POSIXct(x[miss], format = fmt, tz = "UTC")
  }
  out
}
num <- function(x) suppressWarnings(as.numeric(x))

read_year_file <- function(path) {
  message("reading ", basename(path))
  d <- read_csv(path, col_types = cols(.default = col_character()), progress = FALSE,
                name_repair = \(n) tolower(str_remove(n, "^﻿")))
  if (nrow(problems(d))) stop("Could not read ", nrow(problems(d)), " lines of ", path)
  d |>
    rename(any_of(c(created_timestamp = "date_submitted"))) |>
    mutate(across(everything(), \(x) {
      bad <- !is.na(x) & !validUTF8(x)
      x[bad] <- iconv(x[bad], "windows-1252", "UTF-8", sub = " ")
      na_if(str_squish(x), "")
    }),
    row_in_file = row_number())
}

raw <- bind_rows(lapply(files, read_year_file))

est <- raw |>
  mutate(year = as.integer(num(year_filing_for)),
         submitted = parse_time(created_timestamp)) |>
  filter(!is.na(year), !is.na(establishment_id)) |>
  # Keep each establishment's latest submission for the year (ties: the later row in the file)
  arrange(year, establishment_id, submitted, row_in_file) |>
  group_by(year, establishment_id) |>
  slice_tail(n = 1) |>
  ungroup()

naics <- str_remove(est$naics_code, "\\.0+$")
est <- est |>
  transmute(
    establishment_id, year,
    establishment_name, company_name, ein = str_remove_all(ein, "[^0-9]"),
    street_address, city, state = str_to_upper(state),
    zip_code = str_pad(str_extract(zip_code, "^[0-9]{3,5}"), 5, pad = "0"),
    naics_code = if_else(str_detect(naics, "^[0-9]{6}$"), naics, NA_character_),
    naics_year = as.integer(num(naics_year)),
    naics_sector = unname(naics_sectors[str_sub(naics_code, 1, 2)]),
    industry_description,
    ownership = recode(establishment_type, "1" = "Private", "2" = "State government",
                       "3" = "Local government", .default = NA_character_),
    size = case_when(num(size) == 1 ~ "Under 20", num(size) %in% c(2, 21, 22) ~ "20-249",
                     num(size) == 3 ~ "250+"),
    size_detail = case_when(num(size) == 21 ~ "20-99", num(size) == 22 ~ "100-249"),
    annual_average_employees = num(annual_average_employees),
    total_hours_worked = num(total_hours_worked),
    any_cases = case_when(num(no_injuries_illnesses) == 1 ~ TRUE,
                          num(no_injuries_illnesses) == 2 ~ FALSE),
    deaths = num(total_deaths),
    dafw_cases = num(total_dafw_cases),
    djtr_cases = num(total_djtr_cases),
    other_cases = num(total_other_cases),
    dafw_days = num(total_dafw_days),
    djtr_days = num(total_djtr_days),
    injuries = num(total_injuries),
    skin_disorders = num(total_skin_disorders),
    respiratory_conditions = num(total_respiratory_conditions),
    poisonings = num(total_poisonings),
    hearing_loss = num(total_hearing_loss),
    other_illnesses = num(total_other_illnesses),
    submitted = as.Date(submitted),
    revised = !is.na(change_reason) & !str_detect(str_to_lower(change_reason), "^initial submission")
  ) |>
  mutate(
    total_cases = deaths + dafw_cases + djtr_cases + other_cases,
    plausible = coalesce(annual_average_employees > 0 & annual_average_employees <= 50000 &
                         total_hours_worked >= 250 * annual_average_employees &
                         total_hours_worked <= 8760 * annual_average_employees, FALSE)
  ) |>
  select(-any_of(if (include_text) character() else c("street_address", "industry_description"))) |>
  arrange(year, establishment_id)

for (y in sort(unique(est$year))) {
  write_csv(filter(est, year == y), file.path(tidy_dir, sprintf("establishments_%d.csv.gz", y)), na = "")
}

summary_by_industry <- est |>
  group_by(year, naics_sector, state, size, ownership, plausible) |>
  summarise(establishments = n(),
            across(c(annual_average_employees, total_hours_worked, deaths, dafw_cases, djtr_cases,
                     other_cases, total_cases, dafw_days, djtr_days, injuries, skin_disorders,
                     respiratory_conditions, poisonings, hearing_loss, other_illnesses),
                   \(x) sum(x, na.rm = TRUE)),
            .groups = "drop")
write_csv(summary_by_industry, file.path(tidy_dir, "summary_by_industry.csv.gz"), na = "")

est |>
  group_by(year) |>
  filter(plausible) |>
  summarise(establishments = n(), revised = sum(revised),
            employees_millions = sum(annual_average_employees) / 1e6,
            tcr = sum(total_cases, na.rm = TRUE) / sum(total_hours_worked) * 200000,
            dart = sum(dafw_cases + djtr_cases, na.rm = TRUE) / sum(total_hours_worked) * 200000) |>
  print()
for (f in list.files(tidy_dir, full.names = TRUE))
  message(sprintf("%-32s %6.1f MB", basename(f), file.size(f) / 1e6))

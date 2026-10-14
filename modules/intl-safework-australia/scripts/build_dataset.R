# Build tidy Safe Work Australia tables from the published Excel "detailed data files".
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads the three workbooks in data/source/ and writes to data/tidy/:
#   tif_fatalities.csv      Traumatic Injury Fatalities (TIF): worker deaths, counts and rates
#                           per 100,000 workers, 10 calendar and 10 financial years
#   nds_serious_claims.csv  National Dataset for Compensation-based Statistics (NDS): serious
#                           workers' compensation claims, counts, rates, median compensation
#                           and median time lost, 10 financial years
#   wcifr.csv               Workers' compensation injury frequency rates (lost time claims per
#                           million hours worked) by detailed industry and occupation
#
# Every table sheet has the same layout: a title in row 1, a few setting rows, the measure
# name in row 6, the years in row 7, then one row per category with a label in column A.
# Values Safe Work Australia did not publish ("NP") are kept as NA with flag = "NP".

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
})

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
source_dir <- file.path(module_dir, "data", "source")
tidy_dir <- file.path(module_dir, "data", "tidy")
dir.create(tidy_dir, recursive = TRUE, showWarnings = FALSE)

find_source <- function(pattern) {
  path <- list.files(source_dir, pattern = pattern, full.names = TRUE)
  if (length(path) != 1) stop("Expected one file matching '", pattern, "' in ", source_dir)
  path
}
tif_file <- find_source("^traumatic_injury_fatalities.*\\.xlsx$")
nds_file <- find_source("^national_dataset_for_compensation.*\\.xlsx$")
wcifr_file <- find_source("^workers_compensation_injury_frequency.*\\.xlsx$")

# Read one table sheet into long format: table, period, category label, raw value
read_table <- function(path, sheet) {
  d <- read_excel(path, sheet = sheet, col_names = FALSE, col_types = "text", .name_repair = "minimal")
  names(d) <- paste0("c", seq_along(d))
  header_row <- which(is.na(d$c1) & !is.na(d$c2) & seq_len(nrow(d)) > 3)[1]
  periods <- unlist(d[header_row, -1])
  # Excel stores calendar years as numbers, e.g. "2017" or "2017.0"
  periods <- str_remove(periods, "\\.0+$")
  body <- d[(header_row + 1):nrow(d), ]
  names(body) <- c("label", periods)
  body |>
    filter(!is.na(label)) |>
    mutate(row = row_number()) |>
    pivot_longer(-c(label, row), names_to = "period", values_to = "raw") |>
    mutate(table = str_remove(sheet, "^Table "),
           title = d$c1[1],
           measure_label = d$c1[header_row - 1],
           .before = 1)
}

# Split "A Agriculture, forestry and fishing" into a code and a name, and work out the level
# in the classification hierarchy (0 = Total, 1 = broadest group, ...)
split_code <- function(label, classification) {
  code <- str_match(label, "^([A-Z][0-9]?|[0-9]+_?(/[0-9]+)?) ")[, 2]
  category <- if_else(is.na(code), label, str_trim(str_sub(label, nchar(code) + 1)))
  digits <- nchar(str_remove(code, "/.*$"))
  level <- case_when(
    label == "Total" ~ 0L,
    is.na(code) ~ NA_integer_,
    # TOOCS nature: 0/1 = injuries or diseases, letter = group, letter + digit = subgroup
    classification == "nature" & str_detect(code, "^[A-Z]$") ~ 2L,
    classification == "nature" & str_detect(code, "^[A-Z][0-9]$") ~ 3L,
    TRUE ~ as.integer(digits)
  )
  tibble(code = code, category = category, level = level)
}

# Two-way tables (age group by sex; road status by jurisdiction): the group rows are
# followed by their sub-rows
split_groups <- function(label, group_labels) {
  is_group <- label %in% c(group_labels, "Total")
  group <- label
  group[!is_group] <- NA
  group <- zoo_fill(group)
  tibble(group = group,
         category = if_else(is_group, NA_character_, label),
         level = case_when(label == "Total" ~ 0L, is_group ~ 1L, TRUE ~ 2L))
}
zoo_fill <- function(x) {
  for (i in seq_along(x)) if (is.na(x[i]) && i > 1) x[i] <- x[i - 1]
  x
}

age_groups <- c("Under 25", "25-34", "35-44", "45-54", "55-64", "65 and over")
road_groups <- c("Not on a public road", "On a public road")

breakdown_of <- function(title) {
  case_when(
    str_detect(title, "by Industry") ~ "industry",
    str_detect(title, "by Occupation") ~ "occupation",
    str_detect(title, "by Mechanism") ~ "mechanism",
    str_detect(title, "by Breakdown [Aa]gency") ~ "breakdown agency",
    str_detect(title, "by Agency") ~ "agency",
    str_detect(title, "by Nature") ~ "nature",
    str_detect(title, "by Bodily location") ~ "bodily location",
    str_detect(title, "Age group and Sex") ~ "age and sex",
    str_detect(title, "State/Territory") ~ "state",
    str_detect(title, "Public road status") ~ "jurisdiction and road",
    str_detect(title, "\\(Jurisdiction\\)") ~ "jurisdiction",
    str_detect(title, "vehicle type") ~ "vehicle type",
    str_detect(title, "activity type") ~ "vehicle activity",
    TRUE ~ NA_character_
  )
}

add_categories <- function(d) {
  d |>
    group_by(table) |>
    group_modify(function(t, key) {
      b <- t$breakdown[1]
      cats <- if (b %in% c("industry", "occupation", "mechanism", "breakdown agency", "agency",
                           "nature", "bodily location")) {
        split_code(t$label, b) |> mutate(group = NA_character_)
      } else if (b == "age and sex") {
        g <- split_groups(t$label, age_groups)
        # Rows for an age group cover both sexes
        g |> mutate(category = if_else(level == 1L, "Persons", category),
                    category = if_else(level == 0L, "Persons", category))
      } else if (b == "jurisdiction and road") {
        split_groups(t$label, road_groups) |>
          mutate(category = if_else(level <= 1L, "All jurisdictions", category))
      } else {
        tibble(code = NA_character_, category = t$label, group = NA_character_,
               level = if_else(t$label == "Total", 0L, 1L))
      }
      bind_cols(select(t, -label), select(cats, any_of(c("code", "group", "category", "level"))))
    }) |>
    ungroup()
}

finish <- function(d) {
  d |>
    mutate(flag = if_else(raw == "NP", "NP", NA_character_),
           value = suppressWarnings(as.numeric(raw)),
           preliminary = str_ends(period, "p"),
           period = str_remove(period, "p$"),
           # Financial years run 1 July to 30 June; year = the year the period ends
           fy_start = as.integer(str_match(period, "(\\d{4})-\\d{2}$")[, 2]),
           year = coalesce(fy_start + 1L, as.integer(str_extract(period, "^\\d{4}$")))) |>
    select(-fy_start)
}

# --- Traumatic Injury Fatalities --------------------------------------------------------------

tif_sheets <- setdiff(excel_sheets(tif_file), "Cover page")
tif <- bind_rows(lapply(tif_sheets, \(s) read_table(tif_file, s))) |>
  mutate(breakdown = breakdown_of(title),
         period_type = if_else(str_detect(title, "\\(calendar\\)"), "calendar", "financial"),
         measure = if_else(str_detect(measure_label, "rate"), "rate_per_100000_workers", "fatalities")) |>
  add_categories() |>
  finish() |>
  select(table, breakdown, period_type, period, year, code, group, category, level,
         measure, value, flag)

stopifnot(!anyNA(tif$breakdown), !anyNA(tif$category), !anyNA(tif$year), !anyNA(tif$level))

# --- National Dataset for Compensation-based Statistics ---------------------------------------

nds_sheets <- setdiff(excel_sheets(nds_file), "Cover page")
nds <- bind_rows(lapply(nds_sheets, \(s) read_table(nds_file, s))) |>
  mutate(breakdown = breakdown_of(title),
         # Use the sheet title: a few measure labels in the workbook are mislabelled
         measure = case_when(
           str_detect(title, "\\(count\\)") ~ "claims",
           str_detect(title, "frequency rate") ~ "frequency_rate_per_million_hours",
           str_detect(title, "incidence rate") ~ "incidence_rate_per_1000_employees",
           str_detect(title, "median compensation") ~ "median_compensation_aud",
           str_detect(title, "median time lost") ~ "median_time_lost_weeks"
         )) |>
  add_categories() |>
  finish() |>
  select(table, breakdown, period, year, preliminary, code, group, category, level,
         measure, value, flag)

stopifnot(!anyNA(nds$breakdown), !anyNA(nds$measure), !anyNA(nds$category), !anyNA(nds$level))

# --- Workers' compensation injury frequency rates ---------------------------------------------

wcifr_sheets <- setdiff(excel_sheets(wcifr_file), "Cover page")
wcifr <- bind_rows(lapply(wcifr_sheets, \(s) read_table(wcifr_file, s))) |>
  mutate(breakdown = breakdown_of(title),
         # Tables 1.x give one headline value: the average of the last 5 years
         period = if_else(str_detect(title, "5-year average"),
                          paste0("5-year average to ", str_extract(title, "\\d{4}-\\d{2}$")),
                          period),
         measure = "lost_time_claims_per_million_hours") |>
  add_categories() |>
  finish() |>
  select(table, breakdown, period, year, preliminary, code, category, level, measure, value, flag)

stopifnot(!anyNA(wcifr$breakdown), !anyNA(wcifr$year), !anyNA(wcifr$level))

# --- Checks against published totals -----------------------------------------------------------

check <- function(d, ..., expected) {
  got <- filter(d, ...)$value
  if (length(got) != 1 || abs(got - expected) > 1e-6) {
    stop("Check failed: expected ", expected, ", got ", paste(got, collapse = ", "))
  }
}
check(tif, table == "1.1", category == "Total", period == "2025", expected = 222)
check(tif, table == "6.1", group == "25-34", category == "Male", period == "2024", expected = 55)
check(tif, table == "8.1", group == "On a public road", category == "Commonwealth",
      period == "2021", expected = 8)
check(nds, table == "1.1", category == "Total", period == "2024-25", expected = 147174)
check(nds, table == "9.1", category == "NSW", period == "2015-16", expected = 33347)

# Sub-rows add up to their group in the two-way tables
two_way <- tif |>
  filter(measure == "fatalities", breakdown %in% c("age and sex", "jurisdiction and road"), level > 0) |>
  group_by(table, period, group) |>
  summarise(group_value = value[level == 1], parts = sum(value[level == 2]), .groups = "drop")
stopifnot(all(two_way$group_value == two_way$parts))

write_csv(tif, file.path(tidy_dir, "tif_fatalities.csv"), na = "")
write_csv(nds, file.path(tidy_dir, "nds_serious_claims.csv"), na = "")
write_csv(wcifr, file.path(tidy_dir, "wcifr.csv"), na = "")

message("tif_fatalities.csv: ", nrow(tif), " rows; nds_serious_claims.csv: ", nrow(nds),
        " rows; wcifr.csv: ", nrow(wcifr), " rows")

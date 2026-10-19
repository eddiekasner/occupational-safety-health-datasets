# Build tidy tables from Statistics Finland's occupational accident tables.
#
# Usage (from a terminal):   Rscript scripts/build_dataset.R
# Usage (from RStudio):      open this file and click "Source"
#
# Reads the JSON-stat files downloaded by scripts/fetch_data.R and writes, to data/tidy/:
#   accidents.csv.gz       accidents by year, employment status, place, outcome, age, sex and
#                          industry (2-digit NACE), 2008 onward; the most detailed level of each
#                          variable only, so rows add up without double counting
#   esaw_causes.csv        workplace accidents of wage and salary earners by ESAW variable
#                          (activity, deviation, contact, injury, body part), year and sex
#   rates.csv              wage and salary earners' accidents (at least 4 days of disability) per
#                          100,000 workers and per million hours worked, by industry section,
#                          sex, place and year, 2018 onward, with the numbers of workers and hours
#   farmers.csv            farmers' accidents (at least 4 days of disability) per 100,000 insured
#                          farmers, 2000 onward

library(dplyr)
library(readr)
library(tidyr)
library(purrr)

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) {
  dirname(normalizePath(sub("^--file=", "", file_arg)))
} else if (!is.null(sys.frame(1)$ofile)) {
  dirname(normalizePath(sys.frame(1)$ofile))
} else {
  getwd()
}
raw_dir <- file.path(script_dir, "..", "data", "raw")
tidy_dir <- file.path(script_dir, "..", "data", "tidy")
dir.create(tidy_dir, showWarnings = FALSE)

# Read a JSON-stat2 file into a long data frame with one column of codes and one of labels per
# dimension, and a value column
read_jsonstat <- function(path) {
  js <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  dims <- unlist(js$id)
  codes <- lapply(dims, function(d) names(js$dimension[[d]]$category$index))
  names(codes) <- dims
  # JSON-stat stores values with the last dimension varying fastest; expand.grid varies the
  # first fastest, so reverse the order
  grid <- expand.grid(rev(codes), stringsAsFactors = FALSE)[, rev(dims)]
  for (d in dims) {
    lab <- unlist(js$dimension[[d]]$category$label)
    grid[[paste0(d, "_label")]] <- unname(lab[grid[[d]]])
  }
  grid$value <- vapply(js$value, function(x) if (is.null(x)) NA_real_ else as.numeric(x), 0)
  as_tibble(grid)
}

# ---- Main table: accidents ---------------------------------------------------------------------
files <- list.files(raw_dir, "^ttap_12ay_\\d{4}_\\d+\\.json$", full.names = TRUE)
message(length(files), " files for the main table")
raw <- map_dfr(files, function(f) {
  read_jsonstat(f) |>
    filter(contentscode == contentscode[1])  # counts only (the other measure is a percentage)
})

outcome_labels <- c("0-3 days" = "0-3 days", "4-6 days" = "4-6 days", "7-14 days" = "7-14 days",
                    "15-30 days" = "15-30 days", "31-90 days" = "31-90 days",
                    "91-180 days" = "91-180 days", "181 days or more" = "181 days or more",
                    "Workers' compensation pension" = "Disability pension",
                    "Fatal accidents" = "Fatal")
place_labels <- c("1.1 Workplace accident (without occupational traffic accident)" = "Workplace",
                  "1.2 Occupational traffic accident" = "Traffic while working",
                  "2 Commuting accident" = "Commuting")

accidents_all <- raw |>
  transmute(year = as.integer(Timeperiod_y),
            status = ammattiasema_13_19960101_label,
            place = henkilovahinko_30_19960101_label,
            outcome = henkilovahinko_47_19960101_label,
            age_group = gsub(" ", "", ikaryhma_10_20180101_label),
            sex = sukupuoli_9_20180101_label,
            industry_code = toimiala_79_20180101,
            industry_label = toimiala_79_20180101_label,
            accidents = value)

# National totals, kept to check the detailed rows against
totals <- accidents_all |>
  filter(status == "Total", place == "Total", outcome == "Total", age_group == "Total",
         sex == "Total", industry_code == "SSS") |>
  select(year, total = accidents)

# Keep the most detailed level of each variable: industry divisions (a letter and two digits),
# the local government sector (municipal employees are reported as a sector, not by industry)
# and unknown industry, the three places, the nine outcomes, and age groups and sexes
accidents <- accidents_all |>
  filter(status != "Total", place %in% names(place_labels), outcome %in% names(outcome_labels),
         age_group != "Total", sex != "Total",
         grepl("^[A-Z]\\d{2}$", industry_code) | industry_code %in% c("S1313", "X"),
         !is.na(accidents), accidents > 0) |>
  mutate(status = recode(status, "Wage and salary earners" = "Wage and salary earner",
                         "Entrepreneurs (without farmers)" = "Entrepreneur"),
         place = unname(place_labels[place]),
         outcome = unname(outcome_labels[outcome]),
         sex = recode(sex, "Males" = "Male", "Females" = "Female"),
         section = if_else(grepl("^[A-Z]\\d{2}$", industry_code), substr(industry_code, 1, 1),
                           NA_character_),
         industry_division = if_else(is.na(section), NA_character_, substr(industry_code, 2, 3)),
         industry = case_when(industry_code == "S1313" ~ "Local government sector",
                              industry_code == "X" ~ "Unknown",
                              TRUE ~ sub("^\\d{2} ", "", industry_label))) |>
  select(year, status, place, outcome, sex, age_group, section, industry_division, industry,
         accidents) |>
  arrange(year, status, place, outcome, sex, age_group, section, industry_division)

# Section names (for joining), from the section rows of the source
sections <- accidents_all |>
  filter(grepl("^[A-Z]$", industry_code)) |>
  distinct(section = industry_code,
           section_name = sub(" \\([0-9-]+\\)$", "", sub("^[A-Z] ", "", industry_label)))
accidents <- accidents |>
  left_join(sections, by = "section") |>
  relocate(section_name, .after = section)

check <- accidents |>
  group_by(year) |>
  summarise(detail = sum(accidents)) |>
  left_join(totals, by = "year")
print(as.data.frame(check))
if (any(check$detail != check$total)) {
  warning("Detailed rows do not add up to the national total in some years")
} else {
  message("Detailed rows add up to the national totals in every year")
}
write_csv(accidents, file.path(tidy_dir, "accidents.csv.gz"), na = "")

# ---- ESAW variables -----------------------------------------------------------------------------
esaw <- c("12b6" = "Specific physical activity", "12b9" = "Deviation",
          "13p6" = "Contact - mode of injury", "13iw" = "Type of injury",
          "13h8" = "Part of body injured")
esaw_causes <- map_dfr(names(esaw), function(t) {
  x <- read_jsonstat(file.path(raw_dir, paste0("ttap_", t, ".json")))
  var <- grep("^henkilovahinko", names(x), value = TRUE)[1]
  x |>
    filter(contentscode == contentscode[1], .data[[var]] != "SSS") |>
    transmute(year = as.integer(Timeperiod_y), variable = esaw[[t]],
              code = .data[[var]],
              category = sub("^'?[0-9]+ ", "", .data[[paste0(var, "_label")]]),
              sex = sukupuoli_9_20180101_label, accidents = value)
}) |>
  filter(category != "Total") |>
  mutate(sex = recode(sex, "Males" = "Male", "Females" = "Female"))
write_csv(esaw_causes, file.path(tidy_dir, "esaw_causes.csv"), na = "")

# ---- Rates ----------------------------------------------------------------------------------------
# Both rate tables count accidents with at least 4 days of disability among wage and salary earners
# (the "Total" severity in table 12zz is the same figure). The rate per million hours covers
# accidents at work, including traffic while working, but not commuting.
rate_places <- c("SSS" = "All", "1" = "At work (including traffic while working)",
                 "2" = "Workplace", "3" = "Traffic while working", "4" = "Commuting")
section_names <- function(code, label) {
  case_when(code == "SSS" ~ "Total", code == "S1313" ~ "Local government sector",
            code == "X" ~ "Unknown",
            code == "T" ~ "Activities of households as employers",
            TRUE ~ sub(" \\([0-9-]+\\)$", "", sub("^[A-Z] ", "", label)))
}
per_worker <- read_jsonstat(file.path(raw_dir, "ttap_12zz.json")) |>
  filter(henkilovahinko_24_19960101_label == "At least 4 days") |>
  transmute(year = as.integer(Timeperiod_y),
            sex = sukupuoli_9_20180101_label,
            section = toimiala_79_20180101,
            section_name = section_names(toimiala_79_20180101, toimiala_79_20180101_label),
            place = unname(rate_places[henkilovahinko_30_19960101]),
            measure = recode(contentscode, P_turmia = "accidents_4plus_days",
                             Palkansaajat = "workers", P_suhde = "per_100000_workers"),
            value) |>
  pivot_wider(names_from = measure, values_from = value)
per_hours <- read_jsonstat(file.path(raw_dir, "ttap_13ql.json")) |>
  transmute(year = as.integer(Timeperiod_y), sex = sukupuoli_9_20180101_label,
            section = toimiala_79_20180101,
            place = "At work (including traffic while working)",
            measure = case_when(grepl("per million", contentscode_label) ~ "per_million_hours",
                                grepl("hours", contentscode_label) ~ "hours_thousands",
                                TRUE ~ "accidents_hours_table"),
            value) |>
  pivot_wider(names_from = measure, values_from = value) |>
  select(-accidents_hours_table)
rates <- per_worker |>
  left_join(per_hours, by = c("year", "sex", "section", "place")) |>
  mutate(sex = recode(sex, "Males" = "Male", "Females" = "Female"),
         section = recode(section, "SSS" = "Total"),
         place = factor(place, unname(rate_places))) |>
  arrange(year, sex, section, place) |>
  mutate(place = as.character(place))
write_csv(rates, file.path(tidy_dir, "rates.csv"), na = "")

# ---- Farmers --------------------------------------------------------------------------------------
farmers <- read_jsonstat(file.path(raw_dir, "ttap_129t.json")) |>
  transmute(year = as.integer(Timeperiod_y), sex = sukupuoli_9_20180101_label,
            age_group = gsub(" ", "", ikaryhma_10_20180101_label),
            severity = henkilovahinko_24_19960101_label, measure = contentscode_label, value) |>
  mutate(measure = case_when(grepl("per 100,000", measure) ~ "per_100000_farmers",
                             grepl("Insured", measure) ~ "insured_farmers",
                             TRUE ~ "accidents"),
         sex = recode(sex, "Males" = "Male", "Females" = "Female"),
         severity = recode(severity, "At least 4 days" = "4plus_days", "Total" = "all")) |>
  pivot_wider(names_from = c(measure, severity), values_from = value) |>
  # As in the rate tables, the "Total" severity is the same as "At least 4 days"; keep one
  transmute(year, sex, age_group, insured_farmers = insured_farmers_all,
            accidents_4plus_days, per_100000_farmers = per_100000_farmers_4plus_days)
write_csv(farmers, file.path(tidy_dir, "farmers.csv"), na = "")

for (f in list.files(tidy_dir, full.names = TRUE)) {
  message(sprintf("%-22s %8.2f MB", basename(f), file.size(f) / 1e6))
}

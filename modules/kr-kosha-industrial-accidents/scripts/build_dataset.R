# Build the tidy table of injured workers from KOSHA's microdata, with English labels.
#
# Usage (from a terminal):   Rscript scripts/build_dataset.R
# Usage (from RStudio):      open this file and click "Source"
#
# Reads the 90 Excel files downloaded by scripts/fetch_data.R (one per year and major industry)
# and writes data/tidy/injured_workers.csv.gz: one row per injured worker or death, 2017 to 2025.
# Korean labels are translated with scripts/labels_ko_en.csv. The build checks the yearly totals
# against the Ministry of Employment and Labor's published figures (data/tidy/insured_workers.csv,
# made by scripts/extract_insured_workers.py).

library(readxl)
library(readr)
library(dplyr)
library(purrr)

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) {
  dirname(normalizePath(sub("^--file=", "", file_arg)))
} else if (!is.null(sys.frame(1)$ofile)) {
  dirname(normalizePath(sys.frame(1)$ofile))
} else {
  getwd()
}
module_dir <- normalizePath(file.path(script_dir, ".."))
raw_dir <- file.path(module_dir, "data", "raw")
tidy_dir <- file.path(module_dir, "data", "tidy")

# ---- Read the microdata ------------------------------------------------------------------------
files <- list.files(raw_dir, "^kosha_microdata_\\d{4}_industry\\d\\.xlsx$", full.names = TRUE)
if (length(files) != 90) warning("Expected 90 files; found ", length(files))
columns <- c("ym", "industry", "industry_group", "accident_type", "establishment_size", "sex",
             "age_group", "length_of_service", "severity", "region", "labour_office",
             "construction_value", "disease_group", "disease")
raw <- map_dfr(files, function(f) {
  x <- read_excel(f, col_types = "text")
  if (ncol(x) != length(columns)) stop("Unexpected columns in ", basename(f))
  names(x) <- columns
  x
})
message(nrow(raw), " rows read")

# ---- English labels ----------------------------------------------------------------------------
labels <- read_csv(file.path(script_dir, "labels_ko_en.csv"), show_col_types = FALSE)
translate <- function(x, variable, strip_spaces = FALSE) {
  lab <- labels[labels$variable == variable, ]
  key <- if (strip_spaces) gsub("\\s", "", x) else x
  out <- lab$english[match(key, lab$korean)]
  # Values that mean "not applicable" or "unknown" become missing
  missing_ok <- is.na(x) | x %in% c("\ud574\ub2f9\uc5c6\uc74c", "\ubd84\ub958\ubd88\ub2a5")
  unmatched <- unique(x[is.na(out) & !missing_ok])
  if (length(unmatched)) stop("No English label for ", variable, ": ",
                              paste(unmatched, collapse = ", "))
  out
}
# Korean labels used to recognise deaths and diseases (written as escapes so the script
# works in any locale; named ko_* so they are not mistaken for the data's own columns)
ko_death <- "\uc0ac\ub9dd\uc790"  # death
ko_other_death <- "\uc694\uc591\uc7ac\ud574\uc790"  # "injured worker receiving care" (see README)
ko_disease <- "\uc5c5\ubb34\uc0c1\uc9c8\ubcd1"  # occupational disease

injured <- raw |>
  transmute(
    year = as.integer(substr(ym, 1, 4)),
    case_type = case_when(
      severity == ko_death & accident_type == ko_disease ~ "Occupational disease death",
      severity == ko_death ~ "Accident death",
      severity == ko_other_death ~ "Accident death not in the official count",
      accident_type == ko_disease ~ "Occupational disease",
      TRUE ~ "Accident injury"),
    industry_group = translate(industry_group, "industry_group"),
    industry_2020 = translate(industry, "industry_2020"),
    industry = translate(industry, "industry"),
    accident_type = translate(accident_type, "accident_type"),
    establishment_size = translate(establishment_size, "establishment_size"),
    sex = translate(sex, "sex"),
    age_group = translate(age_group, "age_group"),
    length_of_service = translate(length_of_service, "length_of_service"),
    days_of_care = translate(if_else(severity %in% c(ko_death, ko_other_death), NA, severity),
                             "days_of_care"),
    region = translate(region, "region"),
    labour_office = translate(labour_office, "labour_office", strip_spaces = TRUE),
    construction_value = translate(construction_value, "construction_value"),
    disease_group = translate(disease_group, "disease_group"),
    disease = translate(disease, "disease")
  ) |>
  # A stable order: year, then the categories in the order they are listed
  arrange(year, industry_group, industry, case_type, accident_type, establishment_size, sex,
          age_group, length_of_service, days_of_care, region, labour_office)

# ---- Check against the published totals ---------------------------------------------------------
published <- read_csv(file.path(tidy_dir, "insured_workers.csv"), show_col_types = FALSE) |>
  filter(breakdown == "All") |>
  select(year, reported_injured, reported_deaths)
check <- injured |>
  group_by(year) |>
  summarise(injured = n(), deaths = sum(case_type %in% c("Accident death",
                                                        "Occupational disease death"))) |>
  left_join(published, by = "year")
print(as.data.frame(check))
if (any(check$injured != check$reported_injured | check$deaths != check$reported_deaths)) {
  warning("Totals differ from the published figures")
} else {
  message("Injured workers and deaths match the published totals for every year")
}

# ---- Write -------------------------------------------------------------------------------------
dir.create(tidy_dir, showWarnings = FALSE)
out <- file.path(tidy_dir, "injured_workers.csv.gz")
write_csv(injured, out, na = "")
message(sprintf("Wrote %s (%s rows, %.1f MB)", basename(out), format(nrow(injured), big.mark = ","),
                file.size(out) / 1e6))

# Turn the raw ILOSTAT downloads into three tidy tables for analysis.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads data/raw/ (from fetch_data.R) and writes to data/tidy/:
#   injuries_national.csv     injury rates, cases, days lost and workers covered,
#                             by country, year, sex and migrant status
#   injuries_by_sector.csv    fatal and non-fatal injury rates by economic activity
#                             (ILO aggregate sectors and ISIC Rev. 4 sections)
#   labour_inspection.csv     labour inspectors, inspection visits and workplaces
#
# Each table is long: one row per country, year, breakdown and measure.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
})

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
raw_dir <- file.path(module_dir, "data", "raw")
tidy_dir <- file.path(module_dir, "data", "tidy")
dir.create(tidy_dir, recursive = TRUE, showWarnings = FALSE)

read_raw <- function(name) {
  path <- file.path(raw_dir, name)
  if (!file.exists(path)) stop("Missing ", path, ". Run fetch_data.R first.")
  read_csv(path, col_types = cols(.default = col_character()), progress = FALSE)
}

# One continent per country, from the UN M49 regions
continents <- c("2" = "Africa", "19" = "Americas", "142" = "Asia", "150" = "Europe", "9" = "Oceania")
regions <- read_raw("regions_unsd.csv") |>
  filter(region %in% names(continents)) |>
  transmute(country_code = ref_area, region = unname(continents[region])) |>
  distinct(country_code, .keep_all = TRUE)

# Read one indicator and give it plain column names. `measure` is a short name
# for the indicator; breakdown columns are added by the callers.
read_indicator <- function(id, measure) {
  df <- read_raw(paste0(id, ".csv"))
  note_cols <- intersect(c("note_classif.label", "note_indicator.label", "note_source.label"), names(df))
  df |>
    mutate(
      measure = measure,
      notes = apply(across(all_of(note_cols)), 1, \(x) paste(na.omit(x), collapse = " | ")),
      notes = na_if(notes, ""),
      source_type = str_extract(source.label, "^\\S+(?= - )"),
      source = str_remove(source.label, "^\\S+ - "),
      obs_status = if ("obs_status.label" %in% names(df)) obs_status.label else NA_character_
    ) |>
    left_join(regions, by = c("ref_area" = "country_code")) |>
    rename(country_code = ref_area, country = ref_area.label, year = time, value = obs_value)
}

strip_prefix <- function(x) str_remove(x, "^[^:]+: ")
common <- c("country_code", "country", "region", "year", "measure")
trailing <- c("value", "source_type", "source", "obs_status", "notes")

# Table 1: national totals by sex and migrant status
national_ids <- c(
  INJ_FATL_SEX_MIG_RT_A = "fatal_rate_per_100k",
  INJ_NFTL_SEX_MIG_RT_A = "nonfatal_rate_per_100k",
  INJ_FATL_SEX_MIG_NB_A = "fatal_cases",
  INJ_NFTL_SEX_MIG_NB_A = "nonfatal_cases",
  INJ_DAYS_SEX_MIG_NB_A = "days_lost",
  INJ_WORK_SEX_MIG_NB_A = "workers_covered_thousands"
)
national <- bind_rows(lapply(names(national_ids), function(id) {
  read_indicator(id, national_ids[[id]]) |>
    mutate(sex = strip_prefix(sex.label), migrant_status = strip_prefix(classif1.label)) |>
    select(all_of(common), sex, migrant_status, all_of(trailing))
}))

# Table 2: rates by economic activity (ILO aggregate sectors and ISIC Rev. 4 sections)
sector_ids <- c(
  INJ_FATL_ECO_RT_A = "fatal_rate_per_100k",
  INJ_NFTL_ECO_RT_A = "nonfatal_rate_per_100k"
)
# Cases and workers by sector are in data/raw (INJ_*_ECO_NB_A); they are left out here
# to keep this table small enough to commit.
by_sector <- bind_rows(lapply(names(sector_ids), function(id) {
  read_indicator(id, sector_ids[[id]]) |>
    filter(str_detect(classif1, "^ECO_(AGGREGATE|ISIC4)_")) |>
    mutate(classification = if_else(str_starts(classif1, "ECO_AGGREGATE"), "Aggregate", "ISIC Rev. 4"),
           sector_code = str_remove(classif1, "^ECO_(AGGREGATE|ISIC4)_"),
           sector = strip_prefix(classif1.label)) |>
    select(all_of(common), classification, sector_code, sector, all_of(trailing))
}))

# Table 3: labour inspection
inspection_ids <- c(
  LAI_INSP_SEX_NB_A = "inspectors",
  LAI_INDE_NOC_RT_A = "inspectors_per_10k_employed",
  LAI_VIST_NOC_NB_A = "inspection_visits",
  LAI_VDIN_NOC_RT_A = "visits_per_inspector",
  LAI_WOPL_NOC_NB_A = "workplaces_registered"
)
inspection <- bind_rows(lapply(names(inspection_ids), function(id) {
  df <- read_indicator(id, inspection_ids[[id]])
  df$sex <- if ("sex.label" %in% names(df)) strip_prefix(df$sex.label) else "Total"
  select(df, all_of(common), sex, all_of(trailing))
}))

tables <- list(injuries_national = national, injuries_by_sector = by_sector,
               labour_inspection = inspection)
for (name in names(tables)) {
  df <- tables[[name]] |>
    mutate(year = as.integer(year), value = as.numeric(value)) |>
    arrange(country_code, measure, year)
  path <- file.path(tidy_dir, paste0(name, ".csv"))
  write_csv(df, path, na = "")
  message(sprintf("%s: %s rows, %.1f MB", basename(path), format(nrow(df), big.mark = ","),
                  file.size(path) / 1e6))
}

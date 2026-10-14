# Build tidy SOII tables from the BLS downloads.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads data/raw/ (from fetch_data.R) and writes to data/tidy/:
#
# From the "is" series (all recordable cases, 2014-2024):
#   soii_industry.csv.gz     US rates and counts by detailed industry and ownership
#   soii_states.csv          rates and counts by state and ownership (all industries)
#   soii_size.csv            private industry rates by establishment size, by industry sector
# From the "cs" series (cases with days away from work):
#   soii_dafw_characteristics.csv  US rates, counts and median days away by worker and case
#                                  characteristic (age, sex, event, nature, ...)
#   soii_dafw_detail.csv.gz  US rates, counts and median days away by detailed event, nature,
#                            part of body, source, occupation and industry
#   soii_dafw_states.csv     rates, counts and median days away by state
#
# Both series pack their breakdowns into fixed positions of the series ID (see the comments
# in fetch_data.R and the BLS documentation files is.txt and cs.txt). Values BLS did not
# publish ("-") are dropped.

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

read_bls <- function(name) {
  path <- file.path(raw_dir, name)
  if (!file.exists(path)) stop("Missing ", path, ". Run fetch_data.R first.")
  read_tsv(path, col_types = cols(.default = col_character()), progress = FALSE,
           locale = locale(encoding = "UTF-8")) |>
    rename_with(str_trim) |>
    mutate(across(everything(), \(x) str_trim(str_replace_all(x, "�", "'"))))
}

read_data <- function(name) {
  read_bls(name) |>
    filter(value != "-") |>
    transmute(series_id, year = as.integer(year), value = as.numeric(value),
              footnote = na_if(footnote_codes, ""))
}

# The two largest tables are gzip-compressed; read_csv() reads them directly
compressed <- c("soii_industry", "soii_dafw_detail")
write_table <- function(df, name) {
  path <- file.path(tidy_dir, paste0(name, if (name %in% compressed) ".csv.gz" else ".csv"))
  write_csv(df, path, na = "")
  message(sprintf("%s: %s rows, %.1f MB", basename(path), format(nrow(df), big.mark = ","),
                  file.size(path) / 1e6))
}

# ---- "is": industry and state data -------------------------------------------------
# Series ID: IS U sss iiiiii d c aaa  (supersector, industry, data type, case type, area)
message("reading is.data.1.AllData")
is <- read_data("is.data.1.AllData") |>
  mutate(supersector_code = str_sub(series_id, 4, 6),
         industry_code = str_sub(series_id, 7, 12),
         data_type_code = str_sub(series_id, 13, 13),
         case_type_code = str_sub(series_id, 14, 14),
         area_code = str_sub(series_id, 15, 17))

# Data types: the first six are for all establishment sizes; the rest repeat them for
# size classes 1 (1-10 employees) to 5 (1,000 or more)
measures <- c("illness_rate_per_10000", "injury_rate_per_100", "injury_illness_rate_per_100",
              "illness_cases_thousands", "injury_cases_thousands", "injury_illness_cases_thousands")
data_types <- tibble(
  data_type_code = c("0", "1", "3", "4", "5", "6",
                     "2", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H",
                     "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
                     "U", "V", "W", "X", "Y", "Z"),
  # Within each size class the BLS codes run: illness rate, injury rate, injury and illness
  # rate, illness cases, injury cases, injury and illness cases (see is.data_type)
  measure = rep(measures, 6),
  size_class = c(rep("All sizes", 6), rep(c("1-10", "11-49", "50-249", "250-999", "1,000 or more"), each = 6))
)

industries <- read_bls("is.industry") |>
  transmute(supersector_code, industry_code, industry = industry_text,
            display_level = as.integer(display_level))
supersectors <- read_bls("is.supersector") |> select(supersector_code, supersector = supersector_text)
case_types <- read_bls("is.case_type") |> select(case_type_code, case_type = case_type_text)
areas <- read_bls("is.area") |>
  transmute(area_code,
            ownership = str_trim(str_extract(area_text, "^[^,]+")),
            area = str_trim(str_remove(area_text, "^[^,]+,")))

is <- is |>
  left_join(data_types, by = "data_type_code") |>
  left_join(case_types, by = "case_type_code") |>
  left_join(areas, by = "area_code") |>
  left_join(industries, by = c("supersector_code", "industry_code")) |>
  left_join(supersectors, by = "supersector_code")

national <- str_sub(is$area_code, 2, 3) == "00"

write_table(
  is |>
    filter(national, size_class == "All sizes") |>
    select(ownership, supersector, industry_code, industry, display_level, case_type, measure,
           year, value, footnote) |>
    arrange(ownership, industry_code, case_type, measure, year),
  "soii_industry")

write_table(
  is |>
    filter(!national, size_class == "All sizes", industry_code == "000000") |>
    select(state = area, ownership, case_type, measure, year, value, footnote) |>
    arrange(state, ownership, case_type, measure, year),
  "soii_states")

write_table(
  is |>
    filter(area_code == "100", size_class != "All sizes", display_level <= 3,
           !str_starts(case_type, "RSE")) |>
    select(supersector, industry_code, industry, display_level, size_class, case_type, measure,
           year, value, footnote) |>
    arrange(industry_code, case_type, measure, size_class, year),
  "soii_size")

# ---- "cs": case and demographic characteristics (days away from work) -----------------
# Series ID: cs U ccc dddddd t k o ss  (category, detail, data type, case, ownership, state)
message("reading cs.data.filtered")
cs <- read_data("cs.data.filtered") |>
  mutate(category_code = str_sub(series_id, 4, 6),
         detail_code = str_sub(series_id, 7, 12),
         data_type_code = str_sub(series_id, 13, 13),
         case_code = str_sub(series_id, 14, 14),
         ownership_code = str_sub(series_id, 15, 15),
         state_code = str_sub(series_id, 16, 17),
         measure = recode(data_type_code, "3" = "rate_per_10000", "6" = "cases",
                          "7" = "median_days_away"))

categories <- read_bls("cs.category") |>
  filter(case_code == "3") |>
  transmute(category_code, characteristic = category_text)
ownerships <- read_bls("cs.ownership") |> select(ownership_code, ownership = ownership_name)
states <- read_bls("cs.state") |> select(state_code, state = state_name)

detail_files <- c("3" = "cs.industry", "E" = "cs.event", "N" = "cs.nature", "P" = "cs.pob",
                  "S" = "cs.source", "O" = "cs.occupation")
detail_types <- c("3" = "industry", "E" = "event", "N" = "nature", "P" = "part of body",
                  "S" = "source", "O" = "occupation")
details <- bind_rows(lapply(names(detail_files), function(case) {
  m <- read_bls(detail_files[[case]])
  names(m)[1:2] <- c("detail_code", "detail")
  m$display_level <- if ("display_level" %in% names(m)) as.integer(m$display_level) else NA_integer_
  transmute(m, case_code = case, detail_code, detail, display_level)
}))

write_table(
  cs |>
    filter(state_code == "00", case_code == "3", detail_code == "000000") |>
    left_join(categories, by = "category_code") |>
    left_join(ownerships, by = "ownership_code") |>
    select(ownership, category_code, characteristic, measure, year, value, footnote) |>
    arrange(ownership, category_code, measure, year),
  "soii_dafw_characteristics")

write_table(
  cs |>
    filter(state_code == "00", category_code == "00X", case_code %in% names(detail_files)) |>
    left_join(details, by = c("case_code", "detail_code")) |>
    left_join(ownerships, by = "ownership_code") |>
    mutate(detail_type = unname(detail_types[case_code])) |>
    select(ownership, detail_type, detail_code, detail, display_level, measure, year, value, footnote) |>
    arrange(ownership, detail_type, detail_code, measure, year),
  "soii_dafw_detail")

write_table(
  cs |>
    filter(state_code != "00", category_code == "00X", case_code == "3", detail_code == "000000") |>
    left_join(states, by = "state_code") |>
    left_join(ownerships, by = "ownership_code") |>
    select(state, ownership, measure, year, value, footnote) |>
    arrange(state, ownership, measure, year),
  "soii_dafw_states")

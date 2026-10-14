# Build tidy CFOI tables from the BLS downloads.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads data/raw/ (from fetch_data.R) and writes to data/tidy/:
#   cfoi_national.csv    US fatal injury counts by worker and case characteristic, 2011-2022
#   cfoi_by_detail.csv   US counts by detailed industry, occupation, event and source, 2011-2022
#   cfoi_states.csv      counts by state and characteristic, 2011-2022. `area_type` marks the
#                        50 states and DC (these add up to the US total), the two New York parts
#                        (New York City and the rest of the state, already counted in "New York
#                        State and New York City"), and territories (not in the US total)
#   cfoi_rates.csv       fatal injury rates per 100,000 full-time equivalent workers, from
#                        BLS's hours-based rate tables, 2023 and 2024
#
# How the flat file works: each CFOI series ID packs its breakdowns into fixed positions,
#   FW U 00X 000000 8 0 N00
#      |  |   |      | | └ area (N00 = US, Sxx = state, Mxx = metro area)
#      |  |   |      | └ case: what the 6-character detail code means
#      |  |   |      |         (0 = all workers, 1 = private industry, 9 = government industry,
#      |  |   |      |          O = occupation, E = event, S = primary source)
#      |  |   |      └ data type (8 = count of fatal injuries)
#      |  |   └ detail code (industry, occupation, event or source)
#      |  └ category: a worker or case characteristic (00X = all)
#      └ seasonal (U = not seasonally adjusted)
# The data file is filtered on these positions while reading, so the full 620 MB file
# never has to fit in memory. Counts that do not meet publication criteria are absent.

suppressPackageStartupMessages({
  library(readr)
  library(readxl)
  library(dplyr)
  library(stringr)
})

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
raw_dir <- file.path(module_dir, "data", "raw")
tidy_dir <- file.path(module_dir, "data", "tidy")
dir.create(tidy_dir, recursive = TRUE, showWarnings = FALSE)

read_map <- function(name) {
  path <- file.path(raw_dir, name)
  if (!file.exists(path)) stop("Missing ", path, ". Run fetch_data.R first.")
  read_tsv(path, col_types = cols(.default = col_character()), progress = FALSE) |>
    # A few BLS labels contain a broken apostrophe (Unicode replacement character)
    mutate(across(everything(), \(x) str_trim(str_replace_all(x, "\uFFFD", "'"))))
}

# --- 1. Filter the flat file ---------------------------------------------------------
detail_cases <- c("1", "9", "O", "E", "S")
keep_rows <- function(chunk, pos) {
  chunk |>
    mutate(series_id = str_trim(series_id),
           category_code = str_sub(series_id, 4, 6),
           detail_code = str_sub(series_id, 7, 12),
           case_code = str_sub(series_id, 14, 14),
           area_code = str_sub(series_id, 15, 17)) |>
    filter((area_code == "N00" & case_code == "0" & detail_code == "000000") |
             (area_code == "N00" & category_code == "00X" & case_code %in% detail_cases) |
             (str_starts(area_code, "S") & case_code == "0" & detail_code == "000000")) |>
    transmute(category_code, detail_code, case_code, area_code,
              year = as.integer(year), fatalities = as.numeric(value))
}
message("filtering fw.data.1.AllData (this takes a minute)")
fw <- read_tsv_chunked(file.path(raw_dir, "fw.data.1.AllData"), DataFrameCallback$new(keep_rows),
                       chunk_size = 1e6, col_types = cols(.default = col_character()), progress = FALSE)

categories <- read_map("fw.category") |>
  filter(case_code == "0") |>
  transmute(category_code,
            group = str_trim(str_extract(category_text, "^[^-]+(?=--)")),
            category = str_trim(str_remove(category_text, "^[^-]+--")))
categories$group[categories$category_code == "00X"] <- "All"
areas <- read_map("fw.area") |> select(area_code, state = area_text)

national <- fw |>
  filter(area_code == "N00", case_code == "0") |>
  left_join(categories, by = "category_code") |>
  select(year, group, category, category_code, fatalities) |>
  arrange(group, category_code, year)

states <- fw |>
  filter(str_starts(area_code, "S")) |>
  left_join(categories, by = "category_code") |>
  left_join(areas, by = "area_code") |>
  mutate(area_type = case_when(area_code %in% c("S36", "S68") ~ "New York part",
                               area_code %in% c("S43", "S52", "S66") ~ "Territory",
                               TRUE ~ "State or DC")) |>
  select(state_code = area_code, state, area_type, year, group, category, category_code, fatalities) |>
  arrange(state_code, group, category_code, year)

detail_maps <- bind_rows(
  read_map("fw.industry") |> transmute(map = "industry", detail_code = industry_code, label = industry_text, display_level),
  read_map("fw.occupation") |> transmute(map = "occupation", detail_code = occupation_code, label = occupation_text, display_level),
  read_map("fw.event") |> transmute(map = "event", detail_code = event_code, label = event_text, display_level),
  read_map("fw.source") |> transmute(map = "source", detail_code = source_code, label = source_text, display_level)
) |> mutate(display_level = as.integer(display_level))

by_detail <- fw |>
  filter(area_code == "N00", case_code %in% detail_cases) |>
  mutate(detail_type = recode(case_code, "1" = "industry (private)", "9" = "industry (government)",
                              "O" = "occupation", "E" = "event", "S" = "primary source"),
         map = recode(case_code, "1" = "industry", "9" = "industry", "O" = "occupation",
                      "E" = "event", "S" = "source")) |>
  left_join(detail_maps, by = c("map", "detail_code")) |>
  select(detail_type, code = detail_code, label, display_level, year, fatalities) |>
  arrange(detail_type, code, year)

# --- 2. Parse the hours-based rate tables -------------------------------------------
sections <- c("Employee status", "Sex", "Gender", "Age", "Race or ethnic origin", "Occupation", "Industry")
drop_footnote <- function(x) str_squish(str_remove(x, "(?<=[A-Za-z)])\\d+$"))

read_rates <- function(path) {
  year <- as.integer(str_extract(basename(path), "\\d{4}"))
  df <- suppressMessages(read_excel(path, col_names = FALSE, col_types = "text"))
  names(df)[1:5] <- c("characteristic", "code", "hours", "rate", "moe")
  df <- df[-(1:2), 1:5]
  end <- which(str_detect(df$characteristic, "^1 ") | str_starts(df$characteristic, "Note"))[1]
  df <- df[seq_len(end - 1), ] |>
    filter(!is.na(characteristic), characteristic != "no data") |>
    mutate(characteristic = drop_footnote(characteristic))
  section <- ifelse(df$characteristic %in% sections, df$characteristic,
                    ifelse(df$characteristic == "Total", "Total", NA))
  df$section <- section
  df <- tidyr::fill(df, section)
  df$section[df$section == "Gender"] <- "Sex"  # the 2023 table says "Gender", 2024 says "Sex"
  number <- function(x) suppressWarnings(as.numeric(x))
  df |>
    filter(!characteristic %in% c(sections, "Civilian Occupations")) |>
    transmute(year, section, characteristic, code = na_if(str_squish(code), ""),
              hours_millions = number(hours), rate_per_100k_fte = number(rate),
              margin_of_error = number(moe))
}
rate_files <- list.files(raw_dir, pattern = "hours-based-rates-\\d{4}\\.xlsx$", full.names = TRUE)
rates <- bind_rows(lapply(rate_files, read_rates))

# --- 3. Write -------------------------------------------------------------------------
tables <- list(cfoi_national = national, cfoi_by_detail = by_detail,
               cfoi_states = states, cfoi_rates = rates)
for (name in names(tables)) {
  path <- file.path(tidy_dir, paste0(name, ".csv"))
  write_csv(tables[[name]], path, na = "")
  message(sprintf("%s: %s rows, %.1f MB", basename(path), format(nrow(tables[[name]]), big.mark = ","),
                  file.size(path) / 1e6))
}

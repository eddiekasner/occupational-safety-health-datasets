# Build the tidy table of work-related deaths in Japan from the yearly Excel files of MHLW's
# fatal accident database (死亡災害データベース).
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads data/raw/sibou_db_*.xls(x) (from fetch_data.R) and writes:
#   data/tidy/fatalities.csv.gz   one row per person killed, 1991 to the latest year, with the
#                                 Japanese narrative, codes, Japanese labels and English labels
#   data/tidy/code_labels.csv     the English translation of each code used
#
# English labels are this module's translations of MHLW's categories (industry sector and
# subgroup, agent group and subgroup, accident type). The detailed industry and agent categories
# are kept in Japanese. English narratives, where available, come from
# data/tidy/narratives_en.csv (machine translations; see the README).

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(stringr)
  library(purrr)
  library(stringi)
})

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
raw_dir <- file.path(module_dir, "data", "raw")
tidy_dir <- file.path(module_dir, "data", "tidy")
dir.create(tidy_dir, recursive = TRUE, showWarnings = FALSE)

# ---- English labels --------------------------------------------------------------------------

industry_sectors <- c(
  "01" = "Manufacturing", "02" = "Mining", "03" = "Construction",
  "04" = "Transport", "05" = "Cargo handling", "06" = "Agriculture and forestry",
  "07" = "Livestock and fisheries", "08" = "Commerce", "09" = "Finance and advertising",
  "10" = "Film and theatre", "11" = "Communications", "12" = "Education and research",
  "13" = "Health care and social welfare", "14" = "Hotels, restaurants and entertainment",
  "15" = "Cleaning, waste and slaughtering", "16" = "Government offices", "17" = "Other industries")

industry_groups <- c(
  "0101" = "Food", "0102" = "Textiles", "0103" = "Textile products and clothing",
  "0104" = "Wood and wood products", "0105" = "Furniture and fixtures",
  "0106" = "Pulp, paper and paper products", "0107" = "Printing and binding",
  "0108" = "Chemicals", "0109" = "Ceramics, stone and clay products", "0110" = "Iron and steel",
  "0111" = "Non-ferrous metals", "0112" = "Fabricated metal products", "0113" = "Machinery",
  "0114" = "Electrical machinery", "0115" = "Transport equipment",
  "0116" = "Electricity, gas and water", "0117" = "Other manufacturing",
  "0201" = "Coal mining", "0202" = "Quarrying (stone, sand and gravel)", "0203" = "Other mining",
  "0301" = "Civil engineering", "0302" = "Building construction", "0303" = "Other construction",
  "0401" = "Rail, water and air transport", "0402" = "Road passenger transport (bus, taxi)",
  "0403" = "Road freight transport (trucking)", "0404" = "Other transport",
  "0501" = "Land cargo handling", "0502" = "Port cargo handling",
  "0601" = "Agriculture", "0602" = "Forestry", "0701" = "Livestock", "0702" = "Fisheries",
  "0801" = "Wholesale", "0802" = "Retail", "0803" = "Hairdressing and beauty",
  "0804" = "Other commerce", "0901" = "Finance", "0902" = "Advertising and agencies",
  "1001" = "Film and theatre", "1101" = "Communications", "1201" = "Education and research",
  "1301" = "Medical care", "1302" = "Social welfare facilities",
  "1303" = "Other health and hygiene", "1401" = "Hotels and inns", "1402" = "Restaurants",
  "1403" = "Other hospitality and entertainment", "1501" = "Cleaning, waste and slaughtering",
  "1601" = "Government offices", "1701" = "Temporary staffing (worker dispatch)",
  "1702" = "Other industries")

agent_groups <- c(
  "1" = "Power machinery", "2" = "Lifting and transport machinery, vehicles",
  "3" = "Other equipment", "4" = "Temporary structures, buildings and structures",
  "5" = "Substances and materials", "6" = "Loads", "7" = "Environment", "9" = "Other")

agent_subgroups <- c(
  "11" = "Engines", "12" = "Power transmission", "13" = "Woodworking machinery",
  "14" = "Construction machinery", "15" = "Metalworking machinery",
  "16" = "Other powered machinery", "17" = "Timber harvesting vehicles",
  "21" = "Cranes and similar", "22" = "Powered transport machinery (trucks, forklifts, conveyors)",
  "23" = "Vehicles (cars, buses, motorcycles, trains, ships, aircraft)",
  "31" = "Pressure vessels", "32" = "Chemical plant", "33" = "Welding equipment",
  "34" = "Furnaces and kilns", "35" = "Electrical equipment", "36" = "Hand-powered machines and tools",
  "37" = "Tools and equipment (ladders, slings, scaffold boards)", "39" = "Other equipment",
  "41" = "Temporary structures, buildings and structures",
  "51" = "Hazardous and harmful substances", "52" = "Materials", "61" = "Loads",
  "71" = "Environment (ground, water, heat, weather)", "91" = "Other agents",
  "92" = "No agent", "99" = "Unclassifiable")

accident_types <- c(
  "1" = "Fall from height", "2" = "Fall on the same level (slip or trip)",
  "3" = "Striking against an object", "4" = "Struck by flying or falling object",
  "5" = "Collapse (of structures, soil or stacked material)", "6" = "Struck by moving object",
  "7" = "Caught in or between", "8" = "Cut or abrasion", "9" = "Stepping on or through",
  "10" = "Drowning", "11" = "Contact with hot or cold objects (including heatstroke)",
  "12" = "Contact with harmful substances", "13" = "Electric shock", "14" = "Explosion",
  "15" = "Rupture", "16" = "Fire", "17" = "Traffic accident (road)",
  "18" = "Traffic accident (other: rail, ship, aircraft)",
  "19" = "Overexertion or awkward movement", "90" = "Other", "99" = "Unclassifiable")

# Accident types by their Japanese label (written as Unicode escapes so that the script works in
# any locale), used where a code and its label disagree
type_labels_ja <- c("\u589c\u843d\u8ee2\u843d", "\u8ee2\u5012", "\u6fc0\u7a81",
                    "\u98db\u6765\u843d\u4e0b", "\u5d29\u58ca\u5012\u58ca",
                    "\u6fc0\u7a81\u3055\u308c",
                    "\u306f\u3055\u307e\u308c\u5dfb\u304d\u8fbc\u307e\u308c",
                    "\u5207\u308c\u3053\u3059\u308c", "\u8e0f\u307f\u629c\u304d",
                    "\u304a\u307c\u308c",
                    "\u9ad8\u6e29\u4f4e\u6e29\u306e\u7269\u3068\u306e\u63a5\u89e6",
                    "\u6709\u5bb3\u7269\u7b49\u3068\u306e\u63a5\u89e6",
                    "\u6709\u5bb3\u7269\u3068\u306e\u63a5\u89e6", "\u611f\u96fb", "\u7206\u767a",
                    "\u7834\u88c2", "\u706b\u707d", "\u4ea4\u901a\u4e8b\u6545\u9053\u8def",
                    "\u4ea4\u901a\u4e8b\u6545", "\u4ea4\u901a\u4e8b\u6545\u305d\u306e\u4ed6",
                    "\u52d5\u4f5c\u306e\u53cd\u52d5\u7121\u7406\u306a\u52d5\u4f5c",
                    "\u305d\u306e\u4ed6", "\u5206\u985e\u4e0d\u80fd")
type_label_codes <- c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "12", "13",
                      "14", "15", "16", "17", "17", "18", "19", "90", "99")

# ---- Read ------------------------------------------------------------------------------------

files <- list.files(raw_dir, pattern = "^sibou_db_.*\\.xlsx?$", full.names = TRUE)
if (!length(files)) stop("No files in ", raw_dir, ". Run fetch_data.R first.")

columns <- c("id", "month", "time", "narrative", "ind1_code", "ind1", "ind2_code", "ind2",
             "ind3_code", "ind3", "size", "ag1_code", "ag1", "ag2_code", "ag2", "ag3_code",
             "ag3", "type_code", "type")

# File names give the Japanese era year: h03 = Heisei 3 = 1991, r06 = Reiwa 6 = 2024
file_year <- function(f) {
  m <- str_match(basename(f), "_(h|r)([0-9]{2})")
  ifelse(m[, 2] == "h", 1988L, 2018L) + as.integer(m[, 3])
}

read_year <- function(f) {
  d <- read_excel(f, sheet = 1, col_names = FALSE, skip = 2, col_types = "text",
                  .name_repair = "minimal")
  if (ncol(d) != length(columns)) stop(basename(f), " has ", ncol(d), " columns, expected 19")
  names(d) <- columns
  mutate(d, year = file_year(f))
}
raw <- map_dfr(files, read_year) |>
  filter(!is.na(id))

# ---- Tidy ------------------------------------------------------------------------------------

# Text in these files mixes full-width and half-width digits and punctuation. NFKC normalisation
# turns full-width digits, brackets and the full-width space into their ordinary forms
nfkc <- function(x) stri_trans_nfkc(x)
clean <- function(x) na_if(str_squish(nfkc(x)), "")
# For matching labels: drop punctuation and spaces, which are used inconsistently
norm_label <- function(x) str_remove_all(nfkc(x), "[\\p{P}\\s]")
pad_code <- function(x, width) {
  n <- suppressWarnings(as.integer(x))
  if_else(is.na(n), NA_character_, str_pad(n, width, pad = "0"))
}

# Hour bands are written "10～11" (1 hour) or "10～12" (2 hours)
hours <- str_match(nfkc(raw$time), "^([0-9]+)\\s*[~\\u301c\\uff5e]\\s*([0-9]+)$")

fatalities <- raw |>
  mutate(
    narrative = clean(narrative),
    ind1_code = pad_code(ind1_code, 2),
    ind2_code = pad_code(ind2_code, 4),
    ind3_code = pad_code(ind3_code, 6),
    ag1_code = as.character(suppressWarnings(as.integer(ag1_code))),
    ag2_code = as.character(suppressWarnings(as.integer(ag2_code))),
    type_code = as.character(suppressWarnings(as.integer(type_code))),
    type_code = coalesce(type_label_codes[match(norm_label(type), type_labels_ja)], type_code),
    size_reported = clean(size),
    hour_start = as.integer(hours[, 2]),
    hour_end = as.integer(hours[, 3])
  ) |>
  mutate(
    # A few bands are written backwards ("8～7" for 7 to 8)
    swap = coalesce(hour_end < hour_start & hour_end != 0, FALSE),
    hour_start = if_else(swap, hour_end, hour_start),
    hour_end = if_else(swap, hour_start + 1L, hour_end),
    size_num = suppressWarnings(as.integer(str_remove_all(
      str_extract(size_reported, "^[0-9,]+"), ","))),
    establishment_size = case_when(
      is.na(size_num) ~ "Unknown",
      size_num < 10 ~ "Under 10",
      size_num < 30 ~ "10-29",
      size_num < 50 ~ "30-49",
      size_num < 100 ~ "50-99",
      size_num < 300 ~ "100-299",
      TRUE ~ "300+")
  ) |>
  transmute(
    year, id = as.integer(id), month = as.integer(month),
    time_band = clean(time), hour_start, hour_end,
    establishment_size, size_reported,
    industry_sector = unname(industry_sectors[ind1_code]),
    industry_group = unname(industry_groups[ind2_code]),
    agent_group = unname(agent_groups[ag1_code]),
    agent_subgroup = unname(agent_subgroups[ag2_code]),
    accident_type = unname(accident_types[type_code]),
    industry_sector_code = ind1_code, industry_group_code = ind2_code,
    industry_detail_code = ind3_code, industry_detail_ja = clean(ind3),
    agent_group_code = ag1_code, agent_subgroup_code = ag2_code,
    agent_detail_code = clean(ag3_code), agent_detail_ja = clean(ag3),
    accident_type_code = type_code,
    narrative_ja = narrative
  )

# One event can kill several people; each has a row with the same description
fatalities <- fatalities |>
  group_by(year, month, time_band, narrative_ja, size_reported, industry_sector_code,
           industry_group_code, industry_detail_code, agent_detail_code, accident_type_code) |>
  mutate(event_id = sprintf("%d-%04d", year, min(id)), deaths_in_event = n()) |>
  ungroup() |>
  relocate(event_id, deaths_in_event, .after = id)

# English narratives (machine translations), where available
en_path <- file.path(tidy_dir, "narratives_en.csv")
if (file.exists(en_path)) {
  en <- read_csv(en_path, col_types = cols(year = "i", id = "i", narrative_en = "c"))
  fatalities <- left_join(fatalities, en, by = c("year", "id"))
} else {
  fatalities$narrative_en <- NA_character_
}
fatalities <- arrange(fatalities, year, id)

# ---- Checks ----------------------------------------------------------------------------------

stopifnot(!anyDuplicated(select(fatalities, year, id)))
unlabelled <- fatalities |>
  summarise(sector = sum(is.na(industry_sector)), agent = sum(is.na(agent_group)),
            type = sum(is.na(accident_type)))
message("Rows without an English label: sector ", unlabelled$sector, ", agent group ",
        unlabelled$agent, ", accident type ", unlabelled$type)

code_labels <- bind_rows(
  tibble(field = "industry_sector", code = names(industry_sectors), label_en = industry_sectors),
  tibble(field = "industry_group", code = names(industry_groups), label_en = industry_groups),
  tibble(field = "agent_group", code = names(agent_groups), label_en = agent_groups),
  tibble(field = "agent_subgroup", code = names(agent_subgroups), label_en = agent_subgroups),
  tibble(field = "accident_type", code = names(accident_types), label_en = accident_types))
# Add the most common Japanese label for each code
ja <- bind_rows(
  transmute(raw, field = "industry_sector", code = pad_code(ind1_code, 2), label_ja = clean(ind1)),
  transmute(raw, field = "industry_group", code = pad_code(ind2_code, 4), label_ja = clean(ind2)),
  transmute(raw, field = "agent_group", code = as.character(as.integer(ag1_code)), label_ja = clean(ag1)),
  transmute(raw, field = "agent_subgroup", code = as.character(as.integer(ag2_code)), label_ja = clean(ag2)),
  transmute(raw, field = "accident_type", code = as.character(as.integer(type_code)), label_ja = clean(type))) |>
  filter(!is.na(code), !is.na(label_ja)) |>
  count(field, code, label_ja) |>
  group_by(field, code) |>
  slice_max(n, n = 1, with_ties = FALSE) |>
  ungroup() |>
  select(-n)
code_labels <- left_join(code_labels, ja, by = c("field", "code"))

write_csv(fatalities, file.path(tidy_dir, "fatalities.csv.gz"), na = "")
write_csv(code_labels, file.path(tidy_dir, "code_labels.csv"), na = "")

fatalities |> count(year) |> print(n = 50)
message(nrow(fatalities), " deaths in ", n_distinct(fatalities$event_id), " events")

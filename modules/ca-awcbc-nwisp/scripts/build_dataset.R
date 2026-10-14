# Build tidy tables from the AWCBC National Work Injury, Disease and Fatality Statistics
# publication (PDF).
#
# Usage:  Rscript scripts/build_dataset.R
#
# Needs the `pdftotext` command (part of Poppler: on macOS `brew install poppler`, on Linux the
# poppler-utils package, on Windows the Xpdf command line tools). Reads the publication in
# data/raw/ (from fetch_data.R) and writes to data/tidy/:
#   nwisp_jurisdiction_trend.csv  lost time claims 1982-2024 and fatalities 1993-2024, by province
#   nwisp_jurisdiction.csv.gz     claims and fatalities by gender, age, nature of injury, part of
#                                 body, source, event, occupation and industry, by province,
#                                 2022-2024
#   nwisp_industry_occupation.csv.gz  the same characteristics by industry sector and occupation
#                                 category, Canada, 2023-2024
#
# Counts of 3 or fewer are suppressed by AWCBC ("X"): value is NA and flag is "X".

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

pdf <- list.files(raw_dir, pattern = "^National-Work-Injury.*\\.pdf$", full.names = TRUE)
if (length(pdf) != 1) stop("Expected one NWISP publication PDF in ", raw_dir, ". Run fetch_data.R.")
if (!nzchar(Sys.which("pdftotext"))) stop("The pdftotext command was not found (see the top of this script).")

txt <- tempfile(fileext = ".txt")
system2("pdftotext", c("-layout", shQuote(pdf), shQuote(txt)))
pages <- strsplit(read_file(txt, locale = locale(encoding = "UTF-8")), "\f", fixed = TRUE)[[1]]

jurisdictions <- c("Total", "NL", "PE", "NS", "NB", "QC", "ON", "MB", "SK", "AB", "BC", "NT/NU", "YT")
num <- "(?:[0-9][0-9,]*|X)"

# --- What each table contains -----------------------------------------------------------------

characteristics <- c("gender", "age", "nature of injury", "part of body", "source of injury",
                     "event", "occupation")
tables <- bind_rows(
  tibble(table = 1L, outcome = "lost time claims", characteristic = NA, by = "jurisdiction"),
  tibble(table = 2:8, outcome = "lost time claims", characteristic = characteristics,
         by = "jurisdiction"),
  tibble(table = 9:14, outcome = "lost time claims", characteristic = characteristics[1:6],
         by = "occupation"),
  tibble(table = 15L, outcome = "lost time claims", characteristic = "industry", by = "jurisdiction"),
  tibble(table = 16:21, outcome = "lost time claims", characteristic = characteristics[1:6],
         by = "industry"),
  tibble(table = 22L, outcome = "fatalities", characteristic = NA, by = "jurisdiction"),
  tibble(table = 23:29, outcome = "fatalities", characteristic = characteristics, by = "jurisdiction"),
  tibble(table = 30:35, outcome = "fatalities", characteristic = characteristics[1:6], by = "occupation"),
  tibble(table = 36L, outcome = "fatalities", characteristic = "industry", by = "jurisdiction"),
  tibble(table = 37:42, outcome = "fatalities", characteristic = characteristics[1:6], by = "industry")
)

page_table <- as.integer(str_match(pages, "^\\s*Table (\\d+)\\s+Tableau")[, 2])

# --- Row labels -------------------------------------------------------------------------------

# Rows start with a code at the left margin (for example "01", "NC", "31-") followed by the label,
# which may wrap onto the next lines. A code ending in "-" continues on the next line ("31-" "33").
# `left` is the text of each line to the left of the numbers. Returns the block number of each
# line (0 = before the first row) and the code and label of each block.
code_pattern <- "^\\s{0,8}([0-9]{1,2}-?(?=\\s{2})|NC(?=\\s))\\s+"
label_blocks <- function(left) {
  code <- str_match(left, code_pattern)[, 2]
  text <- str_remove(left, code_pattern)
  is_total <- str_detect(left, "^\\s*(Total|Not Coded)\\b")
  block <- integer(length(left))
  codes <- character(0)
  labels <- character(0)
  current <- 0L
  for (i in seq_along(left)) {
    continues_code <- current > 0 && str_ends(codes[current], "-") && !is.na(code[i]) &&
      str_detect(code[i], "^[0-9]{2}$")
    if ((!is.na(code[i]) || is_total[i]) && !continues_code) {
      current <- current + 1L
      codes[current] <- code[i]
      labels[current] <- ""
    } else if (continues_code) {
      codes[current] <- paste0(codes[current], code[i])
    }
    block[i] <- current
    # Keep only the English part: on some pages the French label follows after a wide gap
    english <- str_split(str_trim(if (is.na(code[i])) left[i] else text[i]), "\\s{3,}")[[1]][1]
    if (current > 0) labels[current] <- paste(labels[current], english)
  }
  list(block = block,
       blocks = tibble(block = seq_along(codes), code = codes, label = fix_label(labels)))
}

# Words broken across lines by the PDF's narrow columns
fix_label <- function(x) {
  x |>
    str_squish() |>
    str_replace_all(c("(\\w)- (\\w)" = "\\1-\\2", " \\(s\\)" = "(s)", " \\)" = ")",
                      "Paraprofessio nal" = "Paraprofessional", "Accommodati on" = "Accommodation",
                      "representative s" = "representatives", "Musculoskelet al" = "Musculoskeletal",
                      "Laryngophary nx" = "Laryngopharynx", "nonpressurize d" = "nonpressurized",
                      "insect s" = "insects", "nonvenomou s" = "nonvenomous"))
}

drop_footer <- function(lines) {
  source_line <- which(str_detect(lines, "^\\s*Source:"))[1]
  if (is.na(source_line)) lines else lines[seq_len(source_line - 1)]
}

# --- Tables by jurisdiction (and the two time series) -----------------------------------------

parse_jurisdiction_page <- function(page, table) {
  lines <- drop_footer(str_split(page, "\n")[[1]])
  pattern <- paste0("(?<![0-9])((?:19|20)[0-9]{2})\\s+(", num, "(?:\\s+", num, "){13})\\s+(?:19|20)[0-9]{2}")
  m <- str_match(lines, pattern)
  is_data <- !is.na(m[, 1])
  if (!any(is_data)) return(NULL)
  # Labels are to the left of the year column; page headings are above the first data line
  ycol <- min(str_locate(lines[is_data], pattern)[, 1])
  keep <- seq_along(lines) >= which(is_data)[1]
  lb <- label_blocks(str_sub(lines[keep], 1, ycol - 1))
  tibble(block = lb$block, year = as.integer(m[keep, 2]), values = m[keep, 3]) |>
    filter(!is.na(values)) |>
    mutate(values = str_split(str_squish(values), " ")) |>
    left_join(lb$blocks, by = "block") |>
    # The Total column is printed at both ends of the row
    mutate(table = table, jurisdiction = list(c(jurisdictions, "Total (repeated)"))) |>
    unnest(c(values, jurisdiction)) |>
    filter(jurisdiction != "Total (repeated)") |>
    select(table, code, label, year, jurisdiction, raw = values)
}

jurisdiction_tables <- tables$table[tables$by == "jurisdiction"]
by_jurisdiction <- bind_rows(lapply(which(page_table %in% jurisdiction_tables), \(i)
  parse_jurisdiction_page(pages[i], page_table[i])))

# --- Tables by industry or occupation ---------------------------------------------------------

# Each page shows a few industries or occupations as column pairs (2023, 2024), with the code of
# each industry or occupation centred above its pair; the first page of each table starts with
# the Total pair. A pair can be split across two pages, so each year column is matched to the
# nearest code above it.
parse_division_page <- function(page, table) {
  lines <- drop_footer(str_split(page, "\n")[[1]])
  year_line <- which(str_detect(lines, "^\\s*(?:20[0-9]{2}\\s+)*20[0-9]{2}\\s*$"))[1]
  if (is.na(year_line)) return(NULL)
  year_loc <- str_locate_all(lines[year_line], "20[0-9]{2}")[[1]]
  years <- as.integer(str_sub(lines[year_line], year_loc[, "start"], year_loc[, "end"]))
  code_line <- max(which(str_detect(lines[seq_len(year_line - 1)], "\\S")))
  code_loc <- str_locate_all(lines[code_line], "\\S+")[[1]]
  codes <- str_sub(lines[code_line], code_loc[, "start"], code_loc[, "end"])
  # The Total column has no code; the word "Total" appears in the column headings
  header <- lines[4:(code_line - 1)]
  total_hit <- which(str_detect(header, "\\bTotal\\b"))
  if (length(total_hit)) {
    codes <- c("Total", codes)
  }
  # Group the year columns into units: a (2023, 2024) pair, or a lone year when a pair is split
  # across pages. Units and codes are in the same left-to-right order.
  unit <- integer(length(years))
  u <- 0L
  i <- 1L
  while (i <= length(years)) {
    u <- u + 1L
    unit[i] <- u
    if (i < length(years) && years[i] < years[i + 1]) {
      unit[i + 1] <- u
      i <- i + 2L
    } else {
      i <- i + 1L
    }
  }
  if (u != length(codes)) stop("Table ", table, ": ", u, " column groups but ", length(codes), " codes")
  groups <- codes[unit]
  body <- lines[(year_line + 1):length(lines)]
  # Numbers are right-aligned under their year heading (within a few characters). Matching by
  # position copes with pages where the French label and the row code sit before the numbers.
  year_end <- year_loc[, "end"]
  values <- lapply(body, \(line) {
    tok <- str_locate_all(line, paste0("(?<!\\S)", num, "(?!\\S)"))[[1]]
    if (nrow(tok) < length(year_end)) return(NULL)
    pick <- sapply(year_end, \(e) {
      d <- abs(tok[, "end"] - e)
      if (min(d) <= 6) which.min(d) else NA_integer_
    })
    if (anyNA(pick) || anyDuplicated(pick)) return(NULL)
    str_sub(line, tok[pick, "start"], tok[pick, "end"])
  })
  is_data <- !sapply(values, is.null)
  if (!any(is_data)) return(NULL)
  # Labels are to the left of the first number column
  first_col <- min(year_loc[, "start"]) - 6
  left <- str_sub(body, 1, first_col)
  lb <- label_blocks(left)
  # Each category has one row of numbers here, so a second row in a block is an unlabelled Total
  # row (as at the end of some pages of table 10)
  tibble(block = lb$block, values = values) |>
    filter(is_data, block > 0) |>
    left_join(lb$blocks, by = "block") |>
    mutate(unlabelled_total = duplicated(block),
           code = if_else(unlabelled_total, "Total", code),
           label = if_else(unlabelled_total, "Total", label)) |>
    mutate(table = table, group_code = list(groups), year = list(years)) |>
    unnest(c(values, group_code, year)) |>
    select(table, code, label, group_code, year, raw = values)
}

division_tables <- tables$table[tables$by != "jurisdiction"]
by_division <- bind_rows(lapply(which(page_table %in% division_tables), \(i)
  parse_division_page(pages[i], page_table[i])))

# --- Tidy up ----------------------------------------------------------------------------------

finish <- function(d) {
  d |>
    left_join(tables, by = "table") |>
    mutate(flag = if_else(raw == "X", "X", NA_character_),
           value = suppressWarnings(as.numeric(str_remove_all(raw, ","))),
           code = case_when(label == "Total" & is.na(code) ~ "Total",
                            str_detect(label, "^Not [Cc]oded$") ~ "NC", TRUE ~ code),
           category = case_when(code == "NC" ~ "Not coded", TRUE ~ na_if(label, ""))) |>
    select(-raw, -label)
}

trend <- by_jurisdiction |>
  filter(table %in% c(1, 22)) |>
  finish() |>
  distinct(outcome, year, jurisdiction, value, flag) |>
  arrange(outcome, jurisdiction, year)

jurisdiction <- by_jurisdiction |>
  filter(!table %in% c(1, 22)) |>
  finish() |>
  select(outcome, characteristic, code, category, year, jurisdiction, value, flag)

# Names of the industry sectors (NAICS) and occupation categories (NOC 2011) in the column codes
industry_names <- jurisdiction |>
  filter(characteristic == "industry") |>
  distinct(group_code = code, group = category) |>
  distinct(group_code, .keep_all = TRUE)
occupation_names <- tibble(
  group_code = as.character(0:9),
  group = c("Management occupations", "Business, finance and administration occupations",
            "Natural and applied sciences and related occupations", "Health occupations",
            "Occupations in education, law and social, community and government services",
            "Occupations in art, culture, recreation and sport", "Sales and service occupations",
            "Trades, transport and equipment operators and related occupations",
            "Natural resources, agriculture and related production occupations",
            "Occupations in manufacturing and utilities")) |>
  bind_rows(tibble(group_code = c("NS", "NC"), group = c("Occupation not stated", "Not coded")))

division <- by_division |>
  finish() |>
  left_join(bind_rows(mutate(industry_names, by = "industry"),
                      mutate(occupation_names, by = "occupation")),
            by = c("by", "group_code")) |>
  mutate(group = case_when(group_code == "Total" ~ "All", TRUE ~ coalesce(group, group_code))) |>
  distinct() |>
  select(outcome, characteristic, by, group_code, group, code, category, year, value, flag)

# The same category can be printed with different line breaks in different tables (and on narrow
# pages French words can creep in). Use the spelling found in the most rows for each code.
labels <- bind_rows(select(jurisdiction, characteristic, code, category),
                    select(division, characteristic, code, category)) |>
  count(characteristic, code, category) |>
  group_by(characteristic, code) |>
  slice_max(n, n = 1, with_ties = FALSE) |>
  select(characteristic, code, label = category)
jurisdiction <- jurisdiction |>
  left_join(labels, by = c("characteristic", "code")) |>
  mutate(category = coalesce(label, category)) |>
  select(-label)
division <- division |>
  left_join(labels, by = c("characteristic", "code")) |>
  mutate(category = coalesce(label, category)) |>
  select(-label)

# --- Checks against the publication -----------------------------------------------------------

stopifnot(!anyDuplicated(select(trend, outcome, year, jurisdiction)),
          !anyDuplicated(select(jurisdiction, outcome, characteristic, code, year, jurisdiction)),
          !anyDuplicated(select(division, outcome, characteristic, by, group_code, code, year)))

check <- function(d, ..., expected) {
  got <- filter(d, ...)$value
  if (length(got) != 1 || is.na(got) || got != expected) {
    stop("Check failed: expected ", expected, ", got ", paste(got, collapse = ", "))
  }
}
check(trend, outcome == "lost time claims", year == 1982, jurisdiction == "Total", expected = 479558)
check(trend, outcome == "lost time claims", year == 2024, jurisdiction == "ON", expected = 143562)
check(jurisdiction, outcome == "lost time claims", characteristic == "gender", category == "Female",
      year == 2022, jurisdiction == "QC", expected = 69380)
check(jurisdiction, outcome == "lost time claims", characteristic == "industry", code == "31-33",
      year == 2024, jurisdiction == "ON", expected = 15810)
check(division, outcome == "lost time claims", characteristic == "gender", by == "occupation",
      group_code == "3", category == "Female", year == 2024, expected = 53271)

# Every characteristic table adds up to the published total for Canada
totals <- trend |> filter(jurisdiction == "Total") |> select(outcome, year, total = value)
sums <- jurisdiction |>
  filter(jurisdiction == "Total", code == "Total") |>
  left_join(totals, by = c("outcome", "year"))
if (any(sums$value != sums$total, na.rm = TRUE)) {
  print(filter(sums, value != total))
  stop("Table totals do not match the overall totals")
}

# Industry and occupation totals match the industry and occupation tables by jurisdiction
group_totals <- division |>
  filter(code == "Total", group_code != "Total", group_code != "NS") |>
  select(outcome, characteristic, by, group_code, year, value) |>
  left_join(jurisdiction |>
              filter(characteristic %in% c("industry", "occupation"), jurisdiction == "Total") |>
              select(outcome, by = characteristic, group_code = code, year, expected = value),
            by = c("outcome", "by", "group_code", "year"))
# AWCBC's own tables differ by a death or two in a few places (for example the fatalities by part
# of body table gives 1,044 deaths in 2024, the other tables 1,046), so allow a difference of 2
mismatch <- filter(group_totals, by == "industry",
                   is.na(value) != is.na(expected) | coalesce(abs(value - expected) > 2, FALSE))
if (nrow(mismatch)) {
  print(mismatch, n = 50)
  stop("Industry totals do not match")
}
# Every table has the same number of category rows for each column (a few tables do not print a
# Total row, for example fatalities by age and industry)
row_counts <- count(filter(division, code != "Total"), outcome, characteristic, by, group_code, year)
per_table <- distinct(row_counts, outcome, characteristic, by, n)
if (anyDuplicated(select(per_table, -n))) {
  print(per_table, n = 100)
  stop("Some industry or occupation columns are missing rows")
}

write_csv(trend, file.path(tidy_dir, "nwisp_jurisdiction_trend.csv"), na = "")
write_csv(jurisdiction, file.path(tidy_dir, "nwisp_jurisdiction.csv.gz"), na = "")
write_csv(division, file.path(tidy_dir, "nwisp_industry_occupation.csv.gz"), na = "")
message("trend: ", nrow(trend), " rows; jurisdiction: ", nrow(jurisdiction),
        " rows; industry_occupation: ", nrow(division), " rows")

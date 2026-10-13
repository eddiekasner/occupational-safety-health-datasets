# Combine the yearly OSHA Chemical Exposure Health Data files into one clean table.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads data/raw/sample_data_<year>.zip (from fetch_data.R) and writes
# data/processed/chemical_exposure_1984_2025.csv. Takes a few minutes and needs
# about 2 GB of free memory.
#
# OSHA's yearly files are not consistent with each other. This script handles:
#   - 1984 to 2012: XML files (one tag per line), read line by line to save memory
#   - 2012: the office ID is stored in a second <sampling_number> tag and the blank
#     flag in a second <sample_type> tag
#   - XML tag names that differ from the CSV column names (blank_used, eight_hour_twa_calc)
#   - dates as "1984/05/07 00:00:00" (XML) or "2013-MAR-20" (CSV)
#   - NAICS and SIC codes recorded as 0 when missing
#   - inspection numbers with leading zeros in some years
#   - delimiters that switch between comma and pipe from year to year
#   - 2023: every line is wrapped in quotes
#   - 2024 and 2025: a byte-order mark at the start of the file
#   - some years: Windows-1252 characters mixed into UTF-8 text
#   - 2023: one substance name contains a pipe ("Aluminum (as Al)| Welding Fumes")
#   - 2017: stray trailing commas after the qualifier
#   - month names in upper or mixed case ("2013-MAR-20", "2023-May-12")
#   - leading spaces in city names

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
})

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
raw_dir <- file.path(module_dir, "data", "raw")
out_path <- file.path(module_dir, "data", "processed", "chemical_exposure_1984_2025.csv")

n_fields <- 24
substance_field <- 21

read_zip_lines <- function(zip_path, pattern) {
  name <- grep(pattern, unzip(zip_path, list = TRUE)$Name, ignore.case = TRUE, value = TRUE)[1]
  con <- unz(zip_path, name)
  lines <- readLines(con, warn = FALSE)
  close(con)
  lines[1] <- sub("^\xef\xbb\xbf", "", lines[1], useBytes = TRUE)  # byte-order mark
  # Some years mix in Windows-1252 characters; convert those lines to UTF-8
  bad <- !validUTF8(lines)
  lines[bad] <- iconv(lines[bad], from = "windows-1252", to = "UTF-8", sub = "?")
  Encoding(lines) <- "UTF-8"
  lines
}

decode_entities <- function(x) {
  x <- str_replace_all(x, "&#(\\d+);", \(m) intToUtf8(as.integer(str_sub(m, 3, -2)), multiple = TRUE))
  x <- str_replace_all(x, fixed("&lt;"), "<")
  x <- str_replace_all(x, fixed("&gt;"), ">")
  x <- str_replace_all(x, fixed("&quot;"), "\"")
  x <- str_replace_all(x, fixed("&apos;"), "'")
  str_replace_all(x, fixed("&amp;"), "&")
}

read_year_xml <- function(zip_path) {
  lines <- read_zip_lines(zip_path, "\\.xml$")
  record <- cumsum(str_detect(lines, fixed("<DATA_RECORD>")))
  m <- str_match(lines, "^\\s*<([a-z_0-9]+)>(.*)</\\1>\\s*$")
  rm(lines)
  keep <- !is.na(m[, 1])
  tag <- m[keep, 2]
  value <- m[keep, 3]
  rec <- record[keep]
  rm(m, record)

  # 2012: a repeated tag within one record holds a different field
  repeated <- duplicated(paste(rec, tag))
  tag[repeated & tag == "sampling_number"] <- "office_id"
  tag[repeated & tag == "sample_type"] <- "blank_sample"
  tag[tag == "blank_used"] <- "blank_sample"
  tag[tag == "eight_hour_twa_calc"] <- "eight_hr_twa_calc"

  n <- max(rec)
  cols <- unique(tag)
  df <- as_tibble(lapply(setNames(cols, cols), function(tg) {
    v <- rep(NA_character_, n)
    i <- tag == tg
    v[rec[i]] <- decode_entities(value[i])
    v
  }))
  df$source_file <- basename(zip_path)
  df
}

read_year_csv <- function(zip_path) {
  lines <- read_zip_lines(zip_path, "\\.csv$")
  lines <- lines[nzchar(lines)]
  if (startsWith(lines[1], "\"INSPECTION")) lines <- sub('^"(.*)"$', "\\1", lines)

  if (str_count(lines[1], fixed("|")) > str_count(lines[1], fixed(","))) {
    # Pipe-delimited files have no quoting, so split by hand
    fields <- str_split(lines, fixed("|"))
    fields <- lapply(fields, function(f) {
      extra <- length(f) - n_fields
      if (extra > 0) {
        # A pipe inside the substance name: rejoin it
        f[substance_field] <- paste(f[substance_field:(substance_field + extra)], collapse = "|")
        f <- f[-((substance_field + 1):(substance_field + extra))]
      }
      f
    })
    header <- fields[[1]]
    df <- as_tibble(do.call(rbind, fields[-1]), .name_repair = "minimal")
    names(df) <- header
  } else {
    df <- read_csv(I(paste(lines, collapse = "\n")),
                   col_types = cols(.default = col_character()), progress = FALSE)
  }
  names(df) <- str_remove(tolower(str_trim(names(df))), ",+$")
  stopifnot(ncol(df) == n_fields)
  df$source_file <- basename(zip_path)
  df
}

parse_osha_date <- function(x) {
  # "2013-MAR-20" / "2023-May-12" (CSV years) or "1984/05/07 00:00:00" (XML years)
  parts <- str_match(str_to_upper(x), "^(\\d{4})-([A-Z]{3})-(\\d{1,2})$")
  month <- match(parts[, 3], toupper(month.abb))
  csv_style <- as.Date(sprintf("%s-%02d-%02d", parts[, 2], month, as.integer(parts[, 4])), optional = TRUE)
  xml_style <- as.Date(str_sub(x, 1, 10), format = "%Y/%m/%d", optional = TRUE)
  coalesce(csv_style, xml_style)
}

columns <- c("inspection_number", "establishment_name", "city", "state", "zip_code", "sic_code",
             "naics_code", "sampling_number", "office_id", "date_sampled", "date_reported",
             "eight_hr_twa_calc", "instrument_type", "lab_number", "field_number", "sample_type",
             "blank_sample", "time_sampled", "air_volume_sampled", "sample_weight",
             "imis_substance_code", "substance", "sample_result", "unit_of_measurement", "qualifier")

years <- 1984:2025
files <- file.path(raw_dir, sprintf("sample_data_%d.zip", years))
files <- files[file.exists(files)]
if (length(files) == 0) stop("No sample_data_<year>.zip files in ", raw_dir, ". Run fetch_data.R first.")

combined <- bind_rows(lapply(files, function(f) {
  is_xml <- any(grepl("\\.xml$", unzip(f, list = TRUE)$Name, ignore.case = TRUE))
  df <- if (is_xml) read_year_xml(f) else read_year_csv(f)
  message(sprintf("%s: %s rows", basename(f), format(nrow(df), big.mark = ",")))
  df
}))

clean <- combined |>
  mutate(
    across(everything(), \(x) na_if(str_trim(x), "")),
    qualifier = na_if(str_remove(qualifier, ",+$"), ""),
    inspection_number = str_remove(inspection_number, "^0+(?=\\d)"),
    naics_code = na_if(naics_code, "0"),
    sic_code = na_if(sic_code, "0"),
    file_year = as.integer(str_extract(source_file, "\\d{4}")),
    date_sampled = parse_osha_date(date_sampled),
    date_reported = parse_osha_date(date_reported),
    across(c(time_sampled, air_volume_sampled, sample_weight, sample_result),
           \(x) suppressWarnings(as.numeric(x)))
  ) |>
  select(all_of(columns), file_year)

dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
write_csv(clean, out_path, na = "")
message(sprintf("wrote %s rows to %s (%.0f MB)", format(nrow(clean), big.mark = ","),
                out_path, file.size(out_path) / 1e6))

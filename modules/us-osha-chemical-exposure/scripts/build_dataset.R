# Combine the yearly OSHA Chemical Exposure Health Data files into one clean table.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads data/raw/sample_data_<year>.zip (from fetch_data.R) and writes
# data/processed/chemical_exposure_2013_2025.csv.
#
# OSHA's yearly files are not consistent with each other. This script handles:
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
out_path <- file.path(module_dir, "data", "processed", "chemical_exposure_2013_2025.csv")

n_fields <- 24
substance_field <- 21

read_year <- function(zip_path) {
  csv_name <- grep("\\.csv$", unzip(zip_path, list = TRUE)$Name, ignore.case = TRUE, value = TRUE)[1]
  con <- unz(zip_path, csv_name)
  lines <- readLines(con, warn = FALSE)
  close(con)
  lines[1] <- sub("^\xef\xbb\xbf", "", lines[1], useBytes = TRUE)  # byte-order mark
  # Some years mix in Windows-1252 characters; convert those lines to UTF-8
  bad <- !validUTF8(lines)
  lines[bad] <- iconv(lines[bad], from = "windows-1252", to = "UTF-8", sub = "?")
  Encoding(lines) <- "UTF-8"
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
  parts <- str_match(str_to_upper(x), "^(\\d{4})-([A-Z]{3})-(\\d{1,2})$")
  month <- match(parts[, 3], toupper(month.abb))
  as.Date(sprintf("%s-%02d-%02d", parts[, 2], month, as.integer(parts[, 4])), optional = TRUE)
}

years <- 2013:2025
files <- file.path(raw_dir, sprintf("sample_data_%d.zip", years))
files <- files[file.exists(files)]
if (length(files) == 0) stop("No sample_data_<year>.zip files in ", raw_dir, ". Run fetch_data.R first.")

combined <- bind_rows(lapply(files, function(f) {
  df <- read_year(f)
  message(sprintf("%s: %s rows", basename(f), format(nrow(df), big.mark = ",")))
  df
}))

clean <- combined |>
  mutate(
    across(everything(), \(x) na_if(str_trim(x), "")),
    qualifier = na_if(str_remove(qualifier, ",+$"), ""),
    file_year = as.integer(str_extract(source_file, "\\d{4}")),
    date_sampled = parse_osha_date(date_sampled),
    date_reported = parse_osha_date(date_reported),
    across(c(time_sampled, air_volume_sampled, sample_weight, sample_result),
           \(x) suppressWarnings(as.numeric(x)))
  ) |>
  select(-source_file)

dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
write_csv(clean, out_path, na = "")
message(sprintf("wrote %s rows to %s (%.0f MB)", format(nrow(clean), big.mark = ","),
                out_path, file.size(out_path) / 1e6))

# Turn the raw Eurostat ESAW downloads into tidy tables for analysis.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads data/raw/<table>/<geo>.json (from fetch_data.R) and writes to data/tidy/:
#   esaw_main.csv      accidents by country, year, sex, age and severity, with numbers,
#                      standardised incidence rates and percentages (hsw_mi01)
#   esaw_sector.csv    fatal and non-fatal accidents by NACE Rev. 2 section, with numbers
#                      and incidence rates (hsw_n2_01, hsw_n2_02)
#   esaw_causes.csv.gz accidents by deviation (what went wrong) and by contact, mode of
#                      injury (how the person was hurt), by NACE section (hsw_ph3_06, hsw_ph3_08).
#                      Numbers and incidence rates only, with codes instead of labels.
#                      `classification` is "deviation" or "contact"; both have a TOTAL row.
#                      Compressed with gzip; read_csv() reads it directly
#   esaw_codes.csv     labels for the sector and cause codes used in the other tables
#
# To keep the files small enough to commit, older EU aggregates (EU15, EU28, EU27_2007)
# and NACE divisions below the section level are left out; they remain in data/raw/.
#
# Eurostat's JSON-stat format stores values in one long vector, indexed by the
# combination of all dimensions; read_jsonstat() unpacks it into a data frame.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(jsonlite)
})

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
raw_dir <- file.path(module_dir, "data", "raw")
tidy_dir <- file.path(module_dir, "data", "tidy")
dir.create(tidy_dir, recursive = TRUE, showWarnings = FALSE)

read_jsonstat <- function(path) {
  js <- fromJSON(path, simplifyVector = FALSE)
  if (length(js$value) == 0) return(NULL)
  dims <- unlist(js$id)
  sizes <- unlist(js$size)
  # Values (and status flags) are keyed by their position in the full grid, row-major
  index <- as.integer(names(js$value))
  out <- list()
  remainder <- index
  for (k in rev(seq_along(dims))) {
    category <- js$dimension[[dims[k]]]$category
    codes <- names(sort(unlist(category$index)))
    position <- remainder %% sizes[k]
    remainder <- remainder %/% sizes[k]
    out[[dims[k]]] <- codes[position + 1]
    out[[paste0(dims[k], "_label")]] <- unname(unlist(category$label)[codes[position + 1]])
  }
  df <- as_tibble(out[rev(names(out))])
  df$value <- as.numeric(unlist(js$value))
  flags <- unlist(js$status)
  df$flag <- unname(flags[as.character(index)])
  df
}

read_table <- function(table) {
  files <- list.files(file.path(raw_dir, table), pattern = "\\.json$", full.names = TRUE)
  if (length(files) == 0) stop("No files for ", table, ". Run fetch_data.R first.")
  bind_rows(lapply(files, read_jsonstat))
}

old_aggregates <- c("EU15", "EU28", "EU27_2007")
sections <- "^([A-U]|TOTAL|A_C-N)$"

tidy_common <- function(df) {
  df |>
    filter(!geo %in% old_aggregates) |>
    rename(country_code = geo, country = geo_label, year = time) |>
    mutate(year = as.integer(year),
           severity = recode(severity, D_GE4 = "Non-fatal (4+ days absence)", FAT = "Fatal"),
           unit = recode(unit, NR = "number", RT_INC = "incidence_rate",
                         RT_SINC = "standardised_incidence_rate", PC = "percent")) |>
    select(-any_of(c("freq", "freq_label", "time_label", "severity_label", "unit_label")))
}

main <- read_table("hsw_mi01") |>
  tidy_common() |>
  select(country_code, country, year, severity, sex, age, nace_r2, unit, value, flag)

sector <- bind_rows(
  read_table("hsw_n2_01") |> mutate(severity = "D_GE4"),
  read_table("hsw_n2_02") |> mutate(severity = "FAT", sex = "T")
) |>
  tidy_common() |>
  filter(grepl(sections, nace_r2)) |>
  select(country_code, country, year, severity, sector_code = nace_r2, sector = nace_r2_label,
         unit, value, flag)

causes <- bind_rows(
  read_table("hsw_ph3_06") |>
    rename(cause_code = deviatn, cause = deviatn_label) |>
    mutate(classification = "deviation"),
  read_table("hsw_ph3_08") |>
    rename(cause_code = modinj, cause = modinj_label) |>
    mutate(classification = "contact")
) |>
  tidy_common() |>
  filter(unit != "percent")

codes <- bind_rows(
  distinct(causes, classification, code = cause_code, label = cause),
  distinct(causes, code = nace_r2, label = nace_r2_label) |> mutate(classification = "sector")
) |>
  select(classification, code, label)

causes <- causes |>
  select(country_code, year, severity, sector_code = nace_r2, classification, cause_code, unit, value, flag)

tables <- list(esaw_main = main, esaw_sector = sector, esaw_causes = causes, esaw_codes = codes)
for (name in names(tables)) {
  df <- tables[[name]]
  if ("country_code" %in% names(df)) df <- arrange(df, country_code, year)
  path <- file.path(tidy_dir, paste0(name, if (name == "esaw_causes") ".csv.gz" else ".csv"))
  write_csv(df, path, na = "")
  message(sprintf("%s: %s rows, %.1f MB", basename(path), format(nrow(df), big.mark = ","),
                  file.size(path) / 1e6))
}

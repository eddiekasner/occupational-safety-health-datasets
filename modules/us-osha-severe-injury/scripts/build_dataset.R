# Clean OSHA's Severe Injury Reports into one tidy table.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads the newest zip file in data/raw/ (from fetch_data.R) and writes
# data/tidy/severe_injury_reports.csv.gz (gzip-compressed; read_csv() reads it directly).
#
# Cleaning steps:
#   - plain lower-case column names
#   - EventDate parsed to a date; year and month added
#   - stray spaces removed from the OIICS titles (for example " Fractures   ")
#   - OIICS codes kept as text, with the one-digit division of the event, nature and
#     body part added as labels
#   - counts of hospitalized, amputation and loss of an eye as whole numbers
#   - two-digit NAICS sector added
#   - `upa` is the unique report identifier; OSHA's `ID` column has a few duplicates

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
})

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
raw_dir <- file.path(module_dir, "data", "raw")
out_path <- file.path(module_dir, "data", "tidy", "severe_injury_reports.csv.gz")

zips <- list.files(raw_dir, pattern = "\\.zip$", full.names = TRUE)
if (length(zips) == 0) stop("No zip file in ", raw_dir, ". Run fetch_data.R first.")
zip_path <- zips[which.max(file.mtime(zips))]
message("reading ", basename(zip_path))

raw <- read_csv(zip_path, col_types = cols(.default = col_character()), progress = FALSE)

# OIICS version 2.01 divisions (first digit of each code)
event_divisions <- c(
  "1" = "Violence and other injuries by persons or animals",
  "2" = "Transportation incidents",
  "3" = "Fires and explosions",
  "4" = "Falls, slips, trips",
  "5" = "Exposure to harmful substances or environments",
  "6" = "Contact with objects and equipment",
  "7" = "Overexertion and bodily reaction",
  "9" = "Nonclassifiable"
)
nature_divisions <- c(
  "1" = "Traumatic injuries and disorders",
  "2" = "Systemic diseases and disorders",
  "3" = "Infectious and parasitic diseases",
  "4" = "Neoplasms, tumors, and cancer",
  "5" = "Symptoms, signs, and ill-defined conditions",
  "6" = "Other diseases, conditions, and disorders",
  "7" = "Exposures to disease, no illness incurred",
  "8" = "Multiple diseases, conditions, and disorders",
  "9" = "Nonclassifiable"
)
body_divisions <- c(
  "1" = "Head",
  "2" = "Neck, including throat",
  "3" = "Trunk",
  "4" = "Upper extremities",
  "5" = "Lower extremities",
  "6" = "Body systems",
  "8" = "Multiple body parts",
  "9" = "Other body parts or nonclassifiable"
)
division <- function(code, labels) unname(labels[str_sub(code, 1, 1)])
tidy_title <- function(x) na_if(str_squish(x), "")

sir <- raw |>
  transmute(
    upa = UPA,
    id = ID,
    event_date = as.Date(EventDate, format = "%m/%d/%Y"),
    year = as.integer(format(event_date, "%Y")),
    month = as.integer(format(event_date, "%m")),
    employer = str_squish(Employer),
    address = str_squish(Address1),
    city = str_squish(City),
    state = str_squish(State),
    zip = Zip,
    latitude = as.numeric(Latitude),
    longitude = as.numeric(Longitude),
    naics = `Primary NAICS`,
    naics_2 = str_sub(naics, 1, 2),
    federal_state = FederalState,
    hospitalized = as.integer(round(as.numeric(Hospitalized))),
    amputation = as.integer(round(as.numeric(Amputation))),
    loss_of_eye = as.integer(round(as.numeric(`Loss of Eye`))),
    inspection = Inspection,
    narrative = str_squish(`Final Narrative`),
    event_code = Event,
    event = tidy_title(EventTitle),
    event_division = division(Event, event_divisions),
    nature_code = Nature,
    nature = tidy_title(NatureTitle),
    nature_division = division(Nature, nature_divisions),
    body_part_code = `Part of Body`,
    body_part = tidy_title(`Part of Body Title`),
    body_part_division = division(`Part of Body`, body_divisions),
    source_code = Source,
    source = tidy_title(SourceTitle),
    secondary_source_code = `Secondary Source`,
    secondary_source = tidy_title(`Secondary Source Title`)
  ) |>
  arrange(event_date, upa)

stopifnot(!any(duplicated(sir$upa)), !any(is.na(sir$event_date)))

dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
write_csv(sir, out_path, na = "")
message(sprintf("wrote %s reports (%s to %s) to %s (%.1f MB)",
                format(nrow(sir), big.mark = ","), min(sir$event_date), max(sir$event_date),
                basename(out_path), file.size(out_path) / 1e6))

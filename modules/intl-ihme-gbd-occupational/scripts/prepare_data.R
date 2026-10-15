# Combine and tidy the GBD Results Tool downloads in data/raw/.
#
# Usage (from RStudio):      open this file and click "Source"
# Usage (from a terminal):   Rscript scripts/prepare_data.R
#
# Reads every .zip and .csv file in data/raw/ (download them as described in the README) and
# writes data/processed/gbd_occupational.csv.gz, which the notebooks read. Both folders are
# excluded from git: IHME's licence does not allow the data to be shared.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
})

script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  if (!is.null(sys.frame(1)$ofile)) return(dirname(normalizePath(sys.frame(1)$ofile)))
  getwd()
}
module_dir <- normalizePath(file.path(script_dir(), ".."))
raw_dir <- file.path(module_dir, "data", "raw")
out_dir <- file.path(module_dir, "data", "processed")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# The 21 GBD regions (everything else except "Global" is a country or territory)
gbd_regions <- c(
  "Central Asia", "Central Europe", "Eastern Europe", "Australasia", "High-income Asia Pacific",
  "High-income North America", "Southern Latin America", "Western Europe", "Andean Latin America",
  "Caribbean", "Central Latin America", "Tropical Latin America", "North Africa and Middle East",
  "South Asia", "East Asia", "Oceania", "Southeast Asia", "Central Sub-Saharan Africa",
  "Eastern Sub-Saharan Africa", "Southern Sub-Saharan Africa", "Western Sub-Saharan Africa")

# Read one CSV (from a zip or on its own). Downloads come with either names only (measure,
# location, ...) or IDs and names (measure_id, measure_name, ...); use the names.
read_gbd <- function(con, label) {
  d <- read_csv(con, col_types = cols(.default = col_character()), progress = FALSE)
  names(d) <- str_remove(names(d), "_name$")
  needed <- c("measure", "location", "sex", "age", "cause", "rei", "metric", "year", "val",
              "upper", "lower")
  missing <- setdiff(needed, names(d))
  if (length(missing)) {
    message("Skipping ", label, ": not a GBD risk factor download (missing ",
            paste(missing, collapse = ", "), ")")
    return(NULL)
  }
  select(d, all_of(needed))
}

files <- list.files(raw_dir, pattern = "\\.(zip|csv)$", ignore.case = TRUE, full.names = TRUE)
if (!length(files)) stop("No files in ", raw_dir, ". Download the data as described in the README.")

parts <- list()
for (f in files) {
  if (str_detect(tolower(f), "\\.zip$")) {
    members <- unzip(f, list = TRUE)$Name
    for (m in members[str_detect(tolower(members), "\\.csv$")]) {
      message("reading ", basename(f), ": ", m)
      parts[[length(parts) + 1]] <- read_gbd(unz(f, m), paste(basename(f), m))
    }
  } else {
    message("reading ", basename(f))
    parts[[length(parts) + 1]] <- read_gbd(f, basename(f))
  }
}
gbd <- bind_rows(parts)
if (!nrow(gbd)) stop("None of the files in data/raw/ is a GBD risk factor download.")

gbd <- gbd |>
  transmute(
    measure = case_when(str_starts(measure, "DALYs") ~ "DALYs", TRUE ~ measure),
    location,
    level = case_when(location == "Global" ~ "Global",
                      location %in% gbd_regions ~ "Region",
                      TRUE ~ "Country"),
    sex, age, cause, risk = rei, metric,
    year = as.integer(year),
    val = as.numeric(val), lower = as.numeric(lower), upper = as.numeric(upper)
  ) |>
  # The same estimate may appear in more than one download
  distinct(measure, location, sex, age, cause, risk, metric, year, .keep_all = TRUE) |>
  arrange(level, location, risk, measure, metric, sex, age, year)

write_csv(gbd, file.path(out_dir, "gbd_occupational.csv.gz"))

message("\nWrote ", format(nrow(gbd), big.mark = ","), " rows to data/processed/gbd_occupational.csv.gz")
message("Years: ", min(gbd$year), " to ", max(gbd$year))
message("Risks: ", n_distinct(gbd$risk), "; measures: ", paste(unique(gbd$measure), collapse = ", "),
        "; metrics: ", paste(unique(gbd$metric), collapse = ", "))
places <- distinct(gbd, level, location) |> count(level)
message("Distinct places: ", paste(places$level, places$n, collapse = ", "))
if (!"Region" %in% places$level) message("Note: no GBD regions found; check the first download.")
if (!"Country" %in% places$level) message("Note: no countries found; check the second download.")

# Download European Statistics on Accidents at Work (ESAW) tables from Eurostat.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Saves one JSON file per table and country in data/raw/<table>/. Requests are
# made one country at a time because Eurostat delays large requests. The full
# download takes a few minutes. Existing files are skipped; delete data/raw/ to
# get fresh data. Next step: run scripts/build_dataset.R.
#
# Source: Eurostat dissemination API (JSON-stat),
# https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access

# Tables and the filters applied to each. Filters keep only totals for some
# breakdowns so the files stay small.
tables <- list(
  hsw_mi01   = list(),                              # by sex, age and severity (standardised rates)
  hsw_n2_01  = list(sex = "T"),                     # non-fatal accidents by NACE Rev. 2 activity
  hsw_n2_02  = list(),                              # fatal accidents by NACE Rev. 2 activity
  hsw_ph3_06 = list(sex = "T", age = "TOTAL"),      # by deviation (what went wrong)
  hsw_ph3_08 = list(sex = "T", age = "TOTAL")       # by contact, mode of injury (how the person was hurt)
)

api <- "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/"

script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  if (!is.null(sys.frame(1)$ofile)) return(dirname(normalizePath(sys.frame(1)$ofile)))
  getwd()
}
raw_dir <- file.path(script_dir(), "..", "data", "raw")
options(timeout = 300)

query_url <- function(table, filters) {
  params <- c(paste0(names(filters), "=", unlist(filters)), "lang=en")
  paste0(api, table, "?", paste(params, collapse = "&"))
}

download_json <- function(url, dest) {
  for (attempt in 1:3) {
    tmp <- paste0(dest, ".part")
    ok <- tryCatch(suppressWarnings(download.file(url, tmp, mode = "wb", quiet = TRUE)) == 0,
                   error = function(e) FALSE)
    if (ok && !grepl('"error"', readChar(tmp, 200))) return(invisible(file.rename(tmp, dest)))
    Sys.sleep(5 * attempt)  # Eurostat may ask us to try again later
  }
  stop("Could not download ", url)
}

# The list of countries comes from a small query of the main table
geo_file <- file.path(raw_dir, "geo_list.json")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
if (!file.exists(geo_file)) {
  download_json(query_url("hsw_mi01", list(sex = "T", age = "TOTAL", severity = "FAT", unit = "NR")), geo_file)
}
geos <- names(jsonlite::fromJSON(geo_file)$dimension$geo$category$label)
message(length(geos), " countries and aggregates: ", paste(geos, collapse = " "))

for (table in names(tables)) {
  dir.create(file.path(raw_dir, table), showWarnings = FALSE)
  for (geo in geos) {
    dest <- file.path(raw_dir, table, paste0(geo, ".json"))
    if (file.exists(dest)) next
    download_json(query_url(table, c(tables[[table]], geo = geo)), dest)
  }
  message("done: ", table)
}
message("files are in ", normalizePath(raw_dir))

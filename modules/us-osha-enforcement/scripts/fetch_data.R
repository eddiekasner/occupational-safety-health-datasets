# Download OSHA enforcement data from the US Department of Labor (DOL) data API into data/raw/.
#
# BEFORE RUNNING: you need a free DOL API key. Sign up at https://dataportal.dol.gov, create an API
# key, and either set the environment variable DOL_API_KEY (recommended; in RStudio run
# usethis::edit_r_environ() and add a line DOL_API_KEY=your-key) or paste it into `api_key` below.
# Do not share your key or commit it to a repository.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Downloads, as CSV files:
#   inspection         inspections opened in fiscal years 2015 to 2025 (Oct 2014 to Sep 2025)
#   violation          violations cited from October 2014 to today
#   accident           all accident investigation summaries
#   accident_abstract  their narratives (one row per line of text)
#   accident_injury    the injured or killed workers in those investigations
#   accident_lookup2   code list for the accident tables
# About 1.5 GB in total; it takes an hour or more. Files already downloaded are skipped, so the
# script can be stopped and rerun. Next step: run scripts/build_dataset.R.
#
# The API returns at most 10,000 rows per request. Rather than paging (which can skip or repeat
# rows that tie on the sort column), each request covers a range of dates or record numbers; if a
# range has 10,000 rows or more, it is split in half and each half is requested separately.
#
# API documentation: https://dataportal.dol.gov/api-examples

api_key <- Sys.getenv("DOL_API_KEY", unset = "")  # or write it here: "your-key"
if (!nzchar(api_key)) stop("Set DOL_API_KEY (see the top of this script).")

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) {
  dirname(normalizePath(sub("^--file=", "", file_arg)))
} else if (!is.null(sys.frame(1)$ofile)) {
  dirname(normalizePath(sys.frame(1)$ofile))
} else {
  getwd()
}
raw_dir <- file.path(script_dir, "..", "data", "raw")

options(timeout = 600)
base_url <- "https://apiprod.dol.gov/v4/get/OSHA"
max_rows <- 10000

# One request for all rows with `field` between `from` and `to` (inclusive)
fetch_range <- function(table, field, from, to, dest) {
  is_date <- inherits(from, "Date")
  lower <- if (is_date) format(from - 1) else format(from - 1, scientific = FALSE)
  upper <- if (is_date) format(to + 1) else format(to + 1, scientific = FALSE)
  filter <- sprintf('{"and":[{"field":"%s","operator":"gt","value":"%s"},{"field":"%s","operator":"lt","value":"%s"}]}',
                    field, lower, field, upper)
  query <- c(limit = max_rows, offset = 0, filter_object = filter, `X-API-KEY` = api_key)
  url <- paste0(base_url, "/", table, "/csv?",
                paste0(names(query), "=", vapply(query, URLencode, "", reserved = TRUE),
                       collapse = "&"))
  # The API limits how many requests a key can make (it answers "429 Too Many Requests"). Wait
  # and retry, for up to about an hour, before giving up.
  waits <- c(10, 60, 300, 600, 900, 1800)
  for (attempt in seq_along(waits)) {
    ok <- tryCatch({
      download.file(url, dest, mode = "wb", quiet = TRUE)
      TRUE
    }, error = function(e) FALSE, warning = function(w) FALSE)
    # An empty answer (HTTP 204) means there are no records in this range
    if (ok) {
      if (!file.exists(dest)) file.create(dest)
      return(max(0, length(readLines(dest, warn = FALSE)) - 1))
    }
    message("  request failed (", table, " ", from, " to ", to, "); waiting ", waits[attempt],
            " seconds")
    Sys.sleep(waits[attempt])
  }
  unlink(dest)
  stop("Download failed: ", table, " ", from, " to ", to, ". Check your API key, or wait an ",
       "hour (the API limits requests per key) and run the script again; it resumes where it ",
       "stopped.")
}

# Fetch a range, splitting it in half while it has too many rows for one request
fetch_split <- function(table, field, from, to, folder) {
  name <- paste0(format(from, scientific = FALSE), "_", format(to, scientific = FALSE), ".csv")
  dest <- file.path(folder, name)
  if (file.exists(dest)) return(invisible())
  tmp <- paste0(dest, ".part")
  rows <- fetch_range(table, field, from, to, tmp)
  if (rows < max_rows) {
    file.rename(tmp, dest)
    return(invisible())
  }
  unlink(tmp)
  if (from == to) stop(table, ": more than ", max_rows, " rows for ", field, " = ", from)
  middle <- if (inherits(from, "Date")) from + floor(as.numeric(to - from) / 2) else floor((from + to) / 2)
  fetch_split(table, field, from, middle, folder)
  fetch_split(table, field, middle + 1, to, folder)
}

fetch_table <- function(table, field, from, to, by = NULL) {
  folder <- file.path(raw_dir, table)
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  # Dates: one starting range per month, so progress can be seen and resumed
  starts <- if (is.null(by)) from else seq(from, to, by = by)
  for (i in seq_along(starts)) {
    end <- if (i < length(starts)) starts[i + 1] - 1 else to
    fetch_split(table, field, starts[i], end, folder)
    if (!is.null(by)) message(table, " ", format(starts[i], "%Y-%m"))
  }
  message(table, ": done")
}

fetch_table("inspection", "open_date", as.Date("2014-10-01"), as.Date("2025-09-30"), by = "month")
fetch_table("violation", "issuance_date", as.Date("2014-10-01"), Sys.Date(), by = "month")
fetch_table("accident", "summary_nr", 0, 999999999)
fetch_table("accident_abstract", "summary_nr", 0, 999999999)
fetch_table("accident_injury", "summary_nr", 0, 999999999)
# The code list is small enough for a single request
lookup_dest <- file.path(raw_dir, "accident_lookup2.csv")
if (!file.exists(lookup_dest)) {
  url <- paste0(base_url, "/accident_lookup2/csv?limit=", max_rows, "&X-API-KEY=", api_key)
  download.file(url, lookup_dest, mode = "wb", quiet = TRUE)
}

message("Done. Next: run scripts/build_dataset.R")

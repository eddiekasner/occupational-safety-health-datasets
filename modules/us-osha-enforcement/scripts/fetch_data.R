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
# Downloads, as CSV files of up to 10,000 rows each:
#   inspection        inspections opened in fiscal years 2015 to 2025 (Oct 2014 to Sep 2025),
#                     one folder per month
#   violation         violations cited from October 2014 to today, one folder per month
#   accident          all accident investigation summaries (with their narratives)
#   accident_injury   the injured or killed workers in those investigations
#   accident_lookup2  code list for the accident tables
# About 1.5 GB in total; it takes an hour or more. Files already downloaded are skipped, so the
# script can be stopped and rerun. Next step: run scripts/build_dataset.R.
#
# API documentation: https://dataportal.dol.gov/api-examples

api_key <- Sys.getenv("DOL_API_KEY", unset = "")  # or write it here: "your-key"
if (!nzchar(api_key)) stop("Set DOL_API_KEY (see the top of this script).")

first_month <- as.Date("2014-10-01")   # start of fiscal year 2015
last_inspection_month <- as.Date("2025-09-01")
last_violation_month <- as.Date(format(Sys.Date(), "%Y-%m-01"))

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
page_size <- 10000

# One API request: up to 10,000 rows as CSV, sorted so that pages do not overlap
fetch_page <- function(table, filter, sort_by, offset, dest) {
  query <- c(limit = page_size, offset = offset, sort = "asc", sort_by = sort_by,
             filter_object = filter, `X-API-KEY` = api_key)
  query <- query[!is.na(query)]
  url <- paste0(base_url, "/", table, "/csv?",
                paste0(names(query), "=", vapply(query, URLencode, "", reserved = TRUE),
                       collapse = "&"))
  for (attempt in 1:4) {
    ok <- tryCatch({
      download.file(url, dest, mode = "wb", quiet = TRUE)
      TRUE
    }, error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.size(dest) > 0) return(invisible(TRUE))
    Sys.sleep(2^attempt)
  }
  unlink(dest)
  stop("Download failed: ", table, " offset ", offset, ". Check your API key and try again.")
}

# All pages of one query, saved as <folder>/page_000.csv, page_001.csv, ...
fetch_all <- function(table, folder, filter = NA, sort_by) {
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  done <- file.path(folder, "complete")
  if (file.exists(done)) return(invisible())
  page <- 0
  repeat {
    dest <- file.path(folder, sprintf("page_%03d.csv", page))
    if (!file.exists(dest)) fetch_page(table, filter, sort_by, page * page_size, dest)
    rows <- length(readLines(dest, warn = FALSE)) - 1
    if (rows < page_size) break
    page <- page + 1
  }
  file.create(done)
  message(table, " ", basename(folder), ": ", page * page_size + rows, " rows")
}

date_filter <- function(field, from, to) {
  sprintf('{"and":[{"field":"%s","operator":"gt","value":"%s"},{"field":"%s","operator":"lt","value":"%s"}]}',
          field, format(from - 1), field, format(to))
}

months <- function(from, to) seq(from, to, by = "month")
next_month <- function(m) seq(m, by = "month", length.out = 2)[2]

for (m in as.list(months(first_month, last_inspection_month))) {
  fetch_all("inspection", file.path(raw_dir, "inspection", format(m, "%Y-%m")),
            date_filter("open_date", m, next_month(m)), sort_by = "activity_nr")
}
for (m in as.list(months(first_month, last_violation_month))) {
  fetch_all("violation", file.path(raw_dir, "violation", format(m, "%Y-%m")),
            date_filter("issuance_date", m, next_month(m)), sort_by = "activity_nr")
}
fetch_all("accident", file.path(raw_dir, "accident", "all"), sort_by = "summary_nr")
fetch_all("accident_injury", file.path(raw_dir, "accident_injury", "all"), sort_by = "summary_nr")
fetch_all("accident_lookup2", file.path(raw_dir, "accident_lookup2", "all"), sort_by = "accident_code")

message("Done. Next: run scripts/build_dataset.R")

# Download Statistics Finland's occupational accident tables into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Statistics Finland publishes occupational accident statistics (compiled from the workers'
# compensation insurers' records by the Finnish Workers' Compensation Center, TVK) in its StatFin
# database. This script uses the database's PxWeb API (https://pxdata.stat.fi) and saves each
# table, or each piece of a large table, as a JSON-stat file. The API allows 120,000 cells per
# request and 40 requests a minute, so the largest table is downloaded one year and a few
# industries at a time, with pauses. About 30 MB in all. Files already downloaded are skipped;
# delete them to download again. Next step: run scripts/build_dataset.R.

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) {
  dirname(normalizePath(sub("^--file=", "", file_arg)))
} else if (!is.null(sys.frame(1)$ofile)) {
  dirname(normalizePath(sys.frame(1)$ofile))
} else {
  getwd()
}
raw_dir <- file.path(script_dir, "..", "data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

api <- "https://pxdata.stat.fi/PxWeb/api/v1/en/StatFin/ttap/"

metadata <- function(table) jsonlite::fromJSON(paste0(api, table, ".px"), simplifyVector = FALSE)

# Request a table with the given selections (a named list of value codes; variables not listed
# get all values) and save the JSON-stat2 response
fetch <- function(table, dest, selection = list()) {
  if (file.exists(dest)) return(invisible())
  meta <- metadata(table)
  query <- lapply(meta$variables, function(v) {
    values <- if (!is.null(selection[[v$code]])) selection[[v$code]] else unlist(v$values)
    list(code = v$code, selection = list(filter = "item", values = I(values)))
  })
  body <- jsonlite::toJSON(list(query = query, response = list(format = "json-stat2")),
                           auto_unbox = TRUE)
  for (attempt in 1:5) {
    h <- curl::new_handle(customrequest = "POST", postfields = body)
    curl::handle_setheaders(h, "Content-Type" = "application/json")
    res <- tryCatch(curl::curl_fetch_disk(paste0(api, table, ".px"), dest, handle = h),
                    error = function(e) NULL)
    if (!is.null(res) && res$status_code == 200) break
    if (file.exists(dest)) file.remove(dest)
    Sys.sleep(10 * attempt)  # the API counts requests per minute
  }
  if (!file.exists(dest)) stop("download failed: ", table)
  Sys.sleep(2)
}

# The main table: accidents of wage and salary earners and entrepreneurs (not farmers) by place
# of accident, days of disability, age, sex and industry, 2008 onward. Too large for one request,
# so download each year in eight groups of industries.
main <- "12ay"
meta <- metadata(main)
years <- unlist(meta$variables[[1]]$values)
industries <- unlist(meta$variables[[which(sapply(meta$variables, `[[`, "code") ==
                                             "toimiala_79_20180101")]]$values)
# 15 industries x 3 x 5 x 11 x 7 x 3 x 2 measures = 103,950 cells, under the limit
groups <- split(industries, ceiling(seq_along(industries) / 15))
for (y in years) for (g in seq_along(groups)) {
  dest <- file.path(raw_dir, sprintf("ttap_%s_%s_%d.json", main, y, g))
  message("downloading ", basename(dest))
  fetch(main, dest, setNames(list(y, groups[[g]]), c("Timeperiod_y", "toimiala_79_20180101")))
}

# Smaller tables, each in one request
small <- c(
  "12b6",  # specific physical activity (ESAW), wage and salary earners
  "12b9",  # deviation (ESAW)
  "13p6",  # contact, mode of injury (ESAW)
  "13iw",  # type of injury (ESAW)
  "13h8",  # part of body injured (ESAW)
  "12zz",  # accidents per 100,000 wage and salary earners, by industry, 2018 onward
  "13ql",  # accidents per million hours worked, by industry, 2018 onward
  "129t"   # farmers' accidents per 100,000 insured farmers, 2000 onward
)
for (t in small) {
  dest <- file.path(raw_dir, sprintf("ttap_%s.json", t))
  message("downloading ", basename(dest))
  fetch(t, dest)
}
message("Done: files are in ", normalizePath(raw_dir), ". Next: run scripts/build_dataset.R")

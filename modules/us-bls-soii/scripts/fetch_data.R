# Download Survey of Occupational Injuries and Illnesses (SOII) data from the Bureau of
# Labor Statistics into data/raw/.
#
# BEFORE RUNNING: put your email address in `contact_email` below. BLS blocks automated
# downloads that do not identify who is making them, and asks for contact information
# in the request.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Downloads two BLS flat-file series:
#   is  industry and state injury and illness rates and counts (about 240 MB)
#   cs  case and demographic characteristics of cases with days away from work. The full
#       data file is about 6 GB. It is downloaded to a temporary file (you need about 7 GB of
#       free disk space), checked for completeness, filtered to the series used by this
#       module (see keep_cs_series() below), and then deleted. This can take 30 minutes or more.
# Existing files are skipped. Next step: run scripts/build_dataset.R.
#
# Sources: https://download.bls.gov/pub/time.series/is/
#          https://download.bls.gov/pub/time.series/cs/

contact_email <- Sys.getenv("BLS_CONTACT_EMAIL", unset = "")  # or write it here: "you@example.edu"

if (!nzchar(contact_email)) {
  stop("Set contact_email at the top of fetch_data.R (BLS requires contact information).")
}

is_files <- c("is.txt", "is.area", "is.case_type", "is.data_type", "is.footnote", "is.industry",
              "is.supersector", "is.data.1.AllData")
cs_files <- c("cs.txt", "cs.case", "cs.category", "cs.datatype", "cs.footnote", "cs.age", "cs.gender",
              "cs.race", "cs.los", "cs.event", "cs.nature", "cs.source", "cs.pob", "cs.occupation",
              "cs.industry", "cs.ownership", "cs.special", "cs.state", "cs.time", "cs.hour", "cs.weekday")

script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  if (!is.null(sys.frame(1)$ofile)) return(dirname(normalizePath(sys.frame(1)$ofile)))
  getwd()
}
raw_dir <- file.path(script_dir(), "..", "data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

options(timeout = 7200, HTTPUserAgent = paste0("OSH teaching datasets (", contact_email, ")"))
bls <- "https://download.bls.gov/pub/time.series/"

fetch <- function(series, name) {
  dest <- file.path(raw_dir, name)
  if (file.exists(dest)) return(message("already have ", name))
  message("downloading ", name)
  tmp <- paste0(dest, ".part")
  download.file(paste0(bls, series, "/", name), tmp, mode = "wb", quiet = TRUE)
  file.rename(tmp, dest)
  Sys.sleep(1)  # be polite to the BLS servers
}
for (f in is_files) fetch("is", f)
for (f in cs_files) fetch("cs", f)

# cs series IDs pack their breakdowns into fixed positions:
#   cs U 00X 00XXXX 3 E 1 00
#        |   |      | | | └ state (00 = US)
#        |   |      | | └ ownership (0 = all, 1 = private industry)
#        |   |      | └ case: which detail the 6-character code describes
#        |   |      └ data type (3 = rate, 6 = cases, 7 = median days away)
#        |   └ detail code (an "all" code is zeros followed by Xs)
#        └ category (a characteristic; 00X = all)
# Keep national series for all ownerships and private industry that have either no
# category or no detail breakdown, plus state totals.
keep_cs_series <- function(ids) {
  ids <- gsub(" ", "", ids)
  category <- substr(ids, 4, 6)
  all_detail <- grepl("^0+X*$", substr(ids, 7, 12))
  ownership <- substr(ids, 15, 15)
  state <- substr(ids, 16, 17)
  (state == "00" & ownership %in% c("0", "1") & (category == "00X" | all_detail)) |
    (state != "00" & category == "00X" & all_detail)
}

cs_out <- file.path(raw_dir, "cs.data.filtered")
if (file.exists(cs_out)) {
  message("already have cs.data.filtered")
} else {
  url <- paste0(bls, "cs/cs.data.1.AllData")
  headers <- curlGetHeaders(url)
  expected <- as.numeric(sub(".*:\\s*", "", grep("^content-length", headers, ignore.case = TRUE, value = TRUE)[1]))
  big <- file.path(tempdir(), "cs.data.1.AllData")
  # Long downloads from BLS are sometimes cut off, so check the size and retry
  for (attempt in 1:3) {
    message(sprintf("downloading cs.data.1.AllData (%.1f GB), attempt %d", expected / 1e9, attempt))
    try(download.file(url, big, mode = "wb", quiet = TRUE))
    if (file.exists(big) && file.size(big) == expected) break
    Sys.sleep(10)
  }
  if (!file.exists(big) || file.size(big) != expected) stop("cs.data.1.AllData did not download completely; try again later.")

  message("filtering cs.data.1.AllData")
  con <- file(big, open = "r")
  out <- file(paste0(cs_out, ".part"), open = "w")
  writeLines(readLines(con, n = 1), out)  # header
  repeat {
    lines <- readLines(con, n = 500000)
    if (length(lines) == 0) break
    writeLines(lines[keep_cs_series(sub("\t.*$", "", lines))], out)
  }
  close(con)
  close(out)
  file.rename(paste0(cs_out, ".part"), cs_out)
  unlink(big)
}
message("done: files are in ", normalizePath(raw_dir))

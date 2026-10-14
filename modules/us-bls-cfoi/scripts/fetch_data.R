# Download Census of Fatal Occupational Injuries (CFOI) data from the Bureau of Labor
# Statistics into data/raw/.
#
# BEFORE RUNNING: put your email address in `contact_email` below. BLS blocks automated
# downloads that do not identify who is making them, and asks for contact information
# in the request.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Downloads:
#   - the CFOI flat files (series "fw", 2011 to 2022), about 620 MB
#   - BLS tables of fatal injury rates based on hours worked, 2023 and 2024 (Excel)
# Existing files are skipped. Next step: run scripts/build_dataset.R.
#
# Sources: https://download.bls.gov/pub/time.series/fw/
#          https://www.bls.gov/iif/fatal-injuries-tables.htm

contact_email <- Sys.getenv("BLS_CONTACT_EMAIL", unset = "")  # or write it here: "you@example.edu"

if (!nzchar(contact_email)) {
  stop("Set contact_email at the top of fetch_data.R (BLS requires contact information).")
}

flat_files <- c("fw.area", "fw.case", "fw.category", "fw.event", "fw.industry",
                "fw.occupation", "fw.source", "fw.txt", "fw.data.1.AllData")
rate_years <- c(2023, 2024)

script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  if (!is.null(sys.frame(1)$ofile)) return(dirname(normalizePath(sys.frame(1)$ofile)))
  getwd()
}
raw_dir <- file.path(script_dir(), "..", "data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

options(timeout = 3600, HTTPUserAgent = paste0("OSH teaching datasets (", contact_email, ")"))

fetch <- function(url, name) {
  dest <- file.path(raw_dir, name)
  if (file.exists(dest)) return(message("already have ", name))
  message("downloading ", name)
  tmp <- paste0(dest, ".part")
  download.file(url, tmp, mode = "wb", quiet = TRUE)
  file.rename(tmp, dest)
  Sys.sleep(1)  # be polite to the BLS servers
}

for (f in flat_files) fetch(paste0("https://download.bls.gov/pub/time.series/fw/", f), f)
for (y in rate_years) {
  name <- sprintf("fatal-occupational-injuries-hours-based-rates-%d.xlsx", y)
  fetch(paste0("https://www.bls.gov/iif/fatal-injuries-tables/", name), name)
}
message("done: files are in ", normalizePath(raw_dir))

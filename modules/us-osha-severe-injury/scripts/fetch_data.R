# Download OSHA's Severe Injury Reports (SIR) into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Downloads one zip file (about 16 MB). Next step: run scripts/build_dataset.R.
#
# Source: https://www.osha.gov/severe-injury-reports ("Download the full SIR data set")
# OSHA updates the data periodically and renames the file to match the date range
# (for example January2015toNovember2025.zip). If the link stops working, copy the
# new one from that page and update `file_name` below.

file_name <- "January2015toNovember2025.zip"

script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  if (!is.null(sys.frame(1)$ofile)) return(dirname(normalizePath(sys.frame(1)$ofile)))
  getwd()
}

raw_dir <- file.path(script_dir(), "..", "data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
dest <- file.path(raw_dir, file_name)

# OSHA's website rejects R's default user agent (HTTP 403), so identify as a browser.
options(timeout = 600,
        HTTPUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36")

if (file.exists(dest)) {
  message("already have ", file_name)
} else {
  message("downloading ", file_name)
  tmp <- paste0(dest, ".part")
  download.file(paste0("https://www.osha.gov/sites/default/files/", file_name), tmp, mode = "wb", quiet = TRUE)
  file.rename(tmp, dest)
}
message("done: files are in ", normalizePath(raw_dir))

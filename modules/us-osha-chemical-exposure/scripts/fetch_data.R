# Download OSHA Chemical Exposure Health Data (one zip file per year) into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Files that already exist in data/raw/ are skipped. Years 1984 to 2025 total
# about 55 MB. Next step: run scripts/build_dataset.R.
#
# Source page: https://www.osha.gov/opengov/health-samples
# OSHA updates the data each January and July. The current year (2026) is partial
# and published in a different format, so it is not included.

years <- 1984:2025

script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  if (!is.null(sys.frame(1)$ofile)) return(dirname(normalizePath(sys.frame(1)$ofile)))
  getwd()
}

raw_dir <- file.path(script_dir(), "..", "data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

# OSHA's website rejects R's default user agent (HTTP 403), so identify as a browser.
options(timeout = 600,
        HTTPUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36")
for (year in years) {
  name <- sprintf("sample_data_%d.zip", year)
  dest <- file.path(raw_dir, name)
  if (file.exists(dest)) {
    message("already have ", name)
    next
  }
  message("downloading ", name)
  tmp <- paste0(dest, ".part")
  download.file(paste0("https://www.osha.gov/sites/default/files/", name), tmp,
                mode = "wb", quiet = TRUE)
  file.rename(tmp, dest)
}
message("done: files are in ", normalizePath(raw_dir))

# Download the full ITA case detail files into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Files that already exist in data/raw/ are skipped. The files are large, so the
# first download can take several minutes.

# Direct download links from OSHA's ITA data page:
# https://www.osha.gov/Establishment-Specific-Injury-and-Illness-Data
# OSHA renames the current-year file as new submissions arrive (the date in the
# name changes). If a link stops working, copy the new one from that page.
# Sizes as of October 2026: 2023 = 130 MB zip, 2024 = 86 MB zip, 2025 = 475 MB csv.
osha <- "https://www.osha.gov/sites/default/"
sources <- c(
  "ITA_Case_Detail_Data_2023_through_12-31-2023OIICS.zip" =
    paste0(osha, "largefiles/ITA_Case_Detail_Data_2023_through_12-31-2023OIICS.zip"),
  "ITA_Case_Detail_Data_2024_through_12-31-2025.zip" =
    paste0(osha, "files/ITA_Case_Detail_Data_2024_through_12-31-2025.zip"),
  "ITA_Case_Detail_Data_2025_through_08-31-2026.csv" =
    paste0(osha, "largefiles/ITA_Case_Detail_Data_2025_through_08-31-2026.csv")
)

script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  if (!is.null(sys.frame(1)$ofile)) return(dirname(normalizePath(sys.frame(1)$ofile)))
  getwd()
}

raw_dir <- file.path(script_dir(), "..", "data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

# OSHA's website rejects R's default user agent (HTTP 403), so identify as a browser.
options(timeout = 3600,
        HTTPUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36")
for (name in names(sources)) {
  dest <- file.path(raw_dir, name)
  if (file.exists(dest)) {
    message("already have ", name)
    next
  }
  message("downloading ", name)
  tmp <- paste0(dest, ".part")
  download.file(sources[[name]], tmp, mode = "wb")
  file.rename(tmp, dest)
}
message("done: files are in ", normalizePath(raw_dir))

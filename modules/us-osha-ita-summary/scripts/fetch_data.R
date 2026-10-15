# Download OSHA's ITA Form 300A summary files into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Downloads one file for each calendar year 2016 to 2025 (about 260 MB in total), plus OSHA's data
# dictionary, users' guide, and comparison with BLS estimates. Files that already exist are
# skipped. Next step: run scripts/build_dataset.R.
#
# Direct download links from OSHA's ITA data page:
# https://www.osha.gov/Establishment-Specific-Injury-and-Illness-Data
# OSHA renames the current-year file as new submissions arrive (the date in the name changes), and
# adds a new file each year. If a link stops working, copy the new one from that page.

osha <- "https://www.osha.gov/sites/default/"
sources <- c(
  "ITA_Data_CY_2016.zip" = "files/ITA%20Data%20CY%202016.zip",
  "ITA_Data_CY_2017.zip" = "files/ITA%20Data%20CY%202017.zip",
  "ITA_Data_CY_2018.zip" = "files/ITA%20Data%20CY%202018.zip",
  "ITA_Data_CY_2019.zip" = "files/ITA%20Data%20CY%202019.zip",
  "ITA-Data-CY-2020.zip" = "files/ITA-Data-CY-2020.zip",
  "ITA-data-cy2021.zip" = "files/ITA-data-cy2021.zip",
  "ITA-data-cy2022.zip" = "files/ITA-data-cy2022.zip",
  "ITA_300A_Summary_Data_2023_through_12-31-2024.zip" =
    "files/ITA_300A_Summary_Data_2023_through_12-31-2024.zip",
  "ITA_300A_Summary_Data_2024_through_12-31-2025.zip" =
    "files/ITA_300A_Summary_Data_2024_through_12-31-2025.zip",
  "ITA_300A_Summary_Data_2025_through_08-31-2026.csv" =
    "largefiles/ITA_300A_Summary_Data_2025_through_08-31-2026.csv",
  "summary_data_dictionary.pdf" = "files/summary_data_dictionary.pdf",
  "ITA_data_users_guide.pdf" = "files/ITA_data_users_guide.pdf",
  "ComparisonBetweenOSHAITA_Data_and_BLS_SOII_Estimates.pdf" =
    "files/ComparisonBetweenOSHAITA_Data_and_BLS_SOII_Estimates.pdf"
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
  download.file(paste0(osha, sources[[name]]), tmp, mode = "wb")
  file.rename(tmp, dest)
}
message("done: files are in ", normalizePath(raw_dir))

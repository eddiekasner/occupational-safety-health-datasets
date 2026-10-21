# Download the Labour Department's occupational safety and health statistics into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# The Labour Department publishes Hong Kong's accident and occupational disease statistics each
# year as a PDF, "Occupational Safety and Health Statistics" (https://www.labour.gov.hk, under
# Occupational Safety, then Statistics). Two editions give 1999 to 2025: the 2025 edition has
# ten-year tables for 2016 to 2025 and detailed tables for 2024 and 2025, and the 2015 edition
# has ten-year tables for 2006 to 2015 (industrial accidents from 1999). Two Excel workbooks from
# data.gov.hk give the department's occupational health services and clinic patients. About 3 MB.
# Files already downloaded are skipped; delete them to download again.
# Next step: run scripts/extract_tables.py (Python), which reads the tables.

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

files <- c(
  "OSH_Statistics_2025_en.pdf" =
    "https://www.labour.gov.hk/common/osh/pdf/OSH_Statistics_2025_en.pdf",
  "OSH_Statistics_2015_en.pdf" =
    "https://www.labour.gov.hk/eng/osh/pdf/OSH_Statistics_2015_EN.pdf",
  "ohs-keystats_en.xlsx" =
    "https://www.labour.gov.hk/datagovhk/resource/ohs/ohs-keystats_en.xlsx",
  "ohs-keystats-new-patients-attend-ohc-breakdown-type-of-diseases_en.xlsx" = paste0(
    "https://www.labour.gov.hk/datagovhk/resource/ohs/",
    "ohs-keystats-new-patients-attend-ohc-breakdown-type-of-diseases_en.xlsx")
)
for (name in names(files)) {
  dest <- file.path(raw_dir, name)
  if (file.exists(dest)) next
  message("downloading ", name)
  # The connection sometimes fails on the first try, so retry a few times
  for (attempt in 1:5) {
    ok <- tryCatch({
      curl::curl_download(files[[name]], dest, handle = curl::new_handle(connecttimeout = 30))
      TRUE
    }, error = function(e) {
      message("  attempt ", attempt, " failed: ", conditionMessage(e))
      FALSE
    })
    if (ok) break
    Sys.sleep(2 * attempt)
  }
  if (!ok) stop("Could not download ", name)
}
message("Done: files are in ", normalizePath(raw_dir),
        ". Next: run scripts/extract_tables.py")

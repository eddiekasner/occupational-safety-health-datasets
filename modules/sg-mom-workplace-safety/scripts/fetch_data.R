# Download the Ministry of Manpower's Workplace Safety and Health Reports into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# MOM publishes Singapore's national workplace safety and health statistics as an annual PDF
# report (https://www.mom.gov.sg/workplace-safety-and-health/wsh-reports-and-statistics). Each
# report's statistical tables cover two or three years, so four reports give 2018 to 2025. About
# 9 MB. Files already downloaded are skipped; delete them to download again.
# Next step: run scripts/extract_tables.py (Python), which reads the tables from the PDFs.

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

base <- "https://www.mom.gov.sg/-/media/mom/documents/safety-health/reports-stats/wsh-national-statistics/"
for (year in c(2019, 2021, 2023, 2025)) {
  name <- sprintf("wsh-national-stats-%d.pdf", year)
  dest <- file.path(raw_dir, name)
  if (file.exists(dest)) next
  message("downloading ", name)
  # The site refuses requests without a browser-like user agent
  h <- curl::new_handle(useragent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36")
  curl::curl_download(paste0(base, name), dest, handle = h)
}
message("Done: files are in ", normalizePath(raw_dir),
        ". Next: run scripts/extract_tables.py")

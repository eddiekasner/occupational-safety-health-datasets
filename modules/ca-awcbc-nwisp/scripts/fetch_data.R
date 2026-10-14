# Download the AWCBC National Work Injury, Disease and Fatality Statistics publication into
# data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# By downloading you agree to the AWCBC NWISP Terms and Conditions:
# https://awcbc.org/data-and-statistics/national-work-injury-disease-statistics-program/nwisp-terms-and-conditions
#
# The publication (about 10 MB, 569 pages) has 42 tables of accepted lost time claims and
# fatalities. AWCBC publishes a new edition each year, covering the latest three years; update
# `publication_url` from the NWISP page:
# https://awcbc.org/data-and-statistics/national-work-injury-disease-statistics-program
# Next step: run scripts/build_dataset.R.

publication_url <- paste0("https://awcbc.org/files/statisticsHidden/",
                          "National-Work-Injury-Disease-and-Fatality-Statistics-2022-2024.pdf")

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

options(HTTPUserAgent = "Mozilla/5.0 (OSH teaching datasets; R)", timeout = 600)

dest <- file.path(raw_dir, basename(publication_url))
if (file.exists(dest)) {
  message("Already have ", basename(dest))
} else {
  message("Downloading ", basename(dest))
  download.file(publication_url, dest, mode = "wb", quiet = TRUE)
}
message("Done. Next: run scripts/build_dataset.R")

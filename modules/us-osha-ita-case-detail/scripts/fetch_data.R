# Download the full ITA case detail files into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Files that already exist in data/raw/ are skipped. The files are large, so the
# first download can take several minutes.

# Direct download links from OSHA's ITA data page:
# https://www.osha.gov/Establishment-Specific-Injury-and-Illness-Data
# Right-click each "Case Detail Data" link and choose "Copy link address".
sources <- c(
  # "ita_case_detail_2023.zip" = "https://www.osha.gov/...",
  # "ita_case_detail_2024.zip" = "https://www.osha.gov/...",
  # "ita_case_detail_2025.zip" = "https://www.osha.gov/..."
)

script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  if (!is.null(sys.frame(1)$ofile)) return(dirname(normalizePath(sys.frame(1)$ofile)))
  getwd()
}

raw_dir <- file.path(script_dir(), "..", "data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

if (length(sources) == 0) {
  stop("No download links yet. Add OSHA's links to `sources` at the top of this script, ",
       "or download the files by hand into ", normalizePath(raw_dir))
}

options(timeout = 3600)
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

# Download Health and Safety Executive (HSE) injury statistics tables into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Downloads two sets of Excel tables (about 8 MB in total):
#   RIDDOR  injuries employers reported under the Reporting of Injuries, Diseases and Dangerous
#           Occurrences Regulations
#   LFS     injuries workers reported in the Labour Force Survey
# Existing files are skipped. Next step: run scripts/build_dataset.R.
#
# Sources: https://www.hse.gov.uk/statistics/tables/index.htm
#          https://www.hse.gov.uk/statistics/lfs/tables.htm

riddor_tables <- c(
  "ridhist",    # fatal and non-fatal injuries since 1974, by broad industry
  "ridind",     # by detailed industry
  "ridkind",    # by kind of accident and broad industry
  "ridagegen",  # by age, gender and broad industry
  "ridnat",     # by nature of injury
  "ridsite",    # by site of injury (part of body)
  "ridreg",     # by country, region and local authority
  "ridfatal"    # fatal injuries, latest five years
)
lfs_tables <- c(
  "lfsinjsum",  # summary
  "lfsinjind",  # by industry
  "lfsinjocc",  # by occupation
  "lfsinjknd",  # by kind of accident
  "lfsinjnat",  # by nature of injury
  "lfsinjage",  # by age and gender
  "lfsinjreg",  # by country and region
  "lfsinjsiz"   # by workplace size
)

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

# Some government sites reject R's default user agent
options(HTTPUserAgent = "Mozilla/5.0 (OSH teaching datasets; R)", timeout = 300)

base_url <- "https://www.hse.gov.uk/statistics/assets/docs/"
for (name in c(riddor_tables, lfs_tables)) {
  dest <- file.path(raw_dir, paste0(name, ".xlsx"))
  if (file.exists(dest)) {
    message("Already have ", basename(dest))
    next
  }
  message("Downloading ", basename(dest))
  download.file(paste0(base_url, name, ".xlsx"), dest, mode = "wb", quiet = TRUE)
}
message("Done. Next: run scripts/build_dataset.R")

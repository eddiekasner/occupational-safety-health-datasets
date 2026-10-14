# Get newer versions of the Safe Work Australia source files.
#
# The files used by this module are already in data/source/, so you do not need to run this
# to use the notebook.
#
# Safe Work Australia's data website does not allow scripted downloads, so new files must be
# downloaded by hand. This script opens the download pages in your browser and then checks
# that data/source/ holds one file of each kind.
#
# Usage (from RStudio): open this file and click "Source"
#
# 1. On each page below, download the "detailed data file" (Excel) and, if updated, the
#    explanatory notes:
#      Traumatic Injury Fatalities      (work-related fatalities page)
#      National Dataset for Compensation-based Statistics and
#      Workers' compensation injury frequency rates (workers' compensation page)
# 2. Save them in data/source/, replacing the old files. Keep names starting with
#      traumatic_injury_fatalities...
#      national_dataset_for_compensation...
#      workers_compensation_injury_frequency...
# 3. Run scripts/build_dataset.R

pages <- c(
  "https://data.safeworkaustralia.gov.au/about-our-datasets/work-related-fatalities-data",
  "https://data.safeworkaustralia.gov.au/about-our-datasets/workers-compensation-data"
)

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) {
  dirname(normalizePath(sub("^--file=", "", file_arg)))
} else if (!is.null(sys.frame(1)$ofile)) {
  dirname(normalizePath(sys.frame(1)$ofile))
} else {
  getwd()
}
source_dir <- normalizePath(file.path(script_dir, "..", "data", "source"), mustWork = FALSE)

if (interactive()) for (p in pages) utils::browseURL(p) else cat("Download pages:\n", paste(pages, collapse = "\n "), "\n")

patterns <- c(TIF = "^traumatic_injury_fatalities.*\\.xlsx$",
              NDS = "^national_dataset_for_compensation.*\\.xlsx$",
              WCIFR = "^workers_compensation_injury_frequency.*\\.xlsx$")
for (name in names(patterns)) {
  found <- list.files(source_dir, pattern = patterns[[name]], ignore.case = TRUE)
  status <- if (length(found) == 1) found else if (length(found) == 0) "MISSING" else "MORE THAN ONE FILE"
  cat(sprintf("%-6s %s\n", name, status))
}
cat("When each line shows one file, run scripts/build_dataset.R\n")

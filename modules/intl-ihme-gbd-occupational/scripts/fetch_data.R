# Get the GBD occupational risk data from IHME.
#
# IHME's GBD Results Tool requires a (free) sign-in, so the data cannot be downloaded by a script.
# Follow the steps in this module's README ("Getting the data"). This script opens the tool in
# your web browser and lists the files you have so far in data/raw/.
#
# Usage (from RStudio):  open this file and click "Source"

script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  if (!is.null(sys.frame(1)$ofile)) return(dirname(normalizePath(sys.frame(1)$ofile)))
  getwd()
}
raw_dir <- file.path(script_dir(), "..", "data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

if (interactive()) utils::browseURL("https://vizhub.healthdata.org/gbd-results/")

files <- list.files(raw_dir, pattern = "\\.(zip|csv)$", ignore.case = TRUE)
if (length(files)) {
  message("Files in data/raw/:\n  ", paste(files, collapse = "\n  "),
          "\nNext: run scripts/prepare_data.R")
} else {
  message("No GBD files in ", normalizePath(raw_dir), " yet. Download them as described in the ",
          "README and save them there.")
}

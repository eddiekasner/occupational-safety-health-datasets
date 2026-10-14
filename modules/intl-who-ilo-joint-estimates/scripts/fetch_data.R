# Get the full WHO/ILO Joint Estimates into data/raw/.
#
# You do NOT need to run this to use the notebook: the tidy tables in data/tidy/ are committed.
#
# WHO and the ILO publish the full estimates (every country, sex, age group and risk factor) only
# through an interactive application:
#   https://who-ilo-joint-estimates.shinyapps.io/OccupationalBurdenOfDisease/
#
# Two ways to get the files:
#
# 1. By hand (any computer with a browser). Open the application, go to the "Data" tab, choose
#    a Parameter, Result and Occupational risk factor, click "Refresh", then "Export". Save each
#    file in data/raw/ named like the files listed below. One export per risk factor.
#
# 2. Automatically, with Node.js and Playwright installed (see scripts/export_from_app.js).
#    This script runs it for you if it can.
#
# The exports total about 1 GB. Next step: run scripts/build_dataset.R.

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) {
  dirname(normalizePath(sub("^--file=", "", file_arg)))
} else if (!is.null(sys.frame(1)$ofile)) {
  dirname(normalizePath(sys.frame(1)$ofile))
} else {
  getwd()
}
raw_dir <- normalizePath(file.path(script_dir, "..", "data", "raw"), mustWork = FALSE)
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

if (nzchar(Sys.which("node"))) {
  message("Running export_from_app.js (this takes 30 to 60 minutes)...")
  status <- system2("node", c(shQuote(file.path(script_dir, "export_from_app.js")), shQuote(raw_dir)))
  if (status != 0) {
    message("The automatic export failed. Is Playwright installed? ",
            "Run: npm install playwright && npx playwright install chromium")
  }
} else {
  message("Node.js was not found. Export the files by hand (see the top of this script).")
}

files <- list.files(raw_dir, pattern = "\\.csv$")
message(length(files), " export files in ", raw_dir, ":\n  ", paste(files, collapse = "\n  "))

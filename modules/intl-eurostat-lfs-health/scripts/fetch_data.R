# Download the Eurostat tables from the Labour Force Survey ad hoc modules on accidents at work and
# work-related health problems (2007, 2013 and 2020).
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Saves one JSON-stat file per table in data/raw/. The tables are small (a few thousand values
# each), so each is downloaded whole; together they are about 15 MB. Existing files are skipped;
# delete them to get fresh data. Next step: run scripts/build_dataset.R.
#
# Source: Eurostat dissemination API (JSON-stat),
# https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access

tables <- c(
  # Accidents at work in the past 12 months
  "hsw_ac1", "hsw_ac2", "hsw_ac3", "hsw_ac4", "hsw_ac5a", "hsw_ac5b", "hsw_ac6a", "hsw_ac6b",
  "hsw_ac7", "hsw_ac8", "hsw_ac9", "hsw_ac10", "hsw_ac11", "hsw_ac12", "hsw_ac13", "hsw_ac14",
  # Work-related health problems in the past 12 months
  "hsw_pb1", "hsw_pb2", "hsw_pb3", "hsw_pb4", "hsw_pb5", "hsw_pb6a", "hsw_pb6b", "hsw_pb7",
  "hsw_pb8", "hsw_pb9", "hsw_pb10", "hsw_pb11", "hsw_pb12", "hsw_pb13",
  # Exposure to risk factors for physical health and mental well-being
  "hsw_exp1", "hsw_exp2", "hsw_exp3", "hsw_exp4", "hsw_exp5a", "hsw_exp5b", "hsw_exp6a",
  "hsw_exp6b", "hsw_exp9", "hsw_exp10"
)

api <- "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/"

script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  if (!is.null(sys.frame(1)$ofile)) return(dirname(normalizePath(sys.frame(1)$ofile)))
  getwd()
}
raw_dir <- file.path(script_dir(), "..", "data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
options(timeout = 300)

download_json <- function(url, dest) {
  for (attempt in 1:5) {
    tmp <- paste0(dest, ".part")
    ok <- tryCatch(suppressWarnings(download.file(url, tmp, mode = "wb", quiet = TRUE)) == 0,
                   error = function(e) FALSE)
    if (ok && !grepl('"error"', readChar(tmp, 200))) return(invisible(file.rename(tmp, dest)))
    Sys.sleep(5 * attempt)  # Eurostat may ask us to try again later
  }
  stop("Could not download ", url)
}

for (table in tables) {
  dest <- file.path(raw_dir, paste0(table, ".json"))
  if (file.exists(dest)) next
  message("downloading ", table)
  download_json(paste0(api, table, "?lang=en"), dest)
}
message("Done: ", length(tables), " tables in ", normalizePath(raw_dir),
        ". Next: run scripts/build_dataset.R")

# Download INAIL's open data on work injuries and occupational diseases into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# INAIL (Italy's national work injury insurer) publishes its open data at https://dati.inail.it,
# and lists every dataset in Italy's national open data catalogue (dati.gov.it). This script asks
# the catalogue for INAIL's datasets and downloads:
#   - the half-yearly ("cadenza semestrale") injury files, one zip per region: every injury
#     report for accidents in the last five calendar years
#   - the half-yearly occupational disease files for all of Italy (by date of report and by date of
#     death)
#   - INAIL's national tables (PDF) that explain and summarise the files
# About 120 MB. INAIL replaces the files twice a year (data as of 30 April and 31 October), so
# downloading again later gives a newer five-year window. Files already downloaded are skipped;
# delete them to download again. Next step: run scripts/build_dataset.R.

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
options(timeout = 1200)

# The catalogue's API (CKAN) lists the datasets and their files
api <- "https://www.dati.gov.it/opendata/api/3/action/package_search?fq=organization:inail&rows=500"
catalogue <- jsonlite::fromJSON(api, simplifyVector = FALSE)$result$results
urls <- unique(unlist(lapply(catalogue, function(p) vapply(p$resources, function(r) r$url, ""))))

wanted <- urls[grepl("daticoncadenzasemestraleinfortuni/zip/.*_csv\\.zip$", urls) |
                 grepl("datisemestralimalattieprofessionali/csv/.*Italia\\.csv$", urls) |
                 grepl("Tabelle_nazionali_cadenza_semestrale.*\\.pdf$", urls)]
wanted <- c(wanted, "https://dati.inail.it/opendata_files/downloads/daticoncadenzasemestraleinfortuni/Tabelle_nazionali_cadenza_semestrale.pdf")
if (sum(grepl("Infortuni.*_csv\\.zip$", wanted)) < 21) {
  warning("Expected 21 regional injury files; found ", sum(grepl("Infortuni.*_csv\\.zip$", wanted)))
}

for (u in unique(wanted)) {
  # The national injury tables have the same file name as the disease tables' prefix; keep apart
  name <- basename(u)
  if (grepl("daticoncadenzasemestraleinfortuni/Tabelle_nazionali", u)) {
    name <- "Tabelle_nazionali_cadenza_semestrale_infortuni.pdf"
  }
  dest <- file.path(raw_dir, name)
  if (file.exists(dest)) next
  message("downloading ", name)
  download.file(u, dest, mode = "wb", quiet = TRUE)
}
message("Done: files are in ", normalizePath(raw_dir), ". Next: run scripts/build_dataset.R")

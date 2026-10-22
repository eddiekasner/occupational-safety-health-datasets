# Download SUSESO's annual statistical yearbooks ("Estadisticas de la Seguridad Social") into
# data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Chile's Superintendencia de Seguridad Social (SUSESO) publishes a statistical yearbook each year
# as an Excel workbook on https://www.suseso.gob.cl/608/w3-propertyvalue-10364.html. Chapter I
# covers the insurance against work accidents and occupational diseases (Law 16.744). This script
# reads that page and downloads the yearbooks for 2014 to 2025 (about 35 MB). Files already
# downloaded are skipped; delete them to download again.
# Next step: run scripts/extract_tables.py (Python), which reads the tables.

years <- 2014:2025

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

handle <- function() curl::new_handle(connecttimeout = 30, useragent = "Mozilla/5.0")
download <- function(url, dest) {
  for (attempt in 1:5) {
    ok <- tryCatch({
      curl::curl_download(url, dest, handle = handle())
      TRUE
    }, error = function(e) FALSE)
    if (ok) return(invisible(TRUE))
    Sys.sleep(2 * attempt)
  }
  stop("Could not download ", url)
}

base <- "https://www.suseso.gob.cl/608/"
html <- rawToChar(curl::curl_fetch_memory(paste0(base, "w3-propertyvalue-10364.html"),
                                          handle = handle())$content)
# Links look like: <a href="articles-781783_archivo_01.xlsx?ts=..." ...>Estadisticas de la
# Seguridad Social 2025</a>
links <- regmatches(html, gregexpr(
  'href="articles-[0-9]+_archivo_01\\.xlsx[^"]*"[^>]*>[^<]*Seguridad Social (19|20)[0-9]{2}\\s*<',
  html, useBytes = TRUE))[[1]]
for (year in years) {
  dest <- file.path(raw_dir, sprintf("estadisticas_seguridad_social_%d.xlsx", year))
  if (file.exists(dest)) next
  link <- grep(sprintf("Seguridad Social %d\\s*<", year), links, value = TRUE, useBytes = TRUE)
  if (!length(link)) stop("No link to the ", year, " yearbook")
  file <- sub('^href="([^"?]+).*$', "\\1", link[1], useBytes = TRUE)
  message("downloading the ", year, " yearbook")
  download(paste0(base, file), dest)
}
message("Done: files are in ", normalizePath(raw_dir), ". Next: run scripts/extract_tables.py")

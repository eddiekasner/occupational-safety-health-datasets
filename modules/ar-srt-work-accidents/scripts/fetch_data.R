# Download the historical series of work accident statistics of Argentina's Superintendencia de
# Riesgos del Trabajo (SRT) into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# SRT publishes its historical series ("Serie historica de accidentabilidad laboral") as Excel
# workbooks on https://www.srt.gob.ar/estadisticas/acc_serie_historica.php: national indicators,
# and indicators by province, sector, sex, age and size of employer, from 1996. This script reads
# that page and downloads every workbook it links to (21 files, about 3 MB). Files already
# downloaded are skipped; delete them to download again.
# Next step: run scripts/extract_tables.py (Python), which reads the tables.

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

page <- "https://www.srt.gob.ar/estadisticas/acc_serie_historica.php"
html <- rawToChar(curl::curl_fetch_memory(page, handle = handle())$content)
Encoding(html) <- "UTF-8"
links <- unique(regmatches(html, gregexpr('https://www\\.srt\\.gob\\.ar/estadisticas/series/acc/[^"]+\\.xlsx', html))[[1]])
if (!length(links)) stop("No workbooks found on ", page)
message(length(links), " workbooks")

for (url in links) {
  # Some file names have accents, so take the name byte by byte
  name <- sub("^.*/", "", url, useBytes = TRUE)
  dest <- file.path(raw_dir, name)
  if (file.exists(dest)) next
  message("downloading ", name)
  download(utils::URLencode(url), dest)
}
message("Done: files are in ", normalizePath(raw_dir), ". Next: run scripts/extract_tables.py")

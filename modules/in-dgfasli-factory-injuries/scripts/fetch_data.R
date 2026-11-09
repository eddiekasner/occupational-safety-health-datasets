# Download the Standard Reference Notes of India's Directorate General Factory Advice Service and
# Labour Institutes (DGFASLI) into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# DGFASLI publishes a Standard Reference Note each year as a PDF, listed by year on
# https://dgfasli.gov.in/Standard-reference-notes (2006 to 2024). Their
# statistics chapters hold the tables this module uses. This script reads that page and downloads
# every note it links to (19 files, about 90 MB). Files already downloaded are skipped; delete them
# to download again.
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

handle <- function() curl::new_handle(connecttimeout = 30, timeout = 600)
download <- function(url, dest) {
  for (attempt in 1:5) {
    ok <- tryCatch({
      curl::curl_download(url, dest, handle = handle())
      TRUE
    }, error = function(e) FALSE)
    if (ok) return(invisible(TRUE))
    Sys.sleep(2 * attempt)
  }
  warning("Could not download ", url)
}

page <- "https://dgfasli.gov.in/Standard-reference-notes"
html <- rawToChar(curl::curl_fetch_memory(page, handle = handle())$content)
Encoding(html) <- "UTF-8"
# Links whose text is a year: <a href="...pdf">2024</a>
links <- regmatches(html, gregexpr('<a[^>]+href="[^"]+\\.pdf"[^>]*>\\s*(<[^>]+>\\s*)*20[0-9]{2}\\s*(<[^>]+>\\s*)*</a>',
                                   html, ignore.case = TRUE))[[1]]
if (!length(links)) stop("No notes found on ", page)
urls <- sub('^.*href="([^"]+)".*$', "\\1", links)
years <- sub("^.*>\\s*(20[0-9]{2})\\s*<.*$", "\\1", gsub("\\s+", " ", links))
message(length(urls), " notes: ", paste(sort(years), collapse = ", "))

for (i in seq_along(urls)) {
  dest <- file.path(raw_dir, paste0("standard_reference_note_", years[i], ".pdf"))
  if (file.exists(dest)) next
  message("downloading the ", years[i], " note")
  download(urls[i], dest)
}
message("Done: files are in ", normalizePath(raw_dir), ". Next: run scripts/extract_tables.py")

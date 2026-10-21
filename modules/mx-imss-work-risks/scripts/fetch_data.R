# Download chapter VII (occupational health) of the IMSS statistical yearbooks into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# The Mexican Social Security Institute (IMSS) publishes a statistical yearbook, the Memoria
# Estadistica, each year (https://www.imss.gob.mx/conoce-al-imss/memoria-estadistica-2024). Its
# chapter VII, "Salud en el Trabajo", is an Excel workbook of tables on work accidents, commuting
# accidents, occupational diseases and disability rulings. This script downloads the 2016 to 2024
# workbooks, about 11 MB. Files already downloaded are skipped; delete them to download again.
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

base <- "https://www.imss.gob.mx/sites/all/statics/pdf/estadisticas/memoria/"
for (year in 2016:2024) {
  dest <- file.path(raw_dir, sprintf("memoria_%d_salud_trabajo.xlsx", year))
  if (file.exists(dest)) next
  message("downloading the ", year, " yearbook")
  # The connection sometimes fails on the first try, so retry a few times
  for (attempt in 1:5) {
    ok <- tryCatch({
      curl::curl_download(paste0(base, year, "/07-SaludTrabajo.xlsx"), dest,
                          handle = curl::new_handle(connecttimeout = 30,
                                                    useragent = "Mozilla/5.0"))
      TRUE
    }, error = function(e) {
      message("  attempt ", attempt, " failed: ", conditionMessage(e))
      FALSE
    })
    if (ok) break
    Sys.sleep(2 * attempt)
  }
  if (!ok) stop("Could not download the ", year, " yearbook")
}
message("Done: files are in ", normalizePath(raw_dir),
        ". Next: run scripts/extract_tables.py")

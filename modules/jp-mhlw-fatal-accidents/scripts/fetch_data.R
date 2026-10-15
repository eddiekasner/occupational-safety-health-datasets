# Download the yearly files of MHLW's fatal accident database (死亡災害データベース) into
# data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# The database page lists one Excel file per year since 1991:
# https://anzeninfo.mhlw.go.jp/anzen_pg/SIB_FND.html
# This script reads that page, downloads every file it lists (about 22 MB in all), and also
# downloads MHLW's guide to the database (a Word document, in Japanese). Files already downloaded
# are skipped. MHLW adds a new year each autumn. Next step: run scripts/build_dataset.R.

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
options(timeout = 600)

site <- "https://anzeninfo.mhlw.go.jp"
page <- paste(readLines(paste0(site, "/anzen_pg/SIB_FND.html"), encoding = "UTF-8", warn = FALSE),
              collapse = "\n")
links <- unique(regmatches(page, gregexpr("sib_xls/sibou_db_[a-z0-9]+\\.xlsx?", page))[[1]])
if (!length(links)) stop("No Excel files found on the database page; it may have changed.")

for (link in c(paste0("/anzen/", links), "/anzen_pg/rousai_db_siyou1109.doc")) {
  dest <- file.path(raw_dir, basename(link))
  if (file.exists(dest)) next
  message("downloading ", basename(link))
  download.file(paste0(site, link), dest, mode = "wb", quiet = TRUE)
}
message("Done: ", length(links), " yearly files in ", normalizePath(raw_dir))

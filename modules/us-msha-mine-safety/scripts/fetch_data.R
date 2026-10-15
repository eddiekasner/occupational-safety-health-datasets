# Download MSHA (Mine Safety and Health Administration) open data files into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Downloads from https://arlweb.msha.gov/OpenGovernmentData/OGIMSHA.asp, as zip files (unzipped
# here) plus their definition (data dictionary) files:
#   Accidents                accidents, injuries and illnesses reported by mine operators and
#                            contractors (MSHA Form 7000-1), 2000 onward
#   Mines                    every mine MSHA has assigned an ID, with its location and commodity
#   MinesProdQuarterly       hours worked, employees and coal production reported by mine
#                            operators each quarter (MSHA Form 7000-2), 2000 onward
#   ContractorProdQuarterly  the same, reported by contractors
#   Violations               every citation and order MSHA has issued, 2000 onward
# About 330 MB to download and 2.1 GB unzipped. MSHA updates the files weekly. Files already
# downloaded are skipped; delete them to download again. Next step: run scripts/build_dataset.R.

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

options(timeout = 3600)
base_url <- "https://arlweb.msha.gov/OpenGovernmentData/DataSets/"
# The MSHA server refuses some requests that do not look like they come from a web browser
headers <- c(`User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")

files <- c("Accidents", "Mines", "MinesProdQuarterly", "ContractorProdQuarterly", "Violations")
definitions <- c("Accidents_Definition_File.txt", "Mines_Definition_File.txt",
                 "MineSProdQuarterly_Definition_File.txt",
                 "ContractorProdQuarterly_Definition_File.txt", "violations_Definition_File.txt")

for (f in files) {
  zip <- file.path(raw_dir, paste0(f, ".zip"))
  if (!file.exists(zip)) {
    message("Downloading ", f, ".zip")
    download.file(paste0(base_url, f, ".zip"), zip, mode = "wb", headers = headers)
  }
  if (!file.exists(file.path(raw_dir, paste0(f, ".txt")))) unzip(zip, exdir = raw_dir)
}
for (d in definitions) {
  dest <- file.path(raw_dir, d)
  if (!file.exists(dest)) download.file(paste0(base_url, d), dest, mode = "wb", headers = headers)
}
message("Done. Files are in ", normalizePath(raw_dir))

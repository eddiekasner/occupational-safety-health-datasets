# Download ILOSTAT occupational safety and health indicators into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Downloads 19 indicators (about 135 MB with labels) plus a table of UN regions.
# Files that already exist are skipped; delete them to get fresh data.
# Next step: run scripts/build_dataset.R.
#
# Source: ILOSTAT data API, https://rplumber.ilo.org/__docs__/
# Indicator catalog: https://rplumber.ilo.org/metadata/toc/indicator/?lang=en&format=.csv

indicators <- c(
  # Occupational injuries: rates per 100,000 workers
  "INJ_FATL_SEX_MIG_RT_A", "INJ_NFTL_SEX_MIG_RT_A",
  "INJ_FATL_ECO_RT_A", "INJ_NFTL_ECO_RT_A",
  # Occupational injuries: cases, days lost, workers covered
  "INJ_FATL_SEX_MIG_NB_A", "INJ_NFTL_SEX_MIG_NB_A",
  "INJ_FATL_ECO_NB_A", "INJ_NFTL_ECO_NB_A",
  "INJ_NFTL_SEX_INJ_MIG_NB_A", "INJ_NFTL_INJ_ECO_NB_A",
  "INJ_DAYS_SEX_MIG_NB_A", "INJ_DAYS_ECO_NB_A",
  "INJ_WORK_SEX_MIG_NB_A", "INJ_WORK_ECO_NB_A",
  # Labour inspection
  "LAI_INSP_SEX_NB_A", "LAI_INDE_NOC_RT_A", "LAI_VIST_NOC_NB_A",
  "LAI_VDIN_NOC_RT_A", "LAI_WOPL_NOC_NB_A"
)

script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  if (!is.null(sys.frame(1)$ofile)) return(dirname(normalizePath(sys.frame(1)$ofile)))
  getwd()
}

raw_dir <- file.path(script_dir(), "..", "data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

# The ILO's servers may reject requests that do not look like a web browser.
headers <- c("User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36",
             "Accept" = "text/html,*/*")
options(timeout = 600)

fetch <- function(url, name) {
  dest <- file.path(raw_dir, name)
  if (file.exists(dest)) {
    message("already have ", name)
    return(invisible())
  }
  message("downloading ", name)
  tmp <- paste0(dest, ".part")
  download.file(url, tmp, mode = "wb", quiet = TRUE, headers = headers)
  if (file.size(tmp) == 0) stop("Empty download for ", name, ". The ILO server may be blocking the request.")
  invisible(file.rename(tmp, dest))
}

api <- "https://rplumber.ilo.org"
for (id in indicators) {
  fetch(sprintf("%s/data/indicator/?id=%s&format=.csv&type=both&lang=en", api, id), paste0(id, ".csv"))
}
invisible(fetch(paste0(api, "/aggregate/region/?groups=unsd&format=.csv"), "regions_unsd.csv"))
message("done: files are in ", normalizePath(raw_dir))

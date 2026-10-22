# Download child labour statistics from ILOSTAT and UNICEF into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# ILOSTAT (the International Labour Organization's database) publishes child labour statistics
# that the ILO computes from national household surveys: the shares of children in economic
# activity, in child labour and in hazardous work, by sex, age, rural or urban area and school
# attendance, and the numbers of children working by economic sector and status in employment.
# UNICEF publishes the latest estimate of child labour for each country and region, with the survey
# it comes from. This script saves one CSV file per table, about 30 MB in all. Existing files are
# skipped; delete them to download again. Next step: run scripts/build_dataset.R.
#
# Sources: ILOSTAT data API, https://rplumber.ilo.org/__docs__/
#          UNICEF data warehouse (SDMX API), https://sdmx.data.unicef.org

ilostat <- c(
  # Shares of children (%), by sex and age; by rural or urban area; by school attendance
  "CLD_XSNA_SEX_AGE_RT", "CLD_XCHL_SEX_AGE_RT", "CLD_XHAZ_SEX_AGE_RT", "CLD_XGPB_SEX_AGE_RT",
  "CLD_XSNA_SEX_AGE_GEO_RT", "CLD_XCHL_SEX_AGE_GEO_RT", "CLD_XHAZ_SEX_AGE_GEO_RT",
  "CLD_XSNA_SEX_AGE_STU_RT", "CLD_XCHL_SEX_AGE_STU_RT", "CLD_XHAZ_SEX_AGE_STU_RT",
  # SDG indicator 8.7.1: economic activity, and economic activity and household chores
  "SDG_A871_SEX_AGE_RT", "SDG_B871_SEX_AGE_RT",
  # Numbers of children (thousands) by economic sector and by status in employment
  "CLD_XSNA_SEX_AGE_ECO_NB", "CLD_XCHL_SEX_AGE_ECO_NB", "CLD_XHAZ_SEX_AGE_ECO_NB",
  "CLD_XSNA_SEX_AGE_STE_NB", "CLD_XCHL_SEX_AGE_STE_NB", "CLD_XHAZ_SEX_AGE_STE_NB",
  # Child population (thousands)
  "CLD_TPOP_SEX_AGE_NB"
)
unicef <- c("PT_CHLD_5-17_LBR_ECON", "PT_CHLD_5-17_LBR_ECON-HC", "PT_ADLS_10-14_LBR_HC")

script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(file_arg)) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  if (!is.null(sys.frame(1)$ofile)) return(dirname(normalizePath(sys.frame(1)$ofile)))
  getwd()
}
raw_dir <- file.path(script_dir(), "..", "data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

# ILOSTAT returns an empty file unless the request looks like it comes from a browser
browser <- "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36"

fetch <- function(url, dest, headers = character()) {
  if (file.exists(dest)) return(invisible())
  message("downloading ", basename(dest))
  for (attempt in 1:5) {
    h <- curl::new_handle(connecttimeout = 30, useragent = browser)
    if (length(headers)) curl::handle_setheaders(h, .list = as.list(headers))
    ok <- tryCatch({
      curl::curl_download(url, paste0(dest, ".part"), handle = h)
      file.size(paste0(dest, ".part")) > 0
    }, error = function(e) FALSE)
    if (ok) return(invisible(file.rename(paste0(dest, ".part"), dest)))
    Sys.sleep(5 * attempt)
  }
  stop("Could not download ", url)
}

for (id in ilostat) {
  fetch(sprintf("https://rplumber.ilo.org/data/indicator/?id=%s_A&format=.csv&type=both&lang=en", id),
        file.path(raw_dir, paste0(id, ".csv")))
}
for (id in unicef) {
  fetch(sprintf("https://sdmx.data.unicef.org/ws/public/sdmxapi/rest/data/UNICEF,GLOBAL_DATAFLOW,1.0/.%s....", id),
        file.path(raw_dir, paste0("unicef_", id, ".csv")),
        c(Accept = "application/vnd.sdmx.data+csv;labels=both"))
}
message("Done: files are in ", normalizePath(raw_dir), ". Next: run scripts/build_dataset.R")

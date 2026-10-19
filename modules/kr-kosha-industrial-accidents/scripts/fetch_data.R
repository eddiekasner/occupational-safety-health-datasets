# Download KOSHA's industrial accident microdata into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# KOSHA (the Korea Occupational Safety and Health Agency) publishes Korea's official industrial
# accident statistics as microdata on its Occupational Safety Portal ("산업재해현황 데이터"
# page, https://portal.kosha.or.kr/archive/indus-acc-statis/indus-status-data). Each Excel file
# has one row per injured worker or death, for one year and one major industry. The portal's
# "microdata" button calls the same address this script uses. There are 9 years (2017 to 2025) x
# 10 industries = 90 files, about 70 MB. Files already downloaded are skipped; delete them to
# download again. Next step: run scripts/build_dataset.R.

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

api <- "https://portal.kosha.or.kr/api/portal24/bizV/p/VCPDG03003/"
years <- 2017:2025
industries <- 0:9  # KOSHA's 10 major industry groups (see build_dataset.R)
# Injured person types: 11 accident injury, 12 occupational disease, 31 accident death,
# 32 occupational disease death, 39 other death (not counted as an accident death; see README)
person_types <- "11,12,31,32,39"

post <- function(endpoint, body, dest = NULL) {
  h <- curl::new_handle(customrequest = "POST", postfields = body, http_version = 2L,
                        timeout = 300)
  curl::handle_setheaders(h, "Content-Type" = "application/json",
                          "Origin" = "https://portal.kosha.or.kr",
                          "Referer" = "https://portal.kosha.or.kr/archive/indus-acc-statis/indus-status-data",
                          "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36")
  for (attempt in 1:5) {
    res <- tryCatch(
      if (is.null(dest)) curl::curl_fetch_memory(paste0(api, endpoint), handle = h)
      else curl::curl_fetch_disk(paste0(api, endpoint), dest, handle = h),
      error = function(e) NULL)
    if (!is.null(res) && res$status_code == 200) return(res)
    Sys.sleep(2 * attempt)
  }
  stop("download failed: ", endpoint, " ", body)
}

# Check which years the portal offers (it adds a year each spring)
offered <- jsonlite::fromJSON(rawToChar(post("selectYmList", "{}")$content))
offered <- as.integer(substr(offered$payload$selectYmList$statsStdrYm, 1, 4))
if (!all(years %in% offered)) warning("Years not offered: ", setdiff(years, offered))
if (any(offered > max(years))) message("Newer years are available: ", max(offered))

for (y in years) for (i in industries) {
  dest <- file.path(raw_dir, sprintf("kosha_microdata_%d_industry%d.xlsx", y, i))
  if (file.exists(dest)) next
  message("downloading ", basename(dest))
  body <- sprintf('{"ym":"%d12","dsstr":"%s","indscl":"%d"}', y, person_types, i)
  tmp <- paste0(dest, ".part")
  post("downloadOlapData", body, tmp)
  file.rename(tmp, dest)
}
# KOSHA's manufacturing accident case descriptions (Korean, CSV in the Korean Windows encoding,
# CP949), from Korea's public data portal. The English translations in
# data/tidy/accident_cases.csv.gz were made once from this file (see the README).
cases <- file.path(raw_dir, "kosha_accident_cases.csv")
if (!file.exists(cases)) {
  message("downloading kosha_accident_cases.csv")
  for (attempt in 1:5) {
    ok <- tryCatch({
      download.file(paste0("https://www.data.go.kr/cmm/cmm/fileDownload.do?",
                           "atchFileId=FILE_000000007670926&fileDetailSn=1&insertDataPrcus=N"),
                    cases, mode = "wb", quiet = TRUE)
      TRUE
    }, error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.size(cases) > 0) break
    Sys.sleep(3 * attempt)
  }
}

message("Done: files are in ", normalizePath(raw_dir), ". Next: run scripts/build_dataset.R")

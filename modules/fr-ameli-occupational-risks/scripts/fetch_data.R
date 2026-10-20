# Download Assurance Maladie's occupational risk ("risques professionnels") datasets into data/raw/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# The Caisse nationale de l'Assurance Maladie (Cnam), which runs France's workers' compensation
# insurance for the general scheme (régime général), publishes statistics on work accidents,
# commuting accidents and occupational diseases on its open data portal, data.ameli.fr, under the
# Open Database License (ODbL). This script downloads each dataset as a CSV file through the
# portal's export API (about 200 MB in all). Files already downloaded are skipped; delete them to
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

datasets <- c(
  "sinistralite-par-secteur-d-activite-concerne-naf-1",          # accidents, workers, frequency
  "deces-par-secteur-d-activite-naf-1-et-naf-5",                 # deaths
  "arrets-de-travail-par-secteur-d-activite-naf-1-et-naf-5",     # days of sick leave
  "incapacites-permanentes-par-secteur-d-activite-naf-1-et-naf-5",  # permanent incapacity
  "causes-des-accidents-du-travail-par-secteur-d-activite-naf-1-et-naf-5",
  "causes-des-accidents-de-trajet-par-secteur-d-activite-naf-1-et-naf-5",
  "maladies-professionnelles-par-groupe-et-secteur-d-activite-naf-1-et-naf-5",
  "troubles-musculosquelettiques-par-tableau-et-secteur-d-activite-naf-1-et-naf-5",
  "troubles-musculosquelettiques-par-partie-du-corps-sexe-et-secteur-d-activite-naf-1-et-naf-5",
  "maladies-professionnelles-psychiques-par-secteur-d-activite-naf-1-et-naf-5",
  "entreprises-et-salaries-par-taille-d-entreprise-et-secteur-d-activite-naf-1-et-naf-5",
  "sinistralite-par-region-administrative",
  "depenses-par-poste"
)
api <- "https://data.ameli.fr/api/explore/v2.1/catalog/datasets/"

for (d in datasets) {
  dest <- file.path(raw_dir, paste0(d, ".csv"))
  if (file.exists(dest)) next
  message("downloading ", d)
  url <- paste0(api, d, "/exports/csv?delimiter=%3B&with_bom=false")
  for (attempt in 1:10) {
    ok <- tryCatch({
      curl::curl_download(url, paste0(dest, ".part"),
                          handle = curl::new_handle(http_version = 2L, connecttimeout = 30,
                                                    timeout = 900))
      TRUE
    }, error = function(e) FALSE)
    if (ok && file.size(paste0(dest, ".part")) > 0) break
    Sys.sleep(3 * attempt)  # the first connections often time out; try again
  }
  if (!ok) stop("download failed: ", d)
  file.rename(paste0(dest, ".part"), dest)
}
message("Done: files are in ", normalizePath(raw_dir), ". Next: run scripts/build_dataset.R")

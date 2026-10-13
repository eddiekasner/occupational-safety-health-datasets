# Build the small committed sample from the full processed table.
#
# Usage:  Rscript scripts/make_sample.R          # 10% of inspections
#         Rscript scripts/make_sample.R 0.05     # 5% of inspections
#
# Reads data/processed/chemical_exposure_2013_2025.csv (from build_dataset.R) and
# writes data/sample/chemical_exposure_sample.csv. Whole inspections are sampled,
# so every result from a sampled inspection is kept together. A fixed random seed
# keeps the sample the same each time it is rebuilt.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
})

args <- commandArgs(trailingOnly = TRUE)
fraction <- if (length(args)) as.numeric(args[1]) else 0.10

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
full_path <- file.path(module_dir, "data", "processed", "chemical_exposure_2013_2025.csv")
sample_path <- file.path(module_dir, "data", "sample", "chemical_exposure_sample.csv")

if (!file.exists(full_path)) stop("Missing ", full_path, ". Run build_dataset.R first.")
full <- read_csv(full_path, col_types = cols(.default = col_character()), progress = FALSE)

set.seed(312)
inspections <- sort(unique(full$inspection_number))
keep <- sample(inspections, round(fraction * length(inspections)))
result <- filter(full, inspection_number %in% keep)

dir.create(dirname(sample_path), recursive = TRUE, showWarnings = FALSE)
write_csv(result, sample_path, na = "")
message(sprintf("kept %s of %s inspections: %s rows, %.1f MB",
                format(length(keep), big.mark = ","), format(length(inspections), big.mark = ","),
                format(nrow(result), big.mark = ","), file.size(sample_path) / 1e6))

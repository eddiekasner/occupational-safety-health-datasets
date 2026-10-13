# Build the small committed sample from the full files in data/raw/.
#
# Usage:  Rscript scripts/make_sample.R          # 2,000 random cases per file
#         Rscript scripts/make_sample.R 5000
#
# Reads every .csv and .zip in data/raw/ and writes
# data/sample/ita_case_detail_sample.csv. A fixed random seed keeps the sample
# the same each time it is rebuilt.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
})

args <- commandArgs(trailingOnly = TRUE)
n_per_file <- if (length(args)) as.integer(args[1]) else 2000

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
raw_dir <- file.path(module_dir, "data", "raw")
sample_path <- file.path(module_dir, "data", "sample", "ita_case_detail_sample.csv")

files <- list.files(raw_dir, pattern = "\\.(csv|zip)$", ignore.case = TRUE, full.names = TRUE)
if (length(files) == 0) stop("No .csv or .zip files in ", raw_dir, ". Run fetch_data.R first.")

set.seed(312)
samples <- lapply(files, function(path) {
  df <- read_csv(path, col_types = cols(.default = col_character()), progress = FALSE)
  names(df) <- tolower(trimws(names(df)))
  df$source_file <- basename(path)
  out <- slice_sample(df, n = min(n_per_file, nrow(df)))
  message(sprintf("%s: %s cases, sampled %s", basename(path),
                  format(nrow(df), big.mark = ","), format(nrow(out), big.mark = ",")))
  out
})

result <- bind_rows(samples)
dir.create(dirname(sample_path), recursive = TRUE, showWarnings = FALSE)
write_csv(result, sample_path, na = "")
message(sprintf("wrote %s rows to %s (%.1f MB)", format(nrow(result), big.mark = ","),
                sample_path, file.size(sample_path) / 1e6))

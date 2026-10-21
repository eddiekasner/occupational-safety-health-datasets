# Build tidy tables from the Eurostat tables of the Labour Force Survey ad hoc modules on accidents
# at work and work-related health problems.
#
# Usage (from a terminal):   Rscript scripts/build_dataset.R
# Usage (from RStudio):      open this file and click "Source"
#
# Reads the JSON-stat files downloaded by scripts/fetch_data.R and writes, to data/tidy/:
#   tables.csv               one row per Eurostat table: what it measures and how it is broken down
#   accidents.csv.gz         percentage of people reporting an accident at work in the past 12
#                            months (tables hsw_ac*)
#   health_problems.csv.gz   percentage of people reporting a work-related health problem in the
#                            past 12 months (tables hsw_pb*)
#   exposures.csv.gz         percentage of employed people reporting exposure to risk factors for
#                            physical health or mental well-being (tables hsw_exp*)
# Each row is one value: a table, year, country, sex, age group and category of the table's
# breakdown, with Eurostat's flags.

library(dplyr)
library(readr)
library(purrr)

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) {
  dirname(normalizePath(sub("^--file=", "", file_arg)))
} else if (!is.null(sys.frame(1)$ofile)) {
  dirname(normalizePath(sys.frame(1)$ofile))
} else {
  getwd()
}
raw_dir <- file.path(script_dir, "..", "data", "raw")
tidy_dir <- file.path(script_dir, "..", "data", "tidy")
dir.create(tidy_dir, showWarnings = FALSE)

# Read a Eurostat JSON-stat file into a long data frame. Eurostat stores values and flags sparsely,
# keyed by their position in the full grid of dimensions (the last dimension varying fastest).
read_jsonstat <- function(path) {
  js <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  dims <- unlist(js$id)
  sizes <- unlist(js$size)
  codes <- lapply(dims, function(d) {
    index <- unlist(js$dimension[[d]]$category$index)
    names(sort(index))
  })
  names(codes) <- dims
  pos <- as.integer(names(js$value))
  out <- list()
  rest <- pos
  for (k in rev(seq_along(dims))) {
    out[[dims[k]]] <- codes[[k]][rest %% sizes[k] + 1]
    rest <- rest %/% sizes[k]
  }
  out <- as_tibble(out[dims])
  for (d in dims) {
    lab <- unlist(js$dimension[[d]]$category$label)
    out[[paste0(d, "_label")]] <- unname(lab[out[[d]]])
  }
  status <- unlist(js$status)
  out$value <- vapply(js$value, function(x) if (is.null(x)) NA_real_ else as.numeric(x), 0)
  out$flag <- unname(status[as.character(pos)])
  out$flag[is.na(out$flag)] <- ""
  out$title <- js$label
  out
}

# What each table measures. Unit codes are explained in the data dictionary.
measure_of <- function(table) {
  case_when(
    table == "hsw_ac4" ~ "Road traffic accident at work",
    table %in% c("hsw_ac2", "hsw_ac3", "hsw_ac6a", "hsw_ac6b", "hsw_ac13") ~
      "Accident at work with time off work",
    grepl("^hsw_ac", table) ~ "Accident at work",
    table %in% c("hsw_pb2", "hsw_pb3", "hsw_pb12") ~
      "Work-related health problem with time off work",
    table == "hsw_pb4" ~ "Work-related health problem limiting daily activities",
    grepl("^hsw_pb", table) ~ "Work-related health problem",
    table %in% c("hsw_exp1", "hsw_exp3", "hsw_exp5a", "hsw_exp5b", "hsw_exp9") ~
      "Exposure to risk factors for mental well-being",
    TRUE ~ "Exposure to risk factors for physical health")
}
breakdowns <- c(isced11 = "Education", duration = "Time off work", nace_r1 = "Activity (NACE Rev. 1.1)",
                nace_r2 = "Activity (NACE Rev. 2)", isco08 = "Occupation",
                wstatus = "Professional status", sizes = "Size of local unit",
                worktime = "Full-time or part-time",
                c_birth = "Country of birth", lev_limit = "Limitation of daily activities",
                hlth_pb = "Type of health problem", factor = "Risk factor")
standard <- c("freq", "sex", "age", "unit", "geo", "time")

files <- list.files(raw_dir, "^hsw_.*\\.json$", full.names = TRUE)
all <- map_dfr(files, function(f) {
  table <- sub("\\.json$", "", basename(f))
  x <- read_jsonstat(f)
  extra <- setdiff(grep("_label$", names(x), invert = TRUE, value = TRUE),
                   c(standard, "value", "flag", "title"))
  if (length(extra) > 1) stop(table, " has more than one breakdown")
  # A few tables are for both sexes only
  if (!"sex" %in% names(x)) x$sex <- "T"
  breakdown <- if (table == "hsw_ac11") "Atypical working time"
    else if (table %in% c("hsw_ac14", "hsw_pb13")) "Working from home"
    else if (length(extra)) breakdowns[[extra]]
    else "None"
  x |>
    transmute(table, title, measure = measure_of(table), year = as.integer(time), geo,
              country = geo_label, sex = recode(sex, T = "Total", M = "Male", F = "Female"),
              age = sub("^Y", "", age),
              breakdown = breakdown,
              category_code = if (length(extra)) .data[[extra]] else "TOTAL",
              category = if (length(extra)) .data[[paste0(extra, "_label")]] else "Total",
              unit, value, flag)
})
if (any(is.na(all$breakdown))) stop("A breakdown has no name")

# One row per table, to help find the right one
tables <- all |>
  group_by(table, title, measure, breakdown) |>
  summarise(years = paste(sort(unique(year)), collapse = ", "),
            units = paste(sort(unique(unit)), collapse = ", "),
            values = n(), .groups = "drop") |>
  arrange(factor(substr(table, 5, 6), c("ac", "pb", "ex")),
          as.integer(gsub("\\D", "", table)), table)
write_csv(tables, file.path(tidy_dir, "tables.csv"))

topics <- c(accidents = "^hsw_ac", health_problems = "^hsw_pb", exposures = "^hsw_exp")
for (name in names(topics)) {
  out <- all |>
    filter(grepl(topics[[name]], table)) |>
    select(-title) |>
    arrange(table, year, geo, sex, age, category_code, unit)
  write_csv(out, file.path(tidy_dir, paste0(name, ".csv.gz")), na = "")
  message(sprintf("%-22s %7d rows", name, nrow(out)))
}

# ---- Checks ------------------------------------------------------------------------------------
# The same headline figure appears in several tables (for example, the share of people with an
# accident at work, for all education levels, all activities and all occupations): they must agree
totals <- all |>
  filter(measure == "Accident at work", sex == "Total", age == "15-64",
         unit == "PC_EMP_PREEMP_M12",
         category_code %in% c("TOTAL", "EMP"), !is.na(value)) |>
  group_by(year, geo) |>
  summarise(tables = n(), spread = max(value) - min(value), .groups = "drop")
message("Headline accident rate, largest difference between tables: ",
        round(max(totals$spread), 2), " percentage points")
if (max(totals$spread) > 0.5) warning("Tables disagree on the headline accident rate")

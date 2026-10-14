# Build tidy tables from the HSE RIDDOR and Labour Force Survey (LFS) injury tables.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads data/raw/ (from fetch_data.R) and writes to data/tidy/:
#
# RIDDOR (injuries reported by employers; one row per estimate):
#   riddor_history.csv        fatal and non-fatal injuries since 1974 by broad industry
#   riddor_industry.csv.gz    by detailed industry (SIC 2007), 2014/15 onward
#   riddor_kind.csv.gz        by kind of accident and broad industry, 2014/15 onward
#   riddor_age_gender.csv.gz  by age group, gender and broad industry, 2014/15 onward
#   riddor_nature_site.csv    by nature of injury and site of injury (body part), 2014/15 onward
#   riddor_region.csv.gz      by country, region and local authority, 2014/15 onward
#   riddor_fatal_latest.csv   fatal injuries 2021/22 to 2025/26 (one year more than the others)
# LFS (injuries reported by workers in a household survey):
#   lfs_injury.csv.gz         estimates with 95% confidence intervals, all breakdowns
#
# The HSE tables mark values that are not available with codes in square brackets, for
# example [x] or [U1]. These are stored as NA in `value` with the code in `flag`.

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
})

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
raw_dir <- file.path(module_dir, "data", "raw")
tidy_dir <- file.path(module_dir, "data", "tidy")
dir.create(tidy_dir, recursive = TRUE, showWarnings = FALSE)

# --- Helpers ----------------------------------------------------------------------------------

# Remove note references such as "[Note 11.0], [Note 11.1]"
clean_text <- function(x) str_remove(str_squish(str_remove_all(x, "\\[Note [^]]*\\],?")), "[ ,]+$")

# Read one table sheet. The header is the first row with at least 3 filled cells (the rows
# above it are a title and instructions). Note references are removed from column names.
read_hse <- function(file, sheet) {
  path <- file.path(raw_dir, file)
  if (!file.exists(path)) stop("Missing ", path, ". Run fetch_data.R first.")
  d <- read_excel(path, sheet = sheet, col_names = FALSE, col_types = "text", .name_repair = "minimal")
  filled <- rowSums(!is.na(d))
  header <- which(filled >= min(3, ncol(d)))[1]
  body <- d[(header + 1):nrow(d), ]
  names(body) <- clean_text(unlist(d[header, ]))
  body <- body[rowSums(!is.na(body)) > 0, ]
  attr(body, "title") <- clean_text(d[[1]][1])
  body
}

# Values: numbers, or a shorthand code such as [x], [u], [k], [U1]
parse_values <- function(d) {
  d |>
    mutate(raw = str_trim(raw),
           flag = str_match(raw, "^\\[([A-Za-z0-9]+)\\]$")[, 2],
           value = suppressWarnings(as.numeric(raw))) |>
    select(-raw)
}

# Periods: "1974", "2014/15", "2024/25p", "2021/22 - 2025/26p". Years run April to March;
# `year` is the year the period ends (2024/25 -> 2025)
parse_period <- function(d, col = "period") {
  p <- clean_text(d[[col]])
  status <- case_when(str_detect(p, "p$") ~ "provisional", str_detect(p, "r$") ~ "revised",
                      TRUE ~ "final")
  p <- str_remove(p, "[pr]$")
  last <- str_extract(p, "\\d{4}(/\\d{2})?$")
  year <- as.integer(str_sub(last, 1, 4)) + if_else(str_detect(last, "/"), 1L, 0L)
  d[[col]] <- p
  d$year <- year
  d$status <- status
  d
}

# Turn a RIDDOR measure column name into who, what kind of injury, and what is measured
parse_measure <- function(h) {
  tibble(
    measure_name = h,
    worker_group = case_when(
      str_detect(h, "members of the public") ~ "Members of the public",
      str_detect(h, "self-employed") ~ "Self-employed",
      str_detect(h, "employees") ~ "Employees",
      str_detect(h, "workers") ~ "Workers",
      TRUE ~ NA_character_),
    injury_type = case_when(
      str_detect(h, "non-fatal") ~ "All non-fatal",
      str_detect(h, "fatal injur") ~ "Fatal",
      str_detect(h, "specified") ~ "Specified",
      str_detect(h, "over[- ]7-day") ~ "Over-7-day",
      str_detect(h, "over-3-day") ~ "Over-3-day",
      TRUE ~ NA_character_),
    measure = case_when(
      str_starts(h, "Rate") ~ "rate_per_100000",
      str_starts(h, "%") ~ "share",
      TRUE ~ "count")
  )
}

# Pivot the measure columns (Number..., Total..., Rate..., %...) into long format
pivot_measures <- function(d, default_group = NA_character_) {
  measure_cols <- names(d)[str_detect(names(d), "^(Number|Total|Rate|%)")]
  d |>
    pivot_longer(all_of(measure_cols), names_to = "measure_name", values_to = "raw") |>
    left_join(parse_measure(measure_cols), by = "measure_name") |>
    mutate(worker_group = coalesce(worker_group, default_group)) |>
    select(-measure_name) |>
    parse_values()
}

# Remove note references from label columns and make labels consistent between years
clean_labels <- function(d) {
  d |>
    mutate(across(any_of(c("industry", "main_industry", "category", "accident_kind", "area",
                           "age_group", "gender", "sic_code")), clean_text),
           across(any_of("industry"), \(x) str_replace(x, "Mining and Quarrying", "Mining and quarrying")),
           across(any_of("worker_group"), \(x) recode(x, "Employee" = "Employees")))
}

stop_if_na <- function(d, cols) {
  for (col in cols) if (anyNA(d[[col]])) stop("NA in column ", col)
  invisible(d)
}

check <- function(d, ..., expected) {
  got <- filter(d, ...)$value
  if (length(got) != 1 || abs(got - expected) > 1e-6) {
    stop("Check failed: expected ", expected, ", got ", paste(got, collapse = ", "))
  }
}

# --- RIDDOR: history since 1974 (ridhist) ----------------------------------------------------

hist_cols <- c(period = "Year", regulations = "Regulations injuries reported under",
               industry_classification = "Industry classification",
               rate_denominator_source = "Source of employment data for rates")

hist_fatal <- read_hse("ridhist.xlsx", "Table 1") |>
  rename(any_of(c(hist_cols, industry = "Industry"))) |>
  pivot_measures()

hist_public <- read_hse("ridhist.xlsx", "Table 2") |>
  rename(any_of(hist_cols)) |>
  rename(`All industries` = starts_with("Number of fatal injuries to members of the public")) |>
  pivot_longer(-c(period, regulations, industry_classification), names_to = "industry",
               values_to = "raw") |>
  mutate(worker_group = "Members of the public", injury_type = "Fatal", measure = "count") |>
  parse_values()

hist_nonfatal <- read_hse("ridhist.xlsx", "Table 3") |>
  rename(any_of(c(hist_cols, industry = "Industry", worker_group = "Employment status"))) |>
  # This table's worker group comes from its Employment status column
  rename(group_from_status = worker_group) |>
  pivot_measures() |>
  mutate(worker_group = group_from_status) |>
  select(-group_from_status)

riddor_history <- bind_rows(hist_fatal, hist_public, hist_nonfatal) |>
  # Codes (a) to (o) are explained on the Background information sheet; see data dictionary
  mutate(across(c(regulations, industry_classification, rate_denominator_source),
                \(x) str_remove_all(x, "[() ]"))) |>
  clean_labels() |>
  parse_period() |>
  filter(!(flag %in% "x" & is.na(value))) |>
  select(period, year, status, industry, worker_group, injury_type, measure, value, flag,
         regulations, industry_classification, rate_denominator_source)

stop_if_na(riddor_history, c("period", "year", "industry", "worker_group", "injury_type"))

# --- RIDDOR: detailed industry (ridind) -------------------------------------------------------

ind_cols <- c(period = "Year", sic_level = "Industry Level (SIC)", sic_code = "SIC 2007 code",
              industry = "Industry")

ind_public <- read_hse("ridind.xlsx", "Table 2") |>
  rename(any_of(ind_cols)) |>
  pivot_longer(-c(sic_level, sic_code, industry), names_to = "period", values_to = "raw") |>
  mutate(worker_group = "Members of the public", injury_type = "Fatal", measure = "count") |>
  parse_values()

riddor_industry <- bind_rows(
  read_hse("ridind.xlsx", "Table 1") |> rename(any_of(ind_cols)) |> pivot_measures(),
  ind_public,
  read_hse("ridind.xlsx", "Table 3") |> rename(any_of(ind_cols)) |> pivot_measures("Employees")
) |>
  parse_period() |>
  clean_labels() |>
  select(period, year, status, sic_level, sic_code, industry, worker_group, injury_type,
         measure, value, flag)

stop_if_na(riddor_industry, c("year", "sic_level", "industry", "worker_group", "injury_type"))

# --- RIDDOR: kind of accident (ridkind), age and gender (ridagegen) ---------------------------

broad_cols <- c(period = "Year", sic_section = "Industry Section (SIC)",
                sic_section = "Industry Section (SIC 2007)", main_industry = "Main Industry",
                accident_kind = "Accident Kind", gender = "Gender", age_group = "Age group")

# In these files the two industry columns are sometimes swapped: make sure the codes
# (for example A-U) end up in sic_section
fix_sections <- function(d) {
  swap <- str_detect(d$main_industry, "^[A-Z](-[A-Z])?$")
  d |> mutate(tmp = if_else(swap, main_industry, sic_section),
              main_industry = if_else(swap, sic_section, main_industry),
              sic_section = tmp) |>
    select(-tmp)
}

riddor_kind <- bind_rows(
  read_hse("ridkind.xlsx", "Table 1") |> rename(any_of(broad_cols)) |> pivot_measures(),
  read_hse("ridkind.xlsx", "Table 2") |> rename(any_of(broad_cols)) |> pivot_measures("Employees")
) |>
  fix_sections() |>
  parse_period() |>
  clean_labels() |>
  select(period, year, status, sic_section, main_industry, accident_kind, worker_group,
         injury_type, measure, value, flag)

riddor_age_gender <- bind_rows(
  read_hse("ridagegen.xlsx", "Table 1") |> rename(any_of(broad_cols)) |> pivot_measures(),
  read_hse("ridagegen.xlsx", "Table 2") |> rename(any_of(broad_cols)) |> pivot_measures("Employees")
) |>
  fix_sections() |>
  mutate(age_group = clean_text(age_group)) |>
  parse_period() |>
  clean_labels() |>
  select(period, year, status, sic_section, main_industry, gender, age_group, worker_group,
         injury_type, measure, value, flag)

stop_if_na(riddor_kind, c("year", "sic_section", "accident_kind", "injury_type"))
stop_if_na(riddor_age_gender, c("year", "sic_section", "gender", "age_group", "injury_type"))

# --- RIDDOR: nature and site of injury (ridnat, ridsite) --------------------------------------

site_levels <- function(d) {
  # Site of injury rows: "All injuries", then a body region ("All injuries to head locations",
  # or "General locations") followed by its body parts
  d |>
    mutate(level = case_when(category == "All injuries" ~ 0L,
                             str_starts(category, "All injuries to") | category == "General locations" ~ 1L,
                             TRUE ~ 2L),
           body_region = if_else(level == 1L, category, NA_character_)) |>
    group_by(period, measure, worker_group, injury_type) |>
    fill(body_region) |>
    ungroup()
}

nature <- bind_rows(
  read_hse("ridnat.xlsx", "Table 1") |> pivot_measures(),
  read_hse("ridnat.xlsx", "Table 2") |> pivot_measures("Employees")
) |>
  rename(period = Year, category = `Nature of injury`) |>
  mutate(breakdown = "nature of injury", level = if_else(category == "All injuries", 0L, 1L))

site <- bind_rows(
  read_hse("ridsite.xlsx", "Table 1") |> pivot_measures(),
  read_hse("ridsite.xlsx", "Table 2") |> pivot_measures("Employees")
) |>
  rename(period = Year, category = `Site of injury (on body)`) |>
  mutate(breakdown = "site of injury") |>
  site_levels()

riddor_nature_site <- bind_rows(nature, site) |>
  mutate(category = clean_text(category)) |>
  parse_period() |>
  clean_labels() |>
  select(period, year, status, breakdown, body_region, category, level, worker_group,
         injury_type, measure, value, flag)

stop_if_na(riddor_nature_site, c("year", "category", "worker_group", "injury_type"))

# --- RIDDOR: regions and local authorities (ridreg) -------------------------------------------

reg_cols <- c(period = "Year", area_code = "Area code", area = "Area", area_type = "Area Type")
riddor_region <- bind_rows(
  read_hse("ridreg.xlsx", "Table 1") |> rename(any_of(reg_cols)) |> pivot_measures(),
  read_hse("ridreg.xlsx", "Table 2") |> rename(any_of(reg_cols)) |> pivot_measures("Employees")
) |>
  mutate(area = clean_text(area)) |>
  parse_period() |>
  clean_labels() |>
  select(period, year, status, area_type, area_code, area, worker_group, injury_type,
         measure, value, flag)

stop_if_na(riddor_region, c("year", "area", "injury_type"))

# --- RIDDOR: latest fatal injuries (ridfatal) -------------------------------------------------

fatal_cols <- c(period = "Year", category = "Main Industry SIC 2007 (Section/Division)",
                category = "Accident kind", category = "Age group", category = "Area",
                area_code = "Area code", area_type = "Area Type")

fatal_public <- read_hse("ridfatal.xlsx", "Table 2") |>
  rename(category = 1) |>
  pivot_longer(-category, names_to = "period", values_to = "raw") |>
  mutate(worker_group = "Members of the public", injury_type = "Fatal", measure = "count",
         breakdown = "industry") |>
  parse_values()

riddor_fatal_latest <- bind_rows(
  read_hse("ridfatal.xlsx", "Table 1") |> rename(any_of(fatal_cols)) |> pivot_measures() |>
    mutate(breakdown = "industry"),
  fatal_public,
  read_hse("ridfatal.xlsx", "Table 3") |> rename(any_of(fatal_cols)) |> pivot_measures() |>
    mutate(breakdown = "kind of accident"),
  read_hse("ridfatal.xlsx", "Table 4") |> rename(any_of(fatal_cols)) |> pivot_measures() |>
    mutate(breakdown = "age group"),
  read_hse("ridfatal.xlsx", "Table 5") |> rename(any_of(fatal_cols)) |> pivot_measures() |>
    mutate(breakdown = "country and region")
) |>
  mutate(category = clean_text(category),
         period_length = if_else(str_detect(period, " - "), "5-year total", "1 year")) |>
  parse_period() |>
  clean_labels() |>
  select(period, period_length, year, status, breakdown, category, area_code, area_type,
         worker_group, injury_type, measure, value, flag)

stop_if_na(riddor_fatal_latest, c("year", "category", "worker_group"))

# --- LFS: self-reported injuries ---------------------------------------------------------------

lfs_measures <- c("Incidence" = "injuries_thousands",
                  "Incidence rate per 100,000" = "rate_per_100000_workers",
                  "Days lost" = "days_lost_thousands",
                  "Days lost per worker" = "days_lost_per_worker",
                  "Days lost per case" = "days_lost_per_case")

lfs_breakdown <- c(lfsinjsum = "all", lfsinjind = "industry", lfsinjocc = "occupation",
                   lfsinjknd = "kind of accident", lfsinjnat = "nature of injury",
                   lfsinjage = "age and gender", lfsinjreg = "country and region",
                   lfsinjsiz = "workplace size")

read_lfs <- function(file, sheet) {
  d <- read_hse(file, sheet)
  title <- attr(d, "title")
  names(d) <- str_remove(names(d), " \\(000s\\)")
  id <- names(d)[seq_len(which(str_detect(names(d), ":"))[1] - 1)]
  code_col <- intersect(id, c("SIC code", "SOC code", "Area code"))
  # The category is the last descriptive column (for example "Industry" or "Kind of accident")
  category_col <- setdiff(id, c("Sort key", "Period", "Year(s)", "Level", code_col,
                                "Industry SIC section filter", "Occupation SOC major filter"))
  stopifnot(length(category_col) == 1)
  d |>
    transmute(
      source = paste0(str_remove(file, "\\.xlsx$"), " ", sheet),
      breakdown = lfs_breakdown[[str_remove(file, "\\.xlsx$")]],
      injury_type = case_when(str_detect(title, "over three days") ~ "Over-3-day absence",
                              str_detect(title, "over seven days") ~ "Over-7-day absence",
                              TRUE ~ "All workplace injuries"),
      period_length = Period,
      period = clean_text(`Year(s)`),
      level = Level,
      code = if (length(code_col)) .data[[code_col]] else NA_character_,
      category = clean_text(.data[[category_col]]),
      across(contains(": ")),
      sig_vs_all = if ("Statistical significance vs All" %in% names(d)) `Statistical significance vs All` else NA_character_,
      sig_vs_previous = if ("Statistical significance vs Previous year" %in% names(d)) `Statistical significance vs Previous year` else NA_character_,
      low_sample = !is.na(`Sample size flag`)
    ) |>
    pivot_longer(contains(": "), names_to = c("measure", "stat"), names_sep = ": ",
                 values_to = "raw") |>
    mutate(measure = unname(lfs_measures[measure]),
           stat = recode(stat, "Estimate" = "estimate", "95% CI Lower" = "ci_lower",
                         "95% CI Upper" = "ci_upper")) |>
    parse_values() |>
    pivot_wider(names_from = stat, values_from = c(value, flag)) |>
    rename(estimate = value_estimate, ci_lower = value_ci_lower, ci_upper = value_ci_upper,
           flag = flag_estimate) |>
    select(-flag_ci_lower, -flag_ci_upper)
}

lfs_files <- paste0(names(lfs_breakdown), ".xlsx")
lfs_injury <- bind_rows(lapply(lfs_files, \(f) {
  sheets <- grep("^Table-", excel_sheets(file.path(raw_dir, f)), value = TRUE)
  bind_rows(lapply(sheets, \(s) read_lfs(f, s)))
})) |>
  mutate(across(c(sig_vs_all, sig_vs_previous), \(x) na_if(str_remove_all(x, "\\[|\\]"), "Z"))) |>
  parse_period() |>
  # LFS estimates are not provisional; the latest year is final when published
  select(-status) |>
  # Most detailed industries and occupations have too few survey respondents for an estimate
  # ([U1]); drop those empty rows to keep the file small
  filter(!(level %in% c("Group", "Class", "Minor", "Unit") & is.na(estimate) & flag %in% "U1")) |>
  select(source, breakdown, injury_type, period_length, period, year, level, code, category,
         measure, estimate, ci_lower, ci_upper, flag, sig_vs_all, sig_vs_previous, low_sample)

stop_if_na(lfs_injury, c("breakdown", "period", "year", "measure", "category"))

# --- Checks against published figures ---------------------------------------------------------

check(riddor_history, period == "1974", industry == "All industries", worker_group == "Employees",
      injury_type == "Fatal", measure == "count", expected = 651)
check(riddor_industry, period == "2014/15", sic_code == "All (01-99)", worker_group == "Employees",
      injury_type == "All non-fatal", measure == "count", expected = 75919)
check(riddor_kind, period == "2014/15", sic_section == "A-U", accident_kind == "All accident kinds",
      worker_group == "Workers", measure == "count", expected = 142)
check(riddor_fatal_latest, period == "2021/22", breakdown == "industry",
      category == "All industries (SIC A-U)", worker_group == "Workers", measure == "count",
      expected = 123)
stopifnot(filter(lfs_injury, source == "lfsinjsum Table-1", period == "2024/25",
                 measure == "injuries_thousands")$estimate == 680)

# --- Write --------------------------------------------------------------------------------------

out <- list(riddor_history.csv = riddor_history, riddor_industry.csv.gz = riddor_industry,
            riddor_kind.csv.gz = riddor_kind, riddor_age_gender.csv.gz = riddor_age_gender,
            riddor_nature_site.csv = riddor_nature_site, riddor_region.csv.gz = riddor_region,
            riddor_fatal_latest.csv = riddor_fatal_latest, lfs_injury.csv.gz = lfs_injury)
for (name in names(out)) {
  write_csv(out[[name]], file.path(tidy_dir, name), na = "")
  message(name, ": ", nrow(out[[name]]), " rows")
}

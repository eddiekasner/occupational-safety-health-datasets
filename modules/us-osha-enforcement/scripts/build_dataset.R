# Build tidy OSHA enforcement tables from the DOL API downloads.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads data/raw/ (from fetch_data.R) and writes:
#   data/tidy/inspection_summary.csv.gz  inspections, violations and penalties by fiscal year,
#                                        state, federal or state plan, inspection type and scope,
#                                        safety or health, ownership and industry sector (complete)
#   data/tidy/standards_by_industry.csv.gz violations and penalties by fiscal year, federal or
#                                        state plan, 6-digit NAICS industry and standard cited
#                                        (complete; the same counts as OSHA's "frequently cited
#                                        standards" search)
#   data/tidy/standard_titles.csv        the title of each section of the OSHA standards (29 CFR
#                                        Parts 1903, 1904, 1910, 1915, 1917, 1918, 1926, 1928, 1960)
#   data/tidy/violation_standards.csv.gz violations and penalties by fiscal year, federal or state
#                                        plan, standard cited and violation type (complete)
#   data/tidy/accidents.csv.gz           accident investigations (fatalities and catastrophes) with
#                                        events in fiscal years 2015-2025, with narratives
#   data/tidy/accident_injuries.csv.gz   the workers injured or killed in those investigations
#   data/sample/inspections_sample.csv.gz  a 5% random sample of inspections, one row each
#   data/sample/violations_sample.csv.gz   all violations for the sampled inspections
#
# Scope: inspections opened in federal fiscal years 2015 to 2025 (1 October 2014 to 30 September
# 2025) and their violations. Deleted violations are dropped.

suppressPackageStartupMessages({
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
sample_dir <- file.path(module_dir, "data", "sample")
dir.create(tidy_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(sample_dir, recursive = TRUE, showWarnings = FALSE)

read_table <- function(table) {
  files <- list.files(file.path(raw_dir, table), pattern = "\\.csv$", full.names = TRUE)
  files <- files[file.size(files) > 0]  # empty files: date ranges with no records
  if (!length(files)) stop("No files for ", table, " in ", raw_dir, ". Run fetch_data.R first.")
  bind_rows(lapply(files, \(f) read_csv(f, col_types = cols(.default = col_character()),
                                         progress = FALSE)))
}

fiscal_year <- function(date) as.integer(format(date, "%Y")) + (as.integer(format(date, "%m")) >= 10)

# --- Codes ------------------------------------------------------------------------------------

insp_types <- c(A = "Accident", B = "Complaint", C = "Referral", D = "Monitoring", E = "Variance",
                F = "Follow-up", G = "Unprogrammed related", H = "Planned", I = "Programmed related",
                J = "Unprogrammed other", K = "Programmed other", L = "Other", M = "Fatality/catastrophe",
                N = "Unprogrammed emphasis")
owner_types <- c(A = "Private", B = "Local government", C = "State government", D = "Federal")
viol_types <- c(S = "Serious", W = "Willful", R = "Repeat", O = "Other-than-serious",
                U = "Unclassified")
naics_sectors <- c(
  "11" = "Agriculture, forestry, fishing and hunting", "21" = "Mining, oil and gas extraction",
  "22" = "Utilities", "23" = "Construction", "31" = "Manufacturing", "32" = "Manufacturing",
  "33" = "Manufacturing", "42" = "Wholesale trade", "44" = "Retail trade", "45" = "Retail trade",
  "48" = "Transportation and warehousing", "49" = "Transportation and warehousing",
  "51" = "Information", "52" = "Finance and insurance", "53" = "Real estate and rental and leasing",
  "54" = "Professional, scientific and technical services",
  "55" = "Management of companies and enterprises",
  "56" = "Administrative, support and waste management services", "61" = "Educational services",
  "62" = "Health care and social assistance", "71" = "Arts, entertainment and recreation",
  "72" = "Accommodation and food services", "81" = "Other services",
  "92" = "Public administration")

# --- Inspections ------------------------------------------------------------------------------

inspections <- read_table("inspection") |>
  distinct(activity_nr, .keep_all = TRUE) |>
  transmute(
    activity_nr, reporting_id,
    open_date = as.Date(str_sub(open_date, 1, 10)),
    close_case_date = as.Date(str_sub(close_case_date, 1, 10)),
    fiscal_year = fiscal_year(open_date),
    # The third digit of the reporting ID is 5 for state-plan OSHA offices
    jurisdiction = if_else(str_sub(reporting_id, 3, 3) == "5", "State plan", "Federal"),
    estab_name, site_city, site_state, site_zip,
    owner_type = unname(owner_types[owner_type]),
    safety_health = recode(safety_hlth, S = "Safety", H = "Health"),
    insp_type = unname(insp_types[insp_type]),
    insp_scope = recode(insp_scope, A = "Complete", B = "Partial", C = "Records", D = "No inspection"),
    union = if_else(union_status %in% c("Y", "U", "A"), "Union", "No union"),
    adv_notice = adv_notice == "Y",
    employees = as.numeric(nr_in_estab),
    naics_code, sic_code,
    naics_sector = unname(naics_sectors[str_sub(naics_code, 1, 2)])
  ) |>
  filter(fiscal_year >= 2015, fiscal_year <= 2025)

# --- Violations -------------------------------------------------------------------------------

# Standards are written as part (4 digits) + section (4 digits) + paragraph, for example
# "19260501 B13" = 29 CFR 1926.501(b)(13). State-plan standards and the General Duty Clause
# ("5A0001") use other formats and are kept as written.
standard_section <- function(x) {
  m <- str_match(x, "^(19[0-9]{2})([0-9]{4})")
  if_else(!is.na(m[, 1]), paste0(m[, 2], ".", as.integer(m[, 3])),
          if_else(str_detect(x, "^5A0001"), "General Duty Clause", str_trim(x)))
}

violations_raw <- read_table("violation")
violations <- violations_raw |>
  filter(is.na(delete_flag) | delete_flag != "X") |>
  distinct(activity_nr, citation_id, .keep_all = TRUE) |>
  semi_join(inspections, by = "activity_nr") |>
  transmute(
    activity_nr, citation_id, standard,
    section = standard_section(standard),
    viol_type = unname(viol_types[viol_type]),
    issuance_date = as.Date(str_sub(issuance_date, 1, 10)),
    initial_penalty = as.numeric(initial_penalty),
    current_penalty = as.numeric(current_penalty),
    gravity = as.integer(gravity),
    nr_exposed = as.integer(nr_exposed),
    nr_instances = as.integer(nr_instances),
    hazard_category = hazcat,
    contested = !is.na(contest_date),
    final_order_date = as.Date(str_sub(final_order_date, 1, 10))
  )

# Per-inspection totals
per_inspection <- violations |>
  group_by(activity_nr) |>
  summarise(violations = n(),
            serious = sum(viol_type == "Serious", na.rm = TRUE),
            willful = sum(viol_type == "Willful", na.rm = TRUE),
            repeat_ = sum(viol_type == "Repeat", na.rm = TRUE),
            initial_penalty = sum(initial_penalty, na.rm = TRUE),
            current_penalty = sum(current_penalty, na.rm = TRUE), .groups = "drop") |>
  rename(`repeat` = repeat_)

inspections <- inspections |>
  left_join(per_inspection, by = "activity_nr") |>
  mutate(across(c(violations, serious, willful, `repeat`, initial_penalty, current_penalty),
                \(x) coalesce(x, 0)))

# --- Summary tables ---------------------------------------------------------------------------

inspection_summary <- inspections |>
  group_by(fiscal_year, site_state, jurisdiction, insp_type, insp_scope, safety_health,
           owner_type, naics_sector) |>
  summarise(inspections = n(),
            with_violations = sum(violations > 0),
            violations = sum(violations), serious = sum(serious), willful = sum(willful),
            `repeat` = sum(`repeat`),
            initial_penalty = sum(initial_penalty), current_penalty = sum(current_penalty),
            .groups = "drop")

violation_standards <- violations |>
  left_join(select(inspections, activity_nr, fiscal_year, jurisdiction), by = "activity_nr") |>
  group_by(fiscal_year, jurisdiction, section, viol_type) |>
  summarise(violations = n(), inspections = n_distinct(activity_nr),
            initial_penalty = sum(initial_penalty, na.rm = TRUE),
            current_penalty = sum(current_penalty, na.rm = TRUE), .groups = "drop")

standards_by_industry <- violations |>
  left_join(select(inspections, activity_nr, fiscal_year, jurisdiction, naics_code), by = "activity_nr") |>
  group_by(fiscal_year, jurisdiction, naics_code, section) |>
  summarise(violations = n(), inspections = n_distinct(activity_nr),
            serious = sum(viol_type == "Serious", na.rm = TRUE),
            willful_repeat = sum(viol_type %in% c("Willful", "Repeat")),
            initial_penalty = sum(initial_penalty, na.rm = TRUE),
            current_penalty = sum(current_penalty, na.rm = TRUE), .groups = "drop")

# Titles of the standards, from the eCFR's outline of Title 29 (part > subpart > section)
ecfr <- jsonlite::fromJSON(file.path(raw_dir, "ecfr_title29.json"), simplifyVector = FALSE)
osha_parts <- c("1903", "1904", "1910", "1915", "1917", "1918", "1926", "1928", "1960")
title_rows <- list()
walk_ecfr <- function(node, part = NA, part_title = NA, subpart = NA) {
  label <- if (is.null(node$label_description)) NA else node$label_description
  if (identical(node$type, "part")) { part <- node$identifier; part_title <- label }
  if (identical(node$type, "subpart")) subpart <- paste0("Subpart ", node$identifier, ": ", label)
  if (identical(node$type, "section") && part %in% osha_parts && !isTRUE(node$reserved)) {
    title_rows[[length(title_rows) + 1]] <<- tibble(
      section = node$identifier, title = str_remove(label, "\\.$"), part = part,
      part_title = part_title, subpart = subpart)
  }
  for (child in node$children) walk_ecfr(child, part, part_title, subpart)
}
walk_ecfr(ecfr)
standard_titles <- bind_rows(title_rows) |>
  distinct(section, .keep_all = TRUE) |>
  bind_rows(tibble(section = "General Duty Clause", part = "OSH Act",
                   title = "General duty to keep the workplace free from recognized serious hazards",
                   part_title = "Occupational Safety and Health Act of 1970, section 5(a)(1)")) |>
  # Many titles ("General requirements") only make sense with their subpart
  mutate(full_title = if_else(is.na(subpart), title,
                              paste0(str_remove(subpart, "^Subpart [A-Z0-9-]+: "), ": ", title)),
         .after = title)

# --- Accident investigations ------------------------------------------------------------------

lookup <- read_csv(file.path(raw_dir, "accident_lookup2.csv"),
                   col_types = cols(.default = col_character())) |>
  distinct(accident_code, accident_number, .keep_all = TRUE)
decode <- function(x, code_table) {
  l <- filter(lookup, accident_code == code_table)
  l$accident_value[match(x, l$accident_number)]
}

abstracts <- read_table("accident_abstract") |>
  distinct(summary_nr, line_nr, .keep_all = TRUE) |>
  mutate(line_nr = as.integer(line_nr)) |>
  arrange(summary_nr, line_nr) |>
  group_by(summary_nr) |>
  summarise(narrative = str_squish(paste(abstract_text, collapse = " ")), .groups = "drop")

injuries_all <- read_table("accident_injury") |>
  distinct(summary_nr, injury_line_nr, .keep_all = TRUE)

accidents <- read_table("accident") |>
  distinct(summary_nr, .keep_all = TRUE) |>
  mutate(event_date = as.Date(str_sub(event_date, 1, 10)),
         fiscal_year = fiscal_year(event_date)) |>
  filter(fiscal_year >= 2015, fiscal_year <= 2025) |>
  left_join(abstracts, by = "summary_nr") |>
  # Link to the inspection: take the first inspection number listed among the injuries
  left_join(injuries_all |> group_by(summary_nr) |> summarise(activity_nr = first(rel_insp_nr)),
            by = "summary_nr") |>
  left_join(select(inspections, activity_nr, site_state, jurisdiction, naics_code, naics_sector,
                   estab_name), by = "activity_nr") |>
  transmute(summary_nr, activity_nr, event_date, fiscal_year, site_state, jurisdiction,
            estab_name, naics_code, naics_sector, fatality = fatality %in% "X",
            event_desc, event_keyword, narrative)

accident_injuries <- injuries_all |>
  semi_join(accidents, by = "summary_nr") |>
  transmute(summary_nr, activity_nr = rel_insp_nr, injury_line_nr = as.integer(injury_line_nr),
            age = na_if(as.integer(age), 0L),
            sex = na_if(sex, ""),
            degree = decode(degree_of_inj, "DEGR"),
            nature = decode(nature_of_inj, "IN"),
            part_of_body = decode(part_of_body, "BD"),
            source = decode(src_of_injury, "SO"),
            event_type = decode(event_type, "FT"),
            environmental_factor = decode(evn_factor, "EN"),
            human_factor = decode(hum_factor, "HU"),
            occupation = decode(occ_code, "OCC"),
            construction_operation = decode(const_op, "OPER"),
            fatal_cause = decode(fat_cause, "CAUS"))

# --- Sample -----------------------------------------------------------------------------------

set.seed(312)
inspections_sample <- slice_sample(inspections, prop = 0.05) |> arrange(open_date, activity_nr)
violations_sample <- semi_join(violations, inspections_sample, by = "activity_nr")

# --- Checks -----------------------------------------------------------------------------------

stopifnot(!anyDuplicated(inspections$activity_nr),
          !anyDuplicated(select(violations, activity_nr, citation_id)),
          !anyNA(inspections$fiscal_year),
          sum(inspection_summary$inspections) == nrow(inspections),
          sum(violation_standards$violations) == nrow(violations),
          sum(standards_by_industry$violations) == nrow(violations))
# Narratives should have all their lines (1, 2, 3, ... with no gaps)
gaps <- read_table("accident_abstract") |>
  distinct(summary_nr, line_nr) |>
  group_by(summary_nr) |>
  summarise(ok = max(as.integer(line_nr)) == n(), .groups = "drop")
if (mean(gaps$ok) < 0.99) warning(sum(!gaps$ok), " narratives have missing lines")

write_csv(inspection_summary, file.path(tidy_dir, "inspection_summary.csv.gz"), na = "")
write_csv(violation_standards, file.path(tidy_dir, "violation_standards.csv.gz"), na = "")
write_csv(standard_titles, file.path(tidy_dir, "standard_titles.csv"), na = "")
write_csv(standards_by_industry, file.path(tidy_dir, "standards_by_industry.csv.gz"), na = "")
write_csv(accidents, file.path(tidy_dir, "accidents.csv.gz"), na = "")
write_csv(accident_injuries, file.path(tidy_dir, "accident_injuries.csv.gz"), na = "")
write_csv(inspections_sample, file.path(sample_dir, "inspections_sample.csv.gz"), na = "")
write_csv(violations_sample, file.path(sample_dir, "violations_sample.csv.gz"), na = "")

message("inspections: ", nrow(inspections), "; violations: ", nrow(violations),
        "; accidents: ", nrow(accidents), "; injuries: ", nrow(accident_injuries),
        "; sample: ", nrow(inspections_sample), " inspections, ", nrow(violations_sample),
        " violations")

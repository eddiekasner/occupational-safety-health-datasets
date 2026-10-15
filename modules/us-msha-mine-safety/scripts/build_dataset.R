# Build tidy MSHA mine safety tables from the MSHA open data files.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads data/raw/ (from fetch_data.R) and writes, for calendar years 2000 to 2025:
#   data/tidy/injury_summary.csv.gz      hours worked, employees, coal production, injuries and
#                                        illnesses by year, operator or contractor, coal or
#                                        metal/nonmetal and part of the mine (subunit); for mine
#                                        operators also by state and commodity (complete)
#   data/tidy/fatalities.csv.gz          every fatal injury, 2000 to 2025, with narratives
#   data/tidy/accidents.csv.gz           every accident, injury and illness report, 2015 to 2025,
#                                        with narratives
#   data/tidy/mines.csv.gz               every mine, with its location, type, status and commodity
#   data/tidy/mine_year.csv.gz           one row per mine and year: operator hours, injuries,
#                                        violations and penalties
#   data/tidy/violation_summary.csv.gz   violations and penalties by year, coal or metal/nonmetal,
#                                        mine type, operator or contractor, type of action, and
#                                        the inspector's ratings (complete)
#   data/tidy/violation_standards.csv.gz violations and penalties by year, coal or metal/nonmetal
#                                        and standard cited (complete)
#
# The 1.4 GB violations file needs about 4 GB of memory.

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
dir.create(tidy_dir, recursive = TRUE, showWarnings = FALSE)

years <- 2000:2025

# The files are pipe-delimited, with text in quotes. "?" means no value. Text is mostly ASCII,
# but a few values are in UTF-8 and others in Windows-1252, so each value that is not valid UTF-8
# is converted from Windows-1252. Some text fields contain a stray quote mark, which makes a
# standard CSV reader join lines together, so most files are read with quotes treated as ordinary
# characters and the quotes around each value removed afterwards. (No value in these files contains a "|". The contractor
# file has a few names that do, so it is read the standard way.)
read_msha <- function(name, cols = NULL, quoted = FALSE) {
  path <- file.path(raw_dir, paste0(name, ".txt"))
  if (!file.exists(path)) stop("Missing ", path, ". Run fetch_data.R first.")
  # Problems are checked below, so the general warning about them is not needed
  d <- suppressWarnings(
    read_delim(path, delim = "|", col_types = cols(.default = col_character()),
               col_select = if (is.null(cols)) everything() else all_of(cols),
               quote = if (quoted) "\"" else "", na = character(),
               name_repair = str_trim, progress = FALSE))
  # A value containing a null character is cut off there (one standard in the violations file)
  p <- filter(problems(d), actual != "embedded null")
  if (nrow(p)) stop("Could not read ", nrow(p), " lines of ", path)
  d |> mutate(across(everything(), \(x) {
    bad <- !is.na(x) & !validUTF8(x)
    x[bad] <- iconv(x[bad], "windows-1252", "UTF-8", sub = " ")
    x <- str_squish(str_remove_all(x, '^"|"$'))
    if_else(x %in% c("", "?"), NA_character_, x)
  }))
}
num <- function(x) as.numeric(x)

coal_metal_label <- function(x) recode(x, C = "Coal", M = "Metal/nonmetal", .default = NA_character_)
subunit_labels <- c(
  "01" = "Underground", "02" = "Surface at underground mine", "03" = "Strip, quarry, open pit",
  "04" = "Auger", "05" = "Culm bank or refuse pile", "06" = "Dredge", "12" = "Other surface",
  "17" = "Independent shop or yard", "30" = "Mill or preparation plant",
  "99" = "Office workers at mine site")
subunit_label <- function(code) unname(subunit_labels[code])
degree_labels <- c(
  "00" = "Accident only (no injury)", "01" = "Fatality",
  "02" = "Permanent total or partial disability", "03" = "Days away from work only",
  "04" = "Days away from work and restricted activity", "05" = "Restricted activity only",
  "06" = "No days away, no restriction", "07" = "Occupational illness",
  "08" = "Natural causes", "09" = "Non-employee", "10" = "Other (including first aid)")

# ---- Mines ----
mines_raw <- read_msha("Mines")
mines <- mines_raw |>
  transmute(
    mine_id = MINE_ID,
    mine_name = CURRENT_MINE_NAME,
    coal_metal = coal_metal_label(COAL_METAL_IND),
    mine_type = CURRENT_MINE_TYPE,
    mine_status = CURRENT_MINE_STATUS,
    status_date = as.Date(CURRENT_STATUS_DT, "%m/%d/%Y"),
    operator_name = CURRENT_OPERATOR_NAME,
    controller_name = CURRENT_CONTROLLER_NAME,
    state = STATE,
    county = FIPS_CNTY_NM,
    commodity = recode(PRIMARY_CANVASS, SandAndGravel = "Sand and gravel"),
    primary_sic = PRIMARY_SIC,
    employees = num(NO_EMPLOYEES),
    latitude = num(LATITUDE),
    longitude = num(LONGITUDE)
  ) |>
  distinct(mine_id, .keep_all = TRUE)
# A few coordinates are recorded with the wrong sign or are outside the US and its territories
mines <- mines |>
  mutate(longitude = if_else(!is.na(longitude) & longitude > 0 & longitude < 180, -longitude, longitude),
         bad = is.na(latitude) | is.na(longitude) | latitude < 13 | latitude > 72 |
               longitude < -180 | longitude > -60,
         latitude = if_else(bad, NA_real_, latitude),
         longitude = if_else(bad, NA_real_, longitude)) |>
  select(-bad)
mine_info <- select(mines, mine_id, state, commodity, mine_type)

# ---- Accidents, injuries and illnesses ----
acc_raw <- read_msha("Accidents")
acc <- acc_raw |>
  mutate(year = as.integer(CAL_YR)) |>
  filter(year %in% years) |>
  left_join(mine_info, by = c("MINE_ID" = "mine_id")) |>
  transmute(
    document_no = DOCUMENT_NO,
    mine_id = MINE_ID,
    contractor_id = CONTRACTOR_ID,
    worker_type = if_else(is.na(CONTRACTOR_ID), "Operator", "Contractor"),
    operator_name = OPERATOR_NAME,
    coal_metal = coal_metal_label(COAL_METAL_IND),
    state, commodity, mine_type,
    accident_date = as.Date(ACCIDENT_DT, "%m/%d/%Y"),
    year,
    accident_time = ACCIDENT_TIME,
    shift_begin_time = SHIFT_BEGIN_TIME,
    subunit = subunit_label(SUBUNIT_CD),
    degree_code = DEGREE_INJURY_CD,
    degree = unname(degree_labels[DEGREE_INJURY_CD]),
    classification = str_to_sentence(CLASSIFICATION),
    accident_type = ACCIDENT_TYPE,
    no_injuries = as.integer(NO_INJURIES),
    total_experience = num(TOT_EXPER),
    mine_experience = num(MINE_EXPER),
    job_experience = num(JOB_EXPER),
    occupation = OCCUPATION,
    activity = ACTIVITY,
    injury_source = str_to_sentence(INJURY_SOURCE),
    nature_injury = str_to_sentence(NATURE_INJURY),
    body_part = str_to_sentence(INJ_BODY_PART),
    ug_location = UG_LOCATION,
    ug_mining_method = UG_MINING_METHOD,
    mining_equipment = MINING_EQUIP,
    equipment_manufacturer = EQUIP_MFR_NAME,
    days_lost = num(DAYS_LOST),
    days_restricted = num(DAYS_RESTRICT),
    schedule_charge = num(SCHEDULE_CHARGE),
    narrative = NARRATIVE
  ) |>
  # "NO VALUE FOUND" is the label for a missing code
  mutate(across(where(is.character), \(x) if_else(str_detect(x, "(?i)^no value found$"), NA_character_, x)))

# Injury categories used by MSHA for its injury rates
acc <- acc |>
  mutate(category = case_when(
    degree_code == "01" ~ "fatal",
    degree_code %in% c("02", "03", "04", "05") ~ "nfdl",   # non-fatal, days lost
    degree_code == "06" ~ "ndl",                           # no days lost
    degree_code == "07" ~ "illness",
    TRUE ~ NA_character_))

# ---- Hours worked and employment ----
prod_op <- read_msha("MinesProdQuarterly") |>
  mutate(year = as.integer(CAL_YR)) |>
  filter(year %in% years) |>
  left_join(mine_info, by = c("MINE_ID" = "mine_id")) |>
  transmute(mine_id = MINE_ID, worker_type = "Operator", year, quarter = as.integer(CAL_QTR),
            coal_metal = coal_metal_label(COAL_METAL_IND), subunit = subunit_label(SUBUNIT_CD),
            state, commodity, mine_type,
            employees = num(AVG_EMPLOYEE_CNT), hours = num(HOURS_WORKED),
            coal_tons = num(COAL_PRODUCTION))
prod_con <- read_msha("ContractorProdQuarterly", quoted = TRUE) |>
  mutate(year = as.integer(CAL_YR)) |>
  filter(year %in% years) |>
  transmute(worker_type = "Contractor", year, quarter = as.integer(CAL_QTR),
            coal_metal = coal_metal_label(COAL_METAL_IND), subunit = subunit_label(SUBUNIT_CD),
            state = NA_character_, commodity = NA_character_,
            employees = num(AVG_EMPLOYEE_CNT), hours = num(HOURS_WORKED),
            coal_tons = num(COAL_PRODUCTION))

# ---- Injury summary ----
# Contractors report hours nationally, not by mine, so contractor rows have no state or commodity.
keys <- c("year", "worker_type", "coal_metal", "subunit", "state", "commodity")
work <- bind_rows(prod_op, prod_con) |>
  group_by(across(all_of(keys))) |>
  summarise(reporting_units = n_distinct(if_else(worker_type == "Operator", mine_id, NA_character_), na.rm = TRUE),
            # Annual average employees: the four quarterly averages summed, divided by 4
            employees = sum(employees, na.rm = TRUE) / 4,
            hours = sum(hours, na.rm = TRUE),
            coal_tons = sum(coal_tons, na.rm = TRUE), .groups = "drop") |>
  mutate(reporting_units = if_else(worker_type == "Operator", reporting_units, NA_integer_))
inj <- acc |>
  mutate(state = if_else(worker_type == "Contractor", NA_character_, state),
         commodity = if_else(worker_type == "Contractor", NA_character_, commodity)) |>
  group_by(across(all_of(keys))) |>
  summarise(fatalities = sum(category == "fatal", na.rm = TRUE),
            nfdl_injuries = sum(category == "nfdl", na.rm = TRUE),
            ndl_injuries = sum(category == "ndl", na.rm = TRUE),
            illnesses = sum(category == "illness", na.rm = TRUE),
            days_lost = sum(days_lost[category %in% c("nfdl", "illness")], na.rm = TRUE),
            days_restricted = sum(days_restricted[category %in% c("nfdl", "illness")], na.rm = TRUE),
            .groups = "drop")
injury_summary <- full_join(work, inj, by = keys) |>
  mutate(across(c(employees, hours, coal_tons, fatalities, nfdl_injuries, ndl_injuries, illnesses,
                  days_lost, days_restricted), \(x) coalesce(x, 0)),
         employees = round(employees, 1),
         coal_tons = if_else(coal_metal == "Coal", coal_tons, NA_real_)) |>
  arrange(across(all_of(keys)))
write_csv(injury_summary, file.path(tidy_dir, "injury_summary.csv.gz"), na = "")

# ---- Accident records ----
acc_out <- select(acc, -category)
write_csv(filter(acc_out, degree_code == "01"), file.path(tidy_dir, "fatalities.csv.gz"), na = "")
write_csv(filter(acc_out, year >= 2015), file.path(tidy_dir, "accidents.csv.gz"), na = "")
write_csv(mines, file.path(tidy_dir, "mines.csv.gz"), na = "")

# ---- Violations ----
viol <- read_msha("Violations", c(
  "VIOLATION_NO", "EVENT_NO", "VIOLATOR_TYPE_CD", "MINE_ID", "MINE_TYPE", "COAL_METAL_IND",
  "CAL_YR", "SIG_SUB", "SECTION_OF_ACT", "PART_SECTION", "SECTION_OF_ACT_1", "CIT_ORD_SAFE",
  "LIKELIHOOD", "INJ_ILLNESS", "NEGLIGENCE", "SPECIAL_ASSESS", "PROPOSED_PENALTY",
  "AMOUNT_PAID", "CONTESTED_IND")) |>
  mutate(year = as.integer(CAL_YR)) |>
  filter(year %in% years) |>
  distinct(VIOLATION_NO, .keep_all = TRUE) |>
  transmute(
    mine_id = MINE_ID, year,
    coal_metal = coal_metal_label(COAL_METAL_IND),
    mine_type = MINE_TYPE,
    violator_type = VIOLATOR_TYPE_CD,
    action = case_when(CIT_ORD_SAFE %in% c("Citation", "Order", "Safeguard") ~ CIT_ORD_SAFE,
                       is.na(CIT_ORD_SAFE) ~ NA_character_, TRUE ~ "Other"),
    act_section = SECTION_OF_ACT_1,
    significant_substantial = recode(SIG_SUB, Y = "Yes", N = "No"),
    likelihood = recode(LIKELIHOOD, NoLikelihood = "No likelihood", Unlikely = "Unlikely",
                        Reasonably = "Reasonably likely", Highly = "Highly likely",
                        Occurred = "Occurred"),
    injury_severity = recode(INJ_ILLNESS, NoLostDays = "No lost workdays",
                             LostDays = "Lost workdays or restricted duty",
                             Permanent = "Permanently disabling", Fatal = "Fatal"),
    negligence = recode(NEGLIGENCE, NoNegligence = "None", LowNegligence = "Low",
                        ModNegligence = "Moderate", HighNegligence = "High",
                        Reckless = "Reckless disregard"),
    special_assessment = SPECIAL_ASSESS == "Y",
    contested = CONTESTED_IND == "Y",
    proposed_penalty = num(PROPOSED_PENALTY),
    amount_paid = num(AMOUNT_PAID),
    # The standard cited: a section of Title 30 of the Code of Federal Regulations, without its
    # paragraph, or a section of the Mine Act when no regulation is cited
    standard = coalesce(str_extract(PART_SECTION, "^[0-9]+\\.[0-9]+"),
                        if_else(is.na(SECTION_OF_ACT), NA_character_, paste("Mine Act", SECTION_OF_ACT))),
    cfr_part = str_extract(standard, "^[0-9]+(?=\\.)")
  )

violation_summary <- viol |>
  group_by(year, coal_metal, mine_type, violator_type, action, act_section,
           significant_substantial, likelihood, injury_severity, negligence) |>
  summarise(violations = n(),
            special_assessments = sum(special_assessment, na.rm = TRUE),
            contested = sum(contested, na.rm = TRUE),
            proposed_penalty = sum(proposed_penalty, na.rm = TRUE),
            amount_paid = sum(amount_paid, na.rm = TRUE), .groups = "drop")
write_csv(violation_summary, file.path(tidy_dir, "violation_summary.csv.gz"), na = "")

cfr_parts <- c(
  "40" = "Representatives of miners", "41" = "Notification of legal identity",
  "45" = "Independent contractors", "46" = "Training (sand, gravel, surface stone and similar mines)",
  "47" = "Hazard communication", "48" = "Training and retraining of miners",
  "49" = "Mine rescue teams",
  "50" = "Notification and reporting of accidents, injuries, illnesses, employment and production",
  "56" = "Safety and health standards: surface metal and nonmetal mines",
  "57" = "Safety and health standards: underground metal and nonmetal mines",
  "58" = "Health standards: metal and nonmetal mines", "62" = "Occupational noise exposure",
  "70" = "Health standards: underground coal mines",
  "71" = "Health standards: surface coal mines and surface work areas of underground coal mines",
  "72" = "Health standards: coal mines", "75" = "Safety standards: underground coal mines",
  "77" = "Safety standards: surface coal mines and surface work areas of underground coal mines",
  "90" = "Coal miners with evidence of pneumoconiosis")
violation_standards <- viol |>
  group_by(year, coal_metal, cfr_part, standard) |>
  summarise(violations = n(),
            significant_substantial = sum(significant_substantial == "Yes", na.rm = TRUE),
            mines = n_distinct(mine_id),
            proposed_penalty = sum(proposed_penalty, na.rm = TRUE),
            amount_paid = sum(amount_paid, na.rm = TRUE), .groups = "drop") |>
  mutate(cfr_part_title = unname(cfr_parts[cfr_part]), .after = cfr_part)
write_csv(violation_standards, file.path(tidy_dir, "violation_standards.csv.gz"), na = "")

# ---- Mine-year table (mine operators only) ----
my_work <- prod_op |>
  group_by(mine_id, year) |>
  summarise(employees = sum(employees, na.rm = TRUE) / 4, hours = sum(hours, na.rm = TRUE),
            coal_tons = sum(coal_tons, na.rm = TRUE), .groups = "drop")
my_inj <- acc |>
  filter(worker_type == "Operator") |>
  group_by(mine_id, year) |>
  summarise(fatalities = sum(category == "fatal", na.rm = TRUE),
            nfdl_injuries = sum(category == "nfdl", na.rm = TRUE),
            ndl_injuries = sum(category == "ndl", na.rm = TRUE),
            illnesses = sum(category == "illness", na.rm = TRUE),
            days_lost = sum(days_lost[category %in% c("nfdl", "illness")], na.rm = TRUE),
            .groups = "drop")
my_viol <- viol |>
  filter(violator_type == "Operator") |>
  group_by(mine_id, year) |>
  summarise(violations = n(),
            ss_violations = sum(significant_substantial == "Yes", na.rm = TRUE),
            orders = sum(action == "Order", na.rm = TRUE),
            proposed_penalty = sum(proposed_penalty, na.rm = TRUE), .groups = "drop")
mine_year <- my_work |>
  full_join(my_inj, by = c("mine_id", "year")) |>
  full_join(my_viol, by = c("mine_id", "year")) |>
  mutate(across(-c(mine_id, year), \(x) coalesce(x, 0)),
         employees = round(employees, 1)) |>
  left_join(select(mines, mine_id, coal_metal, mine_type, state, commodity), by = "mine_id") |>
  mutate(coal_tons = if_else(coal_metal %in% "Coal", coal_tons, NA_real_)) |>
  relocate(coal_metal, mine_type, state, commodity, .after = year) |>
  arrange(mine_id, year)
write_csv(mine_year, file.path(tidy_dir, "mine_year.csv.gz"), na = "")

for (f in list.files(tidy_dir, full.names = TRUE))
  message(sprintf("%-28s %9s rows %6.1f MB", basename(f),
                  format(nrow(read_csv(f, col_types = cols(.default = "c"), progress = FALSE)), big.mark = ","),
                  file.size(f) / 1e6))

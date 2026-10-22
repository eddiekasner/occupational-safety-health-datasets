# Build tidy tables of child labour statistics from ILOSTAT and UNICEF.
#
# Usage (from a terminal):   Rscript scripts/build_dataset.R
# Usage (from RStudio):      open this file and click "Source"
#
# Reads the files downloaded by scripts/fetch_data.R and writes, to data/tidy/:
#   rates.csv.gz      ILOSTAT: share of children (%) in economic activity, child labour and
#                     hazardous work, and SDG indicator 8.7.1, by country, survey year, sex and age
#                     group, and also by rural or urban area and by school attendance
#   counts.csv.gz     ILOSTAT: number of children (thousands) in employment, child labour and
#                     hazardous work by economic sector and by status in employment, and the child
#                     population
#   unicef_latest.csv UNICEF: the latest estimate of child labour for each country and region, by
#                     sex, with the survey it comes from

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

measures <- c(XSNA = "Economic activity", XCHL = "Child labour", XHAZ = "Hazardous work",
              XGPB = "Child labour (general production boundary)",
              A871 = "SDG 8.7.1: economic activity",
              B871 = "SDG 8.7.1: economic activity and household chores",
              TPOP = "Child population")

# The part after the colon in ILOSTAT's labels ("Age: 15-17" becomes "15-17")
after_colon <- function(x) sub("^'", "", trimws(sub("^[^:]*:", "", x)))

read_ilostat <- function(id) {
  x <- read_csv(file.path(raw_dir, paste0(id, ".csv")), show_col_types = FALSE,
                col_types = cols(.default = col_character(), obs_value = col_double()))
  if (!"classif2" %in% names(x)) x <- mutate(x, classif2 = NA_character_, classif2.label = NA_character_)
  # Notes on the survey, without the repository note that every row has
  notes <- paste(coalesce(x$note_indicator.label, ""), coalesce(x$note_source.label, ""), sep = " | ")
  notes <- gsub("Repository: ILO-STATISTICS - Micro data processing", "", notes)
  notes <- gsub("^[ |]+|[ |]+$", "", gsub("( \\| )+", " | ", notes))
  x |>
    transmute(measure = unname(measures[sub("^(CLD_|SDG_)", "", sub("_SEX.*", "", id))]),
              table = id, iso3 = ref_area, country = ref_area.label, year = as.integer(time),
              survey = source.label, survey_code = source,
              sex = sex.label, age = after_colon(classif1.label),
              category_code = classif2, category = after_colon(classif2.label),
              value = obs_value,
              flag = case_when(obs_status == "U" ~ "Unreliable", obs_status == "B" ~ "Break in series",
                               TRUE ~ ""),
              note = notes)
}

# ---- Rates ---------------------------------------------------------------------------------------
plain <- c("CLD_XSNA_SEX_AGE_RT", "CLD_XCHL_SEX_AGE_RT", "CLD_XHAZ_SEX_AGE_RT", "CLD_XGPB_SEX_AGE_RT",
           "SDG_A871_SEX_AGE_RT", "SDG_B871_SEX_AGE_RT")
area <- c("CLD_XSNA_SEX_AGE_GEO_RT", "CLD_XCHL_SEX_AGE_GEO_RT", "CLD_XHAZ_SEX_AGE_GEO_RT")
school <- c("CLD_XSNA_SEX_AGE_STU_RT", "CLD_XCHL_SEX_AGE_STU_RT", "CLD_XHAZ_SEX_AGE_STU_RT")

rates_plain <- map_dfr(plain, read_ilostat) |>
  mutate(breakdown = "None", category = "Total")
rates_area <- map_dfr(area, read_ilostat) |> mutate(breakdown = "Area")
rates_school <- map_dfr(school, read_ilostat) |> mutate(breakdown = "School attendance")

# Check: the national rows of the tables by area match the tables without a breakdown
check_area <- rates_area |>
  filter(category_code == "GEO_COV_NAT") |>
  inner_join(rates_plain, by = c("measure", "iso3", "year", "survey_code", "sex", "age"),
             suffix = c("", "_plain")) |>
  mutate(diff = abs(value - value_plain))
message(sprintf("National rows of the tables by area: %d match the plain tables, %d differ by more than 0.1",
                sum(check_area$diff <= 0.1, na.rm = TRUE), sum(check_area$diff > 0.1, na.rm = TRUE)))

# Keep the categories only (the totals repeat the plain tables)
rates <- bind_rows(
  rates_plain,
  rates_area |> filter(category_code %in% c("GEO_COV_RUR", "GEO_COV_URB")),
  rates_school |> filter(category_code %in% c("STU_EDU_YES", "STU_EDU_NO"))
) |>
  filter(!is.na(value)) |>
  mutate(age = factor(age, c("5-17", "5-11", "12-14", "15-17"))) |>
  arrange(measure, iso3, year, survey_code, breakdown, category, sex, age) |>
  mutate(age = as.character(age)) |>
  select(measure, table, iso3, country, year, survey, survey_code, sex, age, breakdown, category,
         value, flag, note)
write_csv(rates, file.path(tidy_dir, "rates.csv.gz"), na = "")

# ---- Counts --------------------------------------------------------------------------------------
counts_tables <- c("CLD_XSNA_SEX_AGE_ECO_NB", "CLD_XCHL_SEX_AGE_ECO_NB", "CLD_XHAZ_SEX_AGE_ECO_NB",
                   "CLD_XSNA_SEX_AGE_STE_NB", "CLD_XCHL_SEX_AGE_STE_NB", "CLD_XHAZ_SEX_AGE_STE_NB")
counts <- map_dfr(counts_tables, read_ilostat) |>
  mutate(measure = recode(measure, "Economic activity" = "Children in employment"),
         breakdown = if_else(grepl("_ECO_", table), "Economic sector", "Status in employment"),
         category = sub("^\\d\\. ", "", category),
         category = recode(category, "X - Not elsewhere classified" = "Not elsewhere classified")) |>
  # Non-agriculture is industry plus services; drop it so that the sectors add up to the total
  filter(category_code != "ECO_SECTOR_NAG")

# Check: sectors and statuses add up to their totals
check_counts <- counts |>
  group_by(measure, breakdown, iso3, year, survey_code, sex, age) |>
  summarise(total = sum(value[category == "Total"], na.rm = TRUE),
            parts = sum(value[category != "Total"], na.rm = TRUE), .groups = "drop") |>
  filter(total > 0) |>
  mutate(diff_pct = 100 * abs(parts - total) / total)
# Categories that are not published (small samples) make the parts fall short of the total; they
# should never exceed it
message(sprintf(paste("Counts: parts add up to the total (within 1%%) in %.1f%% of %d groups,",
                      "and exceed it by more than 1%% in %d"),
                100 * mean(check_counts$diff_pct <= 1), nrow(check_counts),
                sum(check_counts$parts > 1.01 * check_counts$total)))
if (any(check_counts$parts > 1.01 * check_counts$total)) warning("Parts exceed totals in some counts")

population <- read_ilostat("CLD_TPOP_SEX_AGE_NB") |>
  mutate(breakdown = "None", category = "Total")
counts <- bind_rows(counts, population) |>
  filter(!is.na(value)) |>
  rename(thousands = value) |>
  arrange(measure, iso3, year, survey_code, breakdown, category_code, sex, age) |>
  select(measure, table, iso3, country, year, survey, survey_code, sex, age, breakdown, category,
         thousands, flag, note)
write_csv(counts, file.path(tidy_dir, "counts.csv.gz"), na = "")

# ---- UNICEF --------------------------------------------------------------------------------------
code <- function(x) sub(":.*$", "", x)
label <- function(x) trimws(sub("^[^:]*: ", "", x))
unicef_names <- c("PT_CHLD_5-17_LBR_ECON" = "Child labour (economic activities)",
                  "PT_CHLD_5-17_LBR_ECON-HC" = "Child labour (economic activities and household chores)",
                  "PT_ADLS_10-14_LBR_HC" = "Household chores (ages 10-14)")
unicef <- list.files(raw_dir, "^unicef_.*\\.csv$", full.names = TRUE) |>
  map_dfr(~ read_csv(.x, show_col_types = FALSE, col_types = cols(.default = col_character()))) |>
  transmute(indicator = unname(unicef_names[code(`INDICATOR:Indicator`)]),
            area_code = code(`REF_AREA:Geographic area`), area = label(`REF_AREA:Geographic area`),
            # Countries have three-letter ISO codes; regions have longer codes
            is_region = !grepl("^[A-Z]{3}$", area_code),
            sex = recode(code(`SEX:Sex`), "_T" = "Total", "M" = "Male", "F" = "Female"),
            age = sub("^Y(\\d+)T(\\d+)$", "\\1-\\2", code(`AGE:Current age`)),
            year = as.integer(`TIME_PERIOD:Time period`),
            coverage_years = `COVERAGE_TIME:The period of time for which data are provided`,
            value = as.numeric(`OBS_VALUE:Observation Value`),
            data_source = `DATA_SOURCE:Data Source`,
            status = label(`OBS_STATUS:Observation Status`),
            footnote = `OBS_FOOTNOTE:Observation footnote`) |>
  arrange(indicator, is_region, area, sex)
write_csv(unicef, file.path(tidy_dir, "unicef_latest.csv"), na = "")

# Compare UNICEF's country estimates of child labour (economic activities) with ILOSTAT's SDG
# 8.7.1 for the same country and year. They agree for the labour force, income and child labour
# surveys that ILO processes, but often not for household surveys (MICS and DHS), where the two
# agencies compute the indicator differently
compare <- unicef |>
  filter(!is_region, indicator == "Child labour (economic activities)", age == "5-17",
         sex == "Total") |>
  inner_join(rates |> filter(measure == "SDG 8.7.1: economic activity", age == "5-17",
                             breakdown == "None", sex == "Total"),
             by = c("area_code" = "iso3", "year"), suffix = c("", "_ilo")) |>
  mutate(survey_type = sub(" - .*", "", survey)) |>
  group_by(area_code, survey_type) |>
  summarise(diff = min(abs(value - value_ilo), na.rm = TRUE), .groups = "drop") |>
  group_by(survey_type) |>
  summarise(countries = n(), within_half_point = sum(diff <= 0.5))
message("UNICEF vs ILOSTAT, same country and year, by type of survey:")
print(as.data.frame(compare))

for (f in list.files(tidy_dir, full.names = TRUE)) {
  message(sprintf("%-20s %7.2f MB", basename(f), file.size(f) / 1e6))
}

# Build tidy tables of work-related notifications in SINAN (Brazil) from the TabNet downloads.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads data/raw/tabnet/ (from fetch_data.R) and writes:
#   data/tidy/accidents_by_year.csv.gz      work accidents by year of notification and one
#                                           characteristic at a time (employment status, sex,
#                                           age, race, education, state, occupation, industry,
#                                           accident type, outcome, CAT issued, body part,
#                                           cause, and others)
#   data/tidy/accidents_crosstabs.csv.gz    work accidents by year and pairs of characteristics
#                                           (for example employment status by outcome)
#   data/tidy/accidents_occupation_industry.csv.gz
#                                           work accidents and deaths by occupation and by
#                                           industry, 2006 to 2025 together
#   data/tidy/other_conditions.csv.gz       seven work-related diseases and exposures by year
#                                           and state, sex, age, employment status, occupation
#
# Categories are translated to English (category); the Portuguese label is kept (category_pt).
# The translations are written with plain ASCII keys (accents removed) so that the script works
# in any locale.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(stringi)
  library(purrr)
})

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
raw_dir <- file.path(module_dir, "data", "raw", "tabnet")
tidy_dir <- file.path(module_dir, "data", "tidy")
dir.create(tidy_dir, recursive = TRUE, showWarnings = FALSE)

files <- list.files(raw_dir, pattern = "\\.csv$", full.names = TRUE)
if (!length(files)) stop("No files in ", raw_dir, ". Run fetch_data.R first.")

# ---- Variables and translations --------------------------------------------------------------

variables <- c(
  "Sit._Merc._Trab." = "employment_status", "Sexo" = "sex", "Fx_Etaria_(13)" = "age_group",
  "Raca" = "race", "Escolar_SinanNET" = "education", "UF_Acid" = "state",
  "UF_de_notificacao" = "state", "Ocupacao" = "occupation", "CNAE-Ativ._Econ." = "industry",
  "Tipo_acidente" = "accident_type", "Evolucao_caso" = "outcome", "Emitida_CAT" = "cat_issued",
  "Parte_ating._1" = "body_part", "causa_acidente" = "cause",
  "Empresa_Terceirizada" = "outsourced", "Hora_apos_jornada" = "hours_into_shift",
  "atend._medico" = "medical_care")

conditions <- c(
  acgr = "Work accident", acbi = "Exposure to biological material at work",
  lerdor = "Repetitive strain injury and work-related musculoskeletal disorder (LER/DORT)",
  pair = "Noise-induced hearing loss (PAIR)", derm = "Occupational dermatosis",
  pneu = "Pneumoconiosis", canc = "Work-related cancer",
  transmental = "Work-related mental disorder")

# Keys: Portuguese labels with accents removed and in lower case
key <- function(x) {
  # "Latin-ASCII" keeps the ordinal indicators (as in "1a serie"); replace them first. Stray
  # control characters (a Windows apostrophe in one TabNet label) are removed.
  x <- str_replace_all(x, "\\x{00AA}", "a")
  x <- str_replace_all(x, "\\x{00BA}", "o")
  x <- str_replace_all(x, "[\\x{0080}-\\x{009F}]", "")
  str_to_lower(str_squish(stri_trans_general(x, "Latin-ASCII")))
}
translations <- c(
  # shared
  "ign/branco" = "Unknown", "ignorado" = "Unknown", "em branco" = "Unknown",
  "ignorado ou branco" = "Unknown", "sim" = "Yes", "nao" = "No",
  "outros cids nao listados" = "Other (codes not listed by TabNet)",
  "nao se aplica" = "Not applicable", "outro" = "Other", "outra" = "Other", "outros" = "Other",
  # employment status
  "empregado registrado" = "Registered employee", "empregado nao registrado" = "Unregistered employee",
  "autonomo" = "Self-employed", "serv. pub. estatutario" = "Public servant (statutory)",
  "serv. pub. celetista" = "Public employee (labour-law contract)", "aposentado" = "Retired",
  "desempregado" = "Unemployed", "trab. temporario" = "Temporary worker",
  "cooperativado" = "Cooperative member", "trab. avulso" = "Casual worker (avulso)",
  "empregador" = "Employer",
  # sex
  "masculino" = "Male", "feminino" = "Female",
  # race
  "branca" = "White", "preta" = "Black", "parda" = "Mixed (parda)",
  "amarela" = "East Asian (amarela)", "indigena" = "Indigenous",
  # education
  "analfabeto" = "No schooling (illiterate)",
  "1a a 4a serie incompleta do ef" = "Primary, grades 1-4 incomplete",
  "4a serie completa do ef" = "Primary, grade 4 complete",
  "5a a 8a serie incompleta do ef" = "Lower secondary, grades 5-8 incomplete",
  "ensino fundamental completo" = "Lower secondary complete",
  "ensino medio incompleto" = "Upper secondary incomplete",
  "ensino medio completo" = "Upper secondary complete",
  "educacao superior incompleta" = "Higher education incomplete",
  "educacao superior completa" = "Higher education complete",
  # accident type
  "tipico" = "Typical (at work)", "trajeto" = "Commuting",
  # outcome
  "cura" = "Recovered", "incapacidade temporaria" = "Temporary disability",
  "incapacidade parcial permanente" = "Permanent partial disability",
  "incapacidade total permanente" = "Permanent total disability",
  "obito pelo acidente" = "Death from the accident",
  "obito por outras causas" = "Death from other causes",
  # body part
  "mao" = "Hand", "membro superior" = "Upper limb", "membro inferior" = "Lower limb",
  "pe" = "Foot", "cabeca" = "Head", "olho" = "Eye", "todo o corpo" = "Whole body",
  "torax" = "Thorax", "abdome" = "Abdomen", "pescoco" = "Neck")

# ICD-10 blocks for external causes (V01 to Y98); S and T codes (injuries) are included in case
# TabNet lists them
icd_block <- function(code) {
  letter <- str_sub(code, 1, 1)
  num <- suppressWarnings(as.integer(str_sub(code, 2, 3)))
  case_when(
    letter == "V" ~ "Transport accidents (V01-V99)",
    letter == "W" & num <= 19 ~ "Falls (W00-W19)",
    letter == "W" & num <= 49 ~ "Exposure to inanimate mechanical forces (W20-W49)",
    letter == "W" & num <= 64 ~ "Exposure to animate mechanical forces (W50-W64)",
    letter == "W" & num <= 74 ~ "Drowning and submersion (W65-W74)",
    letter == "W" & num <= 84 ~ "Other threats to breathing (W75-W84)",
    letter == "W" ~ "Electric current, radiation, extreme temperature and pressure (W85-W99)",
    letter == "X" & num <= 9 ~ "Smoke, fire and flames (X00-X09)",
    letter == "X" & num <= 19 ~ "Contact with heat and hot substances (X10-X19)",
    letter == "X" & num <= 29 ~ "Venomous animals and plants (X20-X29)",
    letter == "X" & num <= 39 ~ "Forces of nature (X30-X39)",
    letter == "X" & num <= 49 ~ "Accidental poisoning (X40-X49)",
    letter == "X" & num <= 57 ~ "Overexertion, travel and privation (X50-X57)",
    letter == "X" & num <= 59 ~ "Other and unspecified factors (X58-X59)",
    letter == "X" & num <= 84 ~ "Intentional self-harm (X60-X84)",
    letter == "X" | (letter == "Y" & num <= 9) ~ "Assault (X85-Y09)",
    letter == "Y" & num <= 34 ~ "Event of undetermined intent (Y10-Y34)",
    letter == "Y" & num <= 36 ~ "Legal intervention and war (Y35-Y36)",
    letter == "Y" & num <= 84 ~ "Complications of medical care (Y40-Y84)",
    letter == "Y" & num <= 89 ~ "Sequelae of external causes (Y85-Y89)",
    letter == "Y" ~ "Supplementary factors (Y90-Y98), e.g. Y96 work-related condition",
    letter == "S" & num <= 9 ~ "Head (S00-S09)",
    letter == "S" & num <= 19 ~ "Neck (S10-S19)",
    letter == "S" & num <= 29 ~ "Thorax (S20-S29)",
    letter == "S" & num <= 39 ~ "Abdomen, lower back, pelvis (S30-S39)",
    letter == "S" & num <= 49 ~ "Shoulder and upper arm (S40-S49)",
    letter == "S" & num <= 59 ~ "Elbow and forearm (S50-S59)",
    letter == "S" & num <= 69 ~ "Wrist and hand (S60-S69)",
    letter == "S" & num <= 79 ~ "Hip and thigh (S70-S79)",
    letter == "S" & num <= 89 ~ "Knee and lower leg (S80-S89)",
    letter == "S" ~ "Ankle and foot (S90-S99)",
    letter == "T" & num <= 7 ~ "Multiple body regions (T00-T07)",
    letter == "T" & num <= 14 ~ "Unspecified body region (T08-T14)",
    letter == "T" & num <= 19 ~ "Foreign body entering through natural orifice (T15-T19)",
    letter == "T" & num <= 32 ~ "Burns and corrosions (T20-T32)",
    letter == "T" & num <= 35 ~ "Frostbite (T33-T35)",
    letter == "T" & num <= 65 ~ "Poisoning and toxic effects (T36-T65)",
    letter == "T" & num <= 78 ~ "Other effects of external causes (T66-T78)",
    letter == "T" ~ "Complications and sequelae of trauma (T79-T98)",
    TRUE ~ NA_character_)
}

translate <- function(variable, category_pt) {
  k <- key(category_pt)
  code <- str_extract(category_pt, "^[A-Z][0-9]{2}")
  case_when(
    variable == "age_group" ~ str_replace_all(str_replace_all(
      str_replace(str_replace(category_pt, "^Menor 1 ano$", "Under 1"), " anos e mais$", "+"),
      " a ", "-"), " anos?$", ""),
    variable == "hours_into_shift" & str_detect(k, "^[0-9]+ horas?$") ~ str_extract(k, "^[0-9]+"),
    variable == "cause" & !is.na(code) ~ icd_block(code),
    k %in% c("cid nao preenchido", "00 ignorado/exterior", "998999 ignorada") ~ "Unknown",
    variable %in% c("state", "occupation", "industry") & !k %in% names(translations) ~ category_pt,
    k %in% names(translations) ~ unname(translations[k]),
    TRUE ~ NA_character_)
}

# ---- Read ------------------------------------------------------------------------------------

read_table <- function(f) {
  parts <- str_split(str_remove(basename(f), "\\.csv$"), "__")[[1]]
  d <- read_csv(f, col_types = cols(row = "c", col = "c", n = "d", .default = "c"),
                locale = locale(encoding = "UTF-8"))
  d$condition <- parts[1]
  d$row_var <- parts[2]
  d$col_var <- parts[3]
  d$part <- if (length(parts) > 3) parts[4] else NA_character_
  d
}
# Files saved by an R session in a "C" locale may contain escapes such as "<U+00E3>"; decode them
unescape <- function(x) {
  stri_trans_nfc(stri_unescape_unicode(str_replace_all(x, "<U\\+([0-9A-Fa-f]{4})>", "\\\\u\\1")))
}
raw <- map_dfr(files, read_table) |>
  mutate(row = unescape(row), col = unescape(col))

tidy_var <- function(d, prefix) {
  d |>
    mutate(variable = unname(variables[.data[[paste0(prefix, "_var")]]]),
           category_pt = .data[[prefix]],
           category = translate(variable, category_pt))
}

# ---- Work accidents by year and one characteristic -------------------------------------------

by_year <- raw |>
  filter(condition == "acgr", col_var == "year") |>
  rename(var = row_var) |>
  transmute(year = as.integer(col), var, category_pt = row, notifications = n) |>
  mutate(variable = unname(variables[var]), category = translate(variable, category_pt)) |>
  filter(year %in% 2006:2025) |>
  select(variable, category, category_pt, year, notifications) |>
  arrange(variable, category_pt, year)

# TabNet leaves out records whose code is not in its list for a variable (for example invalid
# industry codes), so some variables add up to less than the total. Add the difference as its own
# category, taking the total from sex (which every record has).
yearly_total <- by_year |>
  filter(variable == "sex") |>
  group_by(year) |>
  summarise(total = sum(notifications))
not_listed <- by_year |>
  group_by(variable, year) |>
  summarise(listed = sum(notifications), .groups = "drop") |>
  inner_join(yearly_total, by = "year") |>
  filter(listed < total) |>
  transmute(variable, category = "Not listed by TabNet", category_pt = NA_character_, year,
            notifications = total - listed)
if (any(by_year |> group_by(variable, year) |> summarise(n = sum(notifications), .groups = "drop") |>
        inner_join(yearly_total, by = "year") |> with(n > total))) {
  warning("A variable adds up to more than the yearly total")
}
by_year <- bind_rows(by_year, not_listed) |> arrange(variable, category_pt, year)

# ---- Pairs of characteristics, by year -------------------------------------------------------

crosstabs <- raw |>
  filter(condition == "acgr", !is.na(part), part != "all") |>
  mutate(year = as.integer(part),
         row_variable = unname(variables[row_var]), col_variable = unname(variables[col_var]),
         row_category = translate(row_variable, row), col_category = translate(col_variable, col)) |>
  select(year, row_variable, row_category, row_category_pt = row,
         col_variable, col_category, col_category_pt = col, notifications = n) |>
  arrange(row_variable, col_variable, year)

# ---- Occupation and industry, all years ------------------------------------------------------

occ_ind <- raw |>
  filter(condition == "acgr", part %in% "all") |>
  mutate(variable = unname(variables[row_var]),
         code = str_extract(row, "^[0-9]+"),
         label_pt = str_squish(str_remove(row, "^[0-9]+")),
         outcome = translate("outcome", col)) |>
  group_by(variable, code, label_pt) |>
  summarise(notifications = sum(n),
            deaths = sum(n[outcome == "Death from the accident"]),
            permanent_disability = sum(n[outcome %in% c("Permanent partial disability",
                                                        "Permanent total disability")]),
            .groups = "drop") |>
  arrange(variable, desc(notifications))

# ---- Other work-related conditions -----------------------------------------------------------

other <- raw |>
  filter(condition != "acgr", col_var == "year") |>
  transmute(condition = unname(conditions[condition]), year = as.integer(col),
            variable = unname(variables[row_var]), category_pt = row, notifications = n) |>
  mutate(category = translate(variable, category_pt)) |>
  filter(year %in% 2006:2025) |>
  select(condition, variable, category, category_pt, year, notifications) |>
  arrange(condition, variable, category_pt, year)

# ---- Check and write -------------------------------------------------------------------------

untranslated <- bind_rows(
  distinct(filter(by_year, is.na(category)), variable, category_pt),
  distinct(filter(other, is.na(category)), variable, category_pt),
  distinct(filter(crosstabs, is.na(row_category)), variable = row_variable, category_pt = row_category_pt),
  distinct(filter(crosstabs, is.na(col_category)), variable = col_variable, category_pt = col_category_pt))
if (nrow(untranslated)) {
  message("Categories without an English label:")
  print(distinct(untranslated), n = 50)
}

write_csv(by_year, file.path(tidy_dir, "accidents_by_year.csv.gz"), na = "")
write_csv(crosstabs, file.path(tidy_dir, "accidents_crosstabs.csv.gz"), na = "")
write_csv(occ_ind, file.path(tidy_dir, "accidents_occupation_industry.csv.gz"), na = "")
write_csv(other, file.path(tidy_dir, "other_conditions.csv.gz"), na = "")

by_year |> filter(variable == "sex") |> group_by(year) |>
  summarise(notifications = sum(notifications)) |> print(n = 30)
for (f in list.files(tidy_dir, full.names = TRUE))
  message(sprintf("%-40s %6.2f MB", basename(f), file.size(f) / 1e6))

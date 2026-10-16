# Build tidy tables of work injury reports and occupational disease claims in Italy from INAIL's
# open data.
#
# Usage:  Rscript scripts/build_dataset.R
#
# Reads data/raw/ (from fetch_data.R) and writes:
#   data/tidy/injuries_<year>.csv.gz        every injury report for accidents in that year (one row
#                                           per report), with English column names and labels
#   data/tidy/injuries_summary.csv.gz       reports, accepted cases, deaths and days compensated by
#                                           year, region, sector, sex, age group, birthplace and
#                                           commuting (complete)
#   data/tidy/occupational_diseases.csv.gz  every occupational disease claim reported in the
#                                           five years (one row per claim)
#   data/tidy/disease_deaths.csv.gz         deaths of workers with a recognised occupational
#                                           disease, by year of death
#
# Codes are translated using INAIL's documentation of the files (dati.inail.it). Totals are checked
# against INAIL's national tables.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
  library(purrr)
})

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg))) else getwd()
module_dir <- normalizePath(file.path(script_dir, ".."))
raw_dir <- file.path(module_dir, "data", "raw")
tidy_dir <- file.path(module_dir, "data", "tidy")
dir.create(tidy_dir, recursive = TRUE, showWarnings = FALSE)

read_inail <- function(path) {
  read_delim(path, delim = ";", col_types = cols(.default = col_character()), progress = FALSE,
             na = c("", "ND"))
}
# INAIL writes 01/01/1900 for dates not yet known (for example, cases not yet decided)
ymd <- function(x) {
  d <- as.Date(x, "%d/%m/%Y")
  d[d < as.Date("1950-01-01")] <- NA
  d
}

# ---- Labels ----------------------------------------------------------------------------------

regions_labels <- c(
  Abruzzo = "Abruzzo", Basilicata = "Basilicata", Calabria = "Calabria", Campania = "Campania",
  EmiliaRomagna = "Emilia-Romagna", FriuliVeneziaGiulia = "Friuli-Venezia Giulia", Lazio = "Lazio",
  Liguria = "Liguria", Lombardia = "Lombardia", Marche = "Marche", Molise = "Molise",
  Piemonte = "Piemonte", Puglia = "Puglia", Sardegna = "Sardegna", Sicilia = "Sicilia",
  Toscana = "Toscana", TrentinoAltoAdige = "Trentino-Alto Adige", Umbria = "Umbria",
  ValledAosta = "Valle d'Aosta", Veneto = "Veneto")
macro_area_labels <- c(
  Piemonte = "North-West", "Valle d'Aosta" = "North-West", Lombardia = "North-West",
  Liguria = "North-West", "Trentino-Alto Adige" = "North-East", Veneto = "North-East",
  "Friuli-Venezia Giulia" = "North-East", "Emilia-Romagna" = "North-East", Toscana = "Centre",
  Umbria = "Centre", Marche = "Centre", Lazio = "Centre", Abruzzo = "South", Molise = "South",
  Campania = "South", Puglia = "South", Basilicata = "South", Calabria = "South",
  Sicilia = "Islands", Sardegna = "Islands")

decision_labels <- c(P = "Accepted", N = "Rejected", F = "Short absence (statistical only)",
              I = "Under investigation")
compensation_labels <- c(TE = "Temporary disability", CA = "Lump sum (permanent impairment)",
                  RD = "Annuity to the worker (permanent impairment)",
                  RS = "Annuity to survivors", NE = "None")
# The State scheme ("per conto dello Stato") covers state employees and also school pupils and
# students, so it includes many children
insurance_scheme_labels <- c(I = "Industry and services", A = "Agriculture",
                             S = "State (state employees and school pupils)")
tariff_scheme_labels <- c("1" = "Industry", "2" = "Crafts", "3" = "Tertiary (services)",
                   "4" = "Other activities")
tariff_group_labels <- c("1" = "Agriculture and food", "2" = "Chemicals, paper and leather",
                  "3" = "Construction and installation", "4" = "Energy and communications",
                  "5" = "Wood", "6" = "Metals and machinery",
                  "7" = "Mining, stone and glass", "8" = "Textiles and clothing",
                  "9" = "Transport and warehousing", "0" = "Various activities")
fatal_rejection_labels <- c("244" = "No causal link with the event",
                            "028" = "Insufficient documentation",
                     "021" = "Not in the course of work",
                     "022" = "Not in the course of commuting", "024" = "Person not insured",
                     "027" = "Activity not insured", "300" = "Other reasons")
ateco_sections_labels <- c(
  A = "Agriculture, forestry and fishing", B = "Mining and quarrying", C = "Manufacturing",
  D = "Electricity, gas, steam and air conditioning", E = "Water supply, sewerage and waste",
  F = "Construction", G = "Wholesale and retail trade", H = "Transportation and storage",
  I = "Accommodation and food services", J = "Information and communication",
  K = "Financial and insurance activities", L = "Real estate", M = "Professional, scientific and technical",
  N = "Administrative and support services", O = "Public administration and defence",
  P = "Education", Q = "Health and social work", R = "Arts, entertainment and recreation",
  S = "Other services", T = "Households as employers", U = "Extraterritorial organisations")

# Birthplace: "ITAL" or the code Italy uses for each foreign country ("codice catastale", Z...).
# EU members (as INAIL groups them, including the former Czechoslovakia Z105 and East Germany Z111);
# other countries are grouped by the first digit of the code.
eu_codes <- c("Z102", "Z103", "Z104", "Z105", "Z107", "Z109", "Z110", "Z111", "Z112", "Z115",
              "Z116", "Z120", "Z121", "Z126", "Z127", "Z128", "Z129", "Z131", "Z132", "Z134",
              "Z144", "Z145", "Z146", "Z149", "Z150", "Z155", "Z156", "Z211")
birth_area <- function(code) {
  case_when(
    code == "ITAL" ~ "Italy",
    code %in% eu_codes ~ "Other EU country",
    str_starts(code, "Z1") ~ "Europe outside the EU",
    str_starts(code, "Z2") ~ "Asia",
    str_starts(code, "Z3") ~ "Africa",
    str_starts(code, "Z[456]") ~ "Americas",
    str_starts(code, "Z7") ~ "Oceania",
    TRUE ~ "Unknown")
}
birth_group <- function(area) {
  case_when(area == "Italy" ~ "Italy", area == "Other EU country" ~ "Other EU country",
            area == "Unknown" ~ "Unknown", TRUE ~ "Outside the EU")
}
age_group <- function(age) {
  cut(age, c(-Inf, 14, 19, 24, 29, 34, 39, 44, 49, 54, 59, 64, 69, Inf),
      labels = c("Under 15", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49",
                 "50-54", "55-59", "60-64", "65-69", "70+"))
}
lookup <- function(x, table) unname(table[x])

# ---- Injuries --------------------------------------------------------------------------------

files <- list.files(raw_dir, pattern = "^DatiConCadenzaSemestraleInfortuni.*_csv\\.zip$",
                    full.names = TRUE)
if (!length(files)) stop("No injury files in ", raw_dir, ". Run fetch_data.R first.")
raw <- map_dfr(files, function(f) {
  tag <- str_match(basename(f), "Infortuni(.*)_csv\\.zip")[, 2]
  region <- if (tag %in% names(regions_labels)) regions_labels[[tag]] else NA_character_
  read_inail(f) |> mutate(region = region)
})

injuries <- raw |>
  transmute(
    case_id = IdentificativoCaso,
    accident_date = ymd(DataAccadimento),
    year = as.integer(format(accident_date, "%Y")),
    report_date = ymd(DataProtocollo),
    decision_date = ymd(DataDefinizione),
    death_date = ymd(DataMorte),
    region,
    macro_area = lookup(region, macro_area_labels),
    province_code = LuogoAccadimento,
    sex = recode(Genere, M = "Male", F = "Female"),
    age = na_if(as.integer(Eta), -1L),
    age_group = as.character(age_group(age)),
    birthplace_code = LuogoNascita,
    birth_area = birth_area(LuogoNascita),
    birth_group = birth_group(birth_area),
    commuting = ModalitaAccadimento == "S",
    transport_involved = ConSenzaMezzoTrasporto == "S",
    decision = lookup(DefinizioneAmministrativa, decision_labels),
    fatal = !is.na(DefinizioneAmministrativaEsitoMortale),
    fatal_decision = lookup(DefinizioneAmministrativaEsitoMortale, decision_labels),
    fatal_rejection_reason = if_else(DefinizioneAmministrativaEsitoMortale %in% "N",
                                     lookup(DecisioneIstruttoriaEsitoMortale, fatal_rejection_labels),
                                     NA_character_),
    compensation = lookup(Indennizzo, compensation_labels),
    impairment_pct = na_if(as.integer(GradoMenomazione), -1L),
    days_compensated = as.integer(GiorniIndennizzati),
    ateco_division = SettoreAttivitaEconomica,
    ateco_section = str_sub(SettoreAttivitaEconomica, 1, 1),
    sector = lookup(ateco_section, ateco_sections_labels),
    insurance_scheme = lookup(Gestione, insurance_scheme_labels),
    tariff_scheme = lookup(GestioneTariffaria, tariff_scheme_labels),
    tariff_group = lookup(GrandeGruppoTariffario, tariff_group_labels),
    worker_id = IdentificativoInfortunato,
    employer_id = IdentificativoDatoreLavoro,
    insurance_position_id = PosizioneAssicurativaTerritoriale
  ) |>
  arrange(accident_date, case_id)

# ---- Checks against INAIL's national tables (Tabella B1 and B4.1.4) --------------------------

stopifnot(!anyDuplicated(injuries$case_id), !anyNA(injuries$year), !anyNA(injuries$region))
by_year <- count(injuries, year)
message("Reports by year of accident:\n", paste(by_year$year, by_year$n, collapse = "\n"))
unlabelled <- injuries |>
  summarise(decision = sum(is.na(decision)), compensation = sum(is.na(compensation)),
            scheme = sum(is.na(insurance_scheme)),
            fatal_reason = sum(fatal_decision %in% "Rejected" & is.na(fatal_rejection_reason)))
message("Rows without a label: ", paste(names(unlabelled), unlabelled, collapse = ", "))

# The yearly files leave out columns that are easy to derive (year, macro-area, age group, birth
# group, ATECO section letter) and INAIL's insurance position code, to keep the repository small.
# The summary table and the notebooks add them back.
derived <- c("year", "macro_area", "age_group", "birth_group", "ateco_section",
             "insurance_position_id")
for (y in sort(unique(injuries$year))) {
  write_csv(select(filter(injuries, year == y), -all_of(derived)),
            file.path(tidy_dir, sprintf("injuries_%d.csv.gz", y)), na = "")
}

summary_tbl <- injuries |>
  group_by(year, macro_area, region, sector, insurance_scheme, sex, age_group, birth_group,
           commuting) |>
  summarise(reports = n(),
            accepted = sum(decision == "Accepted", na.rm = TRUE),
            fatal_reports = sum(fatal),
            fatal_accepted = sum(fatal_decision %in% "Accepted"),
            days_compensated = sum(days_compensated, na.rm = TRUE),
            .groups = "drop")
write_csv(summary_tbl, file.path(tidy_dir, "injuries_summary.csv.gz"), na = "")

# ---- Occupational diseases -------------------------------------------------------------------

icd_chapter <- function(code) {
  l <- str_sub(code, 1, 1)
  n <- suppressWarnings(as.integer(str_sub(code, 2, 3)))
  case_when(
    is.na(code) ~ NA_character_,
    l %in% c("A", "B") ~ "Infectious and parasitic diseases",
    l == "C" | (l == "D" & n <= 48) ~ "Neoplasms (cancers)",
    l == "D" ~ "Diseases of the blood",
    l == "E" ~ "Endocrine and metabolic diseases",
    l == "F" ~ "Mental and behavioural disorders",
    l == "G" ~ "Diseases of the nervous system (e.g. carpal tunnel syndrome)",
    l == "H" & n <= 59 ~ "Diseases of the eye",
    l == "H" ~ "Diseases of the ear (e.g. noise-induced hearing loss)",
    l == "I" ~ "Diseases of the circulatory system",
    l == "J" ~ "Diseases of the respiratory system",
    l == "K" ~ "Diseases of the digestive system",
    l == "L" ~ "Diseases of the skin",
    l == "M" ~ "Musculoskeletal disorders",
    l == "N" ~ "Diseases of the genitourinary system",
    l %in% c("S", "T") ~ "Injury and poisoning",
    TRUE ~ "Other")
}

disease_file <- file.path(raw_dir, "DatiSemestraliMalattieProfessionaliDataProtItalia.csv")
diseases <- read_inail(disease_file) |>
  transmute(
    case_id = IdentificativoCaso,
    report_date = ymd(DataProtocollo),
    year = as.integer(format(report_date, "%Y")),
    decision_date = ymd(DataDefinizione),
    death_date = ymd(DataMorte),
    inail_office_province = SedeInailCompetente,
    sex = recode(Genere, M = "Male", F = "Female"),
    birthplace_code = LuogoNascita,
    birth_area = birth_area(LuogoNascita),
    icd10_reported = ICD10denunciato,
    icd10_confirmed = ICD10accertato,
    icd10_chapter = icd_chapter(coalesce(ICD10accertato, ICD10denunciato)),
    causal_agent_code = AgenteCausale,
    scheduled_disease = QualificazioneLegge == "S",
    asbestos_related = MalattiaAsbestoCorrelata == "S",
    decision = lookup(DefinizioneAmministrativaCaso, decision_labels),
    worker_decision = lookup(DefinizioneAmministrativaLavoratore, decision_labels),
    fatal_decision = lookup(DefinizioneAmministrativaEsitoMortale, decision_labels),
    compensation = lookup(Indennizzo, compensation_labels),
    impairment_pct_worker = na_if(as.integer(GradoMenomazioneLavoratore), -1L),
    impairment_pct_case = na_if(as.integer(GradoMenomazioneCaso), -1L),
    days_compensated = as.integer(GiorniIndennizzati),
    insurance_scheme = lookup(Gestione, insurance_scheme_labels),
    sector_group_code = SettoreCorrelatoMalattia,
    sub_sector_code = SubSettoreCorrelatoMalattia,
    worker_id = IdentificativoLavoratore
  ) |>
  arrange(report_date, case_id)
write_csv(diseases, file.path(tidy_dir, "occupational_diseases.csv.gz"), na = "")

disease_deaths <- read_inail(file.path(raw_dir, "DatiSemestraliMalattieProfessionaliDataDecItalia.csv")) |>
  transmute(case_id = IdentificativoCaso, death_date = ymd(DataMorte),
            year = as.integer(format(death_date, "%Y")), age_at_death = as.integer(EtaMorte),
            sex = recode(Genere, M = "Male", F = "Female"), birth_area = birth_area(LuogoNascita),
            silicosis_or_asbestosis = MalattiaSilicosiAsbestosi == "S",
            insurance_scheme = lookup(Gestione, insurance_scheme_labels), worker_id = IdentificativoLavoratore) |>
  arrange(death_date)
write_csv(disease_deaths, file.path(tidy_dir, "disease_deaths.csv.gz"), na = "")

for (f in list.files(tidy_dir, full.names = TRUE))
  message(sprintf("%-32s %6.1f MB", basename(f), file.size(f) / 1e6))

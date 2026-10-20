# Build tidy tables, with English labels, from Assurance Maladie's occupational risk datasets.
#
# Usage (from a terminal):   Rscript scripts/build_dataset.R
# Usage (from RStudio):      open this file and click "Source"
#
# Reads the CSV files downloaded by scripts/fetch_data.R and writes, to data/tidy/:
#   sectors.csv                   the sector codes (NAF sections and subclasses) with French and
#                                 English names
#   claims_by_sector.csv.gz       claims, employees, frequency index, deaths, days off work and
#                                 permanent incapacities by year, risk and sector
#   accident_causes.csv.gz        shares of work and commuting accidents by cause and sector
#   occupational_diseases.csv.gz  occupational diseases by group, ICD-10 chapter and sector
#   msd.csv.gz                    musculoskeletal disorders by compensation table and sector
#   msd_body_parts.csv.gz         shares of musculoskeletal disorders by body part, sex and sector
#   psychological_disorders.csv   recognised psychological disorders by sector
#   companies_by_size.csv.gz      companies and employees by company size and sector
#   regions.csv                   claims, employees and frequency index by region
#   costs.csv                     costs by risk and type of benefit
# French labels are translated with scripts/labels_fr_en.csv and scripts/naf5_en.csv.

library(readr)
library(dplyr)
library(tidyr)

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

read_raw <- function(name) {
  read_delim(file.path(raw_dir, paste0(name, ".csv")), delim = ";",
             col_types = cols(.default = col_character()), na = character(), progress = FALSE)
}

labels <- read_csv(file.path(script_dir, "labels_fr_en.csv"), show_col_types = FALSE)
translate <- function(x, variable) {
  lab <- labels[labels$variable == variable, ]
  out <- lab$english[match(x, lab$french)]
  unmatched <- unique(x[is.na(out) & !is.na(x) & x != ""])
  if (length(unmatched)) stop("No English label for ", variable, ": ",
                              paste(unmatched, collapse = " | "))
  out
}
# Numbers: "NS" (confidential) and "NC" (not computed) become missing
num <- function(x) suppressWarnings(as.numeric(x))
year_of <- function(x) as.integer(substr(x, 1, 4))

# Sector columns: NAF section (naf1) and subclass (naf5); "TOUS" marks totals
sector_cols <- function(d) {
  d |> mutate(year = year_of(annee),
              naf1 = code_naf1,
              naf5 = if_else(code_naf5 %in% c("TOUS", "xxxxx"), NA_character_, code_naf5),
              level = case_when(code_naf1 == "TOUS" ~ "All sectors",
                                code_naf5 == "TOUS" ~ "Section",
                                TRUE ~ "Subclass"))
}

# ---- Sectors -----------------------------------------------------------------------------------
main <- read_raw("sinistralite-par-secteur-d-activite-concerne-naf-1")
naf5_en <- read_csv(file.path(script_dir, "naf5_en.csv"), show_col_types = FALSE)
sectors <- main |>
  distinct(code_naf1, code_naf5, libelle_naf5) |>
  sector_cols() |>
  mutate(name_fr = libelle_naf5,
         name_en = case_when(level == "Subclass" & !is.na(naf5) ~
                               naf5_en$name_en[match(naf5, naf5_en$naf5)],
                             TRUE ~ translate(naf1, "naf1")),
         nace_class = if_else(!is.na(naf5),
                              paste0(substr(naf5, 1, 2), ".", substr(naf5, 3, 4)), NA_character_),
         section_name = translate(naf1, "naf1")) |>
  select(level, naf1, section_name, naf5, nace_class, name_en, name_fr) |>
  arrange(factor(level, c("All sectors", "Section", "Subclass")), naf1, naf5)
if (any(is.na(sectors$name_en))) stop("Missing English names for some sectors")
write_csv(sectors, file.path(tidy_dir, "sectors.csv"), na = "")

# ---- Claims by sector ----------------------------------------------------------------------------
keys <- c("year", "risk", "level", "naf1", "naf5")
claims <- main |>
  sector_cols() |>
  transmute(year, risk = translate(risque, "risk"), level, naf1, naf5,
            claims = num(nb_sinistres_int), employees = num(nb_salaries_int),
            frequency_index = num(indice_frequence_int),
            claims_note = case_when(nb_sinistres == "NS" ~ "Confidential",
                                    nb_sinistres == "NC" ~ "Not available", TRUE ~ ""))
extra <- function(name, from, to) {
  read_raw(name) |>
    sector_cols() |>
    transmute(year, risk = translate(risque, "risk"), level, naf1, naf5,
              !!to := num(.data[[from]]))
}
claims <- claims |>
  left_join(extra("deces-par-secteur-d-activite-naf-1-et-naf-5", "nb_deces_int", "deaths"),
            by = keys) |>
  left_join(extra("arrets-de-travail-par-secteur-d-activite-naf-1-et-naf-5",
                  "nb_jours_arret_travail", "days_off_work"), by = keys) |>
  left_join(extra("incapacites-permanentes-par-secteur-d-activite-naf-1-et-naf-5",
                  "nb_incapacites_permanentes_int", "permanent_incapacities"), by = keys) |>
  arrange(year, risk, factor(level, c("All sectors", "Section", "Subclass")), naf1, naf5)
write_csv(claims, file.path(tidy_dir, "claims_by_sector.csv.gz"), na = "")

# ---- Accident causes -----------------------------------------------------------------------------
work_causes <- read_raw("causes-des-accidents-du-travail-par-secteur-d-activite-naf-1-et-naf-5") |>
  sector_cols() |>
  transmute(year, risk = "Work accidents", level, naf1, naf5,
            cause = translate(libelle_cause_at, "work_accident_cause"), vehicle = NA_character_,
            share_pct = num(part_cause_at_int))
commuting_causes <- read_raw(
  "causes-des-accidents-de-trajet-par-secteur-d-activite-naf-1-et-naf-5") |>
  sector_cols() |>
  transmute(year, risk = "Commuting accidents", level, naf1, naf5,
            cause = translate(libelle_cause_tr, "commuting_cause"),
            vehicle = if_else(libelle_type_vehicule == "", NA_character_,
                              translate(libelle_type_vehicule, "vehicle")),
            share_pct = num(part_cause_tr))
write_csv(bind_rows(work_causes, commuting_causes),
          file.path(tidy_dir, "accident_causes.csv.gz"), na = "")

# ---- Occupational diseases -----------------------------------------------------------------------
diseases <- read_raw("maladies-professionnelles-par-groupe-et-secteur-d-activite-naf-1-et-naf-5") |>
  sector_cols() |>
  transmute(year, level, naf1, naf5,
            disease_group = translate(libelle_groupe_mp, "disease_group"),
            icd10_chapter_code = na_if(code_chapitre_cim10, ""),
            icd10_chapter = if_else(libelle_chapitre_cim10 == "", NA_character_,
                                    translate(libelle_chapitre_cim10, "icd10_chapter")),
            cases = num(nb_mp))
write_csv(diseases, file.path(tidy_dir, "occupational_diseases.csv.gz"), na = "")

msd <- read_raw("troubles-musculosquelettiques-par-tableau-et-secteur-d-activite-naf-1-et-naf-5") |>
  sector_cols() |>
  transmute(year, level, naf1, naf5, table_number = na_if(num_tableau, ""),
            table_name = translate(libelle_tableau, "msd_table"),
            cases = num(nb_tms_int), frequency_index = num(indice_frequence_tms_int))
write_csv(msd, file.path(tidy_dir, "msd.csv.gz"), na = "")

msd_body <- read_raw(
  "troubles-musculosquelettiques-par-partie-du-corps-sexe-et-secteur-d-activite-naf-1-et-naf-5") |>
  sector_cols() |>
  transmute(year, level, naf1, naf5, sex = translate(sexe, "sex"),
            body_part = translate(partie_corps, "body_part"), share_pct = num(part_tms_int))
write_csv(msd_body, file.path(tidy_dir, "msd_body_parts.csv.gz"), na = "")

psych <- read_raw("maladies-professionnelles-psychiques-par-secteur-d-activite-naf-1-et-naf-5") |>
  sector_cols() |>
  transmute(year, level, naf1, naf5, cases = num(nb_mp_psy_int))
write_csv(psych, file.path(tidy_dir, "psychological_disorders.csv"), na = "")

# ---- Companies by size ---------------------------------------------------------------------------
sizes <- read_raw(
  "entreprises-et-salaries-par-taille-d-entreprise-et-secteur-d-activite-naf-1-et-naf-5") |>
  sector_cols() |>
  transmute(year, level, naf1, naf5, company_size = translate(taille_entreprise, "company_size"),
            companies = num(nb_entreprises_int), employees = num(nb_salaries_int))
write_csv(sizes, file.path(tidy_dir, "companies_by_size.csv.gz"), na = "")

# ---- Regions and costs ---------------------------------------------------------------------------
regions <- read_raw("sinistralite-par-region-administrative") |>
  transmute(year = year_of(annee), region_code = code_region_admin,
            region = if_else(libelle_region_admin == "FRANCE", "France", libelle_region_admin),
            risk = translate(risque, "risk"), claims = num(nb_sinistres_int),
            employees = num(nb_salaries), frequency_index = num(indice_frequence_int))
write_csv(regions, file.path(tidy_dir, "regions.csv"), na = "")

costs <- read_raw("depenses-par-poste") |>
  transmute(year = year_of(annee), risk = translate(risque, "risk"),
            cost_item = translate(poste_depenses, "cost_item"),
            amount_eur = num(montant_depenses))
write_csv(costs, file.path(tidy_dir, "costs.csv"), na = "")

# ---- Checks ----------------------------------------------------------------------------------------
# The sections should add up to the national total (apart from confidential cells)
check <- claims |>
  filter(level != "Subclass", !is.na(claims)) |>
  group_by(year, risk) |>
  summarise(total = sum(claims[level == "All sectors"]),
            sections = sum(claims[level == "Section"]), .groups = "drop") |>
  mutate(gap = total - sections)
message("Largest gap between the national total and the sum of sections: ",
        max(abs(check$gap)), " claims")
for (f in list.files(tidy_dir, full.names = TRUE)) {
  message(sprintf("%-32s %7.2f MB", basename(f), file.size(f) / 1e6))
}

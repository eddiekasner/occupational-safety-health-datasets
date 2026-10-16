# Download tables of work-related notifications in Brazil's SINAN from DATASUS TabNet into
# data/raw/tabnet/.
#
# Usage (from a terminal):   Rscript scripts/fetch_data.R
# Usage (from RStudio):      open this file and click "Source"
#
# Needs the R packages "curl" and "readr" (install.packages(c("curl", "readr"))).
#
# SINAN's case-level files are only on DATASUS's FTP server, which many networks (and, reportedly,
# connections from outside Brazil) cannot reach. TabNet, DATASUS's web tabulation tool, gives the
# same notifications as two-way tables. This script asks TabNet for about 180 tables:
#   - serious work accidents (acidente de trabalho grave): each variable by year, and selected
#     pairs of variables for each year
#   - seven work-related diseases and exposures: by year, state, sex, age and employment status
# Each table is saved as its own CSV, so the script can be stopped and rerun; files already
# downloaded are skipped. TabNet is slow and often drops connections; the script retries
# automatically, and skips a table that keeps failing (run the script again to fetch it). A full
# run takes about an hour. Next step: run scripts/build_dataset.R.

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(file_arg)) {
  dirname(normalizePath(sub("^--file=", "", file_arg)))
} else if (!is.null(sys.frame(1)$ofile)) {
  dirname(normalizePath(sys.frame(1)$ofile))
} else {
  getwd()
}
source(file.path(script_dir, "tabnet.R"))
out_dir <- file.path(script_dir, "..", "data", "raw", "tabnet")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

years <- 2006:2025   # 2026 is incomplete
failed <- 0

save_table <- function(form, row, col = NULL, year = NULL, name) {
  dest <- file.path(out_dir, paste0(name, ".csv"))
  if (file.exists(dest)) return(invisible())
  files <- form$files$file[form$files$year %in% (if (is.null(year)) years else year)]
  message("  ", name)
  x <- tryCatch(tabnet_query(form, tabnet_var(form, row),
                             if (is.null(col)) not_active else tabnet_var(form, col), files = files),
                error = function(e) e)
  # If TabNet keeps failing, skip this table for now; rerun the script to fetch what is missing
  if (inherits(x, "error")) {
    message("    failed (", conditionMessage(x), "); rerun the script later")
    failed <<- failed + 1
    return(invisible())
  }
  if (is.null(x)) x <- data.frame(row = character(), col = character(), n = numeric())
  names(x) <- c("row", "col", "n")
  if (!is.null(year)) x$year <- year
  readr::write_csv(x, dest)
}

# ---- Serious work accidents ------------------------------------------------------------------

message("Serious work accidents")
acgr <- tabnet_form("sinannet/cnv/acgrbr.def")

# Each variable by year of notification
by_year <- c("Sit._Merc._Trab.", "Sexo", "Fx_Etaria_(13)", "Raca", "Escolar_SinanNET", "UF_Acid",
             "Ocupacao", "CNAE-Ativ._Econ.", "Tipo_acidente", "Evolucao_caso", "Emitida_CAT",
             "Parte_ating._1", "causa_acidente", "Empresa_Terceirizada",
             "Hora_apos_jornada", "atend._medico")
for (v in by_year) save_table(acgr, v, "Ano_da_Notific", name = paste0("acgr__", fold(v), "__year"))

# Pairs of variables, one table per year
pairs <- list(c("Sit._Merc._Trab.", "Evolucao_caso"), c("Sit._Merc._Trab.", "Emitida_CAT"),
              c("Sit._Merc._Trab.", "Sexo"), c("UF_Acid", "Evolucao_caso"),
              c("Tipo_acidente", "Evolucao_caso"), c("Sexo", "Evolucao_caso"))
for (p in pairs) for (y in years) {
  save_table(acgr, p[1], p[2], year = y, name = paste0("acgr__", fold(p[1]), "__", fold(p[2]), "__", y))
}

# Large tables for all years together
save_table(acgr, "Ocupacao", "Evolucao_caso", name = "acgr__Ocupacao__Evolucao_caso__all")
save_table(acgr, "CNAE-Ativ._Econ.", "Evolucao_caso", name = "acgr__CNAE-Ativ._Econ.__Evolucao_caso__all")

# ---- Other work-related conditions -----------------------------------------------------------

other <- c(acbi = "acbibr", lerdor = "lerdorbr", pair = "pairbr", derm = "dermbr",
           pneu = "pneubr", canc = "cancbr", transmental = "transmentalbr")
for (k in names(other)) {
  message(k)
  form <- tabnet_form(paste0("sinannet/cnv/", other[[k]], ".def"))
  for (v in c("UF_de_notificacao", "Sexo", "Fx_Etaria_(13)", "Sit._Merc._Trab.", "Ocupacao")) {
    if (!v %in% fold(form$variables)) next
    save_table(form, v, "Ano_da_Notific", name = paste0(k, "__", fold(v), "__year"))
  }
}
if (failed) {
  message(failed, " tables could not be downloaded. Run this script again to fetch them.")
} else {
  message("Done. Tables are in ", normalizePath(out_dir), ". Next: run scripts/build_dataset.R")
}

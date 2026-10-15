# Functions to query DATASUS TabNet (https://tabnet.datasus.gov.br), which tabulates SINAN and
# other Brazilian health data, from R. Used by fetch_data.R.
#
# TabNet is a web form: you choose a row variable ("Linha"), a column variable ("Coluna"), the
# years ("Arquivos") and optional filters, and it returns a two-way table. tabnet_query() submits
# the form and returns the table in long format.

library(curl)

tabnet_base <- "https://tabnet.datasus.gov.br/cgi/"
# "No column" in TabNet (written with Unicode escapes so the script works in any locale)
not_active <- "--N\u00e3o-Ativa--"

# The form and its option values are in Latin-1; field names contain accented letters
latin1_encode <- function(x) {
  bytes <- iconv(x, from = "UTF-8", to = "latin1", toRaw = TRUE)[[1]]
  safe <- bytes %in% charToRaw(paste0(c(LETTERS, letters, 0:9, "-", "_", ".", "~"), collapse = ""))
  paste0(ifelse(safe, rawToChar(bytes, multiple = TRUE), paste0("%", toupper(as.character(bytes)))),
         collapse = "")
}

# TabNet's connection is unreliable at times: retry a few times before giving up
fetch_with_retry <- function(url, handle = new_handle(), tries = 10) {
  for (i in seq_len(tries)) {
    res <- tryCatch(curl_fetch_memory(url, handle = handle), error = function(e) NULL)
    if (!is.null(res) && res$status_code == 200) return(res)
    Sys.sleep(min(2^i, 30))
  }
  stop("TabNet did not respond after ", tries, " tries: ", url)
}

# Read a form (.def) once: the filter fields, and the years available
tabnet_form <- function(def) {
  res <- fetch_with_retry(paste0(tabnet_base, "deftohtm.exe?", def))
  html <- iconv(rawToChar(res$content), from = "latin1", to = "UTF-8")
  filters <- unique(regmatches(html, gregexpr('NAME="S[^"]+"', html))[[1]])
  filters <- sub('^NAME="(.*)"$', "\\1", filters)
  arq <- regmatches(html, regexpr('NAME="Arquivos".*?</SELECT>', html))
  files <- regmatches(arq, gregexpr('VALUE="[^"]+"[^>]*>[^<\r\n]+', arq))[[1]]
  files <- data.frame(file = sub('VALUE="([^"]+)".*', "\\1", files),
                      year = as.integer(trimws(sub(".*>", "", files))))
  # Variables that can be used as rows or columns
  linha <- regmatches(html, regexpr('NAME="Linha".*?</SELECT>', html))
  variables <- sub('VALUE="([^"]+)"', "\\1",
                   regmatches(linha, gregexpr('VALUE="[^"]+"', linha))[[1]])
  list(def = def, filters = filters, files = files, variables = variables)
}

# Find a variable by an accent-free name, for example "Evolucao_caso" for "Evolu\u00e7\u00e3o_caso"
fold <- function(x) sub("_+$", "", stringi::stri_trans_general(x, "Latin-ASCII"))
tabnet_var <- function(form, key) {
  hit <- form$variables[fold(form$variables) == key]
  if (length(hit) != 1) stop("Variable ", key, " not found in ", form$def)
  hit
}

# Decode the HTML entities TabNet uses for accented letters (for example "&atilde;" for "a" with
# a tilde)
html_unescape <- function(x) {
  marks <- c(acute = "\u0301", grave = "\u0300", tilde = "\u0303", circ = "\u0302",
             uml = "\u0308", cedil = "\u0327")
  for (m in names(marks)) {
    x <- gsub(paste0("&([A-Za-z])", m, ";"), paste0("\\1", marks[[m]]), x)
  }
  x <- gsub("&amp;", "&", gsub("&nbsp;", " ", x, fixed = TRUE), fixed = TRUE)
  x <- gsub("&ordm;", "\u00ba", gsub("&ordf;", "\u00aa", x, fixed = TRUE), fixed = TRUE)
  # Combine each letter and its accent mark into one character
  stringi::stri_trans_nfc(x)
}

# Parse the "prn" output: a <PRE> block of semicolon-separated values
parse_prn <- function(html, row_name, col_name) {
  pre <- regmatches(html, regexpr("(?s)<PRE>.*?</PRE>", html, perl = TRUE))
  if (!length(pre)) {
    if (grepl("Nenhum registro selecionado", html, ignore.case = TRUE)) return(NULL)
    stop("Unexpected TabNet response")
  }
  lines <- strsplit(gsub("</?PRE>", "", pre), "\r?\n")[[1]]
  lines <- html_unescape(lines[grepl(";", lines)])
  cells <- lapply(strsplit(lines, ";"), function(x) gsub('^"|"$', "", trimws(x)))
  header <- cells[[1]]
  # Keep only the table rows (notes below the table can also contain semicolons)
  cells <- cells[-1]
  cells <- cells[lengths(cells) == length(header)]
  body <- do.call(rbind, cells)
  colnames(body) <- header
  body <- as.data.frame(body, stringsAsFactors = FALSE)
  long <- do.call(rbind, lapply(header[-1], function(h)
    data.frame(row = body[[1]], col = h, n = body[[h]], stringsAsFactors = FALSE)))
  long$n <- suppressWarnings(as.numeric(gsub("\\.", "", ifelse(long$n == "-", "0", long$n))))
  long <- long[long$row != "Total" & long$col != "Total", ]
  names(long) <- c(row_name, col_name, "n")
  long
}

# One two-way table. `filters` is a named list, for example list(SSexo = "2"), using the option
# values from the form.
tabnet_query <- function(form, linha, coluna = not_active, files = form$files$file,
                         filters = list(), increment = "Notifica\u00e7\u00f5es") {
  fields <- c(list(Linha = linha, Coluna = coluna, Incremento = increment),
              setNames(as.list(files), rep("Arquivos", length(files))))
  # Every filter must be sent; "TODAS_AS_CATEGORIAS__" means no filter
  filter_fields <- setNames(lapply(form$filters, function(f)
    if (f %in% names(filters)) filters[[f]] else "TODAS_AS_CATEGORIAS__"), form$filters)
  fields <- c(fields, filter_fields, list(formato = "prn", mostre = "Mostra"))
  body <- paste(vapply(seq_along(fields), function(i)
    paste0(latin1_encode(names(fields)[i]), "=", latin1_encode(fields[[i]])), ""), collapse = "&")
  h <- new_handle(post = TRUE, postfields = body)
  handle_setheaders(h, "Content-Type" = "application/x-www-form-urlencoded")
  res <- fetch_with_retry(paste0(tabnet_base, "tabcgi.exe?", form$def), handle = h)
  html <- iconv(rawToChar(res$content), from = "latin1", to = "UTF-8")
  parse_prn(html, linha, if (coluna == not_active) "total" else coluna)
}

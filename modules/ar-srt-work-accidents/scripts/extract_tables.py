"""Extract the historical series of work accident statistics published by Argentina's
Superintendencia de Riesgos del Trabajo (SRT).

SRT publishes its historical series as Excel workbooks ("Serie historica de accidentabilidad
laboral"), downloaded by scripts/fetch_data.R. Each workbook has an index sheet and one sheet per
table ("Cuadro"). Every table has a title that names the measure, the population covered and the
breakdown, a header row of years, and one row per category (sector, province, age group, size of
employer or 3-digit sector code), with sections for each sex in some tables.

This script reads them all and writes, to data/tidy/:
  national.csv            cases, deaths, rates and mean days lost by sector (1 digit), 1996-2025
  by_jurisdiction.csv     incidence and death rates by province, overall and by sector
  by_sex_age.csv          incidence, death rates and lethality by sex and age group
  by_sex_sector.csv       the same by sex and sector (1 digit)
  by_size.csv             incidence and death rates by number of workers of the employer
  by_sector_3digit.csv    incidence and death rates by sector (3 digits), overall and by sex
Spanish labels are kept, and English ones added from scripts/labels_es_en.csv.

Needs openpyxl (pip install openpyxl). Written in Python, like the extraction scripts of other
modules; the outputs are committed, so you only need to run this to update them.

Usage (from the module folder):  python scripts/extract_tables.py
"""
import csv
import re
import unicodedata
from pathlib import Path

import openpyxl

module = Path(__file__).resolve().parent.parent
raw = module / "data" / "raw"
tidy = module / "data" / "tidy"
tidy.mkdir(exist_ok=True)


def clean(s):
    return re.sub(r"\s+", " ", s).strip() if isinstance(s, str) else s


def key(s):
    """Label key for matching: no accents, footnote stars, final periods or case."""
    s = unicodedata.normalize("NFKD", clean(str(s))).encode("ascii", "ignore").decode()
    return re.sub(r"\s+", " ", s.replace("*", "")).strip(" .").lower()


def year_of(v):
    """A header cell that is a year (some are written "1996*")."""
    if isinstance(v, int) and 1990 < v < 2100:
        return v
    if isinstance(v, str) and re.fullmatch(r"(19|20)\d\d\*?", v.strip()):
        return int(v.strip()[:4])
    return None


def read_tables(path):
    """Yield (sheet, title, rows) for each table of a workbook. Each row is a dict with the
    label, its indentation, the 3-digit code (if any) and {year: value}."""
    wb = openpyxl.load_workbook(path, data_only=True)
    for ws in wb.worksheets[1:]:
        if re.match(r"\d{4}_[MV]_", ws.title):
            continue  # one-year detail sheets (2012-2018 by sex), repeated in the series tables
        grid = [list(r) for r in ws.iter_rows(values_only=True)]
        title = next((clean(c) for r in grid[:8] for c in r
                      if isinstance(c, str) and c.strip().startswith("Cuadro")), "")
        # Some titles continue on the next line ("Periodo 2011-2018")
        head = next((i for i, r in enumerate(grid[:15]) if any(year_of(c) for c in r)), None)
        if head is None:
            print(f"  skipped {path.name} / {ws.title}: no row of years")
            continue
        years = {j: year_of(c) for j, c in enumerate(grid[head]) if year_of(c) is not None}
        label_cols = [j for j in range(min(years)) if any(isinstance(r[j], (str, int)) for r in grid[head + 1:head + 5])]
        rows = []
        for r in grid[head + 1:]:
            cells = [r[j] for j in label_cols]
            text = [c for c in cells if isinstance(c, str) and c.strip()]
            values = {y: r[j] for j, y in years.items() if j < len(r) and r[j] not in (None, "")}
            if not text and not values and not any(isinstance(c, (int, float)) for c in cells):
                if rows:
                    continue
            first = text[0] if text else ""
            if re.match(r"^\s*(Incluye|Excluye|Fuente|Nota|Fecha|La serie|En noviembre|\*|\(\d|\d\)|"
                        r"Unidades productivas:|Casas particulares:|.ndice de [^(]*:)", first):
                break
            if not text and not values:
                continue
            code = cells[0] if len(cells) > 1 and re.fullmatch(r"\d{2,4}", str(cells[0]).strip()) else None
            # Sizes of employer 1 and 2 are written as numbers
            label = text[-1] if text else (str(cells[0]) if cells and isinstance(cells[0], int) else "")
            rows.append({"label": clean(label), "indent": len(label) - len(label.lstrip()),
                         "code": str(code).strip() if code not in (None, "") else "",
                         "values": values})
        yield ws.title.strip(), title, rows


# ---- What each table measures, from its title ---------------------------------------------------
def describe(title):
    t = key(title)
    d = {"case_type": "Work accidents and occupational diseases"
         if re.search(r"at y ep|atep|at/ep", t) else "All cases"}
    if "duracion media" in t:
        d["measure"] = "Mean days lost"
    elif "letalidad" in t:
        d["measure"] = "Lethality per 100,000 cases"
    elif "indice" in t and re.search(r"mortales|fallecid", t):
        d["measure"] = "Deaths per million workers"
    elif "indice" in t:
        d["measure"] = "Cases per 1,000 workers"
    elif re.search(r"fallecid", t):
        d["measure"] = "Deaths"
    elif re.search(r"con (dias|uno|1) .*baja|secuelas", t):
        d["measure"] = "Cases with days lost or disability"
    elif "casos notificados" in t:
        d["measure"] = "Cases"
    else:
        raise ValueError("unknown measure: " + title)
    d["sex"] = "Female" if re.search(r"\bmujeres\b|fallecidas\b", t) and "fallecidas y" not in t \
        else "Male" if re.search(r"\bvarones\b", t) else "Total"
    if "unidades productivas, casas particulares" in t:
        d["scope"] = None  # in the rows
    elif "casas particulares" in t:
        d["scope"] = "Domestic workers"
    elif "total sistema" in t:
        d["scope"] = "Total system"
    else:
        d["scope"] = "Workplaces"
    d["classification"] = "CIIU Rev. 4" if "revision 4" in t else None
    return d


SCOPES = [("total unidades productivas", "Workplaces"), ("total casas particulares", "Domestic workers"),
          ("casas particulares", "Domestic workers"), ("total sistema", "Total system")]


def scope_row(label):
    """Rows that are totals for a population: all workplaces, domestic workers, or the system."""
    k = key(label)
    return next((v for p, v in SCOPES if k.startswith(p)), None)


def classification(path, d):
    """Sector classification: SRT's groups of CIIU Revision 2 to 2018, CIIU Revision 4 from 2019."""
    if d["classification"]:
        return d["classification"]
    return "CIIU Rev. 4" if "Rev4" in path.name or "2019-2024" in path.name else "CIIU Rev. 2"


def tables(pattern):
    for f in sorted(raw.glob(pattern)):
        for sheet, title, rows in read_tables(f):
            yield f, sheet, title, describe(title), rows


def records(d, rows, row_name, extra):
    """Long records from a table whose rows are categories (sectors, provinces, sizes...),
    possibly with total rows for each population (scope)."""
    out = []
    for r in rows:
        if not r["values"] or key(r["label"]) == "proporcion de at y ep":
            continue  # (the share of all cases that are AT and EP, which can be computed)
        sc = scope_row(r["label"])
        label = r["label"].replace("*", "").strip()
        if key(label) == "total":
            sc, label = d["scope"] or "Total system", "Total"
        for year, v in r["values"].items():
            if not isinstance(v, (int, float)):
                continue  # "-": not available
            rec = dict(extra)
            rec.update({"year": year, "case_type": d["case_type"], "measure": d["measure"],
                        "scope": sc or d["scope"] or "Workplaces",
                        row_name: "Total" if sc else label, "value": v})
            out.append(rec)
    return out


def rev_of(rows):
    """Sector classification of a table from its years: SRT's groups of CIIU Revision 2 to 2018,
    CIIU Revision 4 from 2019."""
    years = [y for r in rows for y in r["values"]]
    return "CIIU Rev. 4" if years and min(years) >= 2019 else "CIIU Rev. 2"


# ---- National series --------------------------------------------------------------------------
national = []
for f, sheet, title, d, rows in tables("Serie_historica-Indicadores_*.xlsx"):
    national += records(d, rows, "sector_es", {"classification": rev_of(rows)})

# ---- By jurisdiction ----------------------------------------------------------------------------
jurisdiction = []
for f, sheet, title, d, rows in tables("[1-5]-*.xlsx"):
    if f.name.startswith("1-"):
        sector = "Total"
    else:
        # "... de Agricultura* segun provincia. Unidades productivas" (to 2018), or
        # "... segun jurisdiccion. Construccion. Periodo" (from 2019)
        m = (re.search(r"(?:del sector de|de) ([A-Z\u00c1\u00c9\u00cd\u00d3\u00da][^*]*?)\*? seg.n provincia", title) or
             re.search(r"seg.n (?:jurisdicci.n|provincia)\. (.+?)\. Per.odo", title))
        if not m:
            raise ValueError("no sector in title: " + title)
        sector = m.group(1).strip()
        if key(sector) == "unidades productivas":
            sector = "Total"
    for rec in records(d, rows, "jurisdiction_es", {"classification": rev_of(rows), "sector_es": sector}):
        jurisdiction.append(rec)


# ---- By sex, with age groups or sectors ----------------------------------------------------------
def sectioned(d, rows, row_name, extra):
    """Tables in blocks by sex: a row for each sex (whole system), a total row for workplaces,
    the categories (workplaces), and a row for domestic workers."""
    out, sex, scope = [], None, None
    for r in rows:
        k = key(r["label"])
        if k in ("mujeres", "varones", "total"):
            sex = {"mujeres": "Female", "varones": "Male", "total": "Total"}[k]
            scope, cat = "Total system", "Total"
        elif scope_row(r["label"]):
            scope, cat = scope_row(r["label"]), "Total"
        else:
            scope, cat = "Workplaces", r["label"].strip()
        if sex is None:
            raise ValueError("row before any sex: " + r["label"])
        for year, v in r["values"].items():
            if isinstance(v, (int, float)):
                rec = dict(extra)
                rec.update({"year": year, "sex": sex, "case_type": d["case_type"],
                            "measure": d["measure"], "scope": scope, row_name: cat, "value": v})
                out.append(rec)
        if scope == "Domestic workers":
            scope = None
    return out


sex_age, sex_sector = [], []
for f, sheet, title, d, rows in tables("Serie_historica- *ndices seg*n sexo y edad.xlsx"):
    sex_age += sectioned(d, rows, "age_group", {})
for f, sheet, title, d, rows in tables("Serie_historica- *ndices seg*n sexo y sector*.xlsx"):
    sex_sector += sectioned(d, rows, "sector_es", {"classification": rev_of(rows)})

# ---- By size of employer -------------------------------------------------------------------------
size = []
for f, sheet, title, d, rows in tables("Serie_historica- *ndices seg*n tama*o.xlsx"):
    size += records(d, rows, "workers_es", {})

# ---- By sector, 3 digits -------------------------------------------------------------------------
sector3 = []
for f, sheet, title, d, rows in tables("Indices*CIIU 3_*.xlsx"):
    for r in rows:
        if not r["values"]:
            continue
        sc = scope_row(r["label"])
        for year, v in r["values"].items():
            if isinstance(v, (int, float)):
                sector3.append({"year": year, "classification": rev_of(rows),
                                "code": "" if sc else r["code"].zfill(3),
                                "sector_es": "Total" if sc else r["label"].strip(),
                                "sex": d["sex"], "case_type": d["case_type"],
                                "measure": d["measure"], "scope": sc or "Workplaces", "value": v})

# ---- Labels --------------------------------------------------------------------------------------
here = Path(__file__).resolve().parent
labels, canonical = {}, {}
with open(here / "labels_es_en.csv", encoding="utf-8") as fh:
    for r in csv.DictReader(fh):
        labels[(r["variable"], key(r["spanish"]))] = r["english"]
        canonical.setdefault((r["variable"], key(r["spanish"])), r["spanish"])
with open(here / "labels_sector3_es_en.csv", encoding="utf-8") as fh:
    for r in csv.DictReader(fh):
        labels[("sector3", r["classification"], r["code"])] = r["english"]
missing = set()


def english(variable, spanish):
    e = labels.get((variable, key(spanish)))
    if e is None:
        missing.add((variable, spanish))
    return e or ""


def spanish(variable, text):
    """The Spanish label with accents, as in the labels file (some tables leave them out)."""
    return canonical.get((variable, key(text)), text)


def size_en(s):
    s = str(s)
    return "Total" if s == "Total" else s.replace(" a ", " to ").replace("M\u00e1s de ", "More than ")


for r in national + jurisdiction + sex_sector:
    r["sector_es"] = spanish("sector", r["sector_es"])
    r["sector"] = english("sector", r["sector_es"])
for r in jurisdiction:
    r["jurisdiction"] = english("jurisdiction", r["jurisdiction_es"])
for r in size:
    r["workers"] = size_en(r["workers_es"])
for r in sex_age:
    r["age_group"] = r["age_group"].replace(" y m\u00e1s", " and over")
for r in sector3:
    r["sector"] = "Total" if r["sector_es"] == "Total" else \
        labels.get(("sector3", r["classification"], r["code"]), "")
    if not r["sector"]:
        missing.add(("sector3", r["code"] + " " + r["sector_es"]))
if missing:
    raise ValueError("No English label for: " + "; ".join(f"{v}: {t}" for v, t in sorted(missing)))

# ---- Checks --------------------------------------------------------------------------------------
problems, notes = [], []


def close(a, b, tol):
    return abs(a - b) <= tol * max(1, abs(b))


def index(rows, *keys):
    out = {}
    for r in rows:
        out[tuple(r[k] for k in keys)] = r["value"]
    return out


# 1. National counts: sectors add up to all workplaces, and workplaces plus domestic workers to the
#    whole system
nat = index(national, "year", "case_type", "measure", "scope", "sector")
for (year, ct, m, sc, sector), v in nat.items():
    if m in ("Cases", "Cases with days lost or disability", "Deaths") and sc == "Workplaces" and sector == "Total":
        parts = sum(x for (y, c, mm, s2, sec), x in nat.items()
                    if (y, c, mm, s2) == (year, ct, m, "Workplaces") and sec != "Total")
        if not close(parts, v, 0.001):
            problems.append(f"{year} {ct} {m}: sectors {parts} vs total {v}")
        dom = nat.get((year, ct, m, "Domestic workers", "Total"), 0)
        system = nat.get((year, ct, m, "Total system", "Total"))
        if system is not None and not close(v + dom, system, 0.001):
            problems.append(f"{year} {ct} {m}: workplaces + domestic {v + dom} vs system {system}")
# 2. Rates: the national rate in the tables by province, sex and age, and 3-digit sector agrees with
#    the national series
for name, rows, extra in [("provinces", jurisdiction, {"sector": "Total", "jurisdiction": "Total"}),
                          ("3-digit sectors", sector3, {"sex": "Total", "sector": "Total"})]:
    compared = differ = 0
    for r in rows:
        if all(r.get(k) == v for k, v in extra.items()) and r["measure"] == "Cases per 1,000 workers":
            n = nat.get((r["year"], r["case_type"], r["measure"], r["scope"], "Total"))
            if n is not None:
                compared += 1
                differ += not close(r["value"], n, 0.01)
    notes.append(f"national incidence in the {name} tables: {compared - differ} of {compared} "
                 f"within 1% of the national series")

# 3. The totals for each sex agree between the tables by age and by sector
by_sector = {(r["year"], r["sex"], r["case_type"], r["measure"], r["scope"]): r["value"]
             for r in sex_sector if r["sector"] == "Total"}
pairs = [(r["value"], by_sector[(r["year"], r["sex"], r["case_type"], r["measure"], r["scope"])])
         for r in sex_age if r["age_group"] == "Total"
         and (r["year"], r["sex"], r["case_type"], r["measure"], r["scope"]) in by_sector]
notes.append(f"totals by sex in the age and sector tables: {sum(close(a, b, 0.01) for a, b in pairs)} "
             f"of {len(pairs)} within 1%")

# ---- Write ----------------------------------------------------------------------------------------
def write(name, rows, columns):
    rows = sorted(rows, key=lambda r: tuple(str(r[c]) for c in columns if c != "value"))
    with open(tidy / name, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, columns, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)


common = ["case_type", "measure", "scope"]
write("national.csv", national, ["year", "classification", "sector", "sector_es"] + common + ["value"])
write("by_jurisdiction.csv", jurisdiction, ["year", "jurisdiction", "jurisdiction_es", "classification",
                                            "sector", "sector_es"] + common + ["value"])
write("by_sex_age.csv", sex_age, ["year", "sex", "age_group"] + common + ["value"])
write("by_sex_sector.csv", sex_sector, ["year", "sex", "classification", "sector", "sector_es"] + common + ["value"])
write("by_size.csv", size, ["year", "workers", "workers_es"] + common + ["value"])
write("by_sector_3digit.csv", sector3, ["year", "classification", "code", "sector", "sector_es", "sex"]
      + common + ["value"])
for f in sorted(tidy.glob("*.csv")):
    print(f"{f.name:24} {sum(1 for _ in open(f, encoding='utf-8')) - 1:7} rows")
print("\n".join(notes))
if problems:
    raise ValueError("Checks failed:\n" + "\n".join(problems[:20]))
print("Counts add up: sectors to workplaces, and workplaces plus domestic workers to the system")

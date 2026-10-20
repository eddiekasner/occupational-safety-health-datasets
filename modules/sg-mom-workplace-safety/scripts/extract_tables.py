"""Extract tables from the Ministry of Manpower's Workplace Safety and Health Reports (PDF).

MOM publishes Singapore's workplace safety and health statistics only as annual PDF reports. Each
report's statistical tables (Annex B) give two or three years, so four reports cover 2018 to 2025:
2019 (2018-2019), 2021 (2019-2021), 2023 (2022-2023) and 2025 (2024-2025). Where two reports give
the same year, the later report is used (MOM revises recent figures).

Reads data/raw/wsh-national-stats-<year>.pdf (downloaded by scripts/fetch_data.R) and writes, to
data/tidy/:
  injuries_by_industry.csv   fatal, major and minor injuries, occupational diseases and man-days
                             lost, by industry, with rates per 100,000 workers
  injury_types.csv           major and minor injuries by type of injury
  occupational_diseases.csv  occupational disease cases by type

Needs pdfplumber (pip install pdfplumber) and pdftotext (from poppler). Written in Python because
no R package reads the table cells of these PDFs reliably. The outputs are committed, so you only
need to run this to update them.

Usage (from the module folder):  python scripts/extract_tables.py
"""
import csv
import re
import subprocess
from pathlib import Path

import pdfplumber

module = Path(__file__).resolve().parent.parent
raw = module / "data" / "raw"
tidy = module / "data" / "tidy"

reports = [2019, 2021, 2023, 2025]

# Table titles in each report (the table numbering changed in 2022)
tables = {
    ("Fatal injuries", "count"): ["Table 5:", "Table 5:", "Table 3a:", "Table 3a:"],
    ("Fatal injuries", "rate"): ["Table 6:", "Table 6:", "Table 3b:", "Table 3b:"],
    ("Major injuries", "count"): ["Table 9:", "Table 9:", "Table 4a:", "Table 4a:"],
    ("Major injuries", "rate"): ["Table 10:", "Table 10:", "Table 4b:", "Table 4b:"],
    ("Minor injuries", "count"): ["Table 14:", "Table 14:", "Table 5a:", "Table 5a:"],
    ("Minor injuries", "rate"): ["Table 15:", "Table 15:", "Table 5b:", "Table 5b:"],
    ("Occupational diseases", "count"): ["Table 21:", "Table 22:", "Table 7a:", "Table 7a:"],
    ("Occupational diseases", "rate"): ["Table 22:", "Table 23:", "Table 7b:", "Table 7b:"],
    ("Man-days lost", "count"): ["Table 28:", "Table 29:", "Table 8:", "Table 8:"],
    ("Major injury types", "count"): ["Table 11:", "Table 11:", "Table 4c:", "Table 4c:"],
    ("Minor injury types", "count"): ["Table 18:", "Table 16:", "Table 5c:", "Table 5c:"],
    ("Occupational disease types", "count"): ["Table 23:", "Table 24:", "Table 7c:", "Table 7c:"],
}


def number(s):
    s = (s or "").strip()
    if s in ("n.a.", "-", "–", ""):
        return None
    s = s.replace(",", "")
    return float(s) if "." in s else int(s)


def layout_indents(pdf_path):
    """Indentation of each row label in the pdftotext layout, to tell industries from the
    sub-industries listed under them."""
    text = subprocess.run(["pdftotext", "-layout", str(pdf_path), "-"], capture_output=True,
                          check=True).stdout.decode("utf-8")
    return text


def find_table(pdf, title):
    """Return (page, top, bottom) of the table with this title: the last page where the title
    starts a line (earlier matches are the list of tables)."""
    found = None
    for page in pdf.pages:
        for m in page.search(re.escape(title), regex=True):
            if m["x0"] < 120:  # at the start of a line
                found = (page, m["top"])
    if found is None:
        raise ValueError("table not found: " + title)
    page, top = found
    later = [m["top"] for m in page.search(r"Table \d+[a-z]?:", regex=True)
             if m["top"] > top + 5 and m["x0"] < 120]
    return page, top, (min(later) if later else page.height)


def read_table(pdf, title):
    page, top, bottom = find_table(pdf, title)
    region = page.crop((0, top, page.width, bottom))
    rows = []
    for table in region.extract_tables():
        for r in table:
            cells = [c for c in r if c not in (None, "")]
            if cells:
                rows.append(cells)
    # The header row gives the years; "[N]" marks the new injury series (from 2021)
    header, body = None, []
    for cells in rows:
        if header is None and any(re.fullmatch(r"\d{4}\s*(\[N\]\*?)?", c.strip()) for c in cells):
            header = [c.strip().replace("*", "") for c in cells
                      if re.fullmatch(r"\d{4}\s*(\[N\]\*?)?", c.strip())]
            continue
        label = re.sub(r"\s+", " ", cells[0]).strip()
        values = cells[1:]
        if not values and body:
            body[-1][0] += " " + label  # second line of a label that wraps
        elif values:
            body.append([label, values])
    return header, body


NUM = r"(?:-?[\d,]+(?:\.\d+)?|n\.a\.|-|\u2013)"


def read_table_text(layout_text, title):
    """Fallback for tables without ruling lines (the 2019 report): parse the pdftotext layout,
    where each row is a label followed by one number per year."""
    s = [m.start() for m in re.finditer("^" + re.escape(title), layout_text, re.M)][-1]
    nxt = re.search(r"^(Table |Annex )", layout_text[s + 10:], re.M)
    block = layout_text[s: s + 10 + (nxt.start() if nxt else 3000)]
    header, body = None, []
    for line in block.split("\n")[1:]:
        years = re.findall(r"\b(\d{4})\b", line)
        if header is None and years and re.fullmatch(r"[A-Za-z ]*(\d{4}\s*)+", line.strip()):
            header = years
            continue
        m = re.match(r"^\s*(.*?\S)\s{2,}(" + NUM + r"(?:\s+" + NUM + r")*)\s*$", line)
        if header and m and "REPORT" not in line:
            values = m.group(2).split()
            if len(values) == len(header):
                body.append([m.group(1), values])
    return header, body


def level_of(label, layout_text, pos):
    """Indentation of a row label in the pdftotext layout, searching from position pos (rows are
    matched in order, so a repeated label such as "Others" finds its own line). Returns the
    indentation and the position to search from next."""
    for pattern in (re.escape(label[:25]), re.escape(label.split(" ")[0])):
        m = re.compile(r"^( *)" + pattern, re.M).search(layout_text, pos)
        if m:
            return m.group(1), m.end()
    return "", pos


out = {"industry": [], "types": [], "od_types": []}
for i, rep in enumerate(reports):
    pdf_path = raw / f"wsh-national-stats-{rep}.pdf"
    pdf = pdfplumber.open(pdf_path)
    layout = layout_indents(pdf_path)
    for (measure, statistic), titles in tables.items():
        title = titles[i]
        header, body = read_table(pdf, title)
        if not header or any(len(v) != len(header) for _, v in body):
            header, body = read_table_text(layout, title)
        # indentation of labels within this table's layout block
        s = [m.start() for m in re.finditer("^" + re.escape(title), layout, re.M)][-1]
        block = layout[s: s + 6000]
        pos = 0
        for label, values in body:
            if len(values) != len(header):
                raise ValueError(f"{rep} {title} {label}: {values} vs {header}")
            indent, pos = level_of(label, block, pos)
            for col, v in zip(header, values):
                year = int(col[:4])
                series = "New (any medical leave)" if "[N]" in col else "Standard"
                # Only minor injuries and man-days lost are published under both rules
                if measure not in ("Minor injuries", "Man-days lost", "Minor injury types"):
                    series = ""
                out_row = {"source_report": rep, "year": year, "measure": measure,
                           "statistic": statistic, "series": series, "label": label,
                           "indent": len(indent), "value": number(v)}
                key = "industry" if measure in ("Fatal injuries", "Major injuries",
                                                "Minor injuries", "Occupational diseases",
                                                "Man-days lost") else \
                    "od_types" if measure == "Occupational disease types" else "types"
                out[key].append(out_row)

# Harmonise industry names across reports (spelling varies) and name each sub-industry's parent.
# Sub-industries are listed under their parent in the reports; the parent's figure includes them.
industries = {
    # label as published (lower case, "and" written "&", spaces and asterisks removed): (industry, parent)
    "all industries": ("All industries", ""),
    "all industries (excluding pws)": ("All industries", ""),
    "all industries (including pws)": ("All industries", ""),
    "construction": ("Construction", ""),
    "regular construction": ("Regular construction", "Construction"),
    "smaller scale works": ("Smaller scale works (renovation, addition and alteration)", "Construction"),
    "work-related traffic accidents": ("Work-related traffic accidents", "Construction"),
    "marine": ("Marine", ""),
    "manufacturing": ("Manufacturing", ""),
    "metalworking": ("Metalworking", "Manufacturing"),
    "manufacture of food": ("Manufacture of food, beverages & tobacco", "Manufacturing"),
    "manufacture of petrolchemical": ("Manufacture of petrochemical products", "Manufacturing"),
    "manufacture of petrochemical": ("Manufacture of petrochemical products", "Manufacturing"),
    "manufacture of petroleum": ("Manufacture of petroleum & chemical products", "Manufacturing"),
    "manufacture of computer": ("Manufacture of computer, electronic & optical products", "Manufacturing"),
    "manufacture of other non-metallic": ("Manufacture of other non-metallic mineral products", "Manufacturing"),
    "manufacture of paper": ("Manufacture of paper, rubber & plastic products & printing", "Manufacturing"),
    "manufacture of furniture": ("Manufacture of furniture", "Manufacturing"),
    "manufacture of transport": ("Manufacture of transport equipment", "Manufacturing"),
    "other manufacturing": ("Other manufacturing", "Manufacturing"),
    "electricity": ("Electricity, gas & air-conditioning supply", ""),
    "water supply": ("Water supply, sewerage, waste management & remediation", ""),
    "wholesale & retail trade": ("Wholesale & retail trade", ""),
    "wholesale trade": ("Wholesale trade", "Wholesale & retail trade"),
    "retail trade": ("Retail trade", "Wholesale & retail trade"),
    "repair & maintenance of vehicles": ("Repair & maintenance of vehicles", "Wholesale & retail trade"),
    "transportation & storage": ("Transportation & storage", ""),
    "logistics & transport": ("Logistics & transport", "Transportation & storage"),
    "accommodation & food": ("Accommodation & food service activities", ""),
    "accommodation": ("Accommodation", "Accommodation & food service activities"),
    "food & beverage service": ("Food & beverage service activities",
                                "Accommodation & food service activities"),
    "information & communications": ("Information & communications", ""),
    "telecommunications": ("Telecommunications", "Information & communications"),
    "financial & insurance": ("Financial & insurance services", ""),
    "real estate": ("Real estate activities", ""),
    "rental & leasing": ("Rental & leasing activities", "Administrative & support service activities"),
    "professional, scientific & technical": ("Professional, scientific & technical activities", ""),
    "architectural & engineering": ("Architectural & engineering activities",
                                    "Professional, scientific & technical activities"),
    "legal, accounting & management": ("Legal, accounting & management activities",
                                       "Professional, scientific & technical activities"),
    "administrative & support service": ("Administrative & support service activities", ""),
    "cleaning & landscape": ("Cleaning & landscape maintenance activities",
                             "Administrative & support service activities"),
    "security & investigation": ("Security & investigation activities",
                                 "Administrative & support service activities"),
    "office administrative": ("Office administrative & business support activities",
                              "Administrative & support service activities"),
    "community, social & personal services": ("Community, social & personal services", ""),
    "public administration": ("Public administration & defence", "Community, social & personal services"),
    "education": ("Education", "Community, social & personal services"),
    "health & social services": ("Health & social services", "Community, social & personal services"),
    "health activities": ("Health activities", "Community, social & personal services"),
    "social services": ("Social services", "Community, social & personal services"),
    "arts, entertainment & recreation": ("Arts, entertainment & recreation",
                                         "Community, social & personal services"),
    "other service": ("Other service activities", "Community, social & personal services"),
    "other services": ("Other service activities", "Community, social & personal services"),
    "other personal service": ("Other personal service activities",
                               "Community, social & personal services"),
    "agriculture": ("Agriculture & fishing", ""),
    "platform workers": ("Platform workers", ""),
}


def harmonise(label):
    key = re.sub(r"\s+", " ", label.lower().replace(" and ", " & ").replace("*", "")).strip()
    for prefix in sorted(industries, key=len, reverse=True):
        if key == prefix or key.startswith(prefix):
            return industries[prefix]
    raise ValueError("no industry mapping for: " + label)


for r in out["industry"]:
    r["industry"], r["parent"] = harmonise(r["label"])
    # A sub-industry whose parent is not listed in that table (2019 lists food & beverage service
    # on its own) still has the parent recorded, for reference
# Injury types: the same types are written with different capitals and wording across reports
injury_types = {
    "total": "Total", "amputations": "Amputations", "blindness": "Blindness",
    "burns, with more than 20 mc days": "Burns (more than 20 days of medical leave)",
    "burns": "Burns",
    "concussion, with more than 20 mc days": "Concussion (more than 20 days of medical leave)",
    "concussion": "Concussion", "crushing, fractures": "Crushing, fractures & dislocations",
    "cuts": "Cuts & bruises", "deafness": "Deafness", "drowning": "Drowning",
    "exposure to biological": "Exposure to biological materials",
    "exposure to/ contact with electric": "Electric current", "mosquito": "Mosquito-borne disease",
    "multiple": "Multiple injuries", "paralysis": "Paralysis", "others": "Others",
    "sprains": "Sprains & strains", "bites": "Bites & stings", "puncture": "Puncture wounds",
}
# Occupational diseases: (disease, group); a disease with a group is part of that group's count
diseases = {
    "total": ("Total", ""),
    "work-related musculoskeletal": ("Work-related musculoskeletal disorders", ""),
    "back injuries": ("Back injuries due to ergonomic risks", "Work-related musculoskeletal disorders"),
    "musculoskeletal disorder of the back": ("Musculoskeletal disorder of the back",
                                             "Work-related musculoskeletal disorders"),
    "tendinitis": ("Tendinitis", "Work-related musculoskeletal disorders"),
    "tenosynovitis": ("Tenosynovitis", "Work-related musculoskeletal disorders"),
    "trigger finger": ("Trigger finger/thumb", "Work-related musculoskeletal disorders"),
    "lateral epicondylitis": ("Lateral epicondylitis (tennis elbow)",
                              "Work-related musculoskeletal disorders"),
    "nerve disorder": ("Nerve disorders (e.g. carpal tunnel syndrome)",
                       "Work-related musculoskeletal disorders"),
    "noise induced deafness": ("Noise-induced hearing loss", ""),
    "noise-induced deafness": ("Noise-induced hearing loss", ""),
    "noise-induced hearing loss": ("Noise-induced hearing loss", ""),
    "nid (e)": ("Noise-induced hearing loss, early", "Noise-induced hearing loss"),
    "nihl (e)": ("Noise-induced hearing loss, early", "Noise-induced hearing loss"),
    "nid (a)": ("Noise-induced hearing loss, advanced", "Noise-induced hearing loss"),
    "nihl (a)": ("Noise-induced hearing loss, advanced", "Noise-induced hearing loss"),
    "occupational skin disease": ("Occupational skin disease", ""),
    "eczema": ("Eczema", "Occupational skin disease"),
    "compressed air illness": ("Compressed air illness", ""),
    "cai type 1": ("Compressed air illness, type 1", "Compressed air illness"),
    "cai type 2": ("Compressed air illness, type 2", "Compressed air illness"),
    "barotrauma": ("Barotrauma", ""),
    "aural": ("Aural barotrauma", "Barotrauma"), "sinus": ("Sinus barotrauma", "Barotrauma"),
    "pulmonary": ("Pulmonary barotrauma", "Barotrauma"),
    "occupational lung disease": ("Occupational lung disease", ""),
    "asbestosis": ("Asbestosis", "Occupational lung disease"),
    "silicosis": ("Silicosis", "Occupational lung disease"),
    "occupational asthma": ("Occupational asthma", "Occupational lung disease"),
    "cancers": ("Cancers", ""),
    "mesothelioma": ("Mesothelioma", "Cancers"),
    "occupational lung cancer": ("Occupational lung cancer", "Cancers"),
    "heat disorder": ("Heat disorders", ""),
    "infectious disease": ("Infectious disease", ""), "poisoning": ("Poisoning", ""),
    "others": ("Others", ""),
}


def lookup(table, label):
    key = re.sub(r"\s+", " ", label.lower()).strip()
    for prefix in sorted(table, key=len, reverse=True):
        if key.startswith(prefix):
            return table[prefix]
    raise ValueError("no mapping for: " + label)


for r in out["types"]:
    r["injury_type"] = lookup(injury_types, r["label"])
# Rows are in table order; an indented "Others" row belongs to the disease group above it
group, group_indent = "", 0
for r in out["od_types"]:
    r["disease"], r["group"] = lookup(diseases, r["label"])
    if r["disease"] == "Others" and group and r["indent"] > group_indent:
        r["disease"], r["group"] = "Others (" + group + ")", group
    elif not r["group"] and r["disease"] not in ("Total", "Others"):
        group, group_indent = r["disease"], r["indent"]

# Keep each year from the latest report that gives it. All rows for a year and table come from
# one report, because MOM sometimes regroups categories between reports.
def latest(rows, keys):
    newest = {}
    for r in rows:
        k = (r["measure"], r["statistic"], r["series"], r["year"])
        newest[k] = max(newest.get(k, 0), r["source_report"])
    kept = [r for r in rows
            if r["source_report"] == newest[(r["measure"], r["statistic"], r["series"], r["year"])]]
    seen = {}
    for r in kept:
        seen[tuple(r[x] for x in keys)] = r
    if len(seen) != len(kept):
        dups = {}
        for r in kept:
            dups.setdefault(tuple(r[x] for x in keys), []).append(r["label"])
        raise ValueError("duplicate rows within one report: " + str([v for v in dups.values() if len(v) > 1][:5]))
    return list(seen.values())


def write(path, rows, columns):
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, columns, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)


ind = latest(out["industry"], ["measure", "statistic", "series", "industry", "year"])
write(tidy / "injuries_by_industry.csv",
      sorted(ind, key=lambda r: (r["measure"], r["series"], r["statistic"], r["year"],
                                 r["parent"] or r["industry"], r["parent"] != "", r["industry"])),
      ["year", "measure", "series", "statistic", "industry", "parent", "value", "label",
       "source_report"])
typ = latest(out["types"], ["measure", "series", "injury_type", "year"])
for r in typ:
    r["severity"] = r["measure"].split(" ")[0]
write(tidy / "injury_types.csv",
      sorted(typ, key=lambda r: (r["severity"], r["series"], r["year"], r["injury_type"])),
      ["year", "severity", "series", "injury_type", "value", "label", "source_report"])
odt = latest(out["od_types"], ["disease", "year"])
write(tidy / "occupational_diseases.csv",
      sorted(odt, key=lambda r: (r["year"], r["group"] or r["disease"], r["group"] != "",
                                 r["disease"])),
      ["year", "disease", "group", "value", "label", "source_report"])
print({k: len(v) for k, v in out.items()})

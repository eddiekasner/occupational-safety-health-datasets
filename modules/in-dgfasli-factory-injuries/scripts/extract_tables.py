"""Extract factory injury, enforcement and port statistics from DGFASLI's Standard Reference Notes.

India's Directorate General Factory Advice Service and Labour Institutes (DGFASLI) publishes a
Standard Reference Note each year (PDF). Its statistics chapters have three kinds of tables:
  - Labour Bureau statistics of injuries in factories under the Factories Act, 1948 (national, by
    state, industry and cause), from the annual returns of factories; each note covers five years.
  - Data that DGFASLI collects from each state's Chief Inspector of Factories: fatal and non-fatal
    injuries, factories, employment, occupational diseases, inspectors, inspections, prosecutions,
    and safety, health and welfare provisions, by state.
  - Accidents, inspections and facilities in the dock works of India's major ports.
This script reads the notes for 2006 to 2024 (downloaded by scripts/fetch_data.R), finds the tables by
their titles, reads their cells (pdfplumber), and writes tidy tables to data/tidy/. Each year is
taken from the latest note that has it (`source_edition`).

Needs pdfplumber (pip install pdfplumber). Reading the PDFs takes several minutes; the cells of each
note are cached in data/raw/cells_YYYY.json (not committed).

Usage (from the module folder):  python scripts/extract_tables.py
"""
import csv
import json
import re
from pathlib import Path

import pdfplumber

module = Path(__file__).resolve().parent.parent
raw = module / "data" / "raw"
tidy = module / "data" / "tidy"
tidy.mkdir(exist_ok=True)

# ---- 1. The cells of each statistics table --------------------------------------------------------
TITLE = re.compile(r"^\s*table\s*[-:.]?\s*(\d+\s*\.\s*\d+|\d+\s*\([a-c]\))", re.I)
OTHER = re.compile(r"achievement|target|studies|survey|workshop|seminar|programme|training|talks|paper|"
                   r"article|flameproof|technical advice|awards?|vishwakarma|savings|manpower|consultancy|"
                   r"comments|equipment|heat|model rules|major accidents? hazard|country.?wise", re.I)


def is_table(t):
    cells = [c for r in t for c in r if c not in (None, "")]
    return len(t) >= 3 and cells and not any("STANDARD REFERENCE" in str(c) for c in cells)


def read_note(pdf_path):
    """[{page, title, grids}] for the statistics tables (chapters 7 to 9) of one note."""
    items, current = [], None
    with pdfplumber.open(pdf_path) as pdf:
        for i, page in enumerate(pdf.pages):
            lines = (page.extract_text() or "").split("\n")
            titles = []
            for j, line in enumerate(lines):
                if TITLE.match(line) and not re.search(r"(?i)\bshows?\b", line):
                    t = line.strip()
                    if len(TITLE.sub("", t).strip(" -:.")) < 15 and j + 1 < len(lines):
                        t += " " + lines[j + 1].strip()  # the title is on the next line
                    titles.append(t)
            tables = [t for t in page.extract_tables() if is_table(t)]
            if titles:
                stats = [t for t in titles if not OTHER.search(t) and
                         re.match(r"(?i)^\s*table\s*[-:.]?\s*[789]", t)]
                if not stats:
                    current = None
                    continue
                new = [{"page": i + 1, "title": t, "grids": []} for t in stats]
                items += new
                for k, t in enumerate(tables):  # tables to titles in order
                    new[min(k, len(new) - 1)]["grids"].append(t)
                current = new[-1]
            elif current is not None and tables and current["grids"] and \
                    len(tables[0][0]) == len(current["grids"][-1][0]):
                current["grids"] += tables[:1]  # the table continues on this page
            else:
                current = None
    return items


notes = {}
for pdf_path in sorted(raw.glob("standard_reference_note_*.pdf")):
    edition = int(re.search(r"(\d{4})", pdf_path.name).group(1))
    cache = raw / f"cells_{edition}.json"
    if not cache.exists() or cache.stat().st_mtime < pdf_path.stat().st_mtime:
        print("reading", pdf_path.name, flush=True)
        cache.write_text(json.dumps(read_note(pdf_path), ensure_ascii=False))
    notes[edition] = json.loads(cache.read_text())

# ---- 2. Kinds of table, by title ------------------------------------------------------------------
KINDS = [
    ("lb_national", r"statistics of employment,? industrial injuries"),
    ("lb_state_injuries", r"state.?wise total number of industrial injuries"),
    ("lb_state_fr", r"frequency rates? of industrial injuries"),
    ("lb_state_ir", r"incidence rates? of industrial injuries"),
    ("lb_industry_ir", r"industrial injuries and their incidence rate"),
    ("lb_industry_fr", r"frequency rate of total injuries by important industries"),
    ("lb_cause", r"by causes"),
    ("st_national", r"osh data of registered factories"),
    ("port_accidents_old", r"port.?wise dangerous"),
    ("st_injuries", r"fatal (injuries )?(and|&) non.?fatal injuries|dangerous occurrences, fatal"),
    ("st_employment_old", r"employment in factories during"),
    ("st_registered", r"status of registered factories"),
    ("st_working", r"status of working factories"),
    ("st_employment", r"status of employment in factories"),
    ("st_women", r"women employment"),
    ("st_hazardous_workers", r"workers in hazardous"),
    ("st_hazardous", r"hazardous (process )?factories"),
    ("st_inspectors", r"inspectors of factories"),
    ("st_surgeons", r"certifying surgeons"),
    ("st_inspected", r"factories inspected"),
    ("port_prosecution", r"prosecution in (major )?ports"),
    ("st_prosecution", r"prosecution"),
    ("st_safety_officers", r"safety officers"),
    ("st_safety_policy", r"safety policy"),
    ("st_safety_committee", r"constitution of safety committee"),
    ("st_onsite", r"on.?site emergency"),
    ("st_ambulance", r"ambulance"),
    ("st_medical", r"medical facilities in factories"),
    ("st_canteens", r"canteens"),
    ("st_welfare_officers", r"welfare officers"),
    ("st_diseases", r"occupational diseases"),
    ("port_employment", r"employment (&|and) rates of reportable"),
    ("port_accidents", r"reportable accidents (&|and) dangerous"),
    ("port_agency", r"according to agency"),
    ("port_type", r"according to type"),
    ("port_inspections", r"inspections and other visits"),
    ("port_investigations", r"investigation into reportable"),
    ("port_committee", r"dock safety committee"),
    ("port_ships", r"ships called"),
    ("port_cargo", r"cargo handled"),
    ("port_safety", r"safety facilities in"),
    ("port_health", r"health facilities in"),
    ("port_welfare", r"welfare facilities in"),
]
# Tables whose layout the cell reader cannot follow; other notes cover the same years
SKIP = {(2023, "st_national"), (2013, "lb_industry_ir"), (2013, "lb_industry_fr"), (2013, "port_agency"), (2013, "port_type")}
SKIP |= {(e, k) for e in (2006, 2007, 2008, 2009) for k in ("lb_industry_ir", "lb_industry_fr")}


def kind_of(title):
    t = re.sub(r"\s+", " ", title.lower())
    return next((k for k, p in KINDS if re.search(p, t)), None)


# ---- 3. Reading a table's cells ---------------------------------------------------------------------
HEADER_WORD = re.compile(r"(?i)^(sl\.?|s\.? ?no\.?|sr\.? ?no\.?|sl\.? ?no\.?|state|states|year|industry|"
                         r"causation|cause|agency|type|port|ports|name|nic|particulars|items?|category|"
                         r"description)\b")
MARK = r"na|n\.a\.?|\.\.|#|\*|nil|data not provided|--|-|\(-\)|not available"
VALUE = re.compile(r"(?i)^((-?[\d,]*\.?\d+|" + MARK + r")\s*(\(\s*([\d.,%\s-]+|" + MARK + r")\s*\)?)?|"
                   r"([\d,]+|" + MARK + r")\s*/\s*([\d,]+|" + MARK + r"))$")
END = re.compile(r"(?i)^(source|note|n\.b)")


def clean(c):
    return None if c is None else re.sub(r"\s+", " ", str(c)).strip()


def is_value(c):
    return c not in (None, "") and bool(VALUE.match(c))


def numbering(r):
    nums = [re.sub(r"[()]", "", c) for c in r if c]
    return len(nums) >= 3 and all(n.isdigit() for n in nums) and \
        [int(n) for n in nums] == list(range(int(nums[0]), int(nums[0]) + len(nums)))


def unreverse(text):
    """Some notes print rotated headings, which the PDF holds backwards."""
    if re.search(r"seirotcaF|rednu|deriuqer|denoitcnaS|noitis|seirujnI|latoT|etaR|rekroW", text):
        return text[::-1]
    return text


def parse_grid(grid):
    """Rows of (label, [(header path, raw value)])."""
    rows = [[clean(c) for c in r] for r in grid]
    width = max(len(r) for r in rows)
    rows = [r + [None] * (width - len(r)) for r in rows]
    rows = [r for r in rows if any(c for c in r) and not numbering(r)]
    while rows and sum(1 for c in rows[0] if c) == 1 and len(next(c for c in rows[0] if c)) > 40:
        rows = rows[1:]  # a title inside the table
    start = next((i for i, r in enumerate(rows) if [c for c in r[:2] if c] and
                  not HEADER_WORD.match([c for c in r[:2] if c][0]) and
                  any(is_value(c) for c in r[1:])), None)
    if start is None:
        return []
    header = [list(r) for r in rows[:start]]
    for r in header:  # merged cells: fill to the right
        for j in range(1, width):
            if r[j] is None and r[j - 1] not in (None, ""):
                r[j] = r[j - 1]
    paths = []
    for j in range(width):
        p = []
        for r in header:
            if r[j] and unreverse(r[j]) not in p:
                p.append(unreverse(r[j]))
        paths.append(tuple(p))
    body = []
    for r in rows[start:]:
        # a row with values but no label continues the row above (values split over two lines)
        if body and not any(r[:2]) and any(is_value(c) for c in r) and \
                all(is_value(c) for c in r if c not in (None, "")):
            prev = body[-1]
            for j in range(width):
                if prev[j] in (None, "") and r[j] not in (None, ""):
                    prev[j] = r[j]
            continue
        body.append(list(r))
    out = []
    for r in body:
        lead = next((c for c in r if c), "")
        if END.match(lead):
            break
        k, label = 0, []
        while k < width:
            c = r[k]
            if c and is_value(c) and (label or (k > 0 and not re.fullmatch(r"\d+\.?", c))):
                break
            if c and not re.fullmatch(r"\d{1,2}\.?", c):
                label.append(c)
            k += 1
        cells = [(j, r[j]) for j in range(k, width) if r[j] not in (None, "")]
        cols = [j for j in range(k, width) if paths[j] and not HEADER_WORD.match(paths[j][0])]
        if all(paths[j] for j, _ in cells):
            vals = [(paths[j], v) for j, v in cells]
        elif len(cells) == len(cols):  # values and headings in different cells of merged columns
            vals = [(paths[j], v) for j, (_, v) in zip(cols, cells)]
        else:
            # a value in a column without a heading belongs to the next headed column, if that is empty
            vals = []
            for j, v in cells:
                if not paths[j]:
                    j = next((i for i in range(j + 1, min(j + 4, width)) if paths[i] and r[i] in (None, "")), j)
                if paths[j]:
                    vals.append((paths[j], v))
        out.append((" ".join(label), vals))
    return out


def number(text):
    """The number in a cell: None if not available, 0 for nil."""
    t = text.strip().lower().rstrip("*")
    if re.fullmatch(r"na|n\.a\.?|\.\.|\*|data not provided|not available|", t):
        return None
    if re.fullmatch(r"#|nil|--|-|\(-\)", t):
        return 0.0
    t = t.replace(",", "")
    try:
        return float(t)
    except ValueError:
        return None


def split_value(text):
    """'2661(636)' or '2661 (636)' -> ('2661', '636'); '82/147' -> ('82', '147'); else (text, None)."""
    m = re.fullmatch(r"(.+?)\s*/\s*(.+)", text)
    if m:
        return m.group(1), m.group(2)
    m = re.fullmatch(r"(.+?)\s*\(\s*(.*?)\s*\)?", text)
    if m and m.group(1):
        return m.group(1), (None if "%" in m.group(2) else m.group(2))
    return text, None


# ---- 4. Names -------------------------------------------------------------------------------------
STATES = [
    ("Andaman and Nicobar Islands", r"^andaman|^nicobar"),
    ("Andhra Pradesh", r"^andhra"), ("Arunachal Pradesh", r"^arunachal"), ("Assam", r"^assam"),
    ("Bihar", r"^bihar"), ("Chandigarh", r"^chandigarh"), ("Chhattisgarh", r"^chh?att?isgarh"),
    ("Dadra and Nagar Haveli and Daman and Diu", r"^(daman and diu and|dd and dnh|daman and diu and dadra|"
                                                 r"dadra and nagar haveli and daman)"),
    ("Daman and Diu", r"^daman and diu$"), ("Dadra and Nagar Haveli", r"^dadra( and)? nagar"),
    ("Delhi", r"delhi"), ("Goa", r"^goa"), ("Gujarat", r"^gujarat"), ("Haryana", r"^haryana"),
    ("Himachal Pradesh", r"^himal?chal"), ("Jammu and Kashmir", r"^jammu"), ("Jharkhand", r"^jharkhand"),
    ("Karnataka", r"^karnataka"), ("Kerala", r"^kerala"), ("Ladakh", r"^ladakh"),
    ("Lakshadweep", r"^laksh"), ("Madhya Pradesh", r"^madhya"), ("Maharashtra", r"^maharashtra"),
    ("Manipur", r"^manipur"), ("Meghalaya", r"^meghalaya"), ("Mizoram", r"^mizor"),
    ("Nagaland", r"^nagal?l?and|^nagland"), ("Odisha", r"^(odisha|orissa)"), ("Puducherry", r"^(pud+u?c+h?er+y|pondicherry)"),
    ("Punjab", r"^punjab"), ("Rajasthan", r"^rajasthan"), ("Sikkim", r"^sikkim"), ("Tamil Nadu", r"^tamil"),
    ("Telangana", r"^telangana"), ("Tripura", r"^tripura"), ("Uttar Pradesh", r"^uttar pradesh"),
    ("Uttarakhand", r"^uttara(khand|nchal)"), ("West Bengal", r"^west bengal"), ("Total", r"^total"),
]
PORTS = [("Mumbai", r"^mum"), ("Jawaharlal Nehru Port", r"^(j\.? ?n|jnpt)"), ("Kandla (Deendayal)", r"^(kandla|deendayal)"),
         ("Mormugao", r"^m[oa]a?rm"), ("Kolkata", r"^kol"), ("Haldia", r"^haldia"), ("Paradip", r"^para"),
         ("Visakhapatnam", r"^vis"), ("Chennai", r"^chenn"), ("Kamarajar (Ennore)", r"^(kamarajar|ennore)"),
         ("Kochi", r"^(kochi|cochin)"), ("New Mangalore", r"^(new|n) ?mang"), ("Tuticorin (V.O. Chidambaranar)", r"^(tuti|v\.? ?o)"),
         ("Port Blair", r"^port blair"), ("Total", r"^total")]


def key(text):
    t = text.lower().replace("&", " and ").replace("`", "")
    t = re.sub(r"\(.*?\)|[*:.,]", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def state_of(label):
    k = key(label)
    return next((name for name, p in STATES if re.search(p, k)), None)


def port_of(label):
    k = re.sub(r"[- ]+", " ", key(label))
    k = re.sub(r"(\w) (\w{1,3})\b", lambda m: m.group(1) + m.group(2) if len(m.group(2)) < 3 else m.group(0), k)
    return next((name for name, p in PORTS if re.search(p, k)), None)


INDUSTRIES = [("Textiles", r"textile"), ("Paper and printing", r"paper"), ("Chemicals", r"chemical"),
              ("Non-metallic mineral products", r"non.?\s?metallic"), ("Basic metals", r"basic metal"),
              ("Metal products", r"metal products"), ("Machinery (except electrical)", r"machinery"),
              ("Transport equipment", r"transport equipment"), ("Electricity, gas and steam", r"electricity"),
              ("All industries", r"all\s*industries"), ("Total of the 9 industries", r"total of")]


CAUSES = [("Prime movers", r"prime mover"), ("Machinery not moved by mechanical power", r"not moved"),
          ("Machinery moved by mechanical power", r"machinery moved"), ("Transport", r"transport"),
          ("Electricity", r"electricity"), ("Explosions", r"explosion"), ("Fires", r"fire"), ("Gassing", r"gassing"),
          ("Molten metals and other hot or corrosive substances", r"molten"), ("Hand tools", r"hand tool"),
          ("Falling bodies", r"falling bod"), ("Persons falling", r"persons? falling"),
          ("Stepping on or striking against objects", r"stepping|striking"),
          ("Handling goods or articles", r"handling"), ("Others", r"other"), ("Total", r"^total")]


def cause_of(label):
    k = re.sub(r"^\d+\.\s*", "", label).lower()
    return next((name for name, p in CAUSES if re.search(p, k)), None)


PORT_CATEGORIES = {
    "port_agency": [("Lifting appliances", r"lifting"), ("Loose gear and ropes", r"loose gear|rope"),
                    ("Unitised and break bulk cargo", r"uniti[sz]ed|break bulk"), ("Bulk cargo", r"bulk cargo"),
                    ("Electrical equipment", r"electric"), ("Tools and implements", r"tools?"),
                    ("Means of access", r"access"), ("Means of transportation", r"transport"),
                    ("Other agencies", r"other"), ("Total", r"^total")],
    "port_type": [("Fall of persons", r"fall of (persons|presons)"), ("Fall of objects", r"fall of object"),
                  ("Stepping on, striking against or struck by objects", r"stepping|striking"),
                  ("Caught in or between objects", r"caught"),
                  ("Overexertion or wrong movement", r"exertion"),
                  ("Exposure to or contact with extreme temperature", r"temperature"),
                  ("Exposure to or contact with electric current", r"electric"),
                  ("Exposure to or contact with dangerous goods", r"dangerous goods|harmful"),
                  ("Explosion", r"explosion"), ("Others", r"other"), ("Total", r"^total")]}


def port_category(kind, label):
    k = re.sub(r"^([ivx]+|[a-j])\.\s*", "", label.strip(), flags=re.I).lower()
    k = re.sub(r"(\w)\s*-\s+(\w)|(\w) (on)\b", lambda m: (m.group(1) or m.group(3)) + (m.group(2) or m.group(4)), k)
    return next((name for name, p in PORT_CATEGORIES[kind] if re.search(p, k)), None)


def industry_of(label):
    k = label.lower()
    return next((name for name, p in INDUSTRIES if re.search(p, k)), None)


# ---- 5. Turning tables into records -----------------------------------------------------------------
records = []      # dicts with: output, year, edition, plus dimensions, measure, value
problems = []


def year_of(text):
    m = re.findall(r"\b((?:19|20)\d\d)\b", text)
    return int(m[-1]) if m else None


def add(output, year, edition, measure, value, **dims):
    # (a value that is not available is kept until the latest edition is chosen, below)
    if year is None:
        return
    records.append(dict(output=output, year=int(year), edition=edition, measure=measure, value=value, **dims))


def split_merged(label, name_of):
    """A row that holds two rows ('29. Uttarakhand Total 3 991 3 753'): the values alternate."""
    tokens = label.split()
    nums = []
    while tokens and is_value(tokens[-1]):
        nums.insert(0, tokens.pop())
    names = [n for n in re.split(r"\s*\d+\.\s*|\s+(?=Total\b)|(?<=[a-z])\s+(?=[A-Z][a-z]+\b(?! Pradesh| Nadu| Bengal| Kashmir))",
                                 " ".join(tokens)) if n and name_of(n)]
    if len(names) >= 2 and nums and len(nums) % len(names) == 0:
        return [(n, nums[i::len(names)]) for i, n in enumerate(names)]
    return None


for edition, items in sorted(notes.items()):
    for item in items:
        kind = kind_of(item["title"])
        if kind is None or (edition, kind) in SKIP or not item["grids"]:
            continue
        title_year = year_of(re.sub(r"2\(cb\)", "", item["title"]))
        rows = []
        for g in item["grids"]:
            rows += parse_grid(g)
        out = []
        for label, vals in rows:
            if not vals:
                continue
            name_of = port_of if kind.startswith("port_") else state_of
            if kind not in ("st_national", "port_agency", "port_type") and re.search(r"\d{2}", label) and \
                    (name_of(label) is None or re.search(r"\d+\.\s*\w+.*\d", label)):
                parts = split_merged(label, name_of)
                if parts:
                    # the values follow the table's value columns
                    cols = list(dict.fromkeys(p for _, v in rows for p, _ in v))
                    for name, nums in parts:
                        out.append((name, [(cols[i], v) for i, v in enumerate(nums) if i < len(cols)]))
                    continue
            # "#" means nil, but a row (or a "#/#" cell) that is "#" throughout means no data was sent
            if all(re.fullmatch(r"[#\s/]+", v) for _, v in vals):
                vals = [(path, "NA") for path, _ in vals]
            vals = [(path, "NA/NA" if re.fullmatch(r"#\s*/\s*#", v) else v) for path, v in vals]
            out.append((label, vals))
        rows = out

        # Labour Bureau
        if kind == "lb_national":
            for label, vals in rows:
                y = year_of(label)
                for path, v in vals:
                    p = " ".join(path).lower()
                    m = ("Working factories submitting returns" if "factories" in p and "rate" not in p else
                         "Average daily employment (thousands)" if "employment" in p and "rate" not in p else
                         None)
                    if m is None:
                        sub = "fatal" if path[-1].lower().startswith("fatal") else "total"
                        base = ("Injuries" if "injuries" == path[0].lower().split()[-1] else
                                "Frequency rate" if "frequency" in p else "Incidence rate" if ("incidence" in p or "rate" in p) else None)
                        if base is None:
                            continue
                        m = {"Injuries": {"fatal": "Fatal injuries", "total": "Total injuries"},
                             "Frequency rate": {"fatal": "Frequency rate (fatal)", "total": "Frequency rate (total)"},
                             "Incidence rate": {"fatal": "Incidence rate (fatal)", "total": "Incidence rate (total)"}}[base][sub]
                    add("lb_national", y, edition, m, number(split_value(v)[0]))
        elif kind in ("lb_state_injuries", "lb_state_fr", "lb_state_ir"):
            name = {"lb_state_injuries": ("Total injuries", "Fatal injuries"),
                    "lb_state_fr": ("Frequency rate (total)", "Frequency rate (fatal)"),
                    "lb_state_ir": ("Incidence rate (total)", "Incidence rate (fatal)")}[kind]
            for label, vals in rows:
                st = state_of(label)
                if st is None:
                    problems.append((edition, kind, label))
                    continue
                for path, v in vals:
                    y = year_of(" ".join(path))
                    a, b = split_value(v)
                    add("lb_state", y, edition, name[0], number(a), state=st)
                    if b is not None:
                        add("lb_state", y, edition, name[1], number(b), state=st)
        elif kind in ("lb_industry_ir", "lb_industry_fr"):
            for label, vals in rows:
                ind = industry_of(label)
                if ind is None:
                    problems.append((edition, kind, label))
                    continue
                for path, v in vals:
                    p = " ".join(path)
                    if re.search(r"(?i)nic", p) and not re.search(r"(?i)injur|ir\b", p.split(">")[-1]):
                        if kind == "lb_industry_fr" or len(path) == 1:
                            continue
                    y = year_of(p)
                    a, b = split_value(v)
                    if kind == "lb_industry_fr":
                        add("lb_industry", y, edition, "Frequency rate (total)", number(a), industry=ind)
                    elif re.search(r"(?i)injur", path[-1]):
                        add("lb_industry", y, edition, "Total injuries", number(a), industry=ind)
                        add("lb_industry", y, edition, "Fatal injuries", number(b) if b else None, industry=ind)
                    elif re.search(r"(?i)\bir\b|rate", path[-1]):
                        add("lb_industry", y, edition, "Incidence rate (total)", number(a), industry=ind)
                        add("lb_industry", y, edition, "Incidence rate (fatal)", number(b) if b else None, industry=ind)
        elif kind == "lb_cause":
            for label, vals in rows:
                cause = cause_of(label)
                if cause is None:
                    problems.append((edition, kind, label))
                    continue
                for path, v in vals:
                    y = year_of(" ".join(path))
                    m = "Fatal injuries" if path[-1].lower().startswith("fatal") else "Total injuries"
                    add("lb_cause", y, edition, m, number(v), cause=cause)

        # State inspectorates
        elif kind == "st_national":
            # Every edition has the same 12 columns, in this order (headings of the last three are split)
            NAT = ["Registered factories", "Employment", "Dangerous occurrences", "Fatal injuries",
                   "Non-fatal injuries", "Total injuries"] + \
                  [f"{w} injuries per {d}" for d in ("100,000 workers", "1,000 registered factories")
                   for w in ("Fatal", "Non-fatal", "Total")]
            for label, vals in rows:
                if len(vals) != len(NAT):
                    problems.append((edition, kind, label))
                    continue
                for m, (path, v) in zip(NAT, vals):
                    add("st_national", year_of(label), edition, m, number(split_value(v)[0]))
        elif kind == "st_injuries":
            for label, vals in rows:
                st = state_of(label)
                if st is None:
                    problems.append((edition, kind, label))
                    continue
                for path, v in vals:
                    p = " ".join(path)
                    y = year_of(p) or title_year or edition - 1
                    if "/" in v or "FI/N-FI" in p:
                        a, b = split_value(v)
                        add("st_state", y, edition, "Fatal injuries", number(a), state=st)
                        add("st_state", y, edition, "Non-fatal injuries", number(b) if b else None, state=st)
                    else:
                        leaf = path[-1].lower() if path else ""
                        m = ("Dangerous occurrences" if "dangerous" in leaf else
                             "Non-fatal injuries" if "non" in leaf else "Fatal injuries" if "fatal" in leaf else None)
                        if m:
                            add("st_state", y, edition, m, number(v), state=st)
        elif kind.startswith("st_"):
            y_default = title_year or edition - 1
            for label, vals in rows:
                if kind == "st_diseases":
                    continue
                st = state_of(label)
                if st is None:
                    problems.append((edition, kind, label))
                    continue
                for path, v in vals:
                    p = " ".join(path)
                    y = year_of(p) or y_default
                    leaf = re.sub(r"\b(19|20)\d\d\b", "", p).strip(" >")
                    leaf = re.sub(r"(\w)- (\w)", r"\1\2", leaf)
                    low = leaf.lower()
                    num = number(split_value(v)[0])
                    if kind in ("st_employment_old", "st_registered", "st_working", "st_employment", "st_women",
                                "st_hazardous", "st_hazardous_workers", "st_inspected"):
                        m = {"st_registered": "Registered factories", "st_working": "Working factories",
                             "st_employment": "Employment", "st_women": "Women employed",
                             "st_hazardous_workers": "Workers in hazardous factories"}.get(kind)
                        if m is None:
                            m = ("Registered factories" if "registered" in low else
                                 "Working factories" if "working" in low else
                                 "Women employed" if "female" in low else "Men employed" if "male" in low else
                                 "Employment" if "employment" in low else
                                 "Workers in hazardous factories" if "worker" in low else
                                 "Hazardous factories inspected" if kind == "st_inspected" and "hazardous" in low else
                                 "Factories inspected" if kind == "st_inspected" else
                                 "Hazardous factories" if kind == "st_hazardous" else None)
                        if m:
                            add("st_state", y, edition, m, num, state=st)
                        continue
                    records.append(dict(output="st_enforcement_raw", year=y, edition=edition, kind=kind,
                                        title=item["title"], path=low, state=st, value=num))

        # Ports
        elif kind.startswith("port_"):
            y = title_year if kind not in ("port_ships", "port_cargo") else None
            for label, vals in rows:
                if kind in ("port_agency", "port_type"):
                    cat = port_category(kind, label)
                    if cat is None:
                        problems.append((edition, kind, label))
                        continue
                    for path, v in vals:
                        port = port_of(" ".join(path))
                        a, b = split_value(v)
                        add("port_class", title_year, edition, "Accidents", number(a), port=port,
                            classification="Agency" if kind == "port_agency" else "Type", category=cat)
                        if b is not None:
                            add("port_class", title_year, edition, "Fatal accidents", number(b), port=port,
                                classification="Agency" if kind == "port_agency" else "Type", category=cat)
                    continue
                port = port_of(label)
                if port is None:
                    problems.append((edition, kind, label))
                    continue
                for path, v in vals:
                    p = re.sub(r"(\w)- (\w)", r"\1\2", " ".join(path))
                    yy = year_of(p) or y or edition
                    records.append(dict(output="port_raw", year=yy, edition=edition, kind=kind,
                                        path=re.sub(r"\b(19|20)\d\d\b", "", p).strip(" >"), port=port,
                                        value=number(split_value(v)[0])))

    # Occupational diseases: the state is on the first row of its diseases
    for item in items:
        if kind_of(item["title"]) != "st_diseases":
            continue
        y_default = year_of(item["title"]) or edition - 1
        current = None
        for g in item["grids"]:
            for label, vals in parse_grid(g):
                st = state_of(label)
                disease = label
                if st:
                    current = st
                    m = re.search(r"(?i)\b(Silic\w*|Noise.*|Byssin\w*|Asbest\w*|Pneumo\w*|Toxic.*|Irritant.*|"
                                  r"Crystalline.*|Lead.*|Dermat.*|Occupational asthma.*)$", label)
                    disease = m.group(1) if m else ""
                if not disease or current is None:
                    continue
                for path, v in vals:
                    y = year_of(" ".join(path)) or y_default
                    n = number(v)
                    if n:
                        add("st_diseases", y, edition, "Cases", n, state=current, disease=disease.strip())

# ---- 6. Enforcement and welfare tables: topic and item ------------------------------------------------
TOPIC = {"st_inspectors": "Inspectors of factories", "st_surgeons": "Certifying surgeons",
         "st_prosecution": "Prosecutions", "st_safety_officers": "Safety officers",
         "st_safety_policy": "Safety policy", "st_safety_committee": "Safety committees",
         "st_onsite": "On-site emergency plans (major accident hazard units)",
         "st_medical": "Medical facilities", "st_ambulance": "Medical facilities",
         "st_canteens": "Canteens, shelters and creches", "st_welfare_officers": "Welfare officers"}


def enforcement_item(r):
    k, low, title = r["kind"], r["path"], r["title"].lower()
    req = re.search(r"requir|\breq\b", low)
    have = re.search(r"having|appointed|\bapp\b|working|in.?position|have", low)
    status = "required" if req else "in position" if have else None
    if k in ("st_inspectors", "st_surgeons"):
        status = "sanctioned" if "sanct" in low else "in position" if re.search(r"position|working", low) else None
        if k == "st_surgeons":
            who = "Employed" if "employ" in low or "employed" in title else "Notified" if "notif" in low or "notified" in title else "Total"
            return f"{who} certifying surgeons, {status}" if status else None
        if "certifying" in low:
            return None
        if "inspected" in low:
            return None
        who = ("Medical inspectors" if "medical" in low or "medical" in title else
               "Chemical inspectors" if "chemical" in low or "chemical" in title else
               "Hygiene inspectors" if "hygiene" in low or "hygiene" in title else
               "Other inspectors" if "other" in low or "other" in title else
               "Specialist inspectors" if "specialist" in low else "Inspectors")
        return f"{who}, {status}" if status else None
    if k == "st_prosecution":
        return ("Prosecutions pending from previous year" if "pending" in low else
                "Prosecutions launched" if "launch" in low else
                "Convictions" if "convic" in low else
                "Prosecutions decided" if "decided" in low else
                "Imprisonment (persons)" if "impris" in low else
                "Fines imposed (rupees)" if "fine" in low else None)
    if k == "st_safety_officers":
        if re.search(r"factor", low):
            return "Factories requiring safety officers" if req else "Factories with safety officers"
        return "Safety officers required" if req else "Safety officers in position"
    if k == "st_welfare_officers":
        if re.search(r"factor", low):
            return "Factories requiring welfare officers" if req else "Factories with welfare officers"
        return "Welfare officers required" if req else "Welfare officers in position"
    if k in ("st_safety_policy", "st_safety_committee", "st_onsite"):
        what = {"st_safety_policy": "a safety policy", "st_safety_committee": "a safety committee",
                "st_onsite": "an on-site emergency plan"}[k]
        return f"Factories requiring {what}" if req else f"Factories with {what}"
    if k in ("st_medical", "st_ambulance"):
        if "ambulance van" in low:
            what = "ambulance vans"
        elif "ambulance room" in low:
            what = "ambulance rooms"
        elif "full" in low:
            return "Full-time medical officers required" if req else "Full-time medical officers in position"
        elif "retainer" in low or "part" in low:
            return "Part-time medical officers required" if req else "Part-time medical officers in position"
        else:
            return None
        return f"Factories requiring {what}" if req else f"Factories with {what}"
    if k == "st_canteens":
        what = "canteens" if "canteen" in low else "shelters, rest or lunch rooms" if "shelter" in low else "creches"
        return f"Factories requiring {what}" if req else f"Factories with {what}"
    return None


for r in records:
    if r["output"] == "st_enforcement_raw":
        r["topic"], r["item"] = TOPIC[r["kind"]], enforcement_item(r)
        r["output"] = "st_enforcement" if r["item"] else "drop"
        r["measure"] = r["item"]

PORT_ITEM = [
    ("port_accidents", r"^total", "Total accidents"), ("port_accidents", r"^non", "Non-fatal accidents"),
    ("port_accidents", r"^fatal", "Fatal accidents"), ("port_accidents", r"dangerous", "Dangerous occurrences"),
    ("port_employment", r"employment", "Average daily employment"),
    ("port_employment", r"frequency.*fatal", "Frequency rate (fatal)"),
    ("port_employment", r"frequency.*total", "Frequency rate (total)"),
    ("port_employment", r"incidence.*fatal", "Incidence rate (fatal)"),
    ("port_employment", r"incidence.*total", "Incidence rate (total)"),
]
PORT_ITEMS = [  # (kind or None for any, pattern, topic, measure)
    ("port_ships", r"tanker", "Ships called", "Oil tankers"),
    ("port_ships", r"other", "Ships called", "Other ships"),
    ("port_cargo", r"container|teu", "Cargo handled", "Containers (TEUs)"),
    ("port_cargo", r"\bpol\b", "Cargo handled", "Petroleum, oil and lubricants (tonnes)"),
    ("port_cargo", r"other", "Cargo handled", "Other cargo (tonnes)"),
    ("port_committee", r"committee", "Dock safety committees and safety weeks", "Dock safety committee meetings"),
    ("port_committee", r"safety week", "Dock safety committees and safety weeks", "Safety weeks"),
    ("port_inspections", r"ship", "Inspections and visits", "Ship inspections"),
    ("port_inspections", r"dock", "Inspections and visits", "Dock inspections"),
    ("port_inspections", r"gear", "Inspections and visits", "Gear inspections"),
    ("port_inspections", r"storage|pipeline", "Inspections and visits", "Isolated storage and pipeline inspections"),
    ("port_inspections", r"other", "Inspections and visits", "Other visits"),
    ("port_prosecution", r"pending", "Prosecutions", "Pending from previous year"),
    ("port_prosecution", r"launch", "Prosecutions", "Launched"),
    ("port_prosecution", r"decided", "Prosecutions", "Decided"),
    ("port_prosecution", r"convict", "Prosecutions", "Convicted"),
    ("port_investigations", r"pending", "Investigations of fatal accidents and dangerous occurrences", "Pending from previous year"),
    ("port_investigations", r"initiat", "Investigations of fatal accidents and dangerous occurrences", "Initiated"),
    ("port_investigations", r"conclud", "Investigations of fatal accidents and dangerous occurrences", "Concluded"),
    (None, r"safety officer", "Safety facilities", "Safety officers"),
    (None, r"competent", "Safety facilities", "Competent persons"),
    (None, r"exhibition", "Safety facilities", "Visits to safety exhibition centres"),
    (None, r"osh cent", "Health facilities", "OSH centres"),
    (None, r"ambulance", "Health facilities", "Ambulance rooms"),
    (None, r"first aid", "Health facilities", "First aid centres"),
    (None, r"doctor", "Health facilities", "Empanelled doctors"),
    (None, r"welfare officer", "Welfare facilities", "Welfare officers"),
    (None, r"canteen", "Welfare facilities", "Canteens"),
    (None, r"drinking", "Welfare facilities", "Drinking water points"),
    (None, r"washing", "Welfare facilities", "Washing facilities"),
    (None, r"urinal", "Welfare facilities", "Urinals"),
    (None, r"workers", "Workers", "Workers"),
]
for r in records:
    if r["output"] != "port_raw":
        continue
    low = r["path"].lower()
    if r["kind"] in ("port_accidents", "port_employment"):
        m = next((name for k, p, name in PORT_ITEM if k == r["kind"] and re.search(p, low)), None)
        r["output"], r["measure"] = ("port_accidents", m) if m else ("drop", None)
        continue
    hit = next(((t, m) for k, p, t, m in PORT_ITEMS if (k is None or k == r["kind"]) and re.search(p, low)), None)
    if hit and r["kind"] not in ("port_accidents_old",):
        r["output"], r["topic"], r["measure"] = "port_activity", hit[0], hit[1]
    else:
        r["output"] = "drop"

# ---- 7. One value per year: the latest edition that has it ---------------------------------------------
# Each table (output, year, measure) is taken whole from the latest edition that has it, so that its
# rows (states, ports, industries) come from one edition and add up to its total.
DIMS = {"lb_national": [], "lb_state": ["state"], "lb_industry": ["industry"], "lb_cause": ["cause"],
        "st_national": [], "st_state": ["state"], "st_enforcement": ["state", "topic"],
        "st_diseases": ["state", "disease"], "port_accidents": ["port"], "port_class": ["port", "classification", "category"],
        "port_activity": ["port", "topic"]}
ROW = {"state", "port", "industry", "cause", "disease"}
latest = {}
for r in records:
    if r["output"] not in DIMS or r.get("year") is None:
        continue
    g = (r["output"], r["year"], r["measure"]) + tuple(r.get(d) for d in DIMS[r["output"]] if d not in ROW)
    r["group"] = g
    latest[g] = max(latest.get(g, 0), r["edition"])
best = {}
for r in records:
    if "group" in r and r["edition"] == latest[r["group"]]:
        best[r["group"] + tuple(r.get(d) for d in DIMS[r["output"]] if d in ROW)] = r
# (a later edition that says "not available" replaces an earlier value)
final = [r for r in best.values() if r["value"] is not None]

# ---- 8. Checks -------------------------------------------------------------------------------------------
notes_out = []


def check(name, output, dim, measures):
    """Share of totals that equal the sum of their parts (within 1%), for years where no part is missing."""
    groups = {}
    for r in final:
        if r["output"] != output or r["measure"] not in measures:
            continue
        g = groups.setdefault((r["year"], r["measure"]) + tuple(r.get(d) for d in DIMS[output] if d != dim),
                              [None, 0.0, 0])
        if r[dim] == "Total":
            g[0] = r["value"]
        else:
            g[1] += r["value"]
            g[2] += 1
    tested = [(k, t, p) for k, (t, p, n) in groups.items() if t is not None and n > 1]
    bad = [(k, t, p) for k, t, p in tested if abs(t - p) > 0.01 * max(t, 1)]
    notes_out.append(f"{name}: {len(tested) - len(bad)} of {len(tested)} totals equal the sum of their parts"
                     + (f"; not equal: {sorted(bad)[:8]}" if bad else ""))


check("Labour Bureau injuries by state", "lb_state", "state", ("Total injuries", "Fatal injuries"))
check("Inspectorate injuries and employment by state", "st_state", "state",
      ("Fatal injuries", "Non-fatal injuries", "Dangerous occurrences", "Registered factories", "Working factories",
       "Employment", "Women employed", "Hazardous factories", "Workers in hazardous factories", "Factories inspected"))
check("Labour Bureau injuries by cause", "lb_cause", "cause", ("Total injuries", "Fatal injuries"))
check("Enforcement and welfare by state", "st_enforcement", "state",
      tuple({r["measure"] for r in final if r["output"] == "st_enforcement"}))
check("Port activity", "port_activity", "port", tuple({r["measure"] for r in final if r["output"] == "port_activity"}))
check("Port accidents by agency and type", "port_class", "category", ("Accidents", "Fatal accidents"))
check("Port accidents", "port_accidents", "port", ("Fatal accidents", "Non-fatal accidents", "Total accidents",
                                                    "Dangerous occurrences"))
# The national Labour Bureau series against its state totals, and DGFASLI's national table against its states
for a, b, ms in [("lb_national", "lb_state", ("Total injuries", "Fatal injuries")),
                 ("st_national", "st_state", ("Fatal injuries", "Non-fatal injuries", "Dangerous occurrences"))]:
    nat = {(r["year"], r["measure"]): r["value"] for r in final if r["output"] == a}
    pairs = [(r["year"], r["measure"], r["value"], nat[(r["year"], r["measure"])]) for r in final
             if r["output"] == b and r.get("state") == "Total" and r["measure"] in ms and (r["year"], r["measure"]) in nat]
    bad = [p for p in pairs if abs(p[2] - p[3]) > 0.01 * max(p[3], 1)]
    notes_out.append(f"{a} against the state totals: {len(pairs) - len(bad)} of {len(pairs)} equal"
                     + (f"; not equal: {bad[:8]}" if bad else ""))
unread = sorted({(e, k, l[:50]) for e, k, l in problems if l and not re.fullmatch(r"(?i)(islands|haveli|hawelli|"
                 r"nicobar|& nagar haveli|union territory|nagar haveli|\d{4})", l)})
notes_out.append(f"rows not read: {len(unread)}" + (f"; {unread[:30]}" if unread else ""))

# ---- 9. Write ------------------------------------------------------------------------------------------
FILES = [
    ("labour_bureau_national.csv", "lb_national", ["year", "measure", "value"]),
    ("labour_bureau_by_state.csv", "lb_state", ["year", "state", "measure", "value"]),
    ("labour_bureau_by_industry.csv", "lb_industry", ["year", "industry", "measure", "value"]),
    ("labour_bureau_by_cause.csv", "lb_cause", ["year", "cause", "measure", "value"]),
    ("inspectorate_national.csv", "st_national", ["year", "measure", "value"]),
    ("inspectorate_by_state.csv", "st_state", ["year", "state", "measure", "value"]),
    ("enforcement_by_state.csv", "st_enforcement", ["year", "state", "topic", "measure", "value"]),
    ("occupational_diseases.csv", "st_diseases", ["year", "state", "disease", "value"]),
    ("ports_accidents.csv", "port_accidents", ["year", "port", "measure", "value"]),
    ("ports_accidents_by_agency_type.csv", "port_class", ["year", "port", "classification", "category", "measure", "value"]),
    ("ports_activity.csv", "port_activity", ["year", "port", "topic", "measure", "value"]),
]
for name, output, cols in FILES:
    rows = sorted((r for r in final if r["output"] == output),
                  key=lambda r: tuple(str(r.get(c, "")) for c in cols))
    with open(tidy / name, "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(cols + ["source_edition"])
        for r in rows:
            v = r["value"]
            w.writerow([r.get(c) if c != "value" else (int(v) if float(v).is_integer() else v) for c in cols]
                       + [r["edition"]])
    print(f"{name:36} {len(rows):6} rows")
print("\n".join(notes_out))

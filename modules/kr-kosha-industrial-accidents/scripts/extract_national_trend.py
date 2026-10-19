"""Build Korea's national industrial accident series since 1964 (data/tidy/national_trend.csv).

Sources:
- 1964 to 2016: the Ministry of Employment and Labor's "2016 산업재해현황분석" (2016 industrial
  accident analysis), reference table 3, "산재보험제도 시행 이후 연도별 산업재해 발생현황"
  (industrial accidents by year since workers' compensation insurance began), and its table of
  accident deaths by year for 2007 to 2016. Download the PDF from KOSHA's portal ("[연보]
  2016년도 산업재해분석" on the "연도별/분기별 현황" board) and save it as
  data/raw/reports/annual_analysis_2016.pdf.
- 2017 to 2025: data/tidy/insured_workers.csv and data/tidy/injured_workers.csv.gz (made by the
  other scripts in this folder).

Needs pdftotext (from poppler). Written in Python to sit beside extract_insured_workers.py; its
output is committed, so you only need to run it to update the table.

Usage (from the module folder):  python scripts/extract_national_trend.py
"""
import csv
import gzip
import re
import subprocess
from collections import Counter
from pathlib import Path

module = Path(__file__).resolve().parent.parent
pdf = module / "data" / "raw" / "reports" / "annual_analysis_2016.pdf"
tidy = module / "data" / "tidy"

text = subprocess.run(["pdftotext", "-layout", str(pdf), "-"], capture_output=True,
                      check=True).stdout.decode("utf-8")


def number(s):
    return float(s.replace(",", "")) if "." in s else int(s.replace(",", ""))


# ---- Reference table 3: 1964 to 2016 ---------------------------------------------------------
start = text.rfind("3. 산재보험제도 시행 이후 연도별 산업재해 발생현황")
end = text.find("4. 월평균 근로시간수 산출 근거", start)
table = text[start:end]

# Left half: year, workers, injured, injury rate, deaths (definition before 2011),
# deaths (current definition, from 2003)
left = []
for m in re.finditer(r"^\s*(’\d{2}|\d{4})\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)\s+([\d,]+)(?:\s+([\d,]+))?\s*$",
                     table, re.M):
    y = m.group(1)
    year = int(y) if len(y) == 4 else 1900 + int(y[1:])
    left.append({"year": year, "insured_workers": number(m.group(2)),
                 "injured": number(m.group(3)), "injury_rate_pct": number(m.group(4)),
                 "deaths_old_definition": number(m.group(5)),
                 "deaths": number(m.group(6)) if m.group(6) else None})

# Right half (printed on the facing pages, in the same year order): injured without lasting
# disability, occupational disease cases receiving care, workers with permanent disability,
# severity rate, frequency rate, compensation paid (million won)
right = [tuple(number(x) for x in m.groups()) for m in re.finditer(
    r"^\s*([\d,]+)\s+([\d,]+)\s+([\d,]+)\s+([\d.]+|0)\s+([\d.]+|0)\s+([\d,]+)\s*$", table, re.M)]

years = [r["year"] for r in left]
assert years == list(range(1964, 2017)), years
assert len(right) == len(left), (len(right), len(left))
for r, (injury, disease, disability, severity, frequency, compensation) in zip(left, right):
    # Before 1972 disease cases, and before 1989 permanent disability, were not reported
    # separately (the table shows 0); leave them blank
    r.update(injured_no_lasting_disability=injury,
             disease_cases_in_care=disease if r["year"] >= 1972 else None,
             permanent_disability=disability if r["year"] >= 1989 else None,
             severity_rate=severity if r["year"] >= 1989 else None,
             frequency_rate=frequency if r["year"] >= 1972 else None,
             compensation_million_won=compensation)
    # The four groups should add up to the injured total (deaths counted the old way)
    diff = r["injured"] - (injury + disease + disability + r["deaths_old_definition"])
    if diff:  # 1978 in the source (-181)
        print(f"{r['year']}: injured total differs from the sum of its parts by {diff}")

# ---- Accident deaths, 2007 to 2016 ------------------------------------------------------------
i = text.find("<연도별 업무상사고 사망재해 추이>")
block = text[i:i + 1500]
ys = [int(y) for y in re.findall(r"(\d{4})년", block)[:10]]
m = re.search(r"업무상사고\s+([\d,\s]+?)\s*\n\s*사망자수", block)
acc = [number(x) for x in m.group(1).split()]
assert ys == list(range(2007, 2017)) and len(acc) == 10, (ys, acc)
accident_deaths = dict(zip(ys, acc))

rows = {r["year"]: r for r in left}
for y, n in accident_deaths.items():
    rows[y]["accident_deaths"] = n

# ---- 2017 to 2025 from this module's tables ------------------------------------------------
with open(tidy / "insured_workers.csv", encoding="utf-8") as f:
    for r in csv.DictReader(f):
        if r["breakdown"] == "All":
            y = int(r["year"])
            rows[y] = {"year": y, "insured_workers": int(r["insured_workers"]),
                       "injured": int(r["reported_injured"]),
                       "injury_rate_pct": round(100 * int(r["reported_injured"]) /
                                                int(r["insured_workers"]), 2),
                       "deaths": int(r["reported_deaths"])}
with gzip.open(tidy / "injured_workers.csv.gz", "rt", encoding="utf-8") as f:
    acc = Counter(int(r["year"]) for r in csv.DictReader(f) if r["case_type"] == "Accident death")
for y, n in acc.items():
    rows[y]["accident_deaths"] = n

columns = ["year", "insured_workers", "injured", "injury_rate_pct", "deaths", "accident_deaths",
           "deaths_old_definition", "injured_no_lasting_disability", "disease_cases_in_care",
           "permanent_disability", "frequency_rate", "severity_rate", "compensation_million_won"]
with open(tidy / "national_trend.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, columns)
    w.writeheader()
    for y in sorted(rows):
        w.writerow({c: rows[y].get(c) for c in columns})
print(f"Wrote {len(rows)} years to {tidy / 'national_trend.csv'}")

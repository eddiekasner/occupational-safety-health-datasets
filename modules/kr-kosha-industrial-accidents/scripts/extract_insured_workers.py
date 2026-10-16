"""Extract the number of insured workers (the denominator for injury and fatality rates) from the
Ministry of Employment and Labor's year-end industrial accident reports.

The microdata have no employment figures. The year-end reports ("[분기] 20XX년 12월말 산업재해
발생현황" and "[분기] 2025년 산업재해 현황" on KOSHA's portal, "연도별/분기별 현황" board,
https://portal.kosha.or.kr/archive/indus-acc-statis/industrial-acc-statu) give, for the year and the
year before, the number of workers covered by workers' compensation insurance, injured workers and
deaths, by major industry and by establishment size. The portal's download links expire, so save
the attachments by hand into data/raw/reports/ as report_2017.hwp, report_2019.hwp,
report_2021.hwp, report_2023.hwpx and report_2025.hwpx (each report also covers the year before).

The reports are in Hangul word processor format. .hwpx files are zipped XML and need nothing extra;
.hwp files need pyhwp (pip install pyhwp). This script is written in Python because no R package
reads .hwp files. Its output, data/tidy/insured_workers.csv, is committed, so you only need to run
it to update the table.

Usage (from the module folder):  python scripts/extract_insured_workers.py
"""
import csv
import html
import re
import subprocess
import zipfile
from pathlib import Path

module = Path(__file__).resolve().parent.parent
reports = module / "data" / "raw" / "reports"
out_path = module / "data" / "tidy" / "insured_workers.csv"

# Report year -> file. Each report gives that year and the year before.
files = {2017: "report_2017.hwp", 2019: "report_2019.hwp", 2021: "report_2021.hwp",
         2023: "report_2023.hwpx", 2025: "report_2025.hwpx"}

# Major industries in the reports, with spaces removed. Before 2020 the reports combine
# agriculture, fishing, and finance and insurance as "기타" (other); they are combined here for
# every year so the groups are the same throughout.
industry_labels = {
    "전체": "All", "총계": "All",
    "광업": "Mining",
    "제조업": "Manufacturing",
    "건설업": "Construction",
    "전기·가스·증기·수도사업": "Electricity, gas, steam and water supply",
    "전기·가스·증기및수도사업": "Electricity, gas, steam and water supply",
    "전기·가스수도업": "Electricity, gas, steam and water supply",
    "운수창고통신업": "Transport, warehousing and communications",
    "운수·창고통신업": "Transport, warehousing and communications",
    "임업": "Forestry",
    "기타의사업": "Other businesses (services)",
    "기타": "Agriculture, fishing, finance and insurance",
    "어업": "Agriculture, fishing, finance and insurance",
    "농업": "Agriculture, fishing, finance and insurance",
    "금융및보험업": "Agriculture, fishing, finance and insurance",
}
size_labels = {"전체": "All", "총계": "All", "5인미만": "1-4", "5인~49인": "5-49",
               "50인~99인": "50-99", "100인~299인": "100-299", "300인~999인": "300-999",
               "1,000인이상": "1000+"}


def report_text(path):
    """Return the report's text, with cells separated by \\x1f and table rows by \\x1e."""
    if path.suffix == ".hwpx":
        z = zipfile.ZipFile(path)
        t = "".join(z.read(n).decode("utf-8") for n in sorted(z.namelist())
                    if n.startswith("Contents/section"))
        t = re.sub(r"</hp:tc>", "\x1f", t)
        t = re.sub(r"</hp:tr>", "\x1e", t)
        t = re.sub(r"</hp:p>", " ", t)
    else:
        t = subprocess.run(["hwp5html", "--html", str(path)], capture_output=True,
                           check=True).stdout.decode("utf-8")
        t = re.sub(r"</t[dh]>", "\x1f", t)
        t = re.sub(r"</tr>", "\x1e", t)
        t = re.sub(r"</p>", " ", t)
    return html.unescape(re.sub(r"<[^>]+>", "", t))


def number(s):
    return int(s.replace(",", "")) if re.fullmatch(r"-?[\d,]+", s) else None


def parse_table(text, title, labels):
    """Parse the '○ 업종별' or '○ 규모별' table in the reference tables (참고 통계표)."""
    start = text.find("참고 통계표", text.find("참고 통계표") + 5)  # skip the table of contents
    i = text.find(title, start)
    j = text.find("○", i + len(title))
    rows, label = [], None
    for row in text[i:j].split("\x1e"):
        cells = [re.sub(r"\s+", " ", c).strip() for c in row.split("\x1f")]
        cells = [c for c in cells if c]
        if not cells:
            continue
        key = re.sub(r"\s+", "", cells[0]).replace("∼", "~")
        if not re.fullmatch(r"-?[\d,.]+", cells[0]):
            # A group's first row: workers, injured, rate, then the same for the year before
            label = labels.get(key)
            n = [number(c) for c in cells[1:7]]
            # (The sub-industry table that follows starts its rows with industry names too)
            if label and len(cells) >= 7 and None not in (n[0], n[1], n[3], n[4]):
                rows.append({"group": label, "workers": n[0], "injured": n[1],
                             "prev_workers": n[3], "prev_injured": n[4]})
            else:
                label = None
        elif label:
            # The group's second row: deaths, fatality rate, then the same for the year before
            n = [x for x in (number(c) for c in cells) if x is not None]
            rows[-1].update(deaths=n[0], prev_deaths=n[1])
            label = None
    return rows


records = {}
for report_year, name in files.items():
    text = report_text(reports / name)
    for breakdown, title, labels in [("Industry group", "○ 업종별", industry_labels),
                                     ("Establishment size", "○ 규모별", size_labels)]:
        for r in parse_table(text, title, labels):
            group = r["group"]
            b = "All" if group == "All" else breakdown
            for year, prefix in [(report_year, ""), (report_year - 1, "prev_")]:
                if year < 2017:
                    continue
                key = (year, b, group)
                # A year's own report wins over the next year's report; sum combined groups
                if key in records and records[key]["source_report"] != report_year:
                    if records[key]["source_report"] == year:
                        continue
                    del records[key]
                rec = records.setdefault(key, {"year": year, "breakdown": b, "group": group,
                                               "insured_workers": 0, "reported_injured": 0,
                                               "reported_deaths": 0,
                                               "source_report": report_year})
                if b == "All" and rec["insured_workers"]:
                    continue  # the total appears in both tables
                rec["insured_workers"] += r[prefix + "workers"]
                rec["reported_injured"] += r[prefix + "injured"]
                rec["reported_deaths"] += r[prefix + "deaths"]

order = {"All": 0, "Industry group": 1, "Establishment size": 2}
rows = sorted(records.values(), key=lambda r: (r["year"], order[r["breakdown"]]))
with open(out_path, "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, ["year", "breakdown", "group", "insured_workers", "reported_injured",
                           "reported_deaths", "source_report"])
    w.writeheader()
    w.writerows(rows)
print(f"Wrote {len(rows)} rows to {out_path}")

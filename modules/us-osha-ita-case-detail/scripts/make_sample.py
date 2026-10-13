"""Build the small committed sample from the full files in data/raw/.

Usage:
    python scripts/make_sample.py              # 2,000 random cases per file
    python scripts/make_sample.py --n 5000

Reads every .csv and .zip in data/raw/ and writes
data/sample/ita_case_detail_sample.csv. A fixed random seed keeps the sample
the same each time it is rebuilt.
"""

import argparse
from pathlib import Path

import pandas as pd

MODULE_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = MODULE_DIR / "data" / "raw"
SAMPLE_PATH = MODULE_DIR / "data" / "sample" / "ita_case_detail_sample.csv"
SEED = 312


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--n", type=int, default=2000, help="cases to sample per file")
    args = parser.parse_args()

    files = sorted(p for p in RAW_DIR.iterdir() if p.suffix.lower() in {".csv", ".zip"})
    if not files:
        raise SystemExit(f"No .csv or .zip files in {RAW_DIR}. Run fetch_data.py first.")

    parts = []
    for path in files:
        df = pd.read_csv(path, dtype=str, low_memory=False, encoding_errors="replace")
        df.columns = df.columns.str.strip().str.lower()
        df["source_file"] = path.name
        sample = df.sample(n=min(args.n, len(df)), random_state=SEED)
        print(f"{path.name}: {len(df):,} cases, sampled {len(sample):,}")
        parts.append(sample)

    out = pd.concat(parts, ignore_index=True)
    SAMPLE_PATH.parent.mkdir(parents=True, exist_ok=True)
    out.to_csv(SAMPLE_PATH, index=False)
    print(f"wrote {len(out):,} rows to {SAMPLE_PATH} ({SAMPLE_PATH.stat().st_size / 1e6:.1f} MB)")


if __name__ == "__main__":
    main()

"""Download the full ITA case detail files from this repository's GitHub Release.

Usage:
    python scripts/fetch_data.py               # download every file in the release
    python scripts/fetch_data.py --tag TAG     # use a different release tag

Files are saved to data/raw/. Files that already exist are skipped.
"""

import argparse
import json
import sys
import urllib.error
import urllib.request
from pathlib import Path

REPO = "eddiekasner/occupational-safety-health-datasets"
DEFAULT_TAG = "data-ita-case-detail-v1"
RAW_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"


def release_assets(repo, tag):
    url = f"https://api.github.com/repos/{repo}/releases/tags/{tag}"
    req = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json"})
    try:
        with urllib.request.urlopen(req) as resp:
            release = json.load(resp)
    except urllib.error.HTTPError as err:
        if err.code == 404:
            sys.exit(
                f"Release '{tag}' not found in {repo}. It may not be published yet, "
                "or the repository may be private."
            )
        raise
    return [(a["name"], a["browser_download_url"], a["size"]) for a in release["assets"]]


def download(url, dest):
    tmp = dest.with_suffix(dest.suffix + ".part")
    with urllib.request.urlopen(url) as resp, open(tmp, "wb") as out:
        while chunk := resp.read(1 << 20):
            out.write(chunk)
    tmp.rename(dest)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--repo", default=REPO)
    parser.add_argument("--tag", default=DEFAULT_TAG)
    args = parser.parse_args()

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    for name, url, size in release_assets(args.repo, args.tag):
        dest = RAW_DIR / name
        if dest.exists() and dest.stat().st_size == size:
            print(f"already have {name}")
            continue
        print(f"downloading {name} ({size / 1e6:.1f} MB)")
        download(url, dest)
    print(f"done: files are in {RAW_DIR}")


if __name__ == "__main__":
    main()

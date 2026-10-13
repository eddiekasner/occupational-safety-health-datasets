# Working with large files

GitHub has three size limits that matter here:

| Method | Limit per file |
| --- | --- |
| Uploading through the github.com web page ("Add file") | 25 MB |
| `git push` from a computer | 100 MB (warning above 50 MB) |
| **GitHub Release assets** | **2 GB** |

## Our approach

1. **Full datasets go on GitHub Releases**, not in the repo. Releases are
   uploaded through the browser by drag and drop, so no command line is needed.
2. **A small sample of each dataset is committed** to `modules/<module>/data/sample/`
   so notebooks run immediately, even in Colab.
3. **Each module has a fetch script** (`scripts/fetch_data.py`) that downloads the
   full files from the Release, or from the official source when that is reliable.

This keeps the repo small and fast to clone, and every student gets identical files.

## How to upload a dataset to a Release (instructor)

1. Zip each CSV first (right-click > Compress, or `zip`). CSVs usually shrink 5 to 10 times.
   Keep the original OSHA file name inside the zip.
2. On GitHub, open the repo, click **Releases** (right sidebar) > **Draft a new release**.
3. **Choose a tag**: type a new tag, using the pattern `data-<module>-v1`,
   for example `data-ita-case-detail-v1`, and click "Create new tag".
4. **Title**: for example "ITA case detail data, CY2023 to CY2025".
5. In the description, record for each file: the original download URL, the date
   you downloaded it, and the original file name.
6. Drag the zip files into the "Attach binaries" box. Wait for each upload to finish.
7. Click **Publish release**.

Then tell Claude (or update the module's `scripts/fetch_data.py`) with the tag
name and the file names, and the fetch script will pick them up.

## Alternatives we considered

- **Git LFS**: works, but free storage and bandwidth quotas are small, and every
  student clone counts against them. Not recommended for a classroom repo.
- **Converting to Parquet**: much smaller and faster to load in Python and R. We may
  publish Parquet copies alongside CSVs later; CSV stays the default because it
  opens in Excel.
- **Zenodo / OSF**: permanent archives with a DOI. Worth considering once a module
  is stable and you want a citable, versioned snapshot.

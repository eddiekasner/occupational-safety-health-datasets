# Working with large files

GitHub limits file sizes:

| Method | Limit per file |
| --- | --- |
| Uploading through the github.com web page ("Add file") | 25 MB |
| `git push` from a computer | 100 MB (warning above 50 MB) |
| GitHub Release assets | 2 GB |

The full OSH datasets are larger than the repo limits, so **we do not store them in the repo.**

## Our approach

1. **Each module has a fetch script** (`scripts/fetch_data.R`) that downloads the full
   files straight from the official source (OSHA, BLS, ILO, Eurostat, ...). Students get
   the authoritative files, and the repo stays small.
2. **A small random sample is committed** to `modules/<module>/data/sample/` so the
   notebook works immediately, with no download.
3. **`scripts/make_sample.R`** rebuilds the sample from the full files with a fixed
   random seed, so anyone can reproduce it.

## Adding a new dataset (instructor)

1. Find the official download link: right-click the download link on the source page
   and choose **Copy link address**.
2. Add it to the `sources` list at the top of the module's `scripts/fetch_data.R`
   (or send the links to Claude).
3. Run `fetch_data.R`, then `make_sample.R`, and commit the sample.

## If a source link breaks

Agencies sometimes move files. If a link stops working:

- Check the source page for the new link and update `fetch_data.R`.
- As a backup, keep your own copy of each downloaded file (and the date you got it).
  Options for hosting a backup copy publicly:
  - **GitHub Release**: up to 2 GB per file; zip the CSV first, or split it by year or industry.
  - **Zenodo** (zenodo.org): free, up to 50 GB per record, gives the snapshot a citable DOI.

## Other options

- **Git LFS**: free storage and bandwidth quotas are small, and every student download
  counts against them. Not recommended for a classroom repo.
- **Parquet files** (via the `arrow` R package): much smaller and faster to load than
  CSV. We may offer Parquet copies later; CSV stays the default because it opens in Excel.

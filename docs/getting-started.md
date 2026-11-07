# Getting Started: A Step-by-Step Guide for Students

This guide takes you from nothing installed to a finished notebook you can submit. You do not need
any experience with R. Plan on about 45 minutes the first time; after that, opening a new module
takes a minute.

**What you will use**

| Tool | What it is |
| --- | --- |
| **R** | The programming language that runs the analysis |
| **RStudio** | The program you work in: it shows your notebook, runs the code and makes the report |
| **This repository** | The modules: background, data and the starter notebooks with questions |
| **A starter notebook** | An R Markdown file (`.Rmd`) that mixes text, questions and code. You run the code, type your answers and "knit" it into an HTML report |

There are two ways to set up. Pick one:

- **[Option A: your own computer](#option-a-your-own-computer)** (Windows or Mac). Best if you have
  a laptop you can install programs on.
- **[Option B: Posit Cloud](#option-b-posit-cloud-in-a-browser)** (RStudio in a web browser).
  Nothing to install; use it on a Chromebook, a tablet with a keyboard, or a computer where you
  cannot install programs.

Then continue with [Install the R packages](#step-4-install-the-r-packages) (both options).

---

## Option A: your own computer

### Step 1. Install R

1. Go to [cran.r-project.org](https://cran.r-project.org/).
2. **Windows:** click **Download R for Windows**, then **base**, then **Download R-4.x.x for
   Windows**. Open the downloaded file and accept all the default choices.
3. **Mac:** click **Download R for macOS**. There are two installers; pick the one for your Mac:
   - Apple menu > **About This Mac**. If it says **Chip: Apple M1** (or M2, M3, M4 and so on),
     download the file ending in **arm64.pkg**.
   - If it says **Processor: Intel**, download the file ending in **x86_64.pkg**.

   Open the downloaded file and accept the defaults.

You will not open R itself; RStudio uses it in the background. Install the latest version (any R
from 4.1 on works).

### Step 2. Install RStudio Desktop

1. Go to [posit.co/download/rstudio-desktop](https://posit.co/download/rstudio-desktop/).
2. Skip step 1 on that page (you just installed R) and click the download button under step 2. It
   picks the right version for your computer.
3. **Windows:** run the installer and accept the defaults. **Mac:** open the downloaded file and
   drag **RStudio** into the **Applications** folder.
4. Open **RStudio**. If it asks which version of R to use, accept the default.

### Step 3. Download this repository

The repository is about 330 MB as a ZIP file and 450 MB unzipped.

**Download ZIP (recommended)**

1. Go to [github.com/eddiekasner/occupational-safety-health-datasets](https://github.com/eddiekasner/occupational-safety-health-datasets).
2. Click the green **Code** button, then **Download ZIP**.
3. **Unzip it.** This step matters: RStudio cannot save your work inside a ZIP file.
   - **Windows:** right-click the downloaded file > **Extract All...** > **Extract**.
   - **Mac:** double-click the downloaded file. A folder appears next to it.
4. Move the unzipped folder (`occupational-safety-health-datasets-main`) somewhere easy to find,
   such as your **Documents** folder.

**Git clone (optional, for students who already use Git)**

With Git installed, either run

```
git clone https://github.com/eddiekasner/occupational-safety-health-datasets.git
```

or, in RStudio, **File > New Project... > Version Control > Git** and paste the repository URL.
Cloning makes updates easy (`git pull`, or the **Pull** button in RStudio's **Git** tab). Commit
your answers to your own branch, or keep your edited notebooks under a different file name, so a
pull never clashes with your work.

Now go to [Step 4](#step-4-install-the-r-packages).

---

## Option B: Posit Cloud (in a browser)

1. Go to [posit.cloud](https://posit.cloud/) and sign up for a free account.
2. Click **New Project** > **New Project from Git Repository**.
3. Paste `https://github.com/eddiekasner/occupational-safety-health-datasets` and click **OK**.
   It takes a few minutes to copy the repository.
4. You now have RStudio in your browser, with the repository's files in the **Files** pane.

The free plan limits how many hours a month you can use and how much memory a project has; check
the current limits on Posit Cloud's pricing page. The data committed to the repository fits
within them. Your work is saved in your Posit Cloud project; to keep a copy, select the files in
the **Files** pane and use **More > Export**.

---

## Step 4. Install the R packages

R packages add functions for reading data, making tables and drawing charts. You install them once
per computer (or once per Posit Cloud project).

1. In RStudio: **File > Open File...** and open `install_packages.R` in the repository's main
   folder.
2. Click **Source** (top right of the editor pane).
3. Wait until the **Console** (bottom left) shows the `>` prompt again. It can take a few minutes.

If the Console asks you a question, answer like this:

| Question | Type |
| --- | --- |
| "Do you want to install from sources the packages which need compilation?" | `no` |
| "Would you like to use a personal library instead?" | `yes` |
| "Would you like to create a personal library ... ?" | `yes` |

To check it worked, type `library(dplyr)` in the Console and press Enter. If nothing comes back
but a new `>`, you are set. (Red text that says `Warning` is usually fine; red text that says
`Error` is not; see [Troubleshooting](#troubleshooting).)

---

## Step 5. Find your way around RStudio

RStudio has four panes:

| Pane | Where | What it is for |
| --- | --- | --- |
| **Editor** | Top left | Your notebook. You read, run code and type answers here |
| **Console** | Bottom left | Where R runs. Results and error messages also appear here |
| **Environment** | Top right | The data you have loaded (for example `national`) |
| **Files / Plots / Help / Viewer** | Bottom right | Browse folders, see charts, read help pages |

Two settings make life easier for beginners (**Tools > Global Options...**):

- **General**: untick **Restore .RData into workspace at startup**, and set **Save workspace to
  .RData on exit** to **Never**. Each session then starts clean.
- **R Markdown**: untick **Show output inline for all R Markdown documents** if you prefer charts
  and tables in the Console and Plots pane rather than under each chunk. (Either works.)

---

## Step 6. Open a module and its notebook

1. Pick a module from the table in the [main README](../README.md#modules) (or the one your
   instructor assigned). Each module is a folder in `modules/`.
2. Read the module's `README.md` first: it explains where the data come from and what they can and
   cannot tell you. You can read it on GitHub, or click it in the **Files** pane.
3. Open your course's notebook in the module's `notebooks/` folder (**File > Open File...**):
   - **ENVH 312:** `312_starter.Rmd`
   - **ENVH 460/560:** `460_560_starter.Rmd`
4. **Save a copy under your own name before you start**: **File > Save As...**, in the same
   `notebooks/` folder, for example `312_starter_lastname.Rmd`. Keep it in that folder: the
   notebook looks for the data relative to where it is saved.

---

## Step 7. Run the code

A notebook has text and grey **code chunks**. Each chunk starts with ```` ```{r} ```` and ends
with ```` ``` ````.

- **Run one chunk:** click the green triangle at the top right of the chunk (or put the cursor in
  it and press **Ctrl + Shift + Enter**, **Cmd + Shift + Enter** on a Mac).
- **Run all chunks above this one:** click the grey triangle with the green bar next to it.
- **Run everything:** **Run > Run All** in the editor's toolbar.

**Always run the first chunk (`setup`, Part 0) first.** It loads the packages and the data. Every
other chunk depends on it. If you close RStudio and come back, run it again.

The setup chunk reads the data from the module's `data/` folder. If a file is not there, it reads
it from GitHub instead, so you need an internet connection in that case.

### Reading and changing the code (optional, but worth it)

You do not have to write code to answer the questions, but small changes help you explore. Most
chunks follow the same pattern:

```r
national |>                                   # start with a table
  filter(year == 2024, sector != "Total") |>  # keep some rows
  select(sector, value) |>                    # keep some columns
  arrange(desc(value))                        # sort, largest first
```

- `|>` means "and then": it passes the result of one line to the next.
- `filter()` keeps rows. Try changing `2024` to `2020` and run the chunk again.
- `select()` keeps columns; `mutate()` adds a column; `arrange()` sorts.
- `ggplot(...) + geom_line()` draws a chart; the lines after `+` add layers and labels.
- Text after `#` is a comment, ignored by R.

To see what a function does, type `?filter` in the Console. To look at a whole table, type
`View(national)` (capital V) in the Console. The module's `data_dictionary.md` explains each
column.

If you break a chunk, **Edit > Undo** (Ctrl/Cmd + Z) takes you back.

---

## Step 8. Write your answers

Type your answers under each **Your answer:** heading, as plain text, outside the grey chunks.

- Leave a blank line between paragraphs.
- Start a line with `- ` for a bullet point, or `1. ` for a numbered list.
- `**bold**` and `*italic*` work as you would expect.
- Do not type inside the grey chunks unless you mean to change the code.

Save often (**Ctrl/Cmd + S**).

---

## Step 9. Knit the report and submit it

1. Click **Knit** (the ball of yarn at the top of the editor). RStudio runs every chunk from the top
   in a fresh session and makes an HTML file.
2. The first time, RStudio may offer to install or update packages for R Markdown. Click **Yes**
   or **Install**.
3. A preview opens. The HTML file is saved next to your notebook, with the same name
   (`312_starter_lastname.html`).
4. Submit the HTML file as your instructor asks.

Knitting starts from scratch, so a notebook can run fine chunk by chunk and still fail to knit if
it depends on something you did only in the Console. The error message names the chunk and the
line: fix it there and knit again.

---

## Troubleshooting

| What you see | What it means and what to do |
| --- | --- |
| `there is no package called 'dplyr'` (or another package) | The packages are not installed: do [Step 4](#step-4-install-the-r-packages) again |
| `could not find function "filter"` (or `"ggplot"`) | The setup chunk has not been run in this session: run Part 0 first |
| `object 'national' not found` | Same: run the setup chunk. Or check the spelling; R is case-sensitive |
| `cannot open file` or `HTTP error 404` in the setup chunk | The notebook cannot find the data: make sure it is still in the module's `notebooks/` folder and that you unzipped the repository. Without the local file, it needs an internet connection |
| Knit fails but every chunk runs | Something is defined only in your Console. Run **Session > Restart R**, then **Run > Run All**, to find the chunk that fails |
| Nothing happens when you run a chunk; the Console shows `+` | R is waiting for the end of an unfinished line (often a missing `)`). Click in the Console and press **Esc**, then fix the chunk |
| You cannot save the notebook, or your changes disappear | You opened it from inside the ZIP file. Unzip the repository ([Step 3](#step-3-download-this-repository)) and open the notebook from the unzipped folder |
| A chunk is slow or RStudio runs out of memory | A few modules have large tables. Close other programs, or on Posit Cloud check the project's memory |
| Text with accents shows as `<U+00E9>` | Only a display issue in some consoles; the data and the knitted report are fine |

Still stuck? Copy the **exact** error message and the chunk into your question to the teaching
team: it is much faster to solve than "it doesn't work".

## Getting a newer version of the repository

Modules are added and corrected during the term.

- **ZIP:** download and unzip it again into a **new** folder, then copy your own notebooks
  (`*_lastname.Rmd`) into the matching `notebooks/` folders. Do not unzip on top of your old
  folder.
- **Git:** `git pull` (or the **Pull** button in RStudio's **Git** tab).
- **Posit Cloud:** in the project, open the **Terminal** tab (next to the Console) and run
  `git pull`.

## Learning more R

- [R for Data Science](https://r4ds.hadley.nz/), free online: the chapters on data
  transformation and visualization cover almost everything the notebooks use.
- [Posit cheatsheets](https://posit.co/resources/cheatsheets/) for dplyr, ggplot2 and R Markdown.

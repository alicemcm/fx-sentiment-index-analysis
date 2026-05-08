# News Sentiment Index Analysis

This repository contains my empirical project for **BEE2041 Data Science in Economics**. The project asks whether financial news sentiment about selected emerging-market economies contains useful information about short-run market movements.

The core output is the executed Jupyter notebook at [`src/main.ipynb`](src/main.ipynb). It builds a news article database, scores article sentiment with financial NLP tools, combines the sentiment series with market-return data, and visualises the relationship between news tone and returns.

## Research Question

**Can news sentiment act as a useful high-frequency indicator for country-market stress in emerging economies?**

The analysis focuses on countries that are frequently discussed in macro-financial news:

- Turkey
- India
- Vietnam
- Argentina
- Indonesia and Nigeria are also present in the article database and are used for broader data coverage checks.

## Project Output

The submitted blog-style output is:

- [`src/main.ipynb`](src/main.ipynb)

> Public output URL: **add link here**

## Repository Structure

```text
.
|-- README.md
|-- requirements.txt
|-- .env.example
|-- empiricalProject_2026.pdf
|-- data/
|   |-- articles.db
|   `-- market_prices.csv
|-- src/
|   `-- main.ipynb
`-- sql/
    |-- database.db
    `-- queries.sql
```

Important files:

- `src/main.ipynb` contains the full analysis, plots, and written project output.
- `data/articles.db` is a cached SQLite database of collected news articles and sentiment scores. Keeping this file in the repository makes the project reproducible even if news APIs, rate limits, or article webpages change later.
- `data/market_prices.csv` is a cached copy of the market-price series used by the notebook.
- `.env.example` lists the optional API keys needed to rebuild the article dataset from live news sources.
- `requirements.txt` lists the Python dependencies.
- `empiricalProject_2026.pdf` is the original project document.

## Data Sources

### News Articles

The article database contains **579 articles** from:

| Source | Articles | Date range |
|---|---:|---|
| The Guardian | 453 | 2025-01-02 to 2026-05-01 |
| New York Times | 126 | 2025-12-08 to 2026-04-30 |

The database currently contains the following country coverage:

| Country | Articles | Date range |
|---|---:|---|
| Argentina | 43 | 2025-03-07 to 2026-04-29 |
| India | 73 | 2025-04-27 to 2026-04-30 |
| Indonesia | 26 | 2025-06-05 to 2026-04-22 |
| Nigeria | 18 | 2025-01-25 to 2026-04-23 |
| Turkey | 375 | 2025-01-02 to 2026-05-01 |
| Vietnam | 44 | 2025-04-04 to 2026-04-28 |

Articles were collected using keyword queries such as:

- `{country} economy`
- `{country} GDP`
- `{country} inflation`
- `{country} growth`
- `{country} central bank`
- `{country} fiscal policy`

Each row in `data/articles.db` includes article metadata, the article URL, the publication date, and sentiment scores.

## Methodology

The project follows this pipeline:

1. **Collect news articles** from The Guardian, NewsAPI, and the New York Times API functions in the notebook.
2. **Store articles in SQLite** so the dataset has a clear schema and can be queried reproducibly.
3. **Clean and inspect the article database** using SQL queries and pandas.
4. **Score sentiment** using two approaches:
   - TextBlob polarity scores on article headlines.
   - FinBERT sentiment scores on headlines and scraped article text.
5. **Create daily sentiment indices** by averaging article-level scores by country and date.
6. **Load or download market-return data** for the comparison series.
7. **Compare sentiment and returns** using regression modelling and correlation analysis:
   - cumulative sentiment time-series plots;
   - normalised market performance plots;
   - scatter plots with fitted linear regression lines;
   - lagged correlation and R-squared checks.
8. **Interpret the results** as an empirical data story rather than as a claim of causal identification.

I use web scraping, APIs, SQL, NLP, and regression modelling. The regression modelling is the Unit 5-style method in the project: I estimate the relationship between daily sentiment scores and market returns, including lagged return specifications.

## Database Definition

The main SQLite table is `articles` in `data/articles.db`.

| Column | Type | Description |
|---|---|---|
| `article_id` | `TEXT` | Primary key; source article identifier or generated hash |
| `country` | `TEXT` | Country linked to the article query |
| `date` | `TEXT` | Publication date in `YYYY-MM-DD` form |
| `source_name` | `TEXT` | News source |
| `title` | `TEXT` | Article headline |
| `description` | `TEXT` | Article abstract, trail text, or description |
| `url` | `TEXT` | Article URL |
| `published_at` | `TEXT` | Original timestamp from the source |
| `sentiment_score` | `REAL` | Legacy sentiment column, currently unused in the cached database |
| `sentiment_score_vader` | `REAL` | TextBlob headline polarity score |
| `sentiment_score_finbert` | `REAL` | Signed FinBERT headline score |
| `article_text` | `TEXT` | Scraped article body text where available |
| `sentiment_fulltext_finbert` | `REAL` | Signed FinBERT score using scraped article text |

The signed FinBERT scores use:

- positive label: `+confidence`
- negative label: `-confidence`
- neutral label: `0`

This gives a continuous index from approximately `-1` to `+1`, where lower values indicate more negative financial tone.

## Reproducibility

These instructions assume Python 3.12, which matches the notebook metadata. Python 3.10 or 3.11 should also work for most packages.

### 1. Clone the Repository

```powershell
git clone <REPOSITORY_URL>
cd <REPOSITORY_DIR>
```

### 2. Create a Virtual Environment

Windows PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
```

macOS/Linux:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
```

### 3. Install Python Packages

```powershell
pip install -r requirements.txt
python -m spacy download en_core_web_md
```

FinBERT is downloaded automatically by `transformers` the first time the notebook creates the pipeline:

```python
pipeline("sentiment-analysis", model="ProsusAI/finbert")
```

This first run can take several minutes because it downloads model weights.

### 4. Choose the Reproduction Method

There are two supported ways to reproduce the data used by the notebook.

**Method A: use the cached database.**

This is the default and most stable method. The cached database is already included at `data/articles.db`, so API keys are **not required** to reproduce the existing analysis. Leave the setup-cell switches as `False`:

```python
USE_LIVE_ARTICLE_COLLECTION = False
RUN_ARTICLE_BODY_SCRAPING = False
RECOMPUTE_MISSING_FINBERT = False
```

With this setting, the notebook uses the article metadata, scraped article text, and sentiment scores already stored in the SQLite database.

**Method B: redo the article ingestion.**

If you want to rebuild or extend the article dataset from live sources, create a local `.env` file:

```powershell
Copy-Item .env.example .env
```

Then fill in the keys:

```text
GUARDIAN_API_KEY=your_guardian_key
NEWSAPI_KEY=your_newsapi_key
NYT_API_KEY=your_nyt_key
```

Do not commit `.env` to GitHub.

Then change the switches in the first notebook setup cell depending on how much of the pipeline you want to rerun:

| Switch | `False` means | `True` means |
|---|---|---|
| `USE_LIVE_ARTICLE_COLLECTION` | Use the cached `data/articles.db` article rows. | Fetch articles again from the configured news APIs and insert them into the database. |
| `RUN_ARTICLE_BODY_SCRAPING` | Use cached `article_text` values already stored in the database. | Visit article URLs again and refresh `article_text` where scraping succeeds. |
| `RECOMPUTE_MISSING_FINBERT` | Use cached FinBERT sentiment columns and skip missing-score recomputation. | Run FinBERT for rows that are missing headline or full-text sentiment scores. |

Typical live-ingestion settings are:

```python
USE_LIVE_ARTICLE_COLLECTION = True
RUN_ARTICLE_BODY_SCRAPING = True
RECOMPUTE_MISSING_FINBERT = True
```

You can also mix the switches. For example, set only `RECOMPUTE_MISSING_FINBERT = True` if the database exists but some sentiment scores are missing.

Live ingestion can produce a different dataset from the cached one because API results, rate limits, and article webpages change over time.

### 5. Run the Notebook

The notebook uses paths such as `../data/articles.db`, so execute it with `src` as the working directory.

Interactive run:

```powershell
cd src
jupyter lab main.ipynb
```

Then choose **Kernel > Restart Kernel and Run All Cells**.

Command-line run:

```powershell
cd src
jupyter nbconvert --to notebook --execute main.ipynb --output main_executed.ipynb --ExecutePreprocessor.timeout=1800
```

The notebook may take a while when any live-ingestion switch is set to `True`, because API calls, scraping, and FinBERT inference are heavier than ordinary pandas operations.

## Reproducing the Data

For the most stable reproduction, use **Method A**: keep all three switches set to `False`, use the included `data/articles.db`, and run the notebook sections that:

- load and inspect `../data/articles.db`;
- calculate or verify sentiment columns;
- load or download the market-return comparison series;
- create plots and regression/correlation summaries.

For a fresh data build, use **Method B**: provide API keys in `.env`, turn on the relevant switches, and rerun the notebook from the setup cell. Live API collection and article-body scraping are intentionally optional because:

- news APIs may rate-limit requests;
- article webpages can change structure or become unavailable;
- model downloads depend on external network access;
- rerunning live collection later may produce a different dataset.

The cached SQLite database is therefore the main dataset for reproducing the submitted results, while live ingestion is available for rebuilding or extending the dataset.

## Expected Outputs

The notebook produces several tables and figures. The most important outputs are:

1. A table showing article coverage by country.
2. A table showing the SQLite schema.
3. Cumulative FinBERT sentiment plots for selected countries.
4. Normalised market performance plots.
5. Scatter plots of daily sentiment versus market returns.
6. Lagged sentiment/returns regression, correlation, and R-squared table.
7. Full-article FinBERT sentiment versus lagged returns plots.

These outputs support the blog narrative by moving from data construction, to sentiment measurement, to financial interpretation.

## Interpretation Guide

I read the analysis as exploratory evidence, not as proof that news sentiment causes asset-price movements.

The main interpretation is:

- FinBERT provides a domain-specific measure of whether financial news is positive, negative, or neutral.
- Country-level daily averages can be used as a simple sentiment index.
- Comparing sentiment with same-day and lagged returns through fitted regression lines tests whether news tone and market performance move together.
- Low correlations or R-squared values are still informative because financial markets are noisy and many price-relevant variables are not captured by news headlines alone.

This framing keeps the interpretation transparent about what the method can and cannot show.

## Quality and Robustness Checks

The project includes or enables the following checks:

- duplicate prevention through `article_id` as a primary key;
- SQL inspection of table schema and country coverage;
- source/date coverage summaries;
- separate headline and full-text sentiment scores;
- comparison of dictionary-style polarity with finance-specific FinBERT;
- lag checks across multiple lead/lag windows;
- normalised market prices to make countries visually comparable;
- use of a cached database to avoid non-reproducible API drift.

## Known Limitations

The main limitations are:

- The country label comes from the search query, so an article can mention several countries even if it is stored under one query country.
- English-language sources may bias the dataset toward internationally visible events.
- Turkey has much higher article coverage than the other countries, so direct cross-country comparisons need caution.
- Financial news sentiment does not isolate causality; it may react to markets as well as predict them.
- Market-return proxies are imperfect measures of broad national financial stress.
- Web scraping success depends on webpage structure and access permissions.
- FinBERT is trained for financial text, but it can still misclassify complex geopolitical or macroeconomic stories.

These limitations are useful context for interpreting the results carefully.

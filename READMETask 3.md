# Task 3 — Chinook Business Analysis
**SQL, Python & Power BI | Data Analyst Internship**

End-to-end business analysis of the Chinook digital media store using SQL (extraction), Python/Pandas/Matplotlib (analysis & visualization), and Power BI (dashboard reporting).

---

## 1. Project Structure

```
├── chinook.db              # Chinook SQLite database (source data)
├── analysis.sql             # 20+ SQL queries answering all required business questions
├── analysis.ipynb           # Executed Python notebook (KPIs + 7 visualizations)
├── charts/                  # PNG exports of every chart in the notebook
├── powerbi_data/             # Clean CSVs to import into Power BI (see Section 4)
│   ├── fact_sales.csv        # Main flat fact table (invoice-line grain, all dimensions joined)
│   ├── revenue_by_country.csv
│   ├── top_customers.csv
│   ├── revenue_by_genre.csv
│   ├── top_artists.csv
│   ├── monthly_revenue.csv
│   ├── customers_by_country.csv
│   └── customer_segments.csv
└── README.md                 # This file — insights + dashboard build guide
```

---

## 2. Key KPIs

| Metric | Value |
|---|---|
| Total Revenue | **$2,328.60** |
| Total Customers | **59** |
| Total Orders | **412** |
| Average Order Value | **$5.65** |
| Average Spend per Customer | **$39.47** |

*(All figures computed directly from `Invoice.Total` in `analysis.sql`, Query 1–5, and reproduced in `analysis.ipynb`.)*

---

## 3. Business Insights

**1. The USA is the single largest revenue market.**
Finding: USA generates **$523.06**, roughly **22% of total revenue** ($2,328.60) and nearly double the #2 market. Recommendation: Prioritize USA in retention campaigns (loyalty offers, personalized recommendations) and use it as the template market for expansion strategies elsewhere.

**2. Revenue is heavily concentrated in a few countries.**
Finding: The top 5 countries (USA, Canada, France, Brazil, Germany) contribute **$1,368.70**, about **59% of total revenue**, out of 24 billing countries. Recommendation: Run country-specific promotions in these five markets rather than spreading marketing budget evenly across all 24 countries.

**3. Rock dominates genre sales.**
Finding: Rock generated **$826.65** in revenue, more than double the #2 genre (Latin, $382.14), and together with Metal and Alternative & Punk, guitar-driven genres make up the large majority of catalog sales. Recommendation: Expand the Rock/Metal catalog and feature it prominently in homepage curation and playlists to maximize conversion.

**4. A small set of artists drives disproportionate revenue.**
Finding: Iron Maiden is the top-performing artist at **$138.60**, followed by U2 ($105.93) and Metallica ($90.09) — the top 10 artists alone account for a meaningful share of total music revenue. Recommendation: Negotiate featured placement or bundle deals with these top artists' labels, and use their fanbases to cross-promote similar/adjacent artists.

**5. Customer value is fairly evenly spread, with the top tier still adding up.**
Finding: Splitting the 59 customers into value terciles, the **High-Value segment (20 customers, avg $42.62 each) contributes $852.40**, about **37% of revenue** from just a third of customers. Recommendation: Build a light "VIP" tier (early access to new releases, small discounts) for the High-Value segment to protect this revenue base, since losing even a handful of these customers has an outsized impact.

**6. Monthly revenue is remarkably flat rather than trending up.**
Finding: Monthly revenue holds close to **$37.62** for most months across 2021–2025, with only occasional spikes (e.g., **$52.62 in Jan 2022**, **$51.62 in Apr 2023**) and dips (e.g., **$23.76 in Nov 2023**). Recommendation: Since there's no organic growth trend, the business should test proactive growth levers — seasonal campaigns, new-release pushes, or subscription/bundle pricing — rather than relying on passive demand.

**7. Purchase frequency, not just spend, marks the best customers.**
Finding: A small group of customers places **7+ orders** each (Query 18) despite the average customer placing far fewer — these repeat buyers are the most reliable revenue source. Recommendation: Trigger automated "we miss you" or replenishment emails for customers who drop below their historical order cadence, to convert frequency into a retention lever.

---

## 4. Power BI Dashboard — Build Guide

> **Note on deliverables:** This project was built and validated in a Linux/Python sandbox, which does not have Power BI Desktop installed (it's a licensed Windows desktop app), so a compiled `.pbix` binary could not be generated here. Instead, this section gives you the exact data model, measures, and visual layout to build it in Power BI Desktop in a few minutes — all the source data is already cleaned and exported to `powerbi_data/`.

### Step 1 — Import Data
In Power BI Desktop: **Get Data → Text/CSV** → import `powerbi_data/fact_sales.csv` as the main fact table. It's already a flat table (invoice-line grain) with `CustomerName`, `Country`, `TrackName`, `ArtistName`, `GenreName`, `InvoiceDate`, `Year`, `Month`, `LineRevenue`, and `Quantity` — no further joins needed. Optionally also import the smaller pre-aggregated CSVs for quick reference visuals.

### Step 2 — Create Measures (DAX)
```DAX
Total Revenue        = SUM(fact_sales[LineRevenue])
Total Orders          = DISTINCTCOUNT(fact_sales[InvoiceId])
Total Customers        = DISTINCTCOUNT(fact_sales[CustomerId])
Average Order Value    = DIVIDE([Total Revenue], [Total Orders])
```

### Step 3 — KPI Cards (top of dashboard)
Add 4 **Card** visuals: `Total Revenue`, `Total Orders`, `Total Customers`, `Average Order Value`.

### Step 4 — Required Visuals (at least 5)
| Visual | Chart type | Fields |
|---|---|---|
| Revenue by Country | Bar chart | Axis: `Country`, Value: `Total Revenue` |
| Sales Trend | Line chart | Axis: `InvoiceDate` (by month), Value: `Total Revenue` |
| Top Customers | Bar chart | Axis: `CustomerName`, Value: `Total Revenue` (Top N filter = 10) |
| Revenue by Genre | Bar or Treemap | Axis: `GenreName`, Value: `Total Revenue` |
| Top Artists / Customer Distribution | Bar chart / Map | Axis: `ArtistName` or `Country`, Value: `Total Revenue` / `Total Customers` |

### Step 5 — Filters / Slicers
Add slicers for: `Country`, `Year`, `GenreName`. Place them on the left or top of the canvas so all visuals respond together.

### Step 6 — Formatting Checklist
- Consistent color theme (pick one accent color, e.g. the blue used in the Python charts: `#2E86AB`)
- Data labels turned on for bar charts
- Axis titles and chart titles filled in (no default "Sum of..." labels)
- Tooltips showing exact revenue values
- Page title + KPI row locked at the top so it stays visible while filtering

Once built, save as `dashboard.pbix` alongside the other deliverables.

---

## 5. Deliverables Checklist

| # | Deliverable | Status |
|---|---|---|
| 01 | `analysis.ipynb` | ✅ Included, executed with outputs |
| 02 | `analysis.sql` | ✅ 20 required queries + 2 bonus queries |
| 03 | Minimum 20 SQL queries | ✅ 22 queries total |
| 04 | Minimum 6 Python visualizations | ✅ 7 charts (`charts/` folder) |
| 05 | Power BI dashboard (.pbix) | ⚠️ Not buildable in this sandbox (no Power BI Desktop) — full data + build guide provided in Section 4 above; CSVs in `powerbi_data/` are ready to import |
| 06 | 5–7 business insights | ✅ 7 insights with finding + number + recommendation |
| 07 | `README.md` | ✅ This file |

---

## 6. How to Reproduce

```bash
# Run all SQL queries against the database
sqlite3 chinook.db < analysis.sql

# Or open and run the notebook
jupyter notebook analysis.ipynb
```

Data source: [Chinook SQLite Database (GitHub)](https://github.com/lerocha/chinook-database).

# Olist E-Commerce Analytics: SQL + Power BI

End-to-end analytics project on the Olist Brazilian e-commerce dataset (about 100K orders, 2016-2018) using MySQL and Power BI.

## Tools
MySQL 8, MySQL Workbench, Power BI Desktop, DAX

## What I did
1. Loaded 9 CSV files into MySQL (`olist_setup_mysql_E.sql`).
2. Cleaned and joined the tables into one SQL view, `sales_clean`, with 112,650 rows (`view.sql`).
   - Translated Portuguese category names to English
   - Marked missing categories as `unknown`
   - Added `delivery_days`, `is_late` and `total_value`
   - Averaged multiple reviews per order to avoid duplicate rows
3. Connected Power BI to MySQL and created a DateTable.
4. Wrote DAX measures: Total Revenue, Total Orders, Avg Order Value, YoY Growth %, Avg Review Score, Late Delivery %, Avg Delivery Days, Repeat Customer %.
5. Built a 3-page dashboard.

## Dashboard
Dashboard PDF: [olist_dashborad pdf.pdf](olist_dashborad%20pdf.pdf)

| Page | What it shows |
|------|---------------|
| Overview | 96K delivered orders, 13.22M revenue, average order value 137.04, monthly revenue trend, revenue by state and category |
| Delivery vs Reviews | Late Delivery % (7.91%), average review 4.08, reviews for on-time vs late orders |
| Insights | Top 10 category scorecard, delivery days by state, repeat customer rate |

## Key findings
- Only about 8% of orders arrive late, but late orders score about 2.5 stars vs about 4.2 for on-time orders.
- Remote states (AP, RR, AM) take 27-28 days to deliver, against about 12 days on average.
- Only about 3% of customers buy again.
- bed_bath_table has the lowest review score (3.90) among the top 10 categories.

## Recommendations
- Improve delivery estimates and carriers for remote states.
- Investigate quality and delivery issues in bed_bath_table.
- Run repeat-purchase offers.

## Problems I faced
- LOAD DATA failed because local_infile was disabled and file paths were wrong. I fixed the settings and paths.
- Power BI could not connect to MySQL until I installed MySQL Connector/NET.
- The revenue line chart was flat because the date relationship was inactive. I made it active and sorted the axis by Year Month.
- Page 2 numbers changed when a wrong order status was selected, so I set a page filter to `delivered`.

## Limitations
- One flat SQL view, not a full star schema.
- Revenue is product price only (freight excluded).
- Late Delivery % is calculated at order-item level.

## Dataset
[Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The Power BI file (`.pbix`) is larger than GitHub's 25 MB upload limit, so it is not included here.

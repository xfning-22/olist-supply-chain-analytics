# Olist E-Commerce | Sales & Supply Chain Analytics

**Tech stack:** MySQL 8.0 · SQL · Power BI Desktop · DAX · Relational data modeling  
**Source:** [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Project overview

An independent portfolio project examining sales concentration, seller activity, and delivery performance using historical Brazilian e-commerce data. Data was imported into MySQL, analyzed with SQL, and visualized in two pages of a Power BI report.

**Business questions**
1. How long do eligible deliveries take, and which customer states experience lower on-time performance?
2. How are merchandise sales distributed across sellers, seller states, and months?

## Dashboard pages

### Logistics Performance
- KPI cards: delivered orders, average delivery days, and on-time delivery rate
- On-time rate by **customer state**
- Monthly average delivery days by **purchase month**

### Sales & Seller Performance
- KPI cards: item sales, active sellers, and item sales per active seller
- Merchandise value by **seller state**
- Monthly item-sales trend using purchase month

> **Power BI report:** [Download commercial.pbix](commercial.pbix) (the native two-page Power BI Desktop report). Screenshots of both report pages can also be added to `screenshots/`.

## Selected results

| Metric | Observed value | Interpretation |
|---|---:|---|
| Item sales | **~R$13.59M** | Sum of item prices; excludes freight, does not represent net revenue |
| Active sellers | **3,095** | Distinct seller IDs in order-item rows |
| Item sales per seller | **~R$4.39K** | Item sales divided by active sellers |
| Delivered orders in analysis | **96,478** | Completed orders with non-null actual and estimated delivery timestamps |
| Average delivery duration | **12.50 calendar days** | MySQL `DATEDIFF` from purchase to arrival |
| On-time delivery rate | **91.89%** | Actual delivery **timestamp** on/before estimated timestamp |
| São Paulo sellers' sales share | **64.40%** | Share of matched item sales from sellers located in SP |

The displayed values were obtained from local SQL and Power BI analyses. Rounded Power BI numbers may differ slightly from underlying unrounded values.

## Business findings

**Seller concentration.** Sellers in São Paulo accounted for roughly 64.4% of the merchandise value in matched seller/order-item records. This describes sales concentration, not seller profitability.

**Normalization changes the ranking.** States rank differently by total sales versus sales per active seller. Very small seller populations can produce misleadingly high averages, so a minimum-active-seller filter is useful when making regional comparisons.

**Regional delivery variation.** The analyzed on-time rate was **76.07% in Alagoas** versus **94.11% in São Paulo**; geographic differences warrant investigation but are not proof of a specific carrier, route, or warehouse problem.

**Check low-volume months.** Early or late months can have incomplete coverage and unusually few orders. A visual-level order-count threshold can reduce low-volume noise, but cannot prove that a month is complete.

## Data architecture

- `olist_sellers_dataset` (1) → `olist_order_items_dataset` (*) via `seller_id`
- `olist_orders_dataset` (1) → `olist_order_items_dataset` (*) via `order_id`
- MySQL joins `olist_orders_dataset` and `olist_customers_dataset` on `customer_id` to create `vw_delivery_performance`
- The delivery VIEW is imported separately for the logistics report page

Representative analysis includes `INNER JOIN`, `COUNT(DISTINCT)`, `GROUP BY`, `HAVING`, CTEs, window functions, `CASE WHEN`, `DATEDIFF`, and SQL VIEW creation. DAX measures use `SUM`, `COUNTROWS`, `DISTINCTCOUNT`, `AVERAGE`, and `DIVIDE`.

## Repository contents

| File | Purpose |
|---|---|
| [sql/analysis.sql](sql/analysis.sql) | Representative MySQL queries and delivery VIEW |
| [powerbi/measures.md](powerbi/measures.md) | DAX measures, date columns, and model setup |
| [commercial.pbix](commercial.pbix) | Native Power BI Desktop report; **uploaded** |
| `screenshots/` | Optional final dashboard screenshots; **upload pending** |

## Reproduction steps

1. Download the public Olist CSV dataset from the Kaggle link above.
2. Import customers, sellers, orders, and order-items CSVs into a MySQL schema named `olist_ecommerce`, retaining the original table names.
3. Run the delivery VIEW creation in [sql/analysis.sql](sql/analysis.sql).
4. Use Power BI's MySQL connector (Import mode) to load the delivery VIEW and the relevant base tables.
5. Create the two one-to-many sales relationships and DAX calculations as shown in [powerbi/measures.md](powerbi/measures.md).
6. Build the two dashboard pages, or open the locally saved PBIX after it has been uploaded.

Do **not** commit local database credentials, passwords, or personal connection configuration.

## Methodological notes

- The dataset is historical (roughly 2016–2018); this project does not report present-day operational performance.
- Item sales sum order-item prices irrespective of payment, cancellation, or refund accounting; they are not recognized revenue, margin, or profit. The sales page does **not** impose a delivered-status filter.
- The logistics cohort excludes undelivered orders and deliveries with missing dates.
- **Important:** The implemented on-time definition compares full timestamps. A package delivered later on the estimated delivery *date* can be classified late when its estimated timestamp is midnight. Accordingly, this is **not** an official SLA compliance measure.
- `DATEDIFF` measures differences in calendar dates, not operating hours or business days.
- Observational correlations are not causal explanations of logistics problems.

*Independent project based on a public dataset; not affiliated with Olist.*

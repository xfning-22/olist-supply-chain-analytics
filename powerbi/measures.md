# Power BI measures and model

## Tables and relationships

Rename the Power BI imported tables to `Order Items`, `Sellers`, `Orders`, and `Delivery`.

- `Sellers[seller_id]` (1) → `Order Items[seller_id]` (*) — single-direction filtering
- `Orders[order_id]` (1) → `Order Items[order_id]` (*) — single-direction filtering
- `Delivery` is the separate imported MySQL VIEW `vw_delivery_performance`.

## Logistics page DAX (Delivery)

```dax
Delivered Orders =
COUNTROWS('Delivery')
```

```dax
Average Delivery Days =
AVERAGE('Delivery'[delivery_days])
```

```dax
On-Time Delivery Rate =
AVERAGE('Delivery'[is_on_time])
```

Format On-Time Delivery Rate as percentage, two decimal places. The VIEW uses the **timestamp-based** estimated delivery threshold.

## Sales page DAX (Order Items)

```dax
Total Item Sales (BRL) =
SUM('Order Items'[price])
```

```dax
Active Sellers =
DISTINCTCOUNT('Order Items'[seller_id])
```

```dax
Sales per Seller (BRL) =
DIVIDE([Total Item Sales (BRL)], [Active Sellers])
```

```dax
Sales Orders =
DISTINCTCOUNT('Order Items'[order_id])
```

## Date columns

Create in the `Delivery` table:

```dax
Order Month =
DATE(
    YEAR('Delivery'[order_purchase_timestamp]),
    MONTH('Delivery'[order_purchase_timestamp]),
    1
)
```

Create in `Orders`:

```dax
Order Month =
DATE(
    YEAR('Orders'[order_purchase_timestamp]),
    MONTH('Orders'[order_purchase_timestamp]),
    1
)
```

Format each month field as `yyyy-MM`. Use the raw **Order Month** column (not automatic Date Hierarchy) on X-axis.

## Report visuals

**Logistics Performance**
- KPI cards: Delivered Orders, Average Delivery Days, On-Time Delivery Rate
- Horizontal bar: Y = Delivery[customer_state], X = On-Time Delivery Rate
- Line: X = Delivery[Order Month], Y = Average Delivery Days, Tooltip = Delivered Orders
- Optional minimum sample filter at visual level: Delivered Orders >= 100

**Sales & Seller Performance**
- KPI cards: Total Item Sales (BRL), Active Sellers, Sales per Seller (BRL)
- Horizontal bar: Y = Sellers[seller_state], X = Total Item Sales; other sales measures in tooltips
- Line: X = Orders[Order Month], Y = Total Item Sales, tooltips = Sales Orders
- Optional minimum sample filter at visual level: Sales Orders >= 100

## Observed validation figures

- Eligible deliveries: **96,478**; average calendar days: **12.50**; timestamp-based on-time percentage: **91.89%**
- Item sales: **~R$13.59M**; active sellers: **3,095**; sales per seller: **~R$4.39K**

These are local portfolio results, not live company operational metrics.

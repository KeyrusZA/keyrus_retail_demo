# Live-edit snippets (keep this file open in a second tab during the demo)

All edits happen in `models/semantic/metrics.yml`, on the `net_revenue` metric.

## Starting state (already in the file — do not touch before the demo)

```yaml
  - name: net_revenue
    label: Net Revenue (ZAR)
    description: >
      Gross revenue minus discounts. The single, governed definition of
      net revenue for all reporting.
    type: simple
    type_params:
      measure: net_revenue_zar
```

**Number the audience sees:** R 16,936,421.16 — same wrong number as the naive
Tableau calculated field, because it still counts returned and cancelled orders.

## LIVE EDIT 1 — add the status filter (demo step 2)

Paste directly under `measure: net_revenue_zar` (same indent as `type_params`):

```yaml
    filter: |
      {{ Dimension('order_item__order_status') }} = 'completed'
```

Then: `dbt build --select fct_order_items+` (or run the job) → tests pass.

**Number after refresh:** R 15,383,364.89 (drops by R 1,553,056.27).

## LIVE EDIT 2 — exclude Gift Cards (demo step 6, "close the loop")

Replace the filter block from edit 1 with:

```yaml
    filter: |
      {{ Dimension('order_item__order_status') }} = 'completed'
      and {{ Dimension('order_item__product_category') }} != 'Gift Cards'
```

Re-run, then refresh the Tableau view.

**Number after refresh:** R 14,906,352.39 (drops by another R 477,012.50).

Talking point: "Nobody touched Tableau. The definition changed once, in a
version-controlled file, behind a test and a pull request — and every dashboard
that uses this metric now agrees."

## The "before" Tableau calculated field (demo step 1)

In the throwaway workbook connected directly to Snowflake
(`analytics.marts.fct_order_items`):

```
// Net Revenue — manually recreated, the "before" picture
SUM([Gross Amount Zar] - [Discount Zar])
```

This returns R 16,936,421.16 — and silently includes returns, cancellations
and gift cards. That's the number that "doesn't reconcile" across teams.

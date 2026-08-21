# Keyrus Retail Demo — dbt + Tableau Webinar

Demo dbt project for the Keyrus webinar **"From Data Chaos to Trusted Decisions"**
(27 August 2026). A generic South African retail dataset (customers, products,
orders, order line items — amounts in ZAR, customers across all nine provinces)
with a governed metric layer on top, built to be connected live to Tableau Cloud
via the dbt Semantic Layer connector.

No client data, no client schemas — everything is synthetic and deterministic.

## Project structure

```
seeds/                      Synthetic raw data (loaded with `dbt seed`)
  raw_customers.csv         500 customers, 9 provinces
  raw_products.csv          35 products, 6 categories (incl. Gift Cards — used in the demo)
  raw_orders.csv            4,000 orders, Jan 2025 – Aug 2026 (completed / returned / cancelled)
  raw_order_items.csv       7,552 line items with quantities and discounts
models/staging/             Views: rename, type, light cleanup + source tests
models/marts/               Tables: dim_customers, fct_orders, fct_order_items + exposure
models/semantic/            Semantic Layer: semantic models, metrics, time spine
DEMO_SNIPPETS.md            The two live-edit snippets, copy-paste ready
```

## One-time setup in dbt Cloud (before the webinar)

1. Create a dbt Cloud project (Team/Enterprise tier) connected to the demo
   Snowflake account, and point it at this repo.
2. In the IDE or via a job, run:

   ```
   dbt seed
   dbt build
   ```

   Expected result: 4 seeds, 8 models, 29 tests — all passing.
3. Create a **Production environment** and run a job there at least once
   (the Semantic Layer serves from the production environment's artifacts).
4. Enable the **Semantic Layer**: Account Settings → project → Semantic Layer →
   configure against the production environment. Note the **Host** and
   **Environment ID**.
5. Create a **service token** scoped to *Semantic Layer Only* and store it
   securely (Account Settings → Service Tokens).
6. In Tableau Cloud: Connect to Data → **dbt Semantic Layer (dbt Labs)** →
   sign in with Host, Environment ID and the service token. Confirm the
   metrics list shows: Gross Revenue (ZAR), Net Revenue (ZAR), Total Discounts
   (ZAR), Items Sold, Total Orders, Average Order Value (ZAR).

## The demo hinge: `models/semantic/metrics.yml`

The `net_revenue` metric ships in its deliberately naive "before" state (it
still counts returned/cancelled orders and gift cards). The two scripted live
edits — adding the status filter, then excluding gift cards — are in
`DEMO_SNIPPETS.md` together with the exact numbers the audience should see
at each stage.

## Verified numbers (deterministic — same on any warehouse)

| Stage | Net Revenue (ZAR) |
|---|---|
| Shipped state (naive, no filter) | R 16,936,421.16 |
| After live edit 1 (completed orders only) | R 15,383,364.89 |
| After live edit 2 (also excluding Gift Cards) | R 14,906,352.39 |

Completed orders: 3,621 · Top province: Gauteng (~R 5.15m) · Top category: Electronics.

## Local development (optional)

The project has **no package dependencies** and runs on any dbt adapter.
For a quick local check with DuckDB:

```yaml
# ~/.dbt/profiles.yml
keyrus_retail_demo:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: keyrus_demo.duckdb
      threads: 4
```

```
dbt build
```

Note: the Semantic Layer itself (metric queries, the Tableau connector) only
runs in dbt Cloud — locally you can parse and build, which validates all the
semantic YAML.

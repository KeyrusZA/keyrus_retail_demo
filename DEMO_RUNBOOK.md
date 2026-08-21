# Live Demo Run Book — dbt + Tableau Webinar

**Presenter:** Dandre Diedericks · **Segment:** Agenda item 3, 15–20 min
**Webinar:** From Data Chaos to Trusted Decisions — 27 August 2026, 12:00–13:00 SAST

Everything below assumes the `keyrus_retail_demo` project is set up in dbt Cloud
per its README, and the dry run has been done from the presenting machine.

---

## Pre-flight checklist (day before + 30 min before)

Day before, from the actual presenting machine and network:

- [ ] dbt Cloud production job runs green (4 seeds, 8 models, 29 tests)
- [ ] Semantic Layer status healthy (Account Settings → project → Semantic Layer)
- [ ] Tableau Cloud connects via the "dbt Semantic Layer (dbt Labs)" connector — specifically test for the **"Failed ALPN"** gRPC error; if it appears, switch off the corporate VPN/proxy (Zscaler/Check Point) or use the clean demo machine
- [ ] `net_revenue` in `models/semantic/metrics.yml` is in its **naive starting state** (no `filter:` block) — if a previous rehearsal left the filters in, remove them and re-run the job
- [ ] Fallback screen recording of the full flow is on the desktop, tested with audio off
- [ ] Record the rehearsal numbers; they must match: **16,936,421.16 → 15,383,364.89 → 14,906,352.39**

30 minutes before going live:

- [ ] Log in: dbt Cloud IDE (project open on `models/semantic/metrics.yml`) + `DEMO_SNIPPETS.md` open in a second IDE tab
- [ ] Tableau Cloud open in a second browser window: the "before" workbook AND a fresh Semantic Layer data source, both pre-authenticated
- [ ] Service token pasted into a password manager / notepad ready to show the sign-in flow (or pre-save credentials and just narrate them)
- [ ] Close Slack/Teams/email; hide bookmarks bar; 125% browser zoom for legibility on Demio
- [ ] Do NOT run the production job between now and the demo

---

## The one-sentence story

> "Watch one metric definition change once, in a governed, tested, version-controlled
> file — and every Tableau dashboard update automatically. That's the fix for
> 'our numbers don't match'."

---

## Step 1 — Set the scene: the "before" picture (1 min)

**Show:** the throwaway Tableau workbook connected *directly* to Snowflake, with a
manually created calculated field:

```
SUM([Gross Amount Zar] - [Discount Zar])   →   R 16,936,421.16
```

**Say:** "This is how most Tableau estates work today. An analyst recreated 'Net
Revenue' as a calculated field. It looks right. It's actually wrong — it's counting
returned orders, cancelled orders, and gift card sales. And there are forty other
workbooks, each with their own version of this field. That's the thousand-dashboards
problem Craig just described."

## Step 2 — The governed definition in dbt (5–6 min)

**Show:** dbt Cloud IDE, `models/semantic/metrics.yml`. Walk the `net_revenue`
metric slowly — name, label, description, measure. Point out this is YAML in Git,
not SQL buried in a workbook.

**Scroll briefly** through `sem_order_items.yml` ("entities, dimensions, measures —
the business meaning of the data, defined once") and `marts.yml` ("and here are the
tests and the Tableau exposure — governance is in the same pull request as the code").

**LIVE EDIT 1** — paste from `DEMO_SNIPPETS.md` under the `net_revenue` type_params:

```yaml
    filter: |
      {{ Dimension('order_item__order_status') }} = 'completed'
```

**Say:** "One change, one place. Net revenue means *completed* orders. That
definition is now law for every dashboard downstream."

## Step 3 — Run and validate (2–3 min)

**Do:** in the IDE terminal: `dbt build --select fct_order_items+`
(or trigger the pre-created job — whichever rehearsed faster).

**Show:** the 29 tests passing in the run output. Call out `relationships` and
`accepted_values` on order status by name: "these tests are the audit trail POPIA
auditors ask about — every number is traceable to a tested, versioned definition."

**Optional (if ahead of time):** open the lineage graph / Catalog and show
seed → staging → mart → exposure ("Retail Performance Dashboard") end to end.

## Step 4 — Connect Tableau to the Semantic Layer (3–4 min)

**Do:** Tableau Cloud → New Workbook → Connect to Data → **dbt Semantic Layer
(dbt Labs)** → Host + Environment ID + service token (narrate: "Semantic-Layer-only
token, least privilege").

**Show:** the metrics list appearing: Net Revenue (ZAR), Gross Revenue (ZAR),
Total Orders, Average Order Value (ZAR), Items Sold — with dimensions like
province, product category, channel, month.

**Say:** "Tableau didn't connect to tables. It connected to *metrics*."

## Step 5 — Build the viz live (3–4 min)

**Do:** drag **Net Revenue (ZAR)** onto the canvas, then **order date (month)**
across, then **province** or **product category** onto colour. Keep it to one
simple chart.

**Expected numbers:** grand total **R 15,383,364.89**; Gauteng ~R 5.15m on top,
then Western Cape ~R 3.68m, KZN ~R 2.41m; Electronics dominates category views.

**Say:** "No calculated field. No manual SQL. No join logic in Tableau — the
semantic layer even resolved the customer join for the province split. This number
IS the governed definition."

**Pre-empt the quirk:** "You'll notice Tableau displays every metric as SUM —
that's a display convention of the connector, the aggregation actually running is
whatever dbt defines."

## Step 6 — Close the loop (2 min) — the money moment

**Say first:** "Finance just called: gift cards are deferred revenue, they must
come out of net revenue. In the old world that's a change to forty workbooks.
Watch."

**LIVE EDIT 2** — back in dbt, replace the filter with:

```yaml
    filter: |
      {{ Dimension('order_item__order_status') }} = 'completed'
      and {{ Dimension('order_item__product_category') }} != 'Gift Cards'
```

**Do:** re-run (`dbt build --select fct_order_items+`), flip to Tableau, refresh
the data source.

**Show:** the chart updates: **R 15,383,364.89 → R 14,906,352.39** — a visible
R 477k drop, live, with no one touching Tableau.

**Close:** "One definition. Version controlled, tested, peer reviewed — and every
dashboard in the business just started agreeing with Finance. That's dbt plus
Tableau."

---

## Timing budget (target 17 min, hard cap 20)

| Step | Target | Cut first if running long |
|---|---|---|
| 1. Before picture | 1 min | — |
| 2. Metric + live edit 1 | 5 min | Skip the sem_order_items.yml walkthrough |
| 3. Run + tests | 3 min | Skip the Catalog/lineage detour |
| 4. Tableau connect | 3 min | Use the pre-authenticated data source, narrate sign-in |
| 5. Build viz | 3 min | One chart only, skip the colour split |
| 6. Close the loop | 2 min | Never cut — this is the landing |

## If things break

- **Semantic Layer connection fails live ("Failed ALPN" or timeout):** switch to
  the pre-authenticated Tableau data source from the dry run; if that also fails,
  play the fallback recording and narrate over it. Do not debug on air.
- **dbt run fails:** you edited YAML indentation — `filter:` must align with
  `type_params:` (4 spaces). Paste the full metric block from `DEMO_SNIPPETS.md`
  instead of hand-fixing.
- **Numbers don't match the script:** a rehearsal left a filter in place — the
  three checkpoint numbers above tell you exactly which state the metric is in.

## Likely audience questions (from the known limitations)

- *"Can I still join tables in Tableau?"* — No, and that's the point: the Semantic
  Layer performs joins itself via entities; Tableau consumes governed results.
- *"Why does everything say SUM?"* — Display quirk of the connector; the true
  aggregation is the one defined in dbt.
- *"Custom labels?"* — dbt metric labels aren't currently surfaced in Tableau's UI;
  field names come through instead.
- *"Calculated fields on top?"* — Limited: parameter filters and metric/dimension
  selection are supported; general calculated fields on Semantic Layer data are not.
- *"Do we need Enterprise?"* — Semantic Layer needs dbt Team or Enterprise; the
  connector ships natively in Tableau Cloud (2025.2+).

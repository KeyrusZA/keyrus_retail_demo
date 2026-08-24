WITH fct_order_items AS (
  /* Order line item fact: one row per item sold, enriched with product category and order attributes. This is the model the dbt Semantic Layer metrics are defined on.
 Line-item grain semantic model. Revenue metrics are defined on this model so they can be sliced by product category, channel and (via the customer entity join) province.
*/
  SELECT
    *
  FROM {{ ref('keyrus_retail_demo', 'fct_order_items') }}
), untitled_sql AS (
  SELECT
    *
  FROM fct_order_items
)
SELECT
  *
FROM untitled_sql
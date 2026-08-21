with orders as (

    select * from {{ ref('stg_orders') }}

),

order_items as (

    select * from {{ ref('stg_order_items') }}

),

order_totals as (

    select
        order_id,
        count(*) as line_item_count,
        sum(gross_amount_zar) as gross_amount_zar,
        sum(discount_zar) as discount_zar,
        sum(gross_amount_zar - discount_zar) as net_amount_zar
    from order_items
    group by order_id

),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.order_status,
        orders.channel,
        orders.payment_method,
        coalesce(order_totals.line_item_count, 0) as line_item_count,
        coalesce(order_totals.gross_amount_zar, 0) as gross_amount_zar,
        coalesce(order_totals.discount_zar, 0) as discount_zar,
        coalesce(order_totals.net_amount_zar, 0) as net_amount_zar
    from orders
    left join order_totals
        on orders.order_id = order_totals.order_id

)

select * from final

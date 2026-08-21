with order_items as (

    select * from {{ ref('stg_order_items') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

products as (

    select * from {{ ref('stg_products') }}

),

final as (

    select
        order_items.order_item_id,
        order_items.order_id,
        orders.customer_id,
        orders.order_date,
        orders.order_status,
        orders.channel,
        orders.payment_method,
        order_items.product_id,
        products.product_name,
        products.category as product_category,
        order_items.quantity,
        order_items.unit_price_zar,
        order_items.gross_amount_zar,
        order_items.discount_zar,
        order_items.gross_amount_zar - order_items.discount_zar as net_amount_zar,
        order_items.quantity * products.unit_cost_zar as cost_amount_zar
    from order_items
    inner join orders
        on order_items.order_id = orders.order_id
    inner join products
        on order_items.product_id = products.product_id

)

select * from final

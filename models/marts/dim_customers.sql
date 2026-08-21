with customers as (

    select * from {{ ref('stg_customers') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

customer_orders as (

    select
        customer_id,
        count(*) as lifetime_orders,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date
    from orders
    group by customer_id

),

final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customers.email,
        customers.province,
        customers.city,
        customers.customer_segment,
        customers.signup_date,
        coalesce(customer_orders.lifetime_orders, 0) as lifetime_orders,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date
    from customers
    left join customer_orders
        on customers.customer_id = customer_orders.customer_id

)

select * from final

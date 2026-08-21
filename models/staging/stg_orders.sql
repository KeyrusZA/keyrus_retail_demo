with source as (

    select * from {{ ref('raw_orders') }}

),

renamed as (

    select
        order_id,
        customer_id,
        cast(order_date as date) as order_date,
        status as order_status,
        channel,
        payment_method
    from source

)

select * from renamed

with source as (

    select * from {{ ref('raw_order_items') }}

),

renamed as (

    select
        order_item_id,
        order_id,
        product_id,
        quantity,
        cast(unit_price_zar as {{ dbt.type_numeric() }}) as unit_price_zar,
        cast(discount_zar as {{ dbt.type_numeric() }}) as discount_zar,
        cast(quantity * unit_price_zar as {{ dbt.type_numeric() }}) as gross_amount_zar
    from source

)

select * from renamed

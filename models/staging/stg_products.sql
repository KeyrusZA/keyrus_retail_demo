with source as (

    select * from {{ ref('raw_products') }}

),

renamed as (

    select
        product_id,
        product_name,
        category,
        cast(unit_price_zar as {{ dbt.type_numeric() }}) as unit_price_zar,
        cast(unit_cost_zar as {{ dbt.type_numeric() }}) as unit_cost_zar
    from source

)

select * from renamed

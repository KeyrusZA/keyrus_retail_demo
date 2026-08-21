with source as (

    select * from {{ ref('raw_customers') }}

),

renamed as (

    select
        customer_id,
        first_name,
        last_name,
        email,
        province,
        city,
        customer_segment,
        signup_date
    from source

)

select * from renamed

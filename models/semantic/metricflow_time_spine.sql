{{ config(materialized='table') }}

-- Daily time spine for the dbt Semantic Layer (MetricFlow).
-- Pure cross-database SQL: no package dependencies required.

with digits as (

    select 0 as d union all select 1 union all select 2 union all select 3 union all
    select 4 union all select 5 union all select 6 union all select 7 union all
    select 8 union all select 9

),

numbers as (

    select
        ones.d + tens.d * 10 + hundreds.d * 100 + thousands.d * 1000 as n
    from digits as ones
    cross join digits as tens
    cross join digits as hundreds
    cross join digits as thousands

),

spine as (

    select
        cast({{ dbt.dateadd("day", "n", "cast('2024-01-01' as date)") }} as date) as date_day
    from numbers
    where n < 1200  -- 2024-01-01 through ~2027-04

)

select date_day
from spine

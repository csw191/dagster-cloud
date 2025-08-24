
-- ================================================================
-- FILE: models/intermediate/int_family_demographics.sql
-- LOCATION: ~/child_assistance_analytics/models/intermediate/int_family_demographics.sql
-- ================================================================
{{ config(materialized='view') }}
{% set sources = var('data_sources') %}
{% set income_thresholds = var('income_thresholds') %}
{% set benefit_thresholds = var('benefit_thresholds') %}
with 
{%- for source_name, source_config in sources.items() %}
{{ source_name }}_data as (
    select
        family_id,
        {{ source_config['size_column'] }} as family_size,
        {{ source_config['income_column'] }} as monthly_income,
        {{ source_config['amount_column'] }} as benefit_amount,
        {{ source_config['status_column'] }} as status,
        '{{ source_name }}' as program_type,
        last_synced_at
    from {{ ref('stg_' + source_name) }}
){{ "," if not loop.last }}
{%- endfor %},
combined_data as (
    {%- for source_name in sources.keys() %}
    select * from {{ source_name }}_data
    {{ "union all" if not loop.last }}
    {%- endfor %}
)
select
    family_id,
    program_type,
    family_size,
    monthly_income,
    benefit_amount,
    status,
    case 
        when monthly_income <= {{ income_thresholds.low }} then 'Low Income'
        when monthly_income <= {{ income_thresholds.moderate }} then 'Moderate Income'
        else 'Higher Income'
    end as income_category,
    case 
        when benefit_amount >= monthly_income * {{ benefit_thresholds.high_ratio }} then 'High Benefit'
        when benefit_amount >= monthly_income * {{ benefit_thresholds.moderate_ratio }} then 'Moderate Benefit'
        else 'Low Benefit'
    end as benefit_level,
    round((benefit_amount / nullif(monthly_income, 0)) * 100, 2) as benefit_to_income_ratio,
    case
        when family_size >= 5 then 'Large Family'
        when family_size >= 3 then 'Medium Family'
        else 'Small Family'
    end as family_size_category,
    last_synced_at
from combined_data
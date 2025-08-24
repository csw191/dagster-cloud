-- ================================================================
-- FILE: models/marts/summary_program_effectiveness.sql
-- LOCATION: ~/child_assistance_analytics/models/marts/summary_program_effectiveness.sql
-- ================================================================
{{ config(
    materialized='table',
    cluster_by=['program_type', 'income_category']
) }}
{% set programs = var('data_sources').keys() | list %}
{% set income_thresholds = var('income_thresholds') %}
with program_metrics as (
    select
        program_type,
        income_category,
        family_size_category,
        count(distinct family_id) as total_families,
        avg(monthly_income) as avg_monthly_income,
        avg(family_size) as avg_family_size,
        avg(benefit_amount) as avg_benefit_amount,
        avg(benefit_to_income_ratio) as avg_benefit_ratio,
        count(case when status = 'active' then 1 end) as active_families,
        count(case when benefit_level = 'High Benefit' then 1 end) as high_benefit_families,
        count(case when benefit_level = 'Low Benefit' then 1 end) as low_benefit_families
    from {{ ref('dim_families') }}
    group by program_type, income_category, family_size_category
)
select
    program_type,
    income_category,
    family_size_category,
    total_families,
    active_families,
    round((active_families::float / total_families::float) * 100, 2) as participation_rate,
    round(avg_monthly_income, 2) as avg_monthly_income,
    round(avg_family_size, 1) as avg_family_size,
    round(avg_benefit_amount, 2) as avg_benefit_amount,
    round(avg_benefit_ratio, 2) as avg_benefit_ratio,
    high_benefit_families,
    low_benefit_families,
    case 
        when avg_benefit_ratio < 10 then 'Needs Benefit Review'
        when participation_rate < 80 then 'Needs Outreach'
        else 'Performing Well'
    end as program_recommendation,
    current_timestamp() as dbt_updated_at
from program_metrics
order by program_type, income_category, family_size_category
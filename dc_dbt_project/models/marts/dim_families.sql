-- ================================================================
-- FILE: models/marts/dim_families.sql
-- LOCATION: ~/child_assistance_analytics/models/marts/dim_families.sql
-- ================================================================
{{ config(
    materialized='table',
    cluster_by=['program_type', 'income_category']
) }}
select
    family_id,
    program_type,
    family_size,
    family_size_category,
    monthly_income,
    income_category,
    benefit_amount,
    benefit_level,
    benefit_to_income_ratio,
    status,
    last_synced_at,
    current_timestamp() as dbt_updated_at
from {{ ref('int_family_demographics') }}
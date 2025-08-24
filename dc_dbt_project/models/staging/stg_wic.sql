-- ================================================================
-- FILE: models/staging/stg_wic.sql
-- LOCATION: ~/child_assistance_analytics/models/staging/stg_wic.sql
-- ================================================================
{{ config(materialized='view') }}
{{ generate_staging_model('wic') }}
-- ================================================================
-- FILE: models/staging/stg_snap.sql
-- LOCATION: ~/child_assistance_analytics/models/staging/stg_snap.sql
-- ================================================================
{{ config(materialized='view') }}
{{ generate_staging_model('snap') }}

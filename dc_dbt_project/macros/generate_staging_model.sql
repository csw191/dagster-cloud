-- ================================================================
-- FILE: macros/generate_staging_model.sql
-- LOCATION: ~/child_assistance_analytics/macros/generate_staging_model.sql
-- ================================================================

{% macro generate_staging_model(source_name) %}
  {% set source_config = var('data_sources')[source_name] %}
  
  select
    {%- for column in source_config['columns'] %}
    {{ column }}{{ "," if not loop.last }}
    {%- endfor %},
    _fivetran_synced as last_synced_at
  from {{ source('hhs_raw_data', source_config['table_name']) }}
  where _fivetran_deleted = false
    and {{ source_config['filter_column'] }} in (
      {%- for value in source_config['filter_values'] -%}
        '{{ value }}'{{ "," if not loop.last }}
      {%- endfor -%}
    )
{% endmacro %}
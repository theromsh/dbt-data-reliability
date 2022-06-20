{{
  config(
    materialized = 'view',
    bind=False
  )
}}

with elementary_test_results as (
    select * from {{ ref('elementary_test_results') }}
),

alerts_dbt_tests as (
    select id as alert_id,
           data_issue_id,
           test_execution_id,
           test_unique_id,
           model_unique_id,
           detected_at,
           database_name,
           schema_name,
           table_name,
           column_name,
           test_type as alert_type,
           test_sub_type as sub_type,
           test_results_description as alert_description,
           owners,
           tags,
           test_results_query as alert_results_query,
           other,
           test_name,
           test_params,
           severity,
           status
        from elementary_test_results
        where lower(status) != 'pass' and test_type = 'dbt_test'
)

select * from alerts_dbt_tests
{{ dbt_utils.group_by(21) }}
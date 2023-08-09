{# Same as dateadd, but supports timestamps as well and not just dates #}
{% macro edr_timeadd(date_part, number, timestamp_expression) -%}
    {{ return(adapter.dispatch('edr_timeadd', 'elementary')(date_part, number, timestamp_expression)) }}
{%- endmacro %}

{# Snowflake #}
{% macro default__edr_timeadd(date_part, number, timestamp_expression) %}
    dateadd({{ date_part }}, {{ elementary.edr_cast_as_int(number) }}, {{ elementary.edr_cast_as_timestamp(timestamp_expression) }})
{% endmacro %}

{% macro bigquery__edr_timeadd(date_part, number, timestamp_expression) %}
    {%- if date_part | lower in ['second', 'minute', 'hour', 'day'] %}
       timestamp_add({{ elementary.edr_cast_as_timestamp(timestamp_expression) }}, INTERVAL {{ elementary.edr_cast_as_int(number) }} {{ date_part }})
    {%- elif date_part | lower in ['week', 'month', 'quarter', 'year'] %}
       date_add({{ elementary.edr_cast_as_date(timestamp_expression) }}, INTERVAL {{ elementary.edr_cast_as_int(number) }} {{ date_part }})
    {%- else %}
        {{ exceptions.raise_compiler_error("Unsupported date_part in edr_timeadd: ".format(date_part)) }}
    {%- endif %}
{% endmacro %}

{% macro postgres__edr_timeadd(date_part, number, timestamp_expression) %}
    {{ elementary.edr_cast_as_timestamp(timestamp_expression) }} + {{ elementary.edr_cast_as_int(number) }} * INTERVAL '1 {{ date_part }}'
{% endmacro %}

{% macro redshift__edr_timeadd(date_part, number, timestamp_expression) %}
    dateadd({{ date_part }}, {{ elementary.edr_cast_as_int(number) }}, {{ elementary.edr_cast_as_timestamp(timestamp_expression) }})
{% endmacro %}

{% macro spark__edr_timeadd(date_part, number, timestamp_expression) -%}
    {%- if date_part | lower == 'second' %}
        {{ elementary.edr_cast_as_timestamp(timestamp_expression) }} + make_interval(0, 0, 0, 0, 0, 0, {{ number }})
    {%- elif date_part | lower == 'minute' %}
        {{ elementary.edr_cast_as_timestamp(timestamp_expression) }} + make_interval(0, 0, 0, 0, 0, {{ number }}, 0)
    {%- elif date_part | lower == 'hour' %}
        {{ elementary.edr_cast_as_timestamp(timestamp_expression) }} + make_interval(0, 0, 0, 0, {{ number }}, 0, 0)
    {%- elif date_part | lower == 'day' %}
        {{ elementary.edr_cast_as_timestamp(timestamp_expression) }} + make_interval(0, 0, 0, {{ number }}, 0, 0, 0)
    {%- elif date_part | lower == 'week' %}
        {{ elementary.edr_cast_as_timestamp(timestamp_expression) }} + make_interval(0, 0, {{ number }}, 0, 0, 0, 0)
    {%- elif date_part | lower == 'month' %}
        {{ elementary.edr_cast_as_timestamp(timestamp_expression) }} + make_interval(0, {{ number }}, 0, 0, 0, 0, 0)
    {%- elif date_part | lower == 'year' %}
        {{ elementary.edr_cast_as_timestamp(timestamp_expression) }} + make_interval({{ number }}, 0, 0, 0, 0, 0, 0)
    {%- else %}
        {{ exceptions.raise_compiler_error("Unsupported date_part in edr_timeadd: ".format(date_part)) }}
    {%- endif %}
{%- endmacro %}

{{ config(
    materialized='table'
) }}

WITH base_transitions AS (

    SELECT
        activity_from,
        activity_to,
        transition_count,
        patient_count,
        avg_transition_time_minutes,
        min_transition_time_minutes,
        max_transition_time_minutes,
        median_transition_time_minutes,
        p90_transition_time_minutes,
        avg_source_wait_time_minutes
    FROM {{ ref('int_process_bottlenecks') }}

),

classified_bottlenecks AS (

    SELECT
        activity_from,
        activity_to,
        transition_count,
        patient_count,
        avg_transition_time_minutes,
        min_transition_time_minutes,
        max_transition_time_minutes,
        median_transition_time_minutes,
        p90_transition_time_minutes,
        avg_source_wait_time_minutes,

        -- Bottleneck Severity Logic
        CASE
            WHEN avg_transition_time_minutes >= 120
              OR p90_transition_time_minutes >= 240
                THEN 'High'
            WHEN avg_transition_time_minutes >= 60
              OR p90_transition_time_minutes >= 120
                THEN 'Medium'
            ELSE 'Low'
        END AS bottleneck_level

    FROM base_transitions

)

SELECT
    activity_from,
    activity_to,
    transition_count,
    patient_count,
    avg_transition_time_minutes,
    min_transition_time_minutes,
    max_transition_time_minutes,
    median_transition_time_minutes,
    p90_transition_time_minutes,
    avg_source_wait_time_minutes,
    bottleneck_level,
    
    -- Numerical KPI score for dashboard color scales & sorting
    CASE bottleneck_level
        WHEN 'High' THEN 3
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 1
        ELSE 0
    END AS bottleneck_score

FROM classified_bottlenecks
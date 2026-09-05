{{ config(materialized='table') }}

WITH patient_journeys AS (

    SELECT *
    FROM {{ ref('int_patient_journey') }}
    WHERE total_process_time_minutes >= 0

),

classified AS (

    SELECT
        *,
        CASE
            WHEN total_process_time_minutes < 60 THEN 'Fast'
            WHEN total_process_time_minutes <= 180 THEN 'Moderate'
            ELSE 'Slow'
        END AS process_performance

    FROM patient_journeys

)

SELECT
    Patient_ID,
    first_activity,
    last_activity,
    first_event_timestamp,
    last_event_timestamp,
    total_activities,
    total_process_time_minutes,
    total_wait_time_minutes,
    avg_wait_time_minutes,
    total_service_time_minutes,
    recorded_process_time_minutes,
    process_performance,
    CASE process_performance
        WHEN 'Fast' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Slow' THEN 3
    END AS performance_score

FROM classified
{{ config(
    materialized='table'
) }}

WITH patient_events AS (

    SELECT
        Patient_ID,
        Event_ID,
        Activity,
        Department,
        event_timestamp,
        wait_time_minutes,
        service_time_minutes,
        total_process_time,
        Severity,
        Activity_Status,
        Event_Order

    FROM {{ ref('stg_hospital_event_log') }}

    WHERE Patient_ID IS NOT NULL
      AND event_timestamp IS NOT NULL
),

patient_summary AS (

    SELECT

        Patient_ID,

        MIN(event_timestamp) AS first_event_timestamp,

        MAX(event_timestamp) AS last_event_timestamp,

        ARRAY_AGG(
            Activity
            ORDER BY event_timestamp, Event_Order
            LIMIT 1
        )[OFFSET(0)] AS first_activity,

        ARRAY_AGG(
            Activity
            ORDER BY event_timestamp DESC, Event_Order DESC
            LIMIT 1
        )[OFFSET(0)] AS last_activity,

        COUNT(*) AS total_activities,

        SUM(COALESCE(wait_time_minutes, 0))
            AS total_wait_time_minutes,

        ROUND(
            AVG(COALESCE(wait_time_minutes, 0)),
            2
        ) AS avg_wait_time_minutes,

        SUM(COALESCE(service_time_minutes, 0))
            AS total_service_time_minutes,

        SUM(COALESCE(total_process_time, 0))
            AS recorded_process_time_minutes

    FROM patient_events

    GROUP BY Patient_ID
)

SELECT

    Patient_ID,

    first_activity,
    last_activity,

    first_event_timestamp,
    last_event_timestamp,

    total_activities,

    TIMESTAMP_DIFF(
        last_event_timestamp,
        first_event_timestamp,
        MINUTE
    ) AS total_process_time_minutes,

    total_wait_time_minutes,

    avg_wait_time_minutes,

    total_service_time_minutes,

    recorded_process_time_minutes

FROM patient_summary
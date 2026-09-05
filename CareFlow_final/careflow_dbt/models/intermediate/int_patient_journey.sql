{{ config(materialized='table') }}

WITH patient_events AS (

    SELECT
        e.Patient_ID,
        e.Event_ID,
        e.Activity,
        n.Department,
        e.event_timestamp,
        n.wait_time_minutes,
        n.service_time_minutes,
        n.total_process_time,
        n.Severity,
        n.Activity_Status,
        e.event_order

    FROM {{ ref('int_ordered_events') }} e
    INNER JOIN {{ ref('int_normalized_event_log') }} n
        ON e.Event_ID = n.Event_ID

    WHERE e.Patient_ID IS NOT NULL
      AND e.event_timestamp IS NOT NULL
),

patient_summary AS (

    SELECT
        Patient_ID,

        MIN(event_timestamp) AS first_event_timestamp,
        MAX(event_timestamp) AS last_event_timestamp,

        ARRAY_AGG(
            Activity
            ORDER BY event_order ASC
            LIMIT 1
        )[OFFSET(0)] AS first_activity,

        ARRAY_AGG(
            Activity
            ORDER BY event_order DESC
            LIMIT 1
        )[OFFSET(0)] AS last_activity,

        COUNT(*) AS total_activities,

        SUM(COALESCE(wait_time_minutes, 0)) AS total_wait_time_minutes,

        ROUND(
            AVG(COALESCE(wait_time_minutes, 0)),
            2
        ) AS avg_wait_time_minutes,

        SUM(COALESCE(service_time_minutes, 0)) AS total_service_time_minutes,

        SUM(COALESCE(total_process_time, 0)) AS recorded_process_time_minutes

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